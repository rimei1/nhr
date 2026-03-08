public class NHR_EN_SalesReviewMeetingCtrl {
    public List<FormCreation__c> FormCreation1{get;set;}
    public List<FormCreation__c> FormCreation2{get;set;}
    public List<FormCreation__c> FormCreation3{get;set;}
    public String fileName {get;set;}
    
    public String thisYear {get;set;}
    public String thisFiscalYear {get;set;}
    public Date thisDay {get;set;}
    public String thisDayStr {get;set;}
    public String deStr {get;set;}
    public String userId {get;set;}
    
    public NHR_EN_SalesReviewMeetingCtrl() {
        thisDay = Date.today();
        thisDayStr = thisDay.format();
        thisYear = NHR_Dao.getYear(thisDay);
        thisFiscalYear = NHR_Dao.getFiscalYearStr(thisDay.addYears(1));
        deStr = ApexPages.currentPage().getParameters().get('kubun');
        userId = ApexPages.currentPage().getParameters().get('userId');
        if (String.isNotBlank(userId) ){
            deStr = NHR_Dao.getUserInfo(userId).Name;
        }

        
        FormCreation1 = new List<FormCreation__c>();
        FormCreation2 = new List<FormCreation__c>();
        FormCreation3 = new List<FormCreation__c>();
        //ファイル名
        fileName = String.valueOf(Date.today()).replaceAll('-', '') + '' ;
        
        if (String.isNotBlank(userId)) {
            FormCreation1 = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_SRM1 + userId);
            FormCreation2 = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_SRM2  + userId);
            FormCreation3 = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_SRM3  + userId);
        } else {
            FormCreation1 = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_SRM1);
            FormCreation2 = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_SRM2);
            FormCreation3 = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_SRM3);
        }
        
        

        //FormCreationList = Osmo_Dao.getAccountForFWHForExcel(System.Label.Osmo_CHWSumUser);
    }
}