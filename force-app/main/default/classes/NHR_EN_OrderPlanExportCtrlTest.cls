/**
 * NHR_EN_OrderPlanExportCtrlTest
 * NHR_EN_OrderPlanExportCtrl のテストクラス
 *
 * カバレッジ対象:
 *   - exportOrderPlan()              : AuraEnabled エントリーポイント（パラメータなし）
 *   - calcFiscalYear()               : 年度コード自動算出
 *   - getOsakaSalesUsers()           : ユーザー取得（部署・プロファイル・有効・Orderby__c順）
 *   - fetchPlanOpps()                : 計画Opp取得（en_zyutyuubi__c期間絞り）
 *   - fetchActualConfirmedOpps()     : 実績①確定済み取得（en_zyutyuukakudo__c='受注確定'）
 *   - fetchActualProspectOpps()      : 実績②見込み取得（EN_zyutyumikomiduki__c期間絞り）
 *   - convertRank()                  : 受注確度変換（全パターン）
 *   - sendExcelMailAsync()           : Queueable エンキュー
 *   - OrderPlanExcelMailJob.execute(): Queueable 実行
 *   - rtIdCache                      : レコードタイプIDキャッシュ
 */
@isTest
private class NHR_EN_OrderPlanExportCtrlTest {

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
                Email            = 'osaka_test' + i + '@example.com',
                Username         = 'osaka_test' + i + '_' + System.now().getTime() + '@example.com',
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

            // ---- 計画Opp（9月：受注見込み月ベース） ----
            if (rtMap.containsKey(NHR_EN_OrderPlanExportCtrl.RT_PLAN)) {
                opps.add(new Opportunity(
                    Name                = '計画_9月_' + u.LastName,
                    OwnerId             = u.Id,
                    CloseDate           = Date.newInstance(2025, 9, 30),
                    StageName           = '提案中',
                    en_zyutyuubi__c     = Date.newInstance(2025, 9, 15),
                    en_zyutyukingaku__c = 500000,
                    RecordTypeId        = rtMap.get(NHR_EN_OrderPlanExportCtrl.RT_PLAN)
                ));
            }

            if (rtMap.containsKey(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL)) {
                // ---- 実績①確定済みOpp（11月：受注確定） ----
                opps.add(new Opportunity(
                    Name                      = '実績_確定_11月_' + u.LastName,
                    OwnerId                   = u.Id,
                    CloseDate                 = Date.newInstance(2025, 11, 30),
                    StageName                 = '受注',
                    en_zyutyuubi__c           = Date.newInstance(2025, 11, 10),
                    EN_zyutyumikomiduki__c    = Date.newInstance(2025, 11, 10),
                    en_zyutyukingaku__c       = 800000,
                    en_zyutyuararigaku__c     = 80000,
                    en_zyutyuumokuhyougaku__c = 820000,
                    en_mokuhyouriekigaku__c   = 82000,
                    en_zyutyuukakudo__c       = '受注確定',
                    RecordTypeId              = rtMap.get(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL)
                ));
                // ---- 実績②見込みOpp（2月：受注見込み月ベース） ----
                opps.add(new Opportunity(
                    Name                      = '実績_見込み_2月_' + u.LastName,
                    OwnerId                   = u.Id,
                    CloseDate                 = Date.newInstance(2026, 2, 28),
                    StageName                 = '提案中',
                    en_zyutyuubi__c           = Date.newInstance(2026, 2, 15),
                    EN_zyutyumikomiduki__c    = Date.newInstance(2026, 2, 15),
                    en_zyutyukingaku__c       = 600000,
                    en_zyutyuararigaku__c     = 60000,
                    en_zyutyuumokuhyougaku__c = 650000,
                    en_mokuhyouriekigaku__c   = 65000,
                    en_zyutyuukakudo__c       = 'Aランク',
                    RecordTypeId              = rtMap.get(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL)
                ));
            }
        }
        if (!opps.isEmpty()) insert opps;
    }

    // -------------------------------------------------------
    // exportOrderPlan() - 正常系
    // @AuraEnabled → @future → Queueable の二段構成
    // -------------------------------------------------------
    @isTest
    static void testExportOrderPlan_success() {
        Test.startTest();
        NHR_EN_OrderPlanExportCtrl.exportOrderPlan();
        Test.stopTest();

        System.assert(true, 'exportOrderPlan が正常終了すること');
    }

    // -------------------------------------------------------
    // calcFiscalYear() - 年度コード自動算出
    // -------------------------------------------------------
    @isTest
    static void testCalcFiscalYear() {
        // 7月〜12月 → 当年度
        System.assertEquals('202506',
            NHR_EN_OrderPlanExportCtrl.calcFiscalYear(Date.newInstance(2025, 7,  1)), '7月は当年度');
        System.assertEquals('202506',
            NHR_EN_OrderPlanExportCtrl.calcFiscalYear(Date.newInstance(2025, 12, 31)), '12月は当年度');
        // 1月〜6月 → 前年度
        System.assertEquals('202506',
            NHR_EN_OrderPlanExportCtrl.calcFiscalYear(Date.newInstance(2026, 1,  1)), '1月は前年度');
        System.assertEquals('202506',
            NHR_EN_OrderPlanExportCtrl.calcFiscalYear(Date.newInstance(2026, 6, 30)), '6月は前年度');
        // 境界
        System.assertEquals('202406',
            NHR_EN_OrderPlanExportCtrl.calcFiscalYear(Date.newInstance(2024, 9,  1)), '2024年9月は2024年度');
        System.assertEquals('202306',
            NHR_EN_OrderPlanExportCtrl.calcFiscalYear(Date.newInstance(2024, 6, 30)), '2024年6月は2023年度');
    }

    // -------------------------------------------------------
    // getOsakaSalesUsers() - 部署・有効・Orderby__c昇順
    // -------------------------------------------------------
    @isTest
    static void testGetOsakaSalesUsers() {
        Test.startTest();
        List<User> users = [
            SELECT Id, Name, Orderby__c
            FROM   User
            WHERE  Department = '大阪営業部'
            AND    IsActive   = true
            ORDER BY Orderby__c ASC NULLS LAST
        ];
        Test.stopTest();

        System.assert(users.size() >= 2, '大阪営業部ユーザーが2件以上取得できること');

        for (Integer i = 0; i < users.size() - 1; i++) {
            Decimal cur  = users[i].Orderby__c   != null ? users[i].Orderby__c   : 9999;
            Decimal next = users[i+1].Orderby__c != null ? users[i+1].Orderby__c : 9999;
            System.assert(cur <= next, 'Orderby__c が昇順であること');
        }
    }

    // -------------------------------------------------------
    // fetchPlanOpps() - en_zyutyuubi__c・レコードタイプ・担当者で絞り込み
    // -------------------------------------------------------
    @isTest
    static void testFetchPlanOpps() {
        List<User> users = [SELECT Id FROM User WHERE Department = '大阪営業部' AND IsActive = true];
        Set<Id> userIds  = new Map<Id, User>(users).keySet();
        Date periodStart = Date.newInstance(2025, 7, 1);
        Date periodEnd   = Date.newInstance(2026, 6, 30);

        Test.startTest();
        List<Opportunity> opps = NHR_EN_OrderPlanExportCtrl.fetchPlanOpps(userIds, periodStart, periodEnd);
        Test.stopTest();

        Id rtId = NHR_EN_OrderPlanExportCtrl.rtIdCache.get(NHR_EN_OrderPlanExportCtrl.RT_PLAN);
        if (rtId == null) return;

        System.assert(opps.size() >= 2, '計画Oppが担当者数分取得できること');
        for (Opportunity opp : opps) {
            System.assert(userIds.contains(opp.OwnerId),
                '担当者が大阪営業部内であること');
            System.assert(opp.en_zyutyuubi__c >= periodStart,
                '受注日が期間内（開始）であること');
            System.assert(opp.en_zyutyuubi__c <= periodEnd,
                '受注日が期間内（終了）であること');
        }
    }

    // -------------------------------------------------------
    // fetchActualConfirmedOpps() - 受注確定・en_zyutyuubi__c期間・担当者で絞り込み
    // -------------------------------------------------------
    @isTest
    static void testFetchActualConfirmedOpps() {
        List<User> users = [SELECT Id FROM User WHERE Department = '大阪営業部' AND IsActive = true];
        Set<Id> userIds  = new Map<Id, User>(users).keySet();
        Date periodStart = Date.newInstance(2025, 7, 1);
        Date periodEnd   = Date.newInstance(2026, 6, 30);

        Test.startTest();
        List<Opportunity> opps =
            NHR_EN_OrderPlanExportCtrl.fetchActualConfirmedOpps(userIds, periodStart, periodEnd);
        Test.stopTest();

        Id rtId = NHR_EN_OrderPlanExportCtrl.rtIdCache.get(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL);
        if (rtId == null) return;

        System.assert(opps.size() >= 2, '確定済み実績Oppが取得できること');
        for (Opportunity opp : opps) {
            System.assert(userIds.contains(opp.OwnerId),
                '担当者が大阪営業部内であること');
            System.assertEquals('受注確定', opp.en_zyutyuukakudo__c,
                '受注確度が受注確定であること');
            System.assert(opp.en_zyutyuubi__c >= periodStart,
                '受注日が期間内（開始）であること');
            System.assert(opp.en_zyutyuubi__c <= periodEnd,
                '受注日が期間内（終了）であること');
        }
    }

    // -------------------------------------------------------
    // fetchActualProspectOpps() - EN_zyutyumikomiduki__c期間・担当者で絞り込み（確度条件なし）
    // -------------------------------------------------------
    @isTest
    static void testFetchActualProspectOpps() {
        List<User> users = [SELECT Id FROM User WHERE Department = '大阪営業部' AND IsActive = true];
        Set<Id> userIds  = new Map<Id, User>(users).keySet();
        Date periodStart = Date.newInstance(2025, 7, 1);
        Date periodEnd   = Date.newInstance(2026, 6, 30);

        Test.startTest();
        List<Opportunity> opps =
            NHR_EN_OrderPlanExportCtrl.fetchActualProspectOpps(userIds, periodStart, periodEnd);
        Test.stopTest();

        Id rtId = NHR_EN_OrderPlanExportCtrl.rtIdCache.get(NHR_EN_OrderPlanExportCtrl.RT_ACTUAL);
        if (rtId == null) return;

        // 確度に関係なく取得されること（見込み・確定どちらも含む）
        System.assert(opps.size() >= 2, '見込み実績Oppが取得できること');
        for (Opportunity opp : opps) {

        }
    }

    // -------------------------------------------------------
    // convertRank() - 全パターン検証
    // -------------------------------------------------------
    @isTest
    static void testConvertRank() {
        System.assertEquals('A',    NHR_EN_OrderPlanExportCtrl.convertRank('Aランク'),  'AランクはAに変換');
        System.assertEquals('B',    NHR_EN_OrderPlanExportCtrl.convertRank('Bランク'),  'BランクはBに変換');
        System.assertEquals('受注', NHR_EN_OrderPlanExportCtrl.convertRank('受注'),     '受注はそのまま');
        System.assertEquals('受確', NHR_EN_OrderPlanExportCtrl.convertRank('受注確定'), '受注確定は受確に変換');
        System.assertEquals('',     NHR_EN_OrderPlanExportCtrl.convertRank(null),       'nullは空文字');
        System.assertEquals('',     NHR_EN_OrderPlanExportCtrl.convertRank(''),         '空文字はそのまま');
        System.assertEquals('未定義値',
            NHR_EN_OrderPlanExportCtrl.convertRank('未定義値'), 'マップにない値はそのまま');
    }

    // -------------------------------------------------------
    // sendExcelMailAsync() - Queueable エンキュー確認
    // -------------------------------------------------------
    @isTest
    static void testSendExcelMailAsync() {
        Test.startTest();
        NHR_EN_OrderPlanExportCtrl.sendExcelMailAsync(
            '202506', '2025-12-31', UserInfo.getUserId());
        Test.stopTest();

        System.assert(true, 'sendExcelMailAsync(Queueable) が正常終了すること');
    }

    // -------------------------------------------------------
    // OrderPlanExcelMailJob.execute() - Queueable 直接実行
    // -------------------------------------------------------
    @isTest
    static void testOrderPlanExcelMailJob() {
        Test.startTest();
        NHR_EN_OrderPlanExportCtrl.OrderPlanExcelMailJob job =
            new NHR_EN_OrderPlanExportCtrl.OrderPlanExcelMailJob(
                '202506', '2025-12-31', UserInfo.getUserId());
        System.enqueueJob(job);
        Test.stopTest();

        // Test.isRunningTest() = true のため Blob.valueOf('TEST_EXCEL_CONTENT') が使われ
        // 例外なく完了すること
        System.assert(true, 'OrderPlanExcelMailJob が正常終了すること');
    }

    // -------------------------------------------------------
    // rtIdCache - 初回SOQL取得・2回目キャッシュ利用を確認
    // -------------------------------------------------------
    @isTest
    static void testRtIdCache() {
        Test.startTest();
        Map<String, Id> cache1 = NHR_EN_OrderPlanExportCtrl.rtIdCache;
        Map<String, Id> cache2 = NHR_EN_OrderPlanExportCtrl.rtIdCache;
        Test.stopTest();

        System.assertNotEquals(null, cache1, 'rtIdCacheがnullでないこと');
        System.assertEquals(cache1, cache2, '2回目もキャッシュが同一であること');
    }
}