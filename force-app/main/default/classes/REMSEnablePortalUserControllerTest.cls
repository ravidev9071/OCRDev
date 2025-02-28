@isTest
public with sharing class REMSEnablePortalUserControllerTest {
    @testSetup
    public static void createTestData(){
        
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'testuser62'+ System.now().millisecond() + '@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);
        
        System.runAs ( portalAccountOwner1 ){
            //Record type creation
            String recordTypePrescriberId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId(); 
            
            //Program Creation
            US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
            programObj.Name = 'Sodium Oxybate REMS';
            programObj.US_WSREMS__Status__c ='Active';
            programObj.US_WSREMS__Program_State_Date__c = System.today();
            programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
            Insert programObj;
            //Prescriber Account Creation
            Account accObj = new Account();
            accObj.FirstName = 'Test New';
            accObj.LastName = 'Portal Prescriber';
            accObj.US_WSREMS__REMS_Program__c = programObj.Id;
            accObj.US_WSREMS__Email__c = 'portalprescriber@gmail.com';
            accObj.US_WSREMS__Status__c = 'Certified';
            accObj.RecordTypeId = recordTypePrescriberId;
            accObj.OwnerId=portalAccountOwner1.Id;
            insert accObj;
        }
    }
        
        @isTest
        static void portalUserCreationTest()
        {
            Account accObj = [Select Id From Account Where FirstName =: 'Test New'];
            Test.startTest();
            REMSEnablePortalUserController.portalUserCreation(accObj.Id);
            Test.stopTest();
        }
    
}