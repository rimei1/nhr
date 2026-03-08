@isTest
public class NHR_EN_OrderAmountListOsakaBatchTest {

    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();
        NHR_EN_CreateExcelCtrl.Call_EN_OrderAmountListOsaka();
    }
}