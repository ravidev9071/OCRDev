/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-07-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class AutomationCommunicationFromCaseTest {
    @testSetup
    public static void dataSetup(){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'AVEED REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        programList.add(programObj);
        
        US_WSREMS__REMS_Program__c piaSkyProgramObj = new US_WSREMS__REMS_Program__c();
        piaSkyProgramObj.Name = 'PiaSky REMS';
        piaSkyProgramObj.US_WSREMS__Status__c ='Active';
        piaSkyProgramObj.US_WSREMS__Program_State_Date__c = System.today();
        piaSkyProgramObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        programList.add(piaSkyProgramObj);
        insert programList;

        Account participantAccount = SYN_TestDataUtility.createAccount(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId(), 'test', 'prescriber');
        participantAccount.US_WSREMS__Status__c = 'Pending';
        participantAccount.Fax = '734727777';
        participantAccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        update participantAccount;

        case KAcaseRec = new case();
        KAcaseRec.Program_Record_Type_Control__c = 'AVEED REMS-Knowledge_Assessment';
        KAcaseRec.US_WSREMS__REMS_Program__c = programObj.Id;
        KAcaseRec.US_WSREMS__REMS_Program__r = programObj;
        KAcaseRec.Status = 'Draft';
        KAcaseRec.US_WSREMS__Channel__c = 'Fax';
        KAcaseRec.US_WSREMS__First_Name__c = 'test KA';
        KAcaseRec.US_WSREMS__Last_Name__c = 'test';
        KAcaseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        KAcaseRec.US_WSREMS__Program_Picklist__c = programObj.Name;
        KAcaseRec.US_WSREMS__Participant__r = participantAccount;
        KAcaseRec.US_WSREMS__Participant__c = participantAccount.Id;
        KAcaseRec.US_WSREMS__Email__c = 'test@test.com';
        KAcaseRec.US_WSREMS__Fax__c = '7653216217';
        insert KAcaseRec;
        
		id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PAE').getRecordTypeId();
        id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Id patientEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(piaSkyProgramObj.Id,recordTypeIdPatient);
        Account prescAcc = SYN_TestDataUtility.createPrescriberAccountWithNPI(piaSkyProgramObj.Id,recordTypeIdPrescriber);
        
        US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
            US_WSREMS__Participant__c=createPatientAccount.Id,
            US_WSREMS__REMSProgram__c = piaSkyProgramObj.Id,
            US_WSREMS__Service_Outcome__c='Successful',
            US_WSREMS__Status__c ='Closed', 
            RecordTypeId=SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'PAE_PC_MI'),
            US_WSREMS__Requestor_Type__c='Patient'
        );
        Insert objService;
        
        
        Case cs = New Case(RecordTypeid=caseRecordTypeId, US_WSREMS__REMS_Program__c=programObj.Id,US_WSREMS__Program_Picklist__c='AVEED REMS',
                           US_WSREMS__Channel__c='Phone',
                           US_WSREMS__Phone__c='9878887777',SYN_Reporter__c=createPatientAccount.Id,Date_Voicemail_or_Fax_received__c=Date.Today(),
                           SYN_Prescriber__c=prescAcc.ID,US_WSREMS__Patient__c=createPatientAccount.Id,Program_Record_Type_Control__c='AVEED REMS-PAE',
                           SYN_Event_Description__c='test',status='Complete',US_WSREMS__Outcome__c='Acknowledgment Pending',US_WSREMS__Participant__c=createPatientAccount.Id,US_WSREMS__REMS_Service_Summary__c = objService.Id,
                           SYN_Reporter_First_Name__c='Test', SYN_Reporter_Last_Name__c='testt',US_WSREMS__First_Name__c='test',US_WSREMS__Last_Name__c='testt');
        insert cs;
    }
    
    @isTest
    static void testGetAutomationCommunicationFromCaseData() {
        Case caseRec = [SELECT Id, Status, US_WSREMS__Outcome__c, RecordTypeId, US_WSREMS__Program_Name__c FROM Case WHERE US_WSREMS__Program_Name__c = 'Piasky REMS' LIMIT 1];
       caseRec.US_WSREMS__Channel__c='Fax';
        Test.startTest();
        update caseRec;
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(0, invocations);
    }

    @isTest
    private static void getAssessmentSubmissionRecordsByIdsTest(){
        Set<Id> assessmentIds = new Set<Id>();
        US_WSREMS__Assessment_Submission__c assessmentSubmission= new US_WSREMS__Assessment_Submission__c();
        assessmentSubmission.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Assessment_Submission__c.getSObjectType());
        assessmentIds.add(assessmentSubmission.Id);

        List<US_WSREMS__Assessment_Submission__c> assessmentList = new List<US_WSREMS__Assessment_Submission__c>();
        Test.startTest();
            assessmentList = AutomationCommunicationFromCase.getAssessmentSubmissionRecordsByIds(assessmentIds);
        Test.stopTest();
        system.assert(assessmentList != null, 'Assessment List is not null');
    }

    @isTest
    private static void getCasesByProgramAndaccountIdsTest(){
        Set<Id> accountIds = new Set<Id>();
        Account accountRec= new Account();
        accountRec.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        accountIds.add(accountRec.Id);

        List<Case> caseList = new List<Case>();
        Test.startTest();
            caseList = AutomationCommunicationFromCase.getCasesByProgramAndaccountIds(accountIds, 'AVEED REMS');
        Test.stopTest();
        system.assert(caseList != null , 'Case List is not null');
    }

    @isTest
    private static void getCasesByProgramAndCaseIdsTest(){
        Set<Id> caseIds = new Set<Id>();
        Case caseRec= new Case();
        caseRec.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseIds.add(caseRec.Id);

        List<Case> caseList = new List<Case>();
        Test.startTest();
            caseList = AutomationCommunicationFromCase.getCasesByProgramAndCaseIds(caseIds, 'AVEED REMS');
        Test.stopTest();
        system.assert(caseList != null, 'Case List is not null');
    }

    @isTest
    private static void getNonComplanceCasesByProgramAndaccountIdsTest(){
        Set<Id> accountIds = new Set<Id>();
        Account accountRec= new Account();
        accountRec.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        accountIds.add(accountRec.Id);

        List<Case> caseList = new List<Case>();
        Test.startTest();
            caseList = AutomationCommunicationFromCase.getNonComplanceCasesByProgramAndaccountIds(accountIds, 'AVEED REMS');
        Test.stopTest();
        system.assert(caseList != null, 'Case List is not null');
    }
    
    @isTest
    private static void getProgramFieldConfigurationsForIncompleteReasonsTest(){
        US_WSREMS__REMS_Program__c programObj = [Select Id,Name from US_WSREMS__REMS_Program__c Where Name = 'AVEED REMS' limit 1];
        US_WSREMS__Program_Fields_Configuration__c hcsPfc = new US_WSREMS__Program_Fields_Configuration__c();
        hcsPfc.US_WSREMS__Soft_Required__c = true;
        hcsPfc.US_WSREMS__Target_Object__c = 'Case';
        hcsPfc.US_WSREMS__Target_Object_Field__c = 'US_WSREMS__Email_ar__c';
        hcsPfc.US_WSREMS__Target_Object_Record_Type__c = 'HCS_Enrollment';
        hcsPfc.US_WSREMS__Target_Object_Field_Label__c = 'AR Email';
        hcsPfc.US_WSREMS__REMS_Program__c = programObj.Id;
        hcsPfc.US_WSREMS__REMS_Program__r = programObj;

        Map<String, List<US_WSREMS__Program_Fields_Configuration__c>> pfcMap = new Map<String, List<US_WSREMS__Program_Fields_Configuration__c>>();
        Test.startTest();
        insert hcsPfc;
            pfcMap = AutomationCommunicationFromCase.getProgramFieldConfigurationsForIncompleteReasons('Case', 'AVEED REMS');
        Test.stopTest();
        system.assert(pfcMap.values() != null, 'Program Configuration List is not null');
    }

    @isTest
    private static void sendEmailForKAResponsesTest(){
       	Case KAcaseRec = [SELECT Id,US_WSREMS__Participant__r.PersonEmail,US_WSREMS__Participant__c, US_WSREMS__Channel__c From Case Limit 1];
        US_WSREMS__REMS_Program__c programObj = [Select Id,Name from US_WSREMS__REMS_Program__c WHERE Name = 'AVEED REMS' limit 1];
        Map<Id,US_WSREMS__Assessment_Submission__c> newKAMap = new Map<Id,US_WSREMS__Assessment_Submission__c>();
        Map<Id,US_WSREMS__Assessment_Submission__c> oldKAMap = new Map<Id,US_WSREMS__Assessment_Submission__c>();
      
        US_WSREMS__Assessment__c  assessment = new US_WSREMS__Assessment__c();
        assessment.US_WSREMS__REMS_Program__r = programObj;
        assessment.US_WSREMS__REMS_Program__c = programObj.Id;
        assessment.US_WSREMS__Participant_Type__c='Prescriber';
        assessment.US_WSREMS__Pass_Percentage__c=100;
        assessment.US_WSREMS__Show_Wrong_Answers_Only__c=true;
        assessment.name='Knowledge Assessment';
        insert assessment;

        Test.startTest();
            Exception e;
            try{
                US_WSREMS__Assessment_Submission__c KA = new US_WSREMS__Assessment_Submission__c();
                KA.US_WSREMS__Case__r = KAcaseRec;
                KA.US_WSREMS__Case__c = KAcaseRec.Id;
                KA.US_WSREMS__Assessment_Result__c = 'Failed';
                KA.US_WSREMS__Total_Number_of_Attempts__c = 2;
                KA.US_WSREMS__Assessment__c= assessment.Id;
                insert KA;
                oldKAMap.put(KA.Id, KA);
                
                for(US_WSREMS__Assessment_Submission__c KARec:oldKAMap.values()){
                    US_WSREMS__Assessment_Submission__c newKARec = new US_WSREMS__Assessment_Submission__c();
                    newKARec.Id = KARec.Id;
                    newKARec.US_WSREMS__Assessment_Result__c = 'Failed';
                    newKAMap.put(newKARec.Id, newKARec);
                }
                update newKAMap.values();
                AutomationCommunicationFromCase.sendEmailForKAResponses(newKAMap, oldKAMap);
                } catch(exception ex){
                    e= ex;
                }
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(0, invocations);   
    }

    @isTest
    private static void getAffiliationsRecordsByHcsAccountIdsTest(){
        Set<Id> accountIds = new Set<Id>();
        Account accountRec= new Account();
        accountRec.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        accountIds.add(accountRec.Id);

        List<US_WSREMS__Affiliation__c> affiliationList = new List<US_WSREMS__Affiliation__c>();
        Test.startTest();
            affiliationList = AutomationCommunicationFromCase.getAffiliationsRecordsByHcsAccountIds(accountIds);
        Test.stopTest();
        system.assert(affiliationList != null, 'Affiliation List is not null');
    }
}