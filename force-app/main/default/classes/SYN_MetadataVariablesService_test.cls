/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SYN_MetadataVariablesService_test {
    
    public static final Map<String, Schema.RecordTypeInfo> mapAccountRcTyByDevName =
    Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
	private static final string buttonName = 'Find a Prescriber';
    @testSetup
    static void createTestData(){
        Id sysAdminProfileId = [select id from profile where name ='System Administrator'].id;
        Id portalprofileId = [select id from profile where name ='Customer Community Plus User'].id ;
        //Id programId = [select id from US_WSREMS__REMS_Program__c where name= 'Sodium Oxybate REMS' limit 1].id;
        List<user> AdminUser = [select id from user where ProfileId =: sysAdminProfileId and UserRoleId != null and IsActive = true limit 1 ];
        id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
      
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Sodium Oxybate REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.REMS_Project_Code__c = 'BT6825';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        Insert programObj;

        System.runAs ( AdminUser[0] ) {
            Account portalAccount = new Account(
                recordtypeId = recordTypeIdPharmacyParticipant,
                FirstName = 'portalUser',
                Lastname = 'PharmPatici',
                OwnerId = AdminUser[0].Id,
                Phone  = '9848022338',
                US_WSREMS__Status__c='Initiated',
                SYN_User_Type__c = 'Pharmacist',
                US_WSREMS__REMS_Program__c = programObj.id
            );
            
            Database.insert(portalAccount);
            Id contactId = [select id , PersonContactId from account where Id =: portalAccount.id].PersonContactId;
            system.debug('***Test--'+[select id , PersonContactId from account where Id =: portalAccount.id ]);
             system.debug('***Contact- Account --'+[select id , AccountId from contact where Id =: contactId ]);
            //Create contact
            Contact Portalcontact = new Contact(
                FirstName = 'portalUser',
                Lastname = 'PharmPatici',
                AccountId = portalAccount.Id,
                Email = System.now().millisecond() + 'test@test.com'
            );
            //Database.insert(Portalcontact);
            
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
              system.debug('***Final-'+[select id , ContactId from user where Id =: user1.id ]);
        }
    }

    @isTest
    static void portalButtonAccessCheck(){
        List<user>portalUser = [select id from user where Email ='PortalUser@ButtonCheck.com' limit 1];
        System.runAs ( portalUser[0] ) {

            SYN_MetadataVariablesService.retrievePortalButtonConfigurationData(buttonName);
        }

    }
    
    @isTest
    static void portalButtonHasAccess(){
        Account portalAccount = [select id , US_WSREMS__Status__c  from account where firstName ='portalUser' limit 1];
        portalAccount.US_WSREMS__Status__c = 'Active';
       portalAccount.SYN_User_Type__c = 'Pharmacist;Authorized Representative'; 
        update portalAccount;
        List<user>portalUser = [select id from user where Email ='PortalUser@ButtonCheck.com' limit 1];
         System.runAs ( portalUser[0] ) {

            SYN_MetadataVariablesService.retrievePortalButtonConfigurationData(buttonName);
        }

        
    }
}