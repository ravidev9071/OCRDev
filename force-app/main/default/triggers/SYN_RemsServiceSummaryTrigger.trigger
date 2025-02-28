trigger SYN_RemsServiceSummaryTrigger on US_WSREMS__REMS_Service_Summary__c (before insert, before Update, before delete, after update, after insert) {
    
    Map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
    String soxProgram = 'Sodium Oxybate REMS';
    String maciProgram = 'Macitentan REMS';
    if(trigger.isBefore && trigger.isInsert){
        Map<String, Map<Id, List<US_WSREMS__REMS_Service_Summary__c>>> prgmRTAndCaseListMap = SYN_REMSServiceValidationHandler.filterServicesByPrgm(Trigger.new); 
            SYN_RemsServiceSummaryTriggerHandler.beforeRssInsert(Trigger.New);
        if(prgmRTAndCaseListMap.containsKey(soxProgram)){
            SYN_RemsServiceValidationHandler.validateServices(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap, Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, Trigger.isInsert, Trigger.isUpdate);        
        //SYN_RemsServiceSummaryTriggerHandler.accountStatusUpdate(Trigger.new, Trigger.oldMap);
        } 
    }
    
    if(trigger.isBefore && trigger.isUpdate){
        Map<String, Map<Id, List<US_WSREMS__REMS_Service_Summary__c>>> prgmRTAndCaseListMap = SYN_REMSServiceValidationHandler.filterServicesByPrgm(Trigger.new); 
        if(prgmRTAndCaseListMap.containsKey(soxProgram)){
            SYN_RemsServiceValidationHandler.validateServices(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap, Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, Trigger.isInsert, Trigger.isUpdate);   
        }
        if(prgmRTAndCaseListMap.containsKey(maciProgram)|| prgmRTAndCaseListMap.containsKey(soxProgram)){
            SYN_RemsServiceSummaryTriggerHandler.SurveyMethod(Trigger.New);        
        //SYN_RemsServiceSummaryTriggerHandler.accountStatusUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    if(trigger.isBefore && Trigger.isDelete){
        
        if(mapBigObjectSettings.KeySet().Contains('REMSService') && mapBigObjectSettings.get('REMSService').IsActive__c == TRUE && (!Test.isRunningTest())){
            
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.old,'US_WSREMS__REMS_Service_Summary__c','Delete');
            system.enqueueJob(qe);
        }
    }
    
    if(trigger.isInsert && Trigger.isAfter){
        Map<String, Map<Id, List<US_WSREMS__REMS_Service_Summary__c>>> prgmRTAndCaseListMap = SYN_REMSServiceValidationHandler.filterServicesByPrgm(Trigger.new); 
        if(mapBigObjectSettings.KeySet().Contains('REMSService') && mapBigObjectSettings.get('REMSService').IsActive__c == TRUE && (!Test.isRunningTest())){
            
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'US_WSREMS__REMS_Service_Summary__c','Insert');
            system.enqueueJob(qe);
        }
        if(prgmRTAndCaseListMap.containsKey(maciProgram)){
            SYN_RemsServiceSummaryTriggerHandler.accountStatusUpdate(Trigger.new, null);
            SYN_RemsServiceSummaryTriggerHandler.createPortalConfirmEmailTask(Trigger.new, null);
        }
        SYN_SharingUtility.createRemsServiceSharingRecs(Trigger.new);
    }
    
    if(trigger.isUpdate && trigger.isAfter){
        Map<String, Map<Id, List<US_WSREMS__REMS_Service_Summary__c>>> prgmRTAndCaseListMap = SYN_REMSServiceValidationHandler.filterServicesByPrgm(Trigger.new);
        List<AsyncRequest__e> publishEvents = new List<AsyncRequest__e>();
        if(mapBigObjectSettings.KeySet().Contains('REMSService') && mapBigObjectSettings.get('REMSService').IsActive__c == TRUE && (!Test.isRunningTest())){ 
            AsyncRequest__e ayncReq = new AsyncRequest__e();
            ayncReq.Object_API_Name__c = 'US_WSREMS__REMS_Service_Summary__c';
            ayncReq.Action_Type__c = 'Update';
            ayncReq.Serialized_List__c = JSON.serialize(trigger.new);
            publishEvents.add(ayncReq);            
            /*SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'US_WSREMS__REMS_Service_Summary__c','Update');
            system.enqueueJob(qe);*/
        }
         
        if(prgmRTAndCaseListMap.containsKey(soxProgram)){
            SYN_RemsServiceSummaryTriggerHandler.certificationCommunication(Trigger.new, Trigger.oldMap);
        }
            SYN_RemsServiceSummaryTriggerHandler.createAffiliationRecs(Trigger.newMap, Trigger.oldMap);
            SYN_RemsServiceSummaryTriggerHandler.createAffiliationRecords(Trigger.newMap, Trigger.oldMap);
        if(prgmRTAndCaseListMap.containsKey(maciProgram)){
            SYN_RemsServiceSummaryTriggerHandler.accountStatusUpdate(Trigger.new, Trigger.oldMap);
            SYN_RemsServiceSummaryTriggerHandler.accountFieldUpdate(Trigger.new, Trigger.oldMap);
            MACIAutomationCommunicationUtility.maciEmailAutomationCommunication(Trigger.new, Trigger.oldMap);
        }    
        if(publishEvents.size()>0){
            EventBus.publish(publishEvents);
        }
    }
}