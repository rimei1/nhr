@isTest
private class NHR_SummaryApprovedCtrlTest {

    @isTest
    static void testNHRApproved() {
        // 2. 日報レコード（例：SummaryReport__c）を作成
        SummaryReport__c report = new SummaryReport__c(Name = 'Test Report');
        insert report;

        // 5. テスト対象メソッドの呼び出し
        Test.startTest();
        NHR_SummaryApprovedCtrl.Request input = new NHR_SummaryApprovedCtrl.Request();
        input.SummaryReportId = report.id;
        input.CommentStr = '承認します。';

        NHR_SummaryApprovedCtrl.NHR_Approved(new List<NHR_SummaryApprovedCtrl.Request>{ input });
        NHR_SummaryApprovedCtrl.forTest();
        Test.stopTest();

    }
}