/**************************************************************************
    * Name :   CustomLightningLoginFormControllerTest 
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  07/12/2022             Initial Version
    *********************************************************************************/

@isTest
public class CustomLightningLoginFormControllerTest {
    
    @isTest
    public static void createPrescriberEnrollment_MaciPortal_Test() {
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
            //usr = SYN_TestDataUtility.CreateCommunityUserWthPwd(acc,prf.id,programObj.Name,'Prescriber','wilco123');
            
        }
        
        system.runAs(usr){
            CustomLightningLoginFormController cntlr = new CustomLightningLoginFormController();
            CustomLightningLoginFormController.getIsUsernamePasswordEnabled();
            CustomLightningLoginFormController.getIsSelfRegistrationEnabled();
            CustomLightningLoginFormController.getSelfRegistrationUrl();
            CustomLightningLoginFormController.getForgotPasswordUrl();
            
            String isValidUser = CustomLightningLoginFormController.verifyUserCredentials(usr.userName,'wilco123','/s/prescriber','Macitentan REMS','');
            //system.assert(isValidUser != null);
            String validUser = CustomLightningLoginFormController.login(usr.Email,'wilco@123','/s/prescriber','Macitentan REMS');
            //system.assert(validUser != '');
            CustomLightningLoginFormController.getUserName(usr.Email,'Macitentan REMS');
            CustomLightningLoginFormController.verifyUserAccountStatus(usr.Id);
            MaciPrescriberEnrollmentFormController std = new MaciPrescriberEnrollmentFormController();
            std.getAc();
        }
           
        Test.StopTest();
    
    }
    
    
    @isTest
    public static void validatePortalVerificationCode_Test() {
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
            CustomLightningLoginFormController.login(usr.UserName,'Wilco@123','/s/prescriber','Macitentan REMS');
            acc.SYN_Signature__c='Yes';
            update acc;
           
            MaciPortalCustomController.generatePortalVerificationCode(usr.Id);
            User portluser = [SELECT Id, UserName, Verification_Code__c FROM User WHERE Id =: usr.Id LIMIT 1];
            Boolean validVCode = CustomLightningLoginFormController.validateTwoFactorAuthentication(portluser.UserName,'Macitentan REMS',portluser.Verification_Code__c);
            system.assert(validVCode = true);
            CustomLightningLoginFormController.login(portluser.UserName,'Wilco@123','/s/prescriber','Macitentan REMS');
        }
           
        Test.StopTest();
    
    }
    
    
     @isTest
    public static void validateOutPatientPharmacy_Test() {
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
            id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
            // Create Ar Account
            acc = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.id,recordTypeIdPharmacyParticipant);
            acc.SYN_User_Type__c='Authorized Representative';
            acc.AR_Category__c = 'Primary';
            update acc;
             // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Outpatient Pharmacy');
            String isValidUser = CustomLightningLoginFormController.verifyUserCredentials(usr.userName,'wilco123','/s/pharmacy','Macitentan REMS','Opt-In');
            CustomLightningLoginFormController.login(usr.UserName,'Wilco@123','/s/pharmacy','Macitentan REMS');
            acc.Is_the_Certification_Page_Complete__c = true;
            update acc;
            CustomLightningLoginFormController.login(usr.UserName,'Wilco@123','/s/pharmacy','Macitentan REMS');
        }
           
        Test.StopTest();
    
    }
    
      @isTest
    public static void validateOutPatientPharmacyStaff_Test() {
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
            id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
            // Create Ar Account
            acc = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.id,recordTypeIdPharmacyParticipant);
            acc.US_WSREMS__Status__c='Initiated';
            acc.SYN_User_Type__c='Pharmacy Staff';
            update acc;
             // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Outpatient Pharmacy');
            CustomLightningLoginFormController.login(usr.UserName,'Wilco@123','/s/pharmacy','Macitentan REMS');
            
        }
           
        Test.StopTest();
    
    }
    
    
     @isTest
    public static void validateInPatientPharmacy_Test() {
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
            id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
            // Create Ar Account
            acc = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.id,recordTypeIdPharmacyParticipant);
            acc.SYN_User_Type__c='Authorized Representative';
            acc.AR_Category__c = 'Primary';
            update acc;
             // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Inpatient Pharmacy');
            CustomLightningLoginFormController.login(usr.UserName,'Wilco@123','/s/pharmacy','Macitentan REMS');
            acc.Is_the_Certification_Page_Complete__c = true;
            update acc;
            CustomLightningLoginFormController.login(usr.UserName,'Wilco@123','/s/pharmacy','Macitentan REMS');
        }
           
        Test.StopTest();
    
    }
    
      @isTest
    public static void validateInPatientPharmacyStaff_Test() {
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
            id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
            // Create Ar Account
            acc = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.id,recordTypeIdPharmacyParticipant);
            acc.US_WSREMS__Status__c='Initiated';
            acc.SYN_User_Type__c='Pharmacy Staff';
            update acc;
             // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Inpatient Pharmacy');
            CustomLightningLoginFormController.login(usr.UserName,'Wilco@123','/s/pharmacy','Macitentan REMS');
            
        }
           
        Test.StopTest();
    
    }
    
     @isTest
    public static void validateInAndOutPatientPharmacyStaff_Test() {
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
        Account pacc;
         User pusr;
        Test.StartTest();
        System.runAs (communitydefaulowner) {
            id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
            // Create Ar Account
            acc = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.id,recordTypeIdPharmacyParticipant);
            acc.US_WSREMS__Status__c='Initiated';
            acc.SYN_User_Type__c='Pharmacy Staff';
            update acc;
             // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Inpatient Pharmacy');
              // Create Prescriber Account
            pacc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
            // Create a protal user 
            pusr = SYN_TestDataUtility.CreateCommunityUser(pacc,prf.id,programObj.Name,'Prescriber');
            Map<String,String> userMap = CustomLightningLoginFormController.getUserName(usr.Email,'Macitentan REMS');
            system.assert(userMap != null);
            Map<String,String> forgotuserMap = CustomLightningForgotPasswordController.getUserName(usr.Email,'Macitentan REMS');
            system.assert(forgotuserMap != null);
        }
           
        Test.StopTest();
    
    }
    
}