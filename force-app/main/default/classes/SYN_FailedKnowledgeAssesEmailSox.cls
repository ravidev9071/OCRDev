public without sharing class SYN_FailedKnowledgeAssesEmailSox {
    //Get account id passed in from email template
    public static Id emailCaseId { get; set; }
    public static Id rssId { get; set; }
    public static US_WSREMS__REMS_Service_Summary__c rems{get;set;}
    public static List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap>  newknowledgeAssessmentListA { get; set; }
    public static List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap>  newknowledgeAssessmentListB { get; set; }
    
    public static string returnPatientName(Id emailCaseId){
        case cs =[SELECT id,US_WSREMS__First_Name__c,US_WSREMS__Middle_Name__c,US_WSREMS__Last_Name__c  FROM case WHERE id =: emailCaseId WITH SECURITY_ENFORCED LIMIT 1];
	    string nameWithIntials = cs.US_WSREMS__First_Name__c.substring(0,1)+' ' +cs.US_WSREMS__Middle_Name__c.substring(0,1)+' '+ cs.US_WSREMS__Last_Name__c.substring(0,1);
        return nameWithIntials;
    }
    public static List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap> getKnowledgeAssesmentsFailedQuestionsA(){
        newknowledgeAssessmentListA = getKnowledgeAssesmemnts(emailCaseId, 'knowledgeAssesmentA'); 
        return newknowledgeAssessmentListA;
    }
    public static List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap> getKnowledgeAssesmentsFailedQuestionsB(){
        newknowledgeAssessmentListB = getKnowledgeAssesmemnts(emailCaseId,'knowledgeAssesmentB'); 
        return newknowledgeAssessmentListB;        
    }
   // map<string,List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap> > newMap
    public static List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap> getKnowledgeAssesmemnts(Id emailCaseId, string strval){
         Id  recordTypeOfknowledgeAssementA = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Assessment A').getRecordTypeId();
         Id recordTypeOfknowledgeAssementB = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Assessment B').getRecordTypeId();
        Id casewithRecordTypeA;
        Id casewithRecordTypeB;
        string fullName;
        for(Case cs  :  [SELECT Id, caseNumber,RecordTypeId,US_WSREMS__First_Name__c,US_WSREMS__Last_Name__c  FROM case WHERE Id =: emailCaseId WITH SECURITY_ENFORCED]){
            if(cs.recordtypeId == recordTypeOfknowledgeAssementA){
                casewithRecordTypeA = cs.Id;
                fullName = cs.US_WSREMS__First_Name__c + cs.US_WSREMS__Last_Name__c;
            }
            if(cs.recordtypeId == recordTypeOfknowledgeAssementB){
                casewithRecordTypeB = cs.Id;
                fullName = cs.US_WSREMS__First_Name__c + cs.US_WSREMS__Last_Name__c;
            }
        }
        if(casewithRecordTypeA != null && strval == 'knowledgeAssesmentA'){
            List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap> knowledgeAssessmentUnfilteredListA = SYN_KnowledgeAssessmentAnswerValidation.KnowledgeAssessment(casewithRecordTypeA, recordTypeOfknowledgeAssementA);            
            return knowledgeAssessmentListValues(knowledgeAssessmentUnfilteredListA);
        }
        if(casewithRecordTypeB != null && strval == 'knowledgeAssesmentB'){
            List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap> knowledgeAssessmentUnfilteredListB = SYN_KnowledgeAssessmentAnswerValidation.KnowledgeAssessment(casewithRecordTypeB, recordTypeOfknowledgeAssementB);
            return  knowledgeAssessmentListValues(knowledgeAssessmentUnfilteredListB);
        }
        return null;      
    }
    public static List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap> knowledgeAssessmentListValues(List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap> knowledgeAssessmentUnfilteredListValues){
        List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap> knowledgeAssessmentList = new List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap>();
        for(SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap  kas : knowledgeAssessmentUnfilteredListValues){
            if(kas.fail == TRUE){
                knowledgeAssessmentList.add(kas);
            }   
        }
        return knowledgeAssessmentList != null ? knowledgeAssessmentList : null;
    }
}