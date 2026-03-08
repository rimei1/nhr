public class NHR_DX_OrgUpdOrderByStart {
    @InvocableMethod(label='OrgUpdOrderBy' description='組織並び順更新' category= 'Contact')
    public static void run() {
        NHR_DX_OrgUpdOrderByBatch myBatchObject = new NHR_DX_OrgUpdOrderByBatch();
        Database.executeBatch(myBatchObject,200);
    } 
}