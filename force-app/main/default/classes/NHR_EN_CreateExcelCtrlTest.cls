@isTest
public class NHR_EN_CreateExcelCtrlTest {

    @isTest static void test() {
        NHR_EN_CreateExcelCtrl.Call_EN_SalesReportStart('東京', NHR_Constant.UNIT3);
        NHR_EN_CreateExcelCtrl.Call_EN_SalesReportStart('大阪',NHR_Constant.UNIT1);
 
        NHR_EN_CreateExcelCtrl.Call_EN_OrderAmountList('東京',NHR_Constant.UNIT3);
        NHR_EN_CreateExcelCtrl.Call_EN_OrderAmountList('大阪', NHR_Constant.UNIT1);
        NHR_EN_CreateExcelCtrl.Call_EN_OrderAmountListOsaka();
        NHR_EN_CreateExcelCtrl.Call_AccountOrderTargetBatch('東京', NHR_Constant.UNIT1);
        NHR_EN_CreateExcelCtrl.Call_AccountOrderTargetBatch('大阪', NHR_Constant.UNIT3); 

    }
    
    @isTest static void test2() {

        NHR_EN_CreateExcelCtrl.Call_ConOppOrderBatch('東京', NHR_Constant.UNIT1);
        NHR_EN_CreateExcelCtrl.Call_ConOppOrderBatch('大阪', NHR_Constant.UNIT3);
        NHR_EN_CreateExcelCtrl.Call_ConOrderBatch('東京', NHR_Constant.UNIT1);
        NHR_EN_CreateExcelCtrl.Call_ConOrderBatch('大阪', NHR_Constant.UNIT3);
        
        NHR_EN_CreateExcelCtrl.Call_AccountSalesTargetBatch('東京', NHR_Constant.UNIT1);
        NHR_EN_CreateExcelCtrl.Call_AccountSalesTargetBatch('大阪', NHR_Constant.UNIT3);
        NHR_EN_CreateExcelCtrl.Call_SalesReviewMeetingBatch('東京', NHR_Constant.UNIT1);
        NHR_EN_CreateExcelCtrl.Call_SalesReviewMeetingBatch('大阪', NHR_Constant.UNIT3);
        NHR_EN_CreateExcelCtrl.Call_NHR_ST_QuantityRatioBatch();
        
    }
    
    @isTest static void test3() {
        NHR_EN_CreateExcelNewCtrl.Call_EN_SalesReportStart('東京', NHR_Constant.UNIT3);
        NHR_EN_CreateExcelNewCtrl.Call_EN_SalesReportStart('大阪',NHR_Constant.UNIT1);
 
        NHR_EN_CreateExcelNewCtrl.Call_EN_OrderAmountList('東京',NHR_Constant.UNIT3);
        NHR_EN_CreateExcelNewCtrl.Call_EN_OrderAmountList('大阪', NHR_Constant.UNIT1);
        NHR_EN_CreateExcelNewCtrl.Call_EN_OrderAmountListOsaka();
        NHR_EN_CreateExcelNewCtrl.Call_AccountOrderTargetBatch('東京', NHR_Constant.UNIT1);
        NHR_EN_CreateExcelNewCtrl.Call_AccountOrderTargetBatch('大阪', NHR_Constant.UNIT3); 

    }
    
    @isTest static void test4() {

        NHR_EN_CreateExcelNewCtrl.Call_ConOppOrderBatch('東京', NHR_Constant.UNIT1);
        NHR_EN_CreateExcelNewCtrl.Call_ConOppOrderBatch('大阪', NHR_Constant.UNIT3);
        NHR_EN_CreateExcelNewCtrl.Call_ConOrderBatch('東京', NHR_Constant.UNIT1);
        NHR_EN_CreateExcelNewCtrl.Call_ConOrderBatch('大阪', NHR_Constant.UNIT3);
        
        NHR_EN_CreateExcelNewCtrl.Call_AccountSalesTargetBatch('東京', NHR_Constant.UNIT1);
        NHR_EN_CreateExcelNewCtrl.Call_AccountSalesTargetBatch('大阪', NHR_Constant.UNIT3);
        NHR_EN_CreateExcelNewCtrl.Call_SalesReviewMeetingBatch('東京', NHR_Constant.UNIT1);
        NHR_EN_CreateExcelNewCtrl.Call_SalesReviewMeetingBatch('大阪', NHR_Constant.UNIT3);
        NHR_EN_CreateExcelNewCtrl.Call_NHR_ST_QuantityRatioBatch();
        
    }
}