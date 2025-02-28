@isTest
public class RemsOneTimePortalPasswordSetupControTest {

    private static final String TEST_EMAIL = 'testrems1@test.com';
    private static final String TEST_PASSWORD = 'P@ssw0rd';
    private static final String TEST_CONTACT_FIRST_NAME = 'TestFirstName';
    private static final String TEST_CONTACT_LAST_NAME = 'TestLastName';
    private static final String TEST_PROGRAM_NAME = 'AVEED REMS';
    private static String userTestId;

    @testSetup
    static void setupTestData() {
        // Create test profile
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'AVEED Portal' LIMIT 1];

        // Create test program
        US_WSREMS__REMS_Program__c testProgram = SYN_TestDataUtility.createProgram(TEST_PROGRAM_NAME,'Active');

        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.FirstName= 'TestUser';
        accountObj.LastName = 'Program';
        accountObj.RecordTypeId = recordTypeId;
        accountObj.US_WSREMS__Channel__c  = 'fax';
        accountObj.US_WSREMS__Program_Picklist__c = 'Aveed REMS';
        accountObj.US_WSREMS__SLN_State__c  ='AK';
        accountObj.Phone = '9999999999';
        accountObj.US_WSREMS__NPI__c  = '9999999999';
        accountObj.US_WSREMS__Phone_Type__c  = 'mobile';
        accountObj.US_WSREMS__EXT__c  = '123';
        accountObj.Fax = '9999999999';
        accountObj.US_WSREMS__Email__c  = TEST_EMAIL;
        accountObj.US_WSREMS__Preferred_Contact_Method__c  = 'email';
        accountObj.US_WSREMS__REMS_Program__c = testProgram.Id;
        accountObj.PersonEmail = TEST_EMAIL;
        insert accountObj;

        System.assertEquals( accountObj.Id != NULL, true);
        // Create active test user
        User testUser = SYN_TestDataUtility.CreateCommunityUser(accountObj,portalProfile.id,testProgram.Name,'Prescriber');
    }

    @isTest
    static void testGetActiveUserByEmail_NoPersonAccount() {
        // Test case when no person account is found
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL LIMIT 1];
        String result = RemsOneTimePortalPasswordSetupController.getActiveUserByEmail('nonexistest@example.com',TEST_PROGRAM_NAME, testAccount.Id ,'Link Expired.');
        System.assertEquals('No contact found', result);
    }

    @isTest
    static void testGetActiveUserByEmail_NoUserMessage() {
        // Test case when an active user is found
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL LIMIT 1];
        String result = RemsOneTimePortalPasswordSetupController.getActiveUserByEmail(TEST_EMAIL,TEST_PROGRAM_NAME, testAccount.Id, 'Link Expired.');
        System.assertEquals('No User', result);
    }
    

    @isTest
    static void testCreateCommunityUser_Success() {
        // Test case for successful community user creation
        exception ex;
        String result;
        Test.startTest();
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL LIMIT 1];
        result =  RemsOneTimePortalPasswordSetupController.createCommunityUser(TEST_EMAIL, TEST_PASSWORD,TEST_PROGRAM_NAME,'AVEED Portal','AVEED_PortalPermissionSet', testAccount.Id);
        Test.stopTest();
        system.assertEquals(String.isEmpty(result), true);
    }

    @isTest
    static void  getAccountDetailsByIdTest() {
        Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = :TEST_EMAIL LIMIT 1];
        Account accRec = RemsOneTimePortalPasswordSetupController.getAccountDetailsById(testAccount.Id);
        System.assertEquals( testAccount.Id, accRec.Id);
    }

}