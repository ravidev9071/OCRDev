/**************************************************************************
    * Name :   MaciPortalCustomController_Test
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  30/11/2022             Initial Version
    *********************************************************************************/


@isTest
public class MaciPortalCustomController_Test{

    @isTest
    static void MaciPortalCustomController1_Test() {
        
        // Precriber perosn account case record type Id 
        id PrescriberPersonCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_Person_Account').getRecordTypeId();
        // Precriber Prescribing_Institution_Account case record type Id 
        id PrescribingInstitutionAccountCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution_Account').getRecordTypeId();
        
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
                // Collecting Primary Offie Info Data
                Case primaryOffObj = SYN_TestDataUtility.createPrimaryOfficeObj(programObj.id,PrescribingInstitutionAccountCaseRecordTypeId,'Macitentan REMS');
                // Collecting Secondary Offie Info Data
                Case secondaryOffObj = SYN_TestDataUtility.createSecondaryOfficeObj(programObj.id,PrescribingInstitutionAccountCaseRecordTypeId,'Macitentan REMS');
                
                // Collecting Prescriber Offie Info Data
                Case prescriberOffObj = SYN_TestDataUtility.createPrescriberInfoObj(programObj.id,PrescriberPersonCaseRecordTypeId,'Macitentan REMS');
                
                // Create Prescribing Institution, Prescriber Account, related cases, services and community user
                //String userId = MaciPortalCustomController.createPortalUserAccount(prescriberOffObj,primaryOffObj,secondaryOffObj,prf.Id,'Prescriber','Wilco@123');
            }
        Test.StopTest();
                                     
    }
    
    @isTest
    static void MaciPortalCustomController2_Test() {
    
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
        Test.StartTest();
          System.runAs (communitydefaulowner) {
          
                // Create Prescriber Account
                Account acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
                
                // Create a protal user 
                usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Prescriber');
                
                // Covering code coverage for validatePortalUser method
                boolean isPortalUserExists = MaciPortalCustomController.validatePortalUser('test@test.com',acc.US_WSREMS__NPI__c,'Prescriber',programObj.Name);
                System.Assert(isPortalUserExists = true);
              
               // Covering code coverage for validatePortalUserInfo method
                MaciPortalCustomController.validatePortalUserInfo('testmaci@test.com','9999999999','Prescriber','Macitentan REMS','Program','9999999999');
                
                // Covering code coverage for generatePortalVerificationCode method
                MaciPortalCustomController.generatePortalVerificationCode(usr.id);
                
                // Covering code coverage for reSendConfimarionEmail method
                boolean emailFlag = MaciPortalCustomController.reSendConfimarionEmail(usr.id);
                System.Assert(emailFlag = true); 
                
                // Covering code coverage for getStatesmethod method
                Map<String,String> stateMap = MaciPortalCustomController.getStates();  
                System.Assert(!stateMap.isEmpty());
                
                // Covering code coverage for getProfessionalDesignationmethod
                Map<String,String> profDegMap = MaciPortalCustomController.getProfessionalDesignation();  
                System.Assert(!profDegMap.isEmpty());  
              
                // Covering code coverage for getInpatientPharmacyTypePicklistValues
                Map<String,String> inpatientPharmacyTypeValues = MaciPortalCustomController.getInpatientPharmacyTypePicklistValues();  
                System.Assert(!inpatientPharmacyTypeValues.isEmpty()); 
                
                // Covering code coverage for ManagerAccountSharingPermission method
                MaciPortalCustomController.ManagerAccountSharingPermission(usr.id,acc.id);
                
                // Covering code coverage for ManagerProgramSharingPermission method
                MaciPortalCustomController.ManagerProgramSharingPermission(usr.id,programObj.id);

            }
            system.runAs(usr){
                // Covering code coverage for getCurrentUserType method 
                user u = MaciPortalCustomController.getCurrentUserType();
                System.Assert(u!= null);
                 
                // Covering code coverage for getCurrentUserAccountInfo method 
                Account acc = MaciPortalCustomController.getCurrentUserAccountInfo();
                System.Assert(acc != null);
                
                // Covering code coverage for getPharmacistInfo method 
                Account pharmAcc = MaciPortalCustomController.getPharmacistInfo();
                System.Assert(pharmAcc != null);
                
            }
        Test.StopTest();
                                     
    }
    
   @isTest
   static void MaciOutPatientPharmacy_Test() {
    
        // Precriber perosn account case record type Id 
        id PharmacyParticipantCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant_Account').getRecordTypeId();
       
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
          
                // Collecting Primary Offie Info Data
                Case pharmacyParticipantOff = SYN_TestDataUtility.createOutPatientPharmacyInfoObj(programObj.id,PharmacyParticipantCaseRecordTypeId ,'Macitentan REMS');
                
                // Covering code coverage for getPharmacyTitle method
                Map<String,String> titleMap = MaciPortalCustomController.getPharmacyTitle();
                System.Assert(!titleMap .isEmpty()); 
                
                // Covering code coverage for getPharmacyCredentails method
                Map<String,String> credentialsMap = MaciPortalCustomController.getPharmacyCredentails();
                System.Assert(!credentialsMap .isEmpty()); 
                
                // Create Prescribing Institution, Prescriber Account, related cases, services and community user
                String userId = MaciPortalCustomController.createPharmacyPortalUserAccount(pharmacyParticipantOff,prf.Id,'Pharmacy','Wilco@123','Opt-In');
              system.debug('<<<<userId'+userId);
            }
        Test.StopTest();
                                     
    }
    
     @isTest
     static  void validatePatientDupCheck_Test() {
    
        // Patient account record type Id 
        id PatientAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
       
         // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        // Profile Query for Inserting community user 
        Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
        Date dob = Date.newInstance(1988, 12, 9);
        
        Test.StartTest();
          System.runAs (communitydefaulowner) {
          
                // Collecting Patient Account
                account patientAcc = SYN_TestDataUtility.createPatientAccountTest(programObj.id,PatientAccRecordTypeId);
                                
                // Calling Patient Dup check method
                boolean duplicateFlag= MaciPortalCustomController.validatePatientDupCheck('Test - P','LastName-Patient','12399','Macitentan REMS',dob);
                 System.Assert(duplicateFlag == true);
            }
        Test.StopTest();                         
    }
    
     @isTest
     static void MaciInPatientPharmacy_Test() {
    
        // Precriber perosn account case record type Id 
        id PharmacyParticipantCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant_Account').getRecordTypeId();
       
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
          
                // Collecting Primary Offie Info Data
                Case pharmacyParticipantOff = SYN_TestDataUtility.createOutPatientPharmacyInfoObj(programObj.id,PharmacyParticipantCaseRecordTypeId ,'Macitentan REMS');
                
                // Covering code coverage for getPharmacyTitle method
                Map<String,String> titleMap = MaciPortalCustomController.getPharmacyTitle();
                System.Assert(!titleMap .isEmpty()); 
                
                // Covering code coverage for getPharmacyCredentails method
                Map<String,String> credentialsMap = MaciPortalCustomController.getPharmacyCredentails();
                System.Assert(!credentialsMap .isEmpty()); 
                
                // Create Prescribing Institution, Prescriber Account, related cases, services and community user
                String userId = MaciPortalCustomController.createPharmacyPortalUserAccount(pharmacyParticipantOff,prf.Id,'Pharmacy','Wilco@123','Opt-In');
            }
        Test.StopTest();
                                     
    }
    
    
      @isTest
      static void validatePharmacyNPIDupCheck_Test() {

        // Pharmacy account record type Id 
        id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
       
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
                                
                // Calling Patient Dup check method
                boolean duplicateFlag= MaciPortalCustomController.validatePharmacyNPIDupCheck('8981111111','Pharmacy','Macitentan REMS');
                 System.Assert(duplicateFlag == true);
            }
           
        Test.StopTest();                         
    }
    
    
      @isTest
      static void checkPrescriberAccount_Test() {

        // Pharmacy account record type Id 
        id prescriberAccRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_Person_Account').getRecordTypeId();
        iD prescriberInstRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution_Account').getRecordTypeId();
       
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
          
                // Collecting Prescriber Account
                case prescriberCase = SYN_TestDataUtility.createPrescriberInfoObj(programObj.id,prescriberAccRecordTypeId,'Macitentan REMS');
              
               // case primaryOfficeCase = SYN_TestDataUtility.createPrimaryOfficeObj(programObj.id,prescriberInstRecordTypeId,'Macitentan REMS');
               // case secondaryOfficeCase = SYN_TestDataUtility.createSecondaryOfficeObj(programObj.id,prescriberInstRecordTypeId,'Macitentan REMS');
                                
                // Calling check Prescriber Account method
                MaciPortalCustomController.checkPrescriberAccount(prescriberCase);
                // MaciPortalCustomController.createPrimarySecondaryAccounts(prescriberCase,primaryOfficeCase,secondaryOfficeCase);
            }
           
        Test.StopTest();                         
    }
    
       @isTest
       static void getPrescriberInfoWithOfficeInfo_Test() {

        // Pharmacy account record type Id 
        iD prescriberAccRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_Person_Account').getRecordTypeId();
        iD prescriberInstRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution_Account').getRecordTypeId();
       
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
          
                // Collecting Prescriber Account
                case prescriberCase = SYN_TestDataUtility.createPrescriberInfoObj(programObj.id,prescriberAccRecordTypeId,'Macitentan REMS'); 
                //case primaryOfficeCase = SYN_TestDataUtility.createPrimaryOfficeObj(programObj.id,prescriberInstRecordTypeId,'Macitentan REMS');
                //case secondaryOfficeCase = SYN_TestDataUtility.createSecondaryOfficeObj(programObj.id,prescriberInstRecordTypeId,'Macitentan REMS');

                //MaciPortalCustomController.getPrescriberInfoWithOfficeInfo(prescriberCase);
               //MaciPortalCustomController.insertPrescriberAccount(prescriberCase);

            }
           
        Test.StopTest();                         
    }
    
    
       @isTest
       static void createPrescriberPortalUser_Test() {

        // Pharmacy account record type Id 
        id prescriberAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
       
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
          
                // Collecting Prescriber Account
                case prescriberCase = SYN_TestDataUtility.createPrescriberInfoObj(programObj.id,prescriberAccRecordTypeId,'Macitentan REMS'); 
                // Collecting Patient Account
                account prescriberAcc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
              
           String userId=MaciPortalCustomController.createPrescriberPortalUser(prescriberAcc.id,prescriberCase,prf.Id,'Prescriber','Wilco@123','Opt-In');
		    MaciPortalCustomController.createPrimaryOfficeAccount(prescriberCase);
            MaciPortalCustomController.checkPrescriberAccountStatus(prescriberAcc.id);
            system.debug('<<<<maciuserId'+userId);
            }
           
        Test.StopTest();                         
    }
    /*
      @isTest
       static void createPrescriberPortalUser2_Test() {

        // Pharmacy account record type Id 
        id prescriberAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
           Id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution').getRecordTypeId();
       
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
          
                // Collecting Prescriber Account
                case prescriberCase = SYN_TestDataUtility.createPrimaryOfficeObj(programObj.id,recordTypeIdPrescriber,'Macitentan REMS'); 
                // Collecting Patient Account
                account prescriberAcc = SYN_TestDataUtility.createPrescribingInstitutionAccount(programObj.id,recordTypeIdPrescriber);
              
              String userId=MaciPortalCustomController.createPrescriberPortalUser(prescriberAcc.id,prescriberCase,prf.Id,'Prescriber','Wilco@123');
             system.debug('<<<<maciuserId'+userId);
            }
           
        Test.StopTest();                         
    }
    */
     @isTest
     static void getProviderNPIDetails_Test() {
        Id remsRTId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        US_WSREMS__Program_Users__c programUser = SYN_TestDataUtility.createProgramUser(UserInfo.getUserId(),programObj.id);
        US_WSREMS__REMS_Service_Summary__c remsServiceObject = SYN_TestDataUtility.createService(remsRTId, programObj.Id,'Prescriber','');  
        Account a = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.Id);
        Case cs = SYN_TestDataUtility.createCaseMACI_Veeva(caseRecordTypeId,programObj.Id,remsServiceObject.Id,a.Id);
        list<string> lstcase = new list<string>();
        lstcase.add(cs.id);
        Test.startTest();
         
        Test.setMock(HttpCalloutMock.class, new SYN_VeevaAPIAuthJSON_MockCall()); 
        
         MaciPortalCustomController.getProviderNPIDetails('2222222222');
         MaciPortalCustomController.getPharmacyNPIDetails('2222222222');

        Test.stopTest();
    }
}