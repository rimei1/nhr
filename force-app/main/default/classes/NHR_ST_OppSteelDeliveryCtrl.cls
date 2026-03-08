public class NHR_ST_OppSteelDeliveryCtrl{
    public class InputParam {
        @InvocableVariable(required=true)
        public Id recordId;
    }

    @InvocableMethod(label='ST_着工/竣工日間の「月数分」で、数量を月次t数として均等割当したい')
    public static void exec(List<InputParam> inputs){
        
        Id OppId = inputs[0].recordId;

        Opportunity opp = [Select Id , ST_chakkou__c,ST_syukou__c,ST_suryou__c 
                           From Opportunity
                           Where Id = :OppId ];
        String sdSoql = NHR_Dao.get_NHR_ST_SuryouSet(opp.Id);
        
        List<Steel_delivery__c> sdList = Database.query(sdSoql);

        if(sdList != NULL && sdList.size() > 0) {
            
            Steel_delivery__c sd = sdList[0];
            reSetSteel_delivery(sd);
            Date d1 = opp.ST_chakkou__c;
            Date d2 = opp.ST_syukou__c;
            
            Decimal monthsDiff = (d2.year() - d1.year()) * 12 + (d2.month() - d1.month() + 1);
            
            Decimal base = Math.floor(opp.ST_suryou__c/monthsDiff);  // 商
            Decimal remainder = opp.ST_suryou__c - base * monthsDiff; // 余り
            system.debug('base:'+base);
            system.debug('remainder:'+remainder);
            system.debug('monthsDiff:' + monthsDiff);
            for (integer i = 0; i < monthsDiff; i++) {
                String apiName = setAPIName(d1.addMonths(i));
                if (i == monthsDiff - 1) {
                    // 最後の要素に余りを加算
                    sd.put(apiName , base + remainder);
                } else {
                    sd.put(apiName , base );
                }
            }
            update sd;
        }
    }
    
    /**
     * API取得
     */
    public static void reSetSteel_delivery(Steel_delivery__c obj){
        Schema.SObjectType sType = (Schema.SObjectType)Schema.getGlobalDescribe().get('Steel_delivery__c');
        Schema.DescribeSObjectResult sObjectResult = sType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjectResult.fields.getMap();

        String selectFields = '';
        for (Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            String selectField = fieldResult.getName();
            if (selectField.startsWith('X20')) {
                obj.put(selectField , null);
            }
        }
        update obj;
    }
    
    /**
     * API取得
     */
    private static String setAPIName(Date inDate){
        String inDateYear = String.ValueOf(inDate.Year());
        String inDateMonth = String.ValueOf(inDate.Month());
        String res = 'X' + inDateYear + '_' + inDateMonth + '__c';
        return res;
    }
}