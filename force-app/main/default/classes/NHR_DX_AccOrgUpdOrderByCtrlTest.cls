@isTest
public class NHR_DX_AccOrgUpdOrderByCtrlTest {

    @isTest static void test() {
        NHR_TestDataFactory.createAllMstData();
        Account acc = [Select id From Account limit 1];
        NHR_DX_AccOrgUpdOrderByCtrl.getNewOrgList(acc.id);
        NHR_DX_AccOrgUpdOrderByCtrl.setOrgOrderBy(acc.id); 

    }
}