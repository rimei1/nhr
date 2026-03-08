global without sharing class NHR_EN_OrderAmountListOsakaBatch2 implements Database.Batchable<sObject>, Database.Stateful{

    static final String ACTUAL = '実績';
    static final String BUDGET = '予算';
    static final String TITLE2_1 = '受注';
    static final String TITLE2_2 = '追求';
    static final String TITLE3_1 = '年間計画';
    static final String TITLE3_2 = '累計実績';
    static final String TITLE3_3 = '進捗率';
    static final String TITLE3_4 = '不足額';
    static final String TITLE3_5 = '合計';
    static final String TITLE3_6 = 'A';
    static final String TITLE3_7 = 'B';
    static final String TITLE3_8 = 'C';
    //global Map<String ,FormCreation__c> excelMap1_1 {get;set;}
    global Map<String ,Map<String ,FormCreation__c>> excelMap {get;set;}
    global Map<String ,String> yearMap {get;set;}
    global Map<String ,EN_Report__mdt> reportMap {get;set;}
    global String kanseiki {get;set;}
    global NHR_EN_OrderAmountListOsakaBatch2
        (Map<String ,Map<String ,FormCreation__c>> inExcelMap
         ,Map<String ,EN_Report__mdt> inReportMap
         ,Map<String ,String> inYearMap
         ,String inKanseiki)
    {
        this.excelMap = inExcelMap;
        this.reportMap = inReportMap;
        this.yearMap = inYearMap;
        this.kanseiki = inKanseiki;
    }
    
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_EN_OrderAmountListBatch2');

        Set<String> tantobusyo = reportMap.keySet();
    	String query = NHR_Dao.get_NHR_EN_OrderAmountListOsakaBatch2();
        return Database.getQueryLocator(query);
    }
    
    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){
        for(Opportunity obj : scopes) {
            
            if (!excelMap.containsKey(obj.OwnerId) || Test.isRunningTest()) {
                Map<String ,FormCreation__c> excelMap1_1 = new Map<String ,FormCreation__c>();
                integer orderStart = excelMap.size();
                excelMap1_1.put(obj.OwnerId + TITLE3_1, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_1,TITLE3_1 , orderStart * 10 + 1));
                excelMap1_1.put(obj.OwnerId  + TITLE3_2, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_1,TITLE3_2 ,orderStart * 10 + 2));
                excelMap1_1.put(obj.OwnerId  + TITLE3_3, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_1,TITLE3_3 ,orderStart * 10 + 3));
                excelMap1_1.put(obj.OwnerId  + TITLE3_4, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_1,TITLE3_4 ,orderStart * 10 + 4));
                excelMap1_1.put(obj.OwnerId  + TITLE3_5, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_2,TITLE3_5 ,orderStart * 10 + 5));
                excelMap1_1.put(obj.OwnerId  + TITLE3_6, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_2,TITLE3_6 ,orderStart * 10 + 6));
                excelMap1_1.put(obj.OwnerId  + TITLE3_7, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_2,TITLE3_7 ,orderStart * 10 + 7));
                excelMap1_1.put(obj.OwnerId  + TITLE3_8, setFC(NHR_Constant.BATCHNAME_OAL,obj.Owner.LastName, TITLE2_2,TITLE3_8 ,orderStart * 10 + 8));
                excelMap.put(obj.OwnerId ,excelMap1_1);
            }
            
            FormCreation__c tempInfo = new FormCreation__c();
            if (obj.en_zyutyuukakudo__c == 'Aランク') {
                tempInfo = excelMap.get(obj.OwnerId).get(obj.OwnerId + TITLE3_6);
            } else if (obj.en_zyutyuukakudo__c == 'Bランク') {
                tempInfo = excelMap.get(obj.OwnerId).get(obj.OwnerId + TITLE3_7);
            } else if (obj.en_zyutyuukakudo__c == 'Cランク') {
                tempInfo = excelMap.get(obj.OwnerId).get(obj.OwnerId + TITLE3_8);
            }
            system.debug('tempInfo:' + tempInfo);
            
            tempInfo.D__c += 1;
            tempInfo.E__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
            tempInfo.F__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
            
            system.debug('tempInfo:' + tempInfo);

        }
    }
    
     //完了
    global void finish(Database.BatchableContext BC)
    {
        //完了後の処理があれば
        //小計
        setSum();
        
        List<FormCreation__c> insList = new List<FormCreation__c>();
        for (String keyStr : excelMap.keySet()) {
            insList.addAll(excelMap.get(keyStr).values());
        }
        insert insList;
        
        //完了後の処理があれば
        System.Queueable job = new NHR_EN_OrderExcelCreate();
        System.enqueueJob(job);

    }
    /** 
     * 集計
     */
    private void setSum(){
        FormCreation__c sum_1 = excelMap.get('Sum').get('Sum'  + TITLE3_1);
        FormCreation__c sum_2 = excelMap.get('Sum').get('Sum' + TITLE3_2);
        FormCreation__c sum_3 = excelMap.get('Sum').get('Sum' + TITLE3_3);
        FormCreation__c sum_4 = excelMap.get('Sum').get('Sum' + TITLE3_4);
        FormCreation__c sum_5 = excelMap.get('Sum').get('Sum'  + TITLE3_5);
        FormCreation__c sum_6 = excelMap.get('Sum').get('Sum' + TITLE3_6);
        FormCreation__c sum_7 = excelMap.get('Sum').get('Sum' + TITLE3_7);
        FormCreation__c sum_8 = excelMap.get('Sum').get('Sum' + TITLE3_8);
        
        for (String keyStr : excelMap.keySet()) {
            if (keyStr != 'Sum') {
                FormCreation__c tempInfo_1 = excelMap.get(keyStr).get(keyStr + TITLE3_1);
                FormCreation__c tempInfo_2 = excelMap.get(keyStr).get(keyStr + TITLE3_2);
                FormCreation__c tempInfo_3 = excelMap.get(keyStr).get(keyStr + TITLE3_3);
                FormCreation__c tempInfo_4 = excelMap.get(keyStr).get(keyStr + TITLE3_4);
                FormCreation__c tempInfo_5 = excelMap.get(keyStr).get(keyStr + TITLE3_5);
                FormCreation__c tempInfo_6 = excelMap.get(keyStr).get(keyStr + TITLE3_6);
                FormCreation__c tempInfo_7 = excelMap.get(keyStr).get(keyStr + TITLE3_7);
                FormCreation__c tempInfo_8 = excelMap.get(keyStr).get(keyStr + TITLE3_8);
                
                tempInfo_1 = set1000Tani(tempInfo_1);
                tempInfo_2 = set1000Tani(tempInfo_2);
                tempInfo_4 = set1000Tani(tempInfo_4);
                tempInfo_5 = set1000Tani(tempInfo_5);
                tempInfo_6 = set1000Tani(tempInfo_6);
                tempInfo_7 = set1000Tani(tempInfo_7);
                tempInfo_8 = set1000Tani(tempInfo_8);
                
                tempInfo_3.E__c = NHR_Dao.getDivision(tempInfo_1.E__c ,tempInfo_2.E__c);
                tempInfo_3.F__c = NHR_Dao.getDivision(tempInfo_1.F__c ,tempInfo_2.F__c);
                    
                sum_1 = setSumRow(sum_1 ,tempInfo_1);
                sum_2 = setSumRow(sum_2 ,tempInfo_2);
                sum_4 = setSumRow(sum_4 ,tempInfo_4);
                sum_5 = setSumRow(sum_5 ,tempInfo_5);
                sum_6 = setSumRow(sum_6 ,tempInfo_6);
                sum_7 = setSumRow(sum_7 ,tempInfo_7);
                sum_8 = setSumRow(sum_8 ,tempInfo_8);
            }
        }
        
        sum_3.E__c = NHR_Dao.getDivision(sum_1.E__c ,sum_2.E__c);
        sum_3.F__c = NHR_Dao.getDivision(sum_1.F__c ,sum_2.F__c);

    }
    
    private FormCreation__c setSumRow(FormCreation__c sum , FormCreation__c tempInfo){
        sum.D__c += tempInfo.D__c;
        sum.E__c += tempInfo.E__c;
        sum.F__c += tempInfo.F__c;
        return sum;
    }
    
    private FormCreation__c set1000Tani(FormCreation__c  tempInfo){
        tempInfo.E__c = tempInfo.E__c / 1000;
        tempInfo.F__c = tempInfo.F__c / 1000;
        return tempInfo;
    }
    
    /**
   * EXCEL作成
   */
    public class NHR_EN_OrderExcelCreate implements Queueable, Database.AllowsCallouts {

        public NHR_EN_OrderExcelCreate() 
        {
            
        }
        public void execute(QueueableContext context) {
            if(!Test.isRunningTest()){
                ContentVersion conObject=new ContentVersion();
                //String fileName = System.Label.Osmo_CHWSumUser + '_' + String.valueOf(Date.today()).replaceAll('-', '')  ;
                String fileName = String.valueOf(Date.today()).replaceAll('-', '');
                conObject.title = fileName + '.xls';
                conObject.PathOnClient = fileName + '.xls';
                PageReference pr = Page.NHR_EN_OrderAmountListOsaka;
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
            
            mail.setSubject('「受注追求金額一覧表_大阪」出力完了のお知らせ'); // 件名(String)
            mail.setPlainTextBody('「受注追求金額一覧表_大阪」の出力が完了いたしました。'); // 本文(String)
            mail.setEntityAttachments(new List<String>{contentId}); // 添付ファイル(Document、ContentVersion、AttachmentのIDのリスト)
            
            mail.setReplyTo(UserInfo.getUserEmail()); // 返信先メールアドレス(String)
            
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
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
}