/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-19-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class AddOfficeContactControllerTest {
    public static final Map<String, Schema.RecordTypeInfo> mapAccountRcTyByDevName = REMSUtility.getRecordTypeNameAndSchema('Account');
	private static final string buttonName = 'Find a Prescriber';
    @testSetup
    static void createTestData(){
        Id sysAdminProfileId = [select id from profile where name ='System Administrator'].id;
        Id portalprofileId = [select id from profile where name ='New Maci Portal Profile'].id ;
        //Id programId = [select id from US_WSREMS__REMS_Program__c where name= 'Sodium Oxybate REMS' limit 1].id;
        List<user> AdminUser = [select id from user where ProfileId =: sysAdminProfileId and UserRoleId != null and IsActive = true limit 1 ];
        
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Sodium Oxybate REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.REMS_Project_Code__c = 'BT6825';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        Insert programObj;

        System.runAs ( AdminUser[0] ) {
            Account portalAccount = new Account(
                recordtypeId = mapAccountRcTyByDevName.get('Pharmacy_Participant').getRecordTypeId(),
                FirstName = 'portalUser',
                Lastname = 'PharmPatici',
                OwnerId = AdminUser[0].Id,
                Phone  = '9848022338',
                SYN_User_Type__c = 'Authorized Representative',
                US_WSREMS__REMS_Program__c = programObj.id
            );
            
            Database.insert(portalAccount);
            Id contactId = [select id , PersonContactId from account where Id =: portalAccount.id].PersonContactId;
             //Create contact
            Contact Portalcontact = new Contact(
                FirstName = 'portalUser',
                Lastname = 'PharmPatici',
                AccountId = portalAccount.Id,
                Email = System.now().millisecond() + 'test@test.com'
            ); 
            //Create user
           // Profile portalProfile = [SELECT Id FROM Profile Limit 1];
            User user1 = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = contactId,
                ProfileId = portalprofileId,
                Alias = 'PUser',
                Email = 'PortalUser@ButtonCheck.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                IsActive = true
            );
            Database.insert(user1);
               }
    }
    
    @isTest
    static void searchForAccountsTest(){
        List<user> portalUser = [select id from user where Email ='PortalUser@ButtonCheck.com' limit 1];
        System.runAs ( portalUser[0] ) {
            AddOfficeContactController.searchForAccounts('test','test','test@abc.de');
        }

    }
    
    @isTest
    static void createOfficeContactTest(){
        List<user> portalUser = [select id from user where Email ='PortalUser@ButtonCheck.com' limit 1];
        System.runAs ( portalUser[0] ) {
            US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
            programObj.Name = 'Sodium Oxybate REMS';
            programObj.US_WSREMS__Status__c ='Active';
            programObj.REMS_Project_Code__c = 'BT6825';
            programObj.US_WSREMS__Program_State_Date__c = System.today();
            programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
            Insert programObj;
            try{
                AddOfficeContactController.createOfficeContact('test','test','test@abc.de','1234567890');
            } catch (Exception expObj) {
                system.debug('Error');
            }
            
        }

    }
    
    
}