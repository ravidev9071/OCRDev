trigger SYN_DocumentCheckListItemTrigger on DocumentChecklistItem (before insert, before update, after insert, before delete, after update) {
    
    if(Trigger.isBefore){
        
        if(Trigger.isInsert){
            
            SYN_DocCheckListItemTriggerHandler.beforeInsertHandler(trigger.new);
         
        }else if(Trigger.isUpdate){
        
            SYN_DocCheckListItemTriggerHandler.beforeUpdateHandler(trigger.newMap,trigger.oldMap);
            SYN_DocCheckListItemTriggerHandler.UpdateSecondReviewer(Trigger.new);
            SYN_DocCheckListItemTriggerHandler.calculateTotalSLA(Trigger.new);
         }
        
        
        
    }else if(Trigger.isAfter){
        
        if(Trigger.isInsert){
            SYN_SharingUtility.createShareRecordsList(trigger.new, 'DocumentChecklistItemShare','DocumentCheckListItem');
            SYN_DocCheckListItemTriggerHandler.afterInsertHandler(trigger.newMap,trigger.oldMap);

            //Big object
            map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
            if(mapBigObjectSettings.KeySet().Contains('DocumentChecklistItem') && mapBigObjectSettings.get('DocumentChecklistItem').IsActive__c==True && (!Test.isRunningTest()))
            {
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'DocumentChecklistItem','Insert');
            system.enqueueJob(qe); 
            }
            
        }else if(Trigger.isUpdate){
            //Big object
            map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
            
            if(mapBigObjectSettings.KeySet().Contains('DocumentChecklistItem') && mapBigObjectSettings.get('DocumentChecklistItem').IsActive__c==True && (!Test.isRunningTest()))
            {
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'DocumentChecklistItem','Update');
            system.enqueueJob(qe); 
            }
            SYN_DocCheckListItemTriggerHandler.afterUpdateHandler(trigger.newMap,trigger.oldMap);
            SYN_DocCheckListItemTriggerHandler.updateShareRecord(trigger.newMap,trigger.oldMap);
            SYN_DocCheckListItemTriggerHandler.createTaskOnSecondaryReview(trigger.new,trigger.oldMap);

            
        }
    }

        if(Trigger.isBefore){
        
            if(Trigger.isDelete){
    
                //Big object
                map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
                if(mapBigObjectSettings.KeySet().Contains('DocumentChecklistItem') && mapBigObjectSettings.get('DocumentChecklistItem').IsActive__c==True && (!Test.isRunningTest()))
                {
                SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.old,'DocumentChecklistItem','Delete');
                system.enqueueJob(qe); 
                }
    
            }
        }
        
}