@isTest
public class NHR_ST_DeliveryTonsBatchTest {

    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();
        
        String cron = '0 15 * * * ?';
        
        test.startTest();
            system.Schedule('NHR_ST_DeliveryTonsBatchSchedule', cron, new NHR_ST_DeliveryTonsBatchSchedule());
        test.stopTest();
    }
}