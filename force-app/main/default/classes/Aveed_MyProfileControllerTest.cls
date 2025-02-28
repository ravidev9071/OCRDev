@isTest
public with sharing class Aveed_MyProfileControllerTest {
    @testSetup
    static void setup() {
        List<sObject> insertObjects = new List<sObject>();
        // Create a test profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create a test user
        User testUser = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = testProfile.Id, TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser12323324234s@testorg.com');
        insertObjects.add(testUser);

        US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c ();
        programObj.Name = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        programObj.US_WSREMS__Status__c  ='Active';
        programObj.REMS_Project_Code__c = 'BT1005';
        programObj.US_WSREMS__Program_State_Date__c  = System.today();
        programObj.US_WSREMS__Program_End_Date__c  = System.today().addDays(20);
        insertObjects.add(programObj);
        insert insertObjects;
         
        Id prescriberRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
		Account testAccount = SYN_TestDataUtility.createAccount(programObj.Id,prescriberRecordType,'Test', 'Last');
    }

    @isTest
    static void testGetLoggedInUserAccountDetails() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
        
        // Use System.runAs to set the context to the test user
        System.runAs(testUser) {
            Test.startTest();
            // Call the method to test
            List<User> result = Aveed_MyProfileController.getLoggedInUserAccountDetails();
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
        Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];

        // Prepare the account object as a Map for Positive scenario
        Map<String, Object> accountObject = new Map<String, Object>();
        accountObject.put('Id', testAccount.Id);
        accountObject.put('LastName', 'Updated Test Account');
        
        // Prepare the account object as a Map for negative scenario
        Map<String, Object> accountObj = new Map<String, Object>();
        accountObj.put('LastName', 'Updated Test Account');

        // Use System.runAs to set the context to the test user
        System.runAs(testUser) {
            Test.startTest();
            // Call the method to test
            String result = Aveed_MyProfileController.updateAccountDetails(accountObject);
            String failResult = Aveed_MyProfileController.updateAccountDetails(accountObj);
            Test.stopTest();
            
            Boolean accResult = failResult.Contains('Id not specified in an update call');

            // Verify the result
            System.assertEquals('Success', result, 'Expected update to succeed');
            System.assertEquals(True, accResult, 'Expected update to Fail');
           }
    }
    
  @isTest
    static void testCreateCaseAndServiceSummary() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
        
        // Retrieve the test account
        // Retrieve the programToCreateServiceSummary
        US_WSREMS__REMS_Program__c programRecord = [SELECT Id,Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME LIMIT 1];
        
        RecordType recordType = [SELECT Id,Name from RecordType WHERE sObjectType='Account' AND Name = 'Prescriber' LIMIT 1];

		Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Mock data for the input records and other parameters
        Map<String, String> inputRecords = new Map<String, String>();
        inputRecords.put('recordDetails', '{"FirstName":"someValue"}'); // Adjust according to actual structure
        String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        String demoProgramName = 'Demo AVEED REMS';

        // Use System.runAs to set the context to the test user
        System.runAs(testUser) {
            Test.startTest();
            // Call the method to test and capture any exception
            String result;
            String resultDemo;
            try {
                result = Aveed_MyProfileController.createCaseAndServiceSummary(inputRecords, testAccount.Id, programName);
                resultDemo = Aveed_MyProfileController.createCaseAndServiceSummary(inputRecords, testAccount.Id, demoProgramName);
            } catch (Exception e) {
                result = e.getMessage();
                System.debug('Exception: ' + e.getMessage());
            }
            Test.stopTest();
            
            Boolean accResult = resultDemo.Contains('exception');
            
           // System.assertEquals('Success', result, 'Expected update to succeed');
            System.assertEquals(True, accResult, 'Expected update to Fail');

        }
    }
    
      @isTest
    static void testloggedinUserDetails() { 
     User testUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
    
          System.runAs(testUser) {
            // Call the loggedinUserDetails method
            Aveed_MyProfileController.loggedinUserWrapper result = Aveed_MyProfileController.loggedinUserDetails();
            String result1 = Aveed_MyProfileController.loggedOutUser();
          }
    }
}