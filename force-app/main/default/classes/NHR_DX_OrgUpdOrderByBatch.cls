global without sharing class NHR_DX_OrgUpdOrderByBatch implements Database.Batchable<sObject>, Database.Stateful{

    global Map<String ,Map<String ,decimal>> orgMap {get;set;}
    
    global NHR_DX_OrgUpdOrderByBatch(){
    }
    
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_DX_OrgUpdOrderByBatch');
        setInit();
        Set<String> AccountIdList = orgMap.keySet();
        String query = getSOQL();
        return Database.getQueryLocator(query);
    }
    
    //開始
    global void execute(Database.BatchableContext BC, List<Contact> scopes){
        
        for(Contact obj : scopes) {
            if (orgMap.containskey(obj.AccountId)) {
                Map<String ,decimal> tempMap = orgMap.get(obj.AccountId);
                if (tempMap.containskey(obj.Department)) {
                    obj.OrderBy__c = tempMap.get(obj.Department);
                } else {
                     obj.OrderBy__c = null;
                }
            } else {
                obj.OrderBy__c = null;
            }
        }
        
        update scopes;
    }
    
     //完了
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    /** 
     * 初期設定
     */
    private void setInit(){
        orgMap = new Map<String ,Map<String ,decimal>>();
        List<OrgManagement__c> orgList = new List<OrgManagement__c>();
        orgList = [Select id ,Department__c ,Account__c ,OrderBy__c 
                          From OrgManagement__c
                           Where Account__c != null];
        
        for (OrgManagement__c obj : orgList) {
            if (orgMap.containskey(obj.Account__c)) {
                Map<String ,decimal> tempMap = orgMap.get(obj.Account__c);
                tempMap.put(obj.Department__c,obj.OrderBy__c );
                orgMap.put(obj.Account__c,tempMap );
            } else {
                Map<String ,decimal> tempMap = new Map<String ,decimal>();
                tempMap.put(obj.Department__c,obj.OrderBy__c );
                orgMap.put(obj.Account__c,tempMap );
            }
        }
    }
    private String getSOQL(){
        String soql = '';
        soql += ' SELECT ';
        soql += ' Id  ,';
        soql += ' OrderBy__c  ,'; 
        soql += ' Department  ,'; 
        soql += ' AccountId '; 
        soql += ' FROM Contact  ';
        soql += ' WHERE ';
        soql += '  AccountId   in :AccountIdList';

        system.debug('soql:' + soql);
        return soql;
    }
}