trigger SYN_VaccinationDataBigObject on Vaccination_Data__c (After insert, After Update, Before Delete) {
 if(trigger.isInsert && Trigger.isAfter)
        {
          map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
          if(mapBigObjectSettings.KeySet().Contains('VaccinationData') && mapBigObjectSettings.get('VaccinationData').IsActive__c==True && (!Test.isRunningTest()))
             {
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'Vaccination_Data__c','Insert');
            if(Limits.getQueueableJobs() == 0) {
            system.enqueueJob(qe);}
             }
             
        }
        if(trigger.isUpdate && Trigger.isAfter)
        {
          map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
          if(mapBigObjectSettings.KeySet().Contains('VaccinationData') && mapBigObjectSettings.get('VaccinationData').IsActive__c==True && (!Test.isRunningTest()))
            {
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'Vaccination_Data__c','Update');
            if(Limits.getQueueableJobs() == 0) {
            system.enqueueJob(qe);}
            }
        } 
        if(trigger.isDelete && Trigger.isBefore)
        {
          map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
          if(mapBigObjectSettings.KeySet().Contains('VaccinationData') && mapBigObjectSettings.get('VaccinationData').IsActive__c==True && (!Test.isRunningTest()))
            {
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.old,'Vaccination_Data__c','Delete');
            system.enqueueJob(qe);
            }
        } 
}