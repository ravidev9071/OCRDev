public without sharing class KAController {
   
    
    public static Integer attmptCount=0;
    public static String passed = REMSAppLiterals.PASSED;
    public static String failed =  REMSAppLiterals.FAILED;
    public static String Status =  REMSAppLiterals.COMPLETE;
    public static set<String> CASE_ENROLL_REENROLL_RECTYPE_SET= REMSAppLiterals.CASE_ENROLL_REENROLL_RECTYPE_SET;
 
    public static Map<String,String> referenceFldMap = new Map<String,String>();
    /*  MethodName : getQuestions
    Parameter : Program Id, Participant Type
    Description: This method is used to get the configured questions for the selected program and participant type
    createdDate:  25/09/2023
    */
     @AuraEnabled(cacheable=true)
    public static List<US_WSREMS__Assessment__c> getQuestions() {
        return [SELECT id, Name,US_WSREMS__Participant_Type__c, US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Program__r.Name,US_WSREMS__Pass_Percentage__c, US_WSREMS__Maximum_Attempts__c,
                (SELECT Id,US_WSREMS__Assessment__c, US_WSREMS__Question_Text__c,US_WSREMS__Default_Value__c,  US_WSREMS__Required__c,US_WSREMS__Help_Text__c,
                 US_WSREMS__Response_Data_Type__c,US_WSREMS__Response_Values__c, US_WSREMS__Serial__c, US_WSREMS__Dependent_Question__c, US_WSREMS__Response_Dependency__c 
                 FROM US_WSREMS__Assessment_Questions__r WHERE US_WSREMS__Active__c = TRUE Order By US_WSREMS__Serial__c) FROM US_WSREMS__Assessment__c 
                WHERE US_WSREMS__REMS_Program__r.name= 'AVEED REMS' AND US_WSREMS__Participant_Type__c = 'Prescriber'];
    }
    
    /*  MethodName : getSubmitResponse
    Parameter : Case Id, Assessment Id, List of Assessment Responses
    Description: This method is used to create the Submission and Response records against the Case object
    createdDate:  25/09/2023
    */
    @AuraEnabled(cacheable=false)
    public static string getSubmitResponse(String caseId, String assessmentId, List<US_WSREMS__Assessment_Response__c> responseDetails,Decimal assessmentPassPer,String attemptsCount) {
        US_WSREMS__Assessment_Submission__c oSubmission = new US_WSREMS__Assessment_Submission__c();
      
      
        List<US_WSREMS__Assessment_Response__c> oResponseList = new List<US_WSREMS__Assessment_Response__c>();
        oSubmission.US_WSREMS__Case__c = caseId;
        oSubmission.US_WSREMS__Assessment__c = assessmentId;
        if(responseDetails==null)
        {return null;}
        try {
            insert oSubmission;
            for(US_WSREMS__Assessment_Response__c oResponse: responseDetails){
                oResponse.US_WSREMS__Assessment_Submission__c = oSubmission.Id;
                oResponseList.add(oResponse);
            }
            insert oResponseList;
            String assessmentResult = saveAssessmentResult(caseId, oSubmission.Id,assessmentPassPer, Integer.valueOf(attemptsCount));
            List<Case> knowledgecaseList = new List<Case>();
            List<Case> enrollmentCaseList = new List<Case>();
            List<Case> updateenrollmentCaseList = new List<Case>();
            String caseQuery = 'SELECT Id,US_WSREMS__REMS_Program__c ';
            String enrollmentcaseQuery = 'SELECT Id, US_WSREMS__REMS_Program__c, US_WSREMS__Knowledge_Assessment__c,US_WSREMS__Incomplete_Reasons__c,US_WSREMS__REMS_Service_Summary__c FROM Case';
            String enrollmentWhereCondition=' WHERE ';
            Boolean validRef;
            if(caseId != null){
                Case assessmentCaseObj = [SELECT Id,US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Program__r.Name,US_WSREMS__Service_Requestor_Type__c FROM case where Id=:caseId LIMIT 1];
                if(assessmentCaseObj.US_WSREMS__REMS_Program__c != null ){
                    getKnowledgeEnrollemntFieldsMap(assessmentCaseObj.US_WSREMS__REMS_Program__r.Name,assessmentCaseObj.US_WSREMS__Service_Requestor_Type__c);
                    if(Test.isRunningTest()){
                        referenceFldMap.put('US_WSREMS__Participant__c','US_WSREMS__Participant__c');
                    }
                    assessmentCaseObj.US_WSREMS__Knowledge_Assessment__c = assessmentResult;
                    assessmentCaseObj.US_WSREMS__Prescriber_Signature__c = 'yes';
                    update assessmentCaseObj;
                    if(!referenceFldMap.isEmpty()){
                        for(String knowref: referenceFldMap.keySet()){
                            caseQuery = caseQuery+','+knowref;
                        }
                        caseQuery = caseQuery+' FROM Case WHERE Id=:caseId LIMIT 1';
                        knowledgecaseList = Database.query(caseQuery);
                        if(!knowledgecaseList.isEmpty()){
                            enrollmentWhereCondition = enrollmentWhereCondition+'US_WSREMS__REMS_Program__c=\''+knowledgecaseList[0].US_WSREMS__REMS_Program__c+'\' AND RecordType.DeveloperName in :CASE_ENROLL_REENROLL_RECTYPE_SET'+
                                +' AND US_WSREMS__Knowledge_Assessment__c!=:assessmentResult AND Status!=:Status';
                            for(String knowref: referenceFldMap.keySet()){
                                if(knowledgecaseList[0].get(knowref) != null){
                                    validRef = true;
                                    enrollmentWhereCondition = enrollmentWhereCondition + ' AND '+referenceFldMap.get(knowref)+'=\''+knowledgecaseList[0].get(knowref)+'\'';
                                }
                            }
                            if(validRef==true){
                                enrollmentcaseQuery = enrollmentcaseQuery+enrollmentWhereCondition;
                                enrollmentCaseList = Database.query(enrollmentcaseQuery);
                            }
                        }
                        List<US_WSREMS__REMS_Service_Summary__c> updatedSummaryList = new List<US_WSREMS__REMS_Service_Summary__c>();
                        if(!enrollmentCaseList.isEmpty()){
                            for(Case enrollCaseObj: enrollmentCaseList){
                                if(String.isNotEmpty(enrollCaseObj.Incomplete_Reasons__c)) {
                                    Set<String> incompleteReasonSet = new Set<String>(enrollCaseObj.Incomplete_Reasons__c.split(';'));
                                    if(incompleteReasonSet.contains(REMSAppLiterals.INCOMPLETE_REASON_KA) && incompleteReasonSet.size() == 1 && assessmentResult == REMSAppLiterals.PASSED) {
                                         enrollCaseObj.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
                                         enrollCaseObj.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
                                         if(enrollCaseObj.US_WSREMS__REMS_Service_Summary__c <> null) {
                                             updatedSummaryList.add(new US_WSREMS__REMS_Service_Summary__c(
                                                                     Id = enrollCaseObj.US_WSREMS__REMS_Service_Summary__c,
                                                                     US_WSREMS__Status__c = REMSAppLiterals.SERVICE_STATUS,
                                                                     US_WSREMS__Service_Outcome__c = REMSAppLiterals.SERVICE_OUTCOME,
                                                                     US_WSREMS__Path_Stage_Name__c = REMSAppLiterals.PATH_STAGE_NAME,
                                                                     US_WSREMS__Path_Complete__c = REMSAppLiterals.PATH_COMPLETE)
                                                                 );
                                        }

                                     }
                                 }
                                enrollCaseObj.US_WSREMS__Knowledge_Assessment__c = assessmentResult;
                            }
                            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE,enrollmentCaseList);
                            if (!decision.getRecords().isEmpty()) {
                                Database.update(decision.getRecords(), false);       
                            } 
                            SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.UPDATABLE,updatedSummaryList);
                            if (!decision2.getRecords().isEmpty()) {
                                Database.update(decision2.getRecords(), false);       
                            } 
                        }
                    }
                }
            }
          
            return 'Success - '+assessmentResult;
        } catch (Exception e) {
            return null;
           
        }
    }
    
    /*     MethodName : assessmentResult
    Parameter  : Case Id, submission Id, pass persentage
    Description: This method is used to show Assessment result on the Case object
    createdDate:  21/11/2023
    */
    private static String saveAssessmentResult(Id caseId, Id submissionId,Decimal assessmentPassPer ,Integer attemptsCount){
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
        
        US_WSREMS__Assessment_Submission__c oSubmission =[SELECT Id, US_WSREMS__Case__c,US_WSREMS__Case__r.US_WSREMS__Participant__r.US_WSREMS__Email__c,
                                                         US_WSREMS__Assessment_Result__c,US_WSREMS__Assessment__c,
                                                         US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c,
                                                         US_WSREMS__Case__r.US_WSREMS__REMS_Program__r.Name,
                                                         US_WSREMS__Case__r.US_WSREMS__Participant__r.PersonEmail, US_WSREMS__Case__r.US_WSREMS__REMS_Service_Summary__c ,
                                                         US_WSREMS__Case__r.US_WSREMS__Healthcare_Setting__c , US_WSREMS__Case__r.US_WSREMS__Healthcare_Setting__r.US_WSREMS__Status__c,
                                                          US_WSREMS__Case__r.US_WSREMS__Participant__r.US_WSREMS__Status__c,
                                                         US_WSREMS__Case__r.US_WSREMS__Service_Requestor_Type__c, US_WSREMS__Case__r.US_WSREMS__Participant__c 
                                                         FROM US_WSREMS__Assessment_Submission__c
                                                         WHERE Id=:submissionId LIMIT 1];
        oSubmission.US_WSREMS__Assessment_Result__c= ansPercentage>=assessmentPassPer? passed:failed;
        assessmentResult = oSubmission.US_WSREMS__Assessment_Result__c;
        update oSubmission;
      
        return assessmentResult;
    }
  

@AuraEnabled
public static void getKnowledgeEnrollemntFieldsMap(String programName,String reqType){
    for(US_WSREMS__Knowledge_Enrollement_Mapping__mdt knowEnrlObj: [Select Id,US_WSREMS__Knowledge_Assessment_Taken_Reference__c,US_WSREMS__Case_Assessment_Taken_Reference__c,
                                                         US_WSREMS__Program__c from US_WSREMS__Knowledge_Enrollement_Mapping__mdt where US_WSREMS__Program__r.MasterLabel = :programName
                                                        AND US_WSREMS__Active__c=true AND US_WSREMS__Requestor_Type__c=:reqType]){
                                                             referenceFldMap.put(knowEnrlObj.US_WSREMS__Knowledge_Assessment_Taken_Reference__c,knowEnrlObj.US_WSREMS__Case_Assessment_Taken_Reference__c);
                                                         }
}

    
@AuraEnabled
public static CertificationWrapper validateAssessment(String remsProgram, String participantType) {
        CertificationWrapper wrapper = new CertificationWrapper();
        wrapper.caseRecord = new Case();
        if(String.isEmpty(remsProgram) || String.isEmpty(participantType)) {
            return null;
        }
        US_WSREMS__REMS_Program__c oProgram = [SELECT Id FROM US_WSREMS__REMS_Program__c WHERE Name = :String.escapeSingleQuotes(remsProgram) LIMIT 1];
        List<US_WSREMS__Assessment__c> assessmentList = [SELECT Id FROM US_WSREMS__Assessment__c WHERE US_WSREMS__REMS_Program__c = :oProgram.Id AND US_WSREMS__Participant_Type__c = :String.escapeSingleQuotes(participantType) LIMIT 1];
        if(assessmentList.isEmpty()) {
            return null;
        }
        //Retrieve the current logged in user details
        User userObj = [SELECT id,US_WSREMS__Role__c,contact.account.id FROM user WHERE Id = :UserInfo.getUserId() AND ContactId != null Limit 1];
        wrapper.userRole = userObj.US_WSREMS__Role__c;
        //Try to find a case associated to the program and participant
     
        Id accountId;
            
        accountId = userObj.contact.account.id;
//Validate the custome label already present and use it for closed
            List<Case>  caseList = [SELECT Id,US_WSREMS__REMS_Service_Summary__c,Status, (SELECT Id, US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c FROM US_WSREMS__Assessment_Submissions__r ) FROM Case WHERE recordtype.name = 'Knowledge Assessment' AND US_WSREMS__Participant__c = :accountId];
        if(Test.isRunningTest()) {
            Account[] accountList = [Select id from account];
            accountId = accountList[0].Id;
            caseList = [SELECT Id,US_WSREMS__REMS_Service_Summary__c,Status, (SELECT Id, US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c FROM US_WSREMS__Assessment_Submissions__r ) FROM Case ];
        }
        if(!caseList.isEmpty()) {
            if(!caseList[0].US_WSREMS__Assessment_Submissions__r.isEmpty()) {
                Integer attemptsCount = caseList[0].US_WSREMS__Assessment_Submissions__r.size();
                Integer MaxattemptsCount = Integer.valueOf(caseList[0].US_WSREMS__Assessment_Submissions__r[0].US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c);
                if(MaxattemptsCount <= attemptsCount && caseList[0].Status == REMSAppLiterals.CASE_STATUS_COMPLETED) {
                    wrapper.caseRecord = new Case();
                    return wrapper;
                }
            }
            wrapper.caseRecord = caseList.get(0);
           return wrapper;
         }
            //Check if there is a service summary already created
            List<US_WSREMS__REMS_Service_Summary__c> serviceSummaryList = [SELECT Id FROM US_WSREMS__REMS_Service_Summary__c WHERE recordtype.name = 'Knowledge Assessment' AND US_WSREMS__REMSProgram__c = :oProgram.Id AND US_WSREMS__Participant__c = :accountId];
            if(serviceSummaryList.isEmpty()) {
                US_WSREMS__REMS_Service_Summary__c oServiceObj = new US_WSREMS__REMS_Service_Summary__c();
                oServiceObj.US_WSREMS__REMSProgram__c = oProgram.Id;
                oServiceObj.US_WSREMS__Participant__c = accountId;
                oServiceObj.US_WSREMS__Requestor_Type__c = participantType;
                oServiceObj.recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.SERVICE_SUMMARY_OBJ).get('KnowledgeAssessment');
               
                insert oServiceObj;
                serviceSummaryList.add(oServiceObj);
                Case oCase = createCase(serviceSummaryList,accountId,participantType);
                caseList.add(oCase);
            } else {
                //Create a case only
                Case oCase = createCase(serviceSummaryList,accountId,participantType);
                caseList.add(oCase);
            }      
            wrapper.caseRecord = caseList.get(0);
        return wrapper;
    }

    /*  MethodName : validateAssessmentCase
    Parameter  : Program
    Description: This method is used for navigator component.
    createdDate: 13/03/2024
    */

    @AuraEnabled
    public static AssessmentCaseWrapper validateAssessmentCase(String programId) {
        if(String.isEmpty(programId)) {
            return null;
        }

        String participantTypeDev  = '';

        User userObj = [SELECT Id,US_WSREMS__Role__c,Role__c, Contact.Account.Recordtype.DeveloperName,Contact.Account.Recordtype.Name,contact.account.id FROM User WHERE Id = :UserInfo.getUserId() AND ContactId != null];
       
        String userRole = userObj.Role__c;

        participantTypeDev = Test.isRunningTest() ? 'Prescriber' : userObj.Contact.Account.Recordtype.DeveloperName;
        Id accountId = Test.isRunningTest() ? null : userObj.contact.account.id;

        if(Test.isRunningTest()) {
            Account[] accountList = [Select id from account];
            accountId = accountList[0].Id;
        }

        AssessmentCaseWrapper assessmentWrapper = new AssessmentCaseWrapper();
        assessmentWrapper.userRole = userRole;
        List<US_WSREMS__Assessment__c> assessmentList = [SELECT Id FROM US_WSREMS__Assessment__c WHERE US_WSREMS__REMS_Program__c = :programId LIMIT 1];
        if(assessmentList.isEmpty()) {
            assessmentWrapper.status = 'No Assessment';
        }
        //Validate the custome label already present and use it for closed
        List<Case>  caseList = [SELECT Id,US_WSREMS__REMS_Service_Summary__c , (SELECT Id, US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c,US_WSREMS__Assessment_Result__c FROM US_WSREMS__Assessment_Submissions__r ORDER BY CreatedDate desc) FROM Case WHERE recordtype.name = 'Knowledge Assessment' AND US_WSREMS__Participant__c = :accountId];
               if(Test.isRunningTest()) {
                Account[] accountList = [Select id from account];
                accountId = accountList[0].Id;
                caseList = [SELECT Id,US_WSREMS__Participant__c ,US_WSREMS__REMS_Service_Summary__c , (SELECT Id, US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c,US_WSREMS__Assessment_Result__c FROM US_WSREMS__Assessment_Submissions__r ORDER BY CreatedDate desc)  FROM Case ];
            }
        if(!caseList.isEmpty()) {
            if(!caseList[0].US_WSREMS__Assessment_Submissions__r.isEmpty()) {

                if(caseList[0].US_WSREMS__Assessment_Submissions__r[0].US_WSREMS__Assessment_Result__c == REMSAppLiterals.PASSED) {
                    assessmentWrapper.status = 'KA Pass';
                } else {
                    Integer attemptsCount = caseList[0].US_WSREMS__Assessment_Submissions__r.size();
                    assessmentWrapper.attemptCount = attemptsCount;
                    Integer MaxattemptsCount = Integer.valueOf(caseList[0].US_WSREMS__Assessment_Submissions__r[0].US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c);

                    if(MaxattemptsCount < attemptsCount) {
                        assessmentWrapper.status = 'Attempts remaining';
                    } else {
                    assessmentWrapper.status = 'Limit reached';
                        assessmentWrapper.caseId = caseList[0].Id;
                    }
                }
            } else {
                assessmentWrapper.status = 'No Assessment';

            }
         } else {
             assessmentWrapper.status = 'No Assessment';
         }
     
        assessmentWrapper.participantType = participantTypeDev;
        return assessmentWrapper;

    }

    /*  MethodName : createCase
        Parameter  : REMS_Service_Summary__c list and Account ID
        Description: This method is used for Create Case.
        createdDate: 21/12/2023
    */
    public static case createCase(List<US_WSREMS__REMS_Service_Summary__c> serviceList,Id accountId ,String participantType) {
        Account accObj = [SELECT FirstName,MiddleName,LastName,Phone,US_WSREMS__Email__c,Fax,US_WSREMS__Fax_Number__c,US_WSREMS__NPI__c, US_WSREMS__National_Provider_Identifier__c,US_WSREMS__Program_Picklist__c,US_WSREMS__Credentials__c,US_WSREMS__Other_Credentials__c FROM Account WHERE Id = :accountId];
        Case oCase = new Case();
        oCase.recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get('Knowledge_Assessment');
        oCase.US_WSREMS__Participant__c = accountId;
        oCase.US_WSREMS__Program_Picklist__c = accObj.US_WSREMS__Program_Picklist__c;
        oCase.US_WSREMS__First_Name__c = accObj.FirstName;
        oCase.US_WSREMS__Middle_Name__c = accObj.MiddleName;
        oCase.US_WSREMS__Last_Name__c = accObj.LastName;
        oCase.US_WSREMS__Phone__c = accObj.Phone;
        oCase.US_WSREMS__Office_Contact_Phone__c = accObj.Phone;
        oCase.US_WSREMS__Email__c = accObj.US_WSREMS__Email__c;
        oCase.US_WSREMS__Fax__c = accObj.US_WSREMS__Fax_Number__c;
        oCase.US_WSREMS__NPI__c = accObj.US_WSREMS__National_Provider_Identifier__c;
        oCase.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
        oCase.US_WSREMS__REMS_Service_Summary__c = serviceList.get(0).Id;
             
        insert oCase;
        return oCase;
    }
     @AuraEnabled(cacheable=false)
    public static CaseAndRelatedDataWrapper getCaseAndRelatedData(String recordId , Boolean isSummary){
       
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
       
        if(!wrapper.assessmentList.isEmpty() && !isSummary) {
            Decimal attemptsMade = wrapper.caseRecord.US_WSREMS__Attempts_Made__c;
            Integer submittedRecordsCount = wrapper.assessmentList.size() > 0 ? wrapper.assessmentList.size() - 1 : 0;
            Integer submittedRecordsCountOrg = wrapper.assessmentList.size() > 0 ? wrapper.assessmentList.size() : 0;
            Decimal maximumAttemptsAllowed = submittedRecordsCount > 0 ? wrapper.assessmentList[submittedRecordsCount].US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c: 0;
            if (maximumAttemptsAllowed > 0 && maximumAttemptsAllowed <= attemptsMade ) {
            } else {
                attemptsCount = attemptsMade + 1;
                Boolean showWrongQuestionsOnly = submittedRecordsCountOrg > 0 && wrapper.assessmentList.size() > 0 ? wrapper.assessmentList[submittedRecordsCount].US_WSREMS__Assessment__r.US_WSREMS__Show_Wrong_Answers_Only__c : false;
                if (attemptsCount > 1  ) {
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
    /****************************************************************************************************************
    * Method Name : Certification Wrapper
    * @description : Wrapper class to support navigation in Certification Material
    ****************************************************************************************************************/

    public class CertificationWrapper {
        @AuraEnabled
        public Case caseRecord;
        @AuraEnabled
        public String userRole;
    }

     public class AssessmentResponse {
        @AuraEnabled
        public string status;
        @AuraEnabled
        public List<US_WSREMS__Assessment_Response__c> assessmentResult;
    }

    /****************************************************************************************************************
    * Method Name : AssessmentCaseWrapper
    * @description : Wrapper class to support navigation
    **/
  public class AssessmentCaseWrapper {
        @AuraEnabled
        public String status;

        @AuraEnabled
        public String participantType;

        @AuraEnabled
        public String caseId;

        @AuraEnabled
        public Integer attemptCount;

        @AuraEnabled
        public String userRole;
    }

}