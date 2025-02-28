public without sharing class Aveed_HCPEnrollmentCtrl {
    
    public class CurrentUserDetails {
        @AuraEnabled
        public Account userAccount;
        @AuraEnabled
        public User currentUser;
    }
    
    @AuraEnabled(cacheable=true)
    public static CurrentUserDetails getCurrentUserAccount() {
        CurrentUserDetails details = new CurrentUserDetails();
        Id currentUserId = UserInfo.getUserId();
        SObjectType userType = Schema.getGlobalDescribe().get('User');
        Map<String, Schema.SObjectField> mfields = userType.getDescribe().fields.getMap();
        String query = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM User WHERE Id = :currentUserId';
        List<User> users = Database.query(query);
        details.currentUser = users.get(0);
        Id accountId = users.get(0).AccountId;
        SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        mfields = accountType.getDescribe().fields.getMap();
        query = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE Id = :accountId';
        List<Account> accounts = Database.query(query);
        details.userAccount = accounts.get(0);
        return details;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, String>> getPicklistFieldValues(String objectName, String fieldAPIName) {
        Map<String, Map<String, String>> mapToReturn = new Map<String, Map<String,String>>();
        List<String> fieldNameList = new List<String>();
        fieldNameList.add(fieldAPIName);
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        for(String fieldName: fieldNameList){
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            Map<String, String> picklistMap = new Map<String, String>();
            for( Schema.PicklistEntry pickListVal : ple){
                picklistMap.put(pickListVal.getLabel(), pickListVal.getValue());
            }
            mapToReturn.put(fieldName, picklistMap);
        }
        return mapToReturn;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> searchRecords(String searchString) {
        if (String.isBlank(searchString)) {
            return null;
        }
        // Perform SOQL query based on search criteria
        Id recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        List<String> includedStatus = new List<String>{'Certified'};
        String queryString = 'SELECT Id, Name, US_WSREMS__Address_Line_1__c, US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Zip__c, ShippingCountry, US_WSREMS__NPI__c, Address_1_Secondary_Office__c, Phone, Fax, US_WSREMS__REMS_ID__c FROM Account WHERE RecordTypeId = :recordtypeId AND US_WSREMS__Program_Picklist__c = :programName'; 
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
    public static Boolean addAffiliations(String programId, String accountId, String healthCareSettingId) {
        try {
            //SOQL to check duplicate Affiliations.
            List<US_WSREMS__Affiliation__c> dupAffiliations = [SELECT Id, US_WSREMS__Prescriber__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__isActive__c, US_WSREMS__End_Date__c 
                                                               FROM US_WSREMS__Affiliation__c
                                                               WHERE US_WSREMS__Prescriber__c =: accountId 
                                                               AND US_WSREMS__Health_Care_Setting__c =: healthCareSettingId 
                                                               AND US_WSREMS__isActive__c = true];
            if (dupAffiliations != null && !dupAffiliations.isEmpty()) {
                return true;
            } else {
                Id recordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Healthcare_Setting_Affiliation').getRecordTypeId();
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
            }
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
            String addressLine1 = '%' + recordData.addressLine1 + '%';
            String addressLine2 = '%' + recordData.addressLine2 + '%';
            String city = '%' + recordData.city + '%';
            String state = '%' + recordData.state + '%';
            String zipCode = '%' + recordData.zipCode + '%';
            String query= 'SELECT Id, US_WSREMS__Status__c FROM Account WHERE Name LIKE :name AND US_WSREMS__Address_Line_1__c LIKE :addressLine1 AND US_WSREMS__City__c LIKE :city AND US_WSREMS__State__c LIKE :state AND US_WSREMS__Zip__c LIKE :zipCode AND US_WSREMS__REMS_Program__c = :programId AND RecordTypeId = :recordTypeId';
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
            Map<String,US_WSREMS__REMS_Program__c> programList= SYN_CommonUtility.getActiveProgramIds();
            List<US_WSREMS__REMS_Program__c> program =new List<US_WSREMS__REMS_Program__c>{programList.get(SYN_Utilitycls.AVEED_PROGRAM_NAME)};
            Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(REMSAppLiterals.ACCOUNT_RECORDTYPE_HEALTHCARESETTING);
           	HealthCareSettingAccount wrapper = (HealthCareSettingAccount)System.JSON.deserialize(payload, HealthCareSettingAccount.class);
            Account newAccount = new Account();
            newAccount.Name = wrapper.name;
            newAccount.US_WSREMS__Address_Line_1__c = wrapper.addressLine1;
            newAccount.US_WSREMS__Address_Line_2__c = wrapper.addressLine2;
            newAccount.US_WSREMS__City__c = wrapper.city;
            newAccount.US_WSREMS__State__c = wrapper.state;
            newAccount.US_WSREMS__Zip__c = wrapper.zipCode;
            newAccount.US_WSREMS__Zip_Code__c = wrapper.zipCode;
            newAccount.RecordTypeId = recordTypeId;
            newAccount.US_WSREMS__REMS_Program__c = programId;
            newAccount.US_WSREMS__Program_Picklist__c = (program != null && !program.isEmpty()) ? program.get(0).Name : SYN_Utilitycls.AVEED_PROGRAM_NAME;
            newAccount.ShippingState = wrapper.state;
            newAccount.ShippingCity = wrapper.city;
            newAccount.ShippingPostalCode = wrapper.zipCode;
            newAccount.ShippingStreet = wrapper.addressLine1 + ' ' + wrapper.addressLine2;
            newAccount.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
            insert newAccount;
            
            List<Account> insertedAccount = [SELECT Id, PersonContactId, US_WSREMS__User_Type__c, US_WSREMS__REMS_ID__c, RecordType.Name FROM Account WHERE Id = :newAccount.Id];
            
            //Create case with HCS Record Type
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get(REMSAppLiterals.CASE_RECORDTYPE_HEALTHCARESETTING);
            Case caseRec = new Case();
            caseRec.recordTypeId = caseRecordTypeId;
            caseRec.US_WSREMS__Name__c = wrapper.name;
            caseRec.US_WSREMS__Address_Line_1__c = wrapper.addressLine1;
            caseRec.US_WSREMS__Address_Line_2__c = wrapper.addressLine2;
            caseRec.US_WSREMS__City__c = wrapper.city;
            caseRec.US_WSREMS__State__c = wrapper.state;
            caseRec.US_WSREMS__Zip__c = wrapper.zipCode;
            caseRec.US_WSREMS__REMS_Program__c = programId;
            caseRec.US_WSREMS__Program_Picklist__c = (program != null && !program.isEmpty()) ? program.get(0).Name : SYN_Utilitycls.AVEED_PROGRAM_NAME;
            caseRec.US_WSREMS__Healthcare_Setting__c = newAccount.Id;
            caseRec.SYN_Medical_specialty__c = null;
            caseRec.US_WSREMS__NPI_Status__c = 'Valid';
            caseRec.US_WSREMS__Requestor_Type__c = 'Health Care Setting';
            caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Health_Care_Setting';
            caseRec.US_WSREMS__REMS_ID__c = insertedAccount.get(0).US_WSREMS__REMS_ID__c;
            caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
            insert caseRec;
            
            //Create Service Summary of Participant Account Creation
            US_WSREMS__REMS_Service_Summary__c serviceSummary = NPISearchControllerPortal.insertServiceSummary(newAccount, program, 'Health Care Setting', REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
            
            //Update case
            Case caseToUpdate = new Case(Id = caseRec.Id);
            caseToUpdate.US_WSREMS__REMS_Service_Summary__c = serviceSummary.Id;
            caseToUpdate.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
            caseToUpdate.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
            caseToUpdate.US_WSREMS__Participant__c = newAccount.Id;
            update caseToUpdate;
            
            //update REMS Service
            serviceSummary = NPISearchControllerPortal.updateServiceSummary(serviceSummary);
            return newAccount.Id;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean createCaseAndServiceSummary(String accountId, String programId, String healthCareSettingId) {
        try {
            if (String.isBlank(accountId) || String.isBlank(programId) || String.isBlank(healthCareSettingId)) {
                return false;
            }
            String CANCELLED_STATUS = 'Cancelled';
            String enrollmentServiceRecordType = 'Enrollment';
            String casePrescriberEnrollmentRecordType = 'Prescriber_enrollment';
            Map<String,US_WSREMS__REMS_Program__c> programList= SYN_CommonUtility.getActiveProgramIds();
            
            List<US_WSREMS__REMS_Program__c> program =new List<US_WSREMS__REMS_Program__c>{programList.get(SYN_Utilitycls.AVEED_PROGRAM_NAME)};
                
            SObjectType accountType = Schema.getGlobalDescribe().get('Account');
            Map<String, Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            String query = 'SELECT RecordType.Name, ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE Id = :accountId';
            List<Account> prescriberAccount = Database.query(query);
            
            query = 'SELECT RecordType.Name, ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE Id = :healthCareSettingId';
            List<Account> healthCareAccount = Database.query(query);
            
            US_WSREMS__REMS_Service_Summary__c serviceSummary = NPISearchControllerPortal.insertServiceSummary(prescriberAccount.get(0), program, prescriberAccount.get(0).RecordType.Name, enrollmentServiceRecordType);
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get(casePrescriberEnrollmentRecordType);
            List<Case> enrollmentCases = [SELECT Id FROM Case WHERE US_WSREMS__Participant__c = :accountId AND recordTypeId = :caseRecordTypeId AND status != :CANCELLED_STATUS];
            if (enrollmentCases.isEmpty()) {
                Case caseRec = new Case();
                caseRec.US_WSREMS__First_Name__c = prescriberAccount.get(0).FirstName;
                caseRec.US_WSREMS__Middle_Name__c = prescriberAccount.get(0).MiddleName;
                caseRec.US_WSREMS__Last_Name__c = prescriberAccount.get(0).LastName;
                caseRec.US_WSREMS__Professional_Designation__c = prescriberAccount.get(0).US_WSREMS__Professional_Designation__c;
                caseRec.US_WSREMS__Speciality__c = prescriberAccount.get(0).US_WSREMS__Specialty__c;
                caseRec.US_WSREMS__Fax__c = prescriberAccount.get(0).Fax;
                caseRec.US_WSREMS__Ext__c = prescriberAccount.get(0).US_WSREMS__Ext__c;
                caseRec.US_WSREMS__Phone__c = prescriberAccount.get(0).Phone;
                caseRec.US_WSREMS__DEA__c = prescriberAccount.get(0).US_WSREMS__DEA__c;
                caseRec.US_WSREMS__NPI__c = prescriberAccount.get(0).US_WSREMS__National_Provider_Identifier__c;
                caseRec.US_WSREMS__Prescriber_NPI__c = prescriberAccount.get(0).US_WSREMS__National_Provider_Identifier__c;
                caseRec.US_WSREMS__NPI_Status__c = prescriberAccount.get(0).US_WSREMS__NPI_Status__c;
                caseRec.US_WSREMS__Preferred_Contact_Method__c = prescriberAccount.get(0).US_WSREMS__Preferred_Contact_Method__c;
                caseRec.US_WSREMS__Healthcare_Setting__c = healthCareAccount.get(0).Id;
                caseRec.US_WSREMS__State__c = healthCareAccount.get(0).US_WSREMS__State__c;
                caseRec.US_WSREMS__City__c = healthCareAccount.get(0).US_WSREMS__City__c;
                caseRec.US_WSREMS__Zip__c = healthCareAccount.get(0).US_WSREMS__Zip__c;
                caseRec.US_WSREMS__Zipcode__c = healthCareAccount.get(0).US_WSREMS__Zip__c;
                caseRec.US_WSREMS__Address_Line_1__c = healthCareAccount.get(0).US_WSREMS__Address_Line_1__c;
                caseRec.US_WSREMS__Address_Line_2__c = healthCareAccount.get(0).US_WSREMS__Address_Line_2__c;
                caseRec.recordTypeId = caseRecordTypeId;
                caseRec.US_WSREMS__Name__c = healthCareAccount.get(0).Name;
                caseRec.US_WSREMS__REMS_ID__c = prescriberAccount.get(0).US_WSREMS__REMS_ID__c;
                caseRec.Status = 'Draft';
                caseRec.US_WSREMS__Outcome__c = '';
                caseRec.US_WSREMS__Participant__c = accountId;
                caseRec.US_WSREMS__REMS_Service_Summary__c = serviceSummary.Id;
                caseRec.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
                caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
                caseRec.US_WSREMS__Credential__c = prescriberAccount.get(0).US_WSREMS__Credentials__c;
                caseRec.US_WSREMS__Knowledge_Assessment__c = 'Passed';
                if (prescriberAccount.get(0).US_WSREMS__Credentials__c == REMSAppLiterals.CREDENTIALS_OTHER){
                    caseRec.US_WSREMS__Credential__c = REMSAppLiterals.CREDENTIALS_OTHER;
                    caseRec.US_WSREMS__Other_Credentials__c = prescriberAccount.get(0).US_WSREMS__Other_Credentials__c;
                    caseRec.US_WSREMS__Other_Speciality__c = prescriberAccount.get(0).US_WSREMS__Other_Credentials__c;
                }
                caseRec.US_WSREMS__Participant__c = accountId;
                caseRec.US_WSREMS__Prescriber__c = accountId;
                caseRec.US_WSREMS__Requestor_Type__c = 'Prescriber';
                caseRec.US_WSREMS__Prescriber_Signature__c = 'Yes';
                caseRec.US_WSREMS__Signature__c = 'Yes';
                caseRec.US_WSREMS__Signature_Date__c = Date.Today();
                caseRec.US_WSREMS__Signature_Date_Pharmacist__c = Date.Today();
                caseRec.Email_address__c = prescriberAccount.get(0).PersonEmail;
                caseRec.US_WSREMS__Email__c = prescriberAccount.get(0).PersonEmail;
                caseRec.US_WSREMS__State_License_Number__c = prescriberAccount.get(0).US_WSREMS__SLN__c;
                caseRec.US_WSREMS__SLN__c = prescriberAccount.get(0).US_WSREMS__SLN__c;
                caseRec.US_WSREMS__SLN_Issued_State__c = prescriberAccount.get(0).US_WSREMS__SLN_State__c;
                insert caseRec;
                serviceSummary = NPISearchControllerPortal.updateServiceSummary(serviceSummary);
                addAffiliations(programId, accountId, healthCareSettingId);
                return true;
            }
            else {
                return addAffiliations(programId, accountId, healthCareSettingId);
            }
            
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean updatePrescriberAccount(String payload, String accountId) {
        try {
            if (String.isBlank(accountId) || String.isBlank(payload)) {
                return false;
            }
            RecordDataWrapper recordData = (RecordDataWrapper)System.JSON.deserialize(payload, RecordDataWrapper.class);
            Account accToUpdate = new Account(Id = accountId);
            accToUpdate.FirstName = recordData.firstName;
            accToUpdate.LastName = recordData.lastName;
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
            accToUpdate.US_WSREMS__Specialty__c = recordData.medicalSpeciality;
            accToUpdate.Medical_Specialty__c = recordData.medicalSpeciality;
            if (recordData.medicalSpeciality == REMSAppLiterals.CREDENTIALS_OTHER){
                accToUpdate.US_WSREMS__Other__c = recordData.specialityOther;
            } else {
                accToUpdate.US_WSREMS__Other__c = null;
            }
            update accToUpdate;
            return true;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean savePrescriberSignature(String accountId, String signData) {
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
            accUpdate.US_WSREMS__Status__c = 'Pending';
            update accUpdate;
            return true;
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean updatePortalStageForAccount(String accountId, String portalStage) {
        try {
            if (String.isBlank(accountId)) {
                return false;
            }
            Account accUpdate = new Account(Id = accountId);
            accUpdate.US_WSREMS__PortalStage__c = portalStage;
            update accUpdate;
            return true;
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    
/*****************************************************************************************************************
* Method Name          : createHCSRecordsEnrollmentCase
* @Author              : Surekha
* @CreatedDate         : 20-11-2024
* @param accountId     : Account record ID for which enrolment case should be created
* @param programId     : AVEED REMS Program record Id
* @param payload       : It holds list of HCS records to be inserted
* @return              : void          
*****************************************************************************************************************/
    @AuraEnabled
    public static void createHCSRecordsEnrollmentCase(String accountId, String programId, String payload) {
        try {
            
            List<Id> existingRecords=new List<Id>();
            Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(REMSAppLiterals.ACCOUNT_RECORDTYPE_HEALTHCARESETTING);
            List<HealthCareSettingAccount> wrapper = ( List<HealthCareSettingAccount>)System.JSON.deserialize(payload,  List<HealthCareSettingAccount>.class); 
            if (!wrapper.isEmpty()) { // Check to prevent errors on empty list
            
            HealthCareSettingAccount firstRecord =wrapper.get(0);
            String firstrecorString=System.JSON.serialize(firstRecord);
            if(firstRecord.newrecord == true){
               String hcsrecordId = insertHealthCareSettingAccount(firstrecorString,programId);
               createCaseAndServiceSummary(accountId,programId,hcsrecordId);

            }else{
                createCaseAndServiceSummary(accountId,programId,firstRecord.Id); 
            }
            wrapper.remove(0);
            List<Account> newHcsrecord=new List<Account>();
            List<Id> newHCSrecordIds=new List<Id>();
            Map<Id,String> accountcasemap=new Map<Id,string>();
            Map<Id,String> accountservicemap=new Map<Id,string>();
            for(HealthCareSettingAccount acc : wrapper) {
                if(acc.newrecord == true) {
                    newHCSrecord.add(insertHCSAccount(acc, programId,recordTypeId));
                }else{
                    existingRecords.add(acc.Id);
                   
                }
            }
            if(newHcsrecord.size() > 0) {
               Database.SaveResult[]  results = Database.insert(newHcsrecord);
               for (Database.SaveResult result : results) {
                if (result.isSuccess()) {
                    newHCSrecordIds.add(result.getId());
                } else {
                    System.debug('Error inserting account: ' + result.getErrors()[0].getMessage());
                }
                }
            }
            if(newHCSrecordIds.size() > 0){
                List<Account> insertedAccount = [SELECT Id, Name,PersonContactId, US_WSREMS__User_Type__c, US_WSREMS__REMS_ID__c, RecordType.Name,US_WSREMS__Address_Line_1__c,
                US_WSREMS__Address_Line_2__c,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Zip__c,US_WSREMS__Zip_Code__c,US_WSREMS__REMS_Program__c,
                US_WSREMS__Program_Picklist__c,ShippingState,ShippingCity,ShippingPostalCode,ShippingStreet,US_WSREMS__Channel__c
                FROM Account WHERE Id IN :newHCSrecordIds];
                
                accountcasemap=insertHCSCase(insertedAccount);
                accountservicemap= insertHCSService(insertedAccount);
                List<Case> caseRecList=new List<Case>();
                for(Account accRec : insertedAccount){
                    Case caseToUpdate = new Case(Id = accountcasemap.get(accRec.Id),
                    US_WSREMS__REMS_Service_Summary__c = accountservicemap.get(accRec.Id),
                    Status = REMSAppLiterals.CASE_STATUS_COMPLETED,
                    US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME,
                    US_WSREMS__Participant__c = accRec.Id);
                    caseRecList.add(caseToUpdate);
                }
                if(newHcsrecord.size() > 0) {
                    update caseRecList;
                }
            }
           existingRecords.addAll(newHCSrecordIds);
           addAffilationRecord(existingRecords,accountId,programId);
        } 
                   
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /*****************************************************************************************************************
    * Method Name          : insertHCSAccount
    * @Author              : Surekha
    * @CreatedDate         : 20-11-2024
    * @param wrapper       : It holds HCS Account data to be inserted
    * @param programId     : AVEED REMS Program record Id
    * @param recordTypeId  : HCS Account Record Type Id
    * @return              : Account Object          
    *****************************************************************************************************************/
    @AuraEnabled
    public static Account insertHCSAccount(HealthCareSettingAccount wrapper,String ProgramId,String recordTypeId) {
        try {
            Account newAccount = new Account(
            Name = wrapper.name,
            US_WSREMS__Address_Line_1__c = wrapper.addressLine1,
            US_WSREMS__Address_Line_2__c = wrapper.addressLine2,
            US_WSREMS__City__c = wrapper.city,
            US_WSREMS__State__c = wrapper.state,
            US_WSREMS__Zip__c = wrapper.zipCode,
            US_WSREMS__Zip_Code__c = wrapper.zipCode,
            RecordTypeId = recordTypeId,
            US_WSREMS__REMS_Program__c = programId,
            US_WSREMS__Program_Picklist__c = SYN_Utilitycls.AVEED_PROGRAM_NAME,
            ShippingState = wrapper.state,
            ShippingCity = wrapper.city,
            ShippingPostalCode = wrapper.zipCode,
            ShippingStreet = wrapper.addressLine1 + ' ' + wrapper.addressLine2,
            US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL,
            US_WSREMS__Status__c='');
            return newAccount;
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /*****************************************************************************************************************
    * Method Name               : insertHCSCase
    * @Author                   : Surekha
    * @CreatedDate              : 20-11-2024
    * @param insertedAccounts   : List of Account records to be inserted
    * @return                   : Map<Id,Id>         
    *****************************************************************************************************************/
    @AuraEnabled
    public static Map<Id,Id> insertHCSCase(List<Account> insertedAccounts) {
        try {
            Map<Id,Id> accountcasemap=new Map<Id,Id>();
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get(REMSAppLiterals.CASE_RECORDTYPE_HEALTHCARESETTING);
            List<Case> newHCSCaseRecords=new List<Case>();
            List<Id> newHCSrecordIds=new List<Id>();
            for(Account wrapper :insertedAccounts){
            Case caseRec = new Case(
            recordTypeId = caseRecordTypeId,
            US_WSREMS__Name__c = wrapper.Name,
            US_WSREMS__Address_Line_1__c = wrapper.US_WSREMS__Address_Line_1__c,
            US_WSREMS__Address_Line_2__c = wrapper.US_WSREMS__Address_Line_2__c,
            US_WSREMS__City__c = wrapper.ShippingCity,
            US_WSREMS__State__c = wrapper.ShippingState,
            US_WSREMS__Zip__c = wrapper.ShippingPostalCode,
            US_WSREMS__REMS_Program__c =wrapper.US_WSREMS__REMS_Program__c,
            US_WSREMS__Program_Picklist__c = wrapper.US_WSREMS__Program_Picklist__c,
            US_WSREMS__Healthcare_Setting__c = wrapper.Id,
            SYN_Medical_specialty__c = null,
            US_WSREMS__NPI_Status__c = 'Valid',
            US_WSREMS__Requestor_Type__c = 'Health Care Setting',
            Program_Record_Type_Control__c = 'AVEED REMS-Health_Care_Setting',
            US_WSREMS__REMS_ID__c = wrapper.US_WSREMS__REMS_ID__c,
            US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL);
            newHCSCaseRecords.add(caseRec);
            }
            if(newHCSCaseRecords.size() > 0) {
                insert newHCSCaseRecords;

                for(Case caseRec : newHCSCaseRecords){
                    accountcasemap.put(caseRec.US_WSREMS__Healthcare_Setting__c,caseRec.id);
                  }
             }
             
               return accountcasemap;
        }catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /*****************************************************************************************************************
    * Method Name               : insertHCSService
    * @Author                   : Surekha
    * @CreatedDate              : 20-11-2024
    * @param insertedAccounts   : List of Account records to be inserted
    * @return                   : Map<Id,Id>         
    *****************************************************************************************************************/
    @AuraEnabled
    public static Map<Id,Id> insertHCSService(List<Account> insertedAccounts) {
        try {
            Map<Id,Id> accountcasemap=new Map<Id,Id>();
            List<Id> newHCSrecordIds=new List<Id>();
            List<US_WSREMS__REMS_Service_Summary__c> serviceList=new List<US_WSREMS__REMS_Service_Summary__c>();
            Id idRTforREMSService = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c').get(REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
            for(Account acc : insertedAccounts){
            US_WSREMS__REMS_Service_Summary__c service = new US_WSREMS__REMS_Service_Summary__c(
            US_WSREMS__REMSProgram__c = acc.US_WSREMS__REMS_Program__c,
            RecordTypeId = idRTforREMSService,
            US_WSREMS__Status__c = REMSAppLiterals.SERVICE_STATUS,
            US_WSREMS__Service_Outcome__c = REMSAppLiterals.SERVICE_OUTCOME,
            US_WSREMS__Participant__c = acc.Id,
            US_WSREMS__Requestor_Type__c = REMSAppLiterals.REQUESTORTYPE_HCS,
            US_WSREMS__Path_Stage_Name__c = REMSAppLiterals.PATH_STAGE_NAME,
            US_WSREMS__Path_Complete__c = REMSAppLiterals.PATH_COMPLETE);
            serviceList.add(service);
            }
            if(serviceList.size() > 0) {
                insert serviceList;

                for(US_WSREMS__REMS_Service_Summary__c serviceRec : serviceList){
                    accountcasemap.put(serviceRec.US_WSREMS__Participant__c,serviceRec.id);
                  }

                 }
             
             
                return accountcasemap;
           
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
     /*****************************************************************************************************************
    * Method Name               : addAffilationRecord
    * @Author                   : Surekha
    * @CreatedDate              : 20-11-2024
    * @param healthcareReocrds  : List of HCS Account record Id's for which Affiliation to be created
    * @param PrescriberId       : List of HCP Account record Id's for which Affiliation to be created
    * @param programId          : AVEED REMS Program record Id
    * @return                   : void         
    *****************************************************************************************************************/
    @AuraEnabled
    public static void addAffilationRecord(List<Id> healthcareReocrds, string PrescriberId,String programId) {
        try {
            
            List<US_WSREMS__Affiliation__c> affiliationlist=new List<US_WSREMS__Affiliation__c>();
                Id recordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Healthcare_Setting_Affiliation').getRecordTypeId();
                for(Id recordId:healthcareReocrds){
                US_WSREMS__Affiliation__c oAffiliation = new US_WSREMS__Affiliation__c(
                    US_WSREMS__REMSProgram__c = programId, 
                    US_WSREMS__Prescriber__c = PrescriberId, 
                    US_WSREMS__isActive__c = true,
                    US_WSREMS__Start_Date__c = System.today(),
                    US_WSREMS__Health_Care_Setting__c = recordId,
                    RecordTypeId = recordTypeId,
                    US_WSREMS__End_Date__c = null
                );
                affiliationlist.add(oAffiliation);
                }
                if(affiliationlist.size() > 0) {
                insert affiliationlist;
            }
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public class RecordDataWrapper {
        public String firstName;
        public String lastName;
        public String phoneNumber;
        public String faxNumber;
        public String extension;
        public String credentials;
		public String othercredentials;
        public String preferredContactMethod;
        public String medicalSpeciality;
        public String specialityOther;
    }
    
    public class HealthCareSettingAccount {
        public String name;
        public String addressLine1;
        public String addressLine2;
        public String city;
        public String state;
        public String zipCode;
        public Boolean newrecord;
        public String Id;
    }
}