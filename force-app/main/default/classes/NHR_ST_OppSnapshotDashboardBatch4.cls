/*
 * 【ST】スチール経営ダッシュボード
 * ■追及物件「件数」と「確度」月別推移
 */
global without sharing class NHR_ST_OppSnapshotDashboardBatch4 implements Database.Batchable<sObject>, Database.Stateful{
   
    global NHR_ST_OppSnapshotDashboardBatch4(){}
    global Map<String ,ST_ManagementDashboard__c> reportMap1 {get;set;}
    //global List<String> type1List{get;set;}
    //global List<String> type2List{get;set;}


    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_ST_OppSnapshotDashboardBatch4');

        //type1List = new List<String>{'1_全体' ,'2_事業一部' ,'3_事業二部'};
        //type2List = new List<String>{'AB' ,'CD' ,'EF','GH' ,'失注' ,'受注'};

        //setInit();
        String query = NHR_Dao.get_NHR_ST_OppSnapshotDashboardBatch4();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<ST_Opportunity_Snapshot__c> scopes){

        List<ST_ManagementDashboard__c> tempInfoList = new List<ST_ManagementDashboard__c>();
        for(ST_Opportunity_Snapshot__c obj : scopes) {
            ST_ManagementDashboard__c tempInfo = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_sum = new ST_ManagementDashboard__c();


            String keyStr = obj.StageName__c;
            if (keyStr == 'A' || keyStr == 'B') {
                keyStr = 'AB';
            } else if (keyStr == 'C' || keyStr == 'D') {
                keyStr = 'CD';
            } else if (keyStr == 'E' || keyStr == 'F') {
                keyStr = 'EF';
            } else if (keyStr == 'G' || keyStr == 'H') {
                keyStr = 'GH';
            } else if (keyStr == '受注ST' || keyStr == '完成') {
                keyStr = '受注';
            } else if (keyStr == '辞退' || keyStr == '仕掛') {
                keyStr = '失注';
            } 


            tempInfo = setFC(NHR_Constant.BATCHNAME_ST_OSD3 + keyStr + obj.AccountId__c, '追及物件「件数」と「確度」月別推移_その他' , '重要取引先' ,obj, keyStr,'',0);
            tempInfo_sum = setFC(NHR_Constant.BATCHNAME_ST_OSD3 + keyStr + obj.AccountId__c, '追及物件「件数」と「確度」月別推移_その他' , '全体' ,obj, keyStr,'',0);
            tempInfoList.add(tempInfo);
            tempInfoList.add(tempInfo_sum);

        }
        
        insert tempInfoList;

    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        //system.debug('reportMap1.values();' + reportMap1.values());
        //insert reportMap1.values();
        
        mailSend();
    }
    
    /**
     * 初期設定
    
    private void setInit(){
        reportMap1 = new Map<String ,ST_ManagementDashboard__c>();
        
        //全体・事業
        Integer tempOrderNum0 = 100 ;
        Integer orderNum0 = 100 ;
        
        for(String str0 : type1List) {
            Integer s1 = 1;
            for (String str1 : type2List) {
                reportMap1.put(NHR_Constant.BATCHNAME_ST_OSD4 + str1 + str0 , setFC(NHR_Constant.BATCHNAME_ST_OSD4 + str1 + str0, '追及物件「件数」と「確度」月別推移_その他' , '全体' , str0,str0, str1,'',orderNum0));
                orderNum0 += 1;
                s1 += 1;
            }
            orderNum0 = tempOrderNum0 +  1000;
        }
       
    }
    */
    
    private ST_ManagementDashboard__c setFC(String Name , String ReportType ,String ReportType2 ,ST_Opportunity_Snapshot__c obj ,String Title2 ,String Title3 ,integer orderBy){
        ST_ManagementDashboard__c rec = new ST_ManagementDashboard__c();
        rec.Name = Name;
        rec.X1__c  = obj.AccountName__c;
        rec.X2__c  = Title2;
        rec.PhaseST__c  = Title2;
        if (ReportType2 == '全体') {
            rec.Department__c = ReportType2;
        } else {
            rec.Department__c = obj.Department__c;
        }
        
        rec.ReportType__c = ReportType;
        rec.ReportType2__c = ReportType2;
        rec.Date__c = Date.valueOf(obj.CreatedDate) ;
        rec.OrderBy__c = orderBy;
        rec.Num__c = 1;
        rec.Current1_Orig__c = 0;
        rec.Current2_Orig__c = 0;
        rec.Current3_Orig__c = 0;
        rec.Current4_Orig__c = 0;
        rec.Current5_Orig__c = 0;
        rec.Current6_Orig__c = 0;
        rec.Current7_Orig__c = 0;
        rec.Current8_Orig__c = 0;
        rec.Current9_Orig__c = 0;
        rec.Current10_Orig__c = 0;
        rec.Current11_Orig__c = 0;
        rec.Current12_Orig__c = 0;
        return rec;
    }
    
    /*
    * メール送信
    */
    private void mailSend(){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(new List<String>{UserInfo.getUserEmail()}); // 送信先(String[])
        
        mail.setSubject('【ST】スチール経営ダッシュボード゙作成処理完了のお知らせ'); // 件名(String)
        mail.setPlainTextBody('【ST】スチール経営ダッシュボード゙作成処理完了いたしました。'); // 本文(String)
        
        mail.setReplyTo(UserInfo.getUserEmail()); // 返信先メールアドレス(String)
        
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }

}