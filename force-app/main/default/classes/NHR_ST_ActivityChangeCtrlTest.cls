@isTest
public class NHR_ST_ActivityChangeCtrlTest {    
    @isTest static void test1() {
        NHR_TestDataFactory.createAllMstData();
        test.startTest();
        NHR_ST_ActivityChangeCtrl.NHR_ST_Start();
        test.stopTest();
    }
}