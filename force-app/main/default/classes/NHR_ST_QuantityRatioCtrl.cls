public class NHR_ST_QuantityRatioCtrl {
    public List<FormCreation__c> FormCreationList{get;set;}
    public String fileName {get;set;}

    public NHR_ST_QuantityRatioCtrl() {
        FormCreationList = new List<FormCreation__c>();
        FormCreationList = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_ST_R);
    }
}