/*
 * 【ST】今週の活動・先週の活動・先々週の活動は週毎に自動変更
 */
global without sharing class NHR_ST_ActivityChangeBatch implements Database.Batchable<sObject>, Database.Stateful{
   
    global NHR_ST_ActivityChangeBatch(){}

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_ST_ActivityChangeBatch');
    	String query = getSoql();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){

        for(Opportunity obj : scopes) {
            obj.Last2WeekActive__c = obj.LastWeekActive__c;
            obj.LastWeekActive__c = obj.ThisWeekActive__c;
            obj.ThisWeekActive__c = '';
        }
        
        update scopes;
    }

     //完了
    global void finish(Database.BatchableContext BC){}
    
    global static String getSoql(){
        String soql = '';
        soql += ' SELECT ';
        soql += ' Id';
        soql += ' ,ThisWeekActive__c ';
        soql += ' ,LastWeekActive__c ';
        soql += ' ,Last2WeekActive__c ';
        soql += ' FROM Opportunity  ';
        soql += ' WHERE ';
        soql += '  recordtype.DeveloperName in (\'RecordType_SteelCons\',\'RecordType_Steel_sales\')';
        if(!Test.isRunningTest()){soql += '  AND (ThisWeekActive__c != NULL OR Last2WeekActive__c != NULL OR LastWeekActive__c != NULL)';}

        return soql;
    }
}