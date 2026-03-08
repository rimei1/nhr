@isTest
public with sharing class NHR_ST_EventSummaryBatchTest {
    @isTest 
    static void test01() {
        createTestData();
        List<NHR_ST_EventSummaryCtrl.InputInfo> infos = new List<NHR_ST_EventSummaryCtrl.InputInfo>();
        NHR_ST_EventSummaryCtrl.InputInfo info = new NHR_ST_EventSummaryCtrl.InputInfo();
        info.StartDate = Date.today().addDays(-30);
        info.EndDate = Date.today();
        infos.add(info);

        NHR_ST_EventSummaryCtrl.NHR_ST_EventSummary(infos);

    }
    
    private static void createTestData(){
        // 共通取引先のレコードタイプを取得
        String ComAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CommonRecordType').getRecordTypeId();

        Account acc = new Account(Name = '株式会社A' , RecordTypeId = ComAccRecTypeId ,ST_Department__c = '事業一部', ST_focustype_kouji__c='積極', ST_focustype_boukoubu__c = '積極');
        Account acc1 = new Account(Name = '株式会社B' , RecordTypeId = ComAccRecTypeId ,ST_Department__c = '事業一部');
        insert new List<Account>{ acc, acc1 };

        Integer monthNow = Date.today().month();
        Integer startMonth = 0;
        if(monthNow >= 1 && monthNow <= 6){
            startMonth = 1;
        } else {
            startMonth = 8;
        }

        // 商談の「スチール_工事_材料販売_目標」レコードタイプを取得
        String opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RecordType_SteelCons').getRecordTypeId();

        List<Opportunity> opportunities = new List<Opportunity>();
        Opportunity o1 = new Opportunity(Name = '株式会社A 事業一部目標',StageName = '受注',CloseDate = Date.newInstance(Date.today().year(), startMonth, 1),AccountId = acc.Id, ST_Orderamounttarget__c = 100, 
        ST_Orderquantitytarget__c = 100, ST_zyutyuararigaku__c = 100, steel_OrderDate__c = Date.newInstance(Date.today().year(), startMonth, 1), RecordTypeId = opportunityRecordTypeId);
        opportunities.add(o1);
        Opportunity o2 = new Opportunity(Name = '株式会社A 事業一部目標',StageName = '受注',CloseDate = Date.newInstance(Date.today().year(), startMonth + 1, 1),AccountId = acc.Id,ST_Orderamounttarget__c = 110, 
        ST_Orderquantitytarget__c = 110, ST_zyutyuararigaku__c = 110, steel_OrderDate__c = Date.newInstance(Date.today().year(), startMonth + 1, 1), RecordTypeId = opportunityRecordTypeId);
        opportunities.add(o2);

        Opportunity o3 = new Opportunity(Name = '株式会社B 事業一部目標',StageName = '受注',CloseDate = Date.newInstance(Date.today().year(), startMonth, 1),AccountId = acc1.Id, ST_Orderamounttarget__c = 100, 
        ST_Orderquantitytarget__c = 100, ST_zyutyuararigaku__c = 100, steel_OrderDate__c = Date.newInstance(Date.today().year(), startMonth, 1), RecordTypeId = opportunityRecordTypeId);
        opportunities.add(o3);
        Opportunity o4 = new Opportunity(Name = '株式会社B 事業一部目標',StageName = '受注',CloseDate = Date.newInstance(Date.today().year(), startMonth + 1, 1),AccountId = acc1.Id,ST_Orderamounttarget__c = 110, 
        ST_Orderquantitytarget__c = 110, ST_zyutyuararigaku__c = 110, steel_OrderDate__c = Date.newInstance(Date.today().year(), startMonth + 1, 1), RecordTypeId = opportunityRecordTypeId);
        opportunities.add(o4);

        String jisekiRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RecordType_Steel_sales').getRecordTypeId();

        Opportunity o5 = new Opportunity(Name = '株式会社A 事業一部実績',StageName = '受注',CloseDate = Date.today(),AccountId = acc.Id, ST_Estimatedamount__c = 100, 
        ST_suryou__c = 100, ST_grossprofit__c = 100, steel_OrderDate__c = Date.newInstance(Date.today().year(), startMonth, 1), RecordTypeId = jisekiRecordTypeId);
        opportunities.add(o5);
        Opportunity o6 = new Opportunity(Name = '株式会社A 事業一部実績',StageName = '受注',CloseDate = Date.today(),AccountId = acc.Id, ST_Estimatedamount__c = 100, 
        ST_suryou__c = 100, ST_grossprofit__c = 100, steel_OrderDate__c = Date.newInstance(Date.today().year(), startMonth + 1, 1), RecordTypeId = jisekiRecordTypeId);
        opportunities.add(o6);

        Opportunity o7 = new Opportunity(Name = '株式会社B 事業1部実績',StageName = '受注',CloseDate = Date.today(),AccountId = acc1.Id, ST_Estimatedamount__c = 100, 
        ST_suryou__c = 100, ST_grossprofit__c = 100, steel_OrderDate__c = Date.newInstance(Date.today().year(), startMonth, 1), RecordTypeId = jisekiRecordTypeId);
        opportunities.add(o7);
        Opportunity o8 = new Opportunity(Name = '株式会社B 事業1部実績',StageName = '受注',CloseDate = Date.today(),AccountId = acc1.Id, ST_Estimatedamount__c = 100, 
        ST_suryou__c = 100, ST_grossprofit__c = 100, steel_OrderDate__c = Date.newInstance(Date.today().year(), startMonth + 1, 1), RecordTypeId = jisekiRecordTypeId);
        opportunities.add(o8);
        insert opportunities;
        
        Event eObj = new Event(EndDateTime = DateTime.now() , StartDateTime = DateTime.now(),Description='test',Subject='test',WhatId = opportunities[0].Id);
        insert eObj;
        
    }
}