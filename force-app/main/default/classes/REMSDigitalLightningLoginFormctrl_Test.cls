@IsTest
public with sharing class REMSDigitalLightningLoginFormctrl_Test {
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
        REMSDigitalSiteLightningLoginFormctrl.login(userObj.Email,'abcd@123','https://www.google.com',userObj.US_WSREMS__REMS_Program__c);
        }
 @IsTest
 static void REMSDigitalSiteLightningLoginFormctrlInstantiation() {
  REMSDigitalSiteLightningLoginFormctrl controller = new REMSDigitalSiteLightningLoginFormctrl();
  System.assertNotEquals(controller, null);
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, REMSDigitalSiteLightningLoginFormctrl.getIsUsernamePasswordEnabled());
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, REMSDigitalSiteLightningLoginFormctrl.getIsSelfRegistrationEnabled());
 }
@IsTest
 static void testIsForgotPassword() {
 // System.assertEquals(true, REMSDigitalSiteLightningLoginFormctrl.getForgotPasswordUrl());
     REMSDigitalSiteLightningLoginFormctrl.getForgotPasswordUrl();
     REMSDigitalSiteLightningLoginFormctrl.setExperienceId('Expired');
 }
 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, REMSDigitalSiteLightningLoginFormctrl.getSelfRegistrationUrl());
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = REMSDigitalSiteLightningLoginFormctrl.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
}