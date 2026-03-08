public class NHR_ST_QuantityActualPlansVFCtrl {
    public List<ST_ManagementDashboard__c> FormCreationList{get;set;}
    public List<ST_ManagementDashboard__c> FormCreationList1{get;set;}
    public List<ST_ManagementDashboard__c> FormCreationList2{get;set;}
    public List<ST_ManagementDashboard__c> FormCreationList3{get;set;}
    public String fileName {get;set;}
    public Date thisDay {get;set;}
    public String thisDayStr {get;set;}
    public String thisYearStr {get;set;}

    public NHR_ST_QuantityActualPlansVFCtrl() {
        FormCreationList = new List<ST_ManagementDashboard__c>();
        FormCreationList1 = new List<ST_ManagementDashboard__c>();
        FormCreationList2 = new List<ST_ManagementDashboard__c>();
        FormCreationList3 = new List<ST_ManagementDashboard__c>();
        thisDay = Date.today();
        thisDayStr = thisDay.format();
        if (thisDay.month() >= 7) {
            thisYearStr = String.valueOf(thisDay.year());
        } else {
            thisYearStr = String.valueOf(thisDay.year() - 1);
        }

        //ファイル名
        fileName = String.valueOf(thisDay).replaceAll('-', '') + '_ST';
        FormCreationList = NHR_Dao.get_NHR_ST_QuantityActualPlansCtrl(NHR_Constant.BATCHNAME_ST_AP);
        for(ST_ManagementDashboard__c obj : FormCreationList) {
            if (obj.orderBy__c < 200) {
                FormCreationList1.add(obj);
            } else if (obj.orderBy__c < 300) {
                FormCreationList2.add(obj);
            } else {
                FormCreationList3.add(obj);
            }
        }

    }
}