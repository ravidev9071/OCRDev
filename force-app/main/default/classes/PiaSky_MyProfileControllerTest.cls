@isTest
public class PiaSky_MyProfileControllerTest {

    @testSetup
    static void setup() {
        // Create a test profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create a test user
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser12323324234s@testorg.com');
        insert u;
        
        // Create a test account
        Account acc = new Account(Name = 'Test Account12321', US_WSREMS__Email__c = 'testaccount1232334rg@test.com');
        insert acc;

        // Create a custom linking object or custom field to link the user to the account
        // Assuming a custom object UserAccountLink__c for example
    }

    @isTest
    static void testGetLoggedInUserAccountDetails() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
        
        // Use System.runAs to set the context to the test user
        System.runAs(testUser) {
            Test.startTest();
            // Call the method to test
            List<User> result = PiaSky_MyProfileController.getLoggedInUserAccountDetails();
            Test.stopTest();

            // Verify the result
            System.assertNotEquals(null, result, 'Expected non-null result');
            System.assertEquals(1, result.size(), 'Expected one user record');
            System.assertEquals(testUser.Id, result[0].Id, 'Expected the logged-in user ID');
        }
    }

    @isTest
    static void testUpdateAccountDetails() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
        
        // Retrieve the test account
        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account12321' LIMIT 1];

        // Prepare the account object as a Map
        Map<String, Object> accountObject = new Map<String, Object>();
        accountObject.put('Id', testAccount.Id);
        accountObject.put('Name', 'Updated Test Account');

        // Use System.runAs to set the context to the test user
        System.runAs(testUser) {
            Test.startTest();
            // Call the method to test
            String result = PiaSky_MyProfileController.updateAccountDetails(accountObject);
            Test.stopTest();

            // Verify the result
            System.assertEquals('Success', result, 'Expected update to succeed');
        }
    }
    
  @isTest
    static void testCreateCaseAndServiceSummary() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
        
        // Retrieve the test account
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account12321' LIMIT 1];
        
        // Mock data for the input records and other parameters
        Map<String, String> inputRecords = new Map<String, String>();
        inputRecords.put('recordDetails', '{"FirstName":"someValue"}'); // Adjust according to actual structure
        String programName = 'PiaSky REMS';

        // Use System.runAs to set the context to the test user
        System.runAs(testUser) {
            Test.startTest();
            // Call the method to test and capture any exception
            String result;
            try {
                result = PiaSky_MyProfileController.createCaseAndServiceSummary(inputRecords, testAccount.Id, programName);
            } catch (Exception e) {
                result = e.getMessage();
                System.debug('Exception: ' + e.getMessage());
            }
            Test.stopTest();

        }
    }
}