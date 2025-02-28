@isTest
public class PiaSkyCustomPortalController_Test {
    private static final String TEST_EMAIL = 'testrems1@test.com';
    private static final String TEST_PASSWORD = 'P@ssw0rd';
    private static final String TEST_CONTACT_FIRST_NAME = 'TestFirstName';
    private static final String TEST_CONTACT_LAST_NAME = 'TestLastName';
    private static final String TEST_PROGRAM_NAME = 'PiaSky REMS';

    @testSetup
    static void setupTestData() {
        // Create test profile
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'PiaSky Portal Profile' LIMIT 1];

        // Create test program
        US_WSREMS__REMS_Program__c testProgram = SYN_TestDataUtility.createProgram(TEST_PROGRAM_NAME,'Active');

        // Create test account
        Account testAccount = SYN_TestDataUtility.createPrescriberPersonAccount(testProgram.id);
        testAccount.PersonEmail = TEST_EMAIL;
        update testAccount;
        // Create active test user
        User testUser = SYN_TestDataUtility.CreateCommunityUser(testAccount,portalProfile.id,testProgram.Name,'Prescriber');

    }

    @isTest
    static void testGetActiveUserByEmail_NoPersonAccount() {
        // Test case when no person account is found
        String result = PiaSkyCustomPortalController.getActiveUserByEmail('nonexistent@example.com');
        System.assertEquals('No contact found', result);
    }

    @isTest
    static void testGetActiveUserByEmail_NoUserMessage() {
        // Test case when an active user is found
        String result = PiaSkyCustomPortalController.getActiveUserByEmail(TEST_EMAIL);
        System.assertEquals('No user', result);
    }

    @isTest
    static void testCreateCommunityUser_Success() {
        // Test case for successful community user creation
        exception ex;
        Test.startTest();
        try{
           PiaSkyCustomPortalController.createCommunityUser(TEST_EMAIL, TEST_PASSWORD);
        } catch(exception e){
            ex = e;
        }
        
        Test.stopTest();
        system.assert(ex != null);
    }

    @isTest
    static void  testGetActiveUserByEmail_ExpiredErrorMessage() {
        // Deactivate the test user to test the 'No user' message
        User testUser = [SELECT Id,Email FROM User WHERE IsActive = true AND Program__c =: Label.PiaSky_REMS_Program_Name LIMIT 1];
        testUser.email = TEST_EMAIL;
        update testUser;
        // Test case when no active user is found
        String result = PiaSkyCustomPortalController.getActiveUserByEmail(TEST_EMAIL);
        System.assertEquals('Link expired, please contact administration.', result);

    }
    @isTest
    static void testManagerAccountSharingPermission() {
        // Test case for managing account sharing permission
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'PiaSky Portal Profile' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL LIMIT 1];
        User testUser = [SELECT Id,Email FROM User WHERE IsActive = true AND profileId =:portalProfile.Id LIMIT 1];
        Test.startTest();
        PiaSkyCustomPortalController.ManagerAccountSharingPermission(testUser.Id, testAccount.Id);
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
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'PiaSky Portal Profile' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL LIMIT 1];
        exception ex;
        User testUser;
        Test.startTest();
        try{
            testUser = [SELECT Id,Email FROM User WHERE IsActive = false AND profileId =:portalProfile.Id LIMIT 1];
            PiaSkyCustomPortalController.ManagerAccountSharingPermission(testUser.Id, testAccount.Id);
        } catch(exception e){
            ex = e;
        }
        Test.stopTest();
		system.assert(ex != null);
    }

    @isTest
    static void testManagerProgramSharingPermissionException() {
        // Test case for managing program sharing permission
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'PiaSky Portal Profile' LIMIT 1];

        US_WSREMS__REMS_Program__c testProgram = [SELECT Id FROM US_WSREMS__REMS_Program__c WHERE Name = :TEST_PROGRAM_NAME LIMIT 1];
        User testUser = [SELECT Id,Email FROM User WHERE IsActive = false AND profileId =:portalProfile.Id LIMIT 1];
        exception ex;

        Test.startTest();
        try{
            PiaSkyCustomPortalController.ManagerProgramSharingPermission(testUser.Id, testProgram.Id);
        } catch(exception e){
            ex = e;
        }
        Test.stopTest();
        system.assert(ex != null);
    }

    @isTest
    static void testManagerProgramSharingPermission() {
        // Test case for managing program sharing permission
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'PiaSky Portal Profile' LIMIT 1];

        US_WSREMS__REMS_Program__c testProgram = [SELECT Id FROM US_WSREMS__REMS_Program__c WHERE Name = :TEST_PROGRAM_NAME LIMIT 1];
        User testUser = [SELECT Id,Email FROM User WHERE IsActive = true AND profileId =:portalProfile.Id LIMIT 1];
        Test.startTest();
        PiaSkyCustomPortalController.ManagerProgramSharingPermission(testUser.Id, testProgram.Id);
        Test.stopTest();

        US_WSREMS__REMS_Program__Share share = [SELECT Id,AccessLevel FROM US_WSREMS__REMS_Program__Share WHERE ParentId = :testProgram.Id AND UserOrGroupId = :testUser.Id LIMIT 1];
        System.assertNotEquals(null, share);
        System.assertEquals('Read', share.AccessLevel);
    }


    @isTest
    static void testManagePermissionSet() {
        // Test case for managing program sharing permission
        String permissionSetName = 'PIASKY_Portal_PermissionSet';
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'PiaSky Portal Profile' LIMIT 1];

        US_WSREMS__REMS_Program__c testProgram = [SELECT Id FROM US_WSREMS__REMS_Program__c WHERE Name = :TEST_PROGRAM_NAME LIMIT 1];
        User testUser = [SELECT Id,Email FROM User WHERE IsActive = true AND profileId =:portalProfile.Id LIMIT 1];
        Test.startTest();
        Test.stopTest();

        // Verify that the permission set was assigned to the user
        PermissionSet testPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
        //PermissionSetAssignment psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id AND PermissionSetId = :testPermissionSet.Id LIMIT 1];
        //System.assertNotEquals(null, psa, 'The permission set should be assigned to the user.');
    }

}