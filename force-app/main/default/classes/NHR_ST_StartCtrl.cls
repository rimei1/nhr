public class NHR_ST_StartCtrl{
    @InvocableMethod(label='スチール_ダッシュボード構築')
    public static void NHR_ST_StartCtrl(){
        Database.executeBatch(new NHR_ST_ConsCustomerAmountBatch(),200);
        Database.executeBatch(new NHR_ST_ConstructionOrderAchievementBatch(),200);
        Database.executeBatch(new NHR_ST_SegmentPropertyQuantity(),200);
        Database.executeBatch(new NHR_ST_CusOrderAmountQuantityBatch(),200);
        Database.executeBatch(new NHR_ST_OrderAchievementBatch(),200);
        Database.executeBatch(new NHR_ST_OppSnapshotModelBatch(),200);

    }
}