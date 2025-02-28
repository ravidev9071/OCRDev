/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-21-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class TryvioKAAssessmentController {
 @AuraEnabled(cacheable=true)
    public static List<US_WSREMS__Assessment__c> getQuestions() {
        return [SELECT id, Name,US_WSREMS__Participant_Type__c, US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Program__r.Name,US_WSREMS__Pass_Percentage__c, US_WSREMS__Maximum_Attempts__c,
                (SELECT Id,US_WSREMS__Assessment__c, US_WSREMS__Question_Text__c,US_WSREMS__Default_Value__c,  US_WSREMS__Required__c,US_WSREMS__Help_Text__c,
                 US_WSREMS__Response_Data_Type__c,US_WSREMS__Response_Values__c, US_WSREMS__Serial__c, US_WSREMS__Dependent_Question__c, US_WSREMS__Response_Dependency__c 
                 FROM US_WSREMS__Assessment_Questions__r WHERE US_WSREMS__Active__c = TRUE Order By US_WSREMS__Serial__c) FROM US_WSREMS__Assessment__c 
                WHERE US_WSREMS__REMS_Program__r.name= 'TRYVIO REMS' AND US_WSREMS__Participant_Type__c = 'Prescriber'];
    }
     @AuraEnabled(cacheable=false)
    public static String getSubmitResponse(String caseId, String assessmentId, List<US_WSREMS__Assessment_Response__c> responseDetails,Decimal assessmentPassPer,String attemptsCount) {
        US_WSREMS__Assessment_Submission__c oSubmission = new US_WSREMS__Assessment_Submission__c();
        List<US_WSREMS__Assessment_Response__c> oResponseList = new List<US_WSREMS__Assessment_Response__c>();
        Set<String> prescriberid =new Set<String>();
        List<Case> enrollmentCaseList = new List<Case>();
        oSubmission.US_WSREMS__Case__c = caseId;
        oSubmission.US_WSREMS__Assessment__c = assessmentId;
        if(responseDetails==null)
        {return null;}
        try {
            insert oSubmission;
            system.debug('oSubmission'+oSubmission);
            for(US_WSREMS__Assessment_Response__c oResponse: responseDetails){
                oResponse.US_WSREMS__Assessment_Submission__c = oSubmission.Id;
                oResponseList.add(oResponse);
            }
            insert oResponseList;
            String assessmentResult = saveAssessmentResult(caseId, oSubmission.Id,assessmentPassPer, Integer.valueOf(attemptsCount));
            if(assessmentResult=='Passed'){
               
                 Case assessmentCaseObj = [SELECT Id,US_WSREMS__Prescriber__c,US_WSREMS__Knowledge_Assessment__c,US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Program__r.Name,US_WSREMS__Service_Requestor_Type__c FROM case where Id=:caseId LIMIT 1];
                
                system.debug('assessmentCaseObj'+ assessmentCaseObj);
                if(assessmentCaseObj!=null){
                    assessmentCaseObj.Status='Complete';
                    assessmentCaseObj.US_WSREMS__Outcome__c='Complete';
                    
                    update assessmentCaseObj;
                    if(assessmentCaseObj.US_WSREMS__Prescriber__c!=null){
                          enrollmentCaseList=[select id,status,US_WSREMS__Outcome__c,US_WSREMS__Prescriber_State__c,US_WSREMS__Knowledge_Assessment__c from case where recordtype.developername='Prescriber_enrollment' and US_WSREMS__Participant__c=:assessmentCaseObj.US_WSREMS__Prescriber__c limit 1];
                        if(enrollmentCaseList.size()>0){ 
                            enqueueUpdate(assessmentCaseObj.US_WSREMS__Prescriber__c);
                      
                            assessmentResult= assessmentResult+' - Enrolled';
                        }else{
                            assessmentResult= assessmentResult+' - Not Enrolled';
                        }
                    }
                    
                }
                
            }
            system.debug('assessmentResult'+assessmentResult);
            return 'Success - '+assessmentResult;
            
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    
    
    Private static String saveAssessmentResult(Id caseId, Id submissionId,Decimal assessmentPassPer ,Integer attemptsCount){
        List<US_WSREMS__Assessment_Response__c> responseList=[Select Id, US_WSREMS__Response_Result__c
                                                             FROM US_WSREMS__Assessment_Response__c
                                                             WHERE US_WSREMS__Assessment_Submission__c =: submissionId];
        
        integer  correctAnswers=0;
        String assessmentResult = '';
        
        for(US_WSREMS__Assessment_Response__c response: responseList){
            if(response.US_WSREMS__Response_Result__c){
                correctAnswers++;
            }}
        
        integer questionsCount= responseList.size(); 
        integer ansPercentage=100 * correctAnswers/questionsCount;
        
        US_WSREMS__Assessment_Submission__c oSubmission =[SELECT Id,
                                                         US_WSREMS__Assessment_Result__c,
                                                         US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c
                                                         FROM US_WSREMS__Assessment_Submission__c
                                                         WHERE Id=:submissionId LIMIT 1];
        oSubmission.US_WSREMS__Assessment_Result__c= ansPercentage>=assessmentPassPer? 'Passed':'Failed';
        assessmentResult = oSubmission.US_WSREMS__Assessment_Result__c;
        update oSubmission;
        return assessmentResult;
    }
    @AuraEnabled(cacheable=false)
    public static CaseAndRelatedDataWrapper getCaseAndRelatedData(String recordId , Boolean isSummary){
        system.debug('callled from connected callback');
        CaseAndRelatedDataWrapper wrapper = new CaseAndRelatedDataWrapper();
        wrapper.caseRecord = new Case(); 
        wrapper.assessmentList = new List<US_WSREMS__Assessment_Submission__c>(); 
        wrapper.responseList = new List<US_WSREMS__Assessment_Response__c>(); 
        Decimal attemptsCount = 0;
        for(Case record : [SELECT Id , US_WSREMS__REMS_Program__r.LastModifiedDate,US_WSREMS__REMS_Program__c, US_WSREMS__REMS_Program__r.Name, US_WSREMS__Service_Requestor_Type__c,  US_WSREMS__Attempts_Made__c FROM Case WHERE Id =: recordId ]) {
            wrapper.caseRecord = record;
        }
        for(US_WSREMS__Assessment_Submission__c record : [SELECT ID,US_WSREMS__Assessment__c, US_WSREMS__Assessment_Result__c, US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c, US_WSREMS__Assessment__r.US_WSREMS__Show_Wrong_Answers_Only__c FROM US_WSREMS__Assessment_Submission__c  WHERE US_WSREMS__Case__c =: recordId ORDER BY US_WSREMS__Assessment_Submission__c.CreatedDate]) {
            wrapper.assessmentList.add(record);
        }
        system.debug('assessmentList@@@'+wrapper.assessmentList);
        if(!wrapper.assessmentList.isEmpty() && !isSummary) {
            Decimal attemptsMade = wrapper.caseRecord.US_WSREMS__Attempts_Made__c;
            Integer submittedRecordsCount = wrapper.assessmentList.size() > 0 ? wrapper.assessmentList.size() - 1 : 0;
            Integer submittedRecordsCountOrg = wrapper.assessmentList.size() > 0 ? wrapper.assessmentList.size() : 0;
            Decimal maximumAttemptsAllowed = submittedRecordsCount > 0 ? wrapper.assessmentList[submittedRecordsCount].US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c: 0;
            if (maximumAttemptsAllowed > 0 && maximumAttemptsAllowed <= attemptsMade ) {
            } else {
                attemptsCount = attemptsMade + 1;
                Boolean showWrongQuestionsOnly = submittedRecordsCountOrg > 0 && wrapper.assessmentList.size() > 0 ? wrapper.assessmentList[submittedRecordsCount].US_WSREMS__Assessment__r.US_WSREMS__Show_Wrong_Answers_Only__c : false;
                if (attemptsCount > 1 && showWrongQuestionsOnly  ) {
                    String lastSubmittedRecordId = wrapper.assessmentList[submittedRecordsCount].Id;
                    for(US_WSREMS__Assessment_Response__c record : [SELECT Id,US_WSREMS__Assessment_Question__c, US_WSREMS__Answer__c, US_WSREMS__Response_Result__c,US_WSREMS__Assessment_Submission__c FROM US_WSREMS__Assessment_Response__c WHERE US_WSREMS__Assessment_Submission__c=: lastSubmittedRecordId ]) {
                        wrapper.responseList.add(record);
                    }
                } 
            }
        } else if(!wrapper.assessmentList.isEmpty() && isSummary) {
            Decimal attemptsMade = wrapper.caseRecord.US_WSREMS__Attempts_Made__c;
            Integer submittedRecordsCount = wrapper.assessmentList.size() > 0 ? wrapper.assessmentList.size() - 1 : 0;
            Decimal maximumAttemptsAllowed = submittedRecordsCount > 0 ? wrapper.assessmentList[submittedRecordsCount].US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c: 0;
            String lastSubmittedRecordId = wrapper.assessmentList[submittedRecordsCount].Id;
            for(US_WSREMS__Assessment_Response__c record : [SELECT Id,US_WSREMS__Assessment_Question__c, US_WSREMS__Answer__c, US_WSREMS__Response_Result__c,US_WSREMS__Assessment_Submission__c,US_WSREMS__Assessment_Question__r.US_WSREMS__Question_Text__c FROM US_WSREMS__Assessment_Response__c WHERE US_WSREMS__Assessment_Submission__c=: lastSubmittedRecordId ]) {
                wrapper.responseList.add(record);
            }
        }
        return wrapper;
    }

    public class CaseAndRelatedDataWrapper {
        @AuraEnabled public Case caseRecord ;
        @AuraEnabled public List<US_WSREMS__Assessment_Submission__c> assessmentList ;
        @AuraEnabled public List<US_WSREMS__Assessment_Response__c> responseList ;
    }
    
   @future
    public static void enqueueUpdate(id participantId){
        List<Case> enrollmentCaseList = new List<Case>();
        try{
            enrollmentCaseList=[select id,status,US_WSREMS__Outcome__c,US_WSREMS__State__c,US_WSREMS__Knowledge_Assessment__c from case where recordtype.developername='Prescriber_enrollment' and US_WSREMS__Participant__c=:participantId limit 1];
                        if(enrollmentCaseList.size()>0){ 
                           case enrollcaseupdate= new case();
                            enrollcaseupdate.id=enrollmentCaseList[0].id;
                            enrollcaseupdate.Status='Complete';
                            enrollcaseupdate.US_WSREMS__Outcome__c='Complete';
                            enrollcaseupdate.US_WSREMS__State__c=enrollmentCaseList[0].US_WSREMS__State__c;
                            enrollcaseupdate.US_WSREMS__Knowledge_Assessment__c='Passed';
                           update enrollcaseupdate;
                        }
           }catch(Exception e){
              System.debug('Error in the CaseUpdate::'+e.getMessage());
          }
 
    }
  
    
}