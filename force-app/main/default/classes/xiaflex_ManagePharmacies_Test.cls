/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class xiaflex_ManagePharmacies_Test {
    
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
        
        US_WSREMS__Affiliation__c testAffiliation = new US_WSREMS__Affiliation__c();
        testAffiliation.US_WSREMS__Health_Care_Setting__c = testAccount.Id;
        testAffiliation.US_WSREMS__REMSProgram__c = remsProgram.Id;
        testAffiliation.US_WSREMS__isActive__c = true;
        insert testAffiliation;
        
    }
    
    @isTest
    static void testGetPharmaAccount() {
        User testUser = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        List<Account> pharmaAccounts = xiaflex_ManagePharmacies.getPharmaAccount(testUser.Id);
        Test.stopTest();
        
        System.assertNotEquals(0, pharmaAccounts.size(), 'Pharma accounts should be returned.');
        System.assertEquals('Test Pharmacy', pharmaAccounts[0].Name, 'Pharma account name should match.');
    }
    
    @isTest
    static void testGetArPharmaAccount() {
        User testUser = [SELECT Id FROM User where email = 'testuser@example.com' LIMIT 1];
        
        Test.startTest();
        List<Account> pharmaAccounts = xiaflex_ManagePharmacies.getARPharmaAccount(testUser.Id,'REMS');
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetPharmaAccountDetails() {
        
        Account acc = [Select Id, name, Fax, US_WSREMS__Healthcare_Setting_Type__c,US_WSREMS__Role__c,US_WSREMS__Status__c,SYN_Ref_Id__c,US_WSREMS__DEA__c,US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c, US_WSREMS__Zip__c, US_WSREMS__City__c, US_WSREMS__State__c from Account where recordType.Name = 'Health Care Setting' Limit 1];
        Test.startTest();
        Map<String,List<Account>> pharmaAccounts = xiaflex_ManagePharmacies.getPharmaAccountDetails(acc.Id);
        Test.stopTest();
        System.assertNotEquals(0, pharmaAccounts.size(), 'Pharma accounts should be returned.');
        System.assertEquals('TestPharmact', pharmaAccounts.get('pharma')[0].Name, 'Pharma account name should match.');
        
        
    }
    @isTest()
        static void getARrecords(){
           User testUser = [SELECT Id,firstname, ContactId FROM User where Name like '%Test User%' LIMIT 1];
           US_WSREMS__REMS_Program__c programObj = [Select Id, Name, US_WSREMS__Status__c, REMS_Project_Code__c from US_WSREMS__REMS_Program__c where Name = 'Xiaflex'];		
          string userId = testUser.id; 
          string programName = programObj.Name;
            Account acc = new Account();
        }
    
    @isTest
    static void testRemoveAffiliation() {
        User testUser = [SELECT Id, Contact.AccountId FROM User where Name like '%Test User%' LIMIT 1];
        US_WSREMS__REMS_Program__c programObj = [Select Id, Name, US_WSREMS__Status__c, REMS_Project_Code__c from US_WSREMS__REMS_Program__c where Name = 'Xiaflex'];		
        
        Map<String, String> inputRecords = new Map<String, String>();
        Account accountObj = createPharmaAcc('Test Pharma Acc', '1234567890', programObj);
        insert accountObj;
        inputRecords.put('programName', 'Xiaflex');
        inputRecords.put('Id', accountObj.Id);
        inputRecords.put('CurrentuserID', testUser.Id);
        US_WSREMS__Affiliation__c aff = createAffiliation(null, accountObj.Id, testUser.Contact.AccountId, 'Prescriber Affiliation', programObj);
        insert aff;
        Test.startTest();
        String result = xiaflex_ManagePharmacies.removeAffiliation(inputRecords);
        Test.stopTest();
        }
    
    @isTest
    static void testInsertHCPSubmitWithHcsEntryFalse() {
        User testUser = [SELECT Id, firstname, Contact.AccountId, ContactId FROM User where Name like '%Test User%' LIMIT 1];
        List<US_WSREMS__REMS_Program__c> prg = new List<US_WSREMS__REMS_Program__c>();
        US_WSREMS__REMS_Program__c programObj = [Select Id, Name, US_WSREMS__Status__c, REMS_Project_Code__c from US_WSREMS__REMS_Program__c where Name = 'Xiaflex'];			
        prg.add(programObj);
        Map<String, String> inputRecords = new Map<String, String>();
        inputRecords.put('programName', 'Xiaflex');
        inputRecords.put('recordDetails', '{"name":"Test Pharma Acc","channel":"fax","address1":"address line 1","city":"Kyoto","state":"HI","zipCode":"47389","hcsType":"Independent Practice","npi":"1234321230"}');
        inputRecords.put('Id',null);
        inputRecords.put('programType', 'REMS');
        
        Test.startTest();
        String result = xiaflex_ManagePharmacies.insertHCPSubmit(inputRecords, testUser.Id, false);
        String recordDetails = inputRecords.get('recordDetails');
        xiaflex_ManagePharmacies.RecordDataWrapper recordData = (xiaflex_ManagePharmacies.RecordDataWrapper)System.JSON.deserialize(recordDetails,xiaflex_ManagePharmacies.RecordDataWrapper.class);
        xiaflex_ManagePharmacies.insertAccount(recordData,prg,true,'Prescriber');
        Test.stopTest();        
    }
    
    @isTest
    static void testInsertHCPSubmitWithHcsEntryTrue() {
        User testUser = [SELECT Id, firstname, Contact.AccountId, ContactId FROM User where Name like '%Test User%' LIMIT 1];
        List<US_WSREMS__REMS_Program__c> prg = new List<US_WSREMS__REMS_Program__c>();
        US_WSREMS__REMS_Program__c programObj = [Select Id, Name, US_WSREMS__Status__c, REMS_Project_Code__c from US_WSREMS__REMS_Program__c where Name = 'Xiaflex'];			
        prg.add(programObj);
        Map<String, String> inputRecords = new Map<String, String>();
        inputRecords.put('programName', 'Xiaflex');
        inputRecords.put('recordDetails', '{"name":"Test Pharma Acc","channel":"fax","address1":"address line 1","city":"Kyoto","state":"HI","zipCode":"47389","hcsType":"Independent Practice","npi":"1234321230"}');
        inputRecords.put('Id',null);
        inputRecords.put('programType', 'REMS');
        
        Test.startTest();
        String result = xiaflex_ManagePharmacies.insertHCPSubmit(inputRecords, testUser.Id, true);
        String recordDetails = inputRecords.get('recordDetails');
        xiaflex_ManagePharmacies.RecordDataWrapper recordData = (xiaflex_ManagePharmacies.RecordDataWrapper)System.JSON.deserialize(recordDetails,xiaflex_ManagePharmacies.RecordDataWrapper.class);
        xiaflex_ManagePharmacies.insertAccount(recordData,prg,true,'Prescriber');
        Test.stopTest();        
    }
    
    @isTest()
    public static void insertEnrollment(){
        Map<String, String> inputRecords = new Map<String, String>();
        Account authRepAcc = [Select ID from Account where RecordType.Name = 'Prescriber' limit 1];
        Account pharmacyAcc = [Select ID from Account where RecordType.Name = 'Health Care Setting' limit 1];
        inputRecords.put('arRecord', '{"firstName": "Test","Id": "'+authRepAcc.Id +'", "lastName":"AR","email":"test@3gmail.com", "phone":"9999999999", "fax": "8888888888", "role": "Other", "Channel": "Fax"}');
        inputRecords.put('hcsRecord','{"Id": "'+pharmacyAcc.Id+'", "name": "Test Pharma Enroll New Acc", "address1": "3309 Lakeshore Ave", "address2": "htgrfedws", "city": "Somerset", "state": "ID", "zipCode":"43342", "Channel": "Fax", "npi": "2345687654", "dea" :"tw5678767", "hin":"X21345673", "ncpdp":"5678845", "hcsType": "Institution Central Purchasing (owned or under control of hospital system)"}');
        inputRecords.put('programName', REMSAppLiterals.XIAFLEX_PROGRAM);
    }
    
        @isTest()
    public static void insertEnrollmentWithoutHcsId(){
        Map<String, String> inputRecords = new Map<String, String>();
        Account authRepAcc = [Select ID from Account where RecordType.Name = 'Prescriber' limit 1];
        Account pharmacyAcc = [Select ID from Account where RecordType.Name = 'Health Care Setting' limit 1];
        inputRecords.put('arRecord', '{"firstName": "Test","Id": "'+authRepAcc.Id +'", "lastName":"AR","email":"test@3gmail.com", "phone":"9999999999", "fax": "8888888888", "role": "Other", "Channel": "Fax"}');
        inputRecords.put('hcsRecord','{ "name": "Test Pharma Enroll New Acc", "address1": "3309 Lakeshore Ave", "address2": "htgrfedws", "city": "Somerset", "state": "ID", "zipCode":"43342", "Channel": "Fax", "npi": "2345687654", "dea" :"tw5678767", "hin":"X21345673", "ncpdp":"5678845", "hcsType": "Institution Central Purchasing (owned or under control of hospital system)"}');
        inputRecords.put('programName', REMSAppLiterals.XIAFLEX_PROGRAM);
    }
    
    @isTest()
    public static void insertEnrollment2(){
        Map<String, String> inputRecords = new Map<String, String>();
        Account authRepAcc = [Select ID from Account where RecordType.Name = 'Prescriber' limit 1];
        Account pharmacyAcc = [Select ID from Account where RecordType.Name = 'Health Care Setting' limit 1];
        inputRecords.put('arRecord', '{"firstName": "Test","Id": "'+authRepAcc.Id +'", "lastName":"AR","email":"test@3gmail.com", "phone":"9999999999", "fax": "8888888888", "role": "Other", "Channel": "Fax"}');
        inputRecords.put('hcsRecord','{"Id": "'+pharmacyAcc.Id+'", "name": "Test Pharma Enroll New Acc", "address1": "3309 Lakeshore Ave", "address2": "htgrfedws", "city": "Somerset", "state": "ID", "zipCode":"43342", "Channel": "Fax", "npi": "2345687654", "dea" :"tw5678767", "hin":"X21345673", "ncpdp":"5678845", "hcsType": "Institution Central Purchasing (owned or under control of hospital system)"}');
        inputRecords.put('programName', REMSAppLiterals.XIAFLEX_PROGRAM);
        Test.StartTest();
         String result = xiaflex_ManagePharmacies.insertHcsEnrollment(inputRecords,null);
        Test.StopTest();
        System.assertEquals('Success', result, 'Insert HCP Submit should return success.');
    }
    
        @isTest()
    public static void insertEnrollment3(){
        Map<String, String> inputRecords = new Map<String, String>();
        Account authRepAcc = [Select ID from Account where RecordType.Name = 'Prescriber' limit 1];
        Account pharmacyAcc = [Select ID from Account where RecordType.Name = 'Health Care Setting' limit 1];
        inputRecords.put('arRecord', '{"firstName": "Test","Id": "'+authRepAcc.Id +'", "lastName":"AR","email":"test@3gmail.com", "phone":"9999999999", "fax": "8888888888", "role": "Other", "Channel": "Fax"}');
        inputRecords.put('hcsRecord','{"name": "Test Pharma Enroll New Acc", "address1": "3309 Lakeshore Ave", "address2": "htgrfedws", "city": "Somerset", "state": "ID", "zipCode":"43342", "Channel": "Fax", "npi": "2345687654", "dea" :"tw5678767", "hin":"X21345673", "ncpdp":"5678845", "hcsType": "Institution Central Purchasing (owned or under control of hospital system)"}');
        inputRecords.put('programName', REMSAppLiterals.XIAFLEX_PROGRAM);
        Test.StartTest();
         String result = xiaflex_ManagePharmacies.insertHcsEnrollment(inputRecords,null);
        Test.StopTest();
        System.assertEquals('Success', result, 'Insert HCP Submit should return success.');
    }
    
      @isTest()
    public static void createNewAffiliation(){
        Account presAcc = [Select ID from Account where RecordType.Name = 'Prescriber' limit 1];
        Account pharmacyAcc = [Select ID from Account where RecordType.Name = 'Health Care Setting' limit 1];
        US_WSREMS__REMS_Program__c programObj = [Select Id, Name, US_WSREMS__Status__c, REMS_Project_Code__c from US_WSREMS__REMS_Program__c where Name = 'Xiaflex'];		
        US_WSREMS__Affiliation__c aff = createAffiliation(pharmacyAcc.Id, null, presAcc.Id, 'Prescriber Affiliation', programObj);
        Test.StartTest();
        xiaflex_ManagePharmacies.createNewAffiliation(aff, presAcc.Id, pharmacyAcc.Id);
        Test.StopTest();
    }
    
    @isTest()
        public static void removeAffiliations(){
        Account pharmacyAcc = [Select ID from Account where RecordType.Name = 'Health Care Setting' limit 1];
            User testUser = [Select Id, LastName from User where LastName = 'User' Limit 1];
        Map<String, String> inputRecords = new Map<String, String>();
           inputRecords.put('programName', 'Xiaflex');
           inputRecords.put('Id', pharmacyAcc.Id);
           inputRecords.put('CurrentuserID', testUser.Id);
        }
    @isTest
    static void updateAccount(){
        xiaflex_ManagePharmacies.RecordDataWrapper recordData = new xiaflex_ManagePharmacies.RecordDataWrapper();
        recordData.lastName = 'Test Last';
        recordData.firstName = 'Test First';
        List<US_WSREMS__REMS_Program__c> program = [Select Id, Name, US_WSREMS__Status__c, REMS_Project_Code__c from US_WSREMS__REMS_Program__c where Name = 'Xiaflex' Limit 1];	
        Account presAcc = [Select ID, FirstName, LastName, US_WSREMS__User_Type__c, Phone, PersonEmail, Fax, US_WSREMS__Role__c, US_WSREMS__Other__c from Account where RecordType.Name = 'Prescriber' limit 1];
        Account accountObj = createPharmaAcc('Test Pharma', '1234567890', program[0]);
        presAcc = xiaflex_ManagePharmacies.updateAccount(recordData, program, true, 'Prescriber');
        Id recordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('Prescriber Enrollment').getRecordTypeId();
        Case caseRec = xiaflex_ManagePharmacies.insertCase(recordData, presAcc, null, program, 'Prescriber', null, recordTypeId, true);
        xiaflex_ManagePharmacies.caseChangeARFields(caseRec, accountObj, presAcc, null);
    }
    
    @isTest()
    public static void getPrescriberLists(){
        String enrollId = 'someEnrollId'; 
        String firstName = 'Test'; 
        String lastName = 'Prescriber'; 
        String programType = 'REMS'; 
        list<Account> prescribedListAcc = xiaflex_ManagePharmacies.getPrescriberList(enrollId,firstName,lastName,programType);
        System.assertEquals(0, prescribedListAcc.size(), 'prescribedListAcc accounts should be returned.');
    }
    @isTest()
    public static void getPrescriberLists2(){
        String firstName = 'Test'; 
        String lastName = 'Prescriber'; 
        String programType = 'REMS'; 
        list<Account> prescribedListAcc = xiaflex_ManagePharmacies.getPrescriberList(null,firstName,lastName,programType);
        System.assertEquals(0, prescribedListAcc.size(), 'prescribedListAcc accounts should be returned.');
    }
    @isTest()
        public static void insertprescriberPharmaAffiliations(){
           Account authRepAcc = [Select ID from Account where RecordType.Name = 'Prescriber' limit 1];
            Account pharmacyAcc = [Select ID, Name from Account where Name ='TestPharmact' limit 1];
            Map<string, string> inputRecords = new Map<string, string>();
            inputRecords.put('prescriberId',authRepAcc.id);
            inputRecords.put('pharmaId', pharmacyAcc.Id);
            inputRecords.put('programName', 'Xiaflex');
           String result = xiaflex_ManagePharmacies.insertprescriberPharmaAffiliation(inputRecords);
            System.assertEquals('Success', result, ' US WSREMS Affiliation should return success.');
        }
    @isTest()
    public static void removeArAffiliations(){
        US_WSREMS__Affiliation__c Testaffiliation = [Select id,US_WSREMS__isActive__c from US_WSREMS__Affiliation__c where US_WSREMS__isActive__c = true limit 1];
        id recordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByName().get('Authorized Representative Affiliation').getRecordTypeId();
        User testUser = [Select Id, LastName from User where LastName = 'User' Limit 1];
        US_WSREMS__REMS_Program__c program = [Select Id, Name from US_WSREMS__REMS_Program__c Limit 1];
        Account prescriberAcc = [Select ID from Account where RecordType.Name = 'Prescriber' limit 1];
        Account pharmacyAcc = [Select ID, Name from Account where Name ='TestPharmact' limit 1];
        US_WSREMS__Affiliation__c affiliationRec = createAffiliation(prescriberAcc.Id, pharmacyAcc.Id, null, 'Prescriber Affiliation', program);
        insert affiliationRec;
         Map<string, string> inputRecords = new Map<string, string>(); 
        inputRecords.put('userId',testUser.id);
        inputRecords.put('pharmaId',pharmacyAcc.id);
        inputRecords.put('prescriberId',prescriberAcc.id);
        inputRecords.put('recordType', null);
        System.assertNotEquals(NUll, pharmacyAcc, 'Pharma accounts should be zero.');
        xiaflex_ManagePharmacies.removeArAffiliation(inputRecords);
        
    }
  	@isTest
	static void testInsertArEditEnroll() {
    Map<String, String> inputRecords = new Map<String, String>();
    Account authRepAcc = [Select ID from Account where RecordType.Name = 'Prescriber' limit 1];
    Account pharmacyAcc = [Select ID from Account where RecordType.Name = 'Health Care Setting' limit 1];
    inputRecords.put('arRecord', '{"firstName": "Test","Id": "'+authRepAcc.Id +'", "lastName":"AR","email":"test@3gmail.com", "phone":"9999999999", "fax": "8888888888", "role": "Other", "Channel": "Fax"}');
    inputRecords.put('hcsRecord','{"Id": "'+pharmacyAcc.Id+'", "name": "Test Pharma Enroll New Acc", "address1": "3309 Lakeshore Ave", "address2": "htgrfedws", "city": "Somerset", "state": "ID", "zipCode":"43342", "Channel": "Fax", "npi": "2345687654", "dea" :"tw5678767", "hin":"X21345673", "ncpdp":"5678845", "hcsType": "Institution Central Purchasing (owned or under control of hospital system)"}');
    inputRecords.put('programName', 'Xiaflex');
    inputRecords.put('reenroll', 'false');
    
    Test.StartTest();
    String result = xiaflex_ManagePharmacies.insertArEditEnroll(inputRecords);
    System.assertEquals('Success', result, 'Insert Ar Edit Enroll should return success when reenroll is false.');
    
    inputRecords.put('reenroll', 'true');
    inputRecords.put('signatureData', 'someBase64Content');
    result = xiaflex_ManagePharmacies.insertArEditEnroll(inputRecords);
    System.assertEquals('Success', result, 'Insert Ar Edit Enroll should return success when reenroll is true.');
    
    inputRecords.put('arRecord', null);
    try {
        xiaflex_ManagePharmacies.insertArEditEnroll(inputRecords);
        System.assert(false, 'Expected AuraHandledException');
    } catch (AuraHandledException e) {
        System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected error message');
    }

    inputRecords.put('arRecord', '{"firstName": "Test","Id": "'+authRepAcc.Id +'", "lastName":"AR","email":"test@3gmail.com", "phone":"9999999999", "fax": "8888888888", "role": "Other", "Channel": "Fax"}');
    inputRecords.put('hcsRecord', null);
    try {
        xiaflex_ManagePharmacies.insertArEditEnroll(inputRecords);
        System.assert(false, 'Expected AuraHandledException');
    } catch (AuraHandledException e) {
        System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected error message');
    }
    Test.StopTest();
}
    
    public static US_WSREMS__Affiliation__c createAffiliation(Id arId, Id hcsId, Id presId, String recordType, US_WSREMS__REMS_Program__c program){
        Id recordTypeId = Schema.sObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        US_WSREMS__Affiliation__c affiliatedAcc = new US_WSREMS__Affiliation__c();
        affiliatedAcc.RecordTypeId = recordTypeId;
        affiliatedAcc.US_WSREMS__REMSProgram__c = program.Id;
        affiliatedAcc.US_WSREMS__isActive__c = true;
        affiliatedAcc.US_WSREMS__Start_Date__c = System.Today();
        if(recordType == 'Healthcare Setting Affiliation' || recordType == 'Prescriber Affiliation'){
            affiliatedAcc.US_WSREMS__Prescriber__c = presId;
        } else if(recordType == 'Authorized Representative Affiliation'){
            affiliatedAcc.US_WSREMS__Authorized_Representative__c = arId;
        }
        affiliatedAcc.US_WSREMS__Health_Care_Setting__c = hcsId;
        return affiliatedAcc;
    }
    
    	public static Account createPharmaAcc(String name, String npiValue, US_WSREMS__REMS_Program__c program) {
        Account pharmaAcc = new Account();
        Id recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Health Care Setting').getRecordTypeId();
        pharmaAcc.Name = name;
        pharmaAcc.US_WSREMS__Address_Line_1__c = '#12 Street';
        pharmaAcc.US_WSREMS__City__c = 'test city';
        pharmaAcc.US_WSREMS__State__c = 'ID';
        pharmaAcc.US_WSREMS__Zip__c = '21231';
        pharmaAcc.US_WSREMS__National_Provider_Identifier__c = npiValue;
        pharmaAcc.US_WSREMS__REMS_Program__c= program.Id;
        return pharmaAcc;
    }
    
    
}