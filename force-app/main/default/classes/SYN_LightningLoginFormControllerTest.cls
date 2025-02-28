@IsTest(SeeAllData = true)
public with sharing class SYN_LightningLoginFormControllerTest {
    @IsTest
    static void testIsloginForm(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User userObj = new User();
        userObj.Program__c ='Program1';
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
        /*Test.startTest();
insert userObj;
SYN_LightningLoginFormController.login(userObj.Email,'abcd@123','https://www.google.com',userObj.Program__c);
Test.stopTest();*/
        Test.startTest();
        insert userObj;
        
        try
        {
            SYN_LightningLoginFormController.login(userObj.Email,'abcd@123','https://www.google.com',userObj.Program__c);
        }
        catch(exception e)
        {
        }
        Test.stopTest();
    }
    @IsTest
    static void LightningLoginFormControllerInstantiation() {
        LightningLoginFormController controller = new LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }
    
    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, SYN_LightningLoginFormController.getIsUsernamePasswordEnabled());
    }
    
    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, SYN_LightningLoginFormController.getIsSelfRegistrationEnabled());
    }
    @IsTest
    static void testIsForgotPassword() {
        // System.assertEquals(true, LightningLoginFormController.getForgotPasswordUrl());
        SYN_LightningLoginFormController.getForgotPasswordUrl();
        SYN_LightningLoginFormController.setExperienceId('Expired');
    }
    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, SYN_LightningLoginFormController.getSelfRegistrationUrl());
    }
    
    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = SYN_LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
}