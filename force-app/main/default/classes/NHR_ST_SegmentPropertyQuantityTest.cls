@isTest 
public with sharing class NHR_ST_SegmentPropertyQuantityTest {
    @isTest 
    static void test01() {
        createTestData();

        Database.executeBatch(new NHR_ST_SegmentPropertyQuantity(), 200);
        NHR_ST_SegmentPropertyQuantity.forTest();
    }

    static void createTestData(){
        Date theToday = Date.Today();
        Date forGetDay = Date.Today();
        if (theToday.month() == 7) {
            forGetDay = theToday.addMonths(-1);
        }

        Date startDate = NHR_Dao.getFiscalYearStartDate(forGetDay);
        Date endDate = NHR_Dao.getFiscalYearEndDate(forGetDay);

        String currentLastMonth = endDate.year() + '年' + endDate.month() + '月期';

        // 共通取引先のレコードタイプを取得
        String comAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CommonRecordType').getRecordTypeId();
        Account acc = new Account(Name = '株式会社A' , RecordTypeId = ComAccRecTypeId ,ST_Department__c = '事業一部', ST_focustype_kouji__c='積極', ST_focustype_boukoubu__c='積極');
        Account acc1 = new Account(Name = '株式会社B' , RecordTypeId = ComAccRecTypeId ,ST_Department__c = '事業二部');
        insert new List<Account>{ acc, acc1 };

        String opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RecordType_Steelzairyou_goal').getRecordTypeId();

        List<Opportunity> opportunities = new List<Opportunity>();
        Opportunity o1 = new Opportunity(Name = '株式会社B 事業1部目標',StageName = 'A',AccountId = acc.Id, ST_Orderamounttarget__c = 100, 
        ST_Orderquantitytarget__c = 100, ST_zyutyuararigaku__c = 100, CloseDate = Date.today(), RecordTypeId = opportunityRecordTypeId);
        opportunities.add(o1);

        Opportunity o2 = new Opportunity(Name = '株式会社B 事業1部目標',StageName = 'C',AccountId = acc1.Id, ST_Orderamounttarget__c = 100, 
        ST_Orderquantitytarget__c = 100, ST_zyutyuararigaku__c = 100, CloseDate = Date.today(), RecordTypeId = opportunityRecordTypeId);
        opportunities.add(o2);
        insert opportunities;

        ST_Yojitsu_Snapshot__c snapshot01 = new ST_Yojitsu_Snapshot__c(Opportunity__c=o1.Id, ST_suryou__c=100);
        ST_Yojitsu_Snapshot__c snapshot02 = new ST_Yojitsu_Snapshot__c(Opportunity__c=o2.Id, ST_suryou__c=100);
        insert new List<ST_Yojitsu_Snapshot__c>{ snapshot01, snapshot02 };
    }
}