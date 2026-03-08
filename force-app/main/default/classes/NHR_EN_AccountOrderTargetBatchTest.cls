@isTest
public class NHR_EN_AccountOrderTargetBatchTest {

    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();

         List<en_yojitsu__c > tempList = NHR_TestDataFactory.getEn_yojitsu();
        system.debug('tempList:' + tempList);
        NHR_EN_CreateExcelCtrl.Call_AccountOrderTargetBatch('全社', NHR_Constant.UNIT1);
    }
    
    @isTest static void test2() {
        NHR_TestDataFactory.createAllMstData();

         List<en_yojitsu__c > tempList = NHR_TestDataFactory.getEn_yojitsu();
        system.debug('tempList:' + tempList);
        NHR_EN_CreateExcelCtrl.Call_AccountOrderTargetBatch('大阪', NHR_Constant.UNIT3);
    }
}