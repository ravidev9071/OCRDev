// Created By Rajeev for RDA Portal User Story on 11th July

@isTest
public class AccountControllerRDATest {
    
    @testSetup
    static void setupTestData() {
        RecordType participantAccountRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Outpatient_Pharmacy_Account' LIMIT 1];
        RecordType remsServiceSummaryRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'US_WSREMS__REMS_Service_Summary__c' AND DeveloperName = 'Participant_Enrollment' LIMIT 1];
         US_WSREMS__REMS_Program__c remsProgram = new US_WSREMS__REMS_Program__c(
            name = 'TRYVIO REMS',
             US_WSREMS__Status__c = 'Active'
        );
        insert remsProgram;
        
		 US_WSREMS__REMS_Program__c remsProgramId = [SELECT Id FROM US_WSREMS__REMS_Program__c WHERE Name = 'TRYVIO REMS' LIMIT 1];        
        
        Account account1 = new Account(
            Name = 'Test Account',
			US_WSREMS__First_Name__c = '',
            US_WSREMS__State__c = 'CA',
            US_WSREMS__NPI__c = '1234567890',
            recordtypeid = participantAccountRecordType.id,
            US_WSREMS__REMS_Program__c = remsProgramId.id
        );
        insert account1;
        
        Account account2 = new Account(
            US_WSREMS__First_Name__c = '',
            name = 'John Decosta',
            US_WSREMS__State__c = 'CA',
            US_WSREMS__NPI__c = '0987654321',
            recordtypeid = participantAccountRecordType.id,
            US_WSREMS__REMS_Program__c = remsProgram.id,
            US_WSREMS__National_Provider_Identifier__c = 'Test',
            US_WSREMS__Professional_Designation__c = 'MD'
        );
        insert account2;
        RecordType Participant_Account_CreationRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'US_WSREMS__REMS_Service_Summary__c' AND DeveloperName = 'Pre_Dispense_Authorization'];
    }
    
    @isTest
    static void testsearchAccountsByNpi() {
        // Call the method from the first class
        Test.startTest();
        List<Account> resultsByName = AccountControllerRDA.searchAccountsByNpi('1234567890');
        Test.stopTest();
    }

    @isTest
    static void testsearchAccountsByName() {
        Test.startTest();
        List<Account> resultsByNameState = AccountControllerRDA.searchAccountsByName('', 'John Decosta', 'CA');
        Test.stopTest();
    }
    
    
    @isTest
    static void testGetCaseById() {
        // Get an existing account ID
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
         id recordTypeIdInpatient = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Outpatient_Pharmacy').getRecordTypeId();
        
        // Create a case
        Case testCase = new Case(
            AccountId = account.Id,
            Status = 'Complete',
            US_WSREMS__Channel__c = 'Portal',
            Program_Record_Type_Control__c = 'TRYVIO REMS-PDA',
            RecordTypeId = recordTypeIdInpatient
        );
        insert testCase;
        
        // Call the method from the fourth class
        Test.startTest();
        Case resultCase = AccountControllerRDA.getCaseDetails(testCase.Id);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, resultCase, 'Expected to find a case');
        System.assertEquals('Complete', resultCase.Status, 'Expected case status to be Complete');
    }


 @isTest
    static void testCreateCase() {
        // Fetch the test account
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'John Decosta' LIMIT 1];

        // Start the test context
        Test.startTest();

        // Call the createCase method
        Id caseId = AccountControllerRDA.createCase(testAccount.Id);

        // End the test context
        Test.stopTest();

        // Validate the Case
        Case newCase = [SELECT Id, AccountId, Status, US_WSREMS__Authorization_Status__c, RDA_Authorization_Code__c, RecordTypeId 
                        FROM Case 
                        WHERE Id = :caseId];
        System.assertEquals('Complete', newCase.Status);
        System.assertEquals('Approved', newCase.US_WSREMS__Authorization_Status__c);
        // Validate the REMS Service Summary
    }
    
    @isTest
    static void testcreateCaseWithoutAccount() {
        Test.startTest();
        Id caseId = AccountControllerRDA.createCaseWithoutAccount('Test', 'Test2', 'AK', '1233457698');

        Test.stopTest();
        Case newCase = [SELECT Id, Status, US_WSREMS__Authorization_Status__c, RDA_Authorization_Code__c, RecordTypeId 
                        FROM Case 
                        WHERE Id = :caseId];
        //System.assertNotEquals(null, newCase.RDA_Authorization_Code__c);
        
    }

}