@isTest
public class SYN_CaseRDACtrl_Test {
    public static final Map<String, Schema.RecordTypeInfo> mapAccountRcTyByDevName =
    Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();	
        @testSetup static void  SYN_CaseRDACtrlTestData() {
    Id sysAdminProfileId = [select id from profile where name ='System Administrator'].id;
        Id portalprofileId = [select id from profile where name ='Customer Community Plus User'].id ;
        //Id programId = [select id from US_WSREMS__REMS_Program__c where name= 'Sodium Oxybate REMS' limit 1].id;
        List<user> AdminUser = [select id from user where ProfileId =: sysAdminProfileId and UserRoleId != null and IsActive = true limit 1 ];
        
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Sodium Oxybate REMS';
        programObj.REMS_Project_Code__c = 'BT6825';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        Insert programObj;
          Account PharmacyAccount = new Account(
                recordtypeId = mapAccountRcTyByDevName.get('Pharmacy').getRecordTypeId(),
                FirstName = 'portalUser',
                Lastname = 'PharmPatici',
                OwnerId = AdminUser[0].Id,
                Phone  = '9848022338',
                SYN_User_Type__c = 'Pharmacist',
                US_WSREMS__REMS_Program__c = programObj.id
            );
            Account PrescriberAccount = new Account(
                recordtypeId = mapAccountRcTyByDevName.get('Prescriber').getRecordTypeId(),
                FirstName = 'portalUser',
                Lastname = 'PharmPatici',
                OwnerId = AdminUser[0].Id,
                Phone  = '9848022338',
               // SYN_User_Type__c = 'Pharmacist',
                US_WSREMS__REMS_Program__c = programObj.id
            );
            Account PatientAccount = new Account(
                recordtypeId = mapAccountRcTyByDevName.get('Patient').getRecordTypeId(),
                FirstName = 'portalUser',
                Lastname = 'PharmPatici',
                OwnerId = AdminUser[0].Id,
                Phone  = '9848022338',
                US_WSREMS__Status__c = 'Enrolled',
               // SYN_User_Type__c = 'Pharmacist',
                US_WSREMS__REMS_Program__c = programObj.id
            );
            /*id RemsRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Pre_Dispense_Authorization').getRecordTypeId();
       id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();

         US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = RemsRecordTypeId;
        Insert serviceObj;
       
        Case caseObjlst = new case();
        caseObjlst.US_WSREMS__Phone__c = '9876543210';
        caseObjlst.US_WSREMS__Fax__c='4802223561';
        caseObjlst.RecordTypeId = caseRecordTypeId;
        caseObjlst.US_WSREMS__REMS_Service_Summary__c = serviceObj.id;
       // caseObjlst.US_WSREMS__Participant__c = PIacc.id;
       caseObjlst.RDA_Authorization_Code__c ='1234';
        caseObjlst.US_WSREMS__DEA__c ='123456789';
        caseObjlst.US_WSREMS__Patient__c =PatientAccount.Id;
        caseObjlst.SYN_Prescriber__c =PrescriberAccount.Id;
        caseObjlst.US_WSREMS__DOB__c = Date.newInstance(1997, 12, 24);
        caseObjlst.US_WSREMS__Call_Notes__c = 'test';
        caseObjlst.US_WSREMS__Call_Outcome__c = 'Call Back';
        caseObjlst.US_WSREMS__Call_Outcome_Reason__c = 'Holiday';
        caseObjlst.US_WSREMS__Outcome__c='Approved';
        caseObjlst.status = 'New';
       // caseObjlst.Pharmacy_Participant__c = PIacc.id;
        caseObjlst.US_WSREMS__Pharmacy__c = PharmacyAccount.Id;
   //     Insert caseObjlst;*/
        System.runAs ( AdminUser[0] ) {
            Account portalAccount = new Account(
                recordtypeId = mapAccountRcTyByDevName.get('Pharmacy_Participant').getRecordTypeId(),
                FirstName = 'portalUser1',
                Lastname = 'PharmPatici',
                OwnerId = AdminUser[0].Id,
                SYN_Pharmacy__c = PharmacyAccount.Id,
                Phone  = '9848022338',
                SYN_User_Type__c = 'Pharmacist',
                US_WSREMS__REMS_Program__c = programObj.id
            );
            
            Database.insert(portalAccount);
            Id contactId = [select id , PersonContactId from account where Id =: portalAccount.id].PersonContactId;
            system.debug('***Test--'+[select id , PersonContactId from account where Id =: portalAccount.id ]);
             system.debug('***Contact- Account --'+[select id , AccountId from contact where Id =: contactId ]);
            //Create contact
            Contact Portalcontact = new Contact(
                FirstName = 'portalUser1',
                Lastname = 'PharmPatici',
                AccountId = portalAccount.Id,
                Email = System.now().millisecond() + 'test@test.com'
            );
            //Database.insert(Portalcontact);
            
            //Create user
           // Profile portalProfile = [SELECT Id FROM Profile Limit 1];
            User user1 = new User(
                Username = 'PortalUser@ButtonCheck.com',
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
    public static testMethod void SYN_CaseRDACtrlMethod() {
        List<user>portalUser = [select id from user where Email ='PortalUser@ButtonCheck.com' limit 1];
       System.runAs ( portalUser[0] ) {
           SYN_CaseRDACtrl.getCaseRDA('1234','PharmPatici portalUser','','PharmPatici portalUser','123456789');
           SYN_CaseRDACtrl.getCaseRDA('','', '', '', '123456789');
           SYN_CaseRDACtrl.getCaseRDA('','PharmPatici portalUser', '', '', '123456789');
           SYN_CaseRDACtrl.getCaseRDA('','', '', 'PharmPatici portalUser', '');
           SYN_CaseRDACtrl.getCaseRDA('','', '', '', '');
   }
}      
}