@isTest
public class PiaSky_PrescriberVerificationContlrTest {
    public static final Map<String, Schema.RecordTypeInfo> mapAccountRcTyByDevName =
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();	
    Static ID TestPrescriberIdStore;
    
    @testSetup
    static void setup() {
         string AccRecordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('PiaSky REMS', 'Active');
        programObj.REMS_Project_Code__c = '13231';
        update programObj;
        Account providerAccount = SYN_TestDataUtility.createAccount(programObj.Id,AccRecordTypeId,'TestProviderFristNamekl','TestProviderLastNamekla');
        providerAccount.US_WSREMS__Email__c = 'testpharmacy@tesb.com';
        update providerAccount;
        List<Account> personAccList = [SELECT Id, PersonContactId, US_WSREMS__REMS_ID__c FROM Account WHERE Id = :providerAccount.Id];
        Id serviceRecordType = Schema.sObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get('Participant Account Creation').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c service =  SYN_TestDataFactory.createService(true,programObj.Id,serviceRecordType);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='PiaSky Portal Profile' LIMIT 1];
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
            US_WSREMS__REMS_Program__c = programObj.Name
        );
        insert testUser;
      
        US_WSREMS__Program_Users__c prgUSer =  new US_WSREMS__Program_Users__c();
        prgUser.US_WSREMS__Is_Active__c = true;
        prgUSer.US_WSREMS__REMS_Program__c = programObj.id;
        prgUSer.US_WSREMS__User__c = testUser.id;
        insert prgUser;
        Id idRTforREMSService = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c').get('Pre_Dispense_Authorization');

        US_WSREMS__REMS_Program_Service_Config__c serviceConfig = new US_WSREMS__REMS_Program_Service_Config__c();
        serviceConfig.US_WSREMS__REMS_Program__c = programObj.id;
        serviceConfig.US_WSREMS__Service_Name__c = 'REMS Dispense Authorization';
        serviceConfig.US_WSREMS__Service_API_Name__c = idRTforREMSService;
        serviceConfig.US_WSREMS__Applicable_Services_Account__c = 'Outpatient Pharmacy;Pharmacy';
        serviceConfig.US_WSREMS__Applicable_Channel__c = 'Portal';
        insert serviceConfig;
        Id providerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outpatient Pharmacy').getRecordTypeId();
        Account pharmacyAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id, providerRecTypeId);
        US_WSREMS__Affiliation__c affiliatedAcc = new US_WSREMS__Affiliation__c();
        affiliatedAcc.RecordTypeId = Schema.sObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByName().get('Pharmacy User Affiliation').getRecordTypeId();
        affiliatedAcc.US_WSREMS__REMSProgram__c = programObj.Id;
        affiliatedAcc.US_WSREMS__Pharmacy__c = pharmacyAccount.id;
        affiliatedAcc.US_WSREMS__IsActive__c = true;
        affiliatedAcc.US_WSREMS__Pharmacy_User__c = providerAccount.Id;
        affiliatedAcc.US_WSREMS__Start_Date__c = System.Today();
        affiliatedAcc.US_WSREMS__isActive__c = true;
        Insert affiliatedAcc;
        // Create test data for Accounts
        List<Account> accounts = new List<Account>();
        Account acc1 = new Account(
            recordtypeId = mapAccountRcTyByDevName.get('Prescriber').getRecordTypeId(),
            LastName = 'Smith',
            FirstName = 'John',
            US_WSREMS__Status__c = 'Pending',
            US_WSREMS__NPI__c = '1234567890',
            US_WSREMS__REMS_Program__c = programObj.id
        );
        insert acc1;
        TestPrescriberIdStore = acc1.Id;
    }
    
    @isTest
    static void testGetPrescriberDetails() {
        US_WSREMS__REMS_Program__c programobj1 = [Select id,name from US_WSREMS__REMS_Program__c where name = 'Piasky REMS'];  
        Account acc23 = new Account(
            recordtypeId = mapAccountRcTyByDevName.get('Prescriber').getRecordTypeId(),
            LastName = 'Doe',
            FirstName = 'Jane',
            US_WSREMS__NPI__c = '0987654321',
            US_WSREMS__Status__c = 'Pending',
            US_WSREMS__REMS_Program__c = programObj1.id
        );
        
        insert acc23;
        
        Test.startTest();
        List<Account> result = PiaSky_PrescriberVerificationController.getPrescriberList('1234567890', '', '', '');
        List<Account> result1 = PiaSky_PrescriberVerificationController.getPrescriberList('', 'Jane', 'Doe', 'CA');
        List<Account> result2 = PiaSky_PrescriberVerificationController.getPrescriberList('', '', '', '');        
        Account result3 = PiaSky_PrescriberVerificationController.getPrescriberById(acc23.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getOupPatientPharmacy(){
       
        String returnVal;
          user testuser = [select id,name from user where email = 'testuser@example.com'];
        PermissionSet assignPermission = [SELECT Id FROM PermissionSet WHERE Name = 'PIASKY_Portal_PermissionSet'];
		insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = assignPermission.Id);
        
        List<US_WSREMS__REMS_Program__c> programss =  new List<US_WSREMS__REMS_Program__c>();
        US_WSREMS__REMS_Program__c programobj = [Select id,name from US_WSREMS__REMS_Program__c where name = 'Piasky REMS'];
        programss.add(programObj);
        system.runAs(testUser){
            PiaSky_PrescriberVerificationController.checkOutpatientPharmacy(testUser.Id);
             returnVal  = PiaSky_PrescriberVerificationController.getOutpatientPharmacy(testUser.Id, '4545454545', null, null, null);
            
        }
    }
    
}