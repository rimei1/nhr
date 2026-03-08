/*
 * 【ST】スチール経営ダッシュボード
 * ■追及物件「件数」と「確度」月別推移
 */
global without sharing class NHR_ST_OppSnapshotDashboardBatch3 implements Database.Batchable<sObject>, Database.Stateful{
   
    global NHR_ST_OppSnapshotDashboardBatch3(){}
    global Set<String> reportSet1 {get;set;}
    global List<Account> accList{get;set;}
    global Set<String> accIdSet{get;set;}
    global Map<String, Account> accIdMap{get;set;}
    global List<String> type1List{get;set;}
    global List<String> type2List{get;set;}


    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_ST_OppSnapshotDashboardBatch3');

        String ST_yosankumikomi = '';
        Date theToday = Date.Today();
        if (theToday.month() >= 7) {
            ST_yosankumikomi = String.valueOf(theToday.year() + 1) + '年6月期';
        } else {
            ST_yosankumikomi = String.valueOf(theToday.year() ) + '年6月期';
        }
        reportSet1 = new Set<String>();
        accIdSet = new Set<String>();

        //type1List = new List<String>{'1_全体' ,'2_事業一部' ,'3_事業二部'};
        type1List = new List<String>{
             '01_全体_前期' ,'02_全体_当期' 
            ,'03_全体_積極・維持_前期','04_全体_積極・維持_当期'
            ,'05_全体_その他_前期','06_全体_その他_当期'
            ,'07_事業一部_前期' ,'08_事業一部_当期' 
            ,'09_事業一部_積極・維持_前期','10_事業一部_積極・維持_当期'
            ,'11_事業一部_その他_前期','12_事業一部_その他_当期'
            ,'13_事業二部_前期' ,'14_事業二部_当期' 
            ,'15_事業二部_積極・維持_前期','16_事業二部_積極・維持_当期'
            ,'17_事業二部_その他_前期','18_事業二部_その他_当期'
            };
        type2List = new List<String>{'AB' ,'CD' ,'EF','GH' ,'失注' ,'受注'};

        //setInit();
        String query = NHR_Dao.get_NHR_ST_OppSnapshotDashboardBatch3();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<ST_Opportunity_Snapshot__c> scopes){

        List<ST_ManagementDashboard__c> tempInfoList = new List<ST_ManagementDashboard__c>();
        for(ST_Opportunity_Snapshot__c obj : scopes) {
            ST_ManagementDashboard__c tempInfo = new ST_ManagementDashboard__c();
            Boolean chkThisYear = thisYearChk(obj.OppCreatedDate__c);
            if(!accIdSet.contains(obj.AccountId__c)) {
                accIdSet.add(obj.AccountId__c);
            }
            
            String keyStr = obj.StageName__c;
            if (keyStr == 'A' || keyStr == 'B') {
                keyStr = 'AB';
            } else if (keyStr == 'C' || keyStr == 'D') {
                keyStr = 'CD';
            } else if (keyStr == 'E' || keyStr == 'F') {
                keyStr = 'EF';
            } else if (keyStr == 'G' || keyStr == 'H') {
                keyStr = 'GH';
            } else if (keyStr == '受注ST' || keyStr == '仕掛' || keyStr == '完成') {
                keyStr = '受注';
            } else if (keyStr == '辞退' || keyStr == '失注' ) {
                keyStr = '失注';
            } 
            
            for (String str0 : type1List) { 
                ST_ManagementDashboard__c tempInfo0 = new ST_ManagementDashboard__c();

                if ( (str0 == type1List[0] && !chkThisYear)     //01_全体_前期
                   || (str0 == type1List[1] && chkThisYear)    //02_全体_当期
                   || (str0 == type1List[2] && !chkThisYear && obj.ST_focustype_kouji_im__c)     //03_全体_積極・維持_前期
                   || (str0 == type1List[3] && chkThisYear && obj.ST_focustype_kouji_im__c)    //04_全体_積極・維持_当期
                   || (str0 == type1List[4] && !chkThisYear && !obj.ST_focustype_kouji_im__c)    //05_全体_その他_前期
                   || (str0 == type1List[5] && chkThisYear && !obj.ST_focustype_kouji_im__c)   //06_全体_その他_当期
                   || (str0 == type1List[6] && !chkThisYear && obj.Department__c == '事業一部')   //07_事業一部_前期
                   || (str0 == type1List[7] && chkThisYear && obj.Department__c == '事業一部')    //08_事業一部_当期
                   || (str0 == type1List[8] && !chkThisYear && obj.Department__c == '事業一部' && obj.ST_focustype_kouji_im__c)    //09_事業一部_積極・維持_前期
                   || (str0 == type1List[9] && chkThisYear && obj.Department__c == '事業一部' && obj.ST_focustype_kouji_im__c)    //10_事業一部_積極・維持_当期
                   || (str0 == type1List[10] && !chkThisYear && obj.Department__c == '事業一部' && !obj.ST_focustype_kouji_im__c)    //11_事業一部_その他_前期
                   || (str0 == type1List[11] && chkThisYear && obj.Department__c == '事業一部' && !obj.ST_focustype_kouji_im__c)    //12_事業一部_その他_当期
                   || (str0 == type1List[12] && !chkThisYear && obj.Department__c == '事業二部')    //13_事業二部_前期
                   || (str0 == type1List[13] && chkThisYear && obj.Department__c == '事業二部')    //14_事業二部_当期
                   || (str0 == type1List[14] && !chkThisYear && obj.Department__c == '事業二部' && obj.ST_focustype_kouji_im__c)    //15_事業二部_積極・維持_前期
                   || (str0 == type1List[15] && chkThisYear && obj.Department__c == '事業二部' && obj.ST_focustype_kouji_im__c)    //16_事業二部_積極・維持_当期
                   || (str0 == type1List[16] && !chkThisYear && obj.Department__c == '事業二部' && !obj.ST_focustype_kouji_im__c)    //17_事業二部_その他_前期
                   || (str0 == type1List[17] && chkThisYear && obj.Department__c == '事業二部' && !obj.ST_focustype_kouji_im__c)    //18_事業二部_その他_当期
                   ){
                       tempInfo0 = setFC(NHR_Constant.BATCHNAME_ST_OSD3 + str0 + keyStr, '追及物件「件数」と「確度」月別推移' 
                                         , str0 , obj.AccountName__c ,keyStr 
                                         , obj.Department__c ,'全体' ,Date.valueOf(obj.CreatedDate.addDays(1)) ,1 ,obj.Id);
                       tempInfoList.add(tempInfo0);
                       if(reportSet1.contains(NHR_Constant.BATCHNAME_ST_OSD3 + str0 + keyStr)) {
                           reportSet1.add(NHR_Constant.BATCHNAME_ST_OSD3 + str0 + keyStr);
                       }
                   }
            }

            String imTemp = 'その他';
            if (obj.ST_focustype_kouji_im__c) {imTemp = '積極';}
            if (!chkThisYear) {
                tempInfo = setFC(NHR_Constant.BATCHNAME_ST_OSD3 + keyStr + obj.AccountId__c + '_前期', '追及物件「件数」と「確度」月別推移' 
                                 , obj.AccountName__c + '_前期' ,'前期',keyStr 
                                 , obj.Department__c ,'取引先_' + imTemp ,Date.valueOf(obj.CreatedDate.addDays(1)) ,1 ,obj.Id);
                if(reportSet1.contains(NHR_Constant.BATCHNAME_ST_OSD3 + keyStr + obj.AccountId__c)) {
                    reportSet1.add(NHR_Constant.BATCHNAME_ST_OSD3 + keyStr + obj.AccountId__c + '_前期');
                }
            } else {
                tempInfo = setFC(NHR_Constant.BATCHNAME_ST_OSD3 + keyStr + obj.AccountId__c + '_当期', '追及物件「件数」と「確度」月別推移' 
                                 , obj.AccountName__c + '_当期' ,'当期',keyStr 
                                 , obj.Department__c ,'取引先_' + imTemp ,Date.valueOf(obj.CreatedDate.addDays(1)) ,1 ,obj.Id);
                if(reportSet1.contains(NHR_Constant.BATCHNAME_ST_OSD3 + keyStr + obj.AccountId__c + '_当期')) {
                    reportSet1.add(NHR_Constant.BATCHNAME_ST_OSD3 + keyStr + obj.AccountId__c);
                }
            }
            
            
            tempInfoList.add(tempInfo);
            
        }

        insert tempInfoList;
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        //system.debug('reportMap1.values();' + reportMap1.values());
        //insert reportMap1.values();
        setSum();
        mailSend();
        //NHR_ST_OppSnapshotDashboardBatch4 myBatchObject = new NHR_ST_OppSnapshotDashboardBatch4();
        //Database.executeBatch(myBatchObject,200);
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
                reportMap1.put(NHR_Constant.BATCHNAME_ST_OSD3 + str1 + str0 , setFC(NHR_Constant.BATCHNAME_ST_OSD3 + str1 + str0, '追及物件「件数」と「確度」月別推移' , '全体' , str0,str0, str1,'',orderNum0));
                orderNum0 += 1;
                s1 += 1;
            }
            orderNum0 = tempOrderNum0 +  1000;
        }
        
        //重要取引先リスト
        Integer tempOrderNum = 1000 ;
        Integer orderNum = 1000 ;
        for(Account obj : accList) {
            Integer s1 = 1;
            for (String str1 : type2List) {
                reportMap1.put(NHR_Constant.BATCHNAME_ST_OSD3 + str1 + obj.Id , setFC(NHR_Constant.BATCHNAME_ST_OSD3 + str1 + obj.Id, '追及物件「件数」と「確度」月別推移' , '重要取引先' ,obj.ST_Department__c ,obj.Name, str1,'',orderNum));
                orderNum += 1;
                s1 += 1;
            }
            
            orderNum = tempOrderNum +  1000;
        }

    }
    */
    
    /**
     * 集計
     */
    private void setSum(){
        Integer thisMonthNum = Date.Today().month();

        List<ST_ManagementDashboard__c> tempInfoList = new List<ST_ManagementDashboard__c>();
        accList = new List<Account>();
        accIdMap = new Map<String, Account>();
        accList = [Select Id ,Name ,ST_Department__c ,ST_focustype_kouji_im__c 
                   From Account 
                   Where Id in :accIdSet];
        if (accList != NULL && accList.size() > 0) {
            for (Account obj : accList) {
                accIdMap.put(obj.Id , obj);
            }
        }
        
        
        if ( accIdMap != NULL && accIdMap.size() > 0) {
            for (String str : accIdMap.keyset()) {
                Account obj = accIdMap.get(str);
                String imTemp = 'その他';
                if (obj.ST_focustype_kouji_im__c) {imTemp = '積極';}
                for (String str1 : type2List) {
                    ST_ManagementDashboard__c tempInfo1 = new ST_ManagementDashboard__c();
                    if(!reportSet1.contains(NHR_Constant.BATCHNAME_ST_OSD3 + str1 + str + '_前期')) {
                        tempInfo1 = setFC(NHR_Constant.BATCHNAME_ST_OSD3 + str1 + str + '_前期', '追及物件「件数」と「確度」月別推移' 
                                          , obj.Name + '_前期' ,'前期',str1 
                                          , obj.ST_Department__c ,'取引先_' + imTemp , Date.Today() ,0 ,'');
                        tempInfoList.add(tempInfo1);
                    } 
                    
                    ST_ManagementDashboard__c tempInfo2 = new ST_ManagementDashboard__c();
                    if(!reportSet1.contains(NHR_Constant.BATCHNAME_ST_OSD3 + str1 + str + '_当期')) {
                        tempInfo2 = setFC(NHR_Constant.BATCHNAME_ST_OSD3 + str1 + str + '_当期', '追及物件「件数」と「確度」月別推移' 
                                          , obj.Name + '_当期' ,'当期',str1 
                                          , obj.ST_Department__c ,'取引先_' + imTemp , Date.Today() ,0 ,'');
                        tempInfoList.add(tempInfo2);
                    }
                }
            }
        }

        for (String str0 : type1List) { 
            for (String str1 : type2List) { 
                ST_ManagementDashboard__c tempInfo0 = new ST_ManagementDashboard__c();
                if(!reportSet1.contains(NHR_Constant.BATCHNAME_ST_OSD3 + str0 + str1)) {
                    tempInfo0 = setFC(NHR_Constant.BATCHNAME_ST_OSD3 + str0 + str1, '追及物件「件数」と「確度」月別推移' 
                                      , str0 , '' ,str1 
                                      , '' ,'全体' , Date.Today() ,0 ,'');
                    tempInfoList.add(tempInfo0);
                }
            }
        }
        
        if (tempInfoList.size()  > 0) {
            insert tempInfoList;
        }
    }
    
    
    private Boolean thisYearChk(Date inDate){
        Boolean res = false;
        if (inDate != NULL) {
            if (Date.Today().month() >= 7) {
                if ( (inDate.month() >= 7 && inDate.Year() == Date.Today().Year()) 
                    || (inDate.month() < 7 && inDate.Year() == Date.Today().Year() + 1))
                {
                    res = true;
                }
            } else {
                if ( (inDate.month() >= 7 && inDate.Year() == Date.Today().Year() - 1) 
                    || (inDate.month() < 7 && inDate.Year() == Date.Today().Year()))
                {
                    res = true;
                }
            }
        }
        
        return res;
    }
    
    private ST_ManagementDashboard__c setFC(String Name , String ReportType 
                                            ,String X1 ,String X2 ,String X3 
                                            ,String Department ,String ReportType2 ,Date inDate, Integer num, String oppStId)
    {
        ST_ManagementDashboard__c rec = new ST_ManagementDashboard__c();
        rec.Name = Name;
        rec.X1__c  = X1;
        rec.X2__c  = X2;
        rec.X3__c  = X3;
        rec.PhaseST__c  = X3;
        if (ReportType2 == '全体') {
            rec.Department__c = ReportType2;
        } else {
            rec.Department__c = Department;
        }
        rec.ReportType__c = ReportType;
        rec.ReportType2__c = ReportType2;
        rec.Date__c = Date.valueOf(inDate) ;
        rec.Num__c = num;
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
        if (oppStId != '') {
            rec.ST_Opp_Snapshot__c = oppStId;
        }
        
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