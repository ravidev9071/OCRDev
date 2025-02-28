@IsTest
public class Aveed_PharmHCSEnrollmentCtrlTest {
    
    @TestSetup
    static void setupData() {
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c ();
        programObj.Name = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        programObj.US_WSREMS__Status__c = 'Active';
        programObj.REMS_Project_Code__c = 'BT1005';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        Account accountObj = SYN_TestDataFactory.createPersonAccountforPrescriberAveed('0909876545', 12345678, '1234567896', true, programObj.Id);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<UserRole> roles = [SELECT Id FROM UserRole WHERE Name = 'CEO'];
            if (roles != null && !roles.isEmpty()) {
                User currentUser = new User(Id = UserInfo.getUserId());
                currentUser.UserRoleId = roles.get(0).Id;
                update currentUser;
            }
            List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE Id = :accountObj.Id];
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
    
    @IsTest
    public static void test_searchHCSettingRecords() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount recordData = new Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount();
                recordData.addressLine1 = '27 Lakeview';
                recordData.addressLine2 = '27 Lakeview Drive';
                recordData.city = 'Shelton';
                recordData.state = 'CT';
                recordData.name = 'Portal Testing HCS';
                recordData.zip = '00046';
                recordData.dea = 'CT0234569';
                recordData.phone = '9876543210';
                recordData.faxNumber = '3343350040';
                recordData.emailAddress = 'portaltest@testyopmail.com';
                
                String accountId = Aveed_PharmHCSEnrollmentCtrl.insertHealthCareSettingAccount(System.JSON.serialize(recordData), program.get(0).Id);
                
                Account accToUpdate = new Account(Id = accountId);
                accToUpdate.US_WSREMS__Status__c = 'Certified';
                update accToUpdate;
                
                List<Account> searchAccounts = Aveed_PharmHCSEnrollmentCtrl.searchHCSettingRecords('test');
                Assert.isTrue(searchAccounts != null && !searchAccounts.isEmpty());
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void test_checkDuplicateForHCSAccount() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount recordData = new Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount();
                recordData.addressLine1 = '27 Lakeview';
                recordData.addressLine2 = 'Drive';
                recordData.city = 'Shelton';
                recordData.state = 'CT';
                recordData.name = 'Portal Testing HCS';
                recordData.zip = '00046';
                recordData.dea = 'CT0234569';
                recordData.phone = '9876543210';
                recordData.faxNumber = '3343350040';
                recordData.emailAddress = 'portaltest@testyopmail.com';
                
                String accountId = Aveed_PharmHCSEnrollmentCtrl.insertHealthCareSettingAccount(System.JSON.serialize(recordData), program.get(0).Id);
                
                Boolean duplicateFlag = Aveed_PharmHCSEnrollmentCtrl.checkDuplicateForHCSAccount(System.JSON.serialize(recordData), program.get(0).Id);
                Assert.isTrue(duplicateFlag);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void test_searchARRecords() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Aveed_PharmHCSEnrollmentCtrl.HealthCareProviderAccount recordData = new Aveed_PharmHCSEnrollmentCtrl.HealthCareProviderAccount();
                recordData.firstName = 'CT Provider';
                recordData.lastName = 'Prescriber Test';
                recordData.dea = 'CR0234570';
                recordData.npi = '9196543212';
                
                String accountId = Aveed_PharmHCSEnrollmentCtrl.insertHealthCareProvider(System.JSON.serialize(recordData), program.get(0).Id);
                
                Account accToUpdate = new Account(Id = accountId);
                accToUpdate.US_WSREMS__Status__c = 'Certified';
                update accToUpdate;
                
                List<Account> searchAccounts = Aveed_PharmHCSEnrollmentCtrl.searchARRecords('Provider');
                Assert.isTrue(searchAccounts != null && !searchAccounts.isEmpty());
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void test_checkDuplicateForHCProviderAccount() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Aveed_PharmHCSEnrollmentCtrl.HealthCareProviderAccount recordData = new Aveed_PharmHCSEnrollmentCtrl.HealthCareProviderAccount();
                recordData.firstName = 'CT Provider';
                recordData.lastName = 'Prescriber Test';
                recordData.dea = 'CR0234570';
                recordData.npi = '9196543212';
                
                String accountId = Aveed_PharmHCSEnrollmentCtrl.insertHealthCareProvider(System.JSON.serialize(recordData), program.get(0).Id);
                
                Boolean duplicateFlag = Aveed_PharmHCSEnrollmentCtrl.checkDuplicateForHCProviderAccount(System.JSON.serialize(recordData), program.get(0).Id);
                Assert.isTrue(duplicateFlag);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void test_addAffiliations() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount recordData = new Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount();
                recordData.addressLine1 = '27 Lakeview';
                recordData.addressLine2 = 'Drive';
                recordData.city = 'Shelton';
                recordData.state = 'CT';
                recordData.name = 'Portal Testing HCS';
                recordData.zip = '00046';
                recordData.dea = 'CT0234569';
                recordData.phone = '9876543210';
                recordData.faxNumber = '3343350040';
                recordData.emailAddress = 'portaltest@testyopmail.com';
                
                String hcsAccountId = Aveed_PharmHCSEnrollmentCtrl.insertHealthCareSettingAccount(System.JSON.serialize(recordData), program.get(0).Id);
                
                Aveed_PharmHCSEnrollmentCtrl.HealthCareProviderAccount providerData = new Aveed_PharmHCSEnrollmentCtrl.HealthCareProviderAccount();
                providerData.firstName = 'CT Provider';
                providerData.lastName = 'Prescriber Test';
                providerData.dea = 'CR0234570';
                providerData.npi = '9196543212';
                
                String providerId = Aveed_PharmHCSEnrollmentCtrl.insertHealthCareProvider(System.JSON.serialize(providerData), program.get(0).Id);
                
                Boolean prescriberAffilitionFlag = Aveed_PharmHCSEnrollmentCtrl.addPrescriberAffiliations(program.get(0).Id, accounts.get(0).Id, hcsAccountId);
                Assert.isTrue(prescriberAffilitionFlag);
                
                Boolean arAffilitionFlag = Aveed_PharmHCSEnrollmentCtrl.addARAffiliations(program.get(0).Id, providerId, hcsAccountId);
                Assert.isTrue(arAffilitionFlag);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void test_updateArRecord() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Aveed_PharmHCSEnrollmentCtrl.AccountRecordWrapper data = new Aveed_PharmHCSEnrollmentCtrl.AccountRecordWrapper();
                data.firstName = 'Aveed Portal';
                data.middleName = 'MI T';
                data.lastName = 'Testing User';
                data.title = 'Dr.';
                data.faxNumber = '9876543210';
                data.extension = '22';
                data.phoneNumber = '9876543210';
                data.credentials = 'Other';
                data.othercredentials = 'Others';
                data.preferredContactMethod = 'Email';
                
                Boolean updatePrescriber = Aveed_PharmHCSEnrollmentCtrl.updateArRecord(System.JSON.serialize(data), accounts.get(0).Id);
                Assert.isTrue(updatePrescriber);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void test_saveARSignature() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Boolean saveSignature = Aveed_PharmHCSEnrollmentCtrl.saveARSignature(accounts.get(0).Id, 'ZhN06FHWBXT2PmnH4emWGg==');
                Assert.isTrue(saveSignature);
                
                List<Attachment> attachments = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :accounts.get(0).Id];
                Assert.isTrue(attachments != null && !attachments.isEmpty());
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void test_createCaseAndServiceSummary() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
            try {
                Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount recordData = new Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount();
                recordData.addressLine1 = '27 Lakeview';
                recordData.addressLine2 = 'Drive';
                recordData.city = 'Shelton';
                recordData.state = 'CT';
                recordData.name = 'Portal Testing HCS';
                recordData.zip = '00046';
                recordData.dea = 'CT0234569';
                recordData.phone = '9876543210';
                recordData.faxNumber = '3343350040';
                recordData.emailAddress = 'portaltest@testyopmail.com';
                
                String hcsAccountId = Aveed_PharmHCSEnrollmentCtrl.insertHealthCareSettingAccount(System.JSON.serialize(recordData), program.get(0).Id);
                
                Aveed_PharmHCSEnrollmentCtrl.HealthCareProviderAccount providerData = new Aveed_PharmHCSEnrollmentCtrl.HealthCareProviderAccount();
                providerData.firstName = 'CT Provider';
                providerData.lastName = 'Prescriber Test';
                providerData.dea = 'CR0234570';
                providerData.npi = '9196543212';
                
                String providerId = Aveed_PharmHCSEnrollmentCtrl.insertHealthCareProvider(System.JSON.serialize(providerData), program.get(0).Id);
                Test.startTest();
                    Boolean createCaseSummary = Aveed_PharmHCSEnrollmentCtrl.createCaseAndServiceSummary(accounts.get(0).Id, program.get(0).Id, hcsAccountId, providerId, 'Yes');
                    Assert.isTrue(createCaseSummary);
                Test.stopTest();
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
        }
    }

}