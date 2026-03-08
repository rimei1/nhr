trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.handleAfterInsert(Trigger.newMap);
        }
    }
}