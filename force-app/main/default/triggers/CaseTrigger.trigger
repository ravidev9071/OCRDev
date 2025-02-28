trigger CaseTrigger on Case (after insert, after update, before delete) 
{
    map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
    if(trigger.isInsert && trigger.isAfter)
    {
        list<case> lstCase = new list<case>();
        for(case caseInfo: trigger.new)
        {
            if(caseInfo.Status== system.label.Case_Close_Status)
            {
                lstCase.add(caseInfo);
            }
        }
        if(!lstCase.isEmpty())
        {
            CaseTriggerHandler.caseFollowupTaskCreate(lstCase);
        }
        
        /**if(mapBigObjectSettings.KeySet().Contains('Case') && mapBigObjectSettings.get('Case').IsActive__c==True)
        {
           SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'Case','Insert');
           system.enqueueJob(qe); 
        }**/
    }
    if(trigger.isupdate && trigger.isAfter)
    {
        list<case> lstCase = new list<case>();
        for(case caseInfo: trigger.new)
        {
            if(caseInfo.Status== system.label.Case_Close_Status && trigger.oldMap.get(caseInfo.id).status!=caseInfo.Status)
            {
                lstCase.add(caseInfo);
            }
        }
        if(!lstCase.isEmpty())
        {
            CaseTriggerHandler.caseFollowupTaskCreate(lstCase);
        }
        
        /***if(mapBigObjectSettings.KeySet().Contains('Case') && mapBigObjectSettings.get('Case').IsActive__c==True)
        {
           SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'Case','Update');
           system.enqueueJob(qe); 
        }***/    
    }
    /***if(trigger.isDelete && trigger.isBefore)
    {
        if(mapBigObjectSettings.KeySet().Contains('Case') && mapBigObjectSettings.get('Case').IsActive__c==True)
        {
           SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'Case','Delete');
           system.enqueueJob(qe); 
        }
    }*****/
    
    
    //bigobject creation process
  /* map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
   system.debug('-------------'+mapBigObjectSettings);
   if(mapBigObjectSettings.KeySet().Contains('Case') && mapBigObjectSettings.get('Case').IsActive__c==True)
   {
       SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'case');
       system.enqueueJob(qe); 
   }*/
    
}