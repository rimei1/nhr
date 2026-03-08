@isTest
public class NHR_SL_SalesManagementBatchTest {
        
    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();

        NHR_EN_CreateExcelCtrl.Call_SalesManagementBatch();
        NHR_SL_SalesManagementBatch2.forTest();
        NHR_SL_SalesManagementBatch.forTest();
    }
}