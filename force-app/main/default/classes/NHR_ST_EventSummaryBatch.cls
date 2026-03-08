/*
 * 【ST】指定された範囲の商談Objに紐づく行動が、「前回からの活動」項目に紐づく
 */
global without sharing class NHR_ST_EventSummaryBatch implements Database.Batchable<sObject>, Database.Stateful{
    /** 改行 */
    global static final String CR_LF = '\r\n';
    /** 開始日付 */
    global Date startDate;
    /** 終了日付 */
    global Date endDate;
    global NHR_ST_EventSummaryBatch(Date inStartDate , Date inEndDate){
        startDate = inStartDate;
        endDate = inEndDate;
    }

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_ST_EventSummaryBatch');
    	String query = getSoql();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){

        for(Opportunity obj : scopes) {
            if(obj.Events != NULL && obj.Events.size() > 0) {
                obj.PreviousEvents__c = '';
                for(Event subObj : obj.Events) {
                    obj.PreviousEvents__c += String.valueOf(subObj.ActivityDate) + '' + subObj.Subject + CR_LF + subObj.Description + CR_LF + CR_LF;
                }
                
            } else {
                obj.PreviousEvents__c = '';
            }
        }
        
        update scopes;
    }

     //完了
    global void finish(Database.BatchableContext BC){
        mailSend();
    }
    
    global static String getSoql(){
        String soql = '';
        soql += ' SELECT ';
        soql += ' Id';
        soql += ' ,PreviousEvents__c ';
        soql += ' ,(Select Id ,ActivityDate ,Subject ,Description From Events Where ActivityDate >= :startDate AND ActivityDate <= :endDate order by ActivityDate) ';
        soql += ' FROM Opportunity  ';
        soql += ' WHERE ';
        soql += '  recordtype.DeveloperName = \'RecordType_SteelCons\'';
        if(!Test.isRunningTest()){soql += '  AND StageName in (\'A\',\'B\',\'C\',\'D\',\'E\',\'F\',\'G\',\'H\',\'内定\',\'受注ST\',\'仕掛\')';}

        return soql;
    }
    
    /*
    * メール送信
    */
    private void mailSend(){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(new List<String>{UserInfo.getUserEmail()}); // 送信先(String[])
        
        mail.setSubject('「商談への活動紐づけ」処理完了のお知らせ'); // 件名(String)
        mail.setPlainTextBody('商談への活動紐づけが完了いたしました。'); // 本文(String)
        
        mail.setReplyTo(UserInfo.getUserEmail()); // 返信先メールアドレス(String)
        
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
}