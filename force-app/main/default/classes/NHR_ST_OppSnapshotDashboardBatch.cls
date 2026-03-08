/*
 * 【ST】スチール経営ダッシュボード
 * ■受注実績（数量・金額・件数）推移
 */
global without sharing class NHR_ST_OppSnapshotDashboardBatch implements Database.Batchable<sObject>, Database.Stateful{
   
    global NHR_ST_OppSnapshotDashboardBatch(){}
    global Map<String ,ST_ManagementDashboard__c> reportMap1 {get;set;}
    global List<Account> accList{get;set;}
    global Map<String ,ST_ManagementDashboard__c> goalMap{get;set;}
    global List<String> accIdList{get;set;}
    global List<String> type1List{get;set;}
    global List<String> type2List{get;set;}
    global List<String> type3List{get;set;}
    
    global List<String> typeB_1List{get;set;}

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_ST_OppSnapshotDashboardBatch');
        accList = new List<Account>();
        accIdList = new List<String>();
        goalMap = new Map<String ,ST_ManagementDashboard__c>();
        //type1List = new List<String>{'1_全体' ,'2_事業一部' ,'3_事業二部','4_積極拡大・重要維持顧客12社' ,'5_その他顧客'};
        type1List = new List<String>{'1_全体' ,'2_全体_積極・維持' ,'3_全体_その他'
            ,'4_事業一部_全体' ,'5_事業一部_積極維持' ,'6_事業一部_その他'
            ,'7_事業二部_全体' ,'8_事業二部_積極維持' ,'9_事業二部_その他'};
        type2List = new List<String>{'1_数量' ,'2_金額' ,'3_件数'};
        type3List = new List<String>{'1_目標' ,'2_実績' ,'3_達成率'};
            
        typeB_1List = new List<String>{'1_全体' ,'2_事業1部' ,'3_事業2部'};
            
        //重要取引先取得
        accList = [Select Id ,Name ,ST_Department__c ,Account_ID_18__c From Account 
                   Where ST_focustype_kouji_im__c = true];
        if (accList != NULL && accList.size() > 0) {
            for (Account obj : accList) {
                accIdList.add(obj.Id);
            }
        }
        
        //目標値取得
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [select id,ST_Orderquantitytarget__c,ST_Orderamounttarget__c,ST_Targetnumberoforders__c
                   , Account.Account_ID_18__c , CloseDate ,Account.ST_Department__c ,Account.ST_focustype_kouji_im__c
                   from Opportunity
                   where RecordType.DeveloperName = 'RecordType_Steelzairyou_goal' 
                   and CloseDate = THIS_FISCAL_YEAR];
        if (oppList != NULL && oppList.size() > 0) {
            goalMap.put(type1List[0],setNewFC(''));
            goalMap.put(type1List[1],setNewFC(''));
            goalMap.put(type1List[2],setNewFC(''));
            goalMap.put(type1List[3],setNewFC(''));
            goalMap.put(type1List[4],setNewFC(''));
            goalMap.put(type1List[5],setNewFC(''));
            goalMap.put(type1List[6],setNewFC(''));
            goalMap.put(type1List[7],setNewFC(''));
            goalMap.put(type1List[8],setNewFC(''));

            for (Opportunity obj : oppList) {
                for (String str : type2List) {
                    //取引先
                    String keyStr = obj.Account.Account_ID_18__c + str;
                    Integer monthnum = obj.CloseDate.month();
                    ST_ManagementDashboard__c tempObj = new ST_ManagementDashboard__c();
                    if (goalMap.containsKey(keyStr)) {
                        tempObj = goalMap.get(keyStr);
                    } else {
                        tempObj = setNewFC(obj.Account.ST_Department__c);
                    }
                    
                    String APIName = 'Current' +String.valueOf(monthnum) + '_Orig__c' ;
                    if (str == type2List[0]) {
                        tempObj.put(APIName , obj.ST_Orderquantitytarget__c == null ? 0 : obj.ST_Orderquantitytarget__c);
                    } else if (str == type2List[1]) {
                        tempObj.put(APIName , obj.ST_Orderamounttarget__c == null ? 0 : obj.ST_Orderamounttarget__c);
                    } else if (str == type2List[2]) {
                        tempObj.put(APIName , obj.ST_Targetnumberoforders__c == null ? 0 : obj.ST_Targetnumberoforders__c);
                    }
                    
                    goalMap.put(keyStr,tempObj);
                    
                    //全体
                    for (String str0 : type1List) { 
                        if (str0 == type1List[0]
                            || (str0 == type1List[1] && obj.Account.ST_focustype_kouji_im__c)
                            || (str0 == type1List[2] && !obj.Account.ST_focustype_kouji_im__c)
                            || (str0 == type1List[3] && obj.Account.ST_Department__c == '事業一部')
                            || (str0 == type1List[4] && obj.Account.ST_Department__c == '事業一部' && obj.Account.ST_focustype_kouji_im__c)
                            || (str0 == type1List[5] && obj.Account.ST_Department__c == '事業一部' && !obj.Account.ST_focustype_kouji_im__c)
                            || (str0 == type1List[6] && obj.Account.ST_Department__c == '事業二部')
                            || (str0 == type1List[7] && obj.Account.ST_Department__c == '事業二部' && obj.Account.ST_focustype_kouji_im__c)
                            || (str0 == type1List[8] && obj.Account.ST_Department__c == '事業二部' && !obj.Account.ST_focustype_kouji_im__c)) {
                                String keyStr0 = str0 + str;
                                ST_ManagementDashboard__c tempObj0 = new ST_ManagementDashboard__c();
                                if (goalMap.containsKey(keyStr0)) {
                                    tempObj0 = goalMap.get(keyStr0);
                                } else {
                                    tempObj0 = setNewFC(obj.Account.ST_Department__c);
                                }
                                
                                if (str == type2List[0]) {
                                    tempObj0.put(APIName , obj.ST_Orderquantitytarget__c == null ? Decimal.valueOf(String.valueOf(tempObj0.get(APIName))) : Decimal.valueOf(String.valueOf(tempObj0.get(APIName))) + obj.ST_Orderquantitytarget__c);
                                } else if (str == type2List[1]) {
                                    tempObj0.put(APIName , obj.ST_Orderamounttarget__c == null ? Decimal.valueOf(String.valueOf(tempObj0.get(APIName))) : Decimal.valueOf(String.valueOf(tempObj0.get(APIName))) + obj.ST_Orderamounttarget__c);
                                } else if (str == type2List[2]) {
                                    tempObj0.put(APIName , obj.ST_Targetnumberoforders__c == null ? Decimal.valueOf(String.valueOf(tempObj0.get(APIName))) : Decimal.valueOf(String.valueOf(tempObj0.get(APIName))) + obj.ST_Targetnumberoforders__c);
                                }
                                goalMap.put(keyStr0,tempObj0);
                        }
                        
                    }
                }                
            }
        }
        

        setInit();
        String query = NHR_Dao.get_NHR_ST_OppSnapshotDashboardBatch();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){

        for(Opportunity obj : scopes) {

            ST_ManagementDashboard__c tempInfo1_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo2_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo3_2 = new ST_ManagementDashboard__c();
            
            //全体
            ST_ManagementDashboard__c tempInfo_sum1_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_sum2_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_sum3_2 = new ST_ManagementDashboard__c();
            
            ST_ManagementDashboard__c tempInfo_sum_sub1_1_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_sum_sub1_2_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_sum_sub1_3_2 = new ST_ManagementDashboard__c();
            
            ST_ManagementDashboard__c tempInfo_sum_sub2_1_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_sum_sub2_2_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_sum_sub2_3_2 = new ST_ManagementDashboard__c();
            tempInfo_sum1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '12' + type1List[0]);
            tempInfo_sum2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '22' + type1List[0]);
            tempInfo_sum3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '32' + type1List[0]);
            
            tempInfo_sum_sub1_1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '12' + type1List[1]);
            tempInfo_sum_sub1_2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '22' + type1List[1]);
            tempInfo_sum_sub1_3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '32' + type1List[1]);
            
            tempInfo_sum_sub2_1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '12' + type1List[2]);
            tempInfo_sum_sub2_2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '22' + type1List[2]);
            tempInfo_sum_sub2_3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '32' + type1List[2]);

            //事業一部
            ST_ManagementDashboard__c tempInfo_d1_1_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_d1_2_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_d1_3_2 = new ST_ManagementDashboard__c();
            
            ST_ManagementDashboard__c tempInfo_d1_sub1_1_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_d1_sub1_2_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_d1_sub1_3_2 = new ST_ManagementDashboard__c();
            
            ST_ManagementDashboard__c tempInfo_d1_sub2_1_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_d1_sub2_2_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_d1_sub2_3_2 = new ST_ManagementDashboard__c();
            
            tempInfo_d1_1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '12' + type1List[3]);
            tempInfo_d1_2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '22' + type1List[3]);
            tempInfo_d1_3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '32' + type1List[3]);
            
            tempInfo_d1_sub1_1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '12' + type1List[4]);
            tempInfo_d1_sub1_2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '22' + type1List[4]);
            tempInfo_d1_sub1_3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '32' + type1List[4]);
            
            tempInfo_d1_sub2_1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '12' + type1List[5]);
            tempInfo_d1_sub2_2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '22' + type1List[5]);
            tempInfo_d1_sub2_3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '32' + type1List[5]);
            
            //事業二部
            ST_ManagementDashboard__c tempInfo_d2_1_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_d2_2_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_d2_3_2 = new ST_ManagementDashboard__c();
            
            ST_ManagementDashboard__c tempInfo_d2_sub1_1_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_d2_sub1_2_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_d2_sub1_3_2 = new ST_ManagementDashboard__c();
            
            ST_ManagementDashboard__c tempInfo_d2_sub2_1_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_d2_sub2_2_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo_d2_sub2_3_2 = new ST_ManagementDashboard__c();
            
            tempInfo_d2_1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '12' + type1List[6]);
            tempInfo_d2_2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '22' + type1List[6]);
            tempInfo_d2_3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '32' + type1List[6]);
            
            tempInfo_d2_sub1_1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '12' + type1List[7]);
            tempInfo_d2_sub1_2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '22' + type1List[7]);
            tempInfo_d2_sub1_3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '32' + type1List[7]);
            
            tempInfo_d2_sub2_1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '12' + type1List[8]);
            tempInfo_d2_sub2_2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '22' + type1List[8]);
            tempInfo_d2_sub2_3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '32' + type1List[8]);
            
            tempInfo1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '12' + obj.AccountId);
            tempInfo2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '22' + obj.AccountId);
            tempInfo3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '32' + obj.AccountId);
            
            integer monthnum = obj.transtionDateToPhaseJuchuST__c.month();
            String APIName = 'Current' +String.valueOf(monthnum) + '_Orig__c' ;
            
            if (obj.Department__c == '事業一部') {
                tempInfo_d1_1_2.put (APIName , obj.ST_suryou__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_d1_1_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_d1_1_2.get(APIName))) + obj.ST_suryou__c) ;
                //tempInfo_d1_2_2.put (APIName , obj.ST_initialContractAmount__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_d1_2_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_d1_2_2.get(APIName))) + obj.ST_initialContractAmount__c) ;
                tempInfo_d1_3_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo_d1_3_2.get(APIName))) + 1) ;
                if (obj.Account.ST_focustype_kouji_im__c) {
                    tempInfo_d1_sub1_1_2.put (APIName , obj.ST_suryou__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_d1_sub1_1_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_d1_sub1_1_2.get(APIName))) + obj.ST_suryou__c) ;
                    //tempInfo_d1_sub1_2_2.put (APIName , obj.ST_initialContractAmount__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_d1_sub1_2_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_d1_sub1_2_2.get(APIName))) + obj.ST_initialContractAmount__c) ;
                    tempInfo_d1_sub1_3_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo_d1_sub1_3_2.get(APIName))) + 1) ;
                } else {
                    tempInfo_d1_sub2_1_2.put (APIName , obj.ST_suryou__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_d1_sub2_1_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_d1_sub2_1_2.get(APIName))) + obj.ST_suryou__c) ;
                    //tempInfo_d1_sub2_2_2.put (APIName , obj.ST_initialContractAmount__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_d1_sub2_2_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_d1_sub2_2_2.get(APIName))) + obj.ST_initialContractAmount__c) ;
                    tempInfo_d1_sub2_3_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo_d1_sub2_3_2.get(APIName))) + 1) ;
                }
            } else if (obj.Department__c == '事業二部') {
                tempInfo_d2_1_2.put (APIName , obj.ST_suryou__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_d2_1_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_d2_1_2.get(APIName))) + obj.ST_suryou__c) ;
                //tempInfo_d2_2_2.put (APIName , obj.ST_initialContractAmount__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_d2_2_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_d2_2_2.get(APIName))) + obj.ST_initialContractAmount__c) ;
                tempInfo_d2_3_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo_d2_3_2.get(APIName))) + 1) ;
                if (obj.Account.ST_focustype_kouji_im__c) {
                    tempInfo_d2_sub1_1_2.put (APIName , obj.ST_suryou__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_d2_sub1_1_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_d2_sub1_1_2.get(APIName))) + obj.ST_suryou__c) ;
                    //tempInfo_d2_sub1_2_2.put (APIName , obj.ST_initialContractAmount__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_d2_sub1_2_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_d2_sub1_2_2.get(APIName))) + obj.ST_initialContractAmount__c) ;
                    tempInfo_d2_sub1_3_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo_d2_sub1_3_2.get(APIName))) + 1) ;
                } else {
                    tempInfo_d2_sub2_1_2.put (APIName , obj.ST_suryou__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_d2_sub2_1_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_d2_sub2_1_2.get(APIName))) + obj.ST_suryou__c) ;
                    //tempInfo_d2_sub2_2_2.put (APIName , obj.ST_initialContractAmount__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_d2_sub2_2_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_d2_sub2_2_2.get(APIName))) + obj.ST_initialContractAmount__c) ;
                    tempInfo_d2_sub2_3_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo_d2_sub2_3_2.get(APIName))) + 1) ;
                }
            }
            
            tempInfo_sum1_2.put (APIName , obj.ST_suryou__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_sum1_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_sum1_2.get(APIName))) + obj.ST_suryou__c) ;
            //tempInfo_sum2_2.put (APIName , obj.ST_initialContractAmount__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_sum2_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_sum2_2.get(APIName))) + obj.ST_initialContractAmount__c) ;
            tempInfo_sum3_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo_sum3_2.get(APIName))) + 1) ;
            
            //重要取引先
            if (obj.Account.ST_focustype_kouji_im__c) {
                tempInfo1_2.put (APIName , obj.ST_suryou__c == null ?  Decimal.valueOf(String.valueOf(tempInfo1_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo1_2.get(APIName))) + obj.ST_suryou__c) ;
                //tempInfo2_2.put (APIName , obj.ST_initialContractAmount__c == null ?  Decimal.valueOf(String.valueOf(tempInfo2_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo2_2.get(APIName))) + obj.ST_initialContractAmount__c) ;
                tempInfo3_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo3_2.get(APIName))) + 1) ;
                
                tempInfo_sum_sub1_1_2.put (APIName , obj.ST_suryou__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_sum_sub1_1_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_sum_sub1_1_2.get(APIName))) + obj.ST_suryou__c) ;
                //tempInfo_sum_sub1_2_2.put (APIName , obj.ST_initialContractAmount__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_sum_sub1_2_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_sum_sub1_2_2.get(APIName))) + obj.ST_initialContractAmount__c) ;
                tempInfo_sum_sub1_3_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo_d1_3_2.get(APIName))) + 1) ;
            } else {
                tempInfo_sum_sub2_1_2.put (APIName , obj.ST_suryou__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_sum_sub2_1_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_sum_sub2_1_2.get(APIName))) + obj.ST_suryou__c) ;
                //tempInfo_sum_sub2_2_2.put (APIName , obj.ST_initialContractAmount__c == null ?  Decimal.valueOf(String.valueOf(tempInfo_sum_sub2_2_2.get(APIName))) : Decimal.valueOf(String.valueOf(tempInfo_sum_sub2_2_2.get(APIName))) + obj.ST_initialContractAmount__c) ;
                tempInfo_sum_sub2_3_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo_sum_sub2_3_2.get(APIName))) + 1) ;
            }            
        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        setSum();
        system.debug('reportMap1.values();' + reportMap1.values());
        insert reportMap1.values();
        
        NHR_ST_OppSnapshotDashboardBatch2 myBatchObject = new NHR_ST_OppSnapshotDashboardBatch2();
        Database.executeBatch(myBatchObject,200);
        
        //mailSend();
    }
    
    /**
     * 初期設定
     */
    private void setInit(){
        reportMap1 = new Map<String ,ST_ManagementDashboard__c>();
        
        //全体・事業
        Integer tempOrderNum0 = 100 ;
        Integer orderNum0 = 100 ;
        
        for(String str0 : type1List) {
            Integer s1 = 1;
            for (String str1 : type2List) {
                Integer s2 = 1;
                for (String str2 : type3List) {
                    if (str2 == type3List[0] && goalMap.containsKey(str0+str1)) {
                        reportMap1.put(NHR_Constant.BATCHNAME_ST_OSD1 + String.valueOf(s1) + String.valueOf(s2) + str0 , setFC(NHR_Constant.BATCHNAME_ST_OSD1 + String.valueOf(s1) + String.valueOf(s2)+ str0, '受注実績（数量・金額・件数）推移' , '全体' , str0,str0, str1,str2,orderNum0,goalMap.get(str0+str1)));
                    } else {
                        reportMap1.put(NHR_Constant.BATCHNAME_ST_OSD1 + String.valueOf(s1) + String.valueOf(s2) + str0 , setFC(NHR_Constant.BATCHNAME_ST_OSD1 + String.valueOf(s1) + String.valueOf(s2)+ str0, '受注実績（数量・金額・件数）推移' , '全体' , str0,str0, str1,str2,orderNum0,null));
                    }
                    s2 += 1;
                    orderNum0 += 1;
                }
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
                Integer s2 = 1;
                for (String str2 : type3List) {
                    if (str2 == type3List[0] && goalMap.containsKey(obj.Account_ID_18__c + str1)) {
                        reportMap1.put(NHR_Constant.BATCHNAME_ST_OSD1 + String.valueOf(s1) + String.valueOf(s2) + obj.Id , setFC(NHR_Constant.BATCHNAME_ST_OSD1 + obj.Id, '受注実績（数量・金額・件数）推移' , '重要取引先' ,obj.ST_Department__c ,obj.Name, str1,str2,orderNum,goalMap.get(obj.Account_ID_18__c + str1)));
                    } else {
                        reportMap1.put(NHR_Constant.BATCHNAME_ST_OSD1 + String.valueOf(s1) + String.valueOf(s2) + obj.Id , setFC(NHR_Constant.BATCHNAME_ST_OSD1 + obj.Id, '受注実績（数量・金額・件数）推移' , '重要取引先' ,obj.ST_Department__c ,obj.Name, str1,str2,orderNum,null));
                    }
                    s2 += 1;
                    orderNum += 1;
                }
                s1 += 1;
            }
            orderNum = tempOrderNum +  1000;
        }
        
    }
    
    private ST_ManagementDashboard__c setFC(String Name , String ReportType ,String ReportType2 
                                            ,String Department ,String Title1 ,String Title2 ,String Title3 ,integer orderBy
                                           ,ST_ManagementDashboard__c inMdObj)
    {
        ST_ManagementDashboard__c rec = new ST_ManagementDashboard__c();
        rec.Name = Name;
        rec.X1__c  = Title1;
        rec.X2__c  = Title2;
        rec.X3__c  = Title3;
        rec.Department__c = Department;
        rec.ReportType__c = ReportType;
        rec.ReportType2__c = ReportType2;
        rec.OrderBy__c = orderBy;
        if (inMdObj != NULL) {
            rec.Current1_Orig__c = inMdObj.Current1_Orig__c;
            rec.Current2_Orig__c = inMdObj.Current2_Orig__c;
            rec.Current3_Orig__c = inMdObj.Current3_Orig__c;
            rec.Current4_Orig__c = inMdObj.Current4_Orig__c;
            rec.Current5_Orig__c = inMdObj.Current5_Orig__c;
            rec.Current6_Orig__c = inMdObj.Current6_Orig__c;
            rec.Current7_Orig__c = inMdObj.Current7_Orig__c;
            rec.Current8_Orig__c = inMdObj.Current8_Orig__c;
            rec.Current9_Orig__c = inMdObj.Current9_Orig__c;
            rec.Current10_Orig__c = inMdObj.Current10_Orig__c;
            rec.Current11_Orig__c = inMdObj.Current11_Orig__c;
            rec.Current12_Orig__c = inMdObj.Current12_Orig__c;
        } else {
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
        }
        rec.TotalThisMonth_Orig__c = 0;
        rec.TotalThisYear_Orig__c = 0;
        return rec;
    }
    
    private ST_ManagementDashboard__c setNewFC(String Department)
    {
        ST_ManagementDashboard__c rec = new ST_ManagementDashboard__c();
        rec.Department__c = Department;
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
    
    /**
     * 集計
     */
    private void setSum(){
        Integer thisMonthNum = Date.Today().month();
        for(String str0 : type1List) {            
            ST_ManagementDashboard__c tempInfo1_1 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo2_1 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo3_1 = new ST_ManagementDashboard__c();
            
            ST_ManagementDashboard__c tempInfo1_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo2_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo3_2 = new ST_ManagementDashboard__c();
            
            ST_ManagementDashboard__c tempInfo1_3 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo2_3 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo3_3 = new ST_ManagementDashboard__c();
            
            tempInfo1_1 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '11' + str0);
            tempInfo2_1 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '21' + str0);
            tempInfo3_1 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '31' + str0);
            
            tempInfo1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '12' + str0);
            tempInfo2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '22' + str0);
            tempInfo3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '32' + str0);
            
            tempInfo1_3 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '13' + str0);
            tempInfo2_3 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '23' + str0);
            tempInfo3_3 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '33' + str0);
            
            for(Integer i = 1 ; i <= 12 ; i++) {
                String APIName = 'Current' +String.valueOf(i) + '_Orig__c' ;
                
                if (Decimal.valueOf(String.valueOf(tempInfo1_1.get(APIName))) > 0) {
                    tempInfo1_3.put(APIName , Decimal.valueOf(String.valueOf(tempInfo1_2.get(APIName))) / Decimal.valueOf(String.valueOf(tempInfo1_1.get(APIName))));
                }

                if (Decimal.valueOf(String.valueOf(tempInfo2_1.get(APIName))) > 0) {
                    tempInfo2_3.put(APIName , Decimal.valueOf(String.valueOf(tempInfo2_2.get(APIName))) / Decimal.valueOf(String.valueOf(tempInfo2_1.get(APIName))));
                }
                
                if (Decimal.valueOf(String.valueOf(tempInfo3_1.get(APIName))) > 0) {
                    tempInfo3_3.put(APIName , Decimal.valueOf(String.valueOf(tempInfo3_2.get(APIName))) / Decimal.valueOf(String.valueOf(tempInfo3_1.get(APIName))));
                }
                
                tempInfo1_1.put('TotalThisYear_Orig__c'  ,tempInfo1_1.TotalThisYear_Orig__c +Decimal.valueOf(String.valueOf(tempInfo1_1.get(APIName))));
                tempInfo1_2.put('TotalThisYear_Orig__c'  ,tempInfo1_2.TotalThisYear_Orig__c +Decimal.valueOf(String.valueOf(tempInfo1_2.get(APIName))));
                tempInfo2_1.put('TotalThisYear_Orig__c'  ,tempInfo2_1.TotalThisYear_Orig__c +Decimal.valueOf(String.valueOf(tempInfo2_1.get(APIName))));
                tempInfo2_2.put('TotalThisYear_Orig__c'  ,tempInfo2_2.TotalThisYear_Orig__c +Decimal.valueOf(String.valueOf(tempInfo2_2.get(APIName))));
                tempInfo3_1.put('TotalThisYear_Orig__c'  ,tempInfo3_1.TotalThisYear_Orig__c +Decimal.valueOf(String.valueOf(tempInfo3_1.get(APIName))));
                tempInfo3_2.put('TotalThisYear_Orig__c'  ,tempInfo3_2.TotalThisYear_Orig__c +Decimal.valueOf(String.valueOf(tempInfo3_2.get(APIName))));
                if (thisMonthNum > 6) {
                    if (thisMonthNum >= i && i >= 7) {
                        tempInfo1_1.put('TotalThisMonth_Orig__c'  ,tempInfo1_1.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo1_1.get(APIName))));
                        tempInfo1_2.put('TotalThisMonth_Orig__c'  ,tempInfo1_2.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo1_2.get(APIName))));
                        tempInfo2_1.put('TotalThisMonth_Orig__c'  ,tempInfo2_1.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo2_1.get(APIName))));
                        tempInfo2_2.put('TotalThisMonth_Orig__c'  ,tempInfo2_2.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo2_2.get(APIName))));
                        tempInfo3_1.put('TotalThisMonth_Orig__c'  ,tempInfo3_1.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo3_1.get(APIName))));
                        tempInfo3_2.put('TotalThisMonth_Orig__c'  ,tempInfo3_2.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo3_2.get(APIName))));
                    }
                } else {
                    if (i >= 7 || thisMonthNum >= i) {
                        tempInfo1_1.put('TotalThisMonth_Orig__c'  ,tempInfo1_1.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo1_1.get(APIName))));
                        tempInfo1_2.put('TotalThisMonth_Orig__c'  ,tempInfo1_2.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo1_2.get(APIName))));
                        tempInfo2_1.put('TotalThisMonth_Orig__c'  ,tempInfo2_1.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo2_1.get(APIName))));
                        tempInfo2_2.put('TotalThisMonth_Orig__c'  ,tempInfo2_2.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo2_2.get(APIName))));
                        tempInfo3_1.put('TotalThisMonth_Orig__c'  ,tempInfo3_1.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo3_1.get(APIName))));
                        tempInfo3_2.put('TotalThisMonth_Orig__c'  ,tempInfo3_2.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo3_2.get(APIName))));
                    }
                }
            }
            
            if (tempInfo1_1.TotalThisMonth_Orig__c > 0) {
                tempInfo1_3.TotalThisMonth_Orig__c = tempInfo1_2.TotalThisMonth_Orig__c / tempInfo1_1.TotalThisMonth_Orig__c;
            }
            
            if (tempInfo2_1.TotalThisMonth_Orig__c > 0) {
                tempInfo2_3.TotalThisMonth_Orig__c = tempInfo2_2.TotalThisMonth_Orig__c / tempInfo2_1.TotalThisMonth_Orig__c;
            }
            
            if (tempInfo3_1.TotalThisMonth_Orig__c > 0) {
                tempInfo3_3.TotalThisMonth_Orig__c = tempInfo3_2.TotalThisMonth_Orig__c / tempInfo3_1.TotalThisMonth_Orig__c;
            }
            
            if (tempInfo1_1.TotalThisYear_Orig__c > 0) {
                tempInfo1_3.TotalThisYear_Orig__c = tempInfo1_2.TotalThisYear_Orig__c / tempInfo1_1.TotalThisYear_Orig__c;
            }
            
            if (tempInfo2_1.TotalThisYear_Orig__c > 0) {
                tempInfo2_3.TotalThisYear_Orig__c = tempInfo2_2.TotalThisYear_Orig__c / tempInfo2_1.TotalThisYear_Orig__c;
            }
            
            if (tempInfo3_1.TotalThisYear_Orig__c > 0) {
                tempInfo3_3.TotalThisYear_Orig__c = tempInfo3_2.TotalThisYear_Orig__c / tempInfo3_1.TotalThisYear_Orig__c;
            }
            
        }
        
        if (accList != NULL && accList.size() > 0) {
            for(Account acc : accList) {
                ST_ManagementDashboard__c tempInfo1_1 = new ST_ManagementDashboard__c();
                ST_ManagementDashboard__c tempInfo2_1 = new ST_ManagementDashboard__c();
                ST_ManagementDashboard__c tempInfo3_1 = new ST_ManagementDashboard__c();
                
                ST_ManagementDashboard__c tempInfo1_2 = new ST_ManagementDashboard__c();
                ST_ManagementDashboard__c tempInfo2_2 = new ST_ManagementDashboard__c();
                ST_ManagementDashboard__c tempInfo3_2 = new ST_ManagementDashboard__c();
                
                ST_ManagementDashboard__c tempInfo1_3 = new ST_ManagementDashboard__c();
                ST_ManagementDashboard__c tempInfo2_3 = new ST_ManagementDashboard__c();
                ST_ManagementDashboard__c tempInfo3_3 = new ST_ManagementDashboard__c();
                
                tempInfo1_1 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '11' + acc.Id);
                tempInfo2_1 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '21' + acc.Id);
                tempInfo3_1 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '31' + acc.Id);
                
                tempInfo1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '12' + acc.Id);
                tempInfo2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '22' + acc.Id);
                tempInfo3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '32' + acc.Id);
                
                tempInfo1_3 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '13' + acc.Id);
                tempInfo2_3 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '23' + acc.Id);
                tempInfo3_3 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD1 + '33' + acc.Id);
                
                for(Integer i = 1 ; i <= 12 ; i++) {
                    String APIName = 'Current' +String.valueOf(i) + '_Orig__c' ;
                    if (Decimal.valueOf(String.valueOf(tempInfo1_1.get(APIName))) > 0) {
                        tempInfo1_3.put(APIName , Decimal.valueOf(String.valueOf(tempInfo1_2.get(APIName))) / Decimal.valueOf(String.valueOf(tempInfo1_1.get(APIName))));
                    }
                    
                    if (Decimal.valueOf(String.valueOf(tempInfo2_1.get(APIName))) > 0) {
                        tempInfo2_3.put(APIName , Decimal.valueOf(String.valueOf(tempInfo2_2.get(APIName))) / Decimal.valueOf(String.valueOf(tempInfo2_1.get(APIName))));
                    }
                    
                    if (Decimal.valueOf(String.valueOf(tempInfo3_1.get(APIName))) > 0) {
                        tempInfo3_3.put(APIName , Decimal.valueOf(String.valueOf(tempInfo3_2.get(APIName))) / Decimal.valueOf(String.valueOf(tempInfo3_1.get(APIName))));
                    }
                    tempInfo1_1.put('TotalThisYear_Orig__c'  ,tempInfo1_1.TotalThisYear_Orig__c +Decimal.valueOf(String.valueOf(tempInfo1_1.get(APIName))));
                    tempInfo1_2.put('TotalThisYear_Orig__c'  ,tempInfo1_2.TotalThisYear_Orig__c +Decimal.valueOf(String.valueOf(tempInfo1_2.get(APIName))));
                    tempInfo2_1.put('TotalThisYear_Orig__c'  ,tempInfo2_1.TotalThisYear_Orig__c +Decimal.valueOf(String.valueOf(tempInfo2_1.get(APIName))));
                    tempInfo2_2.put('TotalThisYear_Orig__c'  ,tempInfo2_2.TotalThisYear_Orig__c +Decimal.valueOf(String.valueOf(tempInfo2_2.get(APIName))));
                    tempInfo3_1.put('TotalThisYear_Orig__c'  ,tempInfo3_1.TotalThisYear_Orig__c +Decimal.valueOf(String.valueOf(tempInfo3_1.get(APIName))));
                    tempInfo3_2.put('TotalThisYear_Orig__c'  ,tempInfo3_2.TotalThisYear_Orig__c +Decimal.valueOf(String.valueOf(tempInfo3_2.get(APIName))));
                    if (thisMonthNum > 6) {
                        if (thisMonthNum >= i && i >= 7) {
                            tempInfo1_1.put('TotalThisMonth_Orig__c'  ,tempInfo1_1.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo1_1.get(APIName))));
                            tempInfo1_2.put('TotalThisMonth_Orig__c'  ,tempInfo1_2.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo1_2.get(APIName))));
                            tempInfo2_1.put('TotalThisMonth_Orig__c'  ,tempInfo2_1.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo2_1.get(APIName))));
                            tempInfo2_2.put('TotalThisMonth_Orig__c'  ,tempInfo2_2.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo2_2.get(APIName))));
                            tempInfo3_1.put('TotalThisMonth_Orig__c'  ,tempInfo3_1.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo3_1.get(APIName))));
                            tempInfo3_2.put('TotalThisMonth_Orig__c'  ,tempInfo3_2.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo3_2.get(APIName))));
                        }
                    } else {
                        if (i >= 7 || thisMonthNum >= i) {
                            tempInfo1_1.put('TotalThisMonth_Orig__c'  ,tempInfo1_1.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo1_1.get(APIName))));
                            tempInfo1_2.put('TotalThisMonth_Orig__c'  ,tempInfo1_2.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo1_2.get(APIName))));
                            tempInfo2_1.put('TotalThisMonth_Orig__c'  ,tempInfo2_1.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo2_1.get(APIName))));
                            tempInfo2_2.put('TotalThisMonth_Orig__c'  ,tempInfo2_2.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo2_2.get(APIName))));
                            tempInfo3_1.put('TotalThisMonth_Orig__c'  ,tempInfo3_1.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo3_1.get(APIName))));
                            tempInfo3_2.put('TotalThisMonth_Orig__c'  ,tempInfo3_2.TotalThisMonth_Orig__c  +Decimal.valueOf(String.valueOf(tempInfo3_2.get(APIName))));
                        }
                    }
                }
                
                if (tempInfo1_1.TotalThisMonth_Orig__c > 0) {
                    tempInfo1_3.TotalThisMonth_Orig__c = tempInfo1_2.TotalThisMonth_Orig__c / tempInfo1_1.TotalThisMonth_Orig__c;
                }
                
                if (tempInfo2_1.TotalThisMonth_Orig__c > 0) {
                    tempInfo2_3.TotalThisMonth_Orig__c = tempInfo2_2.TotalThisMonth_Orig__c / tempInfo2_1.TotalThisMonth_Orig__c;
                }
                
                if (tempInfo3_1.TotalThisMonth_Orig__c > 0) {
                    tempInfo3_3.TotalThisMonth_Orig__c = tempInfo3_2.TotalThisMonth_Orig__c / tempInfo3_1.TotalThisMonth_Orig__c;
                }
                
                if (tempInfo1_1.TotalThisYear_Orig__c > 0) {
                    tempInfo1_3.TotalThisYear_Orig__c = tempInfo1_2.TotalThisYear_Orig__c / tempInfo1_1.TotalThisYear_Orig__c;
                }
                
                if (tempInfo2_1.TotalThisYear_Orig__c > 0) {
                    tempInfo2_3.TotalThisYear_Orig__c = tempInfo2_2.TotalThisYear_Orig__c / tempInfo2_1.TotalThisYear_Orig__c;
                }
                
                if (tempInfo3_1.TotalThisYear_Orig__c > 0) {
                    tempInfo3_3.TotalThisYear_Orig__c = tempInfo3_2.TotalThisYear_Orig__c / tempInfo3_1.TotalThisYear_Orig__c;
                }
            }
        }
        
    }

}