@isTest
public with sharing class NHR_ST_ConstructionOrderAchieveBatchTest {
    @isTest 
    static void test01() {
        createTestData();

        Database.executeBatch(new NHR_ST_ConstructionOrderAchievementBatch(), 200);
        NHR_ST_ConstructionOrderAchievementBatch.forTest();
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
        String yosanRecordTypeId = Schema.SObjectType.ST_yojitsu__c.getRecordTypeInfosByDeveloperName().get('ST_yosan').getRecordTypeId();
        String jisekiRecordTypeId = Schema.SObjectType.ST_yojitsu__c.getRecordTypeInfosByDeveloperName().get('ST_jissekin').getRecordTypeId();

        List<ST_yojitsu__c> yojitsuList = new List<ST_yojitsu__c>();
        ST_yojitsu__c yojitsu1 = new ST_yojitsu__c(ST_zyutyuubi__c = Date.newInstance(Date.today().year(), startMonth, 1), ST_Orderquantitytarget__c = 100, Account__c=acc.Id, RecordTypeId = yosanRecordTypeId);
        yojitsuList.add(yojitsu1);

        ST_yojitsu__c yojitsu2 = new ST_yojitsu__c(ST_zyutyuubi__c = Date.newInstance(Date.today().year(), startMonth+1, 1), ST_Orderquantitytarget__c = 100, Account__c=acc.Id, RecordTypeId = yosanRecordTypeId);
        yojitsuList.add(yojitsu2);

        ST_yojitsu__c yojitsu3 = new ST_yojitsu__c(ST_zyutyuubi__c = Date.newInstance(Date.today().year(), startMonth, 1), ST_suryou__c = 100, Account__c=acc.Id, RecordTypeId = jisekiRecordTypeId);
        yojitsuList.add(yojitsu3);
        
        ST_yojitsu__c yojitsu4 = new ST_yojitsu__c(ST_zyutyuubi__c = Date.newInstance(Date.today().year(), startMonth+1, 1), ST_suryou__c = 100, Account__c=acc.Id, RecordTypeId = jisekiRecordTypeId);
        yojitsuList.add(yojitsu4);

        ST_yojitsu__c yojitsu5 = new ST_yojitsu__c(ST_zyutyuubi__c = Date.newInstance(Date.today().year(), startMonth+2, 1), ST_suryou__c = 100, Account__c=acc.Id, RecordTypeId = jisekiRecordTypeId);
        yojitsuList.add(yojitsu5);
        insert yojitsuList;
    }
}