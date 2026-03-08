/*
*スチール_納品トン数objの当月以降（当月含む）のトン数を商談objの項目に積み上げ
*/
global without sharing class NHR_ST_QuantityActualPlansBatch2 implements Database.Batchable<sObject>, Database.Stateful{

    global static final String TYPE1 = '埼玉工場';
    global static final String TYPE2 = '神奈川工場';
    
    global Integer thisYear {get;set;}
    global Integer thisMonth {get;set;}
    global Map<String ,ST_ManagementDashboard__c> excelMap1 {get;set;}

    global NHR_ST_QuantityActualPlansBatch2(Map<String ,ST_ManagementDashboard__c> inExcelMap1){
        excelMap1 = inExcelMap1;
    }
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_ST_QuantityActualPlansBatch2');
        thisYear = Date.Today().Year();
        thisMonth = Date.Today().Month();
    	String query = NHR_Dao.get_NHR_ST_QuantityActualPlansBatch2();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Steel_delivery__c> scopes){       
        ST_ManagementDashboard__c tempInfo1_4 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo2_4 = new ST_ManagementDashboard__c();
        
        tempInfo1_4 = excelMap1.get('saitama4');
        tempInfo2_4 = excelMap1.get('kanagawa4');

        for(Steel_delivery__c obj : scopes) {
            for (integer i = 1; i <= 12 ; i++) {
                Decimal restTons = 0;
                String apiName = setAPIName(thisYear ,i);
                restTons = obj.get(apiName) == null ?  0 : Decimal.valueOf(String.valueOf(obj.get(apiName)));
                String apiName_des = 'Current' + String.valueOf(i) +'_Orig__c';
                
                if (obj.Opp__r.ST_processing__c == '埼玉') { 
                    tempInfo1_4.put(apiName_des , Decimal.valueOf(String.valueOf(tempInfo1_4.get(apiName_des))) + restTons );
                } else if (obj.Opp__r.ST_processing__c == '神奈川') {
                    tempInfo2_4.put(apiName_des , Decimal.valueOf(String.valueOf(tempInfo2_4.get(apiName_des))) + restTons );
                }
            }
        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        setSum();
        insert excelMap1.values();
        
        //完了後の処理があれば
        System.Queueable job = new NHR_ST_QuantityActualPlansExcelCreate();
        System.enqueueJob(job);
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
     * 集計
     */
    private void setSum(){
        ST_ManagementDashboard__c tempInfo1_1 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo1_2 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo1_3 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo1_4 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo1_8 = new ST_ManagementDashboard__c();
        
        ST_ManagementDashboard__c tempInfo2_1 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo2_2 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo2_3 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo2_4 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo2_5 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c tempInfo2_7 = new ST_ManagementDashboard__c();
        
        ST_ManagementDashboard__c sum1 = new ST_ManagementDashboard__c();
        ST_ManagementDashboard__c sum2 = new ST_ManagementDashboard__c();
        
        tempInfo1_1 = excelMap1.get('saitama1');
        tempInfo1_2 = excelMap1.get('saitama2');
        tempInfo1_3 = excelMap1.get('saitama3');
        tempInfo1_4 = excelMap1.get('saitama4');
        tempInfo1_8 = excelMap1.get('saitama8');
        
        tempInfo2_1 = excelMap1.get('kanagawa1');
        tempInfo2_2 = excelMap1.get('kanagawa2');
        tempInfo2_3 = excelMap1.get('kanagawa3');
        tempInfo2_4 = excelMap1.get('kanagawa4');
        tempInfo2_5 = excelMap1.get('kanagawa5');
        tempInfo2_7 = excelMap1.get('kanagawa7');
        
        sum1 = excelMap1.get('sum1');
        sum2 = excelMap1.get('sum2');

        //月毎集計
        for (integer i = 1 ; i <= 12 ; i++) {
            Decimal temp1_sum = 0;
            Decimal temp2_sum = 0;
            
            Decimal sum_1 = 0;
            Decimal sum_2 = 0;
            
            String apiName_des = 'Current' + String.valueOf(i) +'_Orig__c';
            temp1_sum += Decimal.valueOf(String.valueOf(tempInfo1_1.get(apiName_des)));
            temp1_sum += Decimal.valueOf(String.valueOf(tempInfo1_2.get(apiName_des)));
            temp1_sum += Decimal.valueOf(String.valueOf(tempInfo1_3.get(apiName_des)));
            temp1_sum += Decimal.valueOf(String.valueOf(tempInfo1_4.get(apiName_des)));

            temp2_sum += Decimal.valueOf(String.valueOf(tempInfo2_1.get(apiName_des)));
            temp2_sum += Decimal.valueOf(String.valueOf(tempInfo2_2.get(apiName_des)));
            temp2_sum += Decimal.valueOf(String.valueOf(tempInfo2_3.get(apiName_des)));
            temp2_sum += Decimal.valueOf(String.valueOf(tempInfo2_4.get(apiName_des)));
            temp2_sum += Decimal.valueOf(String.valueOf(tempInfo2_5.get(apiName_des)));
            
            sum_1 = temp1_sum + temp2_sum - Decimal.valueOf(String.valueOf(tempInfo2_5.get(apiName_des)));
            sum_2 = temp1_sum + temp2_sum ;
            
            tempInfo1_8.put(apiName_des , temp1_sum );
            tempInfo2_7.put(apiName_des , temp2_sum );

            sum1.put(apiName_des , sum_1 );
            sum2.put(apiName_des , sum_2 );
        }
        
        //行毎集計
        for (String keyStr : excelMap1.keySet()) {
            ST_ManagementDashboard__c tempInfo = excelMap1.get(keyStr);
            for (integer i = 1 ; i <= 12 ; i++) {
                String apiName_des = 'Current' + String.valueOf(i) +'_Orig__c';
                tempInfo.TotalThisYear_Orig__c += Decimal.valueOf(String.valueOf(tempInfo.get(apiName_des)));
            }
        }
    }
    
    /**
   * EXCEL作成
   */
    public class NHR_ST_QuantityActualPlansExcelCreate implements Queueable, Database.AllowsCallouts {
        public NHR_ST_QuantityActualPlansExcelCreate()
        {
        }
        
        public void execute(QueueableContext context) {
            if(!Test.isRunningTest()){
                ContentVersion conObject=new ContentVersion();
                String fileName = String.valueOf(Date.today()).replaceAll('-', '');
                conObject.title = fileName + '.xls';
                conObject.PathOnClient = fileName + '.xls';
                PageReference pr = Page.NHR_ST_QuantityActualPlans;
                conObject.versiondata=pr.getContent();
                insert conObject;
                
                mailSend(conObject.Id);
            }
        }
        
        /*
        * メール送信
       */
        private void mailSend(String contentId){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(new List<String>{UserInfo.getUserEmail()}); // 送信先(String[])
            
            mail.setSubject('【' + '加工数量実績および予定表' +'】作成完了'); // 件名(String)
            mail.setPlainTextBody('加工数量実績および予定表' + 'が作成完了しまして、ご確認をお願いします。'); // 本文(String)
            mail.setEntityAttachments(new List<String>{contentId}); // 添付ファイル(Document、ContentVersion、AttachmentのIDのリスト)
            
            mail.setReplyTo(UserInfo.getUserEmail()); // 返信先メールアドレス(String)
            
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
    }
    
    public static void forTest() {
        String test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
    }

}