@isTest
public class AveedCustomPortalController_Test {
    
    private static final String TEST_EMAIL = 'testrems1@test.com';
    private static final String TEST_PASSWORD = 'P@ssw0rd';
    private static final String TEST_CONTACT_FIRST_NAME = 'TestFirstName';
    private static final String TEST_CONTACT_LAST_NAME = 'TestLastName';
    private static final String TEST_PROGRAM_NAME = 'AVEED REMS';
    
    @testSetup
    static void setupTestData() {
        // Create test profile
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'AVEED Portal' LIMIT 1];
        
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
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL];
        // Test case when no person account is found
        String result = AveedCustomPortalController.getActiveUserByEmail('nonexistent@example.com', testAccount.Id);
        System.assertEquals('No contact found', result);
    }
    
    @isTest
    static void testGetActiveUserByEmail_NoUserMessage() {
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL];
        // Test case when an active user is found
        String result = AveedCustomPortalController.getActiveUserByEmail(TEST_EMAIL, testAccount.Id);
        System.assertEquals('No user', result);
    }
    
    
    @isTest
    static void testCreateCommunityUser_Success() {
        // Test case for successful community user creation
        exception ex;
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL];
        Test.startTest();
        try{
            AveedCustomPortalController.createCommunityUser(TEST_EMAIL, TEST_PASSWORD, testAccount.Id);
        } catch(exception e){
            ex = e;
        }
        
        Test.stopTest();
        
    }
    
    @isTest
    static void  testGetActiveUserByEmail_ExpiredErrorMessage() {
        // Deactivate the test user to test the 'No user' message
        User testUser = [SELECT Id,Email FROM User WHERE IsActive = true AND Program__c =: Label.AVEED_REMS_Program_Name LIMIT 1];
        testUser.email = TEST_EMAIL;
        update testUser;
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL];
        // Test case when no active user is found
        String result = AveedCustomPortalController.getActiveUserByEmail(TEST_EMAIL, testAccount.Id);
        
    }
    @isTest
    static void testManagerAccountSharingPermission() {
        // Test case for managing account sharing permission
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'AVEED Portal' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL LIMIT 1];
        User testUser = [SELECT Id,Email FROM User WHERE IsActive = true AND profileId =:portalProfile.Id LIMIT 1];
        Test.startTest();
        AveedCustomPortalController.ManagerAccountSharingPermission(testUser.Id, testAccount.Id);
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
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'AVEED Portal' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL LIMIT 1];
        exception ex;
        User testUser;
        Test.startTest();
        try{
            testUser = [SELECT Id,Email FROM User WHERE profileId =:portalProfile.Id LIMIT 1];
            AveedCustomPortalController.ManagerAccountSharingPermission(testUser.Id, testAccount.Id);
        } catch(exception e){
            ex = e;
        } 
        Test.stopTest();
        
    }
    
    @isTest
    static void testManagerProgramSharingPermissionException() {
        // Test case for managing program sharing permission
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'AVEED Portal' LIMIT 1];
        
        US_WSREMS__REMS_Program__c testProgram = [SELECT Id FROM US_WSREMS__REMS_Program__c WHERE Name = :TEST_PROGRAM_NAME LIMIT 1];
        User testUser = [SELECT Id,Email FROM User WHERE profileId =:portalProfile.Id AND IsActive = TRUE LIMIT 1];
        exception ex;
        
        AveedCustomPortalController.ManagerProgramSharingPermission(testUser.Id,testProgram.Id);
        Test.startTest();
        try{
            AveedCustomPortalController.ManagerProgramSharingPermission(testUser.Id,testProgram.Id);
        } catch(exception e){
            ex = e;
        }
        Test.stopTest();
        
    } 
    
    
    @isTest
    static void testManagerProgramSharingPermission() {
        // Test case for managing program sharing permission
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'AVEED Portal' LIMIT 1];
        
        US_WSREMS__REMS_Program__c testProgram = [SELECT Id FROM US_WSREMS__REMS_Program__c WHERE Name = :TEST_PROGRAM_NAME LIMIT 1];
        User testUser = [SELECT Id,Email FROM User WHERE IsActive = true AND profileId =:portalProfile.Id LIMIT 1];
        Test.startTest();
        AveedCustomPortalController.ManagerProgramSharingPermission(testUser.Id, testProgram.Id);
        Test.stopTest();
        
        US_WSREMS__REMS_Program__Share share = [SELECT Id,AccessLevel FROM US_WSREMS__REMS_Program__Share WHERE ParentId = :testProgram.Id AND UserOrGroupId = :testUser.Id LIMIT 1];
        System.assertNotEquals(null, share);
        System.assertEquals('Read', share.AccessLevel);
    }

    @isTest
    private static void testManagePermissionSet() {
        String permissionSetName = 'AVEED_PortalPermissionSet';
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'AVEED Portal' LIMIT 1];
		US_WSREMS__REMS_Program__c testProgram = [SELECT Id,Name FROM US_WSREMS__REMS_Program__c WHERE Name = :TEST_PROGRAM_NAME LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

       // User testUser = SYN_TestDataUtility.CreateCommunityUser(testAccount,portalProfile.id,testProgram.Name,'Prescriber');
        User testUser = [SELECT Id,Email FROM User WHERE IsActive = true AND profileId =:portalProfile.Id LIMIT 1];

        string permSetId = [SELECT Id FROM PermissionSet WHERE Name = 'AVEED_PortalPermissionSet' LIMIT 1].Id;
        If (permSetId != null){
            delete [SELECT Id from PermissionSetAssignment WHERE PermissionSetId = : permSetId AND AssigneeId = : testUser.Id];
        }
        Test.startTest();
            AveedCustomPortalController.assignPermissionSetToUser(testUser.Id, permissionSetName);
        Test.stopTest();

        // Verify that the permission set was assigned to the user
        PermissionSet testPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
        PermissionSetAssignment psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id AND PermissionSetId = :testPermissionSet.Id LIMIT 1];
        System.assertNotEquals(null, psa, 'The permission set should be assigned to the user.');
    }
}