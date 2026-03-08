public class NHR_DX_AccOrgUpdOrderByCtrl {
    //最新組織取得
    @AuraEnabled
    public static void getNewOrgList(String inAccountId){
        Set<String> orgSet = new Set<String>();
        Set<String> oldOrgSet = new Set<String>();
        List<OrgManagement__c> DelList = New List<OrgManagement__c>();
        List<OrgManagement__c> InsList = New List<OrgManagement__c>();
        List<OrgManagement__c> OrgList = New List<OrgManagement__c>();
        List<Contact> conList = New List<Contact>();
        conList = [Select id,Department From Contact where AccountId = :inAccountId];
        if (conList.size() > 0) {
            for (Contact con : conList) {
                if(!orgSet.contains(con.Department)){
                    orgSet.add(con.Department);
                }
            }
            
            OrgList = [Select id,Department__c From OrgManagement__c where Account__c = :inAccountId];
            for (OrgManagement__c org : OrgList) {
                if(!orgSet.contains(org.Department__c)){
                    DelList.add(org);
                } else {
                    if(!oldOrgSet.contains(org.Department__c)){
                        oldOrgSet.add(org.Department__c);
                    }
                }
            }
            
            for (String orgStr : orgSet) {
                if(!oldOrgSet.contains(orgStr)) {
                    InsList.add(new OrgManagement__c(Account__c = inAccountId,Department__c=orgStr));
                }
            }
            
            if(DelList.size() > 0) {
                delete DelList;
            }
            
            if(InsList.size() > 0) {
                insert InsList;
            }
        }
    }
    
    //並び順更新
    @AuraEnabled
    public static void setOrgOrderBy(String inAccountId){
        Map<String ,Map<String ,decimal>> orgMap = new Map<String ,Map<String ,decimal>>();
        List<OrgManagement__c> orgList = new List<OrgManagement__c>();
        orgList = [Select id ,Department__c ,Account__c ,OrderBy__c 
                          From OrgManagement__c
                           Where Account__c = :inAccountId];
        
        if (orgList.size() > 0) {
            for (OrgManagement__c obj : orgList) {
                if (orgMap.containskey(obj.Account__c)) {
                    Map<String ,decimal> tempMap = orgMap.get(obj.Account__c);
                    tempMap.put(obj.Department__c,obj.OrderBy__c );
                    orgMap.put(obj.Account__c,tempMap );
                } else {
                    Map<String ,decimal> tempMap = new Map<String ,decimal>();
                    tempMap.put(obj.Department__c,obj.OrderBy__c );
                    orgMap.put(obj.Account__c,tempMap );
                }
            }

            List<Contact> conUpdList = New List<Contact>();
            conUpdList = [Select id ,OrderBy__c ,Department ,AccountId ,Account.Name
                          From Contact
                          Where AccountId = :inAccountId];
            if (orgList.size() > 0) {
                for(Contact obj : conUpdList) {
                    if (orgMap.containskey(obj.AccountId)) {
                        Map<String ,decimal> tempMap = orgMap.get(obj.AccountId);
                        if (tempMap.containskey(obj.Department)) {
                            obj.OrderBy__c = tempMap.get(obj.Department);
                        } else {
                            obj.OrderBy__c = null;
                        }
                    } else {
                        obj.OrderBy__c = null;
                    }
                }
                
                NHR_DX_AccOrgUpdOrderByBatch myBatchObject = new NHR_DX_AccOrgUpdOrderByBatch(conUpdList);
                Database.executeBatch(myBatchObject,Integer.valueOf(System.Label.NHR_Contact_OrderNum) );
                
                /*
                List<Contact> conUpdSubList = New List<Contact>();
                for(Contact con : conUpdList) {
                    conUpdSubList.add(con);
                    if(conUpdList.size() > Integer.valueOf(System.Label.NHR_Contact_OrderNum) ) {
                        update conUpdSubList;
                        conUpdSubList = New List<Contact>();
                    }
                }
                
                if(conUpdSubList.size() > 0) {
                    update conUpdSubList;
                }*/

            }
        }
    }
        
}