@isTest
public class NHR_CS_PerceptualMappingBatchTest {

    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();
        
        String cron = '0 15 * * * ?';
        
        test.startTest();
            system.Schedule('NHR_CS_PerceptualMappingBatchSchedule', cron, new NHR_CS_PerceptualMappingBatchSchedule());
        NHR_CS_PerceptualMappingBatch.forTest();
        test.stopTest();
    }
    
    @isTest static void test2() {
        NHR_TestDataFactory.createAllMstData();
        test.startTest();
        NHR_CS_PerceptualMappingCtrl.NHR_CS_PerceptualMapping();
        test.stopTest();
    }
}