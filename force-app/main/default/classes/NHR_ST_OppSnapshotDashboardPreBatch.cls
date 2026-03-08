/*
 * 【ST】スチール経営ダッシュボード
 */
global without sharing class NHR_ST_OppSnapshotDashboardPreBatch implements Database.Batchable<sObject>, Database.Stateful{
    global NHR_ST_OppSnapshotDashboardPreBatch(){}

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_ST_OppSnapshotDashboardPreBatch');
        String query = NHR_Dao.get_NHR_ST_OppSnapshotDashboardPreBatch();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<ST_ManagementDashboard__c> scopes){
        delete scopes;
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        NHR_ST_OppSnapshotDashboardBatch myBatchObject = new NHR_ST_OppSnapshotDashboardBatch();
        Database.executeBatch(myBatchObject,2000);
    }
}