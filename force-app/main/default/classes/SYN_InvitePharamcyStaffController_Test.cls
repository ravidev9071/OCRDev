/**************************************************************************
* Name :   SYN_InvitePharamcyStaffController_Test

Modification Log:
----------------------------------------------------------------------------------
Developer               Date                   Description
-----------------------------------------------------------------------------------
Prasanth Kumar        06/03/2023              Initial Version
*********************************************************************************/


@isTest
public class SYN_InvitePharamcyStaffController_Test{
    
    @isTest
    public static void getPharmacy_Test() {
        
        Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        Id recordTypeIdPharmacy= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        
        // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        // Profile Query for Inserting community user 
        Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
        User usr;
        Account acc;
        
        Test.StartTest();
        Account pharmCAccount;
        System.runAs (communitydefaulowner) {
            pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy);
            
            // Create Pharmacy participant Account
            acc = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,RecordTypeIdPhPa);
            
            // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Pharmacy');
        }
        
        system.runAs(usr){
            
            // Covering code coverage for get Pharmacist Info method
            SYN_InvitePharamcyStaffController.getPharmacistInfo();
            
            // Covering code coverage for get Pharmacy method
            SYN_InvitePharamcyStaffController.getPharmacyInfo(pharmCAccount,programObj.id);
            
            // Covering code coverage for get Pharmacy title
            SYN_InvitePharamcyStaffController.getPharmacyTitle();
            
            // Covering code coverage for get Pharmacy Credentials
            SYN_InvitePharamcyStaffController.getPharmacyCredentails();
        }
        
        Test.StopTest();
        
    }
    
    
    
    @isTest
    public static void validatePharmacyStaffDupCheck_Test() {
        
        // Pharmacy account record type Id 
        Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        // Id pharmCINPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
        Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        
        
        // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        // Profile Query for Inserting community user 
        Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
        
        Test.StartTest();
        System.runAs (communitydefaulowner) {
            
            // Collecting Pharmacy and Pharmacy Participant Account
            account pharmacyAcc = SYN_TestDataUtility.createPharmacyAccountTest(programObj.id,PharmacyAccRecordTypeId);
            // case pharmacyCase = SYN_TestDataUtility.createCasePharmacyTest(pharmCINPatCaseRecTypeId,programObj.Id,pharmacyAcc.Id);
            account pharmacyParticipantAcc = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,RecordTypeIdPhPa);
            
            boolean duplicateFlag=SYN_InvitePharamcyStaffController.validatePharmacyStaffDupCheck('PharmacyPartD','Account','phartest@test.com',programObj.id,pharmacyParticipantAcc);
            System.Assert(duplicateFlag == false);
        }
        Test.StopTest();                         
    }
    
    @isTest
    public static void createPharmacyPortalUserArAccount_Test() {
        
        // Pharmacy account record type Id 
        Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        Id pharmCINPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
        
        // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        // Profile Query for Inserting community user 
        Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
        
        Test.StartTest();
        System.runAs (communitydefaulowner) {
            
            // Collecting Pharmacy Account and case
            account pharmacyAcc = SYN_TestDataUtility.createPharmacyAccountTest(programObj.id,PharmacyAccRecordTypeId);
            case pharmacyCase = SYN_TestDataUtility.createCasePharmacyTest(pharmCINPatCaseRecTypeId,programObj.Id,pharmacyAcc.Id);
            account pharmacyParticipantAcc = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,RecordTypeIdPhPa);
            
            string pharmacyUsr=  SYN_InvitePharamcyStaffController.createPharmacyPortalUserArAccount(pharmacyCase,'Inpatient',pharmacyAcc,programObj.Id,'Authorized Representative',pharmacyParticipantAcc,null);
            System.Assert(pharmacyUsr !=null);
        }
        Test.StopTest();                         
    }
    
   @isTest
    public static void verifyRDAInfo_Test() {
         // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        // Profile Query for Inserting community user 
        Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
        User usr;
        Account prescriberAccount;
        Account patientAccount;
        Case patietnEnrollmentCase;
        Test.StartTest();
        System.runAs (communitydefaulowner) {
        
            // Create Prescriber Account
            prescriberAccount= SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
            
            id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
            Account prescriberacc = SYN_InvitePharamcyStaffController.validatePrescriberData('9999999999',programObj.id);
            System.Assert(prescriberacc !=null);
            Account patientacc = SYN_InvitePharamcyStaffController.validatePatientData('Test - P','','LastName-Patient',Date.newInstance(1988, 12, 9),programObj.id);
            System.Assert(patientacc !=null);

           
        }
           
        Test.StopTest();
    
    }
    
     @isTest
    public static void createPharmacyAccount_MaciPortalTest() {
        Id recordTypeIdPharmacy= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        
        Account patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
        Account pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy);
        Account pharmcParticipantAcc = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,RecordTypeIdPhPa);
        Account prescAcc = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        
        Test.StartTest();
        SYN_InvitePharamcyStaffController.getCurrentPharmacyInfo(pharmCAccount.Id);
        Map<String,String> manufMap = SYN_InvitePharamcyStaffController.getRDAManufacturerValues();
        Map<String,String> NDCMap = SYN_InvitePharamcyStaffController.getRDANDCCodeValues();
        Map<String,String> reasondForDaysSupplyMap = SYN_InvitePharamcyStaffController.getResonsForDaysSupplyValues();
        Map<String,String> reasondForDaysInterrSupplyMap = SYN_InvitePharamcyStaffController.getResonsForTreatmentInterrValues();
        SYN_InvitePharamcyStaffController.createPharmacyPatientTestRecord(programObj.id,patientAccount.id,pharmCAccount,programObj.Name,'Portal',pharmcParticipantAcc.Id,prescAcc.Id);
        SYN_InvitePharamcyStaffController.createPatientCounselingChecklistCaseRecord(pharmcParticipantAcc,pharmCAccount,prescAcc,patientAccount,'Portal');
        case cs =New case();
        string Id = SYN_InvitePharamcyStaffController.createRDACaseRecord(cs,pharmcParticipantAcc,pharmCAccount,prescAcc,patientAccount);
        Test.StopTest();
        
    }

    @isTest
    public static void getPharmacyAffilicationInfo_Test() {
        
        // Pharmacy account record type Id 
        Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        Id pharmCINPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
        Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        
        
        // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        // Profile Query for Inserting community user 
        Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
        
        Test.StartTest();
        System.runAs (communitydefaulowner) {
            
            // Collecting Patient Account
            account pharmacyAcc = SYN_TestDataUtility.createPharmacyAccountTest(programObj.id,PharmacyAccRecordTypeId);
            case pharmacyCase = SYN_TestDataUtility.createCasePharmacyTest(pharmCINPatCaseRecTypeId,programObj.Id,pharmacyAcc.Id);
            account pharmacyParticipantAcc = SYN_TestDataUtility.createPharmacyParticipantAccountAuthrepTest(programObj.Id,RecordTypeIdPhPa,pharmacyAcc.Id);
            
            US_WSREMS__Affiliation__c affiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmacyParticipantAcc.Id,pharmacyAcc.Id);
            
            //account pharmAcc= SYN_ManagePharamcyController.getPharmacyInfo(pharmacyAcc,programObj.id);
            //System.Assert(pharmAcc != null);
            List<US_WSREMS__Affiliation__c> affilationList = SYN_InvitePharamcyStaffController.getCurrentPharmacyAffilcationList(pharmacyAcc.id);
            System.Assert(!affilationList.isEmpty());
            boolean invaliddate = SYN_InvitePharamcyStaffController.checkInvitatoDate(Date.Today());
            boolean validdate = SYN_InvitePharamcyStaffController.checkInvitatoDate(Date.Today()+3);

        }
        Test.StopTest();                         
    }
    
    public static testMethod void RDACaseInfo_Test() {
        id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id recordTypeIdPharmacy = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        id casePDARecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();
        id recordTypeIdREMSService = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Pre_Dispense_Authorization').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        US_WSREMS__Program_Users__c programUser = SYN_TestDataUtility.createProgramUser(UserInfo.getUserId(),programObj.id);
        Test.StartTest();   
        Account prescAccount = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        Account patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
        Account pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy);
        Account pharmCParticipanAccount = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,recordTypeIdPharmacyParticipant);
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c(US_WSREMS__REMSProgram__c = programObj.id,US_WSREMS__Requestor_Type__c = 'Pharmacy',US_WSREMS__Participant__c = pharmCAccount.id, recordTypeId = recordTypeIdREMSService);
        Insert serviceObj;
        US_WSREMS__Affiliation__c createAffiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmCParticipanAccount.Id,pharmCAccount.Id);
        Case caseObjNPI = SYN_TestDataUtility.createaRDACase(casePDARecordTypeId,programObj.id,prescAccount,patientAccount,pharmCAccount,pharmCParticipanAccount,serviceObj);
        US_WSREMS__Shipping_and_Tracking__c cs = SYN_TestDataUtility.createShippingAndTrackingRecordForRDACase(caseObjNPI.Id,patientAccount.Id);
        SYN_InvitePharamcyStaffController.getRDACaseData(caseObjNPI.id);
        SYN_InvitePharamcyStaffController.getShipmentRelatedDataForMACIRDA(patientAccount.Id);
		SYN_InvitePharamcyStaffController.sendPrescriberInvitation(prescAccount.PersonContactId,'test@test.com',prescAccount.Id);
        Test.StopTest();
        
    }
    
}