public class NHR_JU_CategoryReportCtrl{
    @InvocableMethod(label='住環境_カテゴリ別レポートの作成')
    public static void NHR_Execution(){
        NHR_JU_CategoryReportBatch myBatchObject = new NHR_JU_CategoryReportBatch();
        Database.executeBatch(myBatchObject);
    }
}