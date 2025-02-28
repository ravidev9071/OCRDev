@isTest
private class xiaflex_MyProfileControllerTest {
    
    @isTest
    static void testGetLoggedInUserAccountDetails() {
        // Test setup
        User testUser = [SELECT Id FROM User LIMIT 1];
        System.runAs(testUser) {
            // Call the method to test
            List<User> userDetails = xiaflex_MyProfileController.getLoggedInUserAccountDetails();
            
            // Assert statements to validate the results
            System.assertNotEquals(null, userDetails, 'User details should not be null');
            System.assertEquals(1, userDetails.size(), 'User details list should have one record');
        }
    }
    
    @isTest
    static void testUpdateAccountDetails() {
        
        		// Create a test account
        Account acc = new Account(Name = 'Test Account12321', US_WSREMS__Email__c = 'testaccount1232334rg@test.com');
        insert acc;
        
        // Create a test profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
         // Create a test user
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US',ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',UserName = 'standarduser12323324234s@testorg.com');
        insert u;
        
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
            String result = xiaflex_MyProfileController.updateAccountDetails(accountObject);
            result = PiaSky_MyProfileController.updateAccountDetails(accountObject);
            Test.stopTest();
            
            // Verify the result
            System.assertEquals('Success', result, 'Expected update to succeed');
            
        }   
    }
    
    @isTest()
    public static void getPicklistValues(){
        Map<String, Map<String, String>> result = xiaflex_MyProfileController.getPicklistFieldValues();
    
    System.assert(result != null, 'Picklist values should not be null');
    System.assert(result.size() > 0, 'Picklist values should be found');
    System.assert(result.containsKey('US_WSREMS__SLN_State__c'), 'Picklist values for US_WSREMS__SLN_State__c should be found');
    System.assert(result.get('US_WSREMS__SLN_State__c').size() > 0, 'Picklist values for US_WSREMS__SLN_State__c should be found');

}
}