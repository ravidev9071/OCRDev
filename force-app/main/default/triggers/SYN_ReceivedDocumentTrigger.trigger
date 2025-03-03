trigger SYN_ReceivedDocumentTrigger on ReceivedDocument(before insert,after insert, before delete, after update,before update) {

    List<AsyncRequest__e> publishEvents = new List<AsyncRequest__e>();     
    if(trigger.isInsert && trigger.isBefore){
        SYN_ReceivedDocumentTriggerHandler.updateREMSProgram(trigger.new);
        //SYN_ReceivedDocumentTriggerHandler.updateOwnerQueue(trigger.new);

    }else if(trigger.isInsert && trigger.isAfter){
        
        SYN_SharingUtility.createShareRecordsList(trigger.new, 'ReceivedDocumentShare','ReceivedDocument');

        //Big object
        map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
        if(mapBigObjectSettings.KeySet().Contains('ReceivedDocument') && mapBigObjectSettings.get('ReceivedDocument').IsActive__c==True && (!Test.isRunningTest())){
            /*    
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'ReceivedDocument','Insert');
            system.enqueueJob(qe); 
            */
            AsyncRequest__e ayncReq = new AsyncRequest__e();
            ayncReq.Object_API_Name__c = 'ReceivedDocument';
            ayncReq.Action_Type__c = 'Insert';
            ayncReq.Serialized_List__c = JSON.serialize(trigger.new);
            publishEvents.add(ayncReq);
        }
    }else if(trigger.isUpdate && trigger.isAfter){
    
        SYN_ReceivedDocumentTriggerHandler.updateShareRecord(trigger.newMap,trigger.oldMap);

         //Big object
         map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
         if(mapBigObjectSettings.KeySet().Contains('ReceivedDocument') && mapBigObjectSettings.get('ReceivedDocument').IsActive__c==True && (!Test.isRunningTest()))
         {
         /*
         SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'ReceivedDocument','Update');
         system.enqueueJob(qe); 
         */
        AsyncRequest__e ayncReq = new AsyncRequest__e();
        ayncReq.Object_API_Name__c = 'ReceivedDocument';
        ayncReq.Action_Type__c = 'Update';
        ayncReq.Serialized_List__c = JSON.serialize(trigger.new);
        publishEvents.add(ayncReq); 
         }
    }else if(trigger.isbefore && trigger.isupdate ){
        
    	//SYN_ReceivedDocumentTriggerHandler.updateREMSProgram(trigger.new);
        SYN_ReceivedDocumentTriggerHandler.updateProcessingStatus(trigger.new,trigger.oldMap);
        SYN_ReceivedDocumentTriggerHandler.updateAssignedProcessingTime(trigger.new);
    }
    else if (trigger.isbefore && trigger.isDelete){

        //Big object
        map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
        if(mapBigObjectSettings.KeySet().Contains('ReceivedDocument') && mapBigObjectSettings.get('ReceivedDocument').IsActive__c==True && (!Test.isRunningTest()))
        {
        /*
        SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'ReceivedDocument','delete');
        system.enqueueJob(qe); 
        */
        AsyncRequest__e ayncReq = new AsyncRequest__e();
        ayncReq.Object_API_Name__c = 'ReceivedDocument';
        ayncReq.Action_Type__c = 'delete';
        ayncReq.Serialized_List__c = JSON.serialize(trigger.old);
        publishEvents.add(ayncReq); 
        }
    }
    if(publishEvents.size()>0){
        EventBus.publish(publishEvents);
    }
}