public class NHR_EN_ConOppOrderCtrl {
    public List<FormCreation__c> FormCreation{get;set;}
    public List<List<FormCreation__c>> FormCreationList{get;set;}
    public String fileName {get;set;}
    
    public String thisYear {get;set;}
    public String thisFiscalYear {get;set;}
    public Date thisDay {get;set;}
    public String thisDayStr {get;set;}
    public String deStr {get;set;}
    public String userId {get;set;}
    
    public NHR_EN_ConOppOrderCtrl() {
        thisDay = Date.today();
        thisDayStr = thisDay.format();
        thisYear = NHR_Dao.getYear(thisDay);
        thisFiscalYear = NHR_Dao.getFiscalYearStr(thisDay.addYears(1));
        deStr = ApexPages.currentPage().getParameters().get('kubun');
        userId = ApexPages.currentPage().getParameters().get('userId');
        if (String.isNotBlank(userId) ){
            deStr = NHR_Dao.getUserInfo(userId).Name;
        }
        
        FormCreation = new List<FormCreation__c>();
        FormCreationList = new List<List<FormCreation__c>>();
        
        if (String.isNotBlank(userId)) {
            FormCreation = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_COO + userId);
        } else {
            FormCreation = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_COO);
        }
        
        
        integer i = 0;
        List<FormCreation__c> tempList = new List<FormCreation__c>();
        for (FormCreation__c obj : FormCreation) {
            if (math.mod(i, 5) == 0) {
                if (i != 0) {
                    FormCreationList.add(tempList);
                }
                tempList = new List<FormCreation__c>();
                tempList.add(obj);
            } else {
                tempList.add(obj);
            }
            i += 1;
        }
        FormCreationList.add(tempList);

        //FormCreationList = Osmo_Dao.getAccountForFWHForExcel(System.Label.Osmo_CHWSumUser);
    }
}