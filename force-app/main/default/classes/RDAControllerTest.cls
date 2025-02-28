@isTest
public class RDAControllerTest {
 
    @TestSetup
    static void setupTestData() {
        
        Account testAccount = new Account(
            Name = 'vikki',
            ShippingStreet = 'vikki Street',
            US_WSREMS__NPI__c = '0987654321',
            ShippingCity = 'Gotham',
            ShippingState = 'NY',
            ShippingPostalCode = '54321',
            ShippingCountry = 'London',
            Phone = '333-2453'
        );
        insert testAccount;

        id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id recordTypeIdPharmacy = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
        id caseRDARecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();
        id recordTypeIdREMSService = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Pre_Dispense_Authorization').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        US_WSREMS__Program_Users__c programUser = SYN_TestDataUtility.createProgramUser(UserInfo.getUserId(),programObj.id);
        Account prescAccount = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        Account patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
        Account pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy);
        Account pharmCParticipanAccount = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,recordTypeIdPharmacyParticipant);
        // Create a contact for pharmCAccount (Pharmacy Account)
        Contact pharmacyContact = new Contact(
            LastName = 'Pharmacy Contact', // Modify as per your needs
           AccountId = pharmCAccount.Id,   // Link contact to pharmacy account
           Email = 'pharmacy@example.com', // Modify with actual contact details
           Phone = '123-456-7890'          // Modify as needed
           );
           Insert pharmacyContact;
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c(US_WSREMS__REMSProgram__c = programObj.id,US_WSREMS__Requestor_Type__c = 'Pharmacy',US_WSREMS__Participant__c = pharmCAccount.id, recordTypeId = recordTypeIdREMSService);
        Insert serviceObj;
        US_WSREMS__Affiliation__c createAffiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmCParticipanAccount.Id,pharmCAccount.Id);
        // create RDA 
        Case caseObjRDA = SYN_TestDataUtility.createaRDACase(caseRDARecordTypeId,programObj.id,prescAccount,patientAccount,pharmCAccount,pharmCParticipanAccount,serviceObj);

       // Create Shipping and Tracking Record
        US_WSREMS__Shipping_and_Tracking__c shippingTracking = SYN_TestDataUtility.createShippingAndTrackingRecordForRDACase(
            caseObjRDA.Id,
            patientAccount.Id
        );

        // Create a Community User
        Profile profile = [SELECT Id FROM Profile WHERE UserType = 'PowerCustomerSuccess' LIMIT 1];
        User communityUser = SYN_TestDataUtility.CreateCommunityUser(
            pharmCAccount,
            profile.Id,
            programObj.Name,
            'Outpatient Pharmacy'
        );
    }

    @IsTest
    static void testGetCasesByAccount() {
        // Fetch test data
        Account pharmacyAccount = [SELECT Id FROM Account WHERE Name = 'PharmacyAccountC' LIMIT 1];
         // RT 08-10-24 defect changes
        Account pharmacyParticipantAcc = [SELECT Id FROM Account WHERE Name = 'PharmacyPartD Account' LIMIT 1];
        // Prepare parameters
        Date startDt = Date.today().addDays(-30);
        Date endDt = Date.today();
        String paramJson = JSON.serialize(new Map<String, Object>{
            'accountId' => pharmacyAccount.Id,
            'remsId' => null,
            'sortBy' => 'CreatedDate',
            'sortDirection' => 'DESC',
            'pageSize' => 10,
            'pageNumber' => 1,
            'startDate' => startDt.year() + '-' + startDt.month() + '-' + startDt.day(),
            'endDate' => endDt.year() + '-' + endDt.month() + '-' + endDt.day(),
            'isDownload' => false
        });
        
        Test.startTest();
        // Call the method and check the results
        List<Case> cases = RDAController.getCasesByAccount(paramJson);
        Test.stopTest();
        
        System.assertNotEquals(0, cases.size(), 'Cases should be returned');
    }
    
    @isTest
    static void testCreateReverseRDA() {
        // Fetch test data
        Account pharmacy = [SELECT Id, US_WSREMS__REMS_Program__c, US_WSREMS__REMS_Program__r.Name FROM Account WHERE Name = 'PharmacyAccountC' LIMIT 1];

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testcontact@example.com',
            AccountId = pharmacy.Id
        );
        insert con;

        // Get Original Case
        Case originalCase = [SELECT Id, US_WSREMS__REMS_Service_Summary__c, US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Status__c FROM Case WHERE US_WSREMS__Participant__c = :pharmacy.Id LIMIT 1];
        System.debug(originalCase.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Status__c);

        // Update the REMS Service Summary Status to Closed
        US_WSREMS__REMS_Service_Summary__c remsSS = [SELECT Id, US_WSREMS__Status__c FROM US_WSREMS__REMS_Service_Summary__c WHERE Id =: originalCase.US_WSREMS__REMS_Service_Summary__c LIMIT 1];
        remsSS.US_WSREMS__Status__c = 'Closed';
        update remsSS;

        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'New Maci Portal Profile' LIMIT 1];
        // User communityUser = SYN_TestDataUtility.CreateCommunityUser(
        //     pharmacy,
        //     communityProfile.Id,
        //     pharmacy.US_WSREMS__REMS_Program__r.Name,
        //     'Outpatient Pharmacy'
        // );

        User newCommunityUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testcommunityuser@example.com',
            Username = 'testcommunityuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tcuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = communityProfile.Id,
            LanguageLocaleKey = 'en_US',
            ContactId = con.Id,
            CommunityNickname = 'tcuser', 
            Program__c = pharmacy.US_WSREMS__REMS_Program__c, 
            Role__c = 'Outpatient Pharmacy', 
            UserRoleId = null 
        );
        insert newCommunityUser;

        System.runAs(newCommunityUser) {
            Test.startTest();
            // Call the method and check the results
            Case reversedCase = RDAController.createReverseRDA(pharmacy.Id, originalCase.Id, pharmacy.Id);
            Test.stopTest();

            System.assertEquals(originalCase.US_WSREMS__REMS_Service_Summary__c, reversedCase.US_WSREMS__REMS_Service_Summary__c, 'Reversed Case should be the child of the Original Case');
        }
    }
}