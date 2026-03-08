@isTest
public class NHR_JU_CategoryReportBatchTest {
    
    @isTest static void test2() {
        String JURecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Jukankyo').getRecordTypeId();
        List<Opportunity> insList = new List<Opportunity>();
        insList.add(new Opportunity(Name = 'JU商談' , RecordTypeId = JURecTypeId,StageName = '未着手' 
                                    ,CloseDate =  Date.Today().addMonths(1) ,Department__c='営業一部'));
        insert insList;
        test.startTest();
        NHR_JU_CategoryReportCtrl.NHR_Execution();
        test.stopTest();
    }
}