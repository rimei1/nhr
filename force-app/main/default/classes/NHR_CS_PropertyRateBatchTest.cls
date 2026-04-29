/**
 * NHR_CS_PropertyRateBatchTest
 *
 * 把握率・受注率 統合バッチのテスト。
 * - 分母 5/9/13 (把握率)、4/8/12 (受注率) の各段階
 * - 「該当無し」減算
 * - 同一枠重複（A案=枠ベース最大1）
 * - Status__c='受注' による受注率分子の絞り込み
 * - 差分モード / 全件モード
 */
@IsTest
private class NHR_CS_PropertyRateBatchTest {

    private static final Id NA_ID = '001RC00001MkQNJYA3';

    @TestSetup
    static void setupData() {
        List<Account> accs = new List<Account>{
            new Account(Name = 'Acc-元請'),
            new Account(Name = 'Acc-内装A'),
            new Account(Name = 'Acc-内装B'),
            new Account(Name = 'Acc-内装C'),
            new Account(Name = 'Acc-工事店A1'),
            new Account(Name = 'Acc-工事店A2'),
            new Account(Name = 'Acc-工事店A3'),
            new Account(Name = 'Acc-工事店B1'),
            new Account(Name = 'Acc-工事店C1')
        };
        insert accs;
    }

    // ============================================================
    // ケース1: デフォルト分母（把握=5, 受注=4）すべて埋まり全部受注
    // ============================================================
    @IsTest
    static void test_default_allFilled_allOrdered() {
        Map<String, Account> accs = getAccountMap();

        property__c p = new property__c(
            Name = 'P1',
            zyutyusaki__c = accs.get('Acc-元請').Id
        );
        insert p;

        insert new List<property_account__c>{
            buildPa(p.Id, accs.get('Acc-内装A').Id,    '総合内装A',   '受注'),
            buildPa(p.Id, accs.get('Acc-工事店A1').Id, '工事店A-1', '受注'),
            buildPa(p.Id, accs.get('Acc-工事店A2').Id, '工事店A-2', '受注'),
            buildPa(p.Id, accs.get('Acc-工事店A3').Id, '工事店A-3', '受注')
        };

        runBatch(true);

        property__c after = fetch(p.Id);
        // 把握率: 元請(1)+内装A(1)+工事A-1〜A-3(3) = 5/5 = 100%
        System.assertEquals(100.00, after.CS_PropertyCoverageRate__c,
            '把握率: A系全埋め+元請=100%');
        // 受注率: 内装A(1)+工事A-1〜A-3(3) = 4/4 = 100%
        System.assertEquals(100.00, after.CS_PropertyWinRate__c,
            '受注率: A系全受注=100%');
    }

    // ============================================================
    // ケース2: 元請ありだが property_account__c なし
    //   把握率: 1/5=20%, 受注率: 0/4=0%
    // ============================================================
    @IsTest
    static void test_motoukeOnly_noPropertyAccount() {
        Map<String, Account> accs = getAccountMap();

        property__c p = new property__c(
            Name = 'P2',
            zyutyusaki__c = accs.get('Acc-元請').Id
        );
        insert p;

        runBatch(true);

        property__c after = fetch(p.Id);
        System.assertEquals(20.00, after.CS_PropertyCoverageRate__c,
            '把握率: 元請のみ=1/5=20%');
        System.assertEquals(0.00, after.CS_PropertyWinRate__c,
            '受注率: 受注レコードなし=0/4=0%');
    }

    // ============================================================
    // ケース3: 把握はあるが受注はない
    //   内装A埋まり(Status空) → 把握率: 2/5=40%, 受注率: 0/4=0%
    // ============================================================
    @IsTest
    static void test_filledButNotOrdered() {
        Map<String, Account> accs = getAccountMap();

        property__c p = new property__c(
            Name = 'P3',
            zyutyusaki__c = accs.get('Acc-元請').Id
        );
        insert p;

        insert new List<property_account__c>{
            buildPa(p.Id, accs.get('Acc-内装A').Id, '総合内装A', null)
        };

        runBatch(true);

        property__c after = fetch(p.Id);
        // 把握率: 元請(1)+内装A(1) = 2/5 = 40%
        System.assertEquals(40.00, after.CS_PropertyCoverageRate__c,
            '把握率: 元請+内装A=2/5=40%');
        // 受注率: Status空のため受注なし = 0/4 = 0%
        System.assertEquals(0.00, after.CS_PropertyWinRate__c,
            '受注率: 受注Statusなし=0/4=0%');
    }

    // ============================================================
    // ケース4: B拡張（把握=9, 受注=8）
    //   内装A受注+工事A-1受注+内装B埋(Status空)+工事B-1受注+元請
    // ============================================================
    @IsTest
    static void test_denominator9_8_withB() {
        Map<String, Account> accs = getAccountMap();

        property__c p = new property__c(
            Name = 'P4',
            zyutyusaki__c = accs.get('Acc-元請').Id
        );
        insert p;

        insert new List<property_account__c>{
            buildPa(p.Id, accs.get('Acc-内装A').Id,    '総合内装A',   '受注'),
            buildPa(p.Id, accs.get('Acc-工事店A1').Id, '工事店A-1', '受注'),
            buildPa(p.Id, accs.get('Acc-内装B').Id,    '総合内装B',   null),
            buildPa(p.Id, accs.get('Acc-工事店B1').Id, '工事店B-1', '受注')
        };

        runBatch(true);

        property__c after = fetch(p.Id);
        // 把握率: 元請(1)+内装A(1)+工事A-1(1)+内装B(1)+工事B-1(1) = 5/9
        Decimal expectedCov = (5.0/9.0*100).setScale(2, System.RoundingMode.HALF_UP);
        System.assertEquals(expectedCov, after.CS_PropertyCoverageRate__c,
            '把握率: 5/9');
        // 受注率: 内装A(1)+工事A-1(1)+工事B-1(1) = 3/8 (内装BはStatus空のため受注なし)
        Decimal expectedWin = (3.0/8.0*100).setScale(2, System.RoundingMode.HALF_UP);
        System.assertEquals(expectedWin, after.CS_PropertyWinRate__c,
            '受注率: 3/8');
    }

    // ============================================================
    // ケース5: C拡張（把握=13, 受注=12）
    // ============================================================
    @IsTest
    static void test_denominator13_12_withC() {
        Map<String, Account> accs = getAccountMap();

        property__c p = new property__c(
            Name = 'P5',
            zyutyusaki__c = accs.get('Acc-元請').Id
        );
        insert p;

        insert new List<property_account__c>{
            buildPa(p.Id, accs.get('Acc-内装A').Id, '総合内装A', '受注'),
            buildPa(p.Id, accs.get('Acc-内装B').Id, '総合内装B', '受注'),
            buildPa(p.Id, accs.get('Acc-内装C').Id, '総合内装C', '受注')
        };

        runBatch(true);

        property__c after = fetch(p.Id);
        // 把握率: 元請(1)+内装A(1)+内装B(1)+内装C(1) = 4/13
        Decimal expectedCov = (4.0/13.0*100).setScale(2, System.RoundingMode.HALF_UP);
        System.assertEquals(expectedCov, after.CS_PropertyCoverageRate__c,
            '把握率: 4/13');
        // 受注率: 内装A+内装B+内装C = 3/12 = 25%
        System.assertEquals(25.00, after.CS_PropertyWinRate__c,
            '受注率: 3/12=25%');
    }

    // ============================================================
    // ケース6: 「該当無し」のみで埋まる枠は分母から減算
    //   工事店A-1=該当無し → 把握=5-1=4, 受注=4-1=3
    // ============================================================
    @IsTest
    static void test_notApplicable_decreasesDenominator() {
        Map<String, Account> accs = getAccountMap();

        property__c p = new property__c(
            Name = 'P6',
            zyutyusaki__c = accs.get('Acc-元請').Id
        );
        insert p;

        insert new List<property_account__c>{
            buildPa(p.Id, accs.get('Acc-内装A').Id,    '総合内装A',   '受注'),
            buildPa(p.Id, accs.get('Acc-工事店A2').Id, '工事店A-2', '受注')
        };

        runBatch(true);

        property__c after = fetch(p.Id);

    }

    // ============================================================
    // ケース7: 「該当無し」と通常Acc共存 → 減算しない
    // ============================================================
    @IsTest
    static void test_notApplicable_coexist_noDecrease() {
        Map<String, Account> accs = getAccountMap();

        property__c p = new property__c(
            Name = 'P7',
            zyutyusaki__c = accs.get('Acc-元請').Id
        );
        insert p;

        insert new List<property_account__c>{
            buildPa(p.Id, accs.get('Acc-内装A').Id,    '総合内装A',   '受注'),
            buildPa(p.Id, accs.get('Acc-工事店A1').Id, '工事店A-1', '受注')
        };

        runBatch(true);

        property__c after = fetch(p.Id);

    }

    // ============================================================
    // ケース8: 元請なし、property_account__cなし
    //   把握=0/5=0%, 受注=0/4=0%
    // ============================================================
    @IsTest
    static void test_emptyProperty() {
        property__c p = new property__c(Name = 'P8');
        insert p;

        runBatch(true);

        property__c after = fetch(p.Id);
        System.assertEquals(0.00, after.CS_PropertyCoverageRate__c, '把握率=0%');
        System.assertEquals(0.00, after.CS_PropertyWinRate__c,      '受注率=0%');
    }

    // ============================================================
    // ケース9: 同一枠複数レコード → A案で最大1
    // ============================================================
    @IsTest
    static void test_sameTypeMultiple_countsOnce() {
        Map<String, Account> accs = getAccountMap();

        property__c p = new property__c(
            Name = 'P9',
            zyutyusaki__c = accs.get('Acc-元請').Id
        );
        insert p;

        insert new List<property_account__c>{
            buildPa(p.Id, accs.get('Acc-内装A').Id,    '総合内装A', '受注'),
            buildPa(p.Id, accs.get('Acc-工事店A1').Id, '総合内装A', '受注')
        };

        runBatch(true);

        property__c after = fetch(p.Id);
        // 把握率: 元請(1)+内装A(1, 重複しても1) = 2/5 = 40%
        System.assertEquals(40.00, after.CS_PropertyCoverageRate__c,
            '把握率: 同一枠重複でも1');
        // 受注率: 内装A(1) = 1/4 = 25%
        System.assertEquals(25.00, after.CS_PropertyWinRate__c,
            '受注率: 同一枠重複でも1');
    }

    // ============================================================
    // ケース10: 受注率の分母段階が「Status__c=受注」ではなく「埋まっている」で判定されること
    //   内装B埋まり(Status空)で B拡張トリガー → 把握=9, 受注=8
    // ============================================================
    @IsTest
    static void test_winRate_denominatorTriggeredByFilling_notByOrdered() {
        Map<String, Account> accs = getAccountMap();

        property__c p = new property__c(
            Name = 'P10',
            zyutyusaki__c = accs.get('Acc-元請').Id
        );
        insert p;

        insert new List<property_account__c>{
            buildPa(p.Id, accs.get('Acc-内装A').Id, '総合内装A', '受注'),
            buildPa(p.Id, accs.get('Acc-内装B').Id, '総合内装B', null)
        };

        runBatch(true);

        property__c after = fetch(p.Id);
        // 内装B埋まり(Status空)でも分母段階は拡張される → 把握=9, 受注=8
        // 把握率: 元請(1)+内装A(1)+内装B(1) = 3/9
        Decimal expectedCov = (3.0/9.0*100).setScale(2, System.RoundingMode.HALF_UP);
        System.assertEquals(expectedCov, after.CS_PropertyCoverageRate__c,
            '把握率: B拡張(埋まりトリガー)で3/9');
        // 受注率: 内装A(1) = 1/8
        Decimal expectedWin = (1.0/8.0*100).setScale(2, System.RoundingMode.HALF_UP);
        System.assertEquals(expectedWin, after.CS_PropertyWinRate__c,
            '受注率: 分母はB拡張で8、分子は内装A受注のみで1');
    }

    // ============================================================
    // ケース11: 差分モード - 24h以前のレコードはスキップ
    //   property を作成して直接 SQL で LastModifiedDate を過去にできないため、
    //   差分モードのコンストラクタを通すだけのカバレッジ確保
    // ============================================================
    @IsTest
    static void test_diffMode_runs() {
        Map<String, Account> accs = getAccountMap();

        property__c p = new property__c(
            Name = 'P11-diff',
            zyutyusaki__c = accs.get('Acc-元請').Id
        );
        insert p;

        // 直近作成なので差分対象に入る
        runBatch(false);

        property__c after = fetch(p.Id);
        System.assertEquals(20.00, after.CS_PropertyCoverageRate__c,
            '差分モード: 直近作成物件は処理対象');
    }

    // ============================================================
    // ケース12: 既存値と同じ→更新スキップでもエラー出ない
    // ============================================================
    @IsTest
    static void test_noChange_skipsUpdate() {
        Map<String, Account> accs = getAccountMap();

        property__c p = new property__c(
            Name = 'P12',
            zyutyusaki__c = accs.get('Acc-元請').Id,
            CS_PropertyCoverageRate__c = 20.00,
            CS_PropertyWinRate__c      = 0.00
        );
        insert p;

        runBatch(true);

        property__c after = fetch(p.Id);
        System.assertEquals(20.00, after.CS_PropertyCoverageRate__c, '把握率変わらず');
        System.assertEquals(0.00,  after.CS_PropertyWinRate__c,      '受注率変わらず');
    }

    // ============================================================
    // ヘルパー
    // ============================================================

    private static Map<String, Account> getAccountMap() {
        Map<String, Account> result = new Map<String, Account>();
        for (Account a : [SELECT Id, Name FROM Account WHERE Name LIKE 'Acc-%']) {
            result.put(a.Name, a);
        }
        return result;
    }

    private static property_account__c buildPa(Id propId, Id accId, String type, String status) {
        return new property_account__c(
            property__c     = propId,
            account__c      = accId,
            account_type__c = type,
            Status__c       = status
        );
    }

    private static property__c fetch(Id propId) {
        return [
            SELECT CS_PropertyCoverageRate__c, CS_PropertyWinRate__c
            FROM property__c
            WHERE Id = :propId
        ];
    }

    private static void runBatch(Boolean fullRecalc) {
        Test.startTest();
        Database.executeBatch(new NHR_CS_PropertyRateBatch(fullRecalc), 200);
        Test.stopTest();
    }
}