@IsTest
public class Aveed_ManageHCSForARCtrlTest {
    
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
    public static void test_getRelatedHealthcareSettings() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
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
                
                Boolean creatAffiliation = Aveed_PharmHCSEnrollmentCtrl.addARAffiliations(program.get(0).Id, accounts.get(0).Id, accountId);
                
                Test.startTest();
                	List<Account> relatedHCSSettings = Aveed_ManageHCSForARCtrl.getRelatedHealthcareSettings();
                Test.stopTest();
                
                Assert.isTrue(relatedHCSSettings != null && !relatedHCSSettings.isEmpty());
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
        }
    }
    
    @IsTest
    public static void test_disassociateHCSFromAR() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
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
                
                Boolean creatAffiliation = Aveed_PharmHCSEnrollmentCtrl.addARAffiliations(program.get(0).Id, accounts.get(0).Id, accountId);
                
                Test.startTest();
                	Boolean isDisassociate = Aveed_ManageHCSForARCtrl.disassociateHCSFromAR(accountId);
                Test.stopTest();
                
                Assert.isTrue(isDisassociate);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
        }
    }
    
    @IsTest
    public static void test_getHCSWithProvidersDetail() {
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
                
                Boolean creatAffiliation = Aveed_PharmHCSEnrollmentCtrl.addARAffiliations(program.get(0).Id, accounts.get(0).Id, hcsAccountId);
                
                Aveed_PharmHCSEnrollmentCtrl.HealthCareProviderAccount recordHCPData = new Aveed_PharmHCSEnrollmentCtrl.HealthCareProviderAccount();
                recordHCPData.firstName = 'CT Provider';
                recordHCPData.lastName = 'Prescriber Test';
                recordHCPData.dea = 'CR0234570';
                recordHCPData.npi = '9196543212';
                
                String hcpAccountId = Aveed_PharmHCSEnrollmentCtrl.insertHealthCareProvider(System.JSON.serialize(recordHCPData), program.get(0).Id);
                
                Boolean arAffilitionFlag = Aveed_PharmHCSEnrollmentCtrl.addPrescriberAffiliations(program.get(0).Id, hcpAccountId, hcsAccountId);
                
                Test.startTest();
                Aveed_ManageHCSForARCtrl.HealthCareSettingData data = Aveed_ManageHCSForARCtrl.getHCSWithProvidersDetail(hcsAccountId);
                Test.stopTest();
                
                Assert.isTrue(data != null);
                Assert.isTrue(data.hcsProviders != null && !data.hcsProviders.isEmpty());
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
        }
    }
    
    @IsTest
    public static void test_getCurrentAccountHCSDetails() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =: SYN_Utilitycls.AVEED_PROGRAM_NAME];
        System.runAs(portalUser.get(0)) {
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
                
                Boolean creatAffiliation = Aveed_PharmHCSEnrollmentCtrl.addARAffiliations(program.get(0).Id, accounts.get(0).Id, accountId);
                
                Test.startTest();
                	Aveed_ManageHCSForARCtrl.ManageCurrentAccountHCSDetails details = Aveed_ManageHCSForARCtrl.getCurrentAccountHCSDetails(accountId);
                	Aveed_ManageHCSForARCtrl.updateARVerification(accountId, true);
                Test.stopTest();
                
                Assert.isTrue(details != null);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
        }
    }
    
    @IsTest
    public static void test_updateHCSAccountRecord_Edit() {
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
                
                String accountId = Aveed_PharmHCSEnrollmentCtrl.insertHealthCareSettingAccount(System.JSON.serialize(recordData), program.get(0).Id);
                
                Account accToUpdate = new Account(Id = accountId);
                accToUpdate.US_WSREMS__Status__c = 'Certified';
                update accToUpdate;
                
                Boolean creatAffiliation = Aveed_PharmHCSEnrollmentCtrl.addARAffiliations(program.get(0).Id, accounts.get(0).Id, accountId);
                
                Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount payloadData = new Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount();
                payloadData.name = 'Portal HCS Edit';
                payloadData.dea = 'CT0234570';
                payloadData.addressLine1 = '27 Lakeview';
                payloadData.addressLine2 = 'Drive';
                payloadData.city = 'Shelton';
                payloadData.state = 'CT';
                payloadData.zip = '00046';
                payloadData.phone = '9876543210';
                payloadData.faxNumber = '3343350040';
                payloadData.emailAddress = 'portaltest@testyopmail.com';
                
                Test.startTest();
                	Boolean isEdit = Aveed_ManageHCSForARCtrl.updateHCSAccountRecord(accounts.get(0).Id, System.JSON.serialize(payloadData), accountId, 'Edit', null);
                Test.stopTest();
                
                Assert.isTrue(isEdit);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
        }
    }
    
    @IsTest
    public static void test_updateHCSAccountRecord_ReEnroll() {
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
                
                String accountId = Aveed_PharmHCSEnrollmentCtrl.insertHealthCareSettingAccount(System.JSON.serialize(recordData), program.get(0).Id);
                
                Account accToUpdate = new Account(Id = accountId);
                accToUpdate.US_WSREMS__Status__c = 'Certified';
                update accToUpdate;
                
                Boolean creatAffiliation = Aveed_PharmHCSEnrollmentCtrl.addARAffiliations(program.get(0).Id, accounts.get(0).Id, accountId);
                
                Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount payloadData = new Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount();
                payloadData.name = 'Portal HCS Edit';
                payloadData.dea = 'CT0234570';
                payloadData.addressLine1 = '27 Lakeview';
                payloadData.addressLine2 = 'Drive';
                payloadData.city = 'Shelton';
                payloadData.state = 'CT';
                payloadData.zip = '00046';
                payloadData.phone = '9876543210';
                payloadData.faxNumber = '3343350040';
                payloadData.emailAddress = 'portaltest@testyopmail.com';
                
                Test.startTest();
                	Boolean isReEnroll = Aveed_ManageHCSForARCtrl.updateHCSAccountRecord(accounts.get(0).Id, System.JSON.serialize(payloadData), accountId, 'Re-enroll', 'Yes');
                Test.stopTest();
                
                Assert.isTrue(isReEnroll);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
        }
    }

}