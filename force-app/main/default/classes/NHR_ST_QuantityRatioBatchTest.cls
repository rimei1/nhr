@isTest
public class NHR_ST_QuantityRatioBatchTest {

    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();

        NHR_EN_CreateExcelCtrl.Call_NHR_ST_QuantityRatioBatch();
    }
}