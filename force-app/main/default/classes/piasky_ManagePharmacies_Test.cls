@isTest
public class piasky_ManagePharmacies_Test {
    
    @testSetup
    static void setupTestData() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
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
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        
        string AccRecordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('PiaSky REMS', 'Active');
        Id providerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Account providerAccount = SYN_TestDataUtility.createAccount(programObj.Id,providerRecTypeId,'TestProviderFristNamekl','TestProviderLastNamekla');
        providerAccount.US_WSREMS__Email__c = 'testpharmacy@tesb.com';
        update providerAccount;
        
      
        Id serviceRecordType = Schema.sObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get('Participant Account Creation').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c service =  SYN_TestDataFactory.createService(true,programObj.Id,serviceRecordType);
       // service.US_WSREMS__Requestor_Type__c = 'Pharmacy/HCS Participant';
       // update service;
        
        US_WSREMS__Affiliation__c affiliatedAcc = new US_WSREMS__Affiliation__c();
        affiliatedAcc.RecordTypeId = Schema.sObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByName().get('Pharmacy User Affiliation').getRecordTypeId();
        affiliatedAcc.US_WSREMS__REMSProgram__c = programObj.Id;
        affiliatedAcc.US_WSREMS__IsActive__c = true;
        affiliatedAcc.US_WSREMS__Pharmacy_User__c = providerAccount.Id;
        affiliatedAcc.US_WSREMS__Start_Date__c = System.Today();
        Insert affiliatedAcc;
    }
    
    @isTest
    static void getPharmaAccount() {
        Account acc = [Select Id from Account Limit 1];
        
        User testUser = [SELECT Id FROM User WHERE Alias='tuser' LIMIT 1];
        piasky_ManagePharmacies.managePharmacy_Wrapper wrapperData = new piasky_ManagePharmacies.managePharmacy_Wrapper(acc,testUser);
        
        System.runAs(testUser) {
            
            piasky_ManagePharmacies.managePharmacy_Wrapper result = piasky_ManagePharmacies.getPharmaAccount(testUser.Id);
            
        }
    }
    
    @isTest
    static void getAffiliationRec() {
        
        User testUser = [SELECT Id FROM User WHERE Alias='tuser' LIMIT 1];
        
        System.runAs(testUser) {
            
            piasky_ManagePharmacies.getAffiliationRec(testUser.Id);
            
        }
    }
    
    @isTest
    static void createRecordOnSubmit2() {
        
        Map<String, String> inputRecords = new Map<String, String>{
            'recordDetails' => '{"FirstName":"TestProviderFristNamekl","LastName":"TestProviderFristNamekla","email":"testpharmacy@tesb.com","US_WSREMS__User_Type__c":"Pharmacy Staff"}',
                'programName' => 'PiaSky REMS',
                'participantType' => 'Pharmacy Participant',
                'pharmacyId' => '0015300000UasoaBBB'
                };     
                    
                    
                    User testUser = [SELECT Id, isActive FROM User WHERE Alias='tuser' LIMIT 1];
        
        
        String result = piasky_ManagePharmacies.createRecordOnSubmit(inputRecords, testUser.Id, null);
        
    }
    
    @isTest
    static void updateAffRec() {
        
        US_WSREMS__Affiliation__c affiliatedAcc = [SELECT Id, US_WSREMS__Pharmacy_User__c FROM US_WSREMS__Affiliation__c LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Alias='tuser' LIMIT 1];
        System.runAs(testUser) {
            test.startTest();
            piasky_ManagePharmacies.updateAffRec(String.valueOf(affiliatedAcc.Id));
            test.stopTest();
        }
        
    }
}