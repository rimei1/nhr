public class NHR_ST_OppSnapshotDashboardCtrl{
    @InvocableMethod(label='ST_スチール経営ダッシュボード')
    public static void NHR_ST_OppSnapshotDashboard(){
        NHR_ST_OppSnapshotDashboardPreBatch myBatchObject = new NHR_ST_OppSnapshotDashboardPreBatch();
        Database.executeBatch(myBatchObject,2000);
    }
}