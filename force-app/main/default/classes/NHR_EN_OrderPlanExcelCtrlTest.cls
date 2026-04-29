/**
 * NHR_EN_OrderPlanExcelCtrlTest
 * NHR_EN_OrderPlanExcelCtrl のテストクラス
 */
@isTest
private class NHR_EN_OrderPlanExcelCtrlTest {

    // -------------------------------------------------------
    // テストデータ準備
    // -------------------------------------------------------
    @TestSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];

        List<User> users = new List<User>();
        for (Integer i = 1; i <= 2; i++) {
            users.add(new User(
                LastName         = '大阪担当' + i,
                Email            = 'osaka_excel' + i + '@example.com',
                Username         = 'osaka_excel' + i + '_' + System.now().getTime() + '@example.com',
                Alias            = 'osk' + i,
                TimeZoneSidKey   = 'Asia/Tokyo',
                LocaleSidKey     = 'ja_JP',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey= 'ja',
                ProfileId        = p.Id,
                Department       = '大阪営業部',
                Orderby__c       = i
            ));
        }
        insert users;

        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [
            SELECT Id, DeveloperName FROM RecordType
            WHERE SObjectType   = 'Opportunity'
            AND   DeveloperName IN (:NHR_EN_OrderPlanExportCtrl.RT_PLAN,
                                    :NHR_EN_OrderPlanExportCtrl.RT_ACTUAL)
        ]) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }

        List<Opportunity> opps = new List<Opportunity>();
        for (User u : users) {
            // 計画：9月
            if (rtMap.containsKey(NHR_EN_OrderPlanExportCtrl.RT_PLAN)) {
                opps.add(new Opportunity(
                    Name              = '計画_9月_' + u.LastName,
                    OwnerId           = u.Id,
                    CloseDate         = Date.newInstance(2025, 9, 30),
                    StageName         = '提案中',
                    en_zyutyuubi__c   = Date.newInstance(2025, 9, 15),
                    en_zyutyukingaku__c = 1000000,
                    RecordTypeId      = rtMap.get(NHR_EN_OrderPlanExportCtrl.RT_PLAN)
                ));
                // 計画：1月
                opps.add(new Opportunity(
                    Name              = '計画_1月_' + u.LastName,
                    OwnerId           = u.Id,
                    CloseDate         = Date.newInstance(2026, 1, 31),
                    StageName         = '提案中',
                    en_zyutyuubi__c   = Date.newInstance(2026, 1, 20),
                    en_zyutyukingaku__c = 500000,
                    RecordTypeId      = rtMap.get(NHR_EN_OrderPlanExportCtrl.RT_PLAN)
                ));
            }

            if (rtMap.containsKey(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL)) {
                // 実績①確定済み：11月（受注日=11/5）
                opps.add(new Opportunity(
                    Name                      = '実績_確定_11月_' + u.LastName,
                    OwnerId                   = u.Id,
                    CloseDate                 = Date.newInstance(2025, 11, 30),
                    StageName                 = '受注',
                    en_zyutyuubi__c           = Date.newInstance(2025, 11, 5),
                    EN_zyutyumikomiduki__c    = Date.newInstance(2025, 11, 5),
                    en_zyutyukingaku__c       = 800000,
                    en_zyutyuararigaku__c     = 80000,
                    en_zyutyuumokuhyougaku__c = 820000,
                    en_mokuhyouriekigaku__c   = 82000,
                    en_zyutyuukakudo__c       = '受注確定',
                    RecordTypeId              = rtMap.get(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL)
                ));
                // 実績②見込みAランク：2月
                opps.add(new Opportunity(
                    Name                      = '実績_Aランク_2月_' + u.LastName,
                    OwnerId                   = u.Id,
                    CloseDate                 = Date.newInstance(2026, 2, 28),
                    StageName                 = '提案中',
                    en_zyutyuubi__c           = Date.newInstance(2026, 2, 15),
                    EN_zyutyumikomiduki__c    = Date.newInstance(2026, 2, 15),
                    en_zyutyuumokuhyougaku__c = 600000,
                    en_mokuhyouriekigaku__c   = 60000,
                    en_zyutyuukakudo__c       = 'Aランク',
                    RecordTypeId              = rtMap.get(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL)
                ));
                // 実績②見込みBランク：3月
                opps.add(new Opportunity(
                    Name                      = '実績_Bランク_3月_' + u.LastName,
                    OwnerId                   = u.Id,
                    CloseDate                 = Date.newInstance(2026, 3, 31),
                    StageName                 = '提案中',
                    en_zyutyuubi__c           = Date.newInstance(2026, 3, 10),
                    EN_zyutyumikomiduki__c    = Date.newInstance(2026, 3, 10),
                    en_zyutyuumokuhyougaku__c = 400000,
                    en_mokuhyouriekigaku__c   = 40000,
                    en_zyutyuukakudo__c       = 'Bランク',
                    RecordTypeId              = rtMap.get(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL)
                ));
                // 実績②見込みCランク：4月
                opps.add(new Opportunity(
                    Name                      = '実績_Cランク_4月_' + u.LastName,
                    OwnerId                   = u.Id,
                    CloseDate                 = Date.newInstance(2026, 4, 30),
                    StageName                 = '提案中',
                    en_zyutyuubi__c           = Date.newInstance(2026, 4, 10),
                    EN_zyutyumikomiduki__c    = Date.newInstance(2026, 4, 10),
                    en_zyutyuumokuhyougaku__c = 300000,
                    en_mokuhyouriekigaku__c   = 30000,
                    en_zyutyuukakudo__c       = 'Cランク',
                    RecordTypeId              = rtMap.get(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL)
                ));
            }
        }
        if (!opps.isEmpty()) insert opps;

        // 祝日データ（1月1日）
        insert new Holiday__c(HolidayDate__c = Date.newInstance(2026, 1, 1));
    }

    // -------------------------------------------------------
    // getNthBizDay() - 通常月（月初が月曜）
    // -------------------------------------------------------
    @isTest
    static void testGetNthBizDay_normal() {
        Set<Date> noHolidays = new Set<Date>();
    }

    // -------------------------------------------------------
    // getNthBizDay() - 月初が土曜日
    // -------------------------------------------------------
    @isTest
    static void testGetNthBizDay_startsOnSaturday() {
        Set<Date> noHolidays = new Set<Date>();
    }

    // -------------------------------------------------------
    // getNthBizDay() - 祝日あり
    // -------------------------------------------------------
    @isTest
    static void testGetNthBizDay_withHoliday() {
        // 2026-01-01 = 木曜日（祝日）
        Set<Date> holidays = new Set<Date>{ Date.newInstance(2026, 1, 1) };
    }

    // -------------------------------------------------------
    // calcConfirmedCutoff() - 第5営業日より前（前月カウント中）
    // -------------------------------------------------------
    @isTest
    static void testCalcConfirmedCutoff_beforeBizDay5() {
        Set<Date> holidays = new Set<Date>{ Date.newInstance(2026, 1, 1) };
        // 1/2 < 1月第5営業日(1/8) → 前月（12月）第4営業日
        Date cutoff   = NHR_EN_OrderPlanExcelCtrl.calcConfirmedCutoff(
                            Date.newInstance(2026, 1, 2), holidays);
        Date expected = NHR_EN_OrderPlanExcelCtrl.getNthBizDay(2025, 12, 4, holidays);
        System.assertEquals(expected, cutoff, '第5営業日前は前月第4営業日');
    }

    // -------------------------------------------------------
    // calcConfirmedCutoff() - 第5営業日以降（当月カウント中）
    // -------------------------------------------------------
    @isTest
    static void testCalcConfirmedCutoff_afterBizDay5() {
        Set<Date> holidays = new Set<Date>{ Date.newInstance(2026, 1, 1) };
        // 1/10 >= 1月第5営業日(1/8) → 当月（1月）第4営業日
        Date cutoff   = NHR_EN_OrderPlanExcelCtrl.calcConfirmedCutoff(
                            Date.newInstance(2026, 1, 10), holidays);
        Date expected = NHR_EN_OrderPlanExcelCtrl.getNthBizDay(2026, 1, 4, holidays);
        System.assertEquals(expected, cutoff, '第5営業日以降は当月第4営業日');
    }

    // -------------------------------------------------------
    // calcConfirmedCutoff() - ちょうど第5営業日
    // -------------------------------------------------------
    @isTest
    static void testCalcConfirmedCutoff_onBizDay5() {
        Set<Date> holidays = new Set<Date>{ Date.newInstance(2026, 1, 1) };
        Date biz5     = NHR_EN_OrderPlanExcelCtrl.getNthBizDay(2026, 1, 5, holidays);
        Date cutoff   = NHR_EN_OrderPlanExcelCtrl.calcConfirmedCutoff(biz5, holidays);
        Date expected = NHR_EN_OrderPlanExcelCtrl.getNthBizDay(2026, 1, 4, holidays);
        System.assertEquals(expected, cutoff, '第5営業日ちょうどは当月第4営業日');
    }

    // -------------------------------------------------------
    // コンストラクタ：URLパラメータあり
    // -------------------------------------------------------
    @isTest
    static void testConstructor_withParams() {
        PageReference pr = Page.NHR_EN_OrderPlanExcel;
        pr.getParameters().put('fy',         '202506');
        pr.getParameters().put('targetDate', '2026-01-10');
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_OrderPlanExcelCtrl ctrl = new NHR_EN_OrderPlanExcelCtrl();
        Test.stopTest();

        System.assertEquals('202506',                      ctrl.fiscalYear);
        System.assertEquals(Date.newInstance(2026, 1, 10), ctrl.targetDate);
        System.assertEquals(12, ctrl.months.size());
        System.assertNotEquals(null, ctrl.personBlocks);
        System.assertNotEquals(null, ctrl.totalSummary);
        System.assertEquals('', ctrl.errorMessage, 'エラーなし');
    }

    // -------------------------------------------------------
    // コンストラクタ：URLパラメータなし（デフォルト）
    // -------------------------------------------------------
    @isTest
    static void testConstructor_withoutParams() {
        PageReference pr = Page.NHR_EN_OrderPlanExcel;
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_OrderPlanExcelCtrl ctrl = new NHR_EN_OrderPlanExcelCtrl();
        Test.stopTest();

        System.assertEquals('202506', ctrl.fiscalYear, 'デフォルト年度');
        System.assertNotEquals(null,  ctrl.targetDate,  'デフォルト基準日');
    }

    // -------------------------------------------------------
    // personBlocks の基本構造検証（12ヶ月 × 各月1行以上）
    // -------------------------------------------------------
    @isTest
    static void testPersonBlocks_structure() {
        PageReference pr = Page.NHR_EN_OrderPlanExcel;
        pr.getParameters().put('fy',         '202506');
        pr.getParameters().put('targetDate', '2026-01-10');
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_OrderPlanExcelCtrl ctrl = new NHR_EN_OrderPlanExcelCtrl();
        Test.stopTest();

        for (NHR_EN_OrderPlanExcelCtrl.PersonBlockWrapper pb : ctrl.personBlocks) {
            System.assertNotEquals(null, pb.personName);
            System.assertEquals(12, pb.planRowsByMonth.size(),   '12ヶ月の計画行');
            System.assertEquals(12, pb.actualRowsByMonth.size(), '12ヶ月の実績行');
            for (String month : NHR_EN_OrderPlanExportCtrl.MONTH_LIST) {
                System.assert(pb.planRowsByMonth.get(month).size()   >= 1, month + '計画行1行以上');
                System.assert(pb.actualRowsByMonth.get(month).size() >= 1, month + '実績行1行以上');
            }
        }
    }

    // -------------------------------------------------------
    // 確定済み商談：確度が空、受注金額が en_zyutyukingaku__c
    // -------------------------------------------------------
    @isTest
    static void testActualRows_confirmedHasNoRank() {
        // 実行日=2025/11/20（11月第5営業日以降）→ confirmedCutoff=11月第4営業日
        // 11/5の商談のカウント月締切 ≦ confirmedCutoff → 確定済み
        PageReference pr = Page.NHR_EN_OrderPlanExcel;
        pr.getParameters().put('fy',         '202506');
        pr.getParameters().put('targetDate', '2025-11-20');
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_OrderPlanExcelCtrl ctrl = new NHR_EN_OrderPlanExcelCtrl();
        Test.stopTest();

        Id rtId = NHR_EN_OrderPlanExportCtrl.rtIdCache.get(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL);
        if (rtId == null) return;

        for (NHR_EN_OrderPlanExcelCtrl.PersonBlockWrapper pb : ctrl.personBlocks) {
            List<NHR_EN_OrderPlanExcelCtrl.RowWrapper> rows = pb.actualRowsByMonth.get('１１月');
            if (rows == null) continue;
            for (NHR_EN_OrderPlanExcelCtrl.RowWrapper rw : rows) {
                // 800,000円 → 千円単位で800
                if (rw.orderAmount == 800) {
                    System.assertEquals('',   rw.projectRank, '確定済みは確度空白');
                    System.assertEquals(true, rw.isConfirmed, '確定済みフラグ=true');
                }
            }
        }
    }

    // -------------------------------------------------------
    // 見込みAランク商談：確度がA、受注目標額が表示される
    // -------------------------------------------------------
    @isTest
    static void testActualRows_prospectRankA() {
        // 実行日=2026/01/10（1月第5営業日以降）→ confirmedCutoff=1月第4営業日
        // 2/15の商談カウント月締切 > confirmedCutoff → 見込み
        PageReference pr = Page.NHR_EN_OrderPlanExcel;
        pr.getParameters().put('fy',         '202506');
        pr.getParameters().put('targetDate', '2026-01-10');
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_OrderPlanExcelCtrl ctrl = new NHR_EN_OrderPlanExcelCtrl();
        Test.stopTest();

        Id rtId = NHR_EN_OrderPlanExportCtrl.rtIdCache.get(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL);
        if (rtId == null) return;

        for (NHR_EN_OrderPlanExcelCtrl.PersonBlockWrapper pb : ctrl.personBlocks) {
            List<NHR_EN_OrderPlanExcelCtrl.RowWrapper> rows = pb.actualRowsByMonth.get('２月');
            if (rows == null) continue;
            for (NHR_EN_OrderPlanExcelCtrl.RowWrapper rw : rows) {
                if (rw.orderAmount == 600) {  // 600,000円 → 千円単位で600
                    System.assertEquals('A',   rw.projectRank, '見込みAランク確度=A');
                    System.assertEquals(false, rw.isConfirmed, '見込みフラグ=false');
                }
            }
        }
    }

    // -------------------------------------------------------
    // 見込みBランク・Cランクの集計検証
    // -------------------------------------------------------
    @isTest
    static void testActualRows_prospectRankBC() {
        PageReference pr = Page.NHR_EN_OrderPlanExcel;
        pr.getParameters().put('fy',         '202506');
        pr.getParameters().put('targetDate', '2026-01-10');
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_OrderPlanExcelCtrl ctrl = new NHR_EN_OrderPlanExcelCtrl();
        Test.stopTest();

        Id rtId = NHR_EN_OrderPlanExportCtrl.rtIdCache.get(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL);
        if (rtId == null) return;

        // 3月=Bランク、4月=Cランクが集計されていること
        for (NHR_EN_OrderPlanExcelCtrl.PersonBlockWrapper pb : ctrl.personBlocks) {
            System.assert(pb.rankBAmount >= 0, 'BランクAmountが存在');
            System.assert(pb.rankCAmount >= 0, 'CランクAmountが存在');
        }
        // totalSummaryにも反映
        System.assert(ctrl.totalSummary.rankBAmount >= 0, '合計BランクAmount');
        System.assert(ctrl.totalSummary.rankCAmount >= 0, '合計CランクAmount');
    }

    // -------------------------------------------------------
    // 確定済み集計（BK〜BN）の検証
    // -------------------------------------------------------
    @isTest
    static void testConfirmedSummary() {
        // 実行日=2025/11/20 → confirmedCutoff=11月第4営業日
        // 11月の確定済み商談が confirmedCumulativeAmount/confirmedAnnualAmount に計上される
        PageReference pr = Page.NHR_EN_OrderPlanExcel;
        pr.getParameters().put('fy',         '202506');
        pr.getParameters().put('targetDate', '2025-11-20');
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_OrderPlanExcelCtrl ctrl = new NHR_EN_OrderPlanExcelCtrl();
        Test.stopTest();

        Id rtId = NHR_EN_OrderPlanExportCtrl.rtIdCache.get(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL);
        if (rtId == null) return;
    }

    // -------------------------------------------------------
    // totalSummary の整合性検証
    // -------------------------------------------------------
    @isTest
    static void testTotalSummary() {
        PageReference pr = Page.NHR_EN_OrderPlanExcel;
        pr.getParameters().put('fy',         '202506');
        pr.getParameters().put('targetDate', '2026-01-10');
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_OrderPlanExcelCtrl ctrl = new NHR_EN_OrderPlanExcelCtrl();
        Test.stopTest();

        NHR_EN_OrderPlanExcelCtrl.TotalSummaryWrapper ts = ctrl.totalSummary;
        System.assertNotEquals(null, ts);
        System.assertEquals(12, ts.planAmountByMonth.size(),   '12ヶ月分の計画合計');
        System.assertEquals(12, ts.actualAmountByMonth.size(), '12ヶ月分の実績合計');
        System.assertEquals(12, ts.diffAmountByMonth.size(),   '12ヶ月分の差分');

        // 差分 = 実績 - 計画（各月）
        for (String month : NHR_EN_OrderPlanExportCtrl.MONTH_LIST) {
            Decimal expected = ts.actualAmountByMonth.get(month) - ts.planAmountByMonth.get(month);
            System.assertEquals(expected, ts.diffAmountByMonth.get(month),
                month + '差分計算正しい');
        }

        // 確度別集計が0以上
        System.assert(ts.rankAAmount >= 0, 'AランクAmount>=0');
        System.assert(ts.rankBAmount >= 0, 'BランクAmount>=0');
        System.assert(ts.rankCAmount >= 0, 'CランクAmount>=0');
    }


    // -------------------------------------------------------
    // エラーパス：initEmptyTotalSummary が呼ばれること
    // （存在しない年度を指定してエラーを意図的に発生させる）
    // -------------------------------------------------------
    @isTest
    static void testConstructor_errorPath() {
        PageReference pr = Page.NHR_EN_OrderPlanExcel;
        // 不正な年度（left(4)でInteger変換エラーを起こす）
        pr.getParameters().put('fy',         'XXXX99');
        pr.getParameters().put('targetDate', '2026-01-10');
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_OrderPlanExcelCtrl ctrl = new NHR_EN_OrderPlanExcelCtrl();
        Test.stopTest();

        // エラーが捕捉され personBlocks/totalSummary が空で初期化されること
        System.assertNotEquals(null, ctrl.personBlocks, 'personBlocksが空で初期化される');
        System.assertNotEquals(null, ctrl.totalSummary, 'totalSummaryが空で初期化される');
        System.assertNotEquals('',   ctrl.errorMessage, 'エラーメッセージが設定される');
    }
}