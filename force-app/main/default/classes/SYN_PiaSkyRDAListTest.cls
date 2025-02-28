/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-28-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SYN_PiaSkyRDAListTest {

    @testSetup
    static void setup() {

        List<User> adminUsers = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND UserRoleId != NULL  AND IsActive = TRUE Limit 1];

        if( adminUsers != NULL && adminUsers.size() > 0 ){

           system.runAs(adminUsers[0]){
                List<sObject> insertObjects = new List<sObject>();
                // Create a test profile
                Account account = new Account(Name = 'test123');
                insert account;

                Contact contact = new Contact(LastName = 'Contact Last Name', AccountId = account.Id);
                insert contact;

                User communityUser = new User(
                        Username = 'testpharmacyyy@test.com',
                        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Portal User'].Id,
                        ContactId = contact.Id,
                        Email = 'test@test.com',  // Set the email as username for simplicity
                        Alias = 'test@test.com'.substring(0, 8),  // Set an alias
                        EmailEncodingKey = 'UTF-8',
                        IsActive = true,
                        LastName = 'CommunityUser',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        PortalRole = 'PersonAccount'
                    );
                insert CommunityUser;

                Program_Fax_Configuration__mdt[] prgfax = [SELECT MasterLabel, QualifiedApiName, REMS_Program__c ,Fax_Number__c FROM Program_Fax_Configuration__mdt where Active__c=true];
                US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c (
                Name = 'PiaSky REMS',
                US_WSREMS__Status__c  = 'Active',
                REMS_Project_Code__c = 'BT1005',
                US_WSREMS__Program_State_Date__c  = System.today(),
                US_WSREMS__Program_End_Date__c  = System.today().addDays(20));
                insert programObj;
                
                id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outpatient Pharmacy').getRecordTypeId();
                id recordTypeIdPharmacy1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
                Account pharmCParticipanAccount = new Account(           
                        Name = 'testname',
                        US_WSREMS__REMS_Program__c = programObj.Id,
                        RecordTypeId = recordTypeIdPharmacyParticipant,
                        Industry = 'Banking',
                        US_WSREMS__Channel__c = 'fax',
                        US_WSREMS__Status__c ='Certified'
                        );
                insert pharmCParticipanAccount;
                Account pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy1);  

                id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
                Account prescriberAccount = SYN_TestDataUtility.createPrescriberAccountWithNPIemail(programObj.Id, recordTypeId);
                prescriberAccount.US_WSREMS__Email__c = 'test@example.com';
                prescriberAccount.US_WSREMS__Status__c ='Certified';
                update prescriberAccount;
                
                Id PDARecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get('REMS Dispense Authorization').getRecordTypeId();
                US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c(
                US_WSREMS__REMSProgram__c = programObj.Id,
                US_WSREMS__Expiration_Date__c = system.today(),
                US_WSREMS__Path_Stage_Name__c ='Intake',
                US_WSREMS__Requestor_Type__c ='Outpatient Pharmacy',
                US_WSREMS__Participant__c = pharmCParticipanAccount.Id,
                recordTypeId = PDARecordTypeId);
                insert serviceObj;
                
                Id recordTypeIdPharmacy = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
                US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c(           
                    US_WSREMS__Pharmacy__c = pharmCParticipanAccount.Id,
                    US_WSREMS__Pharmacy_User__c = account.Id,
                    US_WSREMS__REMSProgram__c= programObj.Id,
                    RecordTypeId=recordTypeIdPharmacy,
                    AR_Category__c='Primary',
                    US_WSREMS__isActive__c = true);
                insert affiliationRecord;
            }
        }
    }
	
    @isTest
    public static void createCaseandServiceTest() {
        Account prescriberAccount = [SELECT Id,LastName from Account WHERE US_WSREMS__Email__c = 'test@example.com' LIMIT 1];
        US_WSREMS__Affiliation__c aff  = [Select Id,US_WSREMS__Pharmacy_User__c, US_WSREMS__Pharmacy__r.US_WSREMS__Status__c,US_WSREMS__isActive__c,US_WSREMS__Pharmacy__c from US_WSREMS__Affiliation__c WHERE AR_Category__c='Primary' LIMIT 1];
        String prescriberFName = 'Test';
        String prescriberLName = 'Test1';
        String prescriberNPI = '1234567901';
        String remsId = '0054273';
        String result;
        User u = [Select id from USer where UserName='testpharmacyyy@test.com'];
        System.runAs(u) {
            test.startTest();
            try{
                result = SYN_PiaSkyRDAList.createCaseandService(prescriberAccount.Id, prescriberFName, prescriberLName, prescriberNPI, remsId);
                System.assert(result != null); 
            } catch(exception ex){
                system.debug('Exception...'+ex);
            }
            test.stopTest();
    	}
    }

    @isTest
    static void testGetLoggedInUserAccountDetails() {
         Account account = new Account(Name = 'test123');
         insert account;
         Contact contact = new Contact(LastName = 'Contact Last Name', AccountId = account.Id);
         insert contact;
         User testUser = new User(
                        Username = 'testpharmacyyy@test2.com',
                        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Portal User'].Id,
                        ContactId = contact.Id,
                        Email = 'test@test.com',  // Set the email as username for simplicity
                        Alias = 'test@test.com'.substring(0, 8),  // Set an alias
                        EmailEncodingKey = 'UTF-8',
                        IsActive = true,
                        LastName = 'CommunityUser',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        PortalRole = 'PersonAccount'
                    );
          insert testUser;
          SYN_PiaSkyRDAList.loggedinUserWrapper wrapper = new SYN_PiaSkyRDAList.loggedinUserWrapper();
          System.runAs(testUser) {
            Test.startTest();
            wrapper = SYN_PiaSkyRDAList.loggedinUserDetails();
            Test.stopTest();
           }
        System.assert(wrapper != null); 
    }
    
    @isTest
    static void checkLoggedinUserDetailsTest() {
         Account account = new Account(Name = 'test123');
         insert account;
         Contact contact = new Contact(LastName = 'Contact Last Name', AccountId = account.Id);
         insert contact;
         User testUser = new User(
                        Username = 'testpharmacyyy@test3.com',
                        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Portal User'].Id,
                        ContactId = contact.Id,
                        Email = 'test@test.com',  // Set the email as username for simplicity
                        Alias = 'test@test.com'.substring(0, 8),  // Set an alias
                        EmailEncodingKey = 'UTF-8',
                        IsActive = true,
                        LastName = 'CommunityUser',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        PortalRole = 'PersonAccount'
                    );
         insert testUser;
         Boolean showButton;
         System.runAs(testUser) {
            Test.startTest();
            showButton = SYN_PiaSkyRDAList.checkLoggedinUserDetails();
            Test.stopTest();
        }
        System.assertEquals(true, showButton); 
    }
    
    @isTest
    private static void loggedOutUserTest() {
       Account account = new Account(Name = 'test123');
       insert account;
       Contact contact = new Contact(LastName = 'Contact Last Name', AccountId = account.Id);
       insert contact;
       User testUser = new User(
                        Username = 'testpharmacyyy@test4.com',
                        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Portal User'].Id,
                        ContactId = contact.Id,
                        Email = 'test@test.com',  // Set the email as username for simplicity
                        Alias = 'test@test.com'.substring(0, 8),  // Set an alias
                        EmailEncodingKey = 'UTF-8',
                        IsActive = true,
                        LastName = 'CommunityUser',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        PortalRole = 'PersonAccount'
                    );
        insert testUser;
        String session;
        System.runAs(testUser) {
            Test.startTest();
            session = SYN_PiaSkyRDAList.loggedOutUser();
            Test.stopTest();
        }
       System.assertEquals('delete', session); 
    }
    
     @isTest
    public static void checkRDACasesTest() {
       Account account = new Account(Name = 'test123');
       insert account;
       Contact contact = new Contact(LastName = 'Contact Last Name', AccountId = account.Id);
       insert contact;
       User communityUser = new User(
                        Username = 'testpharmacyyy@test55.com',
                        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Portal User'].Id,
                        ContactId = contact.Id,
                        Email = 'test@test.com',  // Set the email as username for simplicity
                        Alias = 'test@test.com'.substring(0, 8),  // Set an alias
                        EmailEncodingKey = 'UTF-8',
                        IsActive = true,
                        LastName = 'CommunityUser',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        PortalRole = 'PersonAccount'
                    );
         insert communityUser;
        // Retrieve the test account
        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'test123'LIMIT 1];
        List<Case> caseList;
        US_WSREMS__Affiliation__c aff  = [Select Id,US_WSREMS__Pharmacy_User__c, US_WSREMS__Pharmacy__r.US_WSREMS__Status__c,US_WSREMS__isActive__c,US_WSREMS__Pharmacy__c from US_WSREMS__Affiliation__c WHERE AR_Category__c='Primary' LIMIT 1];
        System.runAs(communityUser) { 
            test.startTest();
            caseList = SYN_PiaSkyRDAList.getCaseRDA();
            test.stopTest();
    	} 
    } 
}