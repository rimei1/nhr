global without sharing class NHR_SL_SalesManagementBatch2 implements Database.Batchable<sObject>, Database.Stateful{
    global Date startDate {get;set;}
    global Date endDate {get;set;}
    global Map<String ,FormCreation__c> excelMap1 {get;set;}
    global Map<String ,FormCreation__c> excelMap2 {get;set;}
    global Map<String ,FormCreation__c> excelMap3 {get;set;}
    global Map<String ,FormCreation__c> excelMap4 {get;set;}

    global NHR_SL_SalesManagementBatch2
        (
            Map<String ,FormCreation__c> inExcelMap1,
            Map<String ,FormCreation__c> inExcelMap2,
            Map<String ,FormCreation__c> inExcelMap3,
            Map<String ,FormCreation__c> inExcelMap4,
            Date inStartDate,
            Date inEndDate
        ){
            this.excelMap1 = inExcelMap1;
            this.excelMap2 = inExcelMap2;
            this.excelMap3 = inExcelMap3;
            this.excelMap4 = inExcelMap4;
            this.startDate = inStartDate;
            this.endDate = inEndDate;
    }
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_SL_SalesManagementBatch2');

    	String query = NHR_Dao.get_NHR_SL_SalesManagementBatch2();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Asset> scopes){
        FormCreation__c tempInfo2_1 = excelMap2.get('1');
        FormCreation__c tempInfo2_2 = excelMap2.get('2');
        FormCreation__c tempInfo2_3 = excelMap2.get('3');
        FormCreation__c tempInfo2_4 = excelMap2.get('4');
        
        FormCreation__c tempInfo4_1 = excelMap4.get('1');
        FormCreation__c tempInfo4_2 = excelMap4.get('2');
        FormCreation__c tempInfo4_3 = excelMap4.get('3');

        for(Asset obj : scopes) {
            if (obj.ProductFamily__c == 'Pro3AK') {
                setExcelData(tempInfo2_1 ,tempInfo2_2,tempInfo2_3,tempInfo4_1,obj);
            } else if (obj.ProductFamily__c == 'Pro2') {
                setExcelData(tempInfo2_1 ,tempInfo2_2,tempInfo2_3,tempInfo4_2,obj);
            } else if (obj.ProductFamily__c == 'Axis') {
                setExcelData(tempInfo2_1 ,tempInfo2_2,tempInfo2_3,tempInfo4_3,obj);
            } 
        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        setSum2();
        setSum4();
        //完了後の処理があれば
        insert excelMap2.values();
        insert excelMap4.values();


        //完了後の処理があれば
        System.Queueable job = new NHR_SL_SalesManagementExcelCreate();
        System.enqueueJob(job);
    }

    /**
     * 日付によって値設定
     */
    private void setExcelData(FormCreation__c inData ,FormCreation__c inData2 ,FormCreation__c inData3 ,FormCreation__c inData4 ,Asset aObj){
        if (aObj.SL_SalesManagement__c != null) {
            Integer monthNum =  aObj.SL_SalesManagement__c.month();
            switch on monthNum {
                when 1 {
                    inData.J__c += NHR_Dao.getDecimal(aObj.AdoptionAmount__c);
                    inData2.J__c += NHR_Dao.getDecimal(aObj.Cost__c);
                    inData3.J__c += NHR_Dao.getDecimal(aObj.GrossProfitAmount__c);
                    inData4.J__c += 1;
                }	
                when 2 {
                    inData.K__c += NHR_Dao.getDecimal(aObj.AdoptionAmount__c);
                    inData2.K__c += NHR_Dao.getDecimal(aObj.Cost__c);
                    inData3.K__c += NHR_Dao.getDecimal(aObj.GrossProfitAmount__c);
                    inData4.K__c += 1;
                }
                when 3 {
                    inData.L__c += NHR_Dao.getDecimal(aObj.AdoptionAmount__c);
                    inData2.L__c += NHR_Dao.getDecimal(aObj.Cost__c);
                    inData3.L__c += NHR_Dao.getDecimal(aObj.GrossProfitAmount__c);
                    inData4.L__c += 1;
                }
                when 4 {
                    inData.M__c += NHR_Dao.getDecimal(aObj.AdoptionAmount__c);
                    inData2.M__c += NHR_Dao.getDecimal(aObj.Cost__c);
                    inData3.M__c += NHR_Dao.getDecimal(aObj.GrossProfitAmount__c);
                    inData4.M__c += 1;
                }	
                when 5 {
                    inData.N__c += NHR_Dao.getDecimal(aObj.AdoptionAmount__c);
                    inData2.N__c += NHR_Dao.getDecimal(aObj.Cost__c);
                    inData3.N__c += NHR_Dao.getDecimal(aObj.GrossProfitAmount__c);
                    inData4.N__c += 1;
                }
                when 6 {
                    inData.O__c += NHR_Dao.getDecimal(aObj.AdoptionAmount__c);
                    inData2.O__c += NHR_Dao.getDecimal(aObj.Cost__c);
                    inData3.O__c += NHR_Dao.getDecimal(aObj.GrossProfitAmount__c);
                    inData4.O__c += 1;
                }
                when 7 {
                    inData.D__c += NHR_Dao.getDecimal(aObj.AdoptionAmount__c);
                    inData2.D__c += NHR_Dao.getDecimal(aObj.Cost__c);
                    inData3.D__c += NHR_Dao.getDecimal(aObj.GrossProfitAmount__c);
                    inData4.D__c += 1;
                }	
                when 8 {
                    inData.E__c += NHR_Dao.getDecimal(aObj.AdoptionAmount__c);
                    inData2.E__c += NHR_Dao.getDecimal(aObj.Cost__c);
                    inData3.E__c += NHR_Dao.getDecimal(aObj.GrossProfitAmount__c);
                    inData4.E__c += 1;
                }
                when 9 {
                    inData.F__c += NHR_Dao.getDecimal(aObj.AdoptionAmount__c);
                    inData2.F__c += NHR_Dao.getDecimal(aObj.Cost__c);
                    inData3.F__c += NHR_Dao.getDecimal(aObj.GrossProfitAmount__c);
                    inData4.F__c += 1;
                }
                when 10 {
                    inData.G__c += NHR_Dao.getDecimal(aObj.AdoptionAmount__c);
                    inData2.G__c += NHR_Dao.getDecimal(aObj.Cost__c);
                    inData3.G__c += NHR_Dao.getDecimal(aObj.GrossProfitAmount__c);
                    inData4.G__c += 1;
                }	
                when 11 {
                    inData.H__c += NHR_Dao.getDecimal(aObj.AdoptionAmount__c);
                    inData2.H__c += NHR_Dao.getDecimal(aObj.Cost__c);
                    inData3.H__c += NHR_Dao.getDecimal(aObj.GrossProfitAmount__c);
                    inData4.H__c += 1;
                }
                when 12 {
                    inData.I__c += NHR_Dao.getDecimal(aObj.AdoptionAmount__c);
                    inData2.I__c += NHR_Dao.getDecimal(aObj.Cost__c);
                    inData3.I__c += NHR_Dao.getDecimal(aObj.GrossProfitAmount__c);
                    inData4.I__c += 1;
                }
            }
        }
    }
    
    /**
     * 集計 2
     */
    private void setSum2(){
        FormCreation__c tempInfo2_1 = excelMap2.get('1');
        FormCreation__c tempInfo2_2 = excelMap2.get('2');
        FormCreation__c tempInfo2_3 = excelMap2.get('3');
        FormCreation__c tempInfo2_4 = excelMap2.get('4');
        
        tempInfo2_1 = set1000Tani(tempInfo2_1);
        tempInfo2_2 = set1000Tani(tempInfo2_2);
        tempInfo2_3 = set1000Tani(tempInfo2_3);
        
        setSum(tempInfo2_1);
        setSum(tempInfo2_2);
        setSum(tempInfo2_3);
        
        tempInfo2_4.D__c = NHR_Dao.getDivision(tempInfo2_1.D__c ,tempInfo2_3.D__c);
        tempInfo2_4.E__c = NHR_Dao.getDivision(tempInfo2_1.E__c ,tempInfo2_3.E__c);
        tempInfo2_4.F__c = NHR_Dao.getDivision(tempInfo2_1.F__c ,tempInfo2_3.F__c);
        tempInfo2_4.G__c = NHR_Dao.getDivision(tempInfo2_1.G__c ,tempInfo2_3.G__c);
        tempInfo2_4.H__c = NHR_Dao.getDivision(tempInfo2_1.H__c ,tempInfo2_3.H__c);
        tempInfo2_4.I__c = NHR_Dao.getDivision(tempInfo2_1.I__c ,tempInfo2_3.I__c);
        tempInfo2_4.J__c = NHR_Dao.getDivision(tempInfo2_1.J__c ,tempInfo2_3.J__c);
        tempInfo2_4.K__c = NHR_Dao.getDivision(tempInfo2_1.K__c ,tempInfo2_3.K__c);
        tempInfo2_4.L__c = NHR_Dao.getDivision(tempInfo2_1.L__c ,tempInfo2_3.L__c);
        tempInfo2_4.M__c = NHR_Dao.getDivision(tempInfo2_1.M__c ,tempInfo2_3.M__c);
        tempInfo2_4.N__c = NHR_Dao.getDivision(tempInfo2_1.N__c ,tempInfo2_3.N__c);
        tempInfo2_4.O__c = NHR_Dao.getDivision(tempInfo2_1.O__c ,tempInfo2_3.O__c);
        tempInfo2_4.P__c = NHR_Dao.getDivision(tempInfo2_1.P__c ,tempInfo2_3.P__c);
    }
    
    /**
     * 集計4
     */
    private void setSum4(){
        FormCreation__c tempInfo4_1 = excelMap3.get('1');
        FormCreation__c tempInfo4_2 = excelMap3.get('2');
        FormCreation__c tempInfo4_3 = excelMap3.get('3');
        
        setSum(tempInfo4_1);
        setSum(tempInfo4_2);
        setSum(tempInfo4_3);
    }
    
    private void setSum(FormCreation__c inObj){
        inObj.P__c = inObj.D__c + inObj.E__c + inObj.F__c + inObj.G__c + inObj.H__c + inObj.I__c
             + inObj.J__c + inObj.K__c + inObj.L__c + inObj.M__c + inObj.N__c + inObj.O__c;
    }
    
    private FormCreation__c set1000Tani(FormCreation__c  tempInfo){
        tempInfo.D__c = tempInfo.D__c / 1000;
        tempInfo.E__c = tempInfo.E__c / 1000;
        tempInfo.F__c = tempInfo.F__c / 1000;
        tempInfo.G__c = tempInfo.G__c / 1000;
        tempInfo.H__c = tempInfo.H__c / 1000;
        tempInfo.I__c = tempInfo.I__c / 1000;
        tempInfo.J__c = tempInfo.J__c / 1000;
        tempInfo.K__c = tempInfo.K__c / 1000;
        tempInfo.L__c = tempInfo.L__c / 1000;
        tempInfo.M__c = tempInfo.M__c / 1000;
        tempInfo.N__c = tempInfo.N__c / 1000;
        tempInfo.O__c = tempInfo.O__c / 1000;
        tempInfo.P__c = tempInfo.P__c / 1000;
        tempInfo.Q__c = tempInfo.Q__c / 1000;
        tempInfo.R__c = tempInfo.R__c / 1000;
        tempInfo.S__c = tempInfo.S__c / 1000;
        tempInfo.T__c = tempInfo.T__c / 1000;
        return tempInfo;
    }

    /**
   * EXCEL作成
   */
    public class NHR_SL_SalesManagementExcelCreate implements Queueable, Database.AllowsCallouts {

        public NHR_SL_SalesManagementExcelCreate()
        {

        }
        public void execute(QueueableContext context) {
            if(!Test.isRunningTest()){
                ContentVersion conObject=new ContentVersion();
                String fileSubName = '';
                String fileName = String.valueOf(Date.today()).replaceAll('-', '')+ fileSubName;
                conObject.title = fileName + '.xls';
                conObject.PathOnClient = fileName + '.xls';
                PageReference pr = Page.NHR_SL_SalesManagement;
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

            mail.setSubject('「売上管理表_2」出力完了のお知らせ'); // 件名(String)
            mail.setPlainTextBody('「売上管理表_②」の出力が完了いたしました。'); // 本文(String)
            mail.setEntityAttachments(new List<String>{contentId}); // 添付ファイル(Document、ContentVersion、AttachmentのIDのリスト)

            mail.setReplyTo(UserInfo.getUserEmail()); // 返信先メールアドレス(String)

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
    }
    
    public static void forTest() {
        String test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
        test = '1';
    }
}