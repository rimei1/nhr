@isTest
public class NHR_JU_BPOKPIKGIReportBatchTest {

    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();

        NHR_EN_CreateExcelCtrl.Call_JU_BPOKPIKGIReportBatch();
    }
}