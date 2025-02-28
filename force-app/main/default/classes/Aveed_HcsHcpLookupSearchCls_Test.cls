@isTest
public class Aveed_HcsHcpLookupSearchCls_Test {
    
    @isTest
    public static void getPrescriberAccounts() {
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c ();
        programObj.Name = 'AVEED REMS';
        programObj.US_WSREMS__Status__c  ='Active';
        programObj.US_WSREMS__Program_State_Date__c  = System.today();
        programObj.US_WSREMS__Program_End_Date__c  = System.today().addDays(20);
        programList.add(programObj);
        insert programList; 
        Account participantAccount = SYN_TestDataUtility.createAccount(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId(), 'test', 'prescriber');
        participantAccount.US_WSREMS__City__c = 'NA';
        Update participantAccount;
        
        List<SObject> certifiedAccTest;
        Test.starttest();
        certifiedAccTest = Aveed_HcsHcpLookupSearchCls.searchRecordsForLocator('NA', 'Prescribing');
        Test.stoptest();
        
        System.Assert(certifiedAccTest != null);
    }
    
    @IsTest
    public static void getHCSRecords() {
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c ();
        programObj.Name = 'AVEED REMS';
        programObj.US_WSREMS__Status__c  ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c  = System.today().addDays(20);
        programList.add(programObj);
        insert programList;
        Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(REMSAppLiterals.ACCOUNT_RECORDTYPE_HEALTHCARESETTING);
        Account newAccount = new Account();
        newAccount.Name = 'New HCS Test';
        newAccount.US_WSREMS__Address_Line_1__c = '123 Main Street';
        newAccount.US_WSREMS__Address_Line_2__c = '2nd Lane';
        newAccount.US_WSREMS__City__c = 'Philadelphia';
        newAccount.US_WSREMS__State__c = 'PA';
        newAccount.US_WSREMS__Zip__c = '99999';
        newAccount.RecordTypeId = recordTypeId;
        newAccount.US_WSREMS__REMS_Program__c = programList[0].Id;
        newAccount.US_WSREMS__Program_Picklist__c = (programList != null && !programList.isEmpty()) ? programList.get(0).Name : SYN_Utilitycls.AVEED_PROGRAM_NAME;
        newAccount.US_WSREMS__Status__c = 'Certified';
        insert newAccount;
        
        List<SObject> certifiedAccTest;
        Test.starttest();
        certifiedAccTest = Aveed_HcsHcpLookupSearchCls.searchRecordsForLocator('PA', 'HealthcareSetting');
        Test.stoptest();
        
        System.Assert(certifiedAccTest != null);
    }
}