trigger SYN_ShippingAndTrackingBigObject on US_WSREMS__Shipping_and_Tracking__c (After insert, After Update, Before Delete) {

 
   
       if(trigger.isInsert && Trigger.isAfter)
        {
          map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
          if(mapBigObjectSettings.KeySet().Contains('ShippingTracking') && mapBigObjectSettings.get('ShippingTracking').IsActive__c==True && (!Test.isRunningTest()))
             {
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'US_WSREMS__Shipping_and_Tracking__c','Insert');
            if(Limits.getQueueableJobs() == 0) {
            system.enqueueJob(qe);}
             }
             
        }
        if(trigger.isUpdate && Trigger.isAfter)
        {
          map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
          if(mapBigObjectSettings.KeySet().Contains('ShippingTracking') && mapBigObjectSettings.get('ShippingTracking').IsActive__c==True && (!Test.isRunningTest()))
            {
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'US_WSREMS__Shipping_and_Tracking__c','Update');
            if(Limits.getQueueableJobs() == 0) {
            system.enqueueJob(qe);}
            }
        } 
        if(trigger.isDelete && Trigger.isBefore)
        {
          map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
          if(mapBigObjectSettings.KeySet().Contains('ShippingTracking') && mapBigObjectSettings.get('ShippingTracking').IsActive__c==True && (!Test.isRunningTest()))
            {
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.old,'US_WSREMS__Shipping_and_Tracking__c','Delete');
            system.enqueueJob(qe);
            }
        } 
   
   
}