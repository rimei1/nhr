public class RecordCloneController {
    
    @AuraEnabled
    public static sObjectSummary getSObjectSummary(Id recordId, String childRelationshipNames, String excludedFieldNames) {
        return sObjectSummary.getByRecordId(recordId, childRelationshipNames, excludedFieldNames);
    }
    
    @AuraEnabled
    public static String getNameFieldValue(Id recordId, String objectName, String nameField) {
        sObject sobj = Database.query('SELECT ' + nameField + ' FROM ' + objectName + ' WHERE Id = \'' + recordId + '\'');
        return (String) sobj.get(nameField);
    }
    
    @AuraEnabled
    public static sObject execClone(
        Id recordId, String newParentRecordName, String childRelationshipNames, 
        String excludedFieldNames, String childRecordNameType)
    {
        
        // クローン対象のsObjectの概要を取得
        sObjectSummary sObjSummary = sObjectSummary.getByRecordId(recordId, childRelationshipNames, excludedFieldNames);
        
        // 新規レコード名がない場合はエラーを返す。
        if(sObjSummary.isNamable && String.isBlank(newParentRecordName)) {
            return null;
        }
        
        // クローン元になるレコードを取得
        sObject originalRecord = RecordCloneHandler.getOriginalRecord(recordId, sObjSummary);
        
        // クローンを実行
        sObject clonedRecord = RecordCloneHandler.cloneRecord(originalRecord, sObjSummary, newParentRecordName, childRecordNameType);
        
        return clonedRecord;
    }
    
    // 複数レコードクローン用のカスタムメタデータ
    // 対象オブジェクト
    // 子レコード名命名規則
    // 親レコード名命名規則
    // クローン対象の子レコード名
    
    @InvocableMethod(label='Clone records' description='Cloning multiple records by passing recordIds' category= 'Record Clone')
    public static List<List<Id>> clone (List<List<Id>> recordIds) {
        if(recordIds.size() <= 0 || recordIds[0].size() <= 0) return null;
        
        List<List<Id>> clonedRecordList = new List<List<Id>>();
        for(List<Id> rids : recordIds) {
            if(rids.size() <= 0) continue;

            // 先頭のレコードから、sObjectSummaryを取得
            sObjectSummary sObjSummary = sObjectSummary.getByRecordId(rids[0]);

            // クローン元になるレコードを取得
            List<sObject> originalRecords = RecordCloneHandler.getOriginalRecords(rids, sObjSummary);

            // クローンを実行
            Map<Id, sObject> clonedRecords = new Map<Id, sObject>(RecordCloneHandler.cloneRecords(originalRecords, sObjSummary));
            
            clonedRecordList.add(new List<Id>(clonedRecords.keySet()));
        }
        
        return clonedRecordList;
    }
   
    
}