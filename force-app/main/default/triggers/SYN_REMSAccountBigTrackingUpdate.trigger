trigger SYN_REMSAccountBigTrackingUpdate on Account (after insert, after update) 
{
   map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
   if(mapBigObjectSettings.KeySet().Contains('Account') && mapBigObjectSettings.get('Account').IsActive__c==True)
   {
       if(trigger.isInsert && Trigger.isAfter)
        {
          /*  SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'Account','Insert');
            system.enqueueJob(qe);*/
        }
        if(trigger.isUpdate && Trigger.isAfter)
        {
            /*SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'Account','Update');
            system.enqueueJob(qe);*/
        } 
   }
   
}