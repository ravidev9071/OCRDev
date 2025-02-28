@isTest
public class XiaflexCustomPortalController_test {
 private static final String TEST_EMAIL = 'testrems1@test.com';
    private static final String TEST_PASSWORD = 'P@ssw0rd';
    private static final String TEST_CONTACT_FIRST_NAME = 'TestFirstName';
    private static final String TEST_CONTACT_LAST_NAME = 'TestLastName';
    private static final String TEST_PROGRAM_NAME = 'Xiaflex';

    @testSetup
    static void setupTestData() {
        // Create test profile
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Xiaflex Portal' LIMIT 1];

        // Create test program
        US_WSREMS__REMS_Program__c testProgram = SYN_TestDataUtility.createProgram(TEST_PROGRAM_NAME,'Active');

        // Create test account
        Account testAccount = SYN_TestDataUtility.createPrescriberPersonAccount(testProgram.id);
        testAccount.PersonEmail = TEST_EMAIL;
        testAccount.US_WSREMS__Program_Type__c = 'REMS';
        update testAccount;
        // Create active test user
        User testUser = SYN_TestDataUtility.CreateCommunityUser(testAccount,portalProfile.id,testProgram.Name,'Prescriber');

    }

    @isTest
    static void testGetActiveUserByEmail_NoPersonAccount() {
        // Test case when no person account is found
        String result = xiaflexCustomPortalController.getActiveUserByEmail('nonexistent@example.com','AR');
        System.assertEquals('No contact found', result);
    }

    @isTest
    static void testGetActiveUserByEmail_NoUserMessage() {
        // Test case when an active user is found
        String result = xiaflexCustomPortalController.getActiveUserByEmail(TEST_EMAIL,'AR');
        System.assertEquals('No user', result);
    }

    @isTest
    static void testCreateCommunityUser_Success() {
        string persona = 'PR';
        // Test case for successful community user creation
        exception ex;
        Test.startTest();
        
           xiaflexCustomPortalController.createCommunityUser(TEST_EMAIL, TEST_PASSWORD, persona,'REMS','Xiaflex Portal');
        
        Test.stopTest();
    }

    @isTest
    static void  testGetActiveUserByEmail_ExpiredErrorMessage() {
        // Deactivate the test user to test the 'No user' message
        User testUser = [SELECT Id,Email FROM User WHERE IsActive = true AND Program__c =: 'xiaflex' LIMIT 1];
        testUser.email = TEST_EMAIL;
        update testUser;
        // Test case when no active user is found
        String result = xiaflexCustomPortalController.getActiveUserByEmail(TEST_EMAIL,'PR');

    }
    @isTest
    static void testManagerAccountSharingPermission() {
        // Test case for managing account sharing permission
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'xiaflex Portal' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL LIMIT 1];
        User testUser = [SELECT Id,Email FROM User WHERE IsActive = true AND profileId =:portalProfile.Id LIMIT 1];
        Test.startTest();
        xiaflexCustomPortalController.ManagerAccountSharingPermission(testUser.Id, testAccount.Id);
        Test.stopTest();

        AccountShare share = [SELECT Id,AccountAccessLevel,OpportunityAccessLevel,CaseAccessLevel FROM AccountShare WHERE AccountId = :testAccount.Id AND UserOrGroupId = :testUser.Id LIMIT 1];
        System.assertNotEquals(null, share);
        System.assertEquals('Edit', share.AccountAccessLevel);
        System.assertEquals('Read', share.OpportunityAccessLevel);
        System.assertEquals('Edit', share.CaseAccessLevel);
    }

    @isTest
    static void testManagerAccountSharingPermissionException() {
        // Test case for managing account sharing permission
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'xiaflex Portal' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL LIMIT 1];
        exception ex;
        User testUser;
        Test.startTest();
        try{
            testUser = [SELECT Id,Email FROM User WHERE IsActive = false AND profileId =:portalProfile.Id LIMIT 1];
            xiaflexCustomPortalController.ManagerAccountSharingPermission(testUser.Id, testAccount.Id);
        } catch(exception e){
            ex = e;
        }
        Test.stopTest();
		system.assert(ex != null);
    }
    @isTest
    static void testManagerProgramSharingPermission() {
        
        US_WSREMS__REMS_Program__c testPro=[Select Id, Name, US_WSREMS__Status__c From US_WSREMS__REMS_Program__c  Where US_WSREMS__Status__c = 'Active' LIMIT 1];
        
         User testUser = [SELECT Id,Email FROM User WHERE IsActive = true AND Program__c =: 'xiaflex' LIMIT 1];
        Test.startTest();

            Id progId=testPro.Id;
          String userName=testUser.Id;
            xiaflexCustomPortalController.ManagerProgramSharingPermission(userName, progId);
        xiaflexCustomPortalController.assignPermissionSetToUser(userName,'REMS');
               Test.stopTest();
        
    }
    

   
}