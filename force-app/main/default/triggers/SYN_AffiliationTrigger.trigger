trigger SYN_AffiliationTrigger on US_WSREMS__Affiliation__c (before update, after update,after insert) {

    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            SYN_AffiliationTriggerHandler.beforeUpdateMethod(Trigger.new, trigger.oldMap);
            SYN_AffiliationTriggerHandler.checkUserRole(Trigger.new);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            SYN_AffiliationTriggerHandler.afffilicationAfterMethod(Trigger.new, trigger.oldMap);
        }
    }
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert){
            SYN_AffiliationTriggerHandler.sendAffiliationNotifications(Trigger.New);
        }
    }
   
}