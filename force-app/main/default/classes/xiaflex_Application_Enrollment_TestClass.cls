/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class xiaflex_Application_Enrollment_TestClass {
    @TestSetup
    static void setupData() {
        // Create Program record
        US_WSREMS__REMS_Program__c program = SYN_TestDataUtility.createProgram('XIAFLEX', 'Active');
        // Create Record Types
        RecordType prescriberRT = [SELECT Id FROM RecordType WHERE Name = 'Prescriber' AND SobjectType = 'Account' LIMIT 1];
        RecordType healthcareRT = [SELECT Id FROM RecordType WHERE Name = 'Health Care Setting' AND SobjectType = 'Account' LIMIT 1];
        // Create Prescriber Account
        Account prescriberAccount = new Account();
        prescriberAccount.FirstName = 'PrescriberFname';
        prescriberAccount.LastName = 'PrescriberLname';
        prescriberAccount.RecordTypeId = prescriberRT.Id;
        prescriberAccount.US_WSREMS__REMS_Program__c = program.Id;
        prescriberAccount.US_WSREMS__REMS_ID__c = '1234567890';
        prescriberAccount.US_WSREMS__Status__c = 'Pending';
        insert prescriberAccount;
       
        // Create Healthcare Account
        Account healthcareAccount = new Account();
        healthcareAccount.Name = 'Healthcare Test Acc';
        healthcareAccount.RecordTypeId = healthcareRT.Id;
        healthcareAccount.US_WSREMS__REMS_Program__c = program.Id;
        healthcareAccount.US_WSREMS__REMS_ID__c = '0987654321';
        prescriberAccount.US_WSREMS__Status__c = 'Pending';
 
        insert healthcareAccount;
    }
   
    @isTest
    public static void testGetAutharisedRepAccount() {
        String validARRecord = '{"FirstName":"Test","LastName":"Pharmacy"}';
        String validARRecordWithEmail = '{"FirstName":"Test","LastName":"Pharmacy", "Email":"test@pharmacy.com"}';
       
        // Call the method with valid data
        Account result1 = xiaflex_Application_Enrollment_Class.getDuplicate(validARRecord,'REMS');
        Account result2 = xiaflex_Application_Enrollment_Class.getDuplicate(validARRecordWithEmail,'REMS');
 
         System.assertEquals(null,result1, 'AR account should not be null');
        System.assertEquals(null,result2, 'AR account should not be null');
       
    }
   
    @isTest
    public static void testGetLoggedInUserAccount() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User'].Id;
        String npiValue = '1234567890';
 
        // Create Account
        Account testAccount = createAccount('Test Account Portal', npiValue);
        insert testAccount;
 
        // Create Contact
        Contact testContact = createContact('Test', 'Contact', 'test@gmail.com', testAccount.Id);
        insert testContact;
 
        // Create Community User
        User communityUser = createCommunityUser(testContact.Id, profileId, 'Test', 'User');
        insert communityUser;
 
        // Call the method
        Account result = xiaflex_Application_Enrollment_Class.getLoggedInUserAccount(communityUser.Id);
       System.assert(result != null, 'Logged in user account should not be null');
    }
   
    @isTest
    public static void testGetAccountRecordForSearch() {
        String searchValue = 'Test';
        String participantType1 = 'Healthcare';
        String participantType2 = 'Prescriber';
 
        List<Account> result1 = xiaflex_Application_Enrollment_Class.getAccountRecordForSearch(searchValue, participantType1,'REMS');
        List<Account> result2 = xiaflex_Application_Enrollment_Class.getAccountRecordForSearch(searchValue, participantType2,'REMS');
        // Add assertions
        System.assertEquals(0,result1.size(), 'Account records should be found for healthcare participant type');
        System.assertEquals(0,result2.size(), 'Account records should be found for prescriber participant type');
    }
   
    @isTest
    public static void testGetPicklistFieldValues() {
         // Call the method to get picklist values
        Map<String, Map<String, String>> result = xiaflex_Application_Enrollment_Class.getPicklistFieldValues();
 
        // Add assertions
        System.assert(result != null, 'Picklist values should not be null');
        System.assert(result.size() > 0, 'Picklist values should be found');
    }
   
    @isTest
    static void testInsertHCPData() {
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name FROM US_WSREMS__REMS_Program__c WHERE Name = 'Xiaflex' LIMIT 1];
        xiaflex_NPISearchControllerPortal.RecordDataWrapper recordData = new xiaflex_NPISearchControllerPortal.RecordDataWrapper();
        recordData.firstName = 'Test';
        recordData.lastName = 'Portal';
        recordData.email = 'TestPortal@example.com';
        recordData.phone = '1234567890';
        recordData.fax = '123-456-7891';
        recordData.npi = '1234567890';
        recordData.participantType = 'Prescriber';
        recordData.PMC = 'Email';
        recordData.hcsEmail = 'test@example.com';
        recordData.name = 'TestPortal';
        recorddata.DEA='';
        Account prescriberAccount = SYN_TestDataUtility.createPrescriberPersonAccount(program[0].Id);
         RecordType recType =  [Select Name, SobjectType, Id from RecordType where Name = 'Prescriber Person Account' LIMIT 1];
 
                    US_WSREMS__REMS_Service_Summary__c service  = xiaflex_NPISearchControllerPortal.insertServiceSummary(prescriberAccount, program, REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER, REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
                    Case caseRec = xiaflex_NPISearchControllerPortal.insertCase( recordData, prescriberAccount, service,program,'Prescriber_Person_Account',null ,REMSAppLiterals.REQUESTORTYPE_PHARMACY_HCS_PARTICIPANT, recType.id);                
      //  update prescriberAccount;
        // Prepare data
        case abc = new case();
        xiaflex_ManagePharmacies.caseChangeARFields(caseRec,prescriberAccount,prescriberAccount,prescriberAccount);
       
        Test.startTest();
              case case1  = xiaflex_NPISearchControllerPortal.insertCase( recordData, prescriberAccount, service,program,'Prescriber_Person_Account',null ,REMSAppLiterals.REQUESTORTYPE_PHARMACY_HCS_PARTICIPANT, recType.id);                
               xiaflex_ManagePharmacies.caseChangeARFields(case1,prescriberAccount,prescriberAccount,prescriberAccount);
 
        Test.stopTest();
       
    }
   
   
   
  @isTest
   static void createChangeOfInfoCaseAndService(){
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name FROM US_WSREMS__REMS_Program__c WHERE Name = 'Xiaflex'];
        xiaflex_ManagePharmacies.RecordDataWrapper recordData = new xiaflex_ManagePharmacies.RecordDataWrapper();
        recordData.firstName = 'Test';
        recordData.lastName = 'Portal';
        recordData.email = 'TestPortal@example.com';
        recordData.phone = '1234567890';
        recordData.fax = '123-456-7891';
        recordData.npi = '1234567890';
        recordData.participantType = 'Prescriber';
        recordData.name = 'TestPortal';
        recorddata.DEA='';
        Account prescriberAccount = SYN_TestDataUtility.createPrescriberPersonAccount(program[0].Id);
        xiaflex_Application_Enrollment_Class.createChangeOfInfoCaseAndService(recordData, prescriberAccount, program, 'Prescriber', 'Presceriber', 'REMS');
    }
    
    @isTest()
    public static void insertEnrollment2(){
        Map<String, String> inputRecords = new Map<String, String>();
        Account hcpRecord = [SELECT Id FROM Account WHERE RecordType.Name = 'Prescriber' limit 1];
        Account pharmacyAcc = [SELECT Id FROM Account WHERE RecordType.Name = 'Health Care Setting' limit 1];
        inputRecords.put('prescriberRecord', '{"firstName": "Test", "lastName":"AR","email":"test@3gmail.com", "phone":"9999999999", "fax": "8888888888", "Channel": "Fax"}');
        inputRecords.put('hcsRecord','{"Id": "'+pharmacyAcc.Id+'", "name": "Test Pharma Enroll New Acc", "address1": "3309 Lakeshore Ave", "address2": "htgrfedws", "city": "Somerset", "state": "ID", "zipCode":"43342", "Channel": "Fax", "npi": "2345687654", "dea" :"tw5678767", "hin":"X21345673", "ncpdp":"5678845", "hcsType": "Institution Central Purchasing (owned or under control of hospital system)"}');
        inputRecords.put('programName', REMSAppLiterals.XIAFLEX_PROGRAM);
        inputRecords.put('programType', REMSAppLiterals.XIAFLEX_MDP_PRO_TYPE);
        xiaflex_Application_Enrollment_Class.getHCPRecordForSearch('Test',REMSAppLiterals.XIAFLEX_MDP_PRO_TYPE);
        String result = xiaflex_Application_Enrollment_Class.insertHCPData(inputRecords);
        Test.StopTest();
        System.assertEquals('Success', result, 'Insert HCP Submit should return success.');
    }
    
    @isTest()
    public static void insertEnrollment3(){
        Map<String, String> inputRecords = new Map<String, String>();
        Account hcpRecord = [SELECT Id from Account WHERE RecordType.Name = 'Prescriber' LIMIT 1];
        Account pharmacyAcc = [SELECT Id from Account WHERE RecordType.Name = 'Health Care Setting' LIMIT 1];
        inputRecords.put('prescriberRecord', '{"firstName": "Test", "lastName":"AR","email":"test@3gmail.com", "phone":"9999999999", "fax": "8888888888", "Channel": "Fax"}');
        inputRecords.put('hcsRecord','{ "name": "Test Pharma Enroll New Acc", "address1": "3309 Lakeshore Ave", "address2": "htgrfedws", "city": "Somerset", "state": "ID", "zipCode":"43342", "Channel": "Fax", "npi": "2345687654", "dea" :"tw5678767", "hin":"X21345673", "ncpdp":"5678845", "hcsType": "Institution Central Purchasing (owned or under control of hospital system)"}');
        inputRecords.put('programName', REMSAppLiterals.XIAFLEX_PROGRAM);
        inputRecords.put('programType', REMSAppLiterals.XIAFLEX_MDP_PRO_TYPE);
        String result = xiaflex_Application_Enrollment_Class.insertHCPData(inputRecords);
        Test.StopTest();
        System.assertEquals('Success', result, 'Insert HCP Submit should return success.');
    }
   
    // Helper Methods
    public static User createCommunityUser(String contactId, String profileId, String firstName, String lastName) {
        User user = new User(
            FirstName = firstName,
            LastName = lastName,
            Alias = lastName,
            Email = 'test+' + contactId + '@example.com',
            Username = 'test+' + contactId + '@example.com',
            ContactId = contactId,
            ProfileId = profileId,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        return user;
    }
    
   
    public static Account createAccount(String name, String npiValue) {
        return new Account(Name = name, US_WSREMS__NPI__c = npiValue);
    }
   
    public static Contact createContact(String firstName, String lastName, String email, String accountId) {
        return new Contact(FirstName = firstName, LastName = lastName, Email = email, AccountId = accountId);
    }
}