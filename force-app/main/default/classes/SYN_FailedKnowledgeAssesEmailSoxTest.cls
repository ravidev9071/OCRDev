@isTest
public class SYN_FailedKnowledgeAssesEmailSoxTest {
    
    @TestSetup 
    //US_WSREMS__REMS_Program__c
    static void knowledgeAssessmentCaseCreation() {
         US_WSREMS__REMS_Program__c remsProgram = new US_WSREMS__REMS_Program__c(Name = 'Sodium Oxybate REMS',US_WSREMS__Status__c ='Active', REMS_Project_Code__c = 'BT6825'); 
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
        id RecordTypeIdA=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Assessment A').getRecordTypeId();
        id RecordTypeIdB=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Assessment B').getRecordTypeId();
        Case caseA = new Case();
        caseA.US_WSREMS__REMS_Program__c = remsProgram.id;
        caseA.US_WSREMS__Call_Notes__c = 'test';
        caseA.US_WSREMS__Program_Picklist__c = 'Sodium Oxybate REMS';
        caseA.Us_WSREMS__Participant__c=participant.id;
        caseA.US_WSREMS__REMS_Service_Summary__c =usRemsId.Id;
        caseA.US_WSREMS__First_Name__c='Test';
        caseA.US_WSREMS__Last_Name__c ='case';
        caseA.US_WSREMS__Middle_Name__c='A';
        caseA.Pharmacy_Employee_Type__c = 'Pharmacist';
        caseA.Professional_Designation__c='PharmD';
        caseA.RecordTypeId=RecordTypeIdA;
            //'0123C000000a0cAQAQ';//Knowledge Assessment A- RecoredTyoeId-0123C000000a0cAQAQ
        insert caseA;
        
        Case caseB = new Case();
        caseB.US_WSREMS__REMS_Program__c = remsProgram.id;
        caseB.US_WSREMS__Program_Picklist__c = 'Sodium Oxybate REMS';
        caseB.US_WSREMS__Call_Notes__c = 'test';
        caseB.Us_WSREMS__Participant__c=participant.id;
        caseB.US_WSREMS__REMS_Service_Summary__c =usRemsId.Id;
        caseB.US_WSREMS__First_Name__c='Test';
        caseB.US_WSREMS__Middle_Name__c='B';
        caseB.US_WSREMS__Last_Name__c ='case';
        caseB.Pharmacy_Employee_Type__c = 'Pharmacist';
        caseB.Professional_Designation__c='PharmD';
        caseB.RecordTypeId=RecordTypeIdB;//Knowledge Assessment B- RecoredTyoeId-0123C000000a0c5QAA
        insert caseB;
    }
    @isTest
    static void knowledgeAssessmentTest(){
        string strvalA='knowledgeAssesmentA';
         string strvalB='knowledgeAssesmentB';
        Id recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Assessment A').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c rss=[Select id from US_WSREMS__REMS_Service_Summary__c  where US_WSREMS__Requestor_Type__c =: 'Pharmacy' Limit 1];
        case cs = [SELECT Id, caseNumber,RecordTypeId,US_WSREMS__First_Name__c,US_WSREMS__Middle_Name__c,US_WSREMS__Last_Name__c  FROM case WHERE US_WSREMS__REMS_Service_Summary__c =: rss.Id WITH SECURITY_ENFORCED Limit 1];
        SYN_FailedKnowledgeAssesEmailSox.getKnowledgeAssesmentsFailedQuestionsA();
        SYN_FailedKnowledgeAssesEmailSox.getKnowledgeAssesmentsFailedQuestionsB();
        SYN_FailedKnowledgeAssesEmailSox.getKnowledgeAssesmemnts(cs.Id,strvalA);
        SYN_FailedKnowledgeAssesEmailSox.getKnowledgeAssesmemnts(cs.Id,strvalB);
        SYN_FailedKnowledgeAssesEmailSox.returnPatientName(cs.id);
    }

}