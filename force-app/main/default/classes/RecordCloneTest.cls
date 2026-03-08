@isTest
private class RecordCloneTest {
    
    @IsTest
    private static void controllerTest() {
        
        // insert a record
        Case c = new Case(
        	Subject = 'Test Case'
        );
        insert c;
        
        Case c2 = new Case(
        	Subject = 'Test Child Case',
            ParentId = c.Id
        );
        insert c2;
        Case c3 = new Case(
        	Subject = 'Test Child Case',
            ParentId = c.Id
        );
        insert c3;
        
        Case cc = [SELECT Id, (SELECT Id FROM Cases) FROM Case WHERE Id = :c.Id];
        System.debug(cc.Cases.size());
        
        Account a = new Account(
            Name = 'Test Account'
        );
        insert a;
        
        Opportunity o = new Opportunity(
        	Name = 'Test Opp',
            StageName = 'aaa',
            CloseDate = Date.today(),
            AccountId = a.Id
        );
        insert o;
        
        Contact con = new Contact(
        	FirstName = 'hello',
            LastName = 'hoho'
        );
        insert con;
        
        OpportunityContactRole ocr = new OpportunityContactRole(
            ContactId = con.Id,
            OpportunityId = o.Id,
            IsPrimary = true, 
            Role = 'TestRole'
        );
        
        
        insert ocr;

        // Id recordId, String childRelationshipNames, String excludedFieldNames
        // without relationship, without excludedFields
        RecordCloneController.getSObjectSummary(c.Id, '', '');
        RecordCloneController.getSObjectSummary(c.Id, null, null);
        // with relationship, without excludedFields
        RecordCloneController.getSObjectSummary(c.Id, 'CaseArticles', '');
        RecordCloneController.getSObjectSummary(c.Id, 'CaseArticles, CaseContactRoles, Cases', null);
        // without relationship, with excludedFields
        RecordCloneController.getSObjectSummary(c.Id, '', 'AccountId');
        RecordCloneController.getSObjectSummary(c.Id, null, 'AccountId, SourceId, SuppliedCompany ');
        // with relationship, with excludedFields
        RecordCloneController.getSObjectSummary(c.Id, 'CaseArticles', 'AccountId');
        RecordCloneController.getSObjectSummary(c.Id, 'CaseArticles, CaseContactRoles, Cases ', 'AccountId, SourceId, SuppliedCompany ');
        
        // Id recordId, String objectName, String nameField
        RecordCloneController.getNameFieldValue(a.Id, 'Account', 'Name');
        
        // Id recordId, String newParentRecordName, String childRelationshipNames, String excludedFieldNames
        // without relationship, without excludedFields
        RecordCloneController.execClone(c.Id, '', '', '', '1');
        RecordCloneController.execClone(c.Id, 'hehe', null, null, '1');
        // with relationship, without excludedFields
        RecordCloneController.execClone(c.Id, '', 'CaseArticles', '', '1');
        
        RecordCloneController.execClone(c.Id, 'hehe', 'CaseArticles, CaseContactRoles', null, '3');
        RecordCloneController.execClone(a.Id, 'aaa', 'Opportunities', '', '2');
        // without relationship, with excludedFields
        RecordCloneController.execClone(a.Id, '', '', 'AccountId', '1');
        RecordCloneController.execClone(c.Id, 'hehe', null, 'AccountId, SourceId, SuppliedCompany ', '1');
        // with relationship, with excludedFields
        RecordCloneController.execClone(c.Id, '', 'CaseArticles, Cases', 'AccountId', '1');
        RecordCloneController.execClone(a.Id, 'hehe', 'CaseArticles, CaseContactRoles,  ', 'AccountId, SourceId, SuppliedCompany ', null);
        RecordCloneController.execClone(o.Id, 'aaaa', 'OpportunityContactRoles', '', '2');
        
        // Multiple records
         
        // !!!CAUTION!!!
        // Custom Metadata Types cannot be inserted via Apex.
        // Here is a sample records which you have to add MANUALLY.
        RecordCloneSettings__mdt caseSettings = new RecordCloneSettings__mdt(); 
        caseSettings.DeveloperName = 'TestCaseClone';
        caseSettings.MasterLabel = 'TestCaseClone';
        caseSettings.Language = 'ja';
        caseSettings.Label= 'TestCaseClone';
        caseSettings.QualifiedApiName= 'TestCaseClone';
        caseSettings.ObjectName__c = 'Case';
        caseSettings.ChildRelationshipNames__c = 'CaseSolutions';
        caseSettings.ExcludedFieldNames__c = 'Priority';
        caseSettings.ChildRecordNameType__c = '1';
        // insert caseSettings;
        
        RecordCloneSettings__mdt oppSettings = new RecordCloneSettings__mdt(); 
        oppSettings.DeveloperName = 'TestOppClone';
        oppSettings.MasterLabel = 'TestOppClone';
        oppSettings.Language = 'ja';
        oppSettings.Label= 'TestOppClone';
        oppSettings.QualifiedApiName= 'TestOppClone';
        oppSettings.ObjectName__c = 'Opportunity';
        oppSettings.ChildRelationshipNames__c = 'OpportunityLineItems,OpportunityContactRoles';
        oppSettings.ExcludedFieldNames__c = '';
        oppSettings.ChildRecordNameType__c = '2';
        // insert oppSettings;
        
        List<Id> caseIds = new List<Id>();
        caseIds.add(c.Id);
        caseIds.add(c2.Id);
        caseIds.add(c3.Id);
        List<Id> oppIds = new List<Id>();
        oppIds.add(o.Id);
        List<List<Id>> forInvocable = new List<List<Id>>();
        forInvocable.add(caseIds);
        forInvocable.add(oppIds);
        
        RecordCloneController.clone(forInvocable);
        
        // Debug
        RecordCloneDebugController.showAllChildRelationships(null, 'Account');
        
    }
}