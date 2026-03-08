public class NHR_ST_QuantityActualPlansCtrl{
    @InvocableMethod(label='ST_加工数量実績および予定表作成')
    public static void NHR_ST_QuantityActualPlans(){
        NHR_ST_QuantityActualPlansBatch myBatchObject = new NHR_ST_QuantityActualPlansBatch();
        Database.executeBatch(myBatchObject,200);
    }
}