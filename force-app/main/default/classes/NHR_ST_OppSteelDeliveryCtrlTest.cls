@isTest
public class NHR_ST_OppSteelDeliveryCtrlTest {
    public class InputParam {
        @InvocableVariable(required=true)
        public Id recordId;
    }
    @isTest static void test() {
        
        String StId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RecordType_SteelCons').getRecordTypeId();
        Opportunity opp = new Opportunity(Name = 'ST商談' , RecordTypeId = StId,StageName = 'A' ,transtionDateToPhaseJuchuST__c =  Date.Today().addMonths(1)
                                          ,CloseDate =  Date.Today().addMonths(1) , ST_suryou__c = 10
                                          ,ST_chakkou__c =Date.Today().addMonths(-10) ,ST_syukou__c = Date.Today() );
        insert opp;
        List<NHR_ST_OppSteelDeliveryCtrl.InputParam> ins = new List<NHR_ST_OppSteelDeliveryCtrl.InputParam>();
        NHR_ST_OppSteelDeliveryCtrl.InputParam inO = new NHR_ST_OppSteelDeliveryCtrl.InputParam();
        inO.recordId = opp.Id;
        ins.add(inO);
        NHR_ST_OppSteelDeliveryCtrl.exec(ins);
        
        
    }
}