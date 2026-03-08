/*
 * 【ST】スチール経営ダッシュボード
 * ■組合せモデル別物件一覧
 */
global without sharing class NHR_ST_OppSnapshotDashboardBatch2 implements Database.Batchable<sObject>, Database.Stateful{
   
    global NHR_ST_OppSnapshotDashboardBatch2(){}
    global Map<String ,ST_ManagementDashboard__c> reportMap1 {get;set;}
    global List<String> type1List{get;set;}
    global List<String> type2List{get;set;}


    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_ST_OppSnapshotDashboardBatch2');

        //type1List = new List<String>{'1_全体' ,'2_事業一部' ,'3_事業二部'};
        type1List = new List<String>{'01_全体' ,'02_全体_積極・維持' ,'03_全体_その他'
            ,'04_事業一部_全体' ,'05_事業一部_積極維持' ,'06_事業一部_その他'
            ,'07_事業二部_全体' ,'08_事業二部_積極維持' ,'09_事業二部_その他'
            //,'10_事業二部_全体' ,'11_事業二部_積極維持' 
            };
        type2List = new List<String>{'1' ,'2' ,'3','4' ,'5' ,'6','7' ,'8' ,'9','10' ,'11' ,'12','13' ,'14' ,'15','16' ,'17' ,'18','未定'};

        setInit();
        String query = NHR_Dao.get_NHR_ST_OppSnapshotDashboardBatch2();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<ST_Opportunity_Snapshot__c> scopes){

        for(ST_Opportunity_Snapshot__c obj : scopes) {
            ST_ManagementDashboard__c tempInfo1_1 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo1_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo1_3 = new ST_ManagementDashboard__c();
            
            ST_ManagementDashboard__c tempInfo2_1 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo2_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo2_3 = new ST_ManagementDashboard__c();
            
            ST_ManagementDashboard__c tempInfo3_1 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo3_2 = new ST_ManagementDashboard__c();
            ST_ManagementDashboard__c tempInfo3_3 = new ST_ManagementDashboard__c();
            
            //ST_ManagementDashboard__c tempInfo4_1 = new ST_ManagementDashboard__c();
            //ST_ManagementDashboard__c tempInfo4_2 = new ST_ManagementDashboard__c();
            
            String keyStr = obj.modelpattern__c;
            if (String.isBlank(keyStr) ) {
                keyStr = '未定';
            } 
            tempInfo1_1 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD2 + keyStr + type1List[0]);
            tempInfo1_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD2 + keyStr + type1List[1]);
            tempInfo1_3 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD2 + keyStr + type1List[2]);
            
            tempInfo2_1 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD2 + keyStr + type1List[3]);
            tempInfo2_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD2 + keyStr + type1List[4]);
            tempInfo2_3 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD2 + keyStr + type1List[5]);
            
            tempInfo3_1 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD2 + keyStr + type1List[6]);
            tempInfo3_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD2 + keyStr + type1List[7]);
            tempInfo3_3 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD2 + keyStr + type1List[8]);
            
            //tempInfo4_1 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD2 + keyStr + type1List[9]);
            //tempInfo4_2 = reportMap1.get(NHR_Constant.BATCHNAME_ST_OSD2 + keyStr + type1List[10]);

            integer monthnum = obj.CreatedDate.month();
            String APIName = 'Current' +String.valueOf(monthnum) + '_Orig__c' ;
            
            
            if (obj.Department__c == '事業一部') {
                tempInfo2_1.put (APIName , Decimal.valueOf(String.valueOf(tempInfo2_1.get(APIName))) + 1) ;
                if (obj.ST_focustype_kouji_im__c ) {
                    tempInfo2_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo2_2.get(APIName))) + 1) ;
                } else {
                    tempInfo2_3.put (APIName , Decimal.valueOf(String.valueOf(tempInfo2_3.get(APIName))) + 1) ;
                }
            } else if (obj.Department__c == '事業二部') {
                tempInfo3_1.put (APIName , Decimal.valueOf(String.valueOf(tempInfo3_1.get(APIName))) + 1) ;
                if (obj.ST_focustype_kouji_im__c ) {
                    tempInfo3_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo3_2.get(APIName))) + 1) ;
                } else {
                    tempInfo3_3.put (APIName , Decimal.valueOf(String.valueOf(tempInfo3_3.get(APIName))) + 1) ;
                }
            }
            tempInfo1_1.put (APIName , Decimal.valueOf(String.valueOf(tempInfo1_1.get(APIName))) + 1) ;
            if (obj.ST_focustype_kouji_im__c ) {
                tempInfo1_2.put (APIName , Decimal.valueOf(String.valueOf(tempInfo1_2.get(APIName))) + 1) ;
            } else {
                tempInfo1_3.put (APIName , Decimal.valueOf(String.valueOf(tempInfo1_3.get(APIName))) + 1) ;
            }
        }

    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        system.debug('reportMap1.values();' + reportMap1.values());
        insert reportMap1.values();
        
        NHR_ST_OppSnapshotDashboardBatch3 myBatchObject = new NHR_ST_OppSnapshotDashboardBatch3();
        Database.executeBatch(myBatchObject,200);
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
                reportMap1.put(NHR_Constant.BATCHNAME_ST_OSD2 + str1 + str0 , setFC(NHR_Constant.BATCHNAME_ST_OSD2 + str1 + str0, '組合せモデル別物件一覧' , '全体' , str0,str0, str1,'',orderNum0));
                orderNum0 += 1;
                s1 += 1;
            }
            orderNum0 = tempOrderNum0 +  1000;
        }

    }
    
    private ST_ManagementDashboard__c setFC(String Name , String ReportType ,String ReportType2 ,String Department ,String Title1 ,String Title2 ,String Title3 ,integer orderBy){
        ST_ManagementDashboard__c rec = new ST_ManagementDashboard__c();
        rec.Name = Name;
        rec.X1__c  = Title1;
        rec.X2__c  = Title2;
        rec.modelpattern__c  = Title2;
        rec.Department__c = Department;
        rec.ReportType__c = ReportType;
        rec.ReportType2__c = ReportType2;
        rec.OrderBy__c = orderBy;
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

}