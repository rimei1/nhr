@isTest
public with sharing class ContentDocumentLinkTriggerHandlerTest {
    @isTest
    static void test(){
        String cdlId =  createData();

        Map<Id, ContentDocumentLink> newMap = new Map<Id, ContentDocumentLink>([SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE Id = :cdlId]);
        ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
        handler.handleAfterInsert(newMap);
    }

    public static String createData(){
        // 共通取引先のレコードタイプを取得
        String ComAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CommonRecordType').getRecordTypeId();
        Account acc = new Account(Name = '株式会社A' , RecordTypeId = ComAccRecTypeId ,ST_Department__c = '事業一部');
        insert acc;

        ContentVersion conObject = new ContentVersion();
        conObject.title = '見積.xls';
        conObject.PathOnClient = '見積.xls';
        conObject.versiondata=Blob.valueOf('Test Content Data');
        insert conObject;

        String opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Jukankyo').getRecordTypeId();
        Opportunity o1 = new Opportunity(Name = '株式会社B 事業1部目標',StageName = '受注',AccountId = acc.Id, ST_Orderamounttarget__c = 100, 
        ST_Orderquantitytarget__c = 100, ST_zyutyuararigaku__c = 100, CloseDate = Date.newInstance(Date.today().year(), 1, 1), RecordTypeId = opportunityRecordTypeId);
        insert o1;

        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conObject.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = cv.ContentDocumentId, LinkedEntityId = o1.Id, ShareType = 'V', Visibility = 'AllUsers');
        insert cdl;

        return cdl.Id;
    }
}