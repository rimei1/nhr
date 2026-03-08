/*
 * 3の実績を作成
 */
global without sharing class NHR_EN_SalesReportBatch3 implements Database.Batchable<sObject>, Database.Stateful{
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
    global NHR_EN_SalesReportBatch3
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
        system.debug('NHR_EN_SalesReportBatch3');
        kanseiki = NHR_Dao.getNext10FiscalYear(NHR_Dao.getFiscalYear(Date.today()));
        system.debug('kanseiki:' + kanseiki);
        Set<String> tantobusyo = reportMap.keySet();
    	String query = NHR_Dao.get_NHR_EN_SalesReportBatch3(this.unitStr ,this.userId);
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Opportunity> scopes){
        FormCreation__c tempInfo3_1 = new FormCreation__c();
        tempInfo3_1 = excelMap3.get('1');
        FormCreation__c tempInfo3_2 = new FormCreation__c();
        tempInfo3_2 = excelMap3.get('2');
        FormCreation__c tempInfo3_3 = new FormCreation__c();
        tempInfo3_3 = excelMap3.get('3');

        for(Opportunity obj : scopes) {

            if (obj.EN_kanseiki__c == kanseiki[0]) {
                //今期
                if ( String.isBlank(obj.en_genbastatus__c)
                   || obj.en_genbastatus__c != '完成') {
                    tempInfo3_1.D__c += (obj.en_zyutyuukinngakukgoukei__c == null ? 0 : obj.en_zyutyuukinngakukgoukei__c);
                    tempInfo3_1.E__c += (obj.en_zyutyuuararigoukei__c == null ? 0 : obj.en_zyutyuuararigoukei__c);
                }

            } else  if (obj.EN_kanseiki__c == kanseiki[1]) {
                //来期
                if ( String.isBlank(obj.en_genbastatus__c)
                   || obj.en_genbastatus__c != '完成') {
                    tempInfo3_2.D__c += (obj.en_zyutyuukinngakukgoukei__c == null ? 0 : obj.en_zyutyuukinngakukgoukei__c);
                    tempInfo3_2.E__c += (obj.en_zyutyuuararigoukei__c == null ? 0 : obj.en_zyutyuuararigoukei__c);
                }
            } else {
                //来期以降
                if ( String.isBlank(obj.en_genbastatus__c)
                   || obj.en_genbastatus__c != '完成') {
                    tempInfo3_3.D__c += (obj.en_zyutyuukinngakukgoukei__c == null ? 0 : obj.en_zyutyuukinngakukgoukei__c);
                    tempInfo3_3.E__c += (obj.en_zyutyuuararigoukei__c == null ? 0 : obj.en_zyutyuuararigoukei__c);
                }
            }
        }
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {  
        //完了後の処理があれば
        NHR_EN_SalesReportBatch4 myBatchObject = new NHR_EN_SalesReportBatch4
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
}