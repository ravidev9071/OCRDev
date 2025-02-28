public without sharing class Aveed_PharmHCSEnrollmentCtrl {

    @AuraEnabled(cacheable=true)
    public static List<Account> searchARRecords(String searchString) {
        if (String.isBlank(searchString)) {
            return null;
        }
        // Perform SOQL query based on search criteria
        Id recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        Map<String, Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        List<String> includedStatus = new List<String>{'Certified'};
        String queryString = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',');
        queryString += ', (SELECT Id, US_WSREMS__Health_Care_Setting__r.Name, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c';
        queryString += ' FROM US_WSREMS__Prescriber_PrescribingInstitution__r WHERE US_WSREMS__isActive__c = TRUE AND US_WSREMS__Start_Date__c != NULL ORDER BY US_WSREMS__Start_Date__c ASC LIMIT 1)';
        queryString += ' FROM Account WHERE RecordTypeId = :recordtypeId AND US_WSREMS__Program_Picklist__c = :programName AND US_WSREMS__Status__c IN :includedStatus';
        searchString = String.escapeSingleQuotes(searchString);
        queryString += ' AND (';
        queryString += ' US_WSREMS__REMS_ID__c LIKE \'%' + searchString + '%\'' + ' OR';
        queryString += ' Name LIKE \'%' + searchString + '%\'' + ' OR';
        queryString += ' FirstName LIKE \'%' + searchString + '%\'' + ' OR';
        queryString += ' LastName LIKE \'%' + searchString + '%\'' + ' OR';
        queryString += ' US_WSREMS__City__c LIKE \'%' + searchString + '%\'' + ' OR';
        queryString += ' US_WSREMS__State__c LIKE \'%' + searchString + '%\'' + ' OR';
        queryString += ' US_WSREMS__Zip__c LIKE \'%' + searchString + '%\'' + ' )';
        return Database.query(queryString);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> searchHCSettingRecords(String searchString) {
        if (String.isBlank(searchString)) {
            return null;
        }
        // Perform SOQL query based on search criteria
        Id recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        Map<String, Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        List<String> includedStatus = new List<String>{'Certified'};
        String queryString = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE RecordTypeId = :recordtypeId AND US_WSREMS__Program_Picklist__c = :programName AND US_WSREMS__Status__c IN :includedStatus';
        searchString = String.escapeSingleQuotes(searchString);
        queryString += ' AND (';
        queryString += ' US_WSREMS__REMS_ID__c LIKE \'%' + searchString + '%\'' + ' OR';
        queryString += ' Name LIKE \'%' + searchString + '%\'' + ' OR';
        queryString += ' US_WSREMS__City__c LIKE \'%' + searchString + '%\'' + ' OR';
        queryString += ' US_WSREMS__State__c LIKE \'%' + searchString + '%\'' + ' OR';
        queryString += ' US_WSREMS__Zip__c LIKE \'%' + searchString + '%\'' + ' )';
        return Database.query(queryString);
    }
    
    @AuraEnabled
    public static Boolean addPrescriberAffiliations(String programId, String accountId, String healthCareSettingId) {
        try {
            if (String.isBlank(accountId)) {
                return false;
            }
            //SOQL to check duplicate Affiliations.
            List<US_WSREMS__Affiliation__c> dupAffiliations = [SELECT Id, US_WSREMS__Prescriber__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__isActive__c, US_WSREMS__End_Date__c 
                                                               FROM US_WSREMS__Affiliation__c 
                                                               WHERE US_WSREMS__Prescriber__c = :accountId 
                                                               AND US_WSREMS__Health_Care_Setting__c = :healthCareSettingId 
                                                               AND US_WSREMS__isActive__c = true 
                                                               AND US_WSREMS__End_Date__c = null];
            if (dupAffiliations != null && !dupAffiliations.isEmpty()) {
                return true; 
            }
            Id recordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Prescriber_Affiliation').getRecordTypeId();
            US_WSREMS__Affiliation__c oAffiliation = new US_WSREMS__Affiliation__c(
                US_WSREMS__REMSProgram__c = programId,
                US_WSREMS__Prescriber__c = accountId,
                US_WSREMS__isActive__c = true,
                US_WSREMS__Start_Date__c = System.today(),
                US_WSREMS__Health_Care_Setting__c = healthCareSettingId,
                RecordTypeId = recordTypeId,
                US_WSREMS__End_Date__c = null
            );
            insert oAffiliation;
            return true;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean checkDuplicateARAffiliations(String programId, String accountId, String healthCareSettingId, String arAccountId) {
        try {
            if (String.isNotBlank(arAccountId) && String.isNotBlank(healthCareSettingId)) {
                //SOQL to check duplicate Affiliations.
                List<US_WSREMS__Affiliation__c> dupHCSAffiliations = [SELECT Id, US_WSREMS__Prescriber__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__isActive__c, US_WSREMS__End_Date__c 
                                                                    FROM US_WSREMS__Affiliation__c 
                                                                    WHERE US_WSREMS__Authorized_Representative__c = :arAccountId 
                                                                    AND US_WSREMS__Health_Care_Setting__c =: healthCareSettingId 
                                                                    AND US_WSREMS__isActive__c = true];
                if (dupHCSAffiliations != null && !dupHCSAffiliations.isEmpty()) {
                    return true;
                }
            }
            if (String.isNotBlank(accountId) && String.isNotBlank(healthCareSettingId)) {
                List<US_WSREMS__Affiliation__c> dupHCPAffiliations = [SELECT Id, US_WSREMS__Prescriber__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__isActive__c, US_WSREMS__End_Date__c 
                                                                    FROM US_WSREMS__Affiliation__c 
                                                                    WHERE US_WSREMS__Prescriber__c = :accountId 
                                                                    AND US_WSREMS__Health_Care_Setting__c =: healthCareSettingId 
                                                                    AND US_WSREMS__isActive__c = true];
                if (dupHCPAffiliations != null && !dupHCPAffiliations.isEmpty()) {
                    return true;
                }
            }
            return false;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean addARAffiliations(String programId, String accountId, String healthCareSettingId) {
        try {
            //SOQL to check duplicate Affiliations.
            List<US_WSREMS__Affiliation__c> dupAffiliations = [SELECT Id, US_WSREMS__Prescriber__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__isActive__c, US_WSREMS__End_Date__c 
                                                               FROM US_WSREMS__Affiliation__c 
                                                               WHERE US_WSREMS__Authorized_Representative__c = :accountId 
                                                               AND US_WSREMS__Health_Care_Setting__c =: healthCareSettingId 
                                                               AND US_WSREMS__isActive__c = true 
                                                               AND US_WSREMS__End_Date__c = null];
            if (dupAffiliations != null && !dupAffiliations.isEmpty()) {
                return true; 
            }
            Id recordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Authorized_Representative_Affiliation').getRecordTypeId();
            US_WSREMS__Affiliation__c oAffiliation = new US_WSREMS__Affiliation__c(
                US_WSREMS__REMSProgram__c = programId,
                US_WSREMS__Authorized_Representative__c = accountId,
                US_WSREMS__User_Role__c = 'Primary AR',
                US_WSREMS__isActive__c = true,
                US_WSREMS__Start_Date__c = System.today(),
                US_WSREMS__Health_Care_Setting__c = healthCareSettingId,
                RecordTypeId = recordTypeId,
                US_WSREMS__End_Date__c = null
            );
            insert oAffiliation;
            return true;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean checkDuplicateForHCSAccount(String payload, String programId) {
        try {
            Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(REMSAppLiterals.ACCOUNT_RECORDTYPE_HEALTHCARESETTING);
            HealthCareSettingAccount recordData = (HealthCareSettingAccount)System.JSON.deserialize(payload, HealthCareSettingAccount.class);
            String name = '%' + recordData.name + '%';
            String dea = '%' + recordData.dea + '%';
            String addressLine1 = '%' + recordData.addressLine1 + '%';
            String city = '%' + recordData.city + '%';
            String state = '%' + recordData.state + '%';
            String zipCode = '%' + recordData.zip + '%';
            String phone = '%' + recordData.phone + '%';
            String faxNumber = '%' + recordData.faxNumber + '%';
            String email = String.isNotBlank(recordData.emailAddress) ? '%' + recordData.emailAddress + '%' : '';
            String query= 'SELECT Id, US_WSREMS__Status__c FROM Account WHERE Name LIKE :name AND US_WSREMS__Address_Line_1__c LIKE :addressLine1 AND US_WSREMS__DEA__c LIKE :dea AND US_WSREMS__City__c LIKE :city AND US_WSREMS__State__c LIKE :state AND US_WSREMS__Zip__c LIKE :zipCode AND US_WSREMS__Phone_Number__c LIKE :phone AND Fax LIKE :faxNumber AND US_WSREMS__Email__c LIKE :email AND US_WSREMS__REMS_Program__c = :programId AND RecordTypeId = :recordTypeId';
            List<Account> accRecords = Database.query(query);
            if (accRecords != null && !accRecords.isEmpty()) {
                return true;
            }
            return false;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean checkDuplicateForHCProviderAccount(String payload, String programId) {
        try {
            Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER);
            HealthCareProviderAccount recordData = (HealthCareProviderAccount)System.JSON.deserialize(payload, HealthCareProviderAccount.class);
            String firstName = '%' + recordData.firstName + '%';
            String lastName = '%' + recordData.lastName + '%';
            String dea = '%' + recordData.dea + '%';
            String npiNumber = '%' + recordData.npi + '%';
            String query= 'SELECT Id, US_WSREMS__Status__c FROM Account WHERE FirstName LIKE :firstName AND LastName LIKE :lastName AND US_WSREMS__DEA__c LIKE :dea AND US_WSREMS__National_Provider_Identifier__c LIKE :npiNumber AND US_WSREMS__REMS_Program__c = :programId AND RecordTypeId = :recordTypeId';
            List<Account> accRecords = Database.query(query);
            if (accRecords != null && !accRecords.isEmpty()) {
                return true;
            }
            return false;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String insertHealthCareSettingAccount(String payload, String programId) {
        try {
            List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Id = :programId];
            Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(REMSAppLiterals.ACCOUNT_RECORDTYPE_HEALTHCARESETTING);
            HealthCareSettingAccount wrapper = (HealthCareSettingAccount)System.JSON.deserialize(payload, HealthCareSettingAccount.class);
            Account newAccount = new Account();
            newAccount.Name = wrapper.name;
            newAccount.US_WSREMS__DEA__c = wrapper.dea;
            newAccount.US_WSREMS__Address_Line_1__c = wrapper.addressLine1;
            newAccount.US_WSREMS__Address_Line_2__c = wrapper.addressLine2;
            newAccount.US_WSREMS__City__c = wrapper.city;
            newAccount.US_WSREMS__State__c = wrapper.state;
            newAccount.US_WSREMS__Zip__c = wrapper.zip;
            newAccount.US_WSREMS__Zip_Code__c = wrapper.zip;
            newAccount.RecordTypeId = recordTypeId;
            newAccount.US_WSREMS__REMS_Program__c = programId;
            newAccount.US_WSREMS__Program_Picklist__c = (program != null && !program.isEmpty()) ? program.get(0).Name : SYN_Utilitycls.AVEED_PROGRAM_NAME;
            newAccount.ShippingState = wrapper.state;
            newAccount.ShippingCity = wrapper.city;
            newAccount.ShippingPostalCode = wrapper.zip;
            newAccount.ShippingStreet = wrapper.addressLine1 + ' ' + wrapper.addressLine2;
            newAccount.US_WSREMS__Status__c = 'Pending';
            newAccount.US_WSREMS__Healthcare_Setting_Type__c = wrapper.settingType;
            newAccount.US_WSREMS__Phone_Number__c = wrapper.phone;
            newAccount.Phone = wrapper.phone;
            newAccount.Fax = wrapper.faxNumber;
            newAccount.US_WSREMS__Email__c = wrapper.emailAddress;
            newAccount.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
            insert newAccount;
            
            List<Account> insertedAccount = [SELECT Id, PersonContactId, US_WSREMS__User_Type__c, US_WSREMS__REMS_ID__c, RecordType.Name FROM Account WHERE Id = :newAccount.Id];
            
            //Create Service Summary of Participant Account Creation
            US_WSREMS__REMS_Service_Summary__c serviceSummary = NPISearchControllerPortal.insertServiceSummary(newAccount, program, 'Health Care Setting', REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
            
            //Create case with HCS Record Type
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get(REMSAppLiterals.CASE_RECORDTYPE_HEALTHCARESETTING);
            Case caseRec = new Case();
            caseRec.recordTypeId = caseRecordTypeId;
            caseRec.US_WSREMS__Name__c = wrapper.name;
            caseRec.US_WSREMS__DEA__c = wrapper.dea;
            caseRec.US_WSREMS__Address_Line_1__c = wrapper.addressLine1;
            caseRec.US_WSREMS__Address_Line_2__c = wrapper.addressLine2;
            caseRec.US_WSREMS__City__c = wrapper.city;
            caseRec.US_WSREMS__State__c = wrapper.state;
            caseRec.US_WSREMS__Zip__c = wrapper.zip;
            caseRec.US_WSREMS__REMS_Program__c = programId;
            caseRec.US_WSREMS__Program_Picklist__c = (program != null && !program.isEmpty()) ? program.get(0).Name : SYN_Utilitycls.AVEED_PROGRAM_NAME;
            caseRec.US_WSREMS__Healthcare_Setting__c = newAccount.Id;
            caseRec.SYN_Medical_specialty__c = null;
            caseRec.US_WSREMS__NPI_Status__c = 'Valid';
            caseRec.US_WSREMS__Requestor_Type__c = 'Health Care Setting';
            caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Health_Care_Setting';
            caseRec.US_WSREMS__REMS_ID__c = insertedAccount.get(0).US_WSREMS__REMS_ID__c;
            caseRec.US_WSREMS__Healthcare_Setting_Type__c = wrapper.settingType;
            caseRec.US_WSREMS__Phone__c = wrapper.phone;
            caseRec.US_WSREMS__Fax__c = wrapper.faxNumber;
            caseRec.US_WSREMS__Email__c = wrapper.emailAddress;
            caseRec.Email_address__c = wrapper.emailAddress;
            caseRec.US_WSREMS__REMS_Service_Summary__c = serviceSummary.Id;
            caseRec.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
            caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
            caseRec.US_WSREMS__Participant__c = newAccount.Id;
            caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
            insert caseRec;
            
            //update REMS Service
            serviceSummary = NPISearchControllerPortal.updateServiceSummary(serviceSummary);
            return newAccount.Id;
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String insertHealthCareProvider(String payload, String programId) {
        try {
            List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Id = :programId];
            Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER);
            HealthCareProviderAccount wrapper = (HealthCareProviderAccount)System.JSON.deserialize(payload, HealthCareProviderAccount.class);
            Account newAccount = new Account();
            newAccount.FirstName = wrapper.firstName;
            newAccount.LastName = wrapper.lastName;
            newAccount.US_WSREMS__DEA__c = wrapper.dea;
            newAccount.US_WSREMS__National_Provider_Identifier__c = wrapper.npi;
            newAccount.RecordTypeId = recordTypeId;
            newAccount.US_WSREMS__REMS_Program__c = programId;
            newAccount.US_WSREMS__Program_Picklist__c = (program != null && !program.isEmpty()) ? program.get(0).Name : SYN_Utilitycls.AVEED_PROGRAM_NAME;
            newAccount.US_WSREMS__Status__c = null;
            newAccount.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
            insert newAccount;
            
            List<Account> insertedAccount = [SELECT Id, PersonContactId, US_WSREMS__User_Type__c, US_WSREMS__REMS_ID__c, RecordType.Name FROM Account WHERE Id = :newAccount.Id];
            
            //Create Service Summary of Participant Account Creation
            US_WSREMS__REMS_Service_Summary__c serviceSummary = NPISearchControllerPortal.insertServiceSummary(newAccount, program, REMSAppLiterals.REQUESTORTYPE_PRESCRIBER, REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
            
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get(REMSAppLiterals.CASE_RECTYPE_PRESCRIBER_PERSON_ACCOUNT);
            Case caseRec = new Case();
            caseRec.recordTypeId = caseRecordTypeId;
            caseRec.US_WSREMS__First_Name__c = wrapper.firstName;
            caseRec.US_WSREMS__Last_Name__c = wrapper.lastName;
            caseRec.US_WSREMS__DEA__c = wrapper.dea;
            caseRec.US_WSREMS__NPI__c = wrapper.npi;
            caseRec.US_WSREMS__Participant__c = newAccount.Id;
            caseRec.SYN_Medical_specialty__c = null;
            caseRec.US_WSREMS__NPI_Status__c = 'Valid';
            caseRec.US_WSREMS__Requestor_Type__c = 'Prescriber';
            caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Prescriber_Person_Account';
            caseRec.US_WSREMS__REMS_ID__c = insertedAccount.get(0).US_WSREMS__REMS_ID__c;
            caseRec.US_WSREMS__REMS_Program__c = programId;
            caseRec.US_WSREMS__Program_Picklist__c = (program != null && !program.isEmpty()) ? program.get(0).Name : SYN_Utilitycls.AVEED_PROGRAM_NAME;
            caseRec.US_WSREMS__REMS_Service_Summary__c = serviceSummary.Id;
            caseRec.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
            caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
            caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
            insert caseRec;
            
            //update REMS Service
            serviceSummary = NPISearchControllerPortal.updateServiceSummary(serviceSummary);
            return newAccount.Id;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    //create case with HCS Enrollment type and service with Health Care Setting & Enrollment type
    @AuraEnabled
    public static Boolean createCaseAndServiceSummary(String accountId, String programId, String healthCareSettingId, String healthCareProviderId, String ManagePOMEAnaphylaxis) {
        try {
            if (String.isBlank(accountId) || String.isBlank(programId) || String.isBlank(healthCareSettingId)) {
                return false;
            }
            String enrollmentServiceRecordType = 'Enrollment';
            String casePrescriberEnrollmentRecordType = 'HCS_Enrollment';
            String CANCELLED_STATUS = 'Cancelled';
            List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Id = :programId];
            
            SObjectType accountType = Schema.getGlobalDescribe().get('Account');
            Map<String, Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            String query = 'SELECT RecordType.Name, ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE Id = :accountId';
            List<Account> arAccount = Database.query(query);
            
            query = 'SELECT RecordType.Name, ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE Id = :healthCareSettingId';
            List<Account> healthCareAccount = Database.query(query);
            
            List<Account> healthCareProviderAccount = new List<Account>();
            if (String.isNotBlank(healthCareProviderId)) {
                query = 'SELECT RecordType.Name, ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE Id = :healthCareProviderId';
                healthCareProviderAccount = Database.query(query);
            }
            
            US_WSREMS__REMS_Service_Summary__c serviceSummary = NPISearchControllerPortal.insertServiceSummary(healthCareAccount.get(0), program, healthCareAccount.get(0).RecordType.Name, enrollmentServiceRecordType);
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get(casePrescriberEnrollmentRecordType);
            List<Case> enrollmentCases = [SELECT Id FROM Case WHERE US_WSREMS__Participant__c = :healthCareSettingId and RecordTypeId = :caseRecordTypeId AND Status != :CANCELLED_STATUS];
            if (enrollmentCases == null || enrollmentCases.isEmpty()) {           
                Case caseRec = new Case();
                caseRec.RecordTypeId = caseRecordTypeId;
                //Authorized Representative Information
                caseRec.US_WSREMS__REMS_Authorized_Rep__c = arAccount.get(0).Id;
                caseRec.US_WSREMS__First_Name_ar__c = arAccount.get(0).FirstName;
                caseRec.US_WSREMS__Middle_Name__c = arAccount.get(0).MiddleName;
                caseRec.US_WSREMS__Last_Name_ar__c = arAccount.get(0).LastName;
                caseRec.US_WSREMS__Title__c = arAccount.get(0).US_WSREMS__Title__c;
                caseRec.US_WSREMS__REMS_Job_Title__c = arAccount.get(0).US_WSREMS__Title__c;
                caseRec.US_WSREMS__Email_ar__c = arAccount.get(0).PersonEmail;
                caseRec.US_WSREMS__Phone_ar__c = arAccount.get(0).US_WSREMS__Phone_Number__c;
                caseRec.US_WSREMS__Ext__c = arAccount.get(0).US_WSREMS__Ext__c;
                caseRec.US_WSREMS__Prescriber_Fax__c = arAccount.get(0).Fax;
                caseRec.US_WSREMS__Participant_Fax__c = arAccount.get(0).Fax;
                caseRec.US_WSREMS__Preferred_Contact_Method__c = arAccount.get(0).US_WSREMS__Preferred_Contact_Method__c;
                //caseRec.US_WSREMS__Professional_Designation__c = arAccount.get(0).US_WSREMS__Professional_Designation__c;
                
                //Healthcare Setting Information
                caseRec.US_WSREMS__Name__c = healthCareAccount.get(0).Name;
                caseRec.US_WSREMS__Healthcare_Setting__c = healthCareAccount.get(0).Id;
                caseRec.US_WSREMS__DEA__c = healthCareAccount.get(0).US_WSREMS__DEA__c;
                caseRec.US_WSREMS__Healthcare_Setting_Type__c = healthCareAccount.get(0).US_WSREMS__Healthcare_Setting_Type__c;
                caseRec.US_WSREMS__Phone__c = healthCareAccount.get(0).US_WSREMS__Phone_Number__c;
                caseRec.US_WSREMS__Fax__c = healthCareAccount.get(0).Fax;
                caseRec.US_WSREMS__Email__c = healthCareAccount.get(0).US_WSREMS__Email__c;
                caseRec.US_WSREMS__Address__c = healthCareAccount.get(0).US_WSREMS__Address_Line_1__c + ' ' + healthCareAccount.get(0).US_WSREMS__Address_Line_2__c;
                caseRec.US_WSREMS__Address_Line_1__c = healthCareAccount.get(0).US_WSREMS__Address_Line_1__c;
                caseRec.US_WSREMS__Address_Line_2__c = healthCareAccount.get(0).US_WSREMS__Address_Line_2__c;
                caseRec.US_WSREMS__City__c = healthCareAccount.get(0).US_WSREMS__City__c;
                caseRec.US_WSREMS__State__c = healthCareAccount.get(0).US_WSREMS__State__c;
                caseRec.US_WSREMS__Zip__c = healthCareAccount.get(0).US_WSREMS__Zip__c;
                caseRec.US_WSREMS__Zipcode__c = healthCareAccount.get(0).US_WSREMS__Zip__c;
                
                if (!healthCareProviderAccount.isEmpty()) {
                //Certified Healthcare Providers
                    caseRec.US_WSREMS__Prescriber__c = healthCareProviderAccount.get(0).Id;
                    caseRec.US_WSREMS__Prescriber_First_Name__c = healthCareProviderAccount.get(0).FirstName;
                    caseRec.US_WSREMS__Prescriber_Last_Name__c = healthCareProviderAccount.get(0).LastName;
                    caseRec.US_WSREMS__Prescriber_NPI__c = healthCareProviderAccount.get(0).US_WSREMS__National_Provider_Identifier__c;
                    caseRec.US_WSREMS__NPI__c = healthCareProviderAccount.get(0).US_WSREMS__National_Provider_Identifier__c;
                    caseRec.SYN_DEA__c = healthCareProviderAccount.get(0).US_WSREMS__DEA__c;
                    caseRec.US_WSREMS__NPI_Status__c = healthCareProviderAccount.get(0).US_WSREMS__NPI_Status__c;
                }
                
                caseRec.US_WSREMS__Participant__c = healthCareAccount.get(0).Id;
                caseRec.US_WSREMS__REMS_Service_Summary__c = serviceSummary.Id;
                caseRec.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
                caseRec.US_WSREMS__REMS_Program__c = program[0].Id;
                caseRec.ManagePOMEorAnaphylaxis__c = ManagePOMEAnaphylaxis;
                if(ManagePOMEAnaphylaxis == 'No'){
                    caseRec.Status = 'Draft'; 
                    caseRec.US_WSREMS__Outcome__c ='';
                } else if(ManagePOMEAnaphylaxis == 'Yes' && healthCareProviderAccount.get(0).US_WSREMS__Status__c == 'Certified'){
                    caseRec.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
                    caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
            	}else if(ManagePOMEAnaphylaxis == 'Yes' && healthCareProviderAccount.get(0).US_WSREMS__Status__c != 'Certified'){
                	caseRec.Status = 'Draft'; 
                    caseRec.US_WSREMS__Outcome__c ='';
            	}
                
                caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
                caseRec.US_WSREMS__Requestor_Type__c = 'Health Care Setting';
                caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Health_Care_Setting';
            
                caseRec.US_WSREMS__Signature__c = 'Yes';
                caseRec.US_WSREMS__Signature_Date_Pharmacist__c = System.Today();
                insert caseRec;
                serviceSummary = NPISearchControllerPortal.updateServiceSummary(serviceSummary);
                
                if (healthCareProviderAccount != null && !healthCareProviderAccount.isEmpty()) {
                    if (ManagePOMEAnaphylaxis == 'Yes' && healthCareProviderAccount.get(0).US_WSREMS__Status__c == 'Certified') {
                        Account hcsToCertify = new Account(Id = healthCareSettingId, US_WSREMS__Status__c = 'Certified');
                        update hcsToCertify;
                    }
                }
            }
            else {
                addARAffiliations(program[0].Id, accountId, healthCareSettingId);
                addPrescriberAffiliations(program[0].Id, healthCareProviderId, healthCareSettingId);
            }
            deleteDuplicatePACServices(accountId, healthCareSettingId, healthCareProviderId, program[0].Id);
            return true;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            System.debug(LoggingLevel.ERROR, ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean updateArRecord(String payload, String accountId) {
        try {
            if (String.isBlank(accountId) || String.isBlank(payload)) {
                return false;
            }
            AccountRecordWrapper recordData = (AccountRecordWrapper)System.JSON.deserialize(payload, AccountRecordWrapper.class);
            Account accToUpdate = new Account(Id = accountId);
            accToUpdate.FirstName = recordData.firstName;
            accToUpdate.MiddleName = recordData.middleName;
            accToUpdate.LastName = recordData.lastName;
            accToUpdate.US_WSREMS__Title__c = recordData.title;
            accToUpdate.US_WSREMS__Phone_Number__c = recordData.phoneNumber;
            accToUpdate.Fax = recordData.faxNumber;
            accToUpdate.US_WSREMS__EXT__c = recordData.extension;
            accToUpdate.Phone = recordData.phoneNumber;
            accToUpdate.US_WSREMS__Professional_Designation__c = recordData.credentials;
            if (recordData.credentials == REMSAppLiterals.CREDENTIALS_OTHER) {
                accToUpdate.US_WSREMS__Credentials__c = REMSAppLiterals.CREDENTIALS_OTHER;
                accToUpdate.US_WSREMS__Other_Credentials__c = recordData.othercredentials;
            } else {
                accToUpdate.US_WSREMS__Other_Credentials__c = null;
            }
            accToUpdate.US_WSREMS__Preferred_Contact_Method__c = recordData.preferredContactMethod;
            
            update accToUpdate;
            return true;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            System.debug(LoggingLevel.ERROR, ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean saveARSignature(String accountId, String signData) {
        try {
            if (String.isBlank(accountId) || String.isBlank(signData)) {
                return false;
            }
            //Create Attachment
            Attachment signatureAttachment = new Attachment(
                ParentId = accountId, 
                Name = 'Signature_' + String.valueOf(Date.today()).substring(0,10),
                Body =  EncodingUtil.base64Decode(signData),
                contentType = 'image/jpeg'
            );
            insert signatureAttachment;
            
            Account accUpdate = new Account(Id = accountId);
            accUpdate.US_WSREMS__Prescriber_Signature__c = 'Yes';
            accUpdate.US_WSREMS__Prescriber_Signature_Date__c = Date.today();
            update accUpdate;
            return true;
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            System.debug(LoggingLevel.ERROR, ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @future
    private static void deleteDuplicatePACServices(String arAccountId, String healthCareSettingId, String prescriberId, Id programId) {
        Set<Id> participantIds = new Set<Id>{arAccountId, healthCareSettingId, prescriberId};
        List<US_WSREMS__REMS_Service_Summary__c> servicesToDelete = new List<US_WSREMS__REMS_Service_Summary__c>(); 
        //Delete services that not associated to any cases
        for (US_WSREMS__REMS_Service_Summary__c service : [SELECT Id, (SELECT Id, US_WSREMS__REMS_Service_Summary__c FROM US_WSREMS__Cases__r) 
                                                           FROM US_WSREMS__REMS_Service_Summary__c 
                                                           WHERE US_WSREMS__Participant__c IN :participantIds]) 
        {
            if (service.US_WSREMS__Cases__r == null || service.US_WSREMS__Cases__r.isEmpty()) {
                servicesToDelete.add(service);
            }
        }
        
        if (!servicesToDelete.isEmpty()) {
            delete servicesToDelete;
        }

        List<US_WSREMS__Affiliation__c> affiliationsToActivate = new List<US_WSREMS__Affiliation__c>();
        if (String.isNotBlank(prescriberId)) {
            for (US_WSREMS__Affiliation__c affiliation : [SELECT Id, US_WSREMS__Prescriber__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__isActive__c, US_WSREMS__End_Date__c, US_WSREMS__Start_Date__c 
                                                          FROM US_WSREMS__Affiliation__c 
                                                          WHERE US_WSREMS__Prescriber__c = :prescriberId 
                                                          AND US_WSREMS__Health_Care_Setting__c = :healthCareSettingId 
                                                          AND US_WSREMS__REMSProgram__c = :programId
                                                          AND US_WSREMS__isActive__c = false])
            {
                affiliationsToActivate.add(
                    new US_WSREMS__Affiliation__c(
                        Id = affiliation.Id,
                        US_WSREMS__isActive__c = true,
                        US_WSREMS__End_Date__c = null,
                        US_WSREMS__Start_Date__c = System.today()
                    )
                );
            }
        }
        
        for (US_WSREMS__Affiliation__c affiliation : [SELECT Id, US_WSREMS__Prescriber__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__isActive__c, US_WSREMS__Start_Date__c, US_WSREMS__End_Date__c 
                                                      FROM US_WSREMS__Affiliation__c 
                                                      WHERE US_WSREMS__Authorized_Representative__c = :arAccountId 
                                                      AND US_WSREMS__Health_Care_Setting__c =: healthCareSettingId 
                                                      AND US_WSREMS__REMSProgram__c = :programId 
                                                      AND US_WSREMS__isActive__c = false])
        {
            affiliationsToActivate.add(
                new US_WSREMS__Affiliation__c(
                    Id = affiliation.Id,
                    US_WSREMS__isActive__c = true,
                    US_WSREMS__End_Date__c = null,
                    US_WSREMS__Start_Date__c = System.today()
            	)
            );
        }
        
        if (!affiliationsToActivate.isEmpty()) {
            update affiliationsToActivate;
        }
    }
    
    public class HealthCareSettingAccount {
        public String name;
        public String dea;
        public String addressLine1;
        public String addressLine2;
        public String city;
        public String state;
        public String zip;
        public String settingType;
        public String phone;
        public String faxNumber;
        public String emailAddress;
    }
    
    public class HealthCareProviderAccount {
        public String firstName;
        public String lastName;
        public String dea;
        public String npi;
    }
    
    public class AccountRecordWrapper {
        public String firstName;
        public String lastName;
        public String middleName;
        public String title;
        public String phoneNumber;
        public String extension;
        public String faxNumber;
        public String preferredContactMethod;
        public String credentials;
        public String othercredentials;
    }
}