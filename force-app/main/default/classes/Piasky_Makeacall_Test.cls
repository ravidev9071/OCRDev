@isTest
public class Piasky_Makeacall_Test {
    private static final String TEST_PROGRAM_NAME = 'PiaSky REMS';
    private static final String TEST_EMAIL = 'test@example.com';
    
    @testSetup
    static void setupTestData() {
        // Create test program
        US_WSREMS__REMS_Program__c testProgram = SYN_TestDataUtility.createProgram(TEST_PROGRAM_NAME,'Active');

        // Create test account
        Account testAccount = SYN_TestDataUtility.createPrescriberPersonAccount(testProgram.id);
        testAccount.PersonEmail = TEST_EMAIL;
        update testAccount;

    }
    
    @isTest
    static void testCreateREMSService() {
        // Query the test account created in the @testSetup method
        Account testAccount = [SELECT Id ,US_WSREMS__REMS_Program__c FROM Account WHERE PersonEmail = :TEST_EMAIL LIMIT 1];
        
        // Call the method to test
        Test.startTest();
        String caseId = Piasky_Makeacall.CreateREMSService(testAccount.Id,null,testAccount.US_WSREMS__REMS_Program__c);
        Test.stopTest();
        
        // Assert that the Case record was created and has the expected values
        Case createdCase = [SELECT Id, US_WSREMS__Participant__c, US_WSREMS__REMS_Program__c, US_WSREMS__REMS_Service_Summary__c
                            FROM Case WHERE Id = :caseId LIMIT 1];
        
        System.assertNotEquals(null, createdCase, 'Case record should be created');
        System.assertEquals(testAccount.Id, createdCase.US_WSREMS__Participant__c, 'Case should be linked to the correct account');
    }
}