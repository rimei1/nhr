@isTest
public class NHR_EN_SalesReviewMeetingBatchTest {
        
    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();

        NHR_EN_CreateExcelCtrl.Call_SalesReviewMeetingBatch('全社', NHR_Constant.UNIT1);
    }

    @isTest static void test2() {
        NHR_TestDataFactory.createAllMstData();

        NHR_EN_CreateExcelCtrl.Call_SalesReviewMeetingBatch('大阪営業部', NHR_Constant.UNIT2);
    }

    @isTest static void test3() {
        NHR_TestDataFactory.createAllMstData();

        NHR_EN_CreateExcelCtrl.Call_SalesReviewMeetingBatch('大阪', NHR_Constant.UNIT3);
        NHR_EN_SalesReviewMeetingBatch1.forTest();
    }
}