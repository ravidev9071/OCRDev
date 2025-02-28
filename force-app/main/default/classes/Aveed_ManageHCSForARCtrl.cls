public without sharing class Aveed_ManageHCSForARCtrl {
    
    public class HealthCareSettingData {
        @AuraEnabled
        public Account hcsSetting;
        @AuraEnabled
        public List<Account> hcsProviders;
    }
    
    public class ManageCurrentAccountHCSDetails {
        @AuraEnabled
        public Account currentAccount;
        @AuraEnabled
        public Account hcsSetting;
        @AuraEnabled
        public Case hcsEnrollmentCase;
    }
    
    @AuraEnabled
    public static Boolean updateARVerification(Id hcsId, Boolean isChecked) {
        if (String.isBlank(hcsId)) {
            return false;
        }
        Account hcsSettingAccount = new Account(Id = hcsId);
        hcsSettingAccount.US_WSREMS__VerificationComplete__c = isChecked;
        hcsSettingAccount.US_WSREMS__VerificationDueDate__c = System.Now().addMonths(12);
        update hcsSettingAccount;
        return true;
    }
    
    @AuraEnabled
    public static List<Account> getRelatedHealthcareSettings() {
        List<User> currentUser = [SELECT Id, Name, Email, AccountId, ContactId FROM User WHERE ContactId != null AND Id = :UserInfo.getUserId()];
        if (currentUser == null || currentUser.isEmpty()) {
            return null;
        }
        Set<Id> healthcaresettingIds = new Set<Id>();
        for (US_WSREMS__Affiliation__c affiliation : [SELECT Id, US_WSREMS__Authorized_Representative__c, US_WSREMS__Prescriber__c, US_WSREMS__isActive__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Start_Date__c, US_WSREMS__Health_Care_Setting__r.Name, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c 
                                                      FROM US_WSREMS__Affiliation__c 
                                                      WHERE US_WSREMS__Authorized_Representative__c = :currentUser.get(0).AccountId
                                                      AND US_WSREMS__isActive__c = TRUE
                                                      AND US_WSREMS__Start_Date__c != NULL
                                                      AND US_WSREMS__Health_Care_Setting__c != NULL])
        {
            healthcaresettingIds.add(affiliation.US_WSREMS__Health_Care_Setting__c);
        }
        Id recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        Map<String, Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        String queryString = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE RecordTypeId = :recordtypeId AND US_WSREMS__Program_Picklist__c = :programName';
        queryString += ' AND Id IN :healthcaresettingIds';
        return Database.query(queryString);
    }
    
    @AuraEnabled
    public static Boolean disassociateHCSFromAR(Id hcsSettingId) {
        if (String.isBlank(hcsSettingId)) {
            return false;
        }
        List<User> currentUser = [SELECT Id, Name, Email, AccountId, ContactId FROM User WHERE ContactId != null AND Id = :UserInfo.getUserId()];
        if (currentUser == null || currentUser.isEmpty()) {
            return false;
        }
        List<US_WSREMS__Affiliation__c> affiliationToUpdate = new List<US_WSREMS__Affiliation__c>();
        for (US_WSREMS__Affiliation__c affiliation : [SELECT Id, US_WSREMS__Authorized_Representative__c, US_WSREMS__Prescriber__c, US_WSREMS__isActive__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Start_Date__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c 
                                                      FROM US_WSREMS__Affiliation__c 
                                                      WHERE US_WSREMS__Authorized_Representative__c = :currentUser.get(0).AccountId
                                                      AND US_WSREMS__Health_Care_Setting__c = :hcsSettingId
                                                      AND US_WSREMS__isActive__c = TRUE
                                                      AND US_WSREMS__Start_Date__c != NULL])
        {
            affiliation.US_WSREMS__isActive__c = false;
            affiliation.US_WSREMS__End_Date__c = Date.today();
            affiliationToUpdate.add(affiliation);
        }
        
        if (!affiliationToUpdate.isEmpty()) {
            update affiliationToUpdate;
        }
        return true;
    }
    
    @AuraEnabled
    public static HealthCareSettingData getHCSWithProvidersDetail(Id hcsId) {
        HealthCareSettingData details = new HealthCareSettingData();
        Id recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        Map<String, Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        String queryString = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE RecordTypeId = :recordtypeId AND US_WSREMS__Program_Picklist__c = :programName';
        queryString += ' AND Id = :hcsId';
        List<Account> hcsSettings = Database.query(queryString);
        details.hcsSetting = hcsSettings.get(0);
        Set<Id> hcsproviderIds = new Set<Id>();
        for (US_WSREMS__Affiliation__c affiliation : [SELECT Id, US_WSREMS__Authorized_Representative__c, US_WSREMS__Prescriber__c, US_WSREMS__isActive__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Start_Date__c, US_WSREMS__Health_Care_Setting__r.Name, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c 
                                                      FROM US_WSREMS__Affiliation__c 
                                                      WHERE US_WSREMS__Health_Care_Setting__c = :hcsId
                                                      AND US_WSREMS__isActive__c = TRUE
                                                      AND US_WSREMS__Start_Date__c != NULL
                                                      AND US_WSREMS__Prescriber__c != NULL])
        {
            hcsproviderIds.add(affiliation.US_WSREMS__Prescriber__c);
        }
        if(!hcsproviderIds.isEmpty()){
            List<Account> hcsProviders= [SELECT Id, Name, US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c, US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Zip__c, US_WSREMS__DEA__c, US_WSREMS__REMS_ID__c, US_WSREMS__NPI__c, US_WSREMS__Healthcare_Setting_Type__c, US_WSREMS__Status__c, US_WSREMS__Date_Enrolled__c, US_WSREMS__Role__c,
                                        (SELECT Id, US_WSREMS__Health_Care_Setting__r.Name, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c
                                        FROM US_WSREMS__Prescriber_PrescribingInstitution__r WHERE US_WSREMS__isActive__c = TRUE AND US_WSREMS__Start_Date__c != NULL ORDER BY US_WSREMS__Start_Date__c ASC LIMIT 1)
                                        FROM Account 
                                        WHERE Id IN :hcsproviderIds];

            if(!hcsProviders.isEmpty()){
                details.hcsProviders = hcsProviders;
            }
        }
        return details;
    }
    
    @AuraEnabled
    public static ManageCurrentAccountHCSDetails getCurrentAccountHCSDetails(Id hcsId) {
        ManageCurrentAccountHCSDetails details = new ManageCurrentAccountHCSDetails();
        Id currentUserId = UserInfo.getUserId();
        SObjectType userType = Schema.getGlobalDescribe().get('User');
        Map<String, Schema.SObjectField> mfields = userType.getDescribe().fields.getMap();
        String query = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM User WHERE Id = :currentUserId';
        List<User> users = Database.query(query);
        Id accountId = users.get(0).AccountId;
        SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        mfields = accountType.getDescribe().fields.getMap();
        query = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE Id = :accountId';
        List<Account> accounts = Database.query(query);
        details.currentAccount = accounts.get(0);
        
        query = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE Id = :hcsId';
        accounts = Database.query(query);
        details.hcsSetting = accounts.get(0);
        
        String casePrescriberEnrollmentRecordType = 'HCS_Enrollment';
        Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get(casePrescriberEnrollmentRecordType);
        SObjectType caseType = Schema.getGlobalDescribe().get('Case');
        mfields = caseType.getDescribe().fields.getMap();
        query = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Case WHERE US_WSREMS__REMS_Authorized_Rep__c = :accountId AND US_WSREMS__Participant__c = :hcsId';
        query += ' AND RecordTypeId = :caseRecordTypeId ORDER BY CreatedDate DESC LIMIT 1';
        List<Case> hcsEnrollmentCases = Database.query(query);
        if (hcsEnrollmentCases != null && !hcsEnrollmentCases.isEmpty()) {
            details.hcsEnrollmentCase = hcsEnrollmentCases.get(0);
        }
        return details;
    }
    
    @AuraEnabled
    public static Boolean updateHCSAccountRecord(String arAccountId, String payload, String accountId, String operationType, String ManagePOMEAnaphylaxis) {
        try {
            if (String.isBlank(accountId) || String.isBlank(payload)) {
                return false;
            }
            Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount wrapper = (Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount)System.JSON.deserialize(payload, Aveed_PharmHCSEnrollmentCtrl.HealthCareSettingAccount.class);
            Account accToUpdate = new Account(Id = accountId);
            accToUpdate.Name = wrapper.name;
            accToUpdate.US_WSREMS__DEA__c = wrapper.dea;
            accToUpdate.US_WSREMS__Address_Line_1__c = wrapper.addressLine1;
            accToUpdate.US_WSREMS__Address_Line_2__c = wrapper.addressLine2;
            accToUpdate.US_WSREMS__City__c = wrapper.city;
            accToUpdate.US_WSREMS__State__c = wrapper.state;
            accToUpdate.US_WSREMS__Zip__c = wrapper.zip;
            accToUpdate.US_WSREMS__Zip_Code__c = wrapper.zip;
            accToUpdate.ShippingState = wrapper.state;
            accToUpdate.ShippingCity = wrapper.city;
            accToUpdate.ShippingPostalCode = wrapper.zip;
            accToUpdate.ShippingStreet = wrapper.addressLine1 + ' ' + wrapper.addressLine2;
            accToUpdate.US_WSREMS__Healthcare_Setting_Type__c = wrapper.settingType;
            accToUpdate.US_WSREMS__Phone_Number__c = wrapper.phone;
            accToUpdate.Phone = wrapper.phone;
            accToUpdate.Fax = wrapper.faxNumber;
            accToUpdate.US_WSREMS__Email__c = wrapper.emailAddress;
            update accToUpdate;
            
            if (operationType == 'Edit') {
                List<Account> accList = [SELECT Id, PersonContactId, US_WSREMS__User_Type__c, US_WSREMS__REMS_ID__c, RecordType.Name, US_WSREMS__REMS_Program__c FROM Account WHERE Id = :accountId LIMIT 1];
                String recordTypeName = accList[0].RecordType.Name;
                List<US_WSREMS__REMS_Program__c> program = [SELECT Id,Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Id = :accList[0].US_WSREMS__REMS_Program__c];
                //COI
                US_WSREMS__REMS_Service_Summary__c serviceSummary = NPISearchControllerPortal.insertServiceSummary(accList[0], program, recordTypeName, REMSAppLiterals.CHANGE_OF_INFORMATION);
                Case caseRec = new Case();
                Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get(REMSAppLiterals.CHANGE_OF_INFORMATION);
                if (serviceSummary != null) {
                    caseRec.recordTypeId = caseRecordTypeId;
                    caseRec.US_WSREMS__Name__c = wrapper.name;
                    caseRec.US_WSREMS__DEA__c = wrapper.dea;
                    caseRec.US_WSREMS__Address_Line_1__c = wrapper.addressLine1;
                    caseRec.US_WSREMS__Address_Line_2__c = wrapper.addressLine2;
                    caseRec.US_WSREMS__City__c = wrapper.city;
                    caseRec.US_WSREMS__State__c = wrapper.state;
                    caseRec.US_WSREMS__Zip__c = wrapper.zip;
                    caseRec.US_WSREMS__REMS_Program__c = program.get(0).Id;
                    caseRec.US_WSREMS__Program_Picklist__c = (program != null && !program.isEmpty()) ? program.get(0).Name : SYN_Utilitycls.AVEED_PROGRAM_NAME;
                    caseRec.US_WSREMS__Healthcare_Setting__c = accountId;
                    caseRec.SYN_Medical_specialty__c = null;
                    caseRec.US_WSREMS__NPI_Status__c = 'Valid';
                    caseRec.US_WSREMS__Requestor_Type__c = 'Health Care Setting';
                    caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Health_Care_Setting';
                    caseRec.US_WSREMS__REMS_ID__c = accList.get(0).US_WSREMS__REMS_ID__c;
                    caseRec.US_WSREMS__Healthcare_Setting_Type__c = wrapper.settingType;
                    caseRec.US_WSREMS__Phone__c = wrapper.phone;
                    caseRec.US_WSREMS__Fax__c = wrapper.faxNumber;
                    caseRec.US_WSREMS__Email__c = wrapper.emailAddress;
                    caseRec.Email_address__c = wrapper.emailAddress;
                    caseRec.US_WSREMS__REMS_Service_Summary__c = serviceSummary.Id;
                    caseRec.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
                    caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
                    caseRec.US_WSREMS__Participant__c = accountId;
                    insert caseRec;
                }
                if (caseRec != null) {
                    US_WSREMS__REMS_Service_Summary__c serviceSummaryRec = NPISearchControllerPortal.updateServiceSummary(serviceSummary);
                }
            }
            else if (operationType == 'Re-enroll') {
                //Reenrollment
                createReEnrollmentCaseServiceSummary(accountId, arAccountId, ManagePOMEAnaphylaxis);
            }
            return true;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            System.debug(LoggingLevel.ERROR, ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void createReEnrollmentCaseServiceSummary(Id hcsAccountId, Id arAccountId, String ManagePOMEAnaphylaxis) {
        String reEnrollmentServiceRecordType = 'ReCertification';
        String reEnrollmentCaseRecordTpe = 'ReCertification';
        SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        Map<String, Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        String query = 'SELECT RecordType.Name, ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE Id = :arAccountId';
        List<Account> arAccount = Database.query(query);
        
        query = 'SELECT RecordType.Name, ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE Id = :hcsAccountId';
        List<Account> healthCareAccount = Database.query(query);
        
        String recordTypeName = healthCareAccount.get(0).RecordType.Name;
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Id = :arAccount.get(0).US_WSREMS__REMS_Program__c];
        US_WSREMS__REMS_Service_Summary__c serviceSummary = NPISearchControllerPortal.insertServiceSummary(healthCareAccount.get(0), program, recordTypeName, reEnrollmentServiceRecordType);
        Case caseRec = new Case();
        Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get(reEnrollmentCaseRecordTpe);
        caseRec.recordTypeId = caseRecordTypeId;
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
        
        caseRec.US_WSREMS__Participant__c = healthCareAccount.get(0).Id;
        caseRec.US_WSREMS__REMS_Service_Summary__c = serviceSummary.Id;
        caseRec.US_WSREMS__REMS_Program__c = program.get(0).Id;
        caseRec.US_WSREMS__Program_Picklist__c = (program != null && !program.isEmpty()) ? program.get(0).Name : SYN_Utilitycls.AVEED_PROGRAM_NAME;
        caseRec.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
        caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
        caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
        caseRec.US_WSREMS__Requestor_Type__c = 'Health Care Setting';
        caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Recertification';
        caseRec.ManagePOMEorAnaphylaxis__c = ManagePOMEAnaphylaxis;
        caseRec.SYN_Medical_specialty__c = null;
        caseRec.US_WSREMS__NPI_Status__c = 'Valid';
        caseRec.US_WSREMS__Signature__c = 'Yes';
        caseRec.US_WSREMS__Signature_Date_Pharmacist__c = System.Today();
        caseRec.US_WSREMS__AR_Signature_Date_New_Primary_AR__c = System.Today();
        caseRec.US_WSREMS__Signature_Date__c = System.Today();
        insert caseRec;
        if (caseRec != null) {
            US_WSREMS__REMS_Service_Summary__c serviceSummaryRec = NPISearchControllerPortal.updateServiceSummary(serviceSummary);
        }
    }

}