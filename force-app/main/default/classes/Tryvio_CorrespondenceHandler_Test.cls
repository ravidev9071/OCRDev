@isTest
public class Tryvio_CorrespondenceHandler_Test {
    @testsetup
    public static void stakeholderKnowledgeAssessmentTest() { 
        US_WSREMS__REMS_Program__c remsProgram = new US_WSREMS__REMS_Program__c(Name = 'TRYVIO REMS',US_WSREMS__Status__c ='Active',REMS_Project_Code__c = 'BT4324'); 
        insert  remsProgram;
        Id prescriberAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Account prescriberAccObj = SYN_TestDataUtility.createAccount(remsProgram.id, prescriberAccRecTypeId, 'FirstName', 'LastName');
        prescriberAccObj.US_WSREMS__Email__c='test@test.com';
        prescriberAccObj.PersonEmail='test@test.com';
        update prescriberAccObj;
        Id prescribercaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_Person_Account').getRecordTypeId();
         Id inPatientRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inpatient_Pharmacy_Enrollment').getRecordTypeId();

        Case caseRec = new Case();
        caseRec.RecordTypeId=inPatientRT;
        caseRec.US_WSREMS__Program_Picklist__c ='TRYVIO REMS';
        caseRec.US_WSREMS__REMS_Program__c = remsProgram.id;
        caseRec.Program_Record_Type_Control__c='TRYVIO REMS-Inpatient_Pharmacy_Enrollment';
        caseRec.US_WSREMS__Call_Notes__c = 'test';
        caseRec.Us_WSREMS__Participant__c=prescriberAccObj.id;
        caseRec.AccountId=prescriberAccObj.Id;
        caseRec.US_WSREMS__Channel__c = '';
        insert caseRec;       
        US_WSREMS__Assessment__c  assRec=new  US_WSREMS__Assessment__c ();
        assRec.Name='Test';
        insert assRec;
        US_WSREMS__Assessment_Submission__c assSubRec=new US_WSREMS__Assessment_Submission__c();
        assSubRec.US_WSREMS__Provider_Email__c='test@test.com';
        assSubRec.US_WSREMS__Assessment__c=assRec.Id;
        assSubRec.US_WSREMS__Assessment_Result__c = 'Failed';
        assSubRec.US_WSREMS__Total_Number_of_Attempts__c = 1;
        assSubRec.US_WSREMS__Case__c=caseRec.Id;
        insert assSubRec;
        US_WSREMS__Assessment_Submission__c assSubRecTest=new US_WSREMS__Assessment_Submission__c();
        assSubRecTest.US_WSREMS__Provider_Email__c='test@test.com';
        assSubRecTest.US_WSREMS__Assessment__c=assRec.Id;
        assSubRecTest.US_WSREMS__Assessment_Result__c = 'Failed';
        assSubRecTest.US_WSREMS__Total_Number_of_Attempts__c = 3;
        assSubRec.US_WSREMS__Case__c=caseRec.Id;   
        insert assSubRecTest;
        US_WSREMS__Assessment_Submission__c assSubRecTestPass=new US_WSREMS__Assessment_Submission__c();
        assSubRecTestPass.US_WSREMS__Provider_Email__c='test@test.com';
        assSubRecTestPass.US_WSREMS__Assessment__c=assRec.Id;
        assSubRecTestPass.US_WSREMS__Assessment_Result__c = 'Passed';
        assSubRecTestPass.US_WSREMS__Total_Number_of_Attempts__c = 3;
        assSubRec.US_WSREMS__Case__c=caseRec.Id;   
        insert assSubRecTestPass;       
    }
    @isTest
    public static void stakeholderTest(){
        US_WSREMS__Assessment_Submission__c assSubRec=[Select Id,US_WSREMS__Provider_Email__c From US_WSREMS__Assessment_Submission__c Where US_WSREMS__Total_Number_of_Attempts__c=1 limit 1];
        US_WSREMS__Assessment_Submission__c assSubRecTest=[Select Id,US_WSREMS__Provider_Email__c From US_WSREMS__Assessment_Submission__c Where US_WSREMS__Total_Number_of_Attempts__c=3 and US_WSREMS__Assessment_Result__c = 'Failed' limit 1];
        US_WSREMS__Assessment_Submission__c assSubRecTestPass=[Select Id,US_WSREMS__Provider_Email__c From US_WSREMS__Assessment_Submission__c Where US_WSREMS__Total_Number_of_Attempts__c=3 and US_WSREMS__Assessment_Result__c = 'Passed' limit 1];
        
       /* //Map<Id, US_WSREMS__Assessment_Submission__c> newMapAssesSubmission=new Map<Id, US_WSREMS__Assessment_Submission__c>();        
        //newMapAssesSubmission.put(assSubRec.id,assSubRec);
        //Map<Id, US_WSREMS__Assessment_Submission__c> newMapAssesSubmissionTest=new Map<Id, US_WSREMS__Assessment_Submission__c>();
        newMapAssesSubmissionTest.put(assSubRecTest.id,assSubRecTest);
        //Map<Id, US_WSREMS__Assessment_Submission__c> newMapAssesSubmissionTestPass=new Map<Id, US_WSREMS__Assessment_Submission__c>();
        newMapAssesSubmissionTestPass.put(assSubRecTestPass.id,assSubRecTestPass); */
        
        List<Id> listKAS = new List<Id>();
        listKAS.add(assSubRec.Id);        
        Tryvio_CorrespondenceHandler.stakeholderKnowledgeAssessment(listKAS);
        listKAS.clear();
        listKAS.add(assSubRecTest.Id);
        Tryvio_CorrespondenceHandler.stakeholderKnowledgeAssessment(listKAS);
        listKAS.clear();
        listKAS.add(assSubRecTestPass.Id);
        Tryvio_CorrespondenceHandler.stakeholderKnowledgeAssessment(listKAS);
        
    }
}