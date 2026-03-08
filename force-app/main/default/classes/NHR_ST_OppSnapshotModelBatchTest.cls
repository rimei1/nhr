@isTest
public class NHR_ST_OppSnapshotModelBatchTest {
    
    @isTest static void test2() {
        NHR_TestDataFactory.createAllMstData();
        test.startTest();
        NHR_ST_OppSnapshotModelBatch myBatchObject = new NHR_ST_OppSnapshotModelBatch();
        Database.executeBatch(myBatchObject,2000);
        NHR_ST_OppSnapshotModelBatch.forTest();
        test.stopTest();
    }
}