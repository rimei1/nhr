/**
 * NHR_EN_PartnerMeetingCtrlTest
 * NHR_EN_PartnerMeetingCtrl / NHR_EN_PartnerMeetingExcelCtrl のテストクラス
 * カバレッジ目標: 75%以上
 */
@isTest
private class NHR_EN_PartnerMeetingCtrlTest {

    // -------------------------------------------------------
    // テストデータ準備
    // -------------------------------------------------------
    @TestSetup
    static void setup() {
        // レコードタイプ取得
        Id rtId = Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName()
            .get('en_zenekonsh')
            .getRecordTypeId();

        Date today   = Date.today();
        Date m1Start = today.toStartOfMonth();           // 当月1日
        Date m2Start = m1Start.addMonths(1);             // 翌月1日
        Date m3Start = m1Start.addMonths(2);             // 翌々月1日
        Date m4Start = m1Start.addMonths(3);             // 翌々月以降

        List<Opportunity> opps = new List<Opportunity>{
            // 当月: Aランク・全条件あり
            new Opportunity(
                Name                      = '当月物件_Aランク',
                RecordTypeId              = rtId,
                StageName                 = '提案中',
                en_ukeoisyunkouyoteibi__c = m1Start.addMonths(6),
                en_zyutyuukakudo__c       = 'Aランク',
                en_kensetuc__c            = 'AAA建設',
                EN_AluminumSupplier__c    = '三協立山(東京)',
                en_ukeoityakkouyoteibi__c = m1Start.addMonths(2),
                en_sesyu__c               = '施主A',
                en_sekkeizimusyo__c       = '設計事務所A',
                EN_zyutyumikomiduki__c    = m1Start,
                CloseDate = Date.newInstance(2026, 1, 31),
                en_zyutyuumokuhyougaku__c = 10000
            ),
            // 翌月: Bランク
            new Opportunity(
                Name                      = '翌月物件_Bランク',
                RecordTypeId              = rtId,
                StageName                 = '提案中',
                en_ukeoisyunkouyoteibi__c = m2Start.addMonths(5),
                en_zyutyuukakudo__c       = 'Bランク',
                en_kensetuc__c            = 'BBB建設',
                EN_AluminumSupplier__c    = '三協立山(東京)',
                en_ukeoityakkouyoteibi__c = m2Start.addMonths(1),
                en_sesyu__c               = '施主B',
                en_sekkeizimusyo__c       = '設計事務所B',
                EN_zyutyumikomiduki__c    = m2Start,
                CloseDate = Date.newInstance(2026, 1, 31),
                en_zyutyuumokuhyougaku__c = 20000
            ),
            // 翌々月: Cランク
            new Opportunity(
                Name                      = '翌々月物件_Cランク',
                RecordTypeId              = rtId,
                StageName                 = '提案中',
                en_ukeoisyunkouyoteibi__c = m3Start.addMonths(4),
                en_zyutyuukakudo__c       = 'Cランク',
                en_kensetuc__c            = 'AAA建設',
                EN_AluminumSupplier__c    = '三協立山(東京)',
                en_ukeoityakkouyoteibi__c = m3Start.addMonths(1),
                en_sesyu__c               = '施主C',
                en_sekkeizimusyo__c       = '設計事務所C',
                EN_zyutyumikomiduki__c    = m3Start,
                CloseDate = Date.newInstance(2026, 1, 31),
                en_zyutyuumokuhyougaku__c = 30000
            ),
            // 翌々月以降: Aランク
            new Opportunity(
                Name                      = '翌々月以降物件_Aランク',
                RecordTypeId              = rtId,
                StageName                 = '提案中',
                en_ukeoisyunkouyoteibi__c = m4Start.addMonths(3),
                en_zyutyuukakudo__c       = 'Aランク',
                en_kensetuc__c            = 'CCC建設',
                EN_AluminumSupplier__c    = '三協立山(東京)',
                en_ukeoityakkouyoteibi__c = m4Start.addMonths(1),
                en_sesyu__c               = '施主D',
                en_sekkeizimusyo__c       = '設計事務所D',
                EN_zyutyumikomiduki__c    = m4Start,
                CloseDate = Date.newInstance(2026, 1, 31),
                en_zyutyuumokuhyougaku__c = 50000
            ),
            // 抽出対象外: Dランク
            new Opportunity(
                Name                      = '除外物件_Dランク',
                RecordTypeId              = rtId,
                StageName                 = '提案中',
                en_ukeoisyunkouyoteibi__c = m1Start.addMonths(6),
                en_zyutyuukakudo__c       = 'Dランク',
                en_kensetuc__c            = 'DDD建設',
                EN_AluminumSupplier__c    = '三協立山(東京)',
                EN_zyutyumikomiduki__c    = m1Start,
                CloseDate = Date.newInstance(2026, 1, 31),
                en_zyutyuumokuhyougaku__c = 99999
            ),
            // 抽出対象外: アルミ発注先ブランク
            new Opportunity(
                Name                      = '除外物件_アルミなし',
                RecordTypeId              = rtId,
                StageName                 = '提案中',
                en_ukeoisyunkouyoteibi__c = m1Start.addMonths(6),
                en_zyutyuukakudo__c       = 'Aランク',
                EN_AluminumSupplier__c    = null,
                EN_zyutyumikomiduki__c    = m1Start,
                CloseDate = Date.newInstance(2026, 1, 31),
                en_zyutyuumokuhyougaku__c = 99999
            ),
            // 抽出対象外: 受注見込み月ブランク
            new Opportunity(
                Name                      = '除外物件_見込月なし',
                RecordTypeId              = rtId,
                StageName                 = '提案中',
                en_ukeoisyunkouyoteibi__c = m1Start.addMonths(6),
                en_zyutyuukakudo__c       = 'Bランク',
                EN_AluminumSupplier__c    = '三協立山(東京)',
                EN_zyutyumikomiduki__c    = null,
                CloseDate = Date.newInstance(2026, 1, 31),
                en_zyutyuumokuhyougaku__c = 99999
            ),
            // 抽出対象外: 受注目標額ブランク
            new Opportunity(
                Name                      = '除外物件_目標額なし',
                RecordTypeId              = rtId,
                StageName                 = '提案中',
                en_ukeoisyunkouyoteibi__c = m1Start.addMonths(6),
                en_zyutyuukakudo__c       = 'Cランク',
                EN_AluminumSupplier__c    = '三協立山(東京)',
                EN_zyutyumikomiduki__c    = m1Start,
                CloseDate = Date.newInstance(2026, 1, 31),
                en_zyutyuumokuhyougaku__c = null
            )
        };
        insert opps;
    }

    // -------------------------------------------------------
    // getMeetingData: 正常系（Aura向け）
    // -------------------------------------------------------
    @isTest
    static void testGetMeetingData_success() {
        Test.startTest();
        NHR_EN_PartnerMeetingCtrl.MeetingDataWrapper wrapper =
            NHR_EN_PartnerMeetingCtrl.getMeetingData();
        Test.stopTest();

        System.assertNotEquals(null, wrapper,       'wrapper が null でない');
        System.assertNotEquals(null, wrapper.rows,  'rows が null でない');
        System.assert(wrapper.rows.size() > 0,      '1件以上取得できる');
        System.assertNotEquals('', wrapper.col1Label, '当月ラベルが設定されている');
        System.assertNotEquals('', wrapper.col4Label, '翌々月以降ラベルが設定されている');
        System.assertNotEquals('', wrapper.targetMonth, '対象月が設定されている');
        System.assertNotEquals('', wrapper.reporterName, '担当者名が設定されている');
    }

    // -------------------------------------------------------
    // 月振り分けロジック: 当月・翌月・翌々月・翌々月以降
    // -------------------------------------------------------
    @isTest
    static void testMonthDistribution() {
        Test.startTest();
        NHR_EN_PartnerMeetingCtrl.MeetingDataWrapper wrapper =
            NHR_EN_PartnerMeetingCtrl.buildWrapper(Date.today());
        Test.stopTest();

        Boolean foundCol1 = false, foundCol2 = false,
                foundCol3 = false, foundCol4 = false;
        for (NHR_EN_PartnerMeetingCtrl.PartnerRowData r : wrapper.rows) {
            if (r.col1Amount != null && r.col1Amount > 0) foundCol1 = true;
            if (r.col2Amount != null && r.col2Amount > 0) foundCol2 = true;
            if (r.col3Amount != null && r.col3Amount > 0) foundCol3 = true;
            if (r.col4Amount != null && r.col4Amount > 0) foundCol4 = true;
        }
        System.assert(foundCol1, '当月列に値がある');
        System.assert(foundCol2, '翌月列に値がある');
        System.assert(foundCol3, '翌々月列に値がある');
        System.assert(foundCol4, '翌々月以降列に値がある');
    }

    // -------------------------------------------------------
    // 並び順: 施工会社昇順 → 受注見込み月昇順
    // -------------------------------------------------------
    @isTest
    static void testOrderBy() {
        Test.startTest();
        NHR_EN_PartnerMeetingCtrl.MeetingDataWrapper wrapper =
            NHR_EN_PartnerMeetingCtrl.buildWrapper(Date.today());
        Test.stopTest();

        // 施工会社名が昇順になっていることを確認
        String prev = '';
        for (NHR_EN_PartnerMeetingCtrl.PartnerRowData r : wrapper.rows) {
            if (r.sekoCompany != null && prev != '') {
                System.assert(r.sekoCompany >= prev,
                    '施工会社昇順: ' + prev + ' <= ' + r.sekoCompany);
            }
            if (r.sekoCompany != null) prev = r.sekoCompany;
        }
    }

    // -------------------------------------------------------
    // 抽出条件: Dランクは対象外
    // -------------------------------------------------------
    @isTest
    static void testExclude_DRank() {
        Test.startTest();
        NHR_EN_PartnerMeetingCtrl.MeetingDataWrapper wrapper =
            NHR_EN_PartnerMeetingCtrl.getMeetingData();
        Test.stopTest();

        for (NHR_EN_PartnerMeetingCtrl.PartnerRowData r : wrapper.rows) {
            System.assertNotEquals('Dランク', r.rank, 'Dランクが含まれていない');
        }
    }

    // -------------------------------------------------------
    // 抽出条件: OwnerId = ログインユーザーのみ
    // -------------------------------------------------------
    @isTest
    static void testFilter_OwnerOnly() {
        // 別ユーザーで商談を作成し、ログインユーザーの商談のみ返ることを確認
        Profile p = [SELECT Id FROM Profile WHERE Name = 'システム管理者' LIMIT 1];
        User otherUser = new User(
            LastName         = '別担当',
            Email            = 'other_partner@example.com',
            Username         = 'other_partner_' + System.now().getTime() + '@example.com',
            Alias            = 'other',
            TimeZoneSidKey   = 'Asia/Tokyo',
            LocaleSidKey     = 'ja_JP',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey= 'ja',
            ProfileId        = p.Id
        );
        insert otherUser;

        Id rtId = Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName()
            .get('en_zenekonsh')
            .getRecordTypeId();

        Opportunity otherOpp = new Opportunity(
            Name                      = '別ユーザー物件',
            OwnerId                   = otherUser.Id,
            RecordTypeId              = rtId,
            StageName                 = '提案中',
            en_ukeoisyunkouyoteibi__c = Date.today().addMonths(6),
            en_zyutyuukakudo__c       = 'Aランク',
            EN_AluminumSupplier__c    = '三協立山(東京)',
            EN_zyutyumikomiduki__c    = Date.today().toStartOfMonth(),
            CloseDate = Date.newInstance(2026, 1, 31),
            en_zyutyuumokuhyougaku__c = 99999
        );
        insert otherOpp;

        Test.startTest();
        NHR_EN_PartnerMeetingCtrl.MeetingDataWrapper wrapper =
            NHR_EN_PartnerMeetingCtrl.getMeetingData();
        Test.stopTest();

        // 取得件数はログインユーザー分のみ（別ユーザーの99999千円は含まれない）
        for (NHR_EN_PartnerMeetingCtrl.PartnerRowData r : wrapper.rows) {
            System.assertNotEquals('別ユーザー物件', r.bukenName, '別ユーザーの商談が含まれていない');
        }
    }

    // -------------------------------------------------------
    // enqueueExcelMail: Queueableエンキュー正常終了
    // -------------------------------------------------------
    @isTest
    static void testEnqueueExcelMail() {
        Test.startTest();
        NHR_EN_PartnerMeetingCtrl.enqueueExcelMail();
        Test.stopTest();

        System.assert(true, 'enqueueExcelMail が例外なく完了');
    }

    // -------------------------------------------------------
    // Queueable execute: メール送信（Blobダミー化）
    // -------------------------------------------------------
    @isTest
    static void testQueueableExecute_success() {
        String targetMonthParam = String.valueOf(Date.today().toStartOfMonth());
        Id     userId           = UserInfo.getUserId();

        NHR_EN_PartnerMeetingCtrl.PartnerMeetingExcelMailJob job =
            new NHR_EN_PartnerMeetingCtrl.PartnerMeetingExcelMailJob(targetMonthParam, userId);

        Test.startTest();
        job.execute(null);
        Test.stopTest();

        System.assert(true, 'Queueable execute が例外なく完了');
    }

    // -------------------------------------------------------
    // getMeetingDataForVF: 正常系（Date形式パラメータ）
    // -------------------------------------------------------
    @isTest
    static void testGetMeetingDataForVF_validParam() {
        String param = String.valueOf(Date.today().toStartOfMonth());

        Test.startTest();
        NHR_EN_PartnerMeetingCtrl.MeetingDataWrapper wrapper =
            NHR_EN_PartnerMeetingCtrl.getMeetingDataForVF(param);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.rows);
        System.assert(wrapper.rows.size() > 0, '1件以上取得できる');
    }

    // -------------------------------------------------------
    // getMeetingDataForVF: 不正パラメータ（例外ハンドリング）
    // -------------------------------------------------------
    @isTest
    static void testGetMeetingDataForVF_invalidParam() {
        Test.startTest();
        NHR_EN_PartnerMeetingCtrl.MeetingDataWrapper wrapper =
            NHR_EN_PartnerMeetingCtrl.getMeetingDataForVF('invalid-param');
        Test.stopTest();

        // 例外なく今日の月で処理されること
        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.rows);
    }

    // -------------------------------------------------------
    // getMeetingDataForVF: nullパラメータ（デフォルト動作）
    // -------------------------------------------------------
    @isTest
    static void testGetMeetingDataForVF_nullParam() {
        Test.startTest();
        NHR_EN_PartnerMeetingCtrl.MeetingDataWrapper wrapper =
            NHR_EN_PartnerMeetingCtrl.getMeetingDataForVF(null);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.col1Label);
    }

    // -------------------------------------------------------
    // VFコントローラ: URLパラメータあり・正常系
    // -------------------------------------------------------
    @isTest
    static void testExcelCtrl_withParam() {
        PageReference pr = Page.NHR_EN_PartnerMeetingExcel;
        pr.getParameters().put('targetMonth', String.valueOf(Date.today().toStartOfMonth()));
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_PartnerMeetingExcelCtrl ctrl = new NHR_EN_PartnerMeetingExcelCtrl();
        Test.stopTest();

        System.assertNotEquals(null, ctrl.meetingRows, 'meetingRowsが取得できる');
        System.assertNotEquals(null, ctrl.emptyRows,   'emptyRowsが設定される');
        System.assertEquals('',     ctrl.errorMessage, 'エラーなし');
        System.assert(ctrl.meetingRows.size() > 0, '1件以上取得できる');
        System.assertEquals(
            NHR_EN_PartnerMeetingCtrl.MAX_DATA_ROWS,
            ctrl.meetingRows.size() + ctrl.emptyRows.size(),
            'データ行 + 空行 = MAX_DATA_ROWS'
        );
    }

    // -------------------------------------------------------
    // VFコントローラ: URLパラメータなし（デフォルト動作）
    // -------------------------------------------------------
    @isTest
    static void testExcelCtrl_withoutParam() {
        PageReference pr = Page.NHR_EN_PartnerMeetingExcel;
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_PartnerMeetingExcelCtrl ctrl = new NHR_EN_PartnerMeetingExcelCtrl();
        Test.stopTest();

        System.assertNotEquals(null, ctrl.meetingRows);
        System.assertNotEquals(null, ctrl.sheetName);
        System.assertEquals('', ctrl.errorMessage, 'エラーなし');
    }

    // -------------------------------------------------------
    // VFコントローラ: 合計値の整合性（totalCol1〜4）
    // -------------------------------------------------------
    @isTest
    static void testExcelCtrl_totals() {
        PageReference pr = Page.NHR_EN_PartnerMeetingExcel;
        pr.getParameters().put('targetMonth', String.valueOf(Date.today().toStartOfMonth()));
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_PartnerMeetingExcelCtrl ctrl = new NHR_EN_PartnerMeetingExcelCtrl();
        Test.stopTest();

        // 手動集計してコントローラの合計と一致することを確認
        Decimal sumCol1 = 0, sumCol2 = 0, sumCol3 = 0, sumCol4 = 0;
        for (NHR_EN_PartnerMeetingCtrl.PartnerRowData r : ctrl.meetingRows) {
            sumCol1 += r.col1Amount != null ? r.col1Amount : 0;
            sumCol2 += r.col2Amount != null ? r.col2Amount : 0;
            sumCol3 += r.col3Amount != null ? r.col3Amount : 0;
            sumCol4 += r.col4Amount != null ? r.col4Amount : 0;
        }
        System.assertEquals(sumCol1, ctrl.totalCol1, '当月合計が一致');
        System.assertEquals(sumCol2, ctrl.totalCol2, '翌月合計が一致');
        System.assertEquals(sumCol3, ctrl.totalCol3, '翌々月合計が一致');
        System.assertEquals(sumCol4, ctrl.totalCol4, '翌々月以降合計が一致');
    }

    // -------------------------------------------------------
    // VFコントローラ: 月ヘッダーラベルの動的生成
    // -------------------------------------------------------
    @isTest
    static void testExcelCtrl_monthLabels() {
        PageReference pr = Page.NHR_EN_PartnerMeetingExcel;
        pr.getParameters().put('targetMonth', String.valueOf(Date.today().toStartOfMonth()));
        Test.setCurrentPage(pr);

        Test.startTest();
        NHR_EN_PartnerMeetingExcelCtrl ctrl = new NHR_EN_PartnerMeetingExcelCtrl();
        Test.stopTest();

        Integer thisMonth = Date.today().month();
        System.assert(ctrl.col1Label.contains(String.valueOf(thisMonth)), '当月ラベルに月番号が含まれる');
        System.assert(ctrl.col1Label.contains('予定'), 'ラベルに「予定」が含まれる');
        System.assert(ctrl.col4Label.contains('〜'),   '翌々月以降ラベルに「〜」が含まれる');
    }
}