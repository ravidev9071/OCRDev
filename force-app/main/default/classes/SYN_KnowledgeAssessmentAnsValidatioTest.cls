@isTest
public class SYN_KnowledgeAssessmentAnsValidatioTest {
	@TestSetup 
    //US_WSREMS__REMS_Program__c
    static void knowledgeAssessmentCaseCreation() {
         US_WSREMS__REMS_Program__c remsProgram = new US_WSREMS__REMS_Program__c(Name = 'Sodium Oxybate REMS',US_WSREMS__Status__c ='Active',REMS_Project_Code__c = 'BT6825'); 
         insert  remsProgram;
        Account participant = new Account(Name ='ABC', US_WSREMS__REMS_Program__c =remsProgram.Id,Phone='1234567789');
        insert participant;
        contact con= new contact();
        con.LastName='test';
        con.AccountId=participant.id;
        insert con;
        US_WSREMS__REMS_Service_Summary__c usRemsId = new US_WSREMS__REMS_Service_Summary__c(US_WSREMS__REMSProgram__c = remsProgram.Id,
                                                                                             US_WSREMS__Requestor_Type__c = 'Pharmacy'
                                                                                             );
        insert usRemsId;
        Case caseA = new Case();
        caseA.US_WSREMS__REMS_Program__c = remsProgram.id;
        caseA.US_WSREMS__Call_Notes__c = 'test';
        caseA.Us_WSREMS__Participant__c=participant.id;
        caseA.US_WSREMS__REMS_Service_Summary__c =usRemsId.Id;
        caseA.US_WSREMS__Program_Picklist__c = 'Sodium Oxybate REMS';
        caseA.Pharmacy_Employee_Type__c = 'Pharmacist';
        caseA.Professional_Designation__c='PharmD';
        caseA.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Assessment A').getRecordTypeId();//Knowledge Assessment A- RecoredTyoeId-0123C000000a0cAQAQ
        insert caseA;
        
        Case caseB = new Case();
        caseB.US_WSREMS__REMS_Program__c = remsProgram.id;
        caseB.US_WSREMS__Program_Picklist__c = 'Sodium Oxybate REMS';
        caseB.US_WSREMS__Call_Notes__c = 'test';
        caseB.Us_WSREMS__Participant__c=participant.id;
        caseB.US_WSREMS__REMS_Service_Summary__c =usRemsId.Id;
        caseB.Pharmacy_Employee_Type__c = 'Pharmacist';
        caseB.Professional_Designation__c='PharmD';
        caseB.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Assessment B').getRecordTypeId();//Knowledge Assessment B- RecoredTyoeId-0123C000000a0c5QAA
        insert caseB;
    }
    
    
    @isTest
    static void knowledgeAssessmentTest(){
        Id recordTypeIdA=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Assessment A').getRecordTypeId();
         Id recordTypeIdB=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Assessment A').getRecordTypeId();
        case caseRecA = [Select id,Us_WSREMS__Participant__r.personContactId,AccountId,Us_WSREMS__Participant__c,US_WSREMS__Program_Name__c from case Where RecordTypeId=:recordTypeIdA Limit 1 ];
        case caseRecB = [Select id,Us_WSREMS__Participant__r.personContactId,AccountId,Us_WSREMS__Participant__c,US_WSREMS__Program_Name__c from case Where RecordTypeId=:recordTypeIdB Limit 1 ];
        
        Test.startTest();
        List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap> ansWrapLstKAA = SYN_KnowledgeAssessmentAnswerValidation.KnowledgeAssessment(caseRecA.Id,recordTypeIdA);
        List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap> ansWrapLstKAB = SYN_KnowledgeAssessmentAnswerValidation.KnowledgeAssessment(caseRecB.Id,recordTypeIdB);
        List<SYN_KnowledgeAssessmentAnswerValidation.KAAnswersWrap> ansWrongWrapLstKAA = SYN_KnowledgeAssessmentAnswerValidation.knowledgeAssessmentWrongAnswers(caseRecA.Id,recordTypeIdA);
        test.stopTest();
        
        System.assertEquals(ansWrapLstKAA.size()>0 && ansWrapLstKAB.size()>0 && ansWrongWrapLstKAA.size()>0 , true);
        System.assertEquals(ansWrapLstKAA[0].fail && ansWrapLstKAB[0].fail && ansWrongWrapLstKAA[0].fail, true);
    }
}