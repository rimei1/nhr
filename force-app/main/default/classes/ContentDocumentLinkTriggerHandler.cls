public with sharing class ContentDocumentLinkTriggerHandler {
    public void handleAfterInsert(Map<Id, ContentDocumentLink> newMap){
        // 商談のContentDocumentLink Idリスト
        List<String> opportunityCdlIdList = new List<String>();
        for(ContentDocumentLink cdl : newMap.values()){
            if(cdl.LinkedEntityId.getSobjectType() == Opportunity.SobjectType){
                opportunityCdlIdList.add(cdl.Id);
            }
        }

        if(!opportunityCdlIdList.isEmpty()){
            // ContentDocumentLink取得
            List<Opportunity> opportunityList = new List<Opportunity>();
            // レコードタイプDeveloperNameリスト
            List<String> developerNameList = new List<String>{'Jukankyo' , 'NT'};

            for(ContentDocumentLink cdlTemp : [SELECT Id, ContentDocument.Title, LinkedEntity.RecordType.DeveloperName FROM ContentDocumentLink WHERE Id IN :opportunityCdlIdList]){
                if(cdlTemp.ContentDocument.Title.contains('見積') && developerNameList.contains(cdlTemp.LinkedEntity.RecordType.DeveloperName)){
                    Opportunity opp = new Opportunity(Id=cdlTemp.LinkedEntityId, ju_mitsumoriup__c = true);
                    opportunityList.add(opp);
                }
            }

            update opportunityList;
        }
    }
}