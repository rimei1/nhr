/*
*工種別完工高一覧表
*/
global without sharing class NHR_EN_ConOppOrderBatch implements Database.Batchable<sObject>, Database.Stateful{

    global String deStr {get;set;}
    global String unitStr {get;set;}
    global String userId {get;set;}
    global Date startDate {get;set;}
    global Date endDate {get;set;}
    //global Map<String ,FormCreation__c> excelMap1_1 {get;set;}
    global Map<String ,Map<String ,FormCreation__c>> excelMap {get;set;}
    global Map<String ,String> yearMap {get;set;}
    global Map<String ,EN_Report__mdt> reportMap {get;set;}
    global String kanseiki {get;set;}
    global String thisFiscalYear {get;set;}
    global NHR_EN_ConOppOrderBatch(String inDeStr ,String inUnit ,String userId){
        this.deStr = inDeStr;
        this.unitStr = inUnit;
        this.userId = userId;
    }
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_EN_ConOppOrderBatch');
        setInit();

        Set<String> tantobusyo = reportMap.keySet();
        system.debug('startDate:' + startDate);
        system.debug('endDate:' + endDate);
    	String query = NHR_Dao.get_NHR_EN_ConOppOrderBatch(unitStr ,userId);
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){
        for(Opportunity obj : scopes) {

            if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
                if (!excelMap.containsKey(obj.AccountId)) {
                    Map<String ,FormCreation__c> excelMap1_1 = new Map<String ,FormCreation__c>();
                    integer orderStart = excelMap.size();
                    excelMap1_1.put(obj.AccountId + '_1', setFC(NHR_Constant.BATCHNAME_COO + this.userId,obj.Account.Name, NHR_Constant.CON1 , orderStart * 10 + 1));
                    excelMap1_1.put(obj.AccountId + '_2', setFC(NHR_Constant.BATCHNAME_COO + this.userId,obj.Account.Name, NHR_Constant.CON2 ,orderStart * 10 + 2));
                    excelMap1_1.put(obj.AccountId + '_3', setFC(NHR_Constant.BATCHNAME_COO + this.userId,obj.Account.Name, NHR_Constant.CON3 ,orderStart * 10 + 3));
                    excelMap1_1.put(obj.AccountId + '_4', setFC(NHR_Constant.BATCHNAME_COO + this.userId,obj.Account.Name, NHR_Constant.CON_OTHER ,orderStart * 10 + 4));
                    excelMap1_1.put(obj.AccountId + '_9', setFC(NHR_Constant.BATCHNAME_COO + this.userId,obj.Account.Name, NHR_Constant.TOTAL ,orderStart * 10 + 9));
                    excelMap.put(obj.AccountId ,excelMap1_1);
                }
            } else {
                if (!excelMap.containsKey(obj.AccountId)) {
                    Map<String ,FormCreation__c> excelMap1_1 = new Map<String ,FormCreation__c>();
                    integer orderStart = excelMap.size();
                    excelMap1_1.put(obj.AccountId + '_1', setFC(NHR_Constant.BATCHNAME_COO,obj.Account.Name, NHR_Constant.CON1 , orderStart * 10 + 1));
                    excelMap1_1.put(obj.AccountId + '_2', setFC(NHR_Constant.BATCHNAME_COO,obj.Account.Name, NHR_Constant.CON2 ,orderStart * 10 + 2));
                    excelMap1_1.put(obj.AccountId + '_3', setFC(NHR_Constant.BATCHNAME_COO,obj.Account.Name, NHR_Constant.CON3 ,orderStart * 10 + 3));
                    excelMap1_1.put(obj.AccountId + '_4', setFC(NHR_Constant.BATCHNAME_COO,obj.Account.Name, NHR_Constant.CON_OTHER ,orderStart * 10 + 4));
                    excelMap1_1.put(obj.AccountId + '_9', setFC(NHR_Constant.BATCHNAME_COO,obj.Account.Name, NHR_Constant.TOTAL ,orderStart * 10 + 9));
                    excelMap.put(obj.AccountId ,excelMap1_1);
                }
            }


            FormCreation__c tempInfo1 = excelMap.get(obj.AccountId).get(obj.AccountId + '_1');
            FormCreation__c tempInfo2 = excelMap.get(obj.AccountId).get(obj.AccountId + '_2');
            FormCreation__c tempInfo3 = excelMap.get(obj.AccountId).get(obj.AccountId + '_3');
            FormCreation__c tempInfo4 = excelMap.get(obj.AccountId).get(obj.AccountId + '_4');
            FormCreation__c tempInfo9 = excelMap.get(obj.AccountId).get(obj.AccountId + '_9');
            FormCreation__c sum1 = excelMap.get('Sum').get('Sum_1');
            FormCreation__c sum2 = excelMap.get('Sum').get('Sum_2');
            FormCreation__c sum3 = excelMap.get('Sum').get('Sum_3');
            FormCreation__c sum4 = excelMap.get('Sum').get('Sum_4');
            FormCreation__c sum9 = excelMap.get('Sum').get('Sum_9');

            String theYear = NHR_Dao.getFiscalYear(obj.en_ukeoisyunkouyoteibi__c) ;
            Integer theMonth = obj.en_ukeoisyunkouyoteibi__c.month();
            if (theYear == thisFiscalYear) {
                if (obj.en_koujihinsyu__c == NHR_Constant.CON1) {
                    setFCDetail(tempInfo1 ,obj ,theMonth);
                    setFCDetail(sum1 ,obj ,theMonth);
                } else if (obj.en_koujihinsyu__c == NHR_Constant.CON2) {
                    setFCDetail(tempInfo2 ,obj ,theMonth);
                    setFCDetail(sum2 ,obj ,theMonth);
                } else if (obj.en_koujihinsyu__c == NHR_Constant.CON3) {
                    setFCDetail(tempInfo3 ,obj ,theMonth);
                    setFCDetail(sum3 ,obj ,theMonth);
                } else {
                    setFCDetail(tempInfo4 ,obj ,theMonth);
                    setFCDetail(sum4 ,obj ,theMonth);
                }
                setFCDetail(tempInfo9 ,obj ,theMonth);
                setFCDetail(sum9 ,obj ,theMonth);
            } else {
                if (obj.en_koujihinsyu__c == NHR_Constant.CON1) {
                    tempInfo1.AB__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                    tempInfo1.AC__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                    sum1.AB__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                    sum1.AC__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
                } else if (obj.en_koujihinsyu__c == NHR_Constant.CON2) {
                    tempInfo2.AB__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                    tempInfo2.AC__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                    sum2.AB__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                    sum2.AC__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
                } else if (obj.en_koujihinsyu__c == NHR_Constant.CON3) {
                    tempInfo3.AB__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                    tempInfo3.AC__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                    sum3.AB__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                    sum3.AC__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
                } else {
                    tempInfo4.AB__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                    tempInfo4.AC__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                    sum4.AB__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                    sum4.AC__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
                }
                tempInfo9.AB__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempInfo9.AC__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);

                sum9.AB__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                sum9.AC__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        setSum();
        //完了後の処理があれば
        List<FormCreation__c> insList = new List<FormCreation__c>();
        for (String keyStr : excelMap.keySet()) {
            insList.addAll(excelMap.get(keyStr).values());
        }
        insert insList;


        //完了後の処理があれば
        System.Queueable job = new NHR_EN_ConOppOrderExcelCreate(deStr , userId);
        System.enqueueJob(job);
    }

    /**
     * 集計
     */
    private void setSum(){
        for (String keyStr : excelMap.keySet()) {
            FormCreation__c tempInfo_1 = excelMap.get(keyStr).get(keyStr + '_1');
            FormCreation__c tempInfo_2 = excelMap.get(keyStr).get(keyStr + '_2');
            FormCreation__c tempInfo_3 = excelMap.get(keyStr).get(keyStr + '_3');
            FormCreation__c tempInfo_4 = excelMap.get(keyStr).get(keyStr + '_4');
            FormCreation__c tempInfo_9 = excelMap.get(keyStr).get(keyStr + '_9');

            tempInfo_1 = set1000Tani(tempInfo_1);
            tempInfo_2 = set1000Tani(tempInfo_2);
            tempInfo_3 = set1000Tani(tempInfo_3);
            tempInfo_4 = set1000Tani(tempInfo_4);
            tempInfo_9 = set1000Tani(tempInfo_9);
        }
    }

    private FormCreation__c set1000Tani(FormCreation__c  tempInfo){
        tempInfo.B__c = tempInfo.B__c / 1000;
        tempInfo.C__c = tempInfo.C__c / 1000;
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
        tempInfo.U__c = tempInfo.U__c / 1000;
        tempInfo.V__c = tempInfo.V__c / 1000;
        tempInfo.W__c = tempInfo.W__c / 1000;
        tempInfo.X__c = tempInfo.X__c / 1000;
        tempInfo.Y__c = tempInfo.Y__c / 1000;
        tempInfo.Z__c = tempInfo.Z__c / 1000;
        tempInfo.AA__c = tempInfo.AA__c / 1000;
        tempInfo.AB__c = tempInfo.AB__c / 1000;
        tempInfo.AC__c = tempInfo.AC__c / 1000;
        return tempInfo;
    }

    /**
     * 初期設定
     */
    private void setInit(){
        //日付設定
        Date theToday = Date.Today();
        Date forGetDay = Date.Today();
        if (theToday.month() == 7) {
            forGetDay = theToday.addMonths(-1);
        }

        startDate = NHR_Dao.getFiscalYearStartDate(forGetDay.addYears(-1));
        endDate = NHR_Dao.getFiscalYearEndDate(forGetDay);
        thisFiscalYear = NHR_Dao.getFiscalYear(forGetDay);

        //表示内容設定
        yearMap = new Map<String ,String>();
        reportMap = new Map<String ,EN_Report__mdt>();
        Map<String ,FormCreation__c> excelMap1_1 = new Map<String ,FormCreation__c>();
        excelMap = new Map<String ,Map<String ,FormCreation__c>>();

        // 会年度取得
        List<EN_FiscalYear__mdt> md1 = EN_FiscalYear__mdt.getAll().Values();
        for(EN_FiscalYear__mdt mt : md1) {
            yearMap.put(mt.Year__c ,mt.Period__c);
        }

        //出力部署単位
        List<EN_Report__mdt> md2 = EN_Report__mdt.getAll().Values();
        for(EN_Report__mdt mt : md2) {
            if (deStr == NHR_Constant.ZENSHYA || mt.MasterLabel == deStr ) {
                reportMap.put(mt.Department__c ,mt);
                if (this.deStr == '営業第一チーム') {
                    reportMap.put('営業部' ,mt);
                }
            }
        }
        //合計行追加
        if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
            excelMap1_1.put('Sum_1' , setFC(NHR_Constant.BATCHNAME_COO + this.userId,NHR_Constant.TOTAL ,NHR_Constant.CON1 ,9901));
            excelMap1_1.put('Sum_2' , setFC(NHR_Constant.BATCHNAME_COO + this.userId,NHR_Constant.TOTAL ,NHR_Constant.CON2 ,9902));
            excelMap1_1.put('Sum_3' , setFC(NHR_Constant.BATCHNAME_COO + this.userId,NHR_Constant.TOTAL ,NHR_Constant.CON3 ,9903));
            excelMap1_1.put('Sum_4' , setFC(NHR_Constant.BATCHNAME_COO + this.userId,NHR_Constant.TOTAL ,NHR_Constant.CON_OTHER ,9904));
            excelMap1_1.put('Sum_9' , setFC(NHR_Constant.BATCHNAME_COO + this.userId,NHR_Constant.TOTAL ,NHR_Constant.TOTAL ,9909));
        } else {
            excelMap1_1.put('Sum_1' , setFC(NHR_Constant.BATCHNAME_COO,NHR_Constant.TOTAL ,NHR_Constant.CON1 ,9901));
            excelMap1_1.put('Sum_2' , setFC(NHR_Constant.BATCHNAME_COO,NHR_Constant.TOTAL ,NHR_Constant.CON2 ,9902));
            excelMap1_1.put('Sum_3' , setFC(NHR_Constant.BATCHNAME_COO,NHR_Constant.TOTAL ,NHR_Constant.CON3 ,9903));
            excelMap1_1.put('Sum_4' , setFC(NHR_Constant.BATCHNAME_COO,NHR_Constant.TOTAL ,NHR_Constant.CON_OTHER ,9904));
            excelMap1_1.put('Sum_9' , setFC(NHR_Constant.BATCHNAME_COO,NHR_Constant.TOTAL ,NHR_Constant.TOTAL ,9909));
        }

        excelMap.put('Sum' ,excelMap1_1);

    }

    private FormCreation__c setFCDetail(FormCreation__c tempObj ,Opportunity obj , integer theMonth){
        switch on theMonth {
            when 1 {
                tempObj.P__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempObj.Q__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
            when 2 {
                tempObj.R__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempObj.S__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
            when 3 {
                tempObj.T__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempObj.U__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
            when 4 {
                tempObj.V__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempObj.W__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
            when 5 {
                tempObj.X__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempObj.Z__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
            when 6 {
                tempObj.Z__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempObj.AA__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
            when 7 {
                tempObj.D__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempObj.E__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
            when 8 {
                tempObj.F__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempObj.G__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
            when 9 {
                tempObj.H__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempObj.I__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
            when 10 {
                tempObj.J__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempObj.K__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
            when 11 {
                tempObj.L__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempObj.M__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
            when 12 {
                tempObj.N__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
                tempObj.O__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
            }
        }

        //tempObj.AB__c += (obj.EN_saisyuzyutyuukingaku__c == null ? 0 : obj.EN_saisyuzyutyuukingaku__c);
        //tempObj.AC__c += (obj.EN_saisyuzyutyukingaku__c == null ? 0 : obj.EN_saisyuzyutyukingaku__c);
        return tempObj;
    }

    private FormCreation__c setFC(String Name , String Title1 ,String Title2 ,integer orderBy){
        FormCreation__c rec = new FormCreation__c();
        rec.Name = Name;
        rec.Title1__c = Title1;
        rec.Title2__c = Title2;
        //rec.Title3__c = Title3;
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
        rec.X__c = 0;
        rec.Y__c = 0;
        rec.Z__c = 0;
        rec.AA__c = 0;
        rec.AB__c = 0;
        rec.AC__c = 0;

        return rec;
    }

    /**
   * EXCEL作成
   */
    public class NHR_EN_ConOppOrderExcelCreate implements Queueable, Database.AllowsCallouts {
        public String deStr ;
        public String userId ;
        public NHR_EN_ConOppOrderExcelCreate(String inDeStr,String inUserId)
        {
            deStr = inDeStr;
            userId = inUserId;
        }
        public void execute(QueueableContext context) {
            Map<String, String> deMap = new Map<String, String>();
            deMap.put('全社','zensya');
            deMap.put('東京','honsya');
            deMap.put('大阪','osaka');
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
                PageReference pr = Page.NHR_EN_ConOppOrder;
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

            mail.setSubject('「工種別完工高一覧」出力完了のお知らせ'); // 件名(String)
            mail.setPlainTextBody('「工種別完工高一覧」の出力が完了いたしました。'); // 本文(String)
            mail.setEntityAttachments(new List<String>{contentId}); // 添付ファイル(Document、ContentVersion、AttachmentのIDのリスト)

            mail.setReplyTo(UserInfo.getUserEmail()); // 返信先メールアドレス(String)

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
    }
}