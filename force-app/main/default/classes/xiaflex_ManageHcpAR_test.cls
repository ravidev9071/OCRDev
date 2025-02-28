@isTest
public class xiaflex_ManageHcpAR_test {
 @testSetup
    static void setupTestData() {
        string AccRecordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        US_WSREMS__REMS_Program__c program = SYN_TestDataUtility.createProgram('Xiaflex', 'Active');
        Account prescriberAcc = SYN_TestDataUtility.createPrescriberPersonAccount(program.Id);
        id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Health Care Setting').getRecordTypeId();
        id arRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy/HCS Participant').getRecordTypeId();
        Account authRep = new Account(FirstName = 'Test AR', LastName = 'Account', RecordTypeId = arRecordTypeId,
                                     US_WSREMS__REMS_Program__c = program.Id,Rating = 'Hot',Type = 'Prospect',
                                      Industry = 'Banking',Ownership = 'Public',Phone = '1234567890',AccountNumber = '4567',
                                      Sic = 'Test Site',ShippingCountry = 'United States',
                                      ShippingState = '',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                      ShippingPostalCode = '12345',SYN_Shipping_Address_2__c ='Test');
      //  insert authRep;
        Account pharmacyAcc = new Account();
        pharmacyAcc.Name = 'TestPharmact';
        pharmacyAcc.US_WSREMS__Channel__c = 'fax';
        pharmacyAcc.Rating = 'Hot';
        pharmacyAcc.Type = 'Prospect';
        pharmacyAcc.Industry = 'Banking';
        pharmacyAcc.Ownership = 'Public';
        pharmacyAcc.Phone = '1243546789';
        pharmacyAcc.Sic = 'Test Site';
        pharmacyAcc.RecordTypeId = recordTypeId;
        pharmacyAcc.ShippingCountry = 'United States';
        pharmacyAcc.ShippingState = 'Alabama';
        pharmacyAcc.ShippingStreet = 'Test Street';
        pharmacyAcc.ShippingCity = 'Test City';
        pharmacyAcc.ShippingPostalCode = '12345';
        pharmacyAcc.US_WSREMS__REMS_Program__c = program.Id;
        insert pharmacyAcc;
        Account providerAccount = SYN_TestDataUtility.createAccount(program.Id,AccRecordTypeId,'TestProviderFristNamekl','TestProviderLastNamekla');
        providerAccount.US_WSREMS__Email__c = 'testpharmacy@tesb.com';
        update providerAccount;
        List<Account> personAccList = [SELECT Id, PersonContactId, US_WSREMS__REMS_ID__c FROM Account WHERE Id = :providerAccount.Id];
        Profile p = [SELECT Id FROM Profile WHERE Name='Xiaflex Portal' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + Math.random() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            ContactId = personAccList[0].PersonContactId,
            US_WSREMS__REMS_Program__c = program.Name
        );
        insert testUser;
        Account testAccount = new Account();
        testAccount.Name = 'Test Pharmacy';
        testAccount.Fax = '9999123456';
        testAccount.US_WSREMS__Healthcare_Setting_Type__c = 'Type 1';
        testAccount.US_WSREMS__DEA__c = 'Test12345';
        testAccount.US_WSREMS__NPI__c = '1111122222';
        insert testAccount;
        
        Account accountObj = new Account(FirstName = 'Person',LastName = 'Account',
                                         US_WSREMS__REMS_Program__c = program.Id,Rating = 'Hot',Type = 'Prospect',
                                         Industry = 'Banking',Ownership = 'Public',Phone = '1234567890',AccountNumber = '4567',
                                         Sic = 'Test Site',RecordTypeId = AccRecordTypeId ,ShippingCountry = 'United States',
                                         ShippingState = '',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                         ShippingPostalCode = '12345',SYN_Shipping_Address_2__c ='Test');
        insert accountObj;
        
        US_WSREMS__REMS_Program__c remsProgram = new US_WSREMS__REMS_Program__c();
        remsProgram.Name = 'Test Program';
        remsProgram.US_WSREMS__Phone__c = '1234567890';
        remsProgram.US_WSREMS__Fax__c = '0987654321';
        insert remsProgram;
        string prescriberAffliationRecId = Schema.sObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByName().get('Prescriber Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c testHCPAff = new US_WSREMS__Affiliation__c(
            US_WSREMS__Health_Care_Setting__c = testAccount.Id,
            US_WSREMS__REMSProgram__c = program.Id,
            US_WSREMS__isActive__c = true,
            US_WSREMS__Prescriber__c = providerAccount.Id,
            RecordTypeId=prescriberAffliationRecId
        );
        insert testHCPAff;
        
        string AccAffiliRecordTypeId = Schema.sObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByName().get('Authorized Representative Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c testAffiliation = new US_WSREMS__Affiliation__c(
            US_WSREMS__Health_Care_Setting__c = testAccount.Id,
            US_WSREMS__REMSProgram__c = remsProgram.Id,
            US_WSREMS__isActive__c = true,
            US_WSREMS__Authorized_Representative__c=personAccList[0].Id,
            RecordTypeId=AccAffiliRecordTypeId
        );
        insert testAffiliation;
    }
    @isTest
    static void testGetRelatedHCPToAR() {
        User testUser = [SELECT Id FROM User where email = 'testuser@example.com' LIMIT 1];
        
        Test.startTest();
  		List<US_WSREMS__Affiliation__c> pharmaAccounts = xiaflex_ManageHcpAR.getRelatedHCPToAR(testUser.Id,'REMS');
        US_WSREMS__Affiliation__c presAff;
        US_WSREMS__Affiliation__c arAff;
        for(US_WSREMS__Affiliation__c aff : [SELECT Id,RecordType.Name,US_WSREMS__isActive__c  FROM US_WSREMS__Affiliation__c]) {
            arAff = aff.RecordType.Name == 'Authorized Representative Affiliation' ? aff : presAff;
            presAff = aff.RecordType.Name == 'Prescriber Affiliation' ? aff : presAff;
        }
        presAff.US_WSREMS__isActive__c = false;
        update presAff;
        pharmaAccounts = xiaflex_ManageHcpAR.getRelatedHCPToAR(testUser.Id,'REMS');
        arAff.US_WSREMS__isActive__c = false;
        update arAff;
        pharmaAccounts = xiaflex_ManageHcpAR.getRelatedHCPToAR(testUser.Id,'REMS');
        Test.stopTest();
        
    }
}