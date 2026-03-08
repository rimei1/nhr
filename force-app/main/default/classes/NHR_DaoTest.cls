@isTest
public class NHR_DaoTest {

    @isTest static void test() {
        NHR_Dao.get_NHR_EN_SalesReportBatch('','');
        NHR_Dao.get_NHR_EN_SalesReportBatch2('','');
        NHR_Dao.get_NHR_EN_SalesReportBatch3('','');
        NHR_Dao.get_NHR_EN_SalesReportBatch4('','');
        NHR_Dao.get_NHR_EN_SalesReportBatch5('','');
        NHR_Dao.get_NHR_EN_OrderAmountListBatch('','');
        NHR_Dao.get_NHR_SL_SalesManagementBatch();
        NHR_Dao.get_NHR_SL_SalesManagementBatch2();
        NHR_Dao.get_NHR_JU_BPOKPIKGIReport();
        NHR_Dao.get_NHR_EN_SalesReportCtrl('');
        NHR_Dao.get_NHR_EN_OrderAmountListBatch2('','');
        NHR_Dao.get_NHR_EN_OrderAmountListOsakaBatch();
        NHR_Dao.get_NHR_EN_OrderAmountListOsakaBatch2(); 
        NHR_Dao.get_NHR_EN_AccountOrderTargetBatch('','');
        NHR_Dao.get_NHR_EN_AccountSalesTargetBatch('','');
        NHR_Dao.get_NHR_EN_SalesReviewMeetingEY('','');
        
        NHR_Dao.get_NHR_EN_SalesReviewMeetingOpp('','');
        NHR_Dao.get_NHR_EN_ConOppOrderBatch('','');
        NHR_Dao.get_NHR_EN_ConOrderBatch('','');
        NHR_Dao.get_NHR_ST_QuantityActualPlansBatch2();
        NHR_Dao.get_NHR_ST_QuantityActualPlansCtrl('');
        Date d = Date.Today();
        NHR_Dao.getFiscalYearStartDate(d);
        NHR_Dao.getFiscalYearEndDate(d);
        NHR_Dao.getDivision(1,1);
        NHR_Dao.getYear(d);
        NHR_Dao.getFiscalYear(d);
        NHR_Dao.getFiscalYearStr(d);
        NHR_Dao.getNext10FiscalYear('12');
        NHR_Dao.get_NHR_ST_DeliveryTonsBatch();
        
        NHR_Dao.get_NHR_ST_OppSnapshotDashboardPreBatch();
        NHR_Dao.get_NHR_ST_OppSnapshotDashboardBatch();
        NHR_Dao.get_NHR_ST_OppSnapshotDashboardBatch2();
        NHR_Dao.get_NHR_ST_OppSnapshotDashboardBatch4();
    }
}