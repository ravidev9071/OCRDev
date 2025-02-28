trigger SYN_ContentDocumentLinkTrigger on ContentDocumentLink (After insert) {
    
  if(trigger.isafter && trigger.isInsert) {    
        SYN_ContentDocumentLinkTriggerHandler.onAfterInsert(trigger.new);
      
       
    
    }
}