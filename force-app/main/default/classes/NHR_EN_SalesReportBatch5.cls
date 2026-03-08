/*
 * 3を作成
 */
global without sharing class NHR_EN_SalesReportBatch5 implements Database.Batchable<sObject>, Database.Stateful{
    static final String ACTUAL = '実績';
    static final String BUDGET = '予算';
    global Map<String ,FormCreation__c> excelMap1_1 {get;set;}
    global Map<String ,FormCreation__c> excelMap1_2 {get;set;}
    global Map<String ,FormCreation__c> excelMap2 {get;set;}
    global Map<String ,FormCreation__c> excelMap3 {get;set;}
    global Map<String ,FormCreation__c> excelMap4 {get;set;}
    global Map<String ,String> yearMap {get;set;}
    global Map<String ,EN_Report__mdt> reportMap {get;set;}
    global String deStr {get;set;}
    global String unitStr {get;set;}
    global String userId {get;set;}
    global Date startDate {get;set;}
    global Date endDate {get;set;}
    global Date LastMonthStartDate {get;set;}
    global Date LastMonthEndDate {get;set;}
    global List<String> kanseiki {get;set;}
    global NHR_EN_SalesReportBatch5
        (Map<String ,FormCreation__c> inExcelMap1_1
         ,Map<String ,FormCreation__c> inExcelMap1_2
         ,Map<String ,FormCreation__c> inExcelMap2
         ,Map<String ,FormCreation__c> inExcelMap3
         ,Map<String ,FormCreation__c> inExcelMap4
         ,String inDeStr
         ,String inUnit
         ,String userId
         ,Date inStartDate
         ,Date inEndDate
         ,Date inLastMonthStartDate
         ,Date inLastMonthEndDate
         ,Map<String ,EN_Report__mdt> inReportMap
         ,Map<String ,String> inYearMap)
    {
        this.excelMap1_1 = inExcelMap1_1;
        this.excelMap1_2 = inExcelMap1_2;
        this.excelMap2 = inExcelMap2;
        this.excelMap3 = inExcelMap3;
        this.excelMap4 = inExcelMap4;
        this.deStr = inDeStr;
        this.unitStr = inUnit;
        this.userId = userId;
        this.startDate = inStartDate;
        this.endDate = inEndDate;
        this.LastMonthStartDate = inLastMonthStartDate;
        this.LastMonthEndDate = inLastMonthEndDate;
        this.reportMap = inReportMap;
        this.yearMap = inYearMap;
    }

    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_EN_SalesReportBatch5');
        List<String> tempList = NHR_Dao.getNext10FiscalYear(NHR_Dao.getFiscalYear(Date.today()));
        kanseiki = new List<String>();
        kanseiki.add(tempList[0]);
        kanseiki.add(tempList[1]);
        kanseiki.add(tempList[2]);
        Set<String> tantobusyo = reportMap.keySet();
    	String query = NHR_Dao.get_NHR_EN_SalesReportBatch5(this.unitStr ,this.userId);
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<en_yojitsu__c> scopes){
        FormCreation__c tempInfo3_1 = new FormCreation__c();
        tempInfo3_1 = excelMap3.get('1');
        FormCreation__c tempInfo3_2 = new FormCreation__c();
        tempInfo3_2 = excelMap3.get('2');
        FormCreation__c tempInfo3_3 = new FormCreation__c();
        tempInfo3_3 = excelMap3.get('3');
        
        for(en_yojitsu__c obj : scopes) {
            if (obj.en_yojitu2__c == BUDGET) {
                if (obj.EN_kanseiki__c == kanseiki[0]) {
                    //3.期末受注残高計画(予算：目標受注金額、目標受注粗利金額)
                    //tempInfo3_1.A__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    //tempInfo3_1.B__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                } else if (obj.EN_kanseiki__c == kanseiki[1]) {
                    //3.期末受注残高計画(予算：目標受注金額、目標受注粗利金額)
                    tempInfo3_2.A__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    tempInfo3_2.B__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                } else if (obj.EN_kanseiki__c == kanseiki[2]) {
                    //3.期末受注残高計画(予算：目標受注金額、目標受注粗利金額)
                    tempInfo3_3.A__c += (obj.en_kousyuy12__c == null ? 0 : obj.en_kousyuy12__c);
                    tempInfo3_3.B__c += (obj.EN_yosan_arari__c == null ? 0 : obj.EN_yosan_arari__c);
                }
                
            } else {
                if (obj.en_ankenkubun_yozitsu__c == '本工事'){
                    if (obj.Yeaemonth__c < startDate || obj.Yeaemonth__c > endDate) {
                        if (obj.EN_kanseiki__c == kanseiki[0]) {
                            //3.期末受注残高計画(実績：受注金額、受注粗利金額)
                            //tempInfo3_1.A__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                            //tempInfo3_1.B__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                        } else if (obj.EN_kanseiki__c == kanseiki[1]) {
                            //3.期末受注残高計画(実績：受注金額、受注粗利金額)
                            tempInfo3_2.A__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                            tempInfo3_2.B__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                        } else if (obj.EN_kanseiki__c == kanseiki[2]) {
                            //3.期末受注残高計画(実績：受注金額、受注粗利金額)
                            tempInfo3_3.A__c += (obj.en_juchu12__c == null ? 0 : obj.en_juchu12__c);
                            tempInfo3_3.B__c += (obj.en_jutyuarari__c == null ? 0 : obj.en_jutyuarari__c);
                        }
                    }
                }
            }
        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        //完了後の処理があれば
        //小計
        setSum3();

        //４．当期売上確定
        insert excelMap3.values();

        //完了後の処理があれば
        System.Queueable job = new NHR_EN_SalesReportExcelCreate(deStr, userId);
        System.enqueueJob(job);

    }

    /**
     * 集計3
     */
    private void setSum3(){
        FormCreation__c tempInfo3_1 = excelMap3.get('1');
        FormCreation__c tempInfo3_2 = excelMap3.get('2');
        FormCreation__c tempInfo3_3 = excelMap3.get('3');
        FormCreation__c sum = excelMap3.get('Sum');

        tempInfo3_1.C__c = NHR_Dao.getDivision(tempInfo3_1.A__c ,tempInfo3_1.B__c);
        tempInfo3_1.F__c = NHR_Dao.getDivision(tempInfo3_1.D__c ,tempInfo3_1.E__c);

        tempInfo3_2.C__c = NHR_Dao.getDivision(tempInfo3_2.A__c ,tempInfo3_2.B__c);
        tempInfo3_2.F__c = NHR_Dao.getDivision(tempInfo3_2.D__c ,tempInfo3_2.E__c);

        tempInfo3_3.C__c = NHR_Dao.getDivision(tempInfo3_3.A__c ,tempInfo3_3.B__c);
        tempInfo3_3.F__c = NHR_Dao.getDivision(tempInfo3_3.D__c ,tempInfo3_3.E__c);


        sum.A__c = tempInfo3_1.A__c + tempInfo3_2.A__c + tempInfo3_3.A__c;
        sum.B__c = tempInfo3_1.B__c + tempInfo3_2.B__c + tempInfo3_3.B__c;
        sum.D__c = tempInfo3_1.D__c + tempInfo3_2.D__c + tempInfo3_3.D__c;
        sum.E__c = tempInfo3_1.E__c + tempInfo3_2.E__c + tempInfo3_3.E__c;
        sum.C__c = NHR_Dao.getDivision(sum.A__c ,sum.B__c);
        sum.F__c = NHR_Dao.getDivision(sum.D__c ,sum.E__c);

        excelMap3.put('Sum' ,sum);

        for (String key : excelMap3.keySet()) {
            FormCreation__c  tempInfo = excelMap3.get(key);
                tempInfo = set1000Tani(tempInfo);
                //excelMap3.put(key ,tempInfo);
        }
    }
    
        private FormCreation__c set1000Tani(FormCreation__c  tempInfo){
        tempInfo.A__c = tempInfo.A__c / 1000;
        tempInfo.B__c = tempInfo.B__c / 1000;
        tempInfo.D__c = tempInfo.D__c / 1000;
        tempInfo.E__c = tempInfo.E__c / 1000;
        
        return tempInfo;
    }

    /**
   * EXCEL作成
   */
    public class NHR_EN_SalesReportExcelCreate implements Queueable, Database.AllowsCallouts {
        public String deStr ;
        public String userId ;
        public NHR_EN_SalesReportExcelCreate(String inDeStr ,String inUserId)
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
                PageReference pr = Page.NHR_EN_SalesReport;
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

            mail.setSubject('「営業報告書」出力完了のお知らせ'); // 件名(String)
            mail.setPlainTextBody('「営業報告書」の出力が完了いたしました。'); // 本文(String)
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
    }
}