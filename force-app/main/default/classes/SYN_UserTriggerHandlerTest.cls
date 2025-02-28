@isTest
public class SYN_UserTriggerHandlerTest {
    Public static testmethod void testmethod1(){
       US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        /*
         Id prescriberRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Id PharmacyParticipantRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        
        account acc = new account();
        acc.LastName = 'Test Account';
        acc.FirstName='Test First Name';
        acc.phone='8978008287';
        acc.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        acc.RecordTypeId = prescriberRecordtypeId;
        Database.insert(acc);
        account acc2 = new account(LastName = 'Test Account 2',Phone='9989562352',US_WSREMS__REMS_Program__c = pgrmObj.Id, FirstName='Test First Name',RecordTypeId = prescriberRecordtypeId);
        Database.insert(acc2);
        contact con = new contact();
        con.FirstName = 'Demo';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        Database.insert(con); */
        
         // Create Prescriber Account
            account acc = SYN_TestDataUtility.createPrescriberPersonAccount(pgrmObj.id);
             Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            // Create a protal user 
            user demoUser = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,pgrmObj.Name,'Prescriber');
        //}
    
       /* Id portalProfile  = [select id from profile where name='SoxPortal'].id;
        User demoUser = new User(
            Username = System.now().millisecond() + 'Demo345@test.com',
            ContactId = con.Id,
            IsActive = true,
            ProfileId = portalProfile,
            Alias = 'Demo123',
            Email = 'Demo12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'REMS Test',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(demoUser); */
         User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       // Insert account as current user 
        System.runAs (thisUser) {
            demoUser.Alias='Demo909';
            Database.update(demoUser);
           
        }
         test.startTest();
            acc.LastName='Test46';
        acc.US_WSREMS__Email__c = 'test45896@demotest.com';
            update acc;
            test.stopTest();
    }
    
}