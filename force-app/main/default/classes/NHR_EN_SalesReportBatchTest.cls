@isTest
public class NHR_EN_SalesReportBatchTest {

    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();

        NHR_EN_CreateExcelCtrl.Call_EN_SalesReportStart('全社', NHR_Constant.UNIT1);
        NHR_EN_SalesReportBatch1.forTest();
    }

    @isTest static void test2() {
        NHR_TestDataFactory.createAllMstData();

        NHR_EN_CreateExcelCtrl.Call_EN_SalesReportStart('大阪営業部', NHR_Constant.UNIT2);
        NHR_EN_SalesReportBatch2.forTest();
    }

    @isTest static void test3() {
        NHR_TestDataFactory.createAllMstData();

        NHR_EN_CreateExcelCtrl.Call_EN_SalesReportStart('大阪営業部', NHR_Constant.UNIT3);
        
        NHR_EN_SalesReportBatch5.forTest();
    }
    
    @isTest static void test4() {
        NHR_TestDataFactory.createAllMstData();

        NHR_EN_CreateExcelCtrl.Call_EN_SalesReportStart('', NHR_Constant.UNIT4);
        
        NHR_EN_SalesReportBatch5.forTest();
    }
}