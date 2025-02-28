@isTest
public class aveed_HCS_RecordsManager_Test {
    @testSetup
    static void setup() {
        list<US_WSREMS__REMS_Program__c> programObj = SYN_TestDataFactory.createProgram(1,True,SYN_Utilitycls.AVEED_PROGRAM_NAME,'BT2815');
        insert programObj;
        account prescriberAcc = SYN_TestDataFactory.createPrescriberAccount('741258963','7458269301',False,programObj[0].id);
        prescriberAcc.US_WSREMS__Status__c = 'Certified';
        prescriberAcc.Program__c = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        insert prescriberAcc;  
        
        Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(REMSAppLiterals.ACCOUNT_RECORDTYPE_HEALTHCARESETTING);
        Account newAccount = new Account();
        newAccount.Name = 'New HCS Test';
        newAccount.US_WSREMS__Address_Line_1__c = '123 Main Street';
        newAccount.US_WSREMS__Address_Line_2__c = '2nd Lane';
        newAccount.US_WSREMS__City__c = 'Philadelphia';
        newAccount.US_WSREMS__State__c = 'PA';
        newAccount.US_WSREMS__Zip__c = '99999';
        newAccount.RecordTypeId = recordTypeId;
        newAccount.US_WSREMS__REMS_Program__c = programObj[0].Id;
        newAccount.US_WSREMS__Program_Picklist__c = (programObj != null && !programObj.isEmpty()) ? programObj.get(0).Name : SYN_Utilitycls.AVEED_PROGRAM_NAME;
        newAccount.US_WSREMS__Status__c = 'Pending';
        insert newAccount;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<UserRole> roles = [SELECT Id FROM UserRole WHERE Name = 'CEO'];
            if (roles != null && !roles.isEmpty()) {
                User currentUser = new User(Id = UserInfo.getUserId());
                currentUser.UserRoleId = roles.get(0).Id;
                update currentUser;
            }
            List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE Id = :prescriberAcc.Id];
            List<Profile> aveedPortalProfile = [SELECT Id, Name FROM Profile WHERE Name = 'AVEED Portal'];
            List<PermissionSet> portalPermissionSet = [SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'AVEED_PortalPermissionSet'];
            String orgId = UserInfo.getOrganizationId();  
            String dateString =   
                String.valueof(
                    Datetime.now()
                ).replace(
                    ' ',''
                ).replace(
                    ':',''
                ).replace(
                    '-',''
                );  
            Integer randomInt = Integer.valueOf(
                math.rint(
                    math.random()*1000000
                )
            );  
            String uniqueName = orgId + dateString + randomInt;  
            User portalUser = new User(  
                FirstName = accounts.get(0).FirstName,
                LastName = accounts.get(0).LastName,
                email = uniqueName + '@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = aveedPortalProfile.get(0).Id,
                ContactId = accounts.get(0).PersonContactId
            );  
            insert portalUser;
            
            PermissionSetAssignment permissionAssignment = new PermissionSetAssignment(PermissionSetId = portalPermissionSet.get(0).Id, AssigneeId = portalUser.Id);
            insert permissionAssignment;
        }
    }
    @isTest
    static void testGetRelatedHCSList() {
        
        Account acc=[Select Id,PersonContactId from account where US_WSREMS__Status__c='Certified'];
        US_WSREMS__REMS_Program__c programName=[Select Id,Name from US_WSREMS__REMS_Program__c Where Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :acc.PersonContactId];
        US_WSREMS__Affiliation__c testAffiliation = new US_WSREMS__Affiliation__c(
            US_WSREMS__Prescriber__c = acc.Id,
            US_WSREMS__REMSProgram__c=programName.Id,
            US_WSREMS__isActive__c = true
        );
        insert testAffiliation;
        
        Test.startTest();
        List<Account> hcsList = aveed_HCS_RecordsManager.getRelatedHCSList(portalUser[0].Id);
        Test.stopTest();
        
    }
    @isTest
    static void testdisassociateHandler() {
        Account acc=[Select Id,PersonContactId from account where US_WSREMS__Status__c='Certified'];
        US_WSREMS__REMS_Program__c programName=[Select Id,Name from US_WSREMS__REMS_Program__c Where Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        Account hcsAcc = [select id from Account where Name = 'New HCS Test'];
        
        US_WSREMS__Affiliation__c testAffiliation = new US_WSREMS__Affiliation__c(
            US_WSREMS__Prescriber__c = acc.Id,
            US_WSREMS__REMSProgram__c=programName.Id,
            US_WSREMS__Health_Care_Setting__c = hcsAcc.Id,
            US_WSREMS__isActive__c = true
        );
        insert testAffiliation;
        List<User> portalUser = [SELECT Id, Name,ContactId,contact.accountId FROM User WHERE ContactId = :acc.PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            Boolean disass= aveed_HCS_RecordsManager.disassociateHandler(hcsAcc.Id,0);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testcreateCaseAndServiceSummaryUpdatePrescriber() {
        Account acc=[Select Id,PersonContactId from account where US_WSREMS__Status__c='Certified'];
        US_WSREMS__REMS_Program__c programName=[Select Id,Name from US_WSREMS__REMS_Program__c Where Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        Account hcsAcc = [select id from Account where Name = 'New HCS Test'];
        id RemsRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Participant_Account_Creation').getRecordTypeId();
        id remsRectypeId =  Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId(); 
        
        US_WSREMS__Affiliation__c testAffiliation = new US_WSREMS__Affiliation__c(
            US_WSREMS__Prescriber__c = acc.Id,
            US_WSREMS__REMSProgram__c=programName.Id,
            US_WSREMS__Health_Care_Setting__c = hcsAcc.Id,
            US_WSREMS__isActive__c = true
        );
        insert testAffiliation;
        
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programName.id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = RemsRecordTypeId;
        Insert serviceObj;
        
        serviceObj.US_WSREMS__Status__c ='Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Successful';
        serviceObj.recordtypeId = remsRectypeId;
        update serviceObj;
        
        List<User> portalUser = [SELECT Id, Name,ContactId,contact.accountId FROM User WHERE ContactId = :acc.PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            aveed_HCS_RecordsManager.createCaseAndServiceSummaryUpdatePrescriber(acc.Id,hcsAcc.Id);
            Test.stopTest();
        }
    }
}