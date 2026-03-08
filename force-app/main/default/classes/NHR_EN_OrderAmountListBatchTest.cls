@isTest
public class NHR_EN_OrderAmountListBatchTest {

    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();
        NHR_EN_CreateExcelCtrl.Call_EN_OrderAmountList('全社', NHR_Constant.UNIT1);
    }

    @isTest static void test2() {
        NHR_TestDataFactory.createAllMstData();
        NHR_EN_CreateExcelCtrl.Call_EN_OrderAmountList('大阪', NHR_Constant.UNIT3);
    }
}