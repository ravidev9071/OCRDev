@IsTest
public class Aveed_HCPEnrollmentCtrlTest {
    
    @TestSetup
    static void setupData() {
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c (
        Name = 'AVEED REMS',
        US_WSREMS__Status__c = 'Active',
        REMS_Project_Code__c = 'BT1005',
        US_WSREMS__Program_State_Date__c = System.today(),
        US_WSREMS__Program_End_Date__c = System.today().addDays(20));
        insert programObj;
        Account accountObj = SYN_TestDataFactory.createPersonAccountforPrescriberAveed('0909876545', 12345678, '1234567896', true, programObj.Id);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<UserRole> roles = [SELECT Id FROM UserRole WHERE Name = 'CEO'];
            if (roles != null && !roles.isEmpty()) {
                User currentUser = new User(Id = UserInfo.getUserId(),
                UserRoleId = roles.get(0).Id);
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
    public static void test_getPicklistFieldValues() {
        Test.startTest();
        Map<String, Map<String, String>> statePickListValueMap = Aveed_HCPEnrollmentCtrl.getPicklistFieldValues('Account', 'US_WSREMS__State__c');
        Test.stopTest();
        Assert.isTrue(statePickListValueMap != null && !statePickListValueMap.isEmpty());
        Assert.isTrue(statePickListValueMap.containsKey('US_WSREMS__State__c') && !statePickListValueMap.get('US_WSREMS__State__c').isEmpty());
    }
    
    @IsTest
    public static void test_getCurrentUserAccount() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        
        System.runAs(portalUser.get(0)) {
            Aveed_HCPEnrollmentCtrl.CurrentUserDetails details = Aveed_HCPEnrollmentCtrl.getCurrentUserAccount();
            Assert.isTrue(details != null);
            Assert.isTrue(details.currentUser != null);
            Assert.isTrue(details.userAccount != null);
        }
    }
    
    @IsTest
    public static void test_searchRecords() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Aveed REMS'];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Aveed_HCPEnrollmentCtrl.HealthCareSettingAccount recordData = new Aveed_HCPEnrollmentCtrl.HealthCareSettingAccount();
                recordData.addressLine1 = '27 Lakeview';
                recordData.addressLine2 = '27 Lakeview Drive';
                recordData.city = 'Shelton';
                recordData.state = 'CT';
                recordData.name = 'Portal Testing HCS';
                recordData.zipCode = '00046';
                
                String accountId = Aveed_HCPEnrollmentCtrl.insertHealthCareSettingAccount(System.JSON.serialize(recordData), program.get(0).Id);
                
                Account accToUpdate = new Account(Id = accountId,
                US_WSREMS__Status__c = 'Certified');
                update accToUpdate;
                
                List<Account> searchAccounts = Aveed_HCPEnrollmentCtrl.searchRecords('Testing');
                Assert.isTrue(searchAccounts != null && !searchAccounts.isEmpty());
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
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Aveed REMS'];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Aveed_HCPEnrollmentCtrl.HealthCareSettingAccount recordData = new Aveed_HCPEnrollmentCtrl.HealthCareSettingAccount();
                recordData.addressLine1 = '27 Lakeview';
                recordData.addressLine2 = '27 Lakeview Drive';
                recordData.city = 'Shelton';
                recordData.state = 'CT';
                recordData.name = 'Portal Testing HCS';
                recordData.zipCode = '00046';
                
                String accountId = Aveed_HCPEnrollmentCtrl.insertHealthCareSettingAccount(System.JSON.serialize(recordData), program.get(0).Id);
                
                Boolean affilitionFlag = Aveed_HCPEnrollmentCtrl.addAffiliations(program.get(0).Id, accounts.get(0).Id, accountId);
                Assert.isTrue(affilitionFlag);
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
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Aveed REMS'];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Aveed_HCPEnrollmentCtrl.HealthCareSettingAccount recordData = new Aveed_HCPEnrollmentCtrl.HealthCareSettingAccount();
                recordData.addressLine1 = '27 Lakeview';
                recordData.addressLine2 = '27 Lakeview Drive';
                recordData.city = 'Shelton';
                recordData.state = 'CT';
                recordData.name = 'Portal Testing HCS';
                recordData.zipCode = '00046';
                
                String accountId = Aveed_HCPEnrollmentCtrl.insertHealthCareSettingAccount(System.JSON.serialize(recordData), program.get(0).Id);
                
                Boolean duplicateFlag = Aveed_HCPEnrollmentCtrl.checkDuplicateForHCSAccount(System.JSON.serialize(recordData), program.get(0).Id);
                Assert.isTrue(duplicateFlag);
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
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Aveed REMS'];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Aveed_HCPEnrollmentCtrl.HealthCareSettingAccount recordData = new Aveed_HCPEnrollmentCtrl.HealthCareSettingAccount();
                recordData.addressLine1 = '27 Lakeview';
                recordData.addressLine2 = '27 Lakeview Drive';
                recordData.city = 'Shelton';
                recordData.state = 'CT';
                recordData.name = 'Portal Testing HCS';
                recordData.zipCode = '00046';
                
                String hcsAccountId = Aveed_HCPEnrollmentCtrl.insertHealthCareSettingAccount(System.JSON.serialize(recordData), program.get(0).Id);
                
                Boolean createCaseSummary = Aveed_HCPEnrollmentCtrl.createCaseAndServiceSummary(accounts.get(0).Id, program.get(0).Id, hcsAccountId);
                Id hcsId=Id.valueof(hcsAccountId);
                List<Id> hcsList=new List<Id>{hcsId};
                Aveed_HCPEnrollmentCtrl.addAffilationRecord(hcsList,(accounts[0].Id).toString() ,(program.get(0).Id).toString());
                List<Account> insertedAccount = [SELECT Id, Name,PersonContactId, US_WSREMS__User_Type__c, US_WSREMS__REMS_ID__c, RecordType.Name,US_WSREMS__Address_Line_1__c,
                US_WSREMS__Address_Line_2__c,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Zip__c,US_WSREMS__Zip_Code__c,US_WSREMS__REMS_Program__c,
                US_WSREMS__Program_Picklist__c,ShippingState,ShippingCity,ShippingPostalCode,ShippingStreet,US_WSREMS__Channel__c
                FROM Account WHERE Id = :hcsAccountId];
                Aveed_HCPEnrollmentCtrl.insertHCSCase(insertedAccount);
                Assert.isTrue(createCaseSummary);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void test_updatePrescriberAccount() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Aveed REMS'];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Aveed_HCPEnrollmentCtrl.RecordDataWrapper data = new Aveed_HCPEnrollmentCtrl.RecordDataWrapper();
                data.firstName = 'Aveed Portal';
                data.lastName = 'Testing User';
                data.faxNumber = '9876543210';
                data.extension = '22';
                data.phoneNumber = '9876543210';
                data.credentials = 'Other';
                data.othercredentials = 'Others';
                data.preferredContactMethod = 'Email';
                data.medicalSpeciality = 'Other';
                data.specialityOther = 'Others Spec.';
                
                Boolean updatePrescriber = Aveed_HCPEnrollmentCtrl.updatePrescriberAccount(System.JSON.serialize(data), accounts.get(0).Id);
                Assert.isTrue(updatePrescriber);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void test_savePrescriberSignature() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Aveed REMS'];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Boolean saveSignature = Aveed_HCPEnrollmentCtrl.savePrescriberSignature(accounts.get(0).Id, 'ZhN06FHWBXT2PmnH4emWGg==');
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
    public static void test_updatePortalStageForAccount() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Aveed REMS'];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
                Boolean updateStage = Aveed_HCPEnrollmentCtrl.updatePortalStageForAccount(accounts.get(0).Id, '.completeProgram');
                Assert.isTrue(updateStage);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            Test.stopTest();
        }
    }
    
     @IsTest
    public static void test_createHCSRecordsEnrollmentCase() {
         Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(REMSAppLiterals.ACCOUNT_RECORDTYPE_HEALTHCARESETTING);
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'AVEED REMS'];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            List<Aveed_HCPEnrollmentCtrl.HealthCareSettingAccount> recordDataList=new List<Aveed_HCPEnrollmentCtrl.HealthCareSettingAccount>();
            try {
                for(integer i=0;i<10;i++ ){
                Aveed_HCPEnrollmentCtrl.HealthCareSettingAccount recordData = new Aveed_HCPEnrollmentCtrl.HealthCareSettingAccount();
                recordData.addressLine1 = '27 Lakeview';
                recordData.addressLine2 = '27 Lakeview Drive';
                recordData.city = 'Shelton';
                recordData.state = 'CT';
                recordData.name = 'Portal Testing HCS';
                recordData.zipCode = '00046';
                recordData.newrecord =true;
                recordDataList.add(recordData);
                }
               
             
               	Account acc=Aveed_HCPEnrollmentCtrl.insertHCSAccount(recordDataList[0],program[0].Id,recordTypeId);
                Aveed_HCPEnrollmentCtrl.insertHCSService(accounts);
                Aveed_HCPEnrollmentCtrl.insertHCSCase(accounts);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            Test.stopTest();
        }
    }
}