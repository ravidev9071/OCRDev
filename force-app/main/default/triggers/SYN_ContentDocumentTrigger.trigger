trigger SYN_ContentDocumentTrigger on ContentDocument (Before delete ) {
    
	if(Trigger.isDelete && Trigger.isBefore){
	
		SYN_ContentDocTriggerHandler.beforeDeleteHandler(Trigger.old);
	}
}