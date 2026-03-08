public class RecordCloneHandler {
    
    // TODO: error handling, try catch.
    // single records
    public static sObject getOriginalRecord(Id recordId, sObjectSummary sObjSummary) {
        
        // TODO : filterClonableFieldsじゃないやつも取ってくるフラグにする
        // TODO : CaseのClosedDateがnullじゃない or IsClosedがtrueの場合、Statusを空にできるようにするなどの、例外処理を開発しやすくする準備を仕込む。

        // Build query string
        String q = 'SELECT Id, ' + String.join(sObjSummary.filterClonableFields(), ',') + buildChildrenSelectQuery(sObjSummary) + ' FROM ' + sObjSummary.apiName + ' WHERE Id = \'' + recordId + '\'';
        return Database.query(q);
    }
        
    // multiple records
    public static List<sObject> getOriginalRecords(List<Id> recordIds, sObjectSummary sObjSummary) {
        // Build query string
        String q = 'SELECT Id, ' + String.join(sObjSummary.filterClonableFields(), ',') + buildChildrenSelectQuery(sObjSummary) + ' FROM ' + sObjSummary.apiName + ' WHERE Id IN (\'' + String.join(recordIds, '\',\'') + '\' )';
        return Database.query(q);
    }
    
    public static sObject cloneRecord(
        sObject cloned, 
        sObjectSummary sObjectSummary, 
        String newRecordName, 
        String childRecordNameType
    ) {
        
        // TODO: try catch error handling
        
        // remove original record ID, then insert.
        cloned.Id = null;
        if(sObjectSummary.isNamable) {
            cloned.put(sObjectSummary.nameField, newRecordName);
        }
        insert cloned;
        
        if(sObjectSummary.children != null && sObjectSummary.children.keySet().size() > 0) {
            
            // append to child records' name fields
            String todayStr = Datetime.now().format('yyyy/MM/dd HH:mm');
            
            // remove child record IDs, assign then cloned parent record Id to ref field
            for(String childRelName : sObjectSummary.children.keySet()) {
                sObjectSummary childSummary = sObjectSummary.children.get(childRelName);
                
                if(!childSummary.isClonable) continue;
                sObject[] children;
                try {
                    children = cloned.getSObjects(childRelName);
                } catch(System.SObjectException e) {
                    // TODO : handle error with proper exception class.
                    continue;
                }
                if(children == null) continue;
                
                // On creating an opportunity record, system automatically creates an OpportunityContactRole record.
                // Delete the created record as of now.
                if(sObjectSummary.apiName == 'Opportunity' && childRelName == 'OpportunityContactRoles') {
                    OpportunityContactRole[] ocrs = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = :cloned.Id];
                    delete ocrs;
                }
                
                for(Integer i = 0; i < children.size(); i++) {
                    children[i].put('Id', null);
                    if(childSummary.isNamable) {
                        String nameValue;
                        if(childRecordNameType == '2') {
                            nameValue = 'Cloned - ' + (String) children[i].get(childSummary.nameField);
                        } else if(childRecordNameType == '3') {
                            nameValue = 'Cloned - ' + (String) children[i].get(childSummary.nameField) + ' - ' + todayStr;
                        } else {
                            nameValue = (String) children[i].get(childSummary.nameField);
                        }
                        children[i].put(childSummary.nameField, nameValue);
                    }
                    
                    children[i].put(childSummary.parentRelationshipField, cloned.Id);
                }
                insert children;
            }
        }
        
        // TODO: return created object name and total created record cound
        return cloned;
    }
    
    private static String buildChildrenSelectQuery(sObjectSummary sObjSummary) {
        // concatenate clonable field names of child sObjects to build SOQL string
        String childrenSelect = '';
        if(sObjSummary.children != null && sObjSummary.children.size() > 0) {
            for (String childRelName : sObjSummary.children.keySet()){
                sObjectSummary child = sObjSummary.children.get(childRelName);
                List<String> childFields = child.filterClonableFields();
                if(child.isClonable && childFields.size() > 0) {
                    childrenSelect += ', ( SELECT Id, ' + String.join(childFields, ',') + ' FROM ' + childRelName + ' )';
                }
            }
        }
        return childrenSelect;
    }

    
    public static List<sObject> cloneRecords(List<sObject> clonings, sObjectSummary sObjectSummary) {
        
        for(sObject cloning : clonings) {
            cloning.Id = null;
            if(sObjectSummary.isNamable) {
                // 親レコード名
                // cloning.put(sObjectSummary.nameField, newRecordName);
            }
        }
        
        insert clonings;
        
        if(sObjectSummary.children != null && sObjectSummary.children.keySet().size() > 0) {
            
            // append to child records' name fields
            // String todayStr = Datetime.now().format('yyyy/MM/dd HH:mm');
            
            // remove child record IDs, assign then cloned parent record Id to ref field
            List<sObject> childrens = new List<sObject>();
            List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>();
            for(String childRelName : sObjectSummary.children.keySet()) {
                sObjectSummary childSummary = sObjectSummary.children.get(childRelName);
                
                if(!childSummary.isClonable) continue;
                
                for(sObject cloning : clonings) {
                    sObject[] children;
                    try {
                        children = cloning.getSObjects(childRelName);
                    } catch(System.SObjectException e) {
                        // TODO : handle error with proper exception class.
                        continue;
                    }
                    if(children == null) continue;
                    
                    // On creating an opportunity record, system automatically creates an OpportunityContactRole record.
                    // Delete the created record as of now.
                    if(sObjectSummary.apiName == 'Opportunity' && childRelName == 'OpportunityContactRoles') {
                        ocrs.addAll([SELECT Id FROM OpportunityContactRole WHERE OpportunityId = :cloning.Id]);
                    }
                    
                    for(Integer i = 0; i < children.size(); i++) {
                        children[i].put('Id', null);
                        if(childSummary.isNamable) {
                            String nameValue = (String) children[i].get(childSummary.nameField);
                            children[i].put(childSummary.nameField, nameValue);
                        }
                        
                        children[i].put(childSummary.parentRelationshipField, cloning.Id);
                    }
                    childrens.addAll(children);
                }
            }
            delete ocrs;
            insert childrens;
            
        }
        
        // TODO: return created object name and total created record cound
        return clonings;
    }
    
}