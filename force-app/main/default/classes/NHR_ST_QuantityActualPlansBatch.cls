/*
*スチール_納品トン数objの当月以降（当月含む）のトン数を商談objの項目に積み上げ
*/
global without sharing class NHR_ST_QuantityActualPlansBatch implements Database.Batchable<sObject>, Database.Stateful{

    global static final String TYPE1 = '埼玉工場';
    global static final String TYPE2 = '神奈川工場';
    
    global Integer thisYear {get;set;}
    global Integer thisMonth {get;set;}
    global Map<String ,ST_ManagementDashboard__c> excelMap1 {get;set;}

    global NHR_ST_QuantityActualPlansBatch(){

    }
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_ST_QuantityActualPlansBatch');
        List<ST_ManagementDashboard__c> delList = new List<ST_ManagementDashboard__c>();
        delList = [Select id From ST_ManagementDashboard__c 
                   where Name = :NHR_Constant.BATCHNAME_ST_AP
                  AND OwnerId = :UserInfo.getUserId()];
        if (delList != null && delList.size() >0){delete delList;}
        
        excelMap1 = new Map<String ,ST_ManagementDashboard__c>();
        thisYear = Date.Today().Year();
        thisMonth = Date.Today().Month();
        setInit();
        
    	String query = NHR_Dao.get_NHR_ST_QuantityActualPlansBatch();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Steel_delivery__c> scopes){
        ST_ManagementDashboard__c tempInfo1_1 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo1_2 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo1_3 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo1_4 = new ST_ManagementDashboard__c();
        
        ST_ManagementDashboard__c tempInfo2_1 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo2_2 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo2_3 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo2_4 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo2_5 = new ST_ManagementDashboard__c();
        
        tempInfo1_1 = excelMap1.get('saitama1');
        tempInfo1_2 = excelMap1.get('saitama2');
        tempInfo1_3 = excelMap1.get('saitama3');
        tempInfo1_4 = excelMap1.get('saitama4');
        
        tempInfo2_1 = excelMap1.get('kanagawa1');
        tempInfo2_2 = excelMap1.get('kanagawa2');
        tempInfo2_3 = excelMap1.get('kanagawa3');
        tempInfo2_4 = excelMap1.get('kanagawa4');
        tempInfo2_5 = excelMap1.get('kanagawa5');
        for(Steel_delivery__c obj : scopes) {
            for (integer i = 1; i <= 12 ; i++) {
                Decimal restTons = 0;
                String apiName = setAPIName(thisYear ,i);
                restTons = obj.get(apiName) == null ?  0 : Decimal.valueOf(String.valueOf(obj.get(apiName)));
                String apiName_des = 'Current' + String.valueOf(i) +'_Orig__c';
                if (obj.Opp__r.ST_processing__c == '埼玉') {
                    if (obj.Opp__r.StageName == '仕掛') {
                        tempInfo1_1.put(apiName_des , Decimal.valueOf(String.valueOf(tempInfo1_1.get(apiName_des))) + restTons );
                    }else if (obj.Opp__r.StageName == '受注ST') {
                        tempInfo1_2.put(apiName_des , Decimal.valueOf(String.valueOf(tempInfo1_2.get(apiName_des))) + restTons );
                    }else if (obj.Opp__r.StageName == 'A' || obj.Opp__r.StageName == 'B'
                             || obj.Opp__r.StageName == 'C' || obj.Opp__r.StageName == 'D'
                             || obj.Opp__r.StageName == 'E' || obj.Opp__r.StageName == 'F'
                             || obj.Opp__r.StageName == 'G' || obj.Opp__r.StageName == 'H')  {
                        tempInfo1_3.put(apiName_des , Decimal.valueOf(String.valueOf(tempInfo1_3.get(apiName_des))) + restTons );
                    }
                }else if (obj.Opp__r.ST_processing__c == '神奈川') {
                    if (obj.Opp__r.StageName == '仕掛') {
                        tempInfo2_1.put(apiName_des , Decimal.valueOf(String.valueOf(tempInfo2_1.get(apiName_des))) + restTons );
                    }else if (obj.Opp__r.StageName == '受注ST') {
                        tempInfo2_2.put(apiName_des , Decimal.valueOf(String.valueOf(tempInfo2_2.get(apiName_des))) + restTons );
                    }else if (obj.Opp__r.StageName == 'A' || obj.Opp__r.StageName == 'B'
                             || obj.Opp__r.StageName == 'C' || obj.Opp__r.StageName == 'D'
                             || obj.Opp__r.StageName == 'E' || obj.Opp__r.StageName == 'F'
                             || obj.Opp__r.StageName == 'G' || obj.Opp__r.StageName == 'H') {
                        tempInfo2_3.put(apiName_des , Decimal.valueOf(String.valueOf(tempInfo2_3.get(apiName_des))) + restTons );
                    }
                }else if (obj.Opp__r.ST_processing__c == '外注') {
                    tempInfo2_5.put(apiName_des , Decimal.valueOf(String.valueOf(tempInfo2_5.get(apiName_des))) + restTons );
                }
            }
        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        NHR_ST_QuantityActualPlansBatch2 myBatchObject = new NHR_ST_QuantityActualPlansBatch2(excelMap1);
        Database.executeBatch(myBatchObject,200);
    }
        
    /**
     * API取得
     */
    private String setAPIName(Integer inYears ,Integer num){
        String apiName = 'X';
        if (num < 7) {
            apiName += String.ValueOf(inYears + 1) + '_' + String.ValueOf(num) + '__c';
        } else {
            apiName += String.ValueOf(inYears) + '_' + String.ValueOf(num) + '__c';
        }
        return apiName;
    }
    
    /** 
     * 初期設定
     */
    private void setInit(){
        //日付設定
        Date theToday = Date.Today();
        Date forGetDay = Date.Today();
        
        //埼玉工場
        excelMap1.put('saitama1', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE1, '仕 掛 物 件','',101));
        excelMap1.put('saitama2', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE1, '受 注 物 件','',102));
        excelMap1.put('saitama3', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE1, '追 求 物 件','',103));
        excelMap1.put('saitama4', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE1, '加工材物件','',104));
        excelMap1.put('saitama5', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE1, '委託加工分','',105));
        excelMap1.put('saitama6', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE1, '直  送  分','',106));
        excelMap1.put('saitama7', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE1, '売　却　分','',107));
        excelMap1.put('saitama8', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE1, '計','',108));
        excelMap1.put('saitama9', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE1, '売却分','',109));
        
        //神奈川工場
        excelMap1.put('kanagawa1', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE2, '仕 掛 物 件','',201));
        excelMap1.put('kanagawa2', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE2, '受 注 物 件','',202));
        excelMap1.put('kanagawa3', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE2, '追 求 物 件','',203));
        excelMap1.put('kanagawa4', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE2, '加工材物件','',204));
        excelMap1.put('kanagawa5', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE2, '委託加工分','',205));
        excelMap1.put('kanagawa6', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE2, '直  送  分','',206));
        excelMap1.put('kanagawa7', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE2, '計','',207));
        
        //合計
        excelMap1.put('sum1', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE1 + TYPE2, '２工場　加工　計','',901));
        excelMap1.put('sum2', setFC(NHR_Constant.BATCHNAME_ST_AP,TYPE1 + TYPE2, '加工 計（外注含む）','',902));
    }
    
    private ST_ManagementDashboard__c setFC(String Name , String Title1 ,String Title2 ,String Title3 ,integer orderBy){
        ST_ManagementDashboard__c rec = new ST_ManagementDashboard__c();
        rec.Name = Name;
        rec.X1__c  = Title1;
        rec.X2__c  = Title2;
        rec.X3__c  = Title3;
        rec.orderBy__c = orderBy;
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
        rec.TotalThisYear_Orig__c = 0; 
        return rec;
    } 

}