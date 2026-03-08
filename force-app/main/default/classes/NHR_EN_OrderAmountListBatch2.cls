global without sharing class NHR_EN_OrderAmountListBatch2 implements Database.Batchable<sObject>, Database.Stateful{

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
    
    global Map<String ,FormCreation__c> excelMap1_1 {get;set;}
    global Map<String ,String> yearMap {get;set;}
    global Map<String ,EN_Report__mdt> reportMap {get;set;}
    global List<String> kanseiki {get;set;}
    global String deStr {get;set;}
    global String unitStr {get;set;}
    global String userId {get;set;}
    global NHR_EN_OrderAmountListBatch2
        (Map<String ,FormCreation__c> inExcelMap1_1
         ,Map<String ,EN_Report__mdt> inReportMap
         ,Map<String ,String> inYearMap
         ,List<String> inKanseiki
         ,String inDeStr
         ,String inUnit
         ,String userId)
    {
        this.excelMap1_1 = inExcelMap1_1;
        this.reportMap = inReportMap;
        this.yearMap = inYearMap;
        this.kanseiki = inKanseiki;
        this.deStr = inDeStr;
        this.unitStr = inUnit;
        this.userId = userId;
    }
    
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_EN_OrderAmountListBatch2');

        Set<String> tantobusyo = reportMap.keySet();
        system.debug('tantobusyo:' + tantobusyo);
        system.debug('kanseiki:' + kanseiki);
    	String query = NHR_Dao.get_NHR_EN_OrderAmountListBatch2(this.unitStr ,this.userId);
        return Database.getQueryLocator(query);
    }
    
    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){
        for(Opportunity obj : scopes) {
            FormCreation__c tempInfo = new FormCreation__c();
            
            if (this.unitStr == NHR_Constant.UNIT1) {
                String tantobusyoStr = obj.Department__c;
                if (tantobusyoStr == '営業部') {
                    tantobusyoStr = '営業第一チーム';
                }
                //営業所単位
                if (obj.en_zyutyuukakudo__c == 'Aランク') {
                    tempInfo = excelMap1_1.get(tantobusyoStr + TITLE3_6);
                } else if (obj.en_zyutyuukakudo__c == 'Bランク') {
                    tempInfo = excelMap1_1.get(tantobusyoStr + TITLE3_7);
                } else if (obj.en_zyutyuukakudo__c == 'Cランク') {
                    tempInfo = excelMap1_1.get(tantobusyoStr + TITLE3_8);
                }
            } else if (this.unitStr == NHR_Constant.UNIT2) {
                //チーム単位
                if (!excelMap1_1.containsKey(obj.OwnerId + TITLE3_1)) {
                    integer orderStart = excelMap1_1.size() / 8;
                    excelMap1_1.put(obj.OwnerId + TITLE3_1, setFC('OrderAmountList',obj.Owner.Name, TITLE2_1 , TITLE3_1 ,Integer.valueOf(orderStart * 10 + 1)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_2, setFC('OrderAmountList',obj.Owner.Name, TITLE2_1 , TITLE3_2 ,Integer.valueOf(orderStart * 10 + 2)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_3, setFC('OrderAmountList',obj.Owner.Name, TITLE2_1 , TITLE3_3 ,Integer.valueOf(orderStart * 10 + 3)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_4, setFC('OrderAmountList',obj.Owner.Name, TITLE2_1 , TITLE3_4 ,Integer.valueOf(orderStart * 10 + 4)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_5, setFC('OrderAmountList',obj.Owner.Name, TITLE2_2 , TITLE3_5 ,Integer.valueOf(orderStart * 10 + 5)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_6, setFC('OrderAmountList',obj.Owner.Name, TITLE2_2 , TITLE3_6 ,Integer.valueOf(orderStart * 10 + 6)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_7, setFC('OrderAmountList',obj.Owner.Name, TITLE2_2 , TITLE3_7 ,Integer.valueOf(orderStart * 10 + 7)  ));
                    excelMap1_1.put(obj.OwnerId + TITLE3_8, setFC('OrderAmountList',obj.Owner.Name, TITLE2_2 , TITLE3_8 ,Integer.valueOf(orderStart * 10 + 8)  ));
                }
                if (obj.en_zyutyuukakudo__c == 'Aランク') {
                    tempInfo = excelMap1_1.get(obj.OwnerId + TITLE3_6);
                } else if (obj.en_zyutyuukakudo__c == 'Bランク') {
                    tempInfo = excelMap1_1.get(obj.OwnerId + TITLE3_7);
                } else if (obj.en_zyutyuukakudo__c == 'Cランク') {
                    tempInfo = excelMap1_1.get(obj.OwnerId + TITLE3_8);
                }
            } else if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
                //個人単位
                if (!excelMap1_1.containsKey(obj.AccountId + TITLE3_1)) {
                    integer orderStart = excelMap1_1.size() / 8;
                    excelMap1_1.put(obj.AccountId + TITLE3_1, setFC('OrderAmountList' + this.userId,obj.Account.Name, TITLE2_1 , TITLE3_1 ,Integer.valueOf(orderStart * 10 + 1)  ));
                    excelMap1_1.put(obj.AccountId + TITLE3_2, setFC('OrderAmountList' + this.userId,obj.Account.Name, TITLE2_1 , TITLE3_2 ,Integer.valueOf(orderStart * 10 + 2)  ));
                    excelMap1_1.put(obj.AccountId + TITLE3_3, setFC('OrderAmountList' + this.userId,obj.Account.Name, TITLE2_1 , TITLE3_3 ,Integer.valueOf(orderStart * 10 + 3)  ));
                    excelMap1_1.put(obj.AccountId + TITLE3_4, setFC('OrderAmountList' + this.userId,obj.Account.Name, TITLE2_1 , TITLE3_4 ,Integer.valueOf(orderStart * 10 + 4)  ));
                    excelMap1_1.put(obj.AccountId + TITLE3_5, setFC('OrderAmountList' + this.userId,obj.Account.Name, TITLE2_2 , TITLE3_5 ,Integer.valueOf(orderStart * 10 + 5)  ));
                    excelMap1_1.put(obj.AccountId + TITLE3_6, setFC('OrderAmountList' + this.userId,obj.Account.Name, TITLE2_2 , TITLE3_6 ,Integer.valueOf(orderStart * 10 + 6)  ));
                    excelMap1_1.put(obj.AccountId + TITLE3_7, setFC('OrderAmountList' + this.userId,obj.Account.Name, TITLE2_2 , TITLE3_7 ,Integer.valueOf(orderStart * 10 + 7)  ));
                    excelMap1_1.put(obj.AccountId + TITLE3_8, setFC('OrderAmountList' + this.userId,obj.Account.Name, TITLE2_2 , TITLE3_8 ,Integer.valueOf(orderStart * 10 + 8)  ));
                }
                if (obj.en_zyutyuukakudo__c == 'Aランク') {
                    tempInfo = excelMap1_1.get(obj.AccountId + TITLE3_6);
                } else if (obj.en_zyutyuukakudo__c == 'Bランク') {
                    tempInfo = excelMap1_1.get(obj.AccountId + TITLE3_7);
                } else if (obj.en_zyutyuukakudo__c == 'Cランク') {
                    tempInfo = excelMap1_1.get(obj.AccountId + TITLE3_8);
                }
            }

            if(!Test.isRunningTest()){
                if (obj.EN_kanseiki__c == kanseiki[0]) {
                    //今期
                    tempInfo.E__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempInfo.F__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                } else if (obj.EN_kanseiki__c == kanseiki[1]) {
                    //来期
                    tempInfo.G__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempInfo.H__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                } else {
                    //来期以降
                    tempInfo.I__c += (obj.en_zyutyuumokuhyougaku__c == null ? 0 : obj.en_zyutyuumokuhyougaku__c);
                    tempInfo.J__c += (obj.en_mokuhyouriekigaku__c == null ? 0 : obj.en_mokuhyouriekigaku__c);
                }
            }
        }
    }
    
     //完了
    global void finish(Database.BatchableContext BC)
    {
        //完了後の処理があれば
        //小計
        setSum();

        for (FormCreation__c objt : excelMap1_1.values()) {
            system.debug(objt);
        }
        insert excelMap1_1.values();
        
        //完了後の処理があれば
        System.Queueable job = new NHR_EN_OrderExcelCreate(deStr, userId);
        System.enqueueJob(job);

    }
    /** 
     * 集計
     */
    private void setSum(){
        FormCreation__c sum_5 = new FormCreation__c();
        FormCreation__c sum_6 = new FormCreation__c();
        FormCreation__c sum_7 = new FormCreation__c();
        FormCreation__c sum_8 = new FormCreation__c();
        if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
            sum_5 = excelMap1_1.get('Sum' + this.userId + TITLE3_5);
            sum_6 = excelMap1_1.get('Sum' + this.userId + TITLE3_6);
            sum_7 = excelMap1_1.get('Sum' + this.userId + TITLE3_7);
            sum_8 = excelMap1_1.get('Sum' + this.userId + TITLE3_8);
        } else {
            sum_5 = excelMap1_1.get('Sum'  + TITLE3_5);
            sum_6 = excelMap1_1.get('Sum' + TITLE3_6);
            sum_7 = excelMap1_1.get('Sum' + TITLE3_7);
            sum_8 = excelMap1_1.get('Sum' + TITLE3_8);
        }
        
        for (String keyStr : excelMap1_1.KeySet()) {
            FormCreation__c tempObj = excelMap1_1.get(keyStr);
            if ( !keyStr.contains('Sum') && keyStr.contains(TITLE3_5)) {
                String subKey = keyStr.replace(TITLE3_5 , '');
                FormCreation__c tempInfo_5 = excelMap1_1.get(subKey + TITLE3_5);
                FormCreation__c tempInfo_6 = excelMap1_1.get(subKey + TITLE3_6);
                FormCreation__c tempInfo_7 = excelMap1_1.get(subKey + TITLE3_7);
                FormCreation__c tempInfo_8 = excelMap1_1.get(subKey + TITLE3_8);
                
                tempInfo_6.K__c = tempInfo_6.E__c + tempInfo_6.G__c + tempInfo_6.I__c;
                tempInfo_6.L__c = tempInfo_6.F__c + tempInfo_6.H__c + tempInfo_6.J__c;
                
                tempInfo_7.K__c = tempInfo_7.E__c + tempInfo_7.G__c + tempInfo_7.I__c;
                tempInfo_7.L__c = tempInfo_7.F__c + tempInfo_7.H__c + tempInfo_7.J__c;
                
                tempInfo_8.K__c = tempInfo_8.E__c + tempInfo_8.G__c + tempInfo_8.I__c;
                tempInfo_8.L__c = tempInfo_8.F__c + tempInfo_8.H__c + tempInfo_8.J__c;
                
                tempInfo_5.E__c = tempInfo_6.E__c  + tempInfo_7.E__c + tempInfo_8.E__c;
                tempInfo_5.F__c = tempInfo_6.F__c  + tempInfo_7.F__c + tempInfo_8.F__c;
                tempInfo_5.G__c = tempInfo_6.G__c  + tempInfo_7.G__c + tempInfo_8.G__c;
                tempInfo_5.H__c = tempInfo_6.H__c  + tempInfo_7.H__c + tempInfo_8.H__c;
                tempInfo_5.I__c = tempInfo_6.I__c  + tempInfo_7.I__c + tempInfo_8.I__c;
                tempInfo_5.J__c = tempInfo_6.J__c  + tempInfo_7.J__c + tempInfo_8.J__c;
                tempInfo_5.K__c = tempInfo_6.K__c  + tempInfo_7.K__c + tempInfo_8.K__c;
                tempInfo_5.L__c = tempInfo_6.L__c  + tempInfo_7.L__c + tempInfo_8.L__c;
                
                sum_5 = setSumRow(sum_5 ,tempInfo_5);
                sum_6 = setSumRow(sum_6 ,tempInfo_6);
                sum_7 = setSumRow(sum_7 ,tempInfo_7);
                sum_8 = setSumRow(sum_8 ,tempInfo_8);
            }
        }
        /*
        List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
        for(EN_Report__mdt mt : md2) {
            FormCreation__c tempInfo_5 = excelMap1_1.get(mt.Department__c + TITLE3_5);
            FormCreation__c tempInfo_6 = excelMap1_1.get(mt.Department__c + TITLE3_6);
            FormCreation__c tempInfo_7 = excelMap1_1.get(mt.Department__c + TITLE3_7);
            FormCreation__c tempInfo_8 = excelMap1_1.get(mt.Department__c + TITLE3_8);

            tempInfo_6.K__c = tempInfo_6.E__c + tempInfo_6.G__c + tempInfo_6.I__c;
            tempInfo_6.L__c = tempInfo_6.F__c + tempInfo_6.H__c + tempInfo_6.J__c;
            
            tempInfo_7.K__c = tempInfo_7.E__c + tempInfo_7.G__c + tempInfo_7.I__c;
            tempInfo_7.L__c = tempInfo_7.F__c + tempInfo_7.H__c + tempInfo_7.J__c;
            
            tempInfo_8.K__c = tempInfo_8.E__c + tempInfo_8.G__c + tempInfo_8.I__c;
            tempInfo_8.L__c = tempInfo_8.F__c + tempInfo_8.H__c + tempInfo_8.J__c;
            
            tempInfo_5.E__c = tempInfo_6.E__c  + tempInfo_7.E__c + tempInfo_8.E__c;
            tempInfo_5.F__c = tempInfo_6.F__c  + tempInfo_7.F__c + tempInfo_8.F__c;
            tempInfo_5.G__c = tempInfo_6.G__c  + tempInfo_7.G__c + tempInfo_8.G__c;
            tempInfo_5.H__c = tempInfo_6.H__c  + tempInfo_7.H__c + tempInfo_8.H__c;
            tempInfo_5.I__c = tempInfo_6.I__c  + tempInfo_7.I__c + tempInfo_8.I__c;
            tempInfo_5.J__c = tempInfo_6.J__c  + tempInfo_7.J__c + tempInfo_8.J__c;
            tempInfo_5.K__c = tempInfo_6.K__c  + tempInfo_7.K__c + tempInfo_8.K__c;
            tempInfo_5.L__c = tempInfo_6.L__c  + tempInfo_7.L__c + tempInfo_8.L__c;
            
            sum_5 = setSumRow(sum_5 ,tempInfo_5);
            sum_6 = setSumRow(sum_6 ,tempInfo_6);
            sum_7 = setSumRow(sum_7 ,tempInfo_7);
            sum_8 = setSumRow(sum_8 ,tempInfo_8);
            
            excelMap1_1.put(mt.Department__c + TITLE3_5 ,tempInfo_5);
            excelMap1_1.put(mt.Department__c + TITLE3_6 ,tempInfo_6);
            excelMap1_1.put(mt.Department__c + TITLE3_7 ,tempInfo_7);
            excelMap1_1.put(mt.Department__c + TITLE3_8 ,tempInfo_8);
        }*/

        /*
        excelMap1_1.put('Sum' + TITLE3_5 ,sum_5);
        excelMap1_1.put('Sum' + TITLE3_6 ,sum_6);
        excelMap1_1.put('Sum' + TITLE3_7 ,sum_7);
        excelMap1_1.put('Sum' + TITLE3_8 ,sum_8);
        */
        
        for (String key : excelMap1_1.keySet()) {
            FormCreation__c  tempInfo = excelMap1_1.get(key);
            if (tempInfo.Title3__c != TITLE3_3) {
                tempInfo = set1000Tani(tempInfo);
                excelMap1_1.put(key ,tempInfo);
            }
            
        }
    }
    
    private FormCreation__c setSumRow(FormCreation__c sum , FormCreation__c tempInfo){
        sum.E__c += tempInfo.E__c;
        sum.F__c += tempInfo.F__c;
        sum.G__c += tempInfo.G__c;
        sum.H__c += tempInfo.H__c;
        sum.I__c += tempInfo.I__c;
        sum.J__c += tempInfo.J__c;
        sum.K__c += tempInfo.K__c;
        sum.L__c += tempInfo.L__c;
        return sum;
    }
    
    private FormCreation__c set1000Tani(FormCreation__c  tempInfo){
        tempInfo.E__c = tempInfo.E__c / 1000;
        tempInfo.F__c = tempInfo.F__c / 1000;
        tempInfo.G__c = tempInfo.G__c / 1000;
        tempInfo.H__c = tempInfo.H__c / 1000;
        tempInfo.I__c = tempInfo.I__c / 1000;
        tempInfo.J__c = tempInfo.J__c / 1000;
        tempInfo.K__c = tempInfo.K__c / 1000;
        tempInfo.L__c = tempInfo.L__c / 1000;
        return tempInfo;
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
    public class NHR_EN_OrderExcelCreate implements Queueable, Database.AllowsCallouts {
        public String deStr ;
        public String userId ;
        public NHR_EN_OrderExcelCreate(String inDeStr ,String inUserId)
        {
            deStr = inDeStr;
            userId = inUserId;
        }
        
        public void execute(QueueableContext context) {
            Map<String, String> deMap = new Map<String, String>();
            deMap.put('全社','zensya');
            deMap.put('全社','zensya');
            deMap.put('東京','honsya');
            deMap.put('大阪','osaka');
            deMap.put('営業第一チーム','tokyoTeams1');
            deMap.put('営業第二チーム','tokyoTeams2');
            deMap.put('大阪営業部','osakaTeams');
            if(!Test.isRunningTest()){
                ContentVersion conObject=new ContentVersion();
                //String fileName = System.Label.Osmo_CHWSumUser + '_' + String.valueOf(Date.today()).replaceAll('-', '')  ;
                String fileSubName = '';
                
                if (String.isNotBlank(userId) ){
                    String userName = NHR_Dao.getUserInfo(userId).Username;
                    fileSubName = '_' + userName.left(userName.indexOf('@')) ;
                }
                if (deMap.containsKey(deStr) ){fileSubName +=  '_' + deMap.get(deStr);}
                String fileName = String.valueOf(Date.today()).replaceAll('-', '')+ fileSubName;
                conObject.title = fileName + '.xls';
                conObject.PathOnClient = fileName + '.xls';
                PageReference pr = Page.NHR_EN_OrderAmountList;
                pr.getParameters().put('kubun', deStr);
                pr.getParameters().put('userId', userId);
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
            
            mail.setSubject('【' + '受注追求金額一覧表' +'】作成完了'); // 件名(String)
            mail.setPlainTextBody('受注追求金額一覧表' + 'が作成完了しまして、ご確認をお願いします。'); // 本文(String)
            mail.setEntityAttachments(new List<String>{contentId}); // 添付ファイル(Document、ContentVersion、AttachmentのIDのリスト)
            
            mail.setReplyTo(UserInfo.getUserEmail()); // 返信先メールアドレス(String)
            
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
    }
}