@isTest
public class RDAControllerUnitTest {

    @testSetup
    static void setupTestData() {
        // RT 08-10-24 defect changes
        Account testAccount = new Account(
            Name = 'vikki',
            ShippingStreet = 'vikki Street',
            US_WSREMS__NPI__c = '0987654321',
            ShippingCity = 'Gotham',
            State_Secondary_Office__c = 'GA',
            Zip_Secondary_Office__c = '31024',
            Address_1_Secondary_Office__c = '228 N Jefferson Ave',
            City_Secondary_Office__c = 'Eatonton',
            ShippingState = 'NY',
            ShippingPostalCode = '54321',
            ShippingCountry = 'London',
            Phone = '333-2453'
        );
        insert testAccount;
    }

    @isTest
    static void testGetAccount() {
        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'vikki' LIMIT 1];

        Account result = RDAController.getAccount(testAccount.Id);

        System.assertNotEquals(null, result, 'Account should not be null');
        System.assertEquals(testAccount.Id, result.Id, 'Account Id should match the expected Id');
        System.assertEquals('vikki', result.Name, 'Account Name should match');
        System.assertEquals('vikki Street', result.ShippingStreet, 'ShippingStreet should match');
        System.assertEquals('0987654321', result.US_WSREMS__NPI__c, 'NPI should match');
        System.assertEquals('Gotham', result.ShippingCity, 'ShippingCity should match');
        System.assertEquals('NY', result.ShippingState, 'ShippingState should match');
        System.assertEquals('54321', result.ShippingPostalCode, 'ShippingPostalCode should match');
        System.assertEquals('London', result.ShippingCountry, 'ShippingCountry should match');
        System.assertEquals('333-2453', result.Phone, 'Phone should match');
    }

    @isTest
    static void testGetLatestCaseAndShippingTracking() {
        RecordType businessAccountRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Pharmacy' LIMIT 1];
        Account testAccount = new Account(
            Name = 'Test Pharmacy',
            RecordTypeId = businessAccountRecordType.Id 
        );
        insert testAccount;
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Complete',
            US_WSREMS__Pharmacy__c = testAccount.Id,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId(),
            US_WSREMS__Outcome__c = 'Approved',
            Program_Record_Type_Control__c = 'Macitentan REMS-PDA',
            US_WSREMS__Program_Picklist__c = 'Macitentan REMS'
        );
        insert testCase;
        US_WSREMS__Shipping_and_Tracking__c trackingRecord1 = new US_WSREMS__Shipping_and_Tracking__c(
            US_WSREMS__Case__c = testCase.Id,
            US_WSREMS__Status__c = 'Accepted'
        );
        insert trackingRecord1;

        US_WSREMS__Shipping_and_Tracking__c trackingRecord2 = new US_WSREMS__Shipping_and_Tracking__c(
            US_WSREMS__Case__c = testCase.Id,
            US_WSREMS__Status__c = 'Accepted'
        );
        insert trackingRecord2;

        Test.startTest();
        Map<String, Object> resultMap = RDAController.getLatestCaseAndShippingTracking(testAccount.Id, testCase.Id);
        Test.stopTest();

        System.assertNotEquals(null, resultMap, 'Result map should not be null');
        
        System.assert(resultMap.containsKey('currentCase'), 'Result map should contain current case');
        Case returnedCase = (Case)resultMap.get('currentCase');
        System.assertEquals(testCase.Id, returnedCase.Id, 'Returned case ID should match the inserted case ID');

        System.assert(resultMap.containsKey('shippingTrackingRecords'), 'Result map should contain shipping tracking records');
        List<US_WSREMS__Shipping_and_Tracking__c> shippingTrackingRecords = (List<US_WSREMS__Shipping_and_Tracking__c>)resultMap.get('shippingTrackingRecords');
        System.assertEquals(2, shippingTrackingRecords.size(), 'There should be 2 shipping tracking records');

        System.assert(resultMap.containsKey('hasAcceptedStatus'), 'Result map should contain hasAcceptedStatus key');
        Boolean hasAcceptedStatus = (Boolean)resultMap.get('hasAcceptedStatus');
        System.assert(hasAcceptedStatus, 'There should be at least one accepted status in the shipping tracking records');
    }

    @isTest
    static void testGetLatestCaseAndShippingTrackingException() {
        String invalidAccountId = 'invalid_account_id';
        String invalidCaseId = 'invalid_case_id';
        Test.startTest();
        try {
            RDAController.getLatestCaseAndShippingTracking(invalidAccountId, invalidCaseId);
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            // System.assert(e.getMessage().contains('Error fetching data'), 'Exception message should indicate an error fetching data');
            System.debug(e.getMessage());
        } finally {
            Test.stopTest();
        }
    }
}