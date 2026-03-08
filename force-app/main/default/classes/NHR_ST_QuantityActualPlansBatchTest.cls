@isTest
public class NHR_ST_QuantityActualPlansBatchTest {
    @isTest static void test2() {
        NHR_TestDataFactory.createAllMstData();
        test.startTest();
        NHR_ST_QuantityActualPlansCtrl.NHR_ST_QuantityActualPlans();
        NHR_ST_QuantityActualPlansBatch2.forTest();
        test.stopTest();
    }
    
}