public class NHR_SL_SalesManagementCtrl {
    public List<FormCreation__c> FormCreationList1{get;set;}
    public List<FormCreation__c> FormCreationList2{get;set;}
    public List<FormCreation__c> FormCreationList3{get;set;}
    public List<FormCreation__c> FormCreationList4{get;set;}
    public String fileName {get;set;}
    public String theYear7 {get;set;}
    public String theNextYear {get;set;}
    public String thisMonth {get;set;}
    public Date thisDay {get;set;}

    
    public NHR_SL_SalesManagementCtrl() {

        thisDay = Date.today();
        thisMonth = String.valueOf(thisDay.month());
        if (thisDay.month() < 7) {
            theYear7 = String.valueOf(thisDay.year() - 1) ;
            theNextYear = String.valueOf(thisDay.year()) ;
        } else {
            theYear7 = String.valueOf(thisDay.year() ) ;
            theNextYear = String.valueOf(thisDay.year() + 1) ;
        }

        FormCreationList1 = new List<FormCreation__c>();
        FormCreationList2 = new List<FormCreation__c>();
        FormCreationList3 = new List<FormCreation__c>();
        FormCreationList4 = new List<FormCreation__c>();
        
        FormCreationList1 = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_SLSALES1);
        FormCreationList2 = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_SLSALES2);
        FormCreationList3 = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_SLSALES3);
        FormCreationList4 = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_SLSALES4);
    }
}