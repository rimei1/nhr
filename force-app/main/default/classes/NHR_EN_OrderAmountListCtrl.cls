public class NHR_EN_OrderAmountListCtrl {
    public List<FormCreation__c> FormCreationList{get;set;}
    public String fileName {get;set;}
    public String thisFiscalYear {get;set;}
    public String nextFiscalYear {get;set;}
    public String next2FiscalYear {get;set;}
    public String thisMonth {get;set;}
    public Date thisDay {get;set;}
    public String thisDayStr {get;set;}
    public String deStr {get;set;}
    public String userId {get;set;}
    
    public NHR_EN_OrderAmountListCtrl() {
        deStr = ApexPages.currentPage().getParameters().get('kubun');
        userId = ApexPages.currentPage().getParameters().get('userId');
        thisDay = Date.today();
        thisMonth = String.valueOf(thisDay.month());
        if (thisDay.month() == 7) {
            thisDay = thisDay.addMonths(-1);
        }
        thisDayStr = thisDay.format();
        thisFiscalYear = NHR_Dao.getFiscalYearStr(thisDay);
        nextFiscalYear = NHR_Dao.getFiscalYearStr(thisDay.addYears(1));
        next2FiscalYear = NHR_Dao.getFiscalYearStr(thisDay.addYears(2));
        FormCreationList = new List<FormCreation__c>();
        
        if (String.isNotBlank(userId) ){
            deStr = NHR_Dao.getUserInfo(userId).Name;
        }        
        if (String.isNotBlank(userId)) {
            FormCreationList = NHR_Dao.get_NHR_EN_SalesReportCtrl('OrderAmountList' + userId);
        } else {
            FormCreationList = NHR_Dao.get_NHR_EN_SalesReportCtrl('OrderAmountList');
        }
        
        
        //FormCreationList = Osmo_Dao.getAccountForFWHForExcel(System.Label.Osmo_CHWSumUser);
    }
}