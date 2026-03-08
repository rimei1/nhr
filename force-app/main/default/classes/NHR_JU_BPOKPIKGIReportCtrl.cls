public class NHR_JU_BPOKPIKGIReportCtrl {
    public List<FormCreation__c> FormCreationList{get;set;}
    public String fileName {get;set;}
    
    public NHR_JU_BPOKPIKGIReportCtrl() {
        fileName = 'test';
        FormCreationList = new List<FormCreation__c>();
        FormCreationList = NHR_Dao.get_NHR_EN_SalesReportCtrl(NHR_Constant.BATCHNAME_JU_KPI);
    }
}