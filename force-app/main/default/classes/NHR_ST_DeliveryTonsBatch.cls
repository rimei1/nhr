/*
*スチール_納品トン数objの当月以降（当月含む）のトン数を商談objの項目に積み上げ
*/
global without sharing class NHR_ST_DeliveryTonsBatch implements Database.Batchable<sObject>, Database.Stateful{

    global Integer thisYear {get;set;}
    global Integer thisMonth {get;set;}

    global NHR_ST_DeliveryTonsBatch(){

    }
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('NHR_ST_DeliveryTonsBatch');
        thisYear = Date.Today().Year();
        thisMonth = Date.Today().Month();
    	String query = NHR_Dao.get_NHR_ST_DeliveryTonsBatch();
        return Database.getQueryLocator(query);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<Steel_delivery__c> scopes){
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        for(Steel_delivery__c obj : scopes) {
            Opportunity tempOpp = new Opportunity();
            tempOpp.Id = obj.Opp__c;
            Integer nextYears = Integer.valueOf(System.Label.NHR_ST_Years);
            Decimal restTons = 0;
            for (integer i = 0 ; i < nextYears*12 ; i++) {
                String apiName = setAPIName(thisYear ,thisMonth ,i);
                system.Debug('apiName:' + apiName);
                restTons += obj.get(apiName) == null ?  0 : Decimal.valueOf(String.valueOf(obj.get(apiName)))  ;
            }
            tempOpp.ST_Tons_Onwards__c = restTons;
            oppMap.put(obj.Opp__c ,tempOpp);
        }
        
        update oppMap.values();
    }

     //完了
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    /**
     * API取得
     */
    private String setAPIName(Integer inYears ,Integer inMonth ,Integer num){
        String apiName = 'X';
        Integer yearInt = inYears + Integer.valueOf(Decimal.valueOf( (inMonth+num)/12).round(System.RoundingMode.DOWN));
        Integer monthInt = math.mod(inMonth+num, 12) == 0 ? 12 : math.mod(inMonth+num, 12);
        apiName += String.ValueOf(yearInt) + '_' + String.ValueOf(monthInt) + '__c';
        return apiName;
    }

}