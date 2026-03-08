public class NHR_EN_SalesReportCtrl {
    public List<FormCreation__c> FormCreationList{get;set;}
    public List<FormCreation__c> FormCreationList1_1{get;set;}
    public List<FormCreation__c> FormCreationList1_2{get;set;}
    public List<FormCreation__c> FormCreationList2{get;set;}
    public List<FormCreation__c> FormCreationList3{get;set;}
    public List<FormCreation__c> FormCreationList4{get;set;}
    public String fileName {get;set;}
    public String thisYear {get;set;}
    public String thisFiscalYear {get;set;}
    public String thisMonth {get;set;}
    public String lastMonth {get;set;}
    public Date thisDay {get;set;}
    public String thisDayStr {get;set;}
    public Integer size1_2 {get;set;}
    public Integer size1_2_blank {get;set;}
    public Integer size2 {get;set;}
    public Integer size2_blank {get;set;}
    public String deStr {get;set;}
    public String unitStr {get;set;}
    public String userId {get;set;}


    public NHR_EN_SalesReportCtrl() {
        FormCreationList = new List<FormCreation__c>();
        FormCreationList1_1 = new List<FormCreation__c>();
        FormCreationList1_2 = new List<FormCreation__c>();
        FormCreationList2 = new List<FormCreation__c>();
        FormCreationList3 = new List<FormCreation__c>();
        FormCreationList4 = new List<FormCreation__c>();
        thisDay = Date.today();
        thisDayStr = thisDay.format();
        thisYear = NHR_Dao.getYear(thisDay);
        thisFiscalYear = NHR_Dao.getFiscalYear(thisDay);
        thisMonth = String.valueOf(thisDay.month());
        lastMonth = String.valueOf(thisDay.addMonths(-1).month());

        deStr = ApexPages.currentPage().getParameters().get('kubun');
        unitStr = ApexPages.currentPage().getParameters().get('unitStr');
        userId = ApexPages.currentPage().getParameters().get('userId');
        system.debug('deStr:' + deStr);

        //ファイル名
        fileName = String.valueOf(thisDay).replaceAll('-', '') + '_eigyouhoukokusyo_';
        if (deStr == '全社') {
            fileName += 'zensya';
        } else if (deStr == '東京') {
            fileName += 'honsya';
        } else if (deStr == '大阪') {
            fileName += 'osaka';
        }
        for (integer i = 0 ; i < 5 ; i ++) {
            FormCreationList.add(new FormCreation__c());
        }

        system.debug('deStr:' + deStr);
        if (String.isNotBlank(userId)) {
            FormCreationList1_1 = NHR_Dao.get_NHR_EN_SalesReportCtrl('Sales1_1'+ userId);
            FormCreationList1_2 = NHR_Dao.get_NHR_EN_SalesReportCtrl('Sales1_2'+ userId);
            FormCreationList2 = NHR_Dao.get_NHR_EN_SalesReportCtrl('Sales2'+ userId);
            FormCreationList3 = NHR_Dao.get_NHR_EN_SalesReportCtrl('Sales3'+ userId);
            FormCreationList4 = NHR_Dao.get_NHR_EN_SalesReportCtrl('Sales4'+ userId);
            deStr = NHR_Dao.getUserInfo(userId).Name;
        } else {
            FormCreationList1_1 = NHR_Dao.get_NHR_EN_SalesReportCtrl('Sales1_1'+ deStr);
            FormCreationList1_2 = NHR_Dao.get_NHR_EN_SalesReportCtrl('Sales1_2'+ deStr);
            FormCreationList2 = NHR_Dao.get_NHR_EN_SalesReportCtrl('Sales2'+ deStr);
            FormCreationList3 = NHR_Dao.get_NHR_EN_SalesReportCtrl('Sales3');
            FormCreationList4 = NHR_Dao.get_NHR_EN_SalesReportCtrl('Sales4');
        }

        size1_2 = FormCreationList1_2.size() +1;
        size1_2_blank = FormCreationList1_2.size() +2;

        size2 = FormCreationList2.size() +1;
        size2_blank = FormCreationList2.size() +2;

    }
}