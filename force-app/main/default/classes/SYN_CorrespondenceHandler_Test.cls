/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-19-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SYN_CorrespondenceHandler_Test {
    
    @testSetup
    public static void dataSetup(){
        US_WSREMS__REMS_Program__c remsProg1 = new US_WSREMS__REMS_Program__c();
        remsProg1.Name = 'Sodium Oxybate REMS';
        remsProg1.REMS_Project_Code__c = 'BT6825';
        remsProg1.US_WSREMS__Status__c ='Active';
        remsProg1.QueueName__c ='Syneos Test Call Queue';
        insert remsProg1;
        
        Account acc=new Account();
        acc.Name='test';
        acc.Phone='1234567789';
        acc.US_WSREMS__REMS_Program__c=remsProg1.id;
        insert acc;
        Id patientRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        Id providerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Id ppRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        
        Account patientAccount = SYN_TestDataUtility.createAccount(remsProg1.Id,patientRecTypeId,'TestPatientFristName','TestPatientLastName');
        patientAccount.Fax = '1234568780';
        patientAccount.US_WSREMS__Email__c = 'aneeshas@wilcosource.com';
        patientAccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        update patientAccount;

        Account providerAccount = SYN_TestDataUtility.createAccount(remsProg1.Id,providerRecTypeId,'TestProviderFristName','TestProviderLastName');
        providerAccount.Fax = '1234568780';
        providerAccount.US_WSREMS__Email__c = 'aneeshas@wilcosource.com';
        providerAccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        Update providerAccount;
        
        Account ppAccount = SYN_TestDataUtility.createPharmacyParticipantAccountTest(remsProg1.Id ,ppRecTypeId );
        ppAccount.LastName = 'ppAccount123';
        ppAccount.US_WSREMS__Email__c = 'aneeshas@wilcosource.com';
        Update ppAccount;
        
        Id enrollmentCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();

        Case caseObj1 = SYN_TestDataUtility.createaNewCase(enrollmentCaseRecTypeId,'TestCaseFirstName','TestCaseLastName','Cancelled',remsProg1.Id);
        Id PrescriberCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();

        Case caseObj2 = SYN_TestDataUtility.createaNewCase(PrescriberCaseRecTypeId,'TestCaseFirstName','TestCaseLastName123','Cancelled',remsProg1.Id);
     
        SYN_SOXCorrespondenceHandler.pccCommunication(caseObj1);
        SYN_SOXCorrespondenceHandler soxHandler = new SYN_SOXCorrespondenceHandler();
        List<REMS_Outbound_Communication__c> communicationRec=new List<REMS_Outbound_Communication__c>();
        communicationRec.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseObj1,'Email','SOX-Patient Counseling Checklist Process'));
  
        //SYN_SOXCorrespondenceHandler.getCaseDetailstoSendEmail(communicationRec);
    
    
    }
    /*@isTest
    public static void sendEmailCorrespondencetest(){
        Test.startTest();
        string tempName1 = 'SOX-Stakeholder_Enrollment_Missing_Info';
        Account ptAccount =[SELECT Id, FirstName, LastName, US_WSREMS__Preferred_Contact_Method__c FROM Account WHERE LastName ='TestPatientLastName'];
        Account provAccount =[SELECT Id, FirstName, LastName, US_WSREMS__Preferred_Contact_Method__c FROM Account WHERE LastName ='TestProviderLastName'];
        case cs = [SELECT Id,US_WSREMS__Participant__c,Status,ownerId,US_WSREMS__Participant__r.personContactId,US_WSREMS__Prescriber__r.Fax,
                            US_WSREMS__Program_Name__c,Medical_Conditions__c,US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c,
                            US_WSREMS__Patient__r.Fax,SYN_Type_of_Reporter__c,US_WSREMS__Pharmacy_User__r.Fax,owner.email,owner.name,CaseNumber,Subject,
                            US_WSREMS__Prescriber__r.firstName, US_WSREMS__Prescriber__r.LastName, US_WSREMS__Patient__r.firstName, 
                            US_WSREMS__Patient__r.LastName, US_WSREMS__Pharmacy_User__r.firstName, US_WSREMS__Pharmacy_User__r.LastName,SYN_Prescriber_Fax__c 
                            FROM Case WHERE US_WSREMS__Last_Name__c ='TestCaseLastName' LIMIT 1];
        cs.Medical_Conditions__c = 'COPD';
        cs.US_WSREMS__Participant__c = ptAccount.Id;
        cs.US_WSREMS__Patient__c = ptAccount.Id;
        cs.US_WSREMS__Prescriber__c = provAccount.Id;
        cs.US_WSREMS__Phone__c = '9876543210';
        cs.US_WSREMS__Email__c = 'aneesha@gmail.com';        
        cs.SYN_Prescriber_First_Name__c = 'testtest';
        cs.SYN_Prescriber_Last_Name__c ='testLN';
        cs.SYN_Prescriber_Fax__c = '9876543210';
        cs.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        cs.Status='Draft';
       // cs.Approval_Status__c='Pending for DEA Override	';
       string pgrm = cs.US_WSREMS__Program_Name__c;
		
       cs.Program_Record_Type_Control__c = pgrm+'-Patient_Enrollement';
       update cs;
        Test.stopTest();
    }*/
    /*
    @isTest
    public static void sendFaxCorrespondencetest(){
        Test.startTest();
        string tempName1 = 'SOX-Stakeholder_Enrollment_Missing_Info';
        APXTConga4__Conga_Template__c congaTemplateKey = new APXTConga4__Conga_Template__c();
        congaTemplateKey.APXTConga4__Name__c= 'Conga_Risk Management Report Processed Successfully';
        congaTemplateKey.APXTConga4__Template_Type__c= 'Document';
        congaTemplateKey.APXTConga4__Key__c= '0T_009UAI182987';
        insert congaTemplateKey;

        Account ptAccount =[SELECT Id, FirstName, LastName, US_WSREMS__Preferred_Contact_Method__c FROM Account WHERE LastName ='TestPatientLastName' LIMIT 1];
        ptAccount.US_WSREMS__Preferred_Contact_Method__c ='Fax';
        update ptAccount;
        Account provAccount =[SELECT Id, FirstName, LastName, US_WSREMS__Preferred_Contact_Method__c FROM Account WHERE LastName ='TestProviderLastName' LIMIT 1];
        case cs = [SELECT Id,US_WSREMS__Participant__c,Status,ownerId,US_WSREMS__Participant__r.personContactId,US_WSREMS__Prescriber__r.Fax,US_WSREMS__Program_Name__c,Medical_Conditions__c,US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Patient__r.Fax,US_WSREMS__Pharmacy_User__r.Fax,owner.email,owner.name,CaseNumber,Subject,US_WSREMS__Prescriber__r.firstName, US_WSREMS__Prescriber__r.LastName, US_WSREMS__Patient__r.firstName, US_WSREMS__Patient__r.LastName, US_WSREMS__Pharmacy_User__r.firstName, US_WSREMS__Pharmacy_User__r.LastName FROM Case WHERE US_WSREMS__Last_Name__c ='TestCaseLastName' LIMIT 1];
        cs.Medical_Conditions__c = 'COPD';
        cs.US_WSREMS__Participant__c = ptAccount.Id;
        cs.US_WSREMS__Patient__c = ptAccount.Id;
        cs.US_WSREMS__Prescriber__c = provAccount.Id;
        cs.US_WSREMS__Phone__c = '9876543210';
        //cs.Status='Complete';
        cs.Approval_Status__c='Pending for DEA Override	';
        update cs;
        Test.stopTest();
    } */
   /*@isTest
    public static void PatientsendFaxCorrespondencetest(){
        Test.startTest();
        Account ptAccount =[SELECT Id, FirstName, LastName, US_WSREMS__Preferred_Contact_Method__c FROM Account WHERE LastName ='TestPatientLastName'];
       ptAccount.US_WSREMS__Preferred_Contact_Method__c ='Fax';
        update ptAccount;
        Account provAccount =[SELECT Id, FirstName, LastName, US_WSREMS__Preferred_Contact_Method__c FROM Account WHERE LastName ='TestProviderLastName'];
        case cs = [SELECT Id,US_WSREMS__Participant__c,Status,ownerId,US_WSREMS__Participant__r.personContactId,US_WSREMS__Prescriber__r.Fax,
                            US_WSREMS__Program_Name__c,Medical_Conditions__c,US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c,
                            US_WSREMS__Patient__r.Fax,US_WSREMS__Pharmacy_User__r.Fax,owner.email,owner.name,CaseNumber,Subject,
                            US_WSREMS__Prescriber__r.firstName,SYN_Type_of_Reporter__c, US_WSREMS__Prescriber__r.LastName, US_WSREMS__Patient__r.firstName, 
                            US_WSREMS__Patient__r.LastName, US_WSREMS__Pharmacy_User__r.firstName, US_WSREMS__Pharmacy_User__r.LastName,SYN_Prescriber_Fax__c 
                            FROM Case WHERE US_WSREMS__Last_Name__c ='TestCaseLastName123' LIMIT 1];
        cs.Medical_Conditions__c = 'COPD';
        cs.US_WSREMS__Participant__c = ptAccount.Id;
        cs.US_WSREMS__Patient__c = ptAccount.Id;
        cs.US_WSREMS__Prescriber__c = provAccount.Id;
        cs.US_WSREMS__Phone__c = '9876543210';
        cs.SYN_Prescriber_First_Name__c = 'testtest';
        cs.US_WSREMS__Email__c = 'aneesha@gmail.com';
        cs.SYN_Prescriber_Last_Name__c ='testLN';
        cs.SYN_Prescriber_Fax__c = '9876543210';
        cs.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        cs.Status='Draft';
        update cs;
        Test.stopTest();
    }*/
     @isTest
    public static void PatientFaxCorrespondencetest(){
        Test.startTest();
        Account ptAccount =[SELECT Id, FirstName, LastName, US_WSREMS__Preferred_Contact_Method__c FROM Account WHERE LastName ='TestPatientLastName'];
        Account provAccount =[SELECT Id, FirstName, LastName, US_WSREMS__Preferred_Contact_Method__c FROM Account WHERE LastName ='TestProviderLastName'];
        case cs = [SELECT Id,US_WSREMS__Participant__c,Status,ownerId,US_WSREMS__Participant__r.personContactId,US_WSREMS__Prescriber__r.Fax,
                            US_WSREMS__Program_Name__c,Medical_Conditions__c,US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c,
                            US_WSREMS__Patient__r.Fax,US_WSREMS__Pharmacy_User__r.Fax,owner.email,owner.name,CaseNumber,Subject,
                            US_WSREMS__Prescriber__r.firstName,SYN_Type_of_Reporter__c, US_WSREMS__Prescriber__r.LastName, US_WSREMS__Patient__r.firstName, 
                            US_WSREMS__Patient__r.LastName, US_WSREMS__Pharmacy_User__r.firstName,SYN_Prescriber__c,SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__Pharmacy_User__r.LastName,SYN_Prescriber_Fax__c 
                            FROM Case WHERE US_WSREMS__Last_Name__c ='TestCaseLastName' LIMIT 1];
        cs.Medical_Conditions__c = 'COPD';
        cs.US_WSREMS__Participant__c = ptAccount.Id;
        cs.US_WSREMS__Patient__c = ptAccount.Id;
        cs.SYN_Prescriber__c = provAccount.Id;
        cs.US_WSREMS__Phone__c = '9876543210';
        cs.SYN_Prescriber_First_Name__c = 'testtest';
        cs.US_WSREMS__Email__c = 'aneesha@gmail.com';
        cs.SYN_Prescriber_Last_Name__c ='testLN';
        cs.SYN_Prescriber_Fax__c = '9876543210';
       // cs.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        cs.Status='Draft';
        update cs;
        Test.stopTest();
    }

    @isTest
    public static void getAffiliationFirstAndLastDetailsTest(){

        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram(SYN_Utilitycls.XIAFLEX_PROGRAM_NAME, SYN_Utilitycls.pickListVal_Active);

        //Account Record Types
        Id hcpAccountRT = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.ACCOUNT_OBJECT, SYN_Utilitycls.Prescriber); 
        Id hcsAccountRT = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.ACCOUNT_OBJECT, 'Health_Care_Setting'); 

        List<Account> accList = new List<Account>();

        // Create Accounts
        Account healthCareSetting = new Account(
            Name = 'Health Care Setting',
            US_WSREMS__Email__c = 'healthcare@example.com',
            US_WSREMS__REMS_Program__c = programObj.Id,
            US_WSREMS__Preferred_Contact_Method__c = 'Email',
            US_WSREMS__Program_Type__c = SYN_Utilitycls.REMS,
            RecordTypeId = hcsAccountRT
        );
        accList.add(healthCareSetting);

        Account prescriber = new Account(
            FirstName = 'Prescriber',
            LastName = 'Test123',
            PersonEmail = 'prescriber@example.com',
            US_WSREMS__REMS_Program__c = programObj.Id,
            US_WSREMS__Preferred_Contact_Method__c = 'Email',
            US_WSREMS__Program_Type__c = SYN_Utilitycls.REMS,
            RecordTypeId = hcpAccountRT
        );
        accList.add(prescriber);

        insert accList;

        // Retrieve record types
        Id prescriberAffiliationRT = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.AFFILIATION_OBJECT, SYN_Utilitycls.PRESCRIBER_AFFILIATION_RECORDTYPENAME); 
        Id hcsAffiliationRT = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.AFFILIATION_OBJECT, 'Healthcare_Setting_Affiliation'); 
        
        List<US_WSREMS__Affiliation__c> affList = new List<US_WSREMS__Affiliation__c>();

        // Create affiliations
        US_WSREMS__Affiliation__c prescriberAffiliation = new US_WSREMS__Affiliation__c(
            RecordTypeId = prescriberAffiliationRT,
            US_WSREMS__Prescriber__c = accList[1].Id,
            US_WSREMS__Health_Care_Setting__c = accList[0].Id,
            US_WSREMS__isActive__c = TRUE,
            US_WSREMS__REMSProgram__c = programObj.Id
        );
        affList.add(prescriberAffiliation);

        US_WSREMS__Affiliation__c hcsAffiliation = new US_WSREMS__Affiliation__c(
            RecordTypeId = hcsAffiliationRT,
            US_WSREMS__Prescriber__c = accList[1].Id,
            US_WSREMS__Health_Care_Setting__c = accList[0].Id,
            US_WSREMS__isActive__c = TRUE,
            US_WSREMS__REMSProgram__c = programObj.Id
        );
        affList.add(hcsAffiliation);

        insert affList;
        System.assertEquals(affList.size(), 2);
        SYN_SOXCorrespondenceHandler.getAffiliationFirstAndLastDetails( new Set<Id>{ accList[0].Id }, 'Health_Care_Setting');
        SYN_SOXCorrespondenceHandler.getAffiliationFirstAndLastDetails( new Set<Id>{ accList[1].Id }, SYN_Utilitycls.Prescriber);
        system.assertNotEquals(SYN_SOXCorrespondenceHandler.affiliationFirstAndLastReferenceMap, NULL);
    } 
}