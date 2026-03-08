@isTest
public class NHR_ST_OppSnapshotDashboardTest {
    
    @isTest static void test2() {
        NHR_TestDataFactory.createAllMstData();
        test.startTest();
        NHR_ST_OppSnapshotDashboardCtrl.NHR_ST_OppSnapshotDashboard();
        test.stopTest();
    }
}