@isTest 
public with sharing class NHR_ST_CusOrderAmountQuantityBatchTest {
    @isTest 
    static void test01() {
        createTestData();

        Database.executeBatch(new NHR_ST_CusOrderAmountQuantityBatch(), 200);
        NHR_ST_CusOrderAmountQuantityBatch.forTest();
    }

    private static void createTestData(){
        // 共通取引先のレコードタイプを取得
        String ComAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CommonRecordType').getRecordTypeId();

        Account acc = new Account(Name = '株式会社A' , RecordTypeId = ComAccRecTypeId ,ST_Department__c = '事業一部');
        insert acc;

        Integer monthNow = Date.today().month();
        Integer startMonth = 0;
        if(monthNow >= 1 && monthNow <= 6){
            startMonth = 1;
        } else {
            startMonth = 8;
        }

        // 商談の「スチール_工事_材料販売_目標」レコードタイプを取得
        String opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RecordType_Steelzairyou_goal').getRecordTypeId();

        List<Opportunity> opportunities = new List<Opportunity>();
        Opportunity o1 = new Opportunity(Name = '株式会社B 事業1部目標',StageName = '受注',AccountId = acc.Id, ST_Orderamounttarget__c = 100, 
        ST_Orderquantitytarget__c = 100, ST_zyutyuararigaku__c = 100, CloseDate = Date.newInstance(Date.today().year(), startMonth, 1), RecordTypeId = opportunityRecordTypeId);
        opportunities.add(o1);

        Opportunity o2 = new Opportunity(Name = '株式会社B 事業1部目標',StageName = '受注',AccountId = acc.Id,ST_Orderamounttarget__c = 110, 
        ST_Orderquantitytarget__c = 110, ST_zyutyuararigaku__c = 110, CloseDate = Date.newInstance(Date.today().year(), startMonth + 1, 1), RecordTypeId = opportunityRecordTypeId);
        opportunities.add(o2);

        Opportunity o3 = new Opportunity(Name = '株式会社B 事業1部実績',StageName = '受注',AccountId = acc.Id, ST_Estimatedamount__c = 100, 
        ST_suryou__c = 100, ST_grossprofit__c = 100, steel_OrderDate__c = Date.newInstance(Date.today().year(), startMonth, 1), CloseDate = Date.newInstance(Date.today().year(), startMonth, 1), 
        RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RecordType_Steel_sales').getRecordTypeId());
        opportunities.add(o3);

        Opportunity o4 = new Opportunity(Name = '株式会社B 事業1部実績',StageName = '受注',AccountId = acc.Id, ST_Estimatedamount__c = 100, 
        ST_suryou__c = 100, ST_grossprofit__c = 100, steel_OrderDate__c = Date.newInstance(Date.today().year(), startMonth + 1, 1),CloseDate = Date.newInstance(Date.today().year(), startMonth + 1, 1),  
        RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RecordType_Steel_sales').getRecordTypeId());
        opportunities.add(o4);
        insert opportunities;
    }
}