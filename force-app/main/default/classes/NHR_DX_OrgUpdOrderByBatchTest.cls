@isTest
public class NHR_DX_OrgUpdOrderByBatchTest {

    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();
        NHR_DX_OrgUpdOrderByStart.run();
        NHR_DX_OrgUpdOrderByBatch myBatchObject = new NHR_DX_OrgUpdOrderByBatch();
        Database.executeBatch(myBatchObject,200);
    }
}