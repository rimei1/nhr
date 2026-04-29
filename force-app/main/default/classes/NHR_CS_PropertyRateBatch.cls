/**
 * NHR_CS_PropertyRateBatch
 *
 * CS物件（property__c）の「物件把握率」「物件受注率」を夜間バッチで再計算する。
 * 1バッチで両指標を同時計算する統合バッチ。
 *
 * 【更新項目】
 *   - property__c.CS_PropertyCoverageRate__c (物件把握率)
 *   - property__c.CS_PropertyWinRate__c      (物件受注率)
 *
 * 【動作モード】
 *   - 差分モード（デフォルト）: 過去24h以内に更新された property、
 *     または子の property_account__c が更新された property を対象
 *   - 全件モード: property__c 全件を対象（削除起因のズレを完全リカバリ）
 *
 * 【分母（積み上げ式）】
 *   - 把握率: 5 → 9 → 13 (元請を含む)
 *   - 受注率: 4 → 8 → 12 (元請を含まない)
 *   - 段階トリガー: 総合内装B/C の account__c が「該当無し」以外で埋まっているか
 *   - 「該当無し（001RC00001MkQNJYA3）」のみで構成される枠は分母から -1（元請は対象外）
 *
 * 【分子】
 *   - 把握率: 対応する枠で「該当無し」以外の account__c が埋まっているレコードが存在
 *   - 受注率: 上記 ＋ property_account__c.Status__c = '受注' のレコードが存在
 *   - 把握率の元請: property__c.zyutyusaki__c が埋まっていれば +1
 *   - 同一枠に複数レコードがある場合も最大1としてカウント（A案: 枠ベース）
 *
 * 【起動】
 *   Flow スケジュールから:
 *     差分: Database.executeBatch(new NHR_CS_PropertyRateBatch(), 200);
 *     全件: Database.executeBatch(new NHR_CS_PropertyRateBatch(true), 200);
 */
global without sharing class NHR_CS_PropertyRateBatch
    implements Database.Batchable<sObject>, Database.Stateful {

    // ============================================================
    // 定数（NHR_Constant 不使用方針 - クラス内で定義）
    // ============================================================

    /** 「該当無し」を表す Account ID */
    private static final Id NOT_APPLICABLE_ACCOUNT_ID = System.Label.CS_None ;

    /** property_account__c.Status__c の「受注」値 */
    private static final String STATUS_ORDERED = '受注';

    /** account_type__c 値: 総合内装 A/B/C */
    private static final String TYPE_INTERIOR_A = '総合内装A';
    private static final String TYPE_INTERIOR_B = '総合内装B';
    private static final String TYPE_INTERIOR_C = '総合内装C';

    /** account_type__c 値: 工事店 A系 */
    private static final Set<String> TYPES_KOJITEN_A = new Set<String>{
        '工事店A-1', '工事店A-2', '工事店A-3'
    };

    /** account_type__c 値: 工事店 B系 */
    private static final Set<String> TYPES_KOJITEN_B = new Set<String>{
        '工事店B-1', '工事店B-2', '工事店B-3'
    };

    /** account_type__c 値: 工事店 C系 */
    private static final Set<String> TYPES_KOJITEN_C = new Set<String>{
        '工事店C-1', '工事店C-2', '工事店C-3'
    };

    /** カウント / 減算の対象となる種別の全体集合 */
    private static final Set<String> INTERIOR_TYPES;
    static {
        INTERIOR_TYPES = new Set<String>{ TYPE_INTERIOR_A, TYPE_INTERIOR_B, TYPE_INTERIOR_C };
        INTERIOR_TYPES.addAll(TYPES_KOJITEN_A);
        INTERIOR_TYPES.addAll(TYPES_KOJITEN_B);
        INTERIOR_TYPES.addAll(TYPES_KOJITEN_C);
    }

    /** 差分判定の遡り時間（24時間） */
    private static final Integer DIFF_HOURS = 24;

    /** ジョブ名（ログ用） */
    private static final String JOB_NAME = 'NHR_CS_PropertyRateBatch';

    // ============================================================
    // モード切替
    // ============================================================

    /** true: 全件モード / false: 差分モード（デフォルト） */
    private Boolean isFullRecalc = false;

    // ============================================================
    // 集計用 Stateful フィールド
    // ============================================================

    global Integer processedCount = 0;
    global Integer updatedCount = 0;
    global Integer errorCount = 0;

    // ============================================================
    // コンストラクタ
    // ============================================================

    global NHR_CS_PropertyRateBatch() {
        this(false);
    }

    global NHR_CS_PropertyRateBatch(Boolean fullRecalc) {
        this.isFullRecalc = (fullRecalc == true);
    }

    // ============================================================
    // Batchable 実装
    // ============================================================

    global Database.QueryLocator start(Database.BatchableContext bc) {
        if (isFullRecalc) {
            System.debug(LoggingLevel.INFO, JOB_NAME + ' starting in FULL recalc mode');
            return Database.getQueryLocator([
                SELECT Id,
                       zyutyusaki__c,
                       CS_PropertyCoverageRate__c,
                       CS_PropertyWinRate__c
                FROM property__c
            ]);
        }

        DateTime cutoff = DateTime.now().addHours(-DIFF_HOURS);
        System.debug(LoggingLevel.INFO,
            JOB_NAME + ' starting in DIFF mode, cutoff=' + cutoff);

        // SOQL の制約上、「LastModifiedDate >= cutoff OR Id IN (semi-join)」は
        // 使用不可（Semi join sub-selects are not allowed with the OR operator）。
        // そのため、子の property_account__c から親 Id を先に集め、
        // 最終クエリでは Id IN :combined と LastModifiedDate >= :cutoff を OR で結合する
        // 代わりに、Id 集合を事前にマージして単一の Id IN :ids で取得する。
        Set<Id> targetPropertyIds = new Set<Id>();

        // ① 自身が更新された property の Id
        for (property__c p : [
            SELECT Id FROM property__c
            WHERE LastModifiedDate >= :cutoff
        ]) {
            targetPropertyIds.add(p.Id);
        }

        // ② 子の property_account__c が更新された property の Id
        for (property_account__c pa : [
            SELECT property__c FROM property_account__c
            WHERE LastModifiedDate >= :cutoff
              AND property__c != null
        ]) {
            targetPropertyIds.add(pa.property__c);
        }

        // 対象が0件の場合でも空クエリで終わらせる（QueryLocator は null を返せない）
        return Database.getQueryLocator([
            SELECT Id,
                   zyutyusaki__c,
                   CS_PropertyCoverageRate__c,
                   CS_PropertyWinRate__c
            FROM property__c
            WHERE Id IN :targetPropertyIds
        ]);
    }

    global void execute(Database.BatchableContext bc, List<property__c> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }
        processedCount += scope.size();

        Set<Id> propertyIds = new Set<Id>();
        for (property__c p : scope) {
            propertyIds.add(p.Id);
        }

        Map<Id, Map<String, AccountTypeStat>> statByProperty
            = buildPropertyAccountStats(propertyIds);

        List<property__c> toUpdate = new List<property__c>();
        for (property__c p : scope) {
            Map<String, AccountTypeStat> byType = statByProperty.get(p.Id);

            RateResult res = calcRates(p, byType);

            Boolean changed = isDifferent(p.CS_PropertyCoverageRate__c, res.coverageRate)
                           || isDifferent(p.CS_PropertyWinRate__c, res.winRate);

            if (changed) {
                p.CS_PropertyCoverageRate__c = res.coverageRate;
                p.CS_PropertyWinRate__c      = res.winRate;
                toUpdate.add(p);
            }
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    updatedCount++;
                } else {
                    errorCount++;
                    System.debug(LoggingLevel.ERROR,
                        JOB_NAME + ' update error: '
                        + toUpdate[i].Id + ' / ' + results[i].getErrors());
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO,
            JOB_NAME + ' finished. mode=' + (isFullRecalc ? 'FULL' : 'DIFF')
            + ', processed=' + processedCount
            + ', updated=' + updatedCount
            + ', errors=' + errorCount);
    }

    // ============================================================
    // 集計ロジック
    // ============================================================

    /**
     * property_account__c を集計し、property × account_type__c ごとの状態を返す。
     * 枠ベース集計（同一 property × 同一 type は1枠として扱う）。
     */
    private Map<Id, Map<String, AccountTypeStat>> buildPropertyAccountStats(Set<Id> propertyIds) {
        Map<Id, Map<String, AccountTypeStat>> result
            = new Map<Id, Map<String, AccountTypeStat>>();

        for (property_account__c pa : [
            SELECT Id,
                   property__c,
                   account__c,
                   account_type__c,
                   Status__c
            FROM property_account__c
            WHERE property__c IN :propertyIds
              AND account_type__c IN :INTERIOR_TYPES
        ]) {
            if (pa.property__c == null || pa.account_type__c == null) {
                continue;
            }

            Map<String, AccountTypeStat> byType = result.get(pa.property__c);
            if (byType == null) {
                byType = new Map<String, AccountTypeStat>();
                result.put(pa.property__c, byType);
            }

            AccountTypeStat stat = byType.get(pa.account_type__c);
            if (stat == null) {
                stat = new AccountTypeStat();
                byType.put(pa.account_type__c, stat);
            }

            stat.hasRecord = true;

            Boolean isFilledNonNa = (pa.account__c != null
                                  && pa.account__c != NOT_APPLICABLE_ACCOUNT_ID);
            Boolean isNotApplicable = (pa.account__c == NOT_APPLICABLE_ACCOUNT_ID);

            if (isFilledNonNa) {
                stat.hasFilledNonNa = true;
                if (STATUS_ORDERED.equals(pa.Status__c)) {
                    stat.hasOrdered = true;
                }
            }
            if (isNotApplicable) {
                stat.hasNotApplicable = true;
            }
        }

        return result;
    }

    /**
     * 1物件分の把握率・受注率を計算する。
     */
    @TestVisible
    private RateResult calcRates(property__c p, Map<String, AccountTypeStat> byType) {
        if (byType == null) {
            byType = new Map<String, AccountTypeStat>();
        }

        Boolean hasInteriorB = isFilledNonNa(byType, TYPE_INTERIOR_B);
        Boolean hasInteriorC = isFilledNonNa(byType, TYPE_INTERIOR_C);

        // ===== アクティブ枠の集合 =====
        Set<String> activeTypes = new Set<String>();
        activeTypes.add(TYPE_INTERIOR_A);
        activeTypes.addAll(TYPES_KOJITEN_A);

        Integer coverageBase;
        Integer winBase;

        if (hasInteriorC) {
            coverageBase = 13; winBase = 12;
            activeTypes.add(TYPE_INTERIOR_B);
            activeTypes.addAll(TYPES_KOJITEN_B);
            activeTypes.add(TYPE_INTERIOR_C);
            activeTypes.addAll(TYPES_KOJITEN_C);
        } else if (hasInteriorB) {
            coverageBase = 9; winBase = 8;
            activeTypes.add(TYPE_INTERIOR_B);
            activeTypes.addAll(TYPES_KOJITEN_B);
        } else {
            coverageBase = 5; winBase = 4;
        }

        // ===== 「該当無し」減算（両指標で同じ枠に対して同量を減算） =====
        Integer notApplicableCount = 0;
        for (String t : activeTypes) {
            AccountTypeStat stat = byType.get(t);
            if (stat != null && stat.hasNotApplicable && !stat.hasFilledNonNa) {
                notApplicableCount++;
            }
        }
        Integer coverageDenom = coverageBase - notApplicableCount;
        Integer winDenom      = winBase      - notApplicableCount;

        // ===== 分子計算 =====
        Integer coverageNumer = 0;
        Integer winNumer      = 0;

        // 把握率の元請（受注率には元請を含まない）
        if (p.zyutyusaki__c != null) {
            coverageNumer++;
        }

        // 各枠
        for (String t : activeTypes) {
            AccountTypeStat stat = byType.get(t);
            if (stat == null) continue;
            if (stat.hasFilledNonNa) {
                coverageNumer++;
                if (stat.hasOrdered) {
                    winNumer++;
                }
            }
        }

        // ===== 比率計算 =====
        RateResult res = new RateResult();
        res.coverageRate = computeRate(coverageNumer, coverageDenom);
        res.winRate      = computeRate(winNumer,      winDenom);
        return res;
    }

    /** 比率（％、小数2桁）を計算。分母≤0 の場合は null。 */
    private Decimal computeRate(Integer numer, Integer denom) {
        if (denom == null || denom <= 0) return null;
        // Apex Decimal は multiply(Decimal) を公開していないため、演算子 * を使用する
        Decimal ratio = Decimal.valueOf(numer).divide(Decimal.valueOf(denom), 4);
        return (ratio * 100).setScale(2, System.RoundingMode.HALF_UP);
    }

    private Boolean isFilledNonNa(Map<String, AccountTypeStat> byType, String type) {
        AccountTypeStat stat = byType.get(type);
        return stat != null && stat.hasFilledNonNa;
    }

    private Boolean isDifferent(Decimal oldVal, Decimal newVal) {
        if (oldVal == null && newVal == null) return false;
        if (oldVal == null || newVal == null) return true;
        return oldVal != newVal;
    }

    // ============================================================
    // 内部データクラス
    // ============================================================

    /** 1 property × 1 account_type__c の集計状態 */
    private class AccountTypeStat {
        Boolean hasRecord = false;
        Boolean hasFilledNonNa = false;
        Boolean hasNotApplicable = false;
        Boolean hasOrdered = false;
    }

    /** 計算結果 */
    @TestVisible
    private class RateResult {
        Decimal coverageRate;
        Decimal winRate;
    }
}