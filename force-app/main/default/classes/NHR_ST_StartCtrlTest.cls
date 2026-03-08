@isTest
public class NHR_ST_StartCtrlTest {    
    @isTest static void test1() {
        NHR_TestDataFactory.createAllMstData();
        test.startTest();
        NHR_ST_StartCtrl.NHR_ST_StartCtrl();
        test.stopTest();
    }
}