global without sharing class NHR_EN_SalesReviewMeetingBatch2 implements Database.Batchable<sObject>, Database.Stateful{

    global String deStr {get;set;}
    global String unitStr {get;set;}
    global String userId {get;set;}
    global Date startDate {get;set;}
    global Date endDate {get;set;}
    global Date LastMonthStartDate {get;set;}
    global Date forGetDay {get;set;}
    global Date LastForGetDay {get;set;}
    global Map<String ,FormCreation__c> excelMap1 {get;set;}
    global Map<String ,FormCreation__c> excelMap2 {get;set;}
    global Map<String ,FormCreation__c> excelMap3 {get;set;}
    //global Map<String ,Map<String ,FormCreation__c>> excelMap {get;set;}
    global Map<String ,String> yearMap {get;set;}
    global Map<String ,EN_Report__mdt> reportMap {get;set;}
    global String kanseiki {get;set;}
    global String thisFiscalYear {get;set;}
    global NHR_EN_SalesReviewMeetingBatch2
        (
            Map<String ,FormCreation__c> inExcelMap1,
            Map<String ,FormCreation__c> inExcelMap2,
            Map<String ,FormCreation__c> inExcelMap3,
            Map<String ,String> inYearMap,
            Map<String ,EN_Report__mdt> inReportMap,
            Date inStartDate,
            Date inEndDate,
            Date inLastMonthStartDate,
            Date inForGetDay,
            String inDeStr,
            String inUnit,
            String userId
        ){
            this.excelMap1 = inExcelMap1;
            this.excelMap2 = inExcelMap2;
            this.excelMap3 = inExcelMap3;
            this.yearMap = inYearMap;
            this.reportMap = inReportMap;
            this.startDate = inStartDate;
            this.endDate = inEndDate;
            this.LastMonthStartDate = inLastMonthStartDate;
            this.forGetDay = inForGetDay;
            this.deStr = inDeStr;
            this.unitStr = inUnit;
            this.userId = userId;
    }
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_EN_SalesReviewMeetingBatch2');

        Set<String> tantobusyo = reportMap.keySet();
        LastForGetDay = forGetDay.addMonths(-1);
        system.debug('startDate:' + startDate);
        system.debug('endDate:' + endDate);
    	String query = NHR_Dao.get_NHR_EN_SalesReviewMeetingEY(unitStr,userId);
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<en_yojitsu__c> scopes){
        FormCreation__c sum1_1 = new FormCreation__c();

        FormCreation__c sum2_1 = new FormCreation__c();
        FormCreation__c sum2_2 = new FormCreation__c();
        FormCreation__c sum2_3 = new FormCreation__c();
        FormCreation__c sum2_4 = new FormCreation__c();
        FormCreation__c sum2_9 = new FormCreation__c();
        if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
            sum1_1 = excelMap1.get('Sum'+ this.userId);
            
            sum2_1 = excelMap2.get('Sum_1'+ this.userId);
            sum2_2 = excelMap2.get('Sum_2'+ this.userId);
            sum2_3 = excelMap2.get('Sum_3'+ this.userId);
            sum2_4 = excelMap2.get('Sum_4'+ this.userId);
            sum2_9 = excelMap2.get('Sum_9'+ this.userId);
        } else {
            sum1_1 = excelMap1.get('Sum');
            
            sum2_1 = excelMap2.get('Sum_1');
            sum2_2 = excelMap2.get('Sum_2');
            sum2_3 = excelMap2.get('Sum_3');
            sum2_4 = excelMap2.get('Sum_4');
            sum2_9 = excelMap2.get('Sum_9');
        }

        for(en_yojitsu__c obj : scopes) {
            if (!excelMap1.containsKey(obj.en_tokuisaki_s__c)) {
                integer orderStart = excelMap1.size();
                if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
                    excelMap1.put(obj.en_tokuisaki_s__c ,setFC(NHR_Constant.BATCHNAME_SRM1+ this.userId, obj.en_tokuisaki_s__r.Name , '' , orderStart * 10 + 1));
                } else {
                    excelMap1.put(obj.en_tokuisaki_s__c ,setFC(NHR_Constant.BATCHNAME_SRM1, obj.en_tokuisaki_s__r.Name , '' , orderStart * 10 + 1));
                }
                
            }

            FormCreation__c tempInfo1 = excelMap1.get(obj.en_tokuisaki_s__c);

            String theYear = NHR_Dao.getFiscalYear(obj.Yeaemonth__c) ;

            setFCDetail(tempInfo1 , obj);
            if (obj.en_koujihinsyu__c == NHR_Constant.CON1) {
                setFCDetail(sum2_1 , obj);
            } else if (obj.en_koujihinsyu__c == NHR_Constant.CON2) {
                setFCDetail(sum2_2 , obj);
            } else if (obj.en_koujihinsyu__c == NHR_Constant.CON3) {
                setFCDetail(sum2_3 , obj);
            } else {
                setFCDetail(sum2_4 , obj);
            }

        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        setSum1();
        setSum2();
        setSum3();
        //完了後の処理があれば
        insert excelMap1.values();
        insert excelMap2.values();
        insert excelMap3.values();


        //完了後の処理があれば
        System.Queueable job = new NHR_EN_SalesReviewMeetingExcelCreate(deStr, userId);
        System.enqueueJob(job);
    }

    /**
     * 集計
     */
    private void setSum1(){
        FormCreation__c sum = new FormCreation__c();
        if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
            sum = excelMap1.get('Sum'+ this.userId);
        } else {
            sum = excelMap1.get('Sum');
        }

        for (String keyStr : excelMap1.keySet()) {
            system.debug('keyStr:' + keyStr);
            if (String.isBlank(keyStr) || !keyStr.contains('Sum')) {
                FormCreation__c tempInfo = excelMap1.get(keyStr);
                tempInfo = set1000Tani(tempInfo);
                sum = setSum(sum, tempInfo);

                tempInfo.J__c = NHR_Dao.getDivision(tempInfo.F__c ,tempInfo.H__c);
                tempInfo.K__c = NHR_Dao.getDivision(tempInfo.G__c ,tempInfo.I__c);
                tempInfo.V__c = NHR_Dao.getDivision(tempInfo.T__c ,tempInfo.R__c);
                tempInfo.W__c = NHR_Dao.getDivision(tempInfo.U__c ,tempInfo.S__c);

                sum.J__c = NHR_Dao.getDivision(sum.F__c ,sum.H__c);
                sum.K__c = NHR_Dao.getDivision(sum.G__c ,sum.I__c);
                sum.V__c = NHR_Dao.getDivision(sum.T__c ,sum.R__c);
                sum.W__c = NHR_Dao.getDivision(sum.U__c ,sum.S__c);
            }
        }
    }

    /**
     * 集計
     */
    private void setSum2(){
        FormCreation__c sum = new FormCreation__c();
        if (this.unitStr == NHR_Constant.UNIT3 || this.unitStr == NHR_Constant.UNIT4) {
            sum = excelMap2.get('Sum_9'+ this.userId);
        } else {
            sum = excelMap2.get('Sum_9');
        }

        for (String keyStr : excelMap2.keySet()) {
            if (!keyStr.contains('Sum_9')) {
                FormCreation__c tempInfo = excelMap2.get(keyStr);
                tempInfo = set1000Tani(tempInfo);
                sum = setSum(sum, tempInfo);

                tempInfo.J__c = NHR_Dao.getDivision(tempInfo.F__c ,tempInfo.H__c);
                tempInfo.K__c = NHR_Dao.getDivision(tempInfo.G__c ,tempInfo.I__c);
                tempInfo.V__c = NHR_Dao.getDivision(tempInfo.T__c ,tempInfo.R__c);
                tempInfo.W__c = NHR_Dao.getDivision(tempInfo.U__c ,tempInfo.S__c);

                sum.J__c = NHR_Dao.getDivision(sum.F__c ,sum.H__c);
                sum.K__c = NHR_Dao.getDivision(sum.G__c ,sum.I__c);
                sum.V__c = NHR_Dao.getDivision(sum.T__c ,sum.R__c);
                sum.W__c = NHR_Dao.getDivision(sum.U__c ,sum.S__c);
            }
        }
    }
    /**
     * 集計
     */
    private void setSum3(){
        for (String keyStr : excelMap3.keySet()) {
            FormCreation__c tempInfo = excelMap3.get(keyStr);
            tempInfo = set1000Tani3(tempInfo);
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
        tempInfo.X__c = tempInfo.X__c / 1000;
        tempInfo.Y__c = tempInfo.Y__c / 1000;
        tempInfo.Z__c = tempInfo.Z__c / 1000;
        tempInfo.AA__c = tempInfo.AA__c / 1000;
        tempInfo.AB__c = tempInfo.AB__c / 1000;
        tempInfo.AC__c = tempInfo.AC__c / 1000;
        return tempInfo;
    }

    private FormCreation__c set1000Tani3(FormCreation__c  tempInfo){
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

    private FormCreation__c setSum(FormCreation__c  sumObj ,FormCreation__c  tempInfo){
        sumObj.B__c += tempInfo.B__c;
        sumObj.C__c += tempInfo.C__c;
        sumObj.D__c += tempInfo.D__c;
        sumObj.E__c += tempInfo.E__c;
        sumObj.F__c += tempInfo.F__c;
        sumObj.G__c += tempInfo.G__c;
        sumObj.H__c += tempInfo.H__c;
        sumObj.I__c += tempInfo.I__c;
        sumObj.L__c += tempInfo.L__c;
        sumObj.M__c += tempInfo.M__c;
        sumObj.N__c += tempInfo.N__c;
        sumObj.O__c += tempInfo.O__c;
        sumObj.P__c += tempInfo.P__c;
        sumObj.Q__c += tempInfo.Q__c;
        sumObj.R__c += tempInfo.R__c;
        sumObj.S__c += tempInfo.S__c;
        sumObj.T__c += tempInfo.T__c;
        sumObj.U__c += tempInfo.U__c;
        sumObj.X__c += tempInfo.X__c;
        sumObj.Y__c += tempInfo.Y__c;
        return sumObj;
    }
    private void setFCDetail(FormCreation__c tempObj ,en_yojitsu__c obj ){
        if(tempObj.Title1__c == '林建設株式会社 エンジ本社'){system.debug('riiiii');system.debug(tempObj) ;system.debug(obj) ;}
        if (obj.en_yojitu2__c == NHR_Constant.BUDGET) {
            //予算
            if (obj.Yeaemonth__c >= LastForGetDay && obj.Yeaemonth__c < forGetDay) {
                tempObj.B__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                tempObj.C__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
            }
            tempObj.F__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
            tempObj.G__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
            
            tempObj.T__c += (obj.EN_mokuhyouuriagekingaku__c == null ? 0 : obj.EN_mokuhyouuriagekingaku__c);
            tempObj.U__c += (obj.EN_mokuhyouuriageararikingaku__c == null ? 0 : obj.EN_mokuhyouuriageararikingaku__c);
        } else {
            //実績
            if(obj.en_shodans__r.en_zyutyuukakudo__c == '受注'
               || obj.en_shodans__r.en_zyutyuukakudo__c == '受注確定') {
                   if (obj.Yeaemonth__c < LastForGetDay) {
                       tempObj.L__c += (obj.en_uriagekingaku__c == null ? 0 : obj.en_uriagekingaku__c);
                       tempObj.M__c += (obj.En_uriara__c == null ? 0 : obj.En_uriara__c);
                   } else if (obj.Yeaemonth__c >= LastForGetDay && obj.Yeaemonth__c < forGetDay) {
                       tempObj.D__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                       tempObj.E__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                       
                       tempObj.L__c += (obj.en_uriagekingaku__c == null ? 0 : obj.en_uriagekingaku__c);
                       tempObj.M__c += (obj.En_uriara__c == null ? 0 : obj.En_uriara__c);
                   }
                   tempObj.H__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                   tempObj.I__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                   
                   tempObj.R__c = tempObj.L__c + tempObj.N__c + tempObj.P__c ;
                   tempObj.S__c = tempObj.M__c + tempObj.O__c + tempObj.Q__c;
               }
        }
        

        //tempObj.T__c = tempObj.L__c + tempObj.N__c + tempObj.P__c + tempObj.R__c;
        //tempObj.U__c = tempObj.M__c + tempObj.O__c + tempObj.Q__c + tempObj.S__c;
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
    public class NHR_EN_SalesReviewMeetingExcelCreate implements Queueable, Database.AllowsCallouts {
        public String deStr ;
        public String userId ;
        public NHR_EN_SalesReviewMeetingExcelCreate(String inDeStr ,String inUserId)
        {
            deStr = inDeStr;
            userId = inUserId;
        }
        public void execute(QueueableContext context) {
            Map<String, String> deMap = new Map<String, String>();
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
                PageReference pr = Page.NHR_EN_SalesReviewMeeting;
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

            mail.setSubject('「営業検討会添付資料」出力完了のお知らせ'); // 件名(String)
            mail.setPlainTextBody('「営業検討会添付資料」の出力が完了いたしました。'); // 本文(String)
            mail.setEntityAttachments(new List<String>{contentId}); // 添付ファイル(Document、ContentVersion、AttachmentのIDのリスト)

            mail.setReplyTo(UserInfo.getUserEmail()); // 返信先メールアドレス(String)

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
    }
}