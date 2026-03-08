/*
 * 4を作成
 */
global without sharing class NHR_EN_SalesReportBatch4 implements Database.Batchable<sObject>, Database.Stateful{
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
    global String kanseiki {get;set;}
    global NHR_EN_SalesReportBatch4
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
        system.debug('NHR_EN_SalesReportBatch4');
        kanseiki = NHR_Dao.getNext10FiscalYear(NHR_Dao.getFiscalYear(Date.today()))[0];
        Set<String> tantobusyo = reportMap.keySet();
    	String query = NHR_Dao.get_NHR_EN_SalesReportBatch4(this.unitStr ,this.userId);
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){
        FormCreation__c tempInfo4_1 = new FormCreation__c();
        tempInfo4_1 = excelMap4.get('1');
        FormCreation__c tempInfo4_2 = new FormCreation__c();
        tempInfo4_2 = excelMap4.get('2');
        
        for(Opportunity obj : scopes) {
                //今期
                tempInfo4_1.B__c += (obj.EN_saisyuzyutyuukingaku__c  == null ? 0 : obj.EN_saisyuzyutyuukingaku__c );
                tempInfo4_2.B__c += (obj.EN_saisyuzyutyukingaku__c   == null ? 0 : obj.EN_saisyuzyutyukingaku__c  );
        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        //完了後の処理があれば
        //小計
        setSum4();

        //４．当期売上確定
        insert excelMap4.values();

        //完了後の処理があれば
        NHR_EN_SalesReportBatch5 myBatchObject = new NHR_EN_SalesReportBatch5
            (excelMap1_1
             ,excelMap1_2
             ,excelMap2
             ,excelMap3
             ,excelMap4
             ,deStr
             ,unitStr
             ,userId
             ,startDate
             ,endDate
             ,LastMonthStartDate
             ,LastMonthEndDate
             ,reportMap
             ,yearMap
            );
        Database.executeBatch(myBatchObject,2000);
    }

    /**
     * 集計4
     */
    private void setSum4(){
        FormCreation__c tempInfo4_1 = excelMap4.get('1');
        FormCreation__c tempInfo4_2 = excelMap4.get('2');
        FormCreation__c sum = excelMap4.get('Sum');

        tempInfo4_1.A__c = tempInfo4_1.A__c /1000;
        tempInfo4_1.B__c = tempInfo4_1.B__c /1000;
        tempInfo4_2.A__c = tempInfo4_2.A__c /1000;
        tempInfo4_2.B__c = tempInfo4_2.B__c /1000;

        tempInfo4_1.C__c = NHR_Dao.getDivision(tempInfo4_1.A__c ,tempInfo4_1.B__c);
        excelMap4.put('1' ,tempInfo4_1);
        tempInfo4_2.C__c = NHR_Dao.getDivision(tempInfo4_2.A__c ,tempInfo4_2.B__c);
        excelMap4.put('2' ,tempInfo4_2);

        sum.A__c = NHR_Dao.getDivision(tempInfo4_1.A__c ,tempInfo4_2.A__c);
        sum.B__c = NHR_Dao.getDivision(tempInfo4_1.B__c ,tempInfo4_2.B__c);

        excelMap4.put('Sum' ,sum);
    }

}