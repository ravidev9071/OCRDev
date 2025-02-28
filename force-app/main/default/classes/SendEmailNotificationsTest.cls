/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-29-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest(isParallel = true)
private class SendEmailNotificationsTest {

    @TestSetup
    static void  testDataSetup(){
        List<sObject> updateList = new List<sObject>();
        id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('PiaSky REMS', 'Active');
        programObj.REMS_Project_Code__c = 'BT1005';
        update programObj;
        Account prescriberAccount = SYN_TestDataUtility.createPrescriberAccountWithNPIemail(programObj.Id, recordTypeId);
        prescriberAccount.US_WSREMS__Email__c = 'test@example.com';
        updateList.add(prescriberAccount);
        
        Id serviceRecordType = Schema.sObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get('Participant Account Creation').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c service =  SYN_TestDataFactory.createService(true,programObj.Id, serviceRecordType);
        service.US_WSREMS__REMSProgram__c = programObj.Id;
        service.US_WSREMS__Requestor_Type__c = 'Prescriber';
        service.US_WSREMS__Path_Stage_Name__c = 'Intake';
        updateList.add(service);

        id caseRecTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        Case caseRecord = SYN_TestDataUtility.createCase(caseRecTypeId, service.Id, 'Test', 'LastName', 'Draft');
        caseRecord.SYN_Prescriber__c = prescriberAccount.Id;
        caseRecord.US_WSREMS__Email__c = 'test@example.com';
        updateList.add(caseRecord);

        update updateList; 
        //*******************************************************//
        US_WSREMS__REMS_Program__c remsProgram = new US_WSREMS__REMS_Program__c(Name = 'TRYVIO REMS',US_WSREMS__Status__c ='Active',REMS_Project_Code__c = 'BT4324'); 
        insert  remsProgram;
        Id prescriberAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Account prescriberAccObj = SYN_TestDataUtility.createAccount(remsProgram.id, prescriberAccRecTypeId, 'FirstName', 'LastName');
        prescriberAccObj.US_WSREMS__Email__c='test@test.com';
        prescriberAccObj.PersonEmail='test@test.com';        
        prescriberAccount.US_WSREMS__Status__c ='Certified - On Hold';
        update prescriberAccObj;
        Account prescriberAccObjNew = SYN_TestDataUtility.createAccount(remsProgram.id, prescriberAccRecTypeId, 'FirstName', 'LastName');
        prescriberAccObjNew.US_WSREMS__Email__c='abc@test.com';
        prescriberAccObjNew.PersonEmail='abc@test.com';
        update prescriberAccObjNew;
        Id prescribercaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_Person_Account').getRecordTypeId();
        Id outPatientRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Outpatient_Pharmacy_Enrollment').getRecordTypeId();
        Id inPatientRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inpatient_Pharmacy_Enrollment').getRecordTypeId();
        Case caseRec = new Case();
        caseRec.RecordTypeId=inPatientRT;   
        caseRec.US_WSREMS__Program_Picklist__c ='TRYVIO REMS';
        caseRec.US_WSREMS__REMS_Program__c = remsProgram.id;
        caseRec.US_WSREMS__Call_Notes__c = 'test';
        caseRec.Us_WSREMS__Participant__c=prescriberAccObjNew.id;
        caseRec.AccountId=prescriberAccObj.Id;
        caseRec.US_WSREMS__REMS_Authorized_Rep__c=prescriberAccObjNew.id;
       // caseRec.Status='Certified - On Hold';
        caseRec.Program_Record_Type_Control__c='TRYVIO REMS-Inpatient_Pharmacy_Enrollment';
        //caseRec.US_WSREMS__Pharmacy_Type__c = 'Retail';
        insert caseRec; 
        Case caseRecSpecial = new Case();
        caseRecSpecial.RecordTypeId=inPatientRT;
        caseRecSpecial.US_WSREMS__Program_Picklist__c ='TRYVIO REMS';
        caseRecSpecial.US_WSREMS__REMS_Program__c = remsProgram.id;
        caseRecSpecial.US_WSREMS__Call_Notes__c = 'test';
        caseRecSpecial.Us_WSREMS__Participant__c=prescriberAccObjNew.id;
        caseRecSpecial.AccountId=prescriberAccObj.Id;
        caseRecSpecial.US_WSREMS__REMS_Authorized_Rep__c=prescriberAccObjNew.id;
        //caseRecSpecial.Status='Certified - On Hold';
        caseRecSpecial.Program_Record_Type_Control__c='TRYVIO REMS-Inpatient_Pharmacy_Enrollment';
        //caseRecSpecial.US_WSREMS__Pharmacy_Type__c = 'Specialty';
        insert caseRecSpecial; 
        Case caseNewRec = new Case();
        caseNewRec.RecordTypeId=inPatientRT;
        caseNewRec.US_WSREMS__Program_Picklist__c ='TRYVIO REMS';
        caseNewRec.US_WSREMS__REMS_Program__c = remsProgram.id;
        caseNewRec.US_WSREMS__Call_Notes__c = 'test';
        caseNewRec.Us_WSREMS__Participant__c=prescriberAccObj.id;
        caseNewRec.AccountId=prescriberAccObj.Id;
        //caseNewRec.Status='Certified - On Hold';
        caseNewRec.Program_Record_Type_Control__c='TRYVIO REMS-Inpatient_Pharmacy_Enrollment';
        //caseNewRec.US_WSREMS__Pharmacy_Type__c = 'Retail';
        caseNewRec.US_WSREMS__REMS_Authorized_Rep__c=prescriberAccObj.id;
        insert caseNewRec; 
        Contact con=new Contact();            
        con.LastName='TestLName';
        insert con;
    }

    @isTest
    private static void getNotificationPiaskyWhenStatusCompleteTest(){
        Contact contactRecord = new Contact();
        contactRecord.FirstName ='TestEmailTemplate-DoNotDelete';
        contactRecord.LastName ='Test';
        insert contactRecord;
        
        US_WSREMS__REMS_Program__c programObj = [SELECT id,Name FROM US_WSREMS__REMS_Program__c LIMIT 1];
		US_WSREMS__REMS_Service_Summary__c service = [SELECT Id, US_WSREMS__REMSProgram__c, US_WSREMS__Requestor_Type__c,
                                                    US_WSREMS__Path_Stage_Name__c, US_WSREMS__Service_Outcome__c
                                                    FROM US_WSREMS__REMS_Service_Summary__c LIMIT 1];

        
        Case caseRecord = [SELECT Id,US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__Email__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c,
                                US_WSREMS__Program_Name__c, RecordType.DeveloperName, US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c,
                                Status, US_WSREMS__Incomplete_Reasons__c, US_WSREMS__Email__c,SYN_Prescriber__c,SYN_Prescriber__r.Name,SYN_Prescriber__r.US_WSREMS__Email__c
                                FROM Case LIMIT 1];
        String programName = 'PiaSky REMS';
        caseRecord.Status = 'Complete';
        caseRecord.US_WSREMS__REMS_Program__c = programObj.Id;
        List<Case> caseList = new List<Case>();
        caseList.add(caseRecord);
        
        Test.startTest();
            SendEmailNotifications.getNotificationPiasky(caseList, programName);
        	Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(0, invocations);   
    }
    
    @isTest
    private static void getAllEmailTemplateIdsTest(){
        Case caseRecord = [SELECT Id,US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__Email__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c,
                                US_WSREMS__Program_Name__c, RecordType.DeveloperName, US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c,
                                Status, US_WSREMS__Incomplete_Reasons__c, US_WSREMS__Email__c
                                FROM Case LIMIT 1];
        String programName = 'PiaSky REMS';
        caseRecord.US_WSREMS__Incomplete_Reasons__c = 'Date of Data Exchange Completion';
        caseRecord.Status = 'Draft';
        List<Case> caseList = new List<Case>();
        caseList.add(caseRecord);
        
        Test.startTest();
            SendEmailNotifications.getNotificationPiasky(caseList, programName);
            Map<String, String> templateIdMap = SendEmailNotifications.getAllEmailTemplateIds(programName);
        Test.stopTest();
        System.assert(templateIdMap.values() != null);  
    }

    
//This method is Added By Rajeev for TRYVIO REMS Correspondence Template on 2nd June 2024

@isTest

public static void sendEmailForPAEPCReportableFormEventTRYVIO_Test() {

  id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();

        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PAE_PC_MI').getRecordTypeId();

        id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();

        

        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');

        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);

        Account prescAcc = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);

        

        US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(

            US_WSREMS__Participant__c=prescAcc.Id,

            US_WSREMS__Requestor_Type__c = 'Prescriber',  

            US_WSREMS__REMSProgram__c = programObj.Id,

            US_WSREMS__Service_Outcome__c='Successful',

            US_WSREMS__Status__c ='Closed', 

            RecordTypeId=SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'PAE_PC_MI')

        );

        Insert objService;

        Case cs = New Case(RecordTypeid=caseRecordTypeId, US_WSREMS__REMS_Program__c=programObj.Id,US_WSREMS__Program_Picklist__c='Macitentan REMS',

                        US_WSREMS__Channel__c='Phone',SYN_Type_of_Report__c='Product Quality Compliant',SYN_Sponsor_Responsible__c='Actelion Pharmaceuticals US, Inc., a Johnson & Johnson Company',

                        US_WSREMS__Phone__c='9878887777',SYN_Reporter__c=createPatientAccount.Id,Date_Voicemail_or_Fax_received__c=Date.Today(),

                        SYN_Prescriber__c=prescAcc.ID,US_WSREMS__Patient__c=createPatientAccount.Id,Sponsor_Responsible_1__c='Actelion Pharmaceuticals US, Inc., a Johnson & Johnson Company',Age__c=65,

                        SYN_Event_Description__c='test',status='Complete',US_WSREMS__Outcome__c='Acknowledgment Pending',US_WSREMS__Participant__c=createPatientAccount.Id,US_WSREMS__REMS_Service_Summary__c = objService.Id,

                        SYN_Reporter_First_Name__c='Test', SYN_Reporter_Last_Name__c='testt',US_WSREMS__First_Name__c='test',US_WSREMS__Last_Name__c='testt');

        insert cs;


        //List<Case> csList = New List<Case>();
        Set<Id> csSet = new Set<Id>();
        csSet.add(cs.Id);

    // csList.add(cs);

        Test.StartTest();  
        
        SendEmailNotifications.sendEmailForPAEPCReportableFormEventTRYVIO(csSet);

        //MACIAutomationCommunicationUtility.getReportableEventFormMACI(csSet);

        Test.StopTest();  
    }
    // End Rajeev 
    
@isTest
private static void sendAveedCaseNotificationTest(){
    Id prescriberRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
    Id hcsReEnrollmentRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Reenrollment');
    Id caseHCSRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
    Id hcsRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');

    List<Case> caseList = new List<Case>();

    Account hcsAccountRecord = new Account();
    hcsAccountRecord.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
    hcsAccountRecord.US_WSREMS__Status__c = 'Disenrolled';
    hcsAccountRecord.US_WSREMS__Sub_Status__c = 'Program Opt-Out';
    hcsAccountRecord.recordTypeId = hcsRecordType;

    Account authAccountRecord = new Account();
    authAccountRecord.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
    authAccountRecord.recordTypeId = prescriberRecordType;

    Case hcsCaseRecord = new Case();
    hcsCaseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
    hcsCaseRecord.Status = 'Complete';
    hcsCaseRecord.RecordTypeId = hcsReEnrollmentRecordType;
    hcsCaseRecord.US_WSREMS__Participant__r = hcsAccountRecord;
    hcsCaseRecord.US_WSREMS__Email_ar__c = 'test@test.com';
    hcsCaseRecord.US_WSREMS__REMS_Authorized_Rep__r = authAccountRecord;

    caseList.add(hcsCaseRecord);

    Test.startTest();
        	SendEmailNotifications.sendAveedCaseNotificationAsync(caseList);
    Test.stopTest();

    Integer invocations = Limits.getEmailInvocations();
    system.assertEquals(0, invocations, 'Target object is required');
}

@isTest
    private static void prepareBodyForHCSTemplatesTest(){
    Id prescriberRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');

    Account authAccountRecord = (Account) JSON.deserialize('{"US_WSREMS__First_And_Last_Name__c":"Test Prescriber"}', Account.class);
    authAccountRecord.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
    authAccountRecord.recordTypeId = prescriberRecordType;
    authAccountRecord.FirstName = 'Test';

    Account participantRecord = new Account();
    participantRecord.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
    participantRecord.recordTypeId = prescriberRecordType;
   	participantRecord.Name = 'Test';
    participantRecord.US_WSREMS__Address_Line_1__c = 'Test';
    participantRecord.US_WSREMS__City__c = 'Hyd';
    participantRecord.US_WSREMS__State__c = 'NY';
    participantRecord.US_WSREMS__Zip__c = '20091';

    US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c();
    affiliationRecord.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
    affiliationRecord.US_WSREMS__Authorized_Representative__r = authAccountRecord;
    affiliationRecord.US_WSREMS__Authorized_Representative__c = authAccountRecord.Id;

    Case nonComplainceCaseRecord = new Case();
    nonComplainceCaseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
    nonComplainceCaseRecord.US_WSREMS__X1_Participant__r = participantRecord;

    String aveedHtmlBody = '{{PRESCRIBER_NAME}} {{REMS_ID}} {{REMS_DESCRIPTION}} {{HCS_NAME}} {{HCS_ADDRESS}} {{HCS_CITY}} {{HCS_STATE}} {{HCS_ZIP}}';

    Test.startTest();
    	String body = SendEmailNotifications.prepareBodyForHCSTemplates(affiliationRecord, nonComplainceCaseRecord, aveedHtmlBody);
    Test.stopTest();
    
    System.assert(body.contains(authAccountRecord.US_WSREMS__First_And_Last_Name__c),'Test Prescriber');
    }

    
    
    @isTest
    private static void pprepareBodyForHCPTemplateTest(){
    Id prescriberRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');

    Account authAccountRecord = (Account) JSON.deserialize('{"US_WSREMS__First_And_Last_Name__c":"Test Prescriber"}', Account.class);
    authAccountRecord.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
    authAccountRecord.recordTypeId = prescriberRecordType;
    authAccountRecord.FirstName = 'Test';

    Account participantRecord = new Account();
    participantRecord.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
    participantRecord.recordTypeId = prescriberRecordType;
   	participantRecord.Name = 'Test';
    participantRecord.US_WSREMS__Address_Line_1__c = 'Test';
    participantRecord.US_WSREMS__City__c = 'Hyd';
    participantRecord.US_WSREMS__State__c = 'NY';
    participantRecord.US_WSREMS__Zip__c = '20091';

    Case nonComplainceCaseRecord = new Case();
    nonComplainceCaseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
    nonComplainceCaseRecord.US_WSREMS__X1_Participant__r = participantRecord;
    nonComplainceCaseRecord.US_WSREMS__Description__c = 'test';

    String aveedHtmlBody = '{{PRESCRIBER_NAME}} {{REMS_ID}} {{REMS_DESCRIPTION}} {{HCS_NAME}} {{HCS_ADDRESS}} {{HCS_CITY}} {{HCS_STATE}} {{HCS_ZIP}}';

    Test.startTest();
    	String body = SendEmailNotifications.prepareBodyForHCPTemplate(nonComplainceCaseRecord, aveedHtmlBody);
    Test.stopTest();
        
    System.assert(body.contains(nonComplainceCaseRecord.US_WSREMS__Description__c), 'Description');
    }
    

    @isTest
    private static void prepareBodyForAffiliationHCSTemplatesTest(){
    Id prescriberRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');

    Account authAccountRecord = (Account) JSON.deserialize('{"US_WSREMS__First_And_Last_Name__c":"Test Prescriber"}', Account.class);
    authAccountRecord.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
    authAccountRecord.recordTypeId = prescriberRecordType;
    authAccountRecord.FirstName = 'Test';

    Account participantRecord = new Account();
    participantRecord.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
    participantRecord.recordTypeId = prescriberRecordType;
   	participantRecord.Name = 'Test';
    participantRecord.US_WSREMS__Address_Line_1__c = 'Test';
    participantRecord.US_WSREMS__City__c = 'Hyd';
    participantRecord.US_WSREMS__State__c = 'NY';
    participantRecord.US_WSREMS__Zip__c = '20091';

    US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c();
    affiliationRecord.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
    affiliationRecord.US_WSREMS__Authorized_Representative__r = authAccountRecord;
    affiliationRecord.US_WSREMS__Authorized_Representative__c = authAccountRecord.Id;

    Case nonComplainceCaseRecord = new Case();
    nonComplainceCaseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
    nonComplainceCaseRecord.US_WSREMS__X1_Participant__r = participantRecord;

    String aveedHtmlBody = '{{AUTHREP_NAME}} {{REMS_ID}} {{DEACTIVATION_DATE}} {{REMS_DESCRIPTION}} {{HCS_NAME}} {{HCS_ADDRESS}} {{HCS_CITY}} {{HCS_STATE}} {{HCS_ZIP}}';

    Test.startTest();
    	String body = SendEmailNotifications.prepareBodyForAffiliationHCSTemplates(affiliationRecord, participantRecord, aveedHtmlBody);
    Test.stopTest();
    
    System.assert(body.contains(authAccountRecord.US_WSREMS__First_And_Last_Name__c),'Test Prescriber');
    }
    @isTest
    private static void sendAveedAccountDeactivationNotificationFromAccountTest(){

        Account authAccountRecord = (Account) JSON.deserialize('{"US_WSREMS__First_And_Last_Name__c":"Test Prescriber"}', Account.class);
        authAccountRecord.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        authAccountRecord.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        authAccountRecord.FirstName = 'Test';
        authAccountRecord.PersonEmail = 'test@test.com';

        Account prescriberAcount = new Account();
        prescriberAcount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberAcount.US_WSREMS__Status__c = 'Deactivated';
        prescriberAcount.US_WSREMS__Sub_Status__c = 'Opt-Out';
        prescriberAcount.PersonEmail = 'test@test.com';
        prescriberAcount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();

        Account hcsAccount = new Account();
        hcsAccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsAccount.US_WSREMS__Status__c = 'Deactivated';
        hcsAccount.US_WSREMS__Sub_Status__c = 'Opt-Out';
        hcsAccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();

        Account hcsAccountForArNotConfirm = new Account();
        hcsAccountForArNotConfirm.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsAccountForArNotConfirm.US_WSREMS__Status__c = 'Decertified';
        hcsAccountForArNotConfirm.US_WSREMS__Sub_Status__c = 'AR Not Confirmed';
        hcsAccountForArNotConfirm.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();

        Account hcsAccountForenrollexpire = new Account();
        hcsAccountForenrollexpire.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsAccountForenrollexpire.US_WSREMS__Status__c = 'Decertified';
        hcsAccountForenrollexpire.US_WSREMS__Sub_Status__c = 'Failure to recertify';
        hcsAccountForenrollexpire.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();

        US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c();
        affiliationRecord.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRecord.US_WSREMS__Authorized_Representative__r = authAccountRecord;
        affiliationRecord.US_WSREMS__Authorized_Representative__c = authAccountRecord.Id;

        Map<Id,US_WSREMS__Affiliation__c> affiliationMap = new Map<Id,US_WSREMS__Affiliation__c>();
        affiliationMap.put(hcsAccount.Id, affiliationRecord);
        affiliationMap.put(hcsAccountForArNotConfirm.Id, affiliationRecord);
        affiliationMap.put(hcsAccountForenrollexpire.Id, affiliationRecord);

        List<Account> accountList = new List<Account>();
        accountList.add(hcsAccount);
        accountList.add(hcsAccountForArNotConfirm);
        accountList.add(hcsAccountForenrollexpire);
        accountList.add(prescriberAcount);
        Test.startTest();
            SendEmailNotifications.sendAveedAccountDeactivationNotificationFromAccount(accountList, affiliationMap);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(0, invocations);
    }

    @isTest
    private static void sendAveedAccountDeactivationNotificationForNonComplianceTest(){

        Account authAccountRecord = (Account) JSON.deserialize('{"US_WSREMS__First_And_Last_Name__c":"Test Prescriber"}', Account.class);
        authAccountRecord.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        authAccountRecord.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        authAccountRecord.FirstName = 'Test';
        authAccountRecord.PersonEmail = 'test@test.com';

        Account prescriberAcount = new Account();
        prescriberAcount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberAcount.US_WSREMS__Status__c = 'Decertified';
        prescriberAcount.US_WSREMS__Sub_Status__c = 'Program Noncompliant';
        prescriberAcount.PersonEmail = 'test@test.com';
        prescriberAcount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();

        Account hcsAccount = new Account();
        hcsAccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsAccount.US_WSREMS__Status__c = 'Decertified';
        hcsAccount.US_WSREMS__Sub_Status__c = 'Program Noncompliant';
        hcsAccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();

        US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c();
        affiliationRecord.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRecord.US_WSREMS__Authorized_Representative__r = authAccountRecord;
        affiliationRecord.US_WSREMS__Authorized_Representative__c = authAccountRecord.Id;

        Map<Id,US_WSREMS__Affiliation__c> affiliationMap = new Map<Id,US_WSREMS__Affiliation__c>();
        affiliationMap.put(hcsAccount.Id, affiliationRecord);

        Case nonComplianceCaseRec = new Case();
        nonComplianceCaseRec.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        nonComplianceCaseRec.US_WSREMS__X1_Participant__r = hcsAccount;
        nonComplianceCaseRec.US_WSREMS__X1_Participant__c = hcsAccount.Id;
        nonComplianceCaseRec.recordTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();

        Case nonComplianceCaseRecforPrescriber = new Case();
        nonComplianceCaseRecforPrescriber.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        nonComplianceCaseRecforPrescriber.US_WSREMS__X1_Participant__r = prescriberAcount;
        nonComplianceCaseRecforPrescriber.US_WSREMS__X1_Participant__c = prescriberAcount.Id;
        nonComplianceCaseRecforPrescriber.recordTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();

        List<Case> caseList = new List<Case>();
        caseList.add(nonComplianceCaseRec);
        caseList.add(nonComplianceCaseRecforPrescriber);

        Test.startTest();
            SendEmailNotifications.sendAveedAccountDeactivationNotificationForNonCompliance(caseList, affiliationMap);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(0, invocations);
    }

}