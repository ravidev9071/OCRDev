public without sharing class Aveed_NonPrescribingHCPTrainingCtrl {
    
    public class AccountCreationDetails {
        @AuraEnabled
        public Boolean isCreated;
        @AuraEnabled
        public String notificationMsg;
    }
    
    @AuraEnabled
    public static AccountCreationDetails createNonPrescribingCaseAccountCreation(String payload) {
        try {
            AccountCreationDetails details = new AccountCreationDetails();
            if (String.isNotBlank(payload)) {
                List<US_WSREMS__REMS_Program__c> programs = [SELECT Id, Name FROM US_WSREMS__REMS_Program__c WHERE Name = 'AVEED REMS'];
                List<RecordType> caseRecordTypes = [SELECT Id, Name, DeveloperName, SobjectType, IsActive, NamespacePrefix FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'General_Contact' AND NamespacePrefix = 'US_WSREMS'];
                List<RecordType> accountRecordTypes = [SELECT Id, Name, DeveloperName, SobjectType, IsActive, NamespacePrefix FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'General_Contact' AND NamespacePrefix = 'US_WSREMS'];
                RecordDataWrapper recordData = (RecordDataWrapper)System.JSON.deserialize(payload, RecordDataWrapper.class);
                Case newCase = new Case();
                newCase.RecordTypeId = caseRecordTypes.get(0).Id;
                newCase.US_WSREMS__First_Name__c = recordData.firstName;
                newCase.US_WSREMS__Last_Name__c = recordData.lastName;
                newCase.US_WSREMS__Email__c = recordData.email;
                newCase.US_WSREMS__Phone__c = recordData.phone;
                newCase.US_WSREMS__Address_Line_1__c = recordData.addressLine1;
                newCase.US_WSREMS__Address_Line_2__c = recordData.addressLine2;
                newCase.US_WSREMS__City__c = recordData.city;
                newCase.US_WSREMS__State__c = recordData.state;
                newCase.US_WSREMS__Zipcode__c = recordData.zipCode;
                newCase.US_WSREMS__Zip__c = recordData.zipCode;
                newCase.Other_Professional_Designation__c = recordData.degree == 'Other' ? recordData.otherDegree : null;
                newCase.US_WSREMS__REMS_Program__c = programs.get(0).Id;
                newCase.US_WSREMS__REMS_Country__c = 'US';
                newCase.US_WSREMS__Email_ar__c = recordData.Email;
                newCase.US_WSREMS__Program_Picklist__c = 'AVEED REMS';
                newCase.US_WSREMS__Requestor_Type__c = 'AVEED REMS-General_Contact';
                newCase.US_WSREMS__Requestor_Type__c = 'General Contact';
                if(recordData.degree == REMSAppLiterals.CREDENTIALS_OTHER){
                    newCase.US_WSREMS__Other_Credentials__c = recordData.otherDegree;
                } else {
                    newCase.US_WSREMS__Credential__c = recordData.degree;
                }
                newCase.US_WSREMS__Title__c = recordData.degree;
                newCase.US_WSREMS__MI__c = 'GC';
                newCase.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
                List<Database.SaveResult> results = Database.insert(new List<Case>{newCase});
                Id newCaseId;
                for (Database.SaveResult obj : results) {
                    if (obj.isSuccess()) {
                        newCaseId = obj.getId();
                    }
                }
                if (newCaseId != null) {
                    String programName;
                    SObjectType caseType = Schema.getGlobalDescribe().get('Case');
                    Map<String, Schema.SObjectField> mfields = caseType.getDescribe().fields.getMap();
                    String query = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Case WHERE Id = :newCaseId';
                    List<Case> newCaseLst = Database.query(query);
                    
                    if(newCaseLst[0].US_WSREMS__Program_Name__c != null){
                        programName = newCaseLst[0].US_WSREMS__Program_Name__c;
                    }
                    List<Account> accListToInsert = New List<Account>();
                    Map<String,String> mapofCaseRecordTypeNameVSAccName = New Map<String,String>();
                    Map<String,String> CaseFieldsVsAccountFieldsCustMetaMap = New Map<String,String>();
                    Map<Id, String> mapofCaseRecordTypeIdandName = new Map<Id, String>();
                    Map<String, Object> CaseFieldsVsValuesMap = New Map<String, Object>();
                    
                    List<US_WSREMS__Field_Mapping_Config__mdt> fieldMappingList = New List<US_WSREMS__Field_Mapping_Config__mdt>([SELECT US_WSREMS__Source_Field__c,
                                                                                                                                  US_WSREMS__Source_Object__c,US_WSREMS__Source_RecordType_Name__c,US_WSREMS__Target_Field__c,US_WSREMS__Target_Object__c,
                                                                                                                                  US_WSREMS__Target_RecordType_Name__c FROM US_WSREMS__Field_Mapping_Config__mdt WHERE US_WSREMS__Is_Account_Creation__c = True AND US_WSREMS__IsActive__c = True AND US_WSREMS__Program__r.MasterLabel = : programName]);
                    
                    //Create map for the source field vs the target field based on the custom metadatatype....
                    for(Case cs: newCaseLst){
                        for(US_WSREMS__Field_Mapping_Config__mdt fm : fieldMappingList){
                            if(SYN_Utilitycls.General_Contact == fm.US_WSREMS__Source_RecordType_Name__c){                   
                                CaseFieldsVsAccountFieldsCustMetaMap.put(fm.US_WSREMS__Source_Field__c, fm.US_WSREMS__Target_Field__c);
                            }
                        } 
                    }
                    
                    //Create map for the case field vs its actual value to map it later to the target field as a value...
                    for(Case cs: newCaseLst){
                        for(String cs1 : CaseFieldsVsAccountFieldsCustMetaMap.Keyset()){
                            CaseFieldsVsValuesMap.put(cs1, cs.get(cs1));
                        }
                    }
                    Account accToInsert = new Account();
                    for(Case cs: newCaseLst){
                        accToInsert = new Account();
                        for(String cs1 : CaseFieldsVsAccountFieldsCustMetaMap.Keyset()){
                            accToInsert.RecordTypeId = accountRecordTypes.get(0).Id;
                            accToInsert.PersonEmail = recordData.Email;
                            accToInsert.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
                            accToInsert.Put(CaseFieldsVsAccountFieldsCustMetaMap.get(cs1),CaseFieldsVsValuesMap.get(cs1));
                        }
                    }
                    Database.SaveResult saveResult = Database.insert(accToInsert, false);
                    details.isCreated = saveResult.isSuccess();
                    if (saveResult.isSuccess() && saveResult.getId() != null) {
                        List<Account> insertedAccount = [SELECT Id, PersonContactId, US_WSREMS__User_Type__c, US_WSREMS__REMS_ID__c, RecordType.Name FROM Account WHERE Id = :saveResult.getId()];
                        US_WSREMS__REMS_Service_Summary__c serviceSummary = NPISearchControllerPortal.insertServiceSummary(insertedAccount.get(0), programs, insertedAccount.get(0).RecordType.Name, REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
                        Case caseToUpdate = new Case(Id = newCaseId);
                        caseToUpdate.US_WSREMS__REMS_Service_Summary__c = serviceSummary.Id;
                        caseToUpdate.US_WSREMS__REMS_ID__c = insertedAccount.get(0).US_WSREMS__REMS_ID__c;
                        caseToUpdate.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
                        caseToUpdate.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
                        caseToUpdate.US_WSREMS__Participant__c = insertedAccount.get(0).Id;
                        Database.update(caseToUpdate);
                        serviceSummary = NPISearchControllerPortal.updateServiceSummary(serviceSummary);
                        details.notificationMsg = 'Account is created';
                    } else {
                        if (saveResult.getErrors() != null && !saveResult.getErrors().isEmpty()) {
                            String errorMessage = saveResult.getErrors().get(0).getMessage();
                            details.notificationMsg = errorMessage;
                        } else {
                            details.notificationMsg = 'Something went wrong, please contact admin.';
                        }
                    }
                    
                    return details;
                }
            }
            return details;
        } catch (Exception e) {
            system.debug(LoggingLevel.ERROR, e.getStackTraceString());
            system.debug(LoggingLevel.ERROR, e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //inputRecords contains program name and input value payload from community page
    //recordTypeName -> Developername of the record type of Account Object
    @AuraEnabled
    public static Boolean checkDuplicateAccounts(Map<String, String> inputRecords, String recordTypeName) {
        Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(recordTypeName);
        List<RecordType> accountRecordTypes = [SELECT Id, Name, DeveloperName, SobjectType, IsActive, NamespacePrefix FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = :recordTypeName AND NamespacePrefix = 'US_WSREMS'];
        if (accountRecordTypes != null && !accountRecordTypes.isEmpty()) {
            recordTypeId = accountRecordTypes.get(0).Id;
        }
        String programName = inputRecords.get('programName');
        try {
            String recordDetails = inputRecords.get('recordDetails'); 
            RecordDataWrapper recordData = (RecordDataWrapper)System.JSON.deserialize(recordDetails, RecordDataWrapper.class);
            String firstName = '%' + recordData.firstName + '%';
            String LastName = '%' + recordData.lastName + '%';
            String email = '%' + recordData.email + '%';
            String query= 'SELECT Id, US_WSREMS__Status__c FROM Account WHERE FirstName LIKE :firstName AND LastName LIKE :LastName AND PersonEmail LIKE :email AND US_WSREMS__REMS_Program__r.Name = :programName AND RecordTypeId = :recordTypeId';
            List<Account> accRecords = Database.query(query);
            if (accRecords != null && !accRecords.isEmpty()) {
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String,Map<String,String>> getPicklistFieldValues(){
        Map<String, Map<String,String>> mapToReturn = new Map<String, Map<String,String>>();
        String objectName = 'Account';
        List<String> fieldNameList = new List<String>();
        fieldNameList.add('US_WSREMS__State__c');
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        for(String fieldName: fieldNameList){
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            Map<String,String> picklistMap = new Map<String,String>();
            for( Schema.PicklistEntry pickListVal : ple){
                picklistMap.put(pickListVal.getLabel(), pickListVal.getValue());
            }
            mapToReturn.put(fieldName,picklistMap);
        }
        return mapToReturn;
    }
    
    public class RecordDataWrapper {
        public String firstName;
        public String middleName;
        public String lastName;
        public String email;
        public String phone;
        public String addressLine1;
        public String addressLine2;
        public String city;
        public String state;
        public String zipCode;
        public String degree;
        public String otherDegree;
    }
}