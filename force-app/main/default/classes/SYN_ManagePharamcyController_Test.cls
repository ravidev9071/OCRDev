/**************************************************************************
* Name :   SYN_ManagePharamcyController_Test

Modification Log:
----------------------------------------------------------------------------------
Developer               Date                   Description
-----------------------------------------------------------------------------------
Thandavakrishna Dindu  30/11/2022             Initial Version
*********************************************************************************/


@isTest
public class SYN_ManagePharamcyController_Test{
    
    @isTest
    public static void ManagePharamcyController_Test() {
        
        Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
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
            SYN_ManagePharamcyController.getPharmacistInfo();
            
            // Covering code coverage for get Prescriber List method
            SYN_ManagePharamcyController.getPrescriberList(programObj.id);
            
            // Covering code coverage for remove Pharmacy Staff method
            SYN_ManagePharamcyController.removePharmacyStaff(acc.id,pharmCAccount,programObj.id,'Inpatient');
        }
        
        Test.StopTest();
        
    }
    
    
    
    @isTest
    public static void getPharmacyInfo_Test() {
        
        // Pharmacy account record type Id 
        Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        Id pharmCINPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
        Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();

        
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

            account pharmAcc= SYN_ManagePharamcyController.getPharmacyInfo(pharmacyAcc,programObj.id);
            //System.Assert(pharmAcc != null);
        }
        Test.StopTest();                         
    }
    
    @isTest
    public static void getAuthorizedReps_Test() {
        
        // Pharmacy account record type Id 
        Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
        
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
            
            // Collecting Pharmacy Account
            account pharmacyAcc = SYN_TestDataUtility.createPharmacyAccountTest(programObj.id,PharmacyAccRecordTypeId);
            account pharmacyParticipantAcc = SYN_TestDataUtility.createPharmacyParticipantAccountAuthrepTest(programObj.Id,RecordTypeIdPhPa,pharmacyAcc.Id);
            US_WSREMS__Affiliation__c affiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmacyParticipantAcc.Id,pharmacyAcc.Id);
            
            // Create a protal user 
            User usr = SYN_TestDataUtility.CreateCommunityUser(pharmacyParticipantAcc,prf.id,programObj.Name,'Inpatient Pharmacy');
             
           List<US_WSREMS__Affiliation__c> affRepList= SYN_ManagePharamcyController.getAuthorizedReps(pharmacyAcc,programObj.id,pharmacyParticipantAcc);
           System.Assert(!affRepList.isEmpty());
           SYN_ManagePharamcyController.sendInviteNotification(affiliation.id);
           Account pharmacyPaticipantAcc = MaciPortalCustomController.getCurrentAuthRepInfo(pharmacyParticipantAcc.id);
           System.Assert(pharmacyPaticipantAcc != null);
           MaciPortalCustomController.updatePharmacyParticipantStatus(pharmacyParticipantAcc.id);
        }
        Test.StopTest();                         
    }
    
    @isTest
    public static void createPharmacyPatientTestRecord_Test() {
        // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        id recordTypeIdPharmacy = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        // Profile Query for Inserting community user 
        Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
        User usr;
        Account pharmacyAccount;
        Account patientAccount;
        Account PharmacyParticipantAccount;
        Account prescriberAccount;
        Case patientEnrol;
        Date dob = Date.newInstance(1988, 12, 9);
        Test.StartTest();
        System.runAs (communitydefaulowner) {
            
            // Create Prescriber and patient Account
            
            pharmacyAccount= SYN_TestDataUtility.createPharmacyAccountTest(programObj.id,recordTypeIdPharmacy);
            patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
            PharmacyParticipantAccount=SYN_TestDataUtility.createPharmacyParticipantAccountAuthrepTest(programObj.Id,recordTypeIdPharmacyParticipant,pharmacyAccount.Id);
            prescriberAccount = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
            patientEnrol= SYN_TestDataUtility.createNewPatientEnrollmentCase(programObj.Id,programObj.Name,prescriberAccount,patientAccount);
            // Covering code coverage for pharmacyEnterPatientInformation method
            SYN_ManagePharamcyController.pharmacyEnterPatientInformation('Test - P','LastName-Patient',dob,'Macitentan REMS');
            //  Covering code coverage for createPharmacyPatientTestRecord method
            String remsId =SYN_ManagePharamcyController.createPharmacyPatientTestRecord(programObj.id,patientAccount.id,pharmacyAccount,programObj.Name,'Portal',PharmacyParticipantAccount.Id,prescriberAccount.Id);
            System.Assert(remsId != null);
            //  Covering code coverage for getPrescriberDetails method
            SYN_ManagePharamcyController.getPrescriberDetails(patientAccount.id,programObj.Name);
            //  Covering code coverage for getPrescriberAccount method
            SYN_ManagePharamcyController.getPrescriberAccount(prescriberAccount.Id,programObj.Name);
            //  Covering code coverage for validatePrescriberData method
            SYN_ManagePharamcyController.validatePrescriberData('8989800000',programObj.id);
            //  Covering code coverage for validatePatientData method
            SYN_ManagePharamcyController.validatePatientData('Test - P','','LastName-Patient',dob,programObj.id);
        }
        Test.StopTest(); 
    }
    @isTest
    public static void getPharmacyAffilicationInfo_Test() {
        
        // Pharmacy account record type Id 
        Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        Id pharmCINPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
        Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
        
        
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
            affiliation.Status__c = 'Active';
            update affiliation;
            
            Map<Id,String> affilationMap = SYN_ManagePharamcyController.getPharmacyUsers(pharmacyAcc,programObj.Id);
            

        }
        Test.StopTest();                         
    }
    
    
     @isTest
    public static void createPharmacyPatientCounselingRecord_Test() {
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
        System.runAs (communitydefaulowner) {
            // Pharmacy account record type Id 
            Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
            Id pharmCINPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
            Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
             id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
             // Collecting pharmacy Account
            account pharmacyAcc = SYN_TestDataUtility.createTestPharmacyAccount(programObj.id,PharmacyAccRecordTypeId);
            
            account spharmacAcc = SYN_TestDataUtility.createPharmacyAccount(programObj.id,PharmacyAccRecordTypeId);
            case pharmacyCase = SYN_TestDataUtility.createCasePharmacyTest(pharmCINPatCaseRecTypeId,programObj.Id,pharmacyAcc.Id);
            account pharmacyParticipantAcc = SYN_TestDataUtility.createPharmacyParticipantAccountAuthrepTest(programObj.Id,RecordTypeIdPhPa,pharmacyAcc.Id);
            Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
            // Create Prescriber Account
            Account prescriberacc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
            SYN_ManagePharamcyController.createPharmacyPatientCounselingRecord(pharmacyParticipantAcc,pharmacyAcc,prescriberacc,createPatientAccount,'Portal');
        }
           
        Test.StopTest();
    
    }
    
    @isTest
    public static void deactivatePharmacyUser_Test() {
                Set<Id> activeUserIds = new Set<Id>();

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
        System.runAs (communitydefaulowner) {
        
            // Create Prescriber Account
            acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
             // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Prescriber');
            activeUserIds.add(acc.Id); 
           SYN_ManagePharamcyController.deactivatePortalUser(activeUserIds);
        }
           
        Test.StopTest();
    
    }
    
    @isTest
    public static void removePharmacyStaff_Test() {
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
        System.runAs (communitydefaulowner) {
            // Pharmacy account record type Id 
            Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
            Id pharmCINPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
            Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
             // Collecting Patient Account
            account pharmacyAcc = SYN_TestDataUtility.createPharmacyAccountTest(programObj.id,PharmacyAccRecordTypeId);
            case pharmacyCase = SYN_TestDataUtility.createCasePharmacyTest(pharmCINPatCaseRecTypeId,programObj.Id,pharmacyAcc.Id);
            account pharmacyParticipantAcc = SYN_TestDataUtility.createPharmacyParticipantAccountAuthrepTest(programObj.Id,RecordTypeIdPhPa,pharmacyAcc.Id);
            US_WSREMS__Affiliation__c affiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmacyParticipantAcc.Id,pharmacyAcc.Id);
            affiliation.Status__c = 'Active';
            update affiliation;
             // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(pharmacyParticipantAcc ,prf.id,programObj.Name,'Inpatient Pharmacy');
            SYN_ManagePharamcyController.getPharmacyInfo(pharmacyParticipantAcc,'Macitentan REMS');
            SYN_ManagePharamcyController.removePharmacyStaff(affiliation.Id,pharmacyAcc,programObj.Id,'Inpatient');
           
            
        }
           
        Test.StopTest();
    
    }
    
    @IsTest() 
    static void getRelatedFilesByRecordTest() {
        
        Map<ID,ContentDistribution> mapContentDistribution=new Map<ID, ContentDistribution>();
        
        US_WSREMS__REMS_Program__c programObj =new US_WSREMS__REMS_Program__c();
        programObj.Name='Test0001';
        insert programObj;   
        
        Id idRTforParticipantFile =Schema.SObjectType.REMS_Participant_Files__c.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        
        REMS_Participant_Files__c remsParticipantFileobj = new REMS_Participant_Files__c();
        remsParticipantFileobj.Name ='Test Participant';  
        remsParticipantFileobj.RecordTypeId=idRTforParticipantFile;
        remsParticipantFileobj.Portal_Role__c='Prescriber';
        remsParticipantFileobj.REMS_Program__c=programObj.id;
        insert remsParticipantFileobj;
        
        ContentVersion contentVersionObj=new Contentversion();
        contentVersionObj.title='ABC';
        contentVersionObj.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        contentVersionObj.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert contentVersionObj;
        
        ContentDocumentLink contentlinkObj=new ContentDocumentLink();
        contentlinkObj.LinkedEntityId=remsParticipantFileobj.id;
        contentlinkObj.contentdocumentid=[select contentdocumentid from contentversion where id =: contentVersionObj.id].contentdocumentid;
        contentlinkObj.ShareType = 'I';
        contentlinkObj.Visibility = 'AllUsers';         
        insert contentlinkObj;
        
        ContentDocumentLink contentDocumentList = [select contentdocument.id, contentdocument.title, contentdocument.filetype from contentdocumentlink 
                                                  where linkedentityid =:remsParticipantFileobj.id];
        ContentVersion cver = [select id from contentversion where contentdocumentid = :contentDocumentList.contentdocument.id];
        ContentDistribution contentDocumentObj = new ContentDistribution();
        contentDocumentObj.Name = 'Test';
        contentDocumentObj.ContentVersionId = cver.id;
        contentDocumentObj.PreferencesAllowViewInBrowser= true;
        contentDocumentObj.PreferencesLinkLatestVersion=true;
        contentDocumentObj.PreferencesNotifyOnVisit=false;
        contentDocumentObj.PreferencesPasswordRequired=false;
        contentDocumentObj.PreferencesAllowOriginalDownload= true;
        insert contentDocumentObj;
        
        List<REMS_Participant_Files__c> participantList = [SELECT Id,RecordType.DeveloperName,Portal_Role__c,REMS_Program__c FROM REMS_Participant_Files__c
                                                           WHERE RecordType.DeveloperName = 'Prescriber' LIMIT 1];
        
        
        Test.startTest();
        mapContentDistribution= SYN_ManagePharamcyController.getRelatedFilesByRecordId(participantList[0].RecordType.DeveloperName,
                                                                                     remsParticipantFileobj.REMS_Program__c, remsParticipantFileobj.Portal_Role__c);
        
        System.assert(!mapContentDistribution.isEmpty(), 'There must be at least one record!');
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void removePharmacyStaff1_Test() {
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
        System.runAs (communitydefaulowner) {
            // Pharmacy account record type Id 
            Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
            Id pharmCINPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
            Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
             // Collecting pharmacy Account
            account pharmacyAcc = SYN_TestDataUtility.createTestPharmacyAccount(programObj.id,PharmacyAccRecordTypeId);
            
            account spharmacAcc = SYN_TestDataUtility.createPharmacyAccount(programObj.id,PharmacyAccRecordTypeId);
            case pharmacyCase = SYN_TestDataUtility.createCasePharmacyTest(pharmCINPatCaseRecTypeId,programObj.Id,pharmacyAcc.Id);
            account pharmacyParticipantAcc = SYN_TestDataUtility.createPharmacyParticipantAccountAuthrepTest(programObj.Id,RecordTypeIdPhPa,pharmacyAcc.Id);
            US_WSREMS__Affiliation__c affiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmacyParticipantAcc.Id,pharmacyAcc.Id);
            US_WSREMS__Affiliation__c saffiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmacyParticipantAcc.Id,spharmacAcc.Id);

             // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(pharmacyParticipantAcc ,prf.id,programObj.Name,'Inpatient Pharmacy');
            SYN_ManagePharamcyController.removePharmacyStaff(affiliation.Id,pharmacyAcc,programObj.id,'Inpatient');
        }
           
        Test.StopTest();
    
    }
    
    
    
}