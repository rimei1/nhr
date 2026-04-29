/**
 * NHR_CS_AccountOrderRateBatchTest
 * --------------------------------------------------------------------
 * NHR_CS_AccountOrderRateBatch + NHR_CS_AccountOrderRateClearBatch +
 * NHR_CS_AccountOrderRateBatchSchedule のユニットテスト。
 *
 * テストケース (14 件):
 *   t01 元請 今期75% / 前期50%
 *   t02 内装 今期66.67% / 前期100%
 *   t03 両パターン混在
 *   t04 Batch2 空白クリア (過去値ありで関連0件)
 *   t05 期間外物件は対象外
 *   t06 対象外 account_type__c 除外
 *   t07 差分なしでも正常終了
 *   t08 Schedulable 経由実行
 *   t09 InvocableMethod 経由実行
 *   t10 calcRate / equalsDecimal 境界値
 *   t11 対象 account_type 18種網羅
 *   t12 戦略区分 ① property__c.Status='受注' のみで分子カウント
 *   t13 戦略区分 ② 総合内装 × 受注 のみで親物件が分子
 *   t14 戦略区分 ③ 工事店 × 対象工種 × 受注 のみで親物件が分子
 *   t15 戦略区分 ①②③ 重複排除が働き分子は物件数
 *   t16 戦略区分 ③ 工種が対象外 → カウントされない
 *   t17 Batch1 が関連 Account だけを処理対象とする (semi-join 回避確認)
 */
@IsTest
private class NHR_CS_AccountOrderRateBatchTest {

    private static final Integer FY_START_MONTH = 7;

    // ---------- ヘルパ ----------
    private static Account mkAcc(String name) { return new Account(Name=name); }

    private static Map<String, Date> fy() {
        Date today = System.today();
        Integer y = (today.month() >= FY_START_MONTH) ? today.year() : today.year() - 1;
        return new Map<String, Date>{
            'thisStart' => Date.newInstance(y,     FY_START_MONTH, 1),
            'thisEnd'   => Date.newInstance(y + 1, FY_START_MONTH, 1).addDays(-1),
            'preStart'  => Date.newInstance(y - 1, FY_START_MONTH, 1),
            'preEnd'    => Date.newInstance(y,     FY_START_MONTH, 1).addDays(-1)
        };
    }

    // ======================================================
    // t01 元請 今期75% / 前期50%
    // ======================================================
    @IsTest
    static void t01_direct_thisAndPre_normal() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc01'); insert acc;

        insert new List<property__c>{
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('thisStart'),              Status__c='受注'),
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('thisStart').addDays(30),  Status__c='受注'),
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('thisEnd'),                Status__c='受注'),
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('thisStart').addDays(60),  Status__c='接触済み'),
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('preStart'),               Status__c='受注'),
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('preEnd'),                 Status__c='失注')
        };

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_DirectOrderRate__c, CS_PreFY_DirectOrderRate__c,
                      CS_ThisFY_Strategy_Win_Rate__c, CS_PreFY_Strategy_Win_Rate__c
               FROM Account WHERE Id = :acc.Id];
        System.assertEquals(75.00, acc.CS_ThisFY_DirectOrderRate__c, '今期元請');
        System.assertEquals(50.00, acc.CS_PreFY_DirectOrderRate__c,  '前期元請');
        // 戦略区分: 今期は p1-1/p1-2/p1-3 が受注 (①で分子) → 3/4 = 75.00
        //           前期は p1-5 受注 → 1/2 = 50.00
        System.assertEquals(75.00, acc.CS_ThisFY_Strategy_Win_Rate__c, '今期戦略');
        System.assertEquals(50.00, acc.CS_PreFY_Strategy_Win_Rate__c,  '前期戦略');
    }

    // ======================================================
    // t02 内装 今期66.67% / 前期100%
    // ======================================================
    @IsTest
    static void t02_interior_thisAndPre_normal() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc02'); insert acc;

        property__c pThis = new property__c(syunkoubi__c=d.get('thisStart').addDays(10));
        property__c pPre  = new property__c(syunkoubi__c=d.get('preStart').addDays(10));
        insert new List<property__c>{ pThis, pPre };

        insert new List<property_account__c>{
            new property_account__c(property__c=pThis.Id, Account__c=acc.Id,
                account_type__c='総合内装A', Status__c='受注'),
            new property_account__c(property__c=pThis.Id, Account__c=acc.Id,
                account_type__c='工事店B-1', Status__c='受注'),
            new property_account__c(property__c=pThis.Id, Account__c=acc.Id,
                account_type__c='工事店C-5', Status__c='失注'),
            new property_account__c(property__c=pPre.Id,  Account__c=acc.Id,
                account_type__c='工事店A-1', Status__c='受注')
        };

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_Interior_WinRate__c, CS_PreFY_Interior_WinRate__c,
                      CS_ThisFY_DirectOrderRate__c, CS_PreFY_DirectOrderRate__c
               FROM Account WHERE Id = :acc.Id];
        System.assertEquals(66.67,  acc.CS_ThisFY_Interior_WinRate__c);
        System.assertEquals(100.00, acc.CS_PreFY_Interior_WinRate__c);
        // Account はこの Account を zyutyusaki__c としていないので元請0 → null
        System.assertEquals(null, acc.CS_ThisFY_DirectOrderRate__c);
        System.assertEquals(null, acc.CS_PreFY_DirectOrderRate__c);
    }

    // ======================================================
    // t03 両パターン混在
    // ======================================================
    @IsTest
    static void t03_mixed() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc03'); insert acc;

        insert new List<property__c>{
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('thisStart'), Status__c='受注'),
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('thisStart'), Status__c='失注')
        };
        property__c parent = new property__c(syunkoubi__c=d.get('thisStart').addDays(5));
        insert parent;
        insert new property_account__c(property__c=parent.Id, Account__c=acc.Id,
            account_type__c='総合内装B', Status__c='受注');

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_DirectOrderRate__c, CS_ThisFY_Interior_WinRate__c
               FROM Account WHERE Id = :acc.Id];
        System.assertEquals(50.00,  acc.CS_ThisFY_DirectOrderRate__c);
        System.assertEquals(100.00, acc.CS_ThisFY_Interior_WinRate__c);
    }

    // ======================================================
    // t04 Batch2 空白クリア (過去値 + 関連0件 → null)
    // ======================================================
    @IsTest
    static void t04_clear_batch_nullifies() {
        Account acc = new Account(
            Name='Acc04',
            CS_ThisFY_DirectOrderRate__c   = 33.33,
            CS_PreFY_DirectOrderRate__c    = 44.44,
            CS_ThisFY_Interior_WinRate__c  = 55.55,
            CS_PreFY_Interior_WinRate__c   = 66.66,
            CS_ThisFY_Strategy_Win_Rate__c = 77.77,
            CS_PreFY_Strategy_Win_Rate__c  = 88.88
        );
        insert acc;
        // 関連レコードを一切作らない

        Test.startTest();
        // Batch1 + Batch2 連鎖
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_DirectOrderRate__c, CS_PreFY_DirectOrderRate__c,
                      CS_ThisFY_Interior_WinRate__c, CS_PreFY_Interior_WinRate__c,
                      CS_ThisFY_Strategy_Win_Rate__c, CS_PreFY_Strategy_Win_Rate__c
               FROM Account WHERE Id = :acc.Id];
        System.assertEquals(null, acc.CS_ThisFY_DirectOrderRate__c);
        System.assertEquals(null, acc.CS_PreFY_DirectOrderRate__c);
        System.assertEquals(null, acc.CS_ThisFY_Interior_WinRate__c);
        System.assertEquals(null, acc.CS_PreFY_Interior_WinRate__c);
        System.assertEquals(null, acc.CS_ThisFY_Strategy_Win_Rate__c);
        System.assertEquals(null, acc.CS_PreFY_Strategy_Win_Rate__c);
    }

    // ======================================================
    // t05 期間外物件は対象外
    // ======================================================
    @IsTest
    static void t05_out_of_period() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc05'); insert acc;

        insert new List<property__c>{
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('preStart').addDays(-1), Status__c='受注'),
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('thisEnd').addDays(1),   Status__c='受注')
        };

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_DirectOrderRate__c, CS_PreFY_DirectOrderRate__c
               FROM Account WHERE Id = :acc.Id];
        // Batch1 は対象外期間の物件しか持たない Account も start() で引くが
        // execute() で期間フィルタ → 値は null。その後 Batch2 は Batch1 処理済みなので触らない。
        System.assertEquals(null, acc.CS_ThisFY_DirectOrderRate__c);
        System.assertEquals(null, acc.CS_PreFY_DirectOrderRate__c);
    }

    // ======================================================
    // t06 対象外 account_type__c は集計されない
    // ======================================================
    @IsTest
    static void t06_non_target_type() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc06'); insert acc;

        property__c parent = new property__c(syunkoubi__c=d.get('thisStart'));
        insert parent;

        insert new property_account__c(property__c=parent.Id, Account__c=acc.Id,
            account_type__c='ゼネコン', Status__c='受注');

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_Interior_WinRate__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(null, acc.CS_ThisFY_Interior_WinRate__c);
    }

    // ======================================================
    // t07 差分なし
    // ======================================================
    @IsTest
    static void t07_no_diff() {
        Map<String, Date> d = fy();
        Account acc = new Account(
            Name='Acc07',
            CS_ThisFY_DirectOrderRate__c   = 100.00,
            CS_ThisFY_Strategy_Win_Rate__c = 100.00
        );
        insert acc;
        insert new property__c(zyutyusaki__c=acc.Id,
            syunkoubi__c=d.get('thisStart'), Status__c='受注');

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_DirectOrderRate__c, CS_ThisFY_Strategy_Win_Rate__c
               FROM Account WHERE Id = :acc.Id];
        System.assertEquals(100.00, acc.CS_ThisFY_DirectOrderRate__c);
        System.assertEquals(100.00, acc.CS_ThisFY_Strategy_Win_Rate__c);
    }

    // ======================================================
    // t08 Schedulable
    // ======================================================
    @IsTest
    static void t08_schedulable() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc08'); insert acc;
        insert new property__c(zyutyusaki__c=acc.Id,
            syunkoubi__c=d.get('thisStart'), Status__c='受注');

        Test.startTest();
        String jobId = System.schedule(
            'NHR_CS_AcctRate_Test_' + System.now().getTime(),
            '0 0 2 1 1 ? 2099',
            new NHR_CS_AccountOrderRateBatchSchedule()
        );
        System.assertNotEquals(null, jobId);
        Test.stopTest();
    }

    // ======================================================
    // t09 InvocableMethod
    // ======================================================
    @IsTest
    static void t09_invocable() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc09'); insert acc;
        insert new property__c(zyutyusaki__c=acc.Id,
            syunkoubi__c=d.get('thisStart'), Status__c='受注');

        Test.startTest();
        NHR_CS_AccountOrderRateBatchSchedule.runBatchFromFlow();
        Test.stopTest();

        acc = [SELECT CS_ThisFY_DirectOrderRate__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(100.00, acc.CS_ThisFY_DirectOrderRate__c);
    }

    // ======================================================
    // t10 calcRate / equalsDecimal 境界値
    // ======================================================
    @IsTest
    static void t10_utils() {
        Decimal r1 = NHR_CS_AccountOrderRateBatch.calcRate(
            new NHR_CS_AccountOrderRateBatch.RateNum(1, 3));
        System.assertEquals(33.33, r1);

        Decimal r2 = NHR_CS_AccountOrderRateBatch.calcRate(
            new NHR_CS_AccountOrderRateBatch.RateNum(2, 3));
        System.assertEquals(66.67, r2);

        Decimal r3 = NHR_CS_AccountOrderRateBatch.calcRate(
            new NHR_CS_AccountOrderRateBatch.RateNum(0, 0));
        System.assertEquals(null, r3);

        System.assertEquals(null, NHR_CS_AccountOrderRateBatch.calcRate(null));

        System.assertEquals(true,  NHR_CS_AccountOrderRateBatch.equalsDecimal(null, null));
        System.assertEquals(false, NHR_CS_AccountOrderRateBatch.equalsDecimal(null, 1));
        System.assertEquals(false, NHR_CS_AccountOrderRateBatch.equalsDecimal(1, null));
        System.assertEquals(true,  NHR_CS_AccountOrderRateBatch.equalsDecimal(50.00, 50.00));
        System.assertEquals(false, NHR_CS_AccountOrderRateBatch.equalsDecimal(50.00, 50.01));
    }

    // ======================================================
    // t11 対象 account_type 18種すべてが集計される (内装)
    // ======================================================
    @IsTest
    static void t11_all_18_types() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc11'); insert acc;

        property__c parent = new property__c(syunkoubi__c=d.get('thisStart'));
        insert parent;

        List<String> allTypes = new List<String>{
            '総合内装A','総合内装B','総合内装C',
            '工事店A-1','工事店A-2','工事店A-3','工事店A-4','工事店A-5',
            '工事店B-1','工事店B-2','工事店B-3','工事店B-4','工事店B-5',
            '工事店C-1','工事店C-2','工事店C-3','工事店C-4','工事店C-5'
        };
        List<property_account__c> rows = new List<property_account__c>();
        for (Integer i = 0; i < allTypes.size(); i++) {
            rows.add(new property_account__c(property__c=parent.Id, Account__c=acc.Id,
                account_type__c=allTypes[i],
                Status__c = (Math.mod(i, 2) == 0) ? '受注' : '失注'
            ));
        }
        insert rows;

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_Interior_WinRate__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(50.00, acc.CS_ThisFY_Interior_WinRate__c);
    }

    // ======================================================
    // t12 戦略区分 ① のみ (property__c.Status='受注')
    // ======================================================
    @IsTest
    static void t12_strategy_pattern1_only() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc12'); insert acc;

        // 分母 3 件・うち 2 件 property__c.Status='受注' → 66.67%
        insert new List<property__c>{
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('thisStart'), Status__c='受注'),
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('thisStart'), Status__c='受注'),
            new property__c(zyutyusaki__c=acc.Id,
                syunkoubi__c=d.get('thisStart'), Status__c='失注')
        };

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_Strategy_Win_Rate__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(66.67, acc.CS_ThisFY_Strategy_Win_Rate__c,
            '① property__c.Status=受注 のみで分子');
    }

    // ======================================================
    // t13 戦略区分 ② のみ (総合内装 × 受注)
    // ======================================================
    @IsTest
    static void t13_strategy_pattern2_only() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc13'); insert acc;

        // 分母 = property__c 2件 (両方 Status='失注' で ① には該当しない)
        property__c p1 = new property__c(zyutyusaki__c=acc.Id,
            syunkoubi__c=d.get('thisStart'), Status__c='失注');
        property__c p2 = new property__c(zyutyusaki__c=acc.Id,
            syunkoubi__c=d.get('thisStart'), Status__c='失注');
        insert new List<property__c>{ p1, p2 };

        // p1 の子: 総合内装A × 受注 → 親 p1 を分子にカウント
        insert new property_account__c(property__c=p1.Id, Account__c=acc.Id,
            account_type__c='総合内装A', Status__c='受注');

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_Strategy_Win_Rate__c FROM Account WHERE Id = :acc.Id];
        // 1/2 = 50.00
        System.assertEquals(50.00, acc.CS_ThisFY_Strategy_Win_Rate__c,
            '② 総合内装×受注 のみで分子');
    }

    // ======================================================
    // t14 戦略区分 ③ のみ (工事店 × 対象工種 × 受注)
    // ======================================================
    @IsTest
    static void t14_strategy_pattern3_only() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc14'); insert acc;

        property__c p1 = new property__c(zyutyusaki__c=acc.Id,
            syunkoubi__c=d.get('thisStart'), Status__c='失注');
        property__c p2 = new property__c(zyutyusaki__c=acc.Id,
            syunkoubi__c=d.get('thisStart'), Status__c='失注');
        property__c p3 = new property__c(zyutyusaki__c=acc.Id,
            syunkoubi__c=d.get('thisStart'), Status__c='失注');
        insert new List<property__c>{ p1, p2, p3 };

        // p1: 工事店A-1 × 軽鉄ボード × 受注 → 分子
        // p2: 工事店B-3 × 壁装仕上 × 受注 → 分子
        // p3: 工事店C-5 × 木質床 × 受注 → 分子
        insert new List<property_account__c>{
            new property_account__c(property__c=p1.Id, Account__c=acc.Id,
                account_type__c='工事店A-1', Typeofwork__c='軽鉄ボード', Status__c='受注'),
            new property_account__c(property__c=p2.Id, Account__c=acc.Id,
                account_type__c='工事店B-3', Typeofwork__c='壁装仕上', Status__c='受注'),
            new property_account__c(property__c=p3.Id, Account__c=acc.Id,
                account_type__c='工事店C-5', Typeofwork__c='木質床', Status__c='受注')
        };

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_Strategy_Win_Rate__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(100.00, acc.CS_ThisFY_Strategy_Win_Rate__c,
            '③ 工事店×対象工種×受注 のみで分子');
    }

    // ======================================================
    // t15 ①②③ 重複排除: 同じ物件が複数条件を満たしても分子=1
    // ======================================================
    @IsTest
    static void t15_strategy_union_dedupe() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc15'); insert acc;

        // 1 つの property__c に ①②③すべての条件を同時に該当させる
        property__c p1 = new property__c(zyutyusaki__c=acc.Id,
            syunkoubi__c=d.get('thisStart'),
            Status__c='受注');  // ①
        property__c p2 = new property__c(zyutyusaki__c=acc.Id,
            syunkoubi__c=d.get('thisStart'),
            Status__c='失注');
        insert new List<property__c>{ p1, p2 };

        // p1 に ② と ③ も重ねる
        insert new List<property_account__c>{
            new property_account__c(property__c=p1.Id, Account__c=acc.Id,
                account_type__c='総合内装B', Status__c='受注'),        // ②
            new property_account__c(property__c=p1.Id, Account__c=acc.Id,
                account_type__c='工事店A-2', Typeofwork__c='軽鉄ボード',
                Status__c='受注')                                        // ③
        };

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_Strategy_Win_Rate__c FROM Account WHERE Id = :acc.Id];
        // 分母 2、分子 1 (p1 のみ) → 50.00
        System.assertEquals(50.00, acc.CS_ThisFY_Strategy_Win_Rate__c,
            '①②③ 重複時も分子は物件ID単位で 1');
    }

    // ======================================================
    // t16 戦略区分 ③ 工種が対象外 → カウントされない
    // ======================================================
    @IsTest
    static void t16_strategy_pattern3_wrong_worktype() {
        Map<String, Date> d = fy();
        Account acc = mkAcc('Acc16'); insert acc;

        property__c p1 = new property__c(zyutyusaki__c=acc.Id,
            syunkoubi__c=d.get('thisStart'), Status__c='失注');
        insert p1;

        // 工事店 × 受注だが、工種が対象外
        insert new property_account__c(property__c=p1.Id, Account__c=acc.Id,
            account_type__c='工事店A-1', Typeofwork__c='その他', Status__c='受注');

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        acc = [SELECT CS_ThisFY_Strategy_Win_Rate__c FROM Account WHERE Id = :acc.Id];
        // 分母 1、分子 0 → 0.00
        System.assertEquals(0.00, acc.CS_ThisFY_Strategy_Win_Rate__c,
            '③ 対象外工種は分子に含めない');
    }

    // ======================================================
    // t17 Batch1 start の semi-join 回避確認:
    //      関連のない Account は集計対象に含まれない
    // ======================================================
    @IsTest
    static void t17_semi_join_avoidance() {
        Map<String, Date> d = fy();
        Account accRelated   = mkAcc('AccRel');     insert accRelated;
        Account accUnrelated = mkAcc('AccUnrelated'); insert accUnrelated;

        // 関連側にのみ物件を作成
        insert new property__c(zyutyusaki__c=accRelated.Id,
            syunkoubi__c=d.get('thisStart'), Status__c='受注');

        Test.startTest();
        Database.executeBatch(new NHR_CS_AccountOrderRateBatch(), 200);
        Test.stopTest();

        Account a1 = [SELECT CS_ThisFY_DirectOrderRate__c FROM Account WHERE Id=:accRelated.Id];
        Account a2 = [SELECT CS_ThisFY_DirectOrderRate__c FROM Account WHERE Id=:accUnrelated.Id];
        System.assertEquals(100.00, a1.CS_ThisFY_DirectOrderRate__c, '関連 Account は集計される');
        System.assertEquals(null,   a2.CS_ThisFY_DirectOrderRate__c, '無関係 Account は触らない');
    }
}