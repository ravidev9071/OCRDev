@IsTest
public with sharing class REMSDigitalLightningLoginFormTest {
    
     @TestSetup
    static void setupData() {
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c ();
        programObj.Name = 'Aveed REMS';
        programObj.US_WSREMS__Status__c = 'Active';
        programObj.REMS_Project_Code__c = 'BT1005';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        Account accountObj = SYN_TestDataFactory.createPersonAccountforPrescriber('0909876545', 12345678, '1234567896', true, programObj.Id);
        Account hcsAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId());
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<UserRole> roles = [SELECT Id FROM UserRole WHERE Name = 'CEO'];
            if (roles != null && !roles.isEmpty()) {
                User currentUser = new User(Id = UserInfo.getUserId());
                currentUser.UserRoleId = roles.get(0).Id;
                update currentUser;
            }
            List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE Id = :accountObj.Id];
            List<Profile> aveedPortalProfile = [SELECT Id, Name FROM Profile WHERE Name = 'AVEED Portal'];
            List<PermissionSet> portalPermissionSet = [SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'AVEED_PortalPermissionSet'];
            String orgId = UserInfo.getOrganizationId();  
            String dateString =   
                String.valueof(
                    Datetime.now()
                ).replace(
                    ' ',''
                ).replace(
                    ':',''
                ).replace(
                    '-',''
                );  
            Integer randomInt = Integer.valueOf(
                math.rint(
                    math.random()*1000000
                )
            );  
            String uniqueName = orgId + dateString + randomInt;  
            User portalUser = new User(  
                FirstName = accounts.get(0).FirstName,
                LastName = accounts.get(0).LastName,
                email = 'program@gmail.com',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = aveedPortalProfile.get(0).Id,
                ContactId = accounts.get(0).PersonContactId
            );  
            insert portalUser;
            
            PermissionSetAssignment permissionAssignment = new PermissionSetAssignment(PermissionSetId = portalPermissionSet.get(0).Id, AssigneeId = portalUser.Id);
            insert permissionAssignment;
        }
    }
    
@IsTest
    static void testIsloginForm(){
      
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
		User userObj = new User();
        userObj.US_WSREMS__REMS_Program__c ='Program1';
        userObj.UserRoleId = portalRole.Id;
        userObj.ProfileId = profile1.Id;
        userObj.Username = System.now().millisecond() + 'demo@test.com';
        userObj.Alias = 'demo';
        userObj.Email='program@gmail.com';
        userObj.EmailEncodingKey='UTF-8';
        userObj.Firstname='demo';
        userObj.Lastname='sample';
        userObj.LanguageLocaleKey='en_US';
        userObj.LocaleSidKey='en_US';
        userObj.TimeZoneSidKey='America/Chicago';
        insert userObj;
        REMSDigitalSiteLightningLoginForm.login(userObj.Email,'abcd@123','https://www.google.com',userObj.US_WSREMS__REMS_Program__c);
        REMSDigitalSiteLightningLoginForm.loginUser(userObj.Email,'abcd@123','https://www.google.com',userObj.US_WSREMS__REMS_Program__c);
        REMSDigitalSiteLightningLoginForm.login('abcd@gamil.com','abcd@123','https://www.google.com',userObj.US_WSREMS__REMS_Program__c);
        }
    
    @IsTest
    static void testIsloginFormAveedPR(){       
        User userObj = [Select id, name,email,US_WSREMS__REMS_Program__c from User where email = 'program@gmail.com'];
        REMSDigitalSiteLightningLoginForm.loginAveed(userObj.Email,'abcd@123','https://www.google.com',userObj.US_WSREMS__REMS_Program__c,'PR');
    }
    
     @IsTest
    static void testIsloginFormAveedNotAR(){       
        User userObj = [Select id, name,email,US_WSREMS__REMS_Program__c from User where email = 'program@gmail.com'];
        REMSDigitalSiteLightningLoginForm.loginAveed(userObj.Email,'abcd@123','https://www.google.com',userObj.US_WSREMS__REMS_Program__c,'AR');
    }
    
     @IsTest
    static void testIsloginFormAveedElseIf(){       
        User userObj = [Select id, name,email,US_WSREMS__REMS_Program__c from User where email = 'program@gmail.com'];
        REMSDigitalSiteLightningLoginForm.loginAveed('','abcd@123','https://www.google.com','Program1','PR'); 
    }
     @IsTest
    static void testIsloginFormAveedNotPR(){       
        User userObj = [Select id, name,email,US_WSREMS__REMS_Program__c from User where email = 'program@gmail.com'];
        REMSDigitalSiteLightningLoginForm.loginAveed('abcd@gmail.com','abcd@123','https://www.google.com',userObj.US_WSREMS__REMS_Program__c,'AR');
        REMSDigitalSiteLightningLoginForm.loginUser('abcd@gmail.com','abcd@123','https://www.google.com', userObj.US_WSREMS__REMS_Program__c);
    }
    
 @IsTest
 static void REMSDigitalSiteLightningLoginFormctrlInstantiation() {
  REMSDigitalSiteLightningLoginForm controller = new REMSDigitalSiteLightningLoginForm();
  System.assertNotEquals(controller, null);
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, REMSDigitalSiteLightningLoginForm.getIsUsernamePasswordEnabled());
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, REMSDigitalSiteLightningLoginForm.getIsSelfRegistrationEnabled());
 }
@IsTest
 static void testIsForgotPassword() {
 // System.assertEquals(true, REMSDigitalSiteLightningLoginFormctrl.getForgotPasswordUrl());
     REMSDigitalSiteLightningLoginForm.getForgotPasswordUrl();
     REMSDigitalSiteLightningLoginForm.setExperienceId('Expired');
 }
 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, REMSDigitalSiteLightningLoginForm.getSelfRegistrationUrl());
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = REMSDigitalSiteLightningLoginForm.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
}