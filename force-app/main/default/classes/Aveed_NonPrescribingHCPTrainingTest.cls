@IsTest
public class Aveed_NonPrescribingHCPTrainingTest {
    
    @TestSetup
    static void setupData() {
        List<sObject> insertObjects = new List<sObject>();
        US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c ();
        programObj.Name = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        programObj.US_WSREMS__Status__c = 'Active';
        programObj.REMS_Project_Code__c = 'BT1005';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insertObjects.add(programObj);
        insert insertObjects;
    }
    
    @IsTest
    public static void test_getPicklistFieldValues() {
        Test.startTest();
        Map<String, Map<String, String>> statePickListValueMap = Aveed_NonPrescribingHCPTrainingCtrl.getPicklistFieldValues();
        Test.stopTest();
        Assert.isTrue(statePickListValueMap != null && !statePickListValueMap.isEmpty());
    }
    
    @IsTest
    public static void test_checkDuplicateAccounts_valid() {
        Id recordTypeId;
        List<RecordType> accountRecordTypes = [SELECT Id, Name, DeveloperName, SobjectType, IsActive, NamespacePrefix FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'General_Contact' AND NamespacePrefix = 'US_WSREMS'];
        if (accountRecordTypes != null && !accountRecordTypes.isEmpty()) {
            recordTypeId = accountRecordTypes.get(0).Id;
        }
        List<US_WSREMS__REMS_Program__c> programs = [SELECT Id, Name FROM US_WSREMS__REMS_Program__c];
        //Create Account
        Account testAccount = SYN_TestDataUtility.createAccount(programs.get(0).Id, recordTypeId, 'Test Accout', 'Last');
        testAccount.PersonEmail = 'testingacc@test.com';
        update testAccount;
        Test.startTest();
        Map<String, String> inputRecords = new Map<String, String>();
        inputRecords.put('programName', programs.get(0).Name);
        Map<String, String> recordDetailsMap = new Map<String, String>();
        recordDetailsMap.put('firstName', 'Test Acc');
        recordDetailsMap.put('lastName', 'Last');
        recordDetailsMap.put('email', 'testingacc@test.com');
        inputRecords.put('recordDetails', System.JSON.serialize(recordDetailsMap));
        Boolean hasDuplicate = Aveed_NonPrescribingHCPTrainingCtrl.checkDuplicateAccounts(inputRecords, 'General_Contact');
        Test.stopTest();
        
        Assert.areEqual(true, hasDuplicate);
    }
    
    @IsTest
    public static void test_checkDuplicateAccounts_invalid() {
        Id recordTypeId;
        List<RecordType> accountRecordTypes = [SELECT Id, Name, DeveloperName, SobjectType, IsActive, NamespacePrefix FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'General_Contact' AND NamespacePrefix = 'US_WSREMS'];
        if (accountRecordTypes != null && !accountRecordTypes.isEmpty()) {
            recordTypeId = accountRecordTypes.get(0).Id;
        }
        List<US_WSREMS__REMS_Program__c> programs = [SELECT Id, Name FROM US_WSREMS__REMS_Program__c];
        //Create Account
        Account testAccount = SYN_TestDataUtility.createAccount(programs.get(0).Id, recordTypeId, 'Test Person', 'Account');
        testAccount.PersonEmail = 'testingacc@yopmail.com';
        update testAccount;
        Test.startTest();
        Map<String, String> inputRecords = new Map<String, String>();
        inputRecords.put('programName', programs.get(0).Name);
        Map<String, String> recordDetailsMap = new Map<String, String>();
        recordDetailsMap.put('firstName', 'Test');
        recordDetailsMap.put('lastName', 'Last');
        recordDetailsMap.put('email', 'test@test.com');
        inputRecords.put('recordDetails', System.JSON.serialize(recordDetailsMap));
        Boolean hasDuplicate = Aveed_NonPrescribingHCPTrainingCtrl.checkDuplicateAccounts(inputRecords, 'General_Contact');
        Test.stopTest();
        
        Assert.isFalse(hasDuplicate);
        Assert.areNotEqual(true, hasDuplicate);
    }
    
    @IsTest
    public static void test_createNonPrescribingCaseAccountCreation() {
        Test.startTest();
        Aveed_NonPrescribingHCPTrainingCtrl.RecordDataWrapper wrapper = new Aveed_NonPrescribingHCPTrainingCtrl.RecordDataWrapper();
        wrapper.addressLine1 = '27 Lakeview';
        wrapper.addressLine2 = 'Drive';
        wrapper.city = 'Shelton';
        wrapper.degree = 'MD';
        wrapper.phone = '9876543210';
        wrapper.state = 'CT';
        wrapper.zipCode = '00046';
        wrapper.email = 'testingacc@yopmail.com';
        wrapper.firstName = 'Test Acc';
        wrapper.lastName = 'Last';
        Aveed_NonPrescribingHCPTrainingCtrl.AccountCreationDetails details = Aveed_NonPrescribingHCPTrainingCtrl.createNonPrescribingCaseAccountCreation(System.JSON.serialize(wrapper));
        Test.stopTest();
        
        Assert.isTrue(details.isCreated);
        Assert.isTrue(String.isNotBlank(details.notificationMsg));
    } 

}