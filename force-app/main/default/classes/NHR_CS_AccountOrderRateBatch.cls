/**
 * NHR_CS_AccountOrderRateBatch  (Batch 1 / 2: 集計更新)
 * --------------------------------------------------------------------
 * 取引先(Account)ごとの物件受注率を集計し、以下 6 項目を更新する。
 *   【元請】     CS_ThisFY_DirectOrderRate__c  / CS_PreFY_DirectOrderRate__c
 *   【内装】     CS_ThisFY_Interior_WinRate__c / CS_PreFY_Interior_WinRate__c
 *   【戦略区分】 CS_ThisFY_Strategy_Win_Rate__c / CS_PreFY_Strategy_Win_Rate__c
 *
 * ========= 計算ロジック =========
 *
 * 【1. 元請パターン】(CS_XxFY_DirectOrderRate__c)
 *     分母 = property__c WHERE zyutyusaki__c=Account AND syunkoubi__c 期間内
 *     分子 = 上記のうち property__c.Status__c='受注'
 *
 * 【2. 総合内装/工事店パターン】(CS_XxFY_Interior_WinRate__c)
 *     分母 = property_account__c WHERE Account__c=Account
 *                                   AND account_type__c ∈ 18種 (総合内装A-C + 工事店A-1〜C-5)
 *                                   AND property__r.syunkoubi__c 期間内
 *     分子 = 上記のうち property_account__c.Status__c='受注'
 *
 * 【3. 戦略区分別パターン】(CS_XxFY_Strategy_Win_Rate__c)  ★物件単位の OR 集計
 *     分母 = 元請パターンと同じ (property__c 件数)
 *     分子 = 以下①②③いずれかを満たす property__c の件数 (重複排除)
 *       ① property__c.Status__c='受注'
 *       ② 子 property_account__c.account_type__c ∈ {総合内装A,B,C}
 *          AND property_account__c.Status__c='受注'
 *       ③ 子 property_account__c.account_type__c ∈ 工事店A-1〜C-5 (計15種)
 *          AND property_account__c.Typeofwork__c ∈ {軽鉄ボード,壁装仕上,木質床}
 *          AND property_account__c.Status__c='受注'
 *
 * 会計年度: 7月～翌年6月 (当クラス内ハードコード)
 *
 * ========= 処理対象 Account =========
 *   property__c.zyutyusaki__c で参照されている Account
 *   ∪ property_account__c.Account__c で参照されている Account
 *   (OR + semi-join 制約を避けるため start() 内で事前 AggregateResult で Id を収集)
 *
 * ========= 空白クリア =========
 *   本バッチでは集計対象外の Account は触らない。
 *   finish() で NHR_CS_AccountOrderRateClearBatch を連鎖起動し、
 *   そちらで「本バッチ未処理 かつ 6項目いずれか non-null」な Account を null 化する。
 *
 * ========= 設計メモ =========
 *   - ユーザ指示により NHR_Dao / NHR_Constant は使わず当クラスに全てを集約
 *   - SOQL は CASE WHEN 非対応のため GROUP BY + Apex 側分解方式
 *   - Database.Stateful で 処理済み AccountId / カウンタを保持
 *   - 戦略区分 ②③ は親 property__c.Id Set を作って ① と Set 合算で重複排除
 *
 * ========= 実行 =========
 *   Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
 *   → 終了時 NHR_CS_AccountOrderRateClearBatch が自動連鎖
 */
global without sharing class NHR_CS_AccountOrderRateBatch
    implements Database.Batchable<sObject>, Database.Stateful {

    // =============================================================
    // 定数
    // =============================================================

    /** 会計年度 開始月 (7月固定) */
    @TestVisible
    private static final Integer FISCAL_YEAR_START_MONTH = 7;

    /** 受注ステータス */
    @TestVisible
    private static final String STATUS_ORDERED = '受注';

    /** 総合内装のみ (戦略区分 ②) */
    @TestVisible
    private static final Set<String> SOUGOU_NAISOU_TYPES = new Set<String>{
        '総合内装A', '総合内装B', '総合内装C'
    };

    /** 工事店系のみ (戦略区分 ③ の account_type__c) */
    @TestVisible
    private static final Set<String> KOUJITEN_TYPES = new Set<String>{
        '工事店A-1', '工事店A-2', '工事店A-3', '工事店A-4', '工事店A-5',
        '工事店B-1', '工事店B-2', '工事店B-3', '工事店B-4', '工事店B-5',
        '工事店C-1', '工事店C-2', '工事店C-3', '工事店C-4', '工事店C-5'
    };

    /** 内装パターン対象 = 総合内装 + 工事店 (計18種) */
    @TestVisible
    private static final Set<String> INTERIOR_ACCOUNT_TYPES;
    static {
        INTERIOR_ACCOUNT_TYPES = new Set<String>();
        INTERIOR_ACCOUNT_TYPES.addAll(SOUGOU_NAISOU_TYPES);
        INTERIOR_ACCOUNT_TYPES.addAll(KOUJITEN_TYPES);
    }

    /** 戦略区分 ③ の対象工種 (Typeofwork__c) */
    @TestVisible
    private static final Set<String> STRATEGY_TYPE_OF_WORK = new Set<String>{
        '軽鉄ボード', '壁装仕上', '木質床'
    };

    // =============================================================
    // Stateful
    // =============================================================
    /** Batch2 連鎖用: 本バッチで処理した AccountId 全件 */
    global Set<Id> processedAccountIds = new Set<Id>();

    global Integer totalScanned     = 0;
    global Integer totalUpdated     = 0;
    global Integer totalErrors      = 0;
    global List<String> errorMessages = new List<String>();

    /** テストで Batch2 連鎖を抑止したい場合に true にする */
    @TestVisible
    private static Boolean suppressChainForTest = false;

    // =============================================================
    // 期間キャッシュ
    // =============================================================
    @TestVisible private Date thisFyStart;
    @TestVisible private Date thisFyEnd;
    @TestVisible private Date preFyStart;
    @TestVisible private Date preFyEnd;

    global NHR_CS_AccountOrderRateBatch() {
        Date today = System.today();
        Integer thisFyStartYear =
            (today.month() >= FISCAL_YEAR_START_MONTH) ? today.year() : today.year() - 1;

        this.thisFyStart = Date.newInstance(thisFyStartYear,     FISCAL_YEAR_START_MONTH, 1);
        this.thisFyEnd   = Date.newInstance(thisFyStartYear + 1, FISCAL_YEAR_START_MONTH, 1).addDays(-1);
        this.preFyStart  = Date.newInstance(thisFyStartYear - 1, FISCAL_YEAR_START_MONTH, 1);
        this.preFyEnd    = Date.newInstance(thisFyStartYear,     FISCAL_YEAR_START_MONTH, 1).addDays(-1);
    }

    // =============================================================
    // start
    // =============================================================
    /**
     * 対象 Account:
     *   (A) property__c.zyutyusaki__c で参照されている
     *   (B) property_account__c.Account__c で参照されている
     *
     * SOQL の semi-join + OR 併用制約 ("Semi join sub-selects are not allowed with the 'OR' operator")
     * を回避するため、start() 内で事前に AggregateResult で AccountId を収集し、
     * Id IN :targetIds の単純な条件に変換する。
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> targetIds = collectTargetAccountIds();

        if (targetIds.isEmpty()) {
            // 対象 0 件でも QueryLocator は返す必要があるので、
            // 絶対マッチしない条件でダミーを返す (Bind 変数は維持)
            Set<Id> emptySet = new Set<Id>();
            return Database.getQueryLocator([
                SELECT Id,
                       CS_ThisFY_DirectOrderRate__c,
                       CS_PreFY_DirectOrderRate__c,
                       CS_ThisFY_Interior_WinRate__c,
                       CS_PreFY_Interior_WinRate__c,
                       CS_ThisFY_Strategy_Win_Rate__c,
                       CS_PreFY_Strategy_Win_Rate__c
                FROM Account
                WHERE Id IN :emptySet
            ]);
        }

        return Database.getQueryLocator([
            SELECT Id,
                   CS_ThisFY_DirectOrderRate__c,
                   CS_PreFY_DirectOrderRate__c,
                   CS_ThisFY_Interior_WinRate__c,
                   CS_PreFY_Interior_WinRate__c,
                   CS_ThisFY_Strategy_Win_Rate__c,
                   CS_PreFY_Strategy_Win_Rate__c
            FROM Account
            WHERE Id IN :targetIds
        ]);
    }

    /**
     * 対象 AccountId を 2 クエリの和集合として収集。
     * GROUP BY で distinct 化して Heap を節約。
     */
    @TestVisible
    private Set<Id> collectTargetAccountIds() {
        Set<Id> ids = new Set<Id>();

        for (AggregateResult ar : [
            SELECT zyutyusaki__c aId
            FROM property__c
            WHERE zyutyusaki__c != null
            GROUP BY zyutyusaki__c
        ]) {
            Id v = (Id) ar.get('aId');
            if (v != null) ids.add(v);
        }
        for (AggregateResult ar : [
            SELECT Account__c aId
            FROM property_account__c
            WHERE Account__c != null
            GROUP BY Account__c
        ]) {
            Id v = (Id) ar.get('aId');
            if (v != null) ids.add(v);
        }
        return ids;
    }

    // =============================================================
    // execute
    // =============================================================
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        if (scope == null || scope.isEmpty()) return;
        totalScanned += scope.size();

        Set<Id> acctIds = new Map<Id, Account>(scope).keySet();

        // --- property__c を Account 毎にバケツ分け (元請分母/分子 + 戦略① の原資) ---
        Map<Id, PropertyBucket> bucketsThis = loadPropertyBuckets(acctIds, thisFyStart, thisFyEnd);
        Map<Id, PropertyBucket> bucketsPre  = loadPropertyBuckets(acctIds, preFyStart,  preFyEnd);

        // --- 内装パターン (件数ベース) ---
        Map<Id, RateNum> interiorThis = aggregateInterior(acctIds, thisFyStart, thisFyEnd);
        Map<Id, RateNum> interiorPre  = aggregateInterior(acctIds, preFyStart,  preFyEnd);

        // --- 戦略区分 ②③: 親 property__c Id を Account 毎に集める ---
        Map<Id, Set<Id>> strategyWonThis = collectStrategyChildWonPropIds(
            acctIds, thisFyStart, thisFyEnd);
        Map<Id, Set<Id>> strategyWonPre  = collectStrategyChildWonPropIds(
            acctIds, preFyStart,  preFyEnd);

        List<Account> toUpdate = new List<Account>();
        for (Account a : scope) {
            PropertyBucket bThis = bucketsThis.get(a.Id);
            PropertyBucket bPre  = bucketsPre.get(a.Id);

            // 元請
            Decimal newThisDirect = calcRate( (bThis == null) ? null : bThis.toDirectRateNum() );
            Decimal newPreDirect  = calcRate( (bPre  == null) ? null : bPre.toDirectRateNum() );

            // 内装
            Decimal newThisInter  = calcRate(interiorThis.get(a.Id));
            Decimal newPreInter   = calcRate(interiorPre.get(a.Id));

            // 戦略区分
            Decimal newThisStrat  = calcStrategyRate(bThis, strategyWonThis.get(a.Id));
            Decimal newPreStrat   = calcStrategyRate(bPre,  strategyWonPre.get(a.Id));

            Boolean changed = false;
            if (!equalsDecimal(a.CS_ThisFY_DirectOrderRate__c, newThisDirect)) {
                a.CS_ThisFY_DirectOrderRate__c = newThisDirect; changed = true;
            }
            if (!equalsDecimal(a.CS_PreFY_DirectOrderRate__c, newPreDirect)) {
                a.CS_PreFY_DirectOrderRate__c = newPreDirect; changed = true;
            }
            if (!equalsDecimal(a.CS_ThisFY_Interior_WinRate__c, newThisInter)) {
                a.CS_ThisFY_Interior_WinRate__c = newThisInter; changed = true;
            }
            if (!equalsDecimal(a.CS_PreFY_Interior_WinRate__c, newPreInter)) {
                a.CS_PreFY_Interior_WinRate__c = newPreInter; changed = true;
            }
            if (!equalsDecimal(a.CS_ThisFY_Strategy_Win_Rate__c, newThisStrat)) {
                a.CS_ThisFY_Strategy_Win_Rate__c = newThisStrat; changed = true;
            }
            if (!equalsDecimal(a.CS_PreFY_Strategy_Win_Rate__c, newPreStrat)) {
                a.CS_PreFY_Strategy_Win_Rate__c = newPreStrat; changed = true;
            }

            // Batch2 に渡す: 本バッチで見た Account は全て「処理済み」
            processedAccountIds.add(a.Id);

            if (changed) toUpdate.add(a);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(toUpdate, false);
            for (Integer i = 0; i < results.size(); i++) {
                Database.SaveResult r = results[i];
                if (r.isSuccess()) {
                    totalUpdated++;
                } else {
                    totalErrors++;
                    if (errorMessages.size() < 50) {
                        errorMessages.add(
                            toUpdate[i].Id + ': ' + r.getErrors()[0].getMessage()
                        );
                    }
                }
            }
        }
    }

    // =============================================================
    // finish → Batch2 連鎖
    // =============================================================
    global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO,
            '[NHR_CS_AccountOrderRateBatch] '
            + 'scanned=' + totalScanned
            + ' updated=' + totalUpdated
            + ' errors=' + totalErrors
            + ' processedCount=' + processedAccountIds.size()
        );
        if (totalErrors > 0) {
            System.debug(LoggingLevel.WARN, 'Errors (first 50): ' + errorMessages);
        }

        // 連鎖起動: 本バッチが触っていない Account の 6 項目を null クリア
        // (Test context では Test.stopTest() 内で 1 chained batch が同期実行される)
        if (!suppressChainForTest) {
            Database.executeBatch(
                new NHR_CS_AccountOrderRateClearBatch(processedAccountIds),
                200
            );
        }
    }

    // =============================================================
    // 中間構造体
    // =============================================================

    /** 件数ベースの分母/分子 */
    public class RateNum {
        public Integer numer;
        public Integer denom;
        public RateNum() { this.numer = 0; this.denom = 0; }
        public RateNum(Integer n, Integer d) { this.numer = n; this.denom = d; }
        public void addRow(String status, Integer cnt) {
            this.denom += cnt;
            if (status == STATUS_ORDERED) this.numer += cnt;
        }
    }

    /** 物件単位集計用バケット */
    public class PropertyBucket {
        public Set<Id> totalPropIds = new Set<Id>(); // 期間内 property__c 全Id
        public Set<Id> wonPropIds   = new Set<Id>(); // 上記のうち Status='受注'

        public RateNum toDirectRateNum() {
            return new RateNum(wonPropIds.size(), totalPropIds.size());
        }
    }

    // =============================================================
    // SOQL 集計メソッド
    // =============================================================

    /** 期間内 property__c を Account 毎に PropertyBucket へ格納 */
    @TestVisible
    private Map<Id, PropertyBucket> loadPropertyBuckets(
        Set<Id> acctIds, Date fromDt, Date toDt
    ) {
        Map<Id, PropertyBucket> out = new Map<Id, PropertyBucket>();
        if (acctIds == null || acctIds.isEmpty()) return out;

        for (property__c p : [
            SELECT Id, zyutyusaki__c, Status__c
            FROM property__c
            WHERE zyutyusaki__c IN :acctIds
              AND syunkoubi__c >= :fromDt
              AND syunkoubi__c <= :toDt
        ]) {
            PropertyBucket pb = out.get(p.zyutyusaki__c);
            if (pb == null) { pb = new PropertyBucket(); out.put(p.zyutyusaki__c, pb); }
            pb.totalPropIds.add(p.Id);
            if (p.Status__c == STATUS_ORDERED) pb.wonPropIds.add(p.Id);
        }
        return out;
    }

    /**
     * 内装パターン: property_account__c 件数集計。
     * SOQL CASE WHEN 非対応のため Status__c でグルーピング → Apex で積む。
     */
    @TestVisible
    private Map<Id, RateNum> aggregateInterior(Set<Id> acctIds, Date fromDt, Date toDt) {
        Map<Id, RateNum> out = new Map<Id, RateNum>();
        if (acctIds == null || acctIds.isEmpty()) return out;

        Set<String> types = INTERIOR_ACCOUNT_TYPES;

        for (AggregateResult ar : [
            SELECT Account__c acctId,
                   Status__c  st,
                   COUNT(Id)  cnt
            FROM property_account__c
            WHERE Account__c IN :acctIds
              AND account_type__c IN :types
              AND property__r.syunkoubi__c >= :fromDt
              AND property__r.syunkoubi__c <= :toDt
            GROUP BY Account__c, Status__c
        ]) {
            Id acctId = (Id) ar.get('acctId');
            String st = (String) ar.get('st');
            Integer cnt = toIntSafe(ar.get('cnt'));

            RateNum rn = out.get(acctId);
            if (rn == null) { rn = new RateNum(); out.put(acctId, rn); }
            rn.addRow(st, cnt);
        }
        return out;
    }

    /**
     * 戦略区分 ②③ の分子対象 親 property__c Id を Account 毎に集める。
     *   ②: account_type__c ∈ 総合内装A-C + Status='受注' → 親 property__c Id
     *   ③: account_type__c ∈ 工事店系15種 + Typeofwork__c ∈ 対象3値 + Status='受注' → 親 property__c Id
     */
    @TestVisible
    private Map<Id, Set<Id>> collectStrategyChildWonPropIds(
        Set<Id> acctIds, Date fromDt, Date toDt
    ) {
        Map<Id, Set<Id>> out = new Map<Id, Set<Id>>();
        if (acctIds == null || acctIds.isEmpty()) return out;

        // ② 総合内装 A-C × Status='受注'
        Set<String> sougouTypes = SOUGOU_NAISOU_TYPES;
        for (property_account__c pa : [
            SELECT Account__c, property__c
            FROM property_account__c
            WHERE Account__c IN :acctIds
              AND account_type__c IN :sougouTypes
              AND Status__c = :STATUS_ORDERED
              AND property__c != null
              AND property__r.syunkoubi__c >= :fromDt
              AND property__r.syunkoubi__c <= :toDt
        ]) {
            addToSetMap(out, pa.Account__c, pa.property__c);
        }

        // ③ 工事店系 × 対象工種 × Status='受注'
        Set<String> koujitenTypes = KOUJITEN_TYPES;
        Set<String> workTypes     = STRATEGY_TYPE_OF_WORK;
        for (property_account__c pa : [
            SELECT Account__c, property__c
            FROM property_account__c
            WHERE Account__c IN :acctIds
              AND account_type__c IN :koujitenTypes
              AND Typeofwork__c IN :workTypes
              AND Status__c = :STATUS_ORDERED
              AND property__c != null
              AND property__r.syunkoubi__c >= :fromDt
              AND property__r.syunkoubi__c <= :toDt
        ]) {
            addToSetMap(out, pa.Account__c, pa.property__c);
        }
        return out;
    }

    private static void addToSetMap(Map<Id, Set<Id>> m, Id key, Id val) {
        if (key == null || val == null) return;
        Set<Id> s = m.get(key);
        if (s == null) { s = new Set<Id>(); m.put(key, s); }
        s.add(val);
    }

    // =============================================================
    // ユーティリティ
    // =============================================================

    /** 件数ベース受注率 (パーセント・小数2桁・HALF_UP) */
    @TestVisible
    private static Decimal calcRate(RateNum r) {
        if (r == null || r.denom == null || r.denom == 0) return null;
        Integer numer = (r.numer == null) ? 0 : r.numer;
        Decimal pct = (Decimal.valueOf(numer) / Decimal.valueOf(r.denom)) * 100;
        return pct.setScale(2, System.RoundingMode.HALF_UP);
    }

    /**
     * 戦略区分受注率:
     *   分母 = bucket.totalPropIds.size()
     *   分子 = bucket.wonPropIds ∪ childWonPropIds の size
     *   (ただし分母スコープ内の Id のみカウント ＝ bucket.totalPropIds との交差)
     */
    @TestVisible
    private static Decimal calcStrategyRate(PropertyBucket bucket, Set<Id> childWonPropIds) {
        if (bucket == null || bucket.totalPropIds == null || bucket.totalPropIds.isEmpty()) {
            return null;
        }
        Integer denom = bucket.totalPropIds.size();

        Set<Id> unionWon = new Set<Id>();
        unionWon.addAll(bucket.wonPropIds);                  // ①
        if (childWonPropIds != null) {
            // ②③ の親 Id は必ず期間内 property__c の Id であるため
            // bucket.totalPropIds に含まれるが、念のため交差を取る
            for (Id pid : childWonPropIds) {
                if (bucket.totalPropIds.contains(pid)) unionWon.add(pid);
            }
        }
        Integer numer = unionWon.size();

        Decimal pct = (Decimal.valueOf(numer) / Decimal.valueOf(denom)) * 100;
        return pct.setScale(2, System.RoundingMode.HALF_UP);
    }

    /** Decimal null 安全一致 */
    @TestVisible
    private static Boolean equalsDecimal(Decimal a, Decimal b) {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        return a == b;
    }

    /** AggregateResult の数値を Integer 化 */
    private static Integer toIntSafe(Object v) {
        if (v == null) return 0;
        if (v instanceof Integer) return (Integer) v;
        if (v instanceof Decimal) return ((Decimal) v).intValue();
        return Integer.valueOf(String.valueOf(v));
    }
}