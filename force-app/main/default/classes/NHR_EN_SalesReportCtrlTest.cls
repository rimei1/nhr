@isTest
public class NHR_EN_SalesReportCtrlTest {

    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();

        NHR_EN_SalesReportCtrl ne = new NHR_EN_SalesReportCtrl();
        /*
        PageReference pr = Page.NHR_EN_SalesReport;
        pr.getParameters().put('kubun', '本社');
        pr.getContent();
*/
    }
}