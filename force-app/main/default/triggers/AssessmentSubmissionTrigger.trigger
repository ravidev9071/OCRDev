trigger AssessmentSubmissionTrigger on US_WSREMS__Assessment_Submission__c (after insert, after update, before delete) {
    if(SYN_CommonUtility.triggerByPass())
    return;
    if(trigger.isupdate && trigger.isAfter) {  
        Set<Id> setId = new Set<Id>();
        for(US_WSREMS__Assessment_Submission__c asRec : Trigger.new){
            if(asRec.US_WSREMS__Case__c != null){
                setId.add(asRec.US_WSREMS__Case__c);
            }
        }

        if(!setId.isEmpty()){
            List<Case> listCases = [SELECT Id, US_WSREMS__Program_Picklist__c,US_WSREMS__Program_Name__c, RecordTypeId FROM Case WHERE Id IN: setId];
            Map<String, Map<Id, List<Case>>> prgmRTAndCaseListMap = SYN_CaseTriggerHanlder.filterCasesByPrgm(listCases);
            if(prgmRTAndCaseListMap.containsKey(SYN_Utilitycls.AVEED_PROGRAM_NAME)){ 
                AutomationCommunicationFromCase.sendEmailForKAResponses(Trigger.newMap, Trigger.oldMap);
                AVEEDAutomationCommunicationUtility.sendFaxForKAResponses(Trigger.newMap, Trigger.oldMap);
            }
        }
    }
}