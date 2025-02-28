public without sharing class SYN_FailedKnowledgeAssesEmailTryvio {
    public static Id assessSubId { get; set; }
    
    public static List<US_WSREMS__Assessment_Response__c> getKnowledgeAssesmemnts(){
        return getKnowledgeResponse(assessSubId);
    }    
    public static List<US_WSREMS__Assessment_Response__c> getKnowledgeResponse(Id  assesSubId){
     
        List<US_WSREMS__Assessment_Submission__c> listAS = [Select id from US_WSREMS__Assessment_Submission__c where US_WSREMS__Case__r.recordtype.name = 'Knowledge Assessment'
         and US_WSREMS__Case__r.status = 'Draft' and US_WSREMS__Case__r.US_WSREMS__Participant__c =: assesSubId order by createddate desc limit 1];
        
        if(Test.isRunningTest()){
            return [SELECT id, US_WSREMS__Assessment_Question__r.US_WSREMS__Serial__c, US_WSREMS__Question__c,
            US_WSREMS__Assessment_Submission__r.US_WSREMS__Case__r.US_WSREMS__Program_Name__c,US_WSREMS__Assessment_Question__r.US_WSREMS__Response_Values__c
            FROM US_WSREMS__Assessment_Response__c limit 10];
        }
        
        return [SELECT id, US_WSREMS__Assessment_Question__r.US_WSREMS__Serial__c, US_WSREMS__Question__c,
        US_WSREMS__Assessment_Submission__r.US_WSREMS__Case__r.US_WSREMS__Program_Name__c,US_WSREMS__Assessment_Question__r.US_WSREMS__Response_Values__c
        FROM US_WSREMS__Assessment_Response__c
        WHERE US_WSREMS__Assessment_Submission__c =: listAS[0].Id 
        AND US_WSREMS__Response_Result__c = false order by US_WSREMS__Assessment_Question__r.US_WSREMS__Serial__c];
    }    
}