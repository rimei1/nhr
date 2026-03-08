/*
*住環境_カテゴリ別レポートの作成
*/
global without sharing class NHR_JU_CategoryReportBatch implements Database.Batchable<sObject>, Database.Stateful{

    global NHR_JU_CategoryReportBatch(){
    }
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_JU_CategoryReportBatch');

    	String query = NHR_Dao.get_NHR_JU_CategoryReportBatch();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){
        List<JU_Category__c> insList = new List<JU_Category__c>();
        For(Opportunity opp : scopes){
            JU_Category__c obj = new JU_Category__c();
            obj.Opportunity__c = opp.Id;
            obj.Account__c  = opp.AccountId;
            obj.T1_Account__c = opp.Account.ParentId;
            obj.OppStatus__c = opp.StageName;
            obj.FirstEstimates__c = opp.FirstEstimates__c;
            IF(opp.OppotunityProposedProduct__r != NULL && opp.OppotunityProposedProduct__r.size() > 0){
                obj.Category__c = opp.OppotunityProposedProduct__r[0].Category__c;
            }
            insList.add(obj);
        }
        insert insList;
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {

    }

}