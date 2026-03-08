global without sharing class NHR_JU_BPOKPIKGIReportBatch implements Database.Batchable<sObject>, Database.Stateful{
    global Map<String ,FormCreation__c> excelMap {get;set;}
    global Map<String ,String> orgMap {get;set;}

    global NHR_JU_BPOKPIKGIReportBatch(){
    }
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_JU_BPOKPIKGIReportBatch');
        setInit();
    	String query = NHR_Dao.get_NHR_JU_BPOKPIKGIReport();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){

        FormCreation__c tempInfoSum = new FormCreation__c();
        tempInfoSum = excelMap.get('9992');
        for(Opportunity obj : scopes) {
            FormCreation__c tempInfo = new FormCreation__c();
            FormCreation__c tempInfo2 = new FormCreation__c();
            String tempKey = obj.Department__c + '_' + (String.isBlank(obj.Account.JU_sakuzusekisanbpo_yusendo__c) ? '' : obj.Account.JU_sakuzusekisanbpo_yusendo__c);
            String tempKeySum = obj.Department__c + '_Sum';
            if (excelMap.containskey(tempKey)) {
                tempInfo = excelMap.get(tempKey);
                tempInfo2 = excelMap.get(tempKeySum);
                setExcelData(tempInfo,tempInfoSum,tempInfo2,obj);
            } else {
                system.debug('test');
                tempInfo = excelMap.get('9991');
                setExcelData(tempInfo,tempInfoSum,NULL,obj);
            }
        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        setSum1();
        //完了後の処理があれば
        insert excelMap.values();



        //完了後の処理があれば
        System.Queueable job = new ExcelCreate();
        System.enqueueJob(job);
    }
    
    /**
     * 初期設定
     */
    private void setInit(){
        //表示内容設定
        excelMap = new Map<String ,FormCreation__c>();
        
        //合計行
        excelMap.put('9991', setFC(NHR_Constant.BATCHNAME_JU_KPI,'その他 集計','','　',9991));
        excelMap.put('9992', setFC(NHR_Constant.BATCHNAME_JU_KPI,'総計','','　',9992));
        excelMap.put('9993', setFC(NHR_Constant.BATCHNAME_JU_KPI,'目標','','　',9993));
        excelMap.put('9994', setFC(NHR_Constant.BATCHNAME_JU_KPI,'実績','','　',9994));
        excelMap.put('9995', setFC(NHR_Constant.BATCHNAME_JU_KPI,'達成率','','　',9995));
        
        // 各営業所取得
        List<JU_BPOGoal__mdt> md1 = JU_BPOGoal__mdt.getAll().Values();
        orgMap = new Map<String,String>();
        
        system.debug('md1:' + md1);
        integer orderNum = 0;
        FormCreation__c tempInfo_9993 = new FormCreation__c();
        //目標設定
        tempInfo_9993 = excelMap.get('9993');
        tempInfo_9993.K__c = 7;
        for(JU_BPOGoal__mdt mt : md1) {
            orgMap.put(mt.Label ,mt.OrderBy__c);
            excelMap.put(mt.Label + '_', setFC(NHR_Constant.BATCHNAME_JU_KPI,mt.OrderBy__c + '.' + mt.Label,'','　',Integer.valueof(mt.OrderBy__c) * 10 + 1));
            excelMap.put(mt.Label + '_A', setFC(NHR_Constant.BATCHNAME_JU_KPI,mt.OrderBy__c + '.' + mt.Label,'A','　',Integer.valueof(mt.OrderBy__c) * 10 + 2));
            excelMap.put(mt.Label + '_B', setFC(NHR_Constant.BATCHNAME_JU_KPI,mt.OrderBy__c + '.' + mt.Label,'B','　',Integer.valueof(mt.OrderBy__c) * 10 + 3));
            excelMap.put(mt.Label + '_C', setFC(NHR_Constant.BATCHNAME_JU_KPI,mt.OrderBy__c + '.' + mt.Label,'C','　',Integer.valueof(mt.OrderBy__c) * 10 + 4));
            excelMap.put(mt.Label + '_Sum', setFC(NHR_Constant.BATCHNAME_JU_KPI,mt.OrderBy__c + '.' + mt.Label + ' 集計','','　',Integer.valueof(mt.OrderBy__c) * 10 + 9));
            orderNum += 1;
            tempInfo_9993.E__c += mt.KPI__c == NULL ? 0 : mt.KPI__c;
            tempInfo_9993.G__c += mt.KGI__c == NULL ? 0 : mt.KGI__c;
        }
        
        

    }

    /**
     * 日付によって値設定
     */
    private void setExcelData(FormCreation__c inData1 ,FormCreation__c inData2, FormCreation__c inData3, Opportunity aObj){
            switch on aObj.StageName {
                when '未着手' {
                    inData1.C__c += 1;
                    inData2.C__c += 1;
                    if (inData3 != NULL) {inData3.C__c += 1;}
                    
                }	
                when '活動開始' {
                    inData1.D__c += 1;
                    inData2.D__c += 1;
                    if (inData3 != NULL) {inData3.D__c += 1;}
                    
                }
                when '初回訪問' {
                    inData1.E__c += 1;
                    inData2.E__c += 1;
                    if (inData3 != NULL) {inData3.E__c += 1;}
                    
                }
                when 'KMプレゼン完了' {
                    inData1.F__c += 1;
                    inData2.F__c += 1;
                    if (inData3 != NULL) {inData3.F__c += 1;}
                    
                }	
                when 'Phase1導入' {
                    inData1.G__c += 1;
                    inData2.G__c += 1;
                    if (inData3 != NULL) {inData3.G__c += 1;}
                    
                }
                when '最終提案完了' {
                    inData1.H__c += 1;
                    inData2.H__c += 1;
                    if (inData3 != NULL) {inData3.H__c += 1;}
                    
                }
                when '検討保留' {
                    inData1.I__c += 1;
                    inData2.I__c += 1;
                    if (inData3 != NULL) {inData3.I__c += 1;}
                    
                }	
                when '提案停止' {
                    inData1.J__c += 1;
                    inData2.J__c += 1;
                    if (inData3 != NULL) { inData3.J__c += 1;}
                   
                }
                when '採用（受注）' {
                    inData1.K__c += 1;
                    inData2.K__c += 1;
                    if (inData3 != NULL) {inData3.K__c += 1;}
                    
                }
                when '材販切替' {
                    inData1.L__c += 1;
                    inData2.L__c += 1;
                    if (inData3 != NULL) {inData3.L__c += 1;}
                    
                }
                when else {
                    inData1.M__c += 1;
                    inData2.M__c += 1;
                    if (inData3 != NULL) {inData3.M__c += 1;}
                    
                }
            }
    }
    
    /**
     * 集計
     */
    private void setSum1(){
        FormCreation__c tempInfo = new FormCreation__c();
        for (String str : excelMap.keySet()) {
            tempInfo = excelMap.get(str);
            setSum(tempInfo);
        }
        //合計値取得
        FormCreation__c tempInfo_9992 = new FormCreation__c();
        tempInfo_9992 = excelMap.get('9992');
        //目標値取得
        FormCreation__c tempInfo_9993 = new FormCreation__c();
        tempInfo_9993 = excelMap.get('9993');
        
        //実績設定
        FormCreation__c tempInfo_9994 = new FormCreation__c();
        tempInfo_9994 = excelMap.get('9994');
        tempInfo_9994.E__c = tempInfo_9992.E__c + tempInfo_9992.F__c + tempInfo_9992.H__c + tempInfo_9992.K__c;
        tempInfo_9994.G__c = tempInfo_9992.G__c +tempInfo_9992.H__c + tempInfo_9992.K__c;
        tempInfo_9994.K__c = tempInfo_9992.K__c;
        
        //達成率設定
        FormCreation__c tempInfo_9995 = new FormCreation__c();
        tempInfo_9995 = excelMap.get('9995');
        tempInfo_9995.E__c = NHR_Dao.getDivision(tempInfo_9993.E__c ,tempInfo_9994.E__c);
        tempInfo_9995.G__c = NHR_Dao.getDivision(tempInfo_9993.G__c ,tempInfo_9994.G__c);
        tempInfo_9995.K__c = NHR_Dao.getDivision(tempInfo_9993.K__c ,tempInfo_9994.K__c);
    }
    
    private void setSum(FormCreation__c inObj){
        inObj.N__c = inObj.C__c + inObj.D__c + inObj.E__c + inObj.F__c + inObj.G__c + inObj.H__c + inObj.I__c
             + inObj.J__c + inObj.K__c + inObj.L__c + inObj.M__c;
    }
    
    private FormCreation__c setFC(String Name , String Title1 ,String Title2 ,String Title3 ,integer orderBy){
        FormCreation__c rec = new FormCreation__c();
        rec.Name = Name;
        rec.Title1__c = Title1;
        rec.Title2__c = Title2;
        rec.Title3__c = Title3;
        rec.orderBy__c = orderBy;
        rec.A__c = 0;
        rec.B__c = 0;
        rec.C__c = 0;
        rec.D__c = 0;
        rec.E__c = 0;
        rec.F__c = 0;
        rec.G__c = 0;
        rec.H__c = 0;
        rec.I__c = 0;
        rec.J__c = 0;
        rec.K__c = 0;
        rec.L__c = 0;
        rec.M__c = 0;
        rec.N__c = 0;
        rec.O__c = 0;
        rec.P__c = 0;
        rec.Q__c = 0;
        rec.R__c = 0;
        rec.S__c = 0;
        rec.T__c = 0;
        rec.U__c = 0;
        rec.V__c = 0;
        rec.W__c = 0;
        return rec;
    }

    /**
   * EXCEL作成
   */
    public class ExcelCreate implements Queueable, Database.AllowsCallouts {

        public ExcelCreate()
        {

        }
        public void execute(QueueableContext context) {
            if(!Test.isRunningTest()){
                ContentVersion conObject=new ContentVersion();
                String fileSubName = '';
                String fileName = String.valueOf(Date.today()).replaceAll('-', '')+ fileSubName;
                conObject.title = fileName + '.xls';
                conObject.PathOnClient = fileName + '.xls';
                PageReference pr = Page.NHR_JU_BPOKPIKGIReport;
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

            mail.setSubject('「住環境_作図積算BPOKPIKGIレポートダッシュボード」出力完了のお知らせ'); // 件名(String)
            mail.setPlainTextBody('「住環境_作図積算BPOKPIKGIレポートダッシュボード」の出力が完了いたしました。'); // 本文(String)
            mail.setEntityAttachments(new List<String>{contentId}); // 添付ファイル(Document、ContentVersion、AttachmentのIDのリスト)

            mail.setReplyTo(UserInfo.getUserEmail()); // 返信先メールアドレス(String)

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
    }
    
}