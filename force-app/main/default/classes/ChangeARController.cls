/**
 * @File Name          : ChangeARController.cls
 * @Description        : This class provides methods to manage changes related to Authorized Representatives (AR) for Accounts.
 *                       It includes functionalities for retrieving case field mappings, creating AR accounts, updating affiliations,
 *                       and managing account status based on certain criteria.
 * @TestClass          : ChangeARControllerTest
 * @Author             : Citiustech
 * @Modification Log   :
 * Ver       Date               Developer                       Modification
 * 1.0      21-05-2024            Mari                 Initial Implementation.
 */
public class ChangeARController {

        private static final String FIELD_MAPPING_CONFIG = 'Field_Mapping_Configuration';
        private static final String CASE_OBJECT = 'Case';
        private static final String CHANGE_AR = 'Change Authorized Representative';
        private static final String CHANGE_AR_RECORD_TYPE = 'Change_Authorized_Representative';
        private static final String HEALTHCARE_SETTING_FIELD = 'Healthcare_Setting__c';
        private static final String HEALTHCARE_SETTING = 'Health_Care_Setting';
        private static final String PHARMACY_FIELD = 'Pharmacy__c';
        private static final String DISTRIBUTOR_FIELD = 'Distributor__c';
        private static final String DISTRIBUTOR_REC_TYPE = 'REMS_Distributor_Account';
        private static final String PRIMARY_AR = 'Primary AR';
        private static final String SECONDARY_AR = 'Secondary AR';
        private static final String ACCOUNT_SOBJECT_TYPE = 'Account';
        private static final String STATUS_COMPLETE = 'Complete';
        private static final String STATUS_DRAFT = 'Draft';
        private static final String STATUS_CERTIFIED = 'Certified';
        private static final String PRESCRIBER_SIGNATURE_YES = 'Yes';
        private static final String AUTH_REP_AFFILATION = 'Authorized Representative Affiliation';
        private static final String PHARMACY_AUTH_REP_AFFILATION = 'Pharmacy User Affiliation';
        private static final String INPATIENT_PHAR = 'Inpatient_Pharmacy_Account';
    /**
     * Retrieves a map of case fields and their values based on the input parameters.
     *
     * @param accountId           The ID of the account to retrieve values from.
     * @param requestorType       The type of requestor (e.g., 'Primary AR', 'Secondary AR').
     * @param targetObject        The target Salesforce object.
     * @param sourceObject        The source Salesforce object.
     * @param sourceRecordType    The record type of the source object.
     * @param parentFieldType     The parent field type.
     * @param programName         The name of the program.
     * @param overrideReqType     A flag to override the requestor type based on the account ID.
     * @return                    A map containing the case fields and their corresponding values.
     */
    @AuraEnabled
    public static Map<String, String> getCaseFieldAndValueMap(String accountId, String requestorType, String targetObject, String sourceObject, String sourceRecordType, String parentFieldType, String programName, Boolean overrideReqType) {
        List<Account> actList = new List<Account>();  // List to hold queried account records
        List<SObject> sObjectRecList = new List<SObject>();  // List to hold queried sObject records
        Map<String, String> TargetFieldToValueMap = new Map<String, String>();  // Map to store target field values
        Map<String, String> TargetSourceMap = new Map<String, String>();  // Map to store source to target field mappings
        Set<String> dynamicFieldSet = new Set<String>();  // Set to hold dynamic fields for query

        // Override requestorType if overrideReqType is true and accountId is not blank
        if (overrideReqType == true && !String.isBlank(accountId)) {
            actList = [SELECT Id, Recordtype.Name FROM Account WHERE Id = :accountId];
            requestorType = actList[0].Recordtype.Name;
        }

        // Fetch field mappings from Automation_Configuration__c based on the input parameters
        List<US_WSREMS__Automation_Configuration__c> fieldMappingList = [SELECT US_WSREMS__Source_Object__c, US_WSREMS__Source_Field__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c, US_WSREMS__Target_RecordType_Name__c, US_WSREMS__Source_RecordType_Name__c, US_WSREMS__Parent_Field__c, US_WSREMS__IsActive__c, US_WSREMS__Order__c
                                                            FROM US_WSREMS__Automation_Configuration__c WHERE US_WSREMS__Source_Object__c = :sourceObject AND US_WSREMS__REMS_Program__r.Name = :programName AND US_WSREMS__Target_Object__c = :targetObject AND US_WSREMS__Request_Type__c = :requestorType
                                                            AND RecordType.DeveloperName = :FIELD_MAPPING_CONFIG AND US_WSREMS__Source_RecordType_Name__c = :sourceRecordType AND US_WSREMS__Parent_Field__c = :parentFieldType AND US_WSREMS__IsActive__c = true ORDER BY US_WSREMS__Order__c];

        // Populate TargetSourceMap and dynamicFieldSet
        for (US_WSREMS__Automation_Configuration__c mdt : fieldMappingList) {
            TargetSourceMap.put(mdt.US_WSREMS__Source_Field__c, mdt.US_WSREMS__Target_Field__c);
            dynamicFieldSet.add(mdt.US_WSREMS__Target_Field__c);
        }

        String dynamicFieldStr = String.join(new List<String>(dynamicFieldSet), ',');

        // Query account if accountId is provided
        if (accountId != null && accountId != '') {
            String dynamicQueryStr = 'SELECT ' + dynamicFieldStr + ' FROM Account WHERE Id = :accountId';
            sObjectRecList = Database.query(dynamicQueryStr);

            // Populate TargetFieldToValueMap with field values from the queried account
            for (String Field : TargetSourceMap.keySet()) {
                String FieldValue = String.valueOf(sObjectRecList[0].get(TargetSourceMap.get(Field)));
                TargetFieldToValueMap.put(Field, String.isBlank(FieldValue) ? '' : FieldValue);
            }
        } else {
            // Initialize TargetFieldToValueMap with empty values if accountId is not provided
            for (String Field : TargetSourceMap.keySet()) {
                TargetFieldToValueMap.put(Field, '');
            }
        }

        dynamicFieldSet = new Set<String>();

        // Additional logic for specific conditions
        if (sourceObject == CASE_OBJECT && sourceRecordType == CHANGE_AR_RECORD_TYPE && (parentFieldType.contains(HEALTHCARE_SETTING_FIELD) || parentFieldType.contains(PHARMACY_FIELD) || parentFieldType.contains(DISTRIBUTOR_FIELD))) {
            List<String> requestorTypeList = new List<String>{PRIMARY_AR, SECONDARY_AR};

            // Fetch additional field mappings based on specific conditions
            fieldMappingList = [SELECT US_WSREMS__Source_Object__c, US_WSREMS__Source_Field__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c, US_WSREMS__Target_RecordType_Name__c, US_WSREMS__Source_RecordType_Name__c, US_WSREMS__Parent_Field__c, US_WSREMS__IsActive__c, US_WSREMS__Order__c, US_WSREMS__Request_Type__c
                                FROM US_WSREMS__Automation_Configuration__c WHERE US_WSREMS__Source_Object__c = :sourceObject AND US_WSREMS__REMS_Program__r.Name = :programName AND US_WSREMS__Target_Object__c = :targetObject AND US_WSREMS__Request_Type__c IN :requestorTypeList
                                AND US_WSREMS__Source_RecordType_Name__c = :sourceRecordType AND US_WSREMS__IsActive__c = true AND RecordType.DeveloperName = :FIELD_MAPPING_CONFIG];

            if (fieldMappingList.size() > 0) {
                for (US_WSREMS__Automation_Configuration__c mdt : fieldMappingList) {
                    TargetSourceMap.put(mdt.US_WSREMS__Source_Field__c, mdt.US_WSREMS__Target_Field__c);

                    if (mdt.US_WSREMS__Request_Type__c == requestorTypeList[0]) {
                        dynamicFieldSet.add(mdt.US_WSREMS__Target_Field__c);
                    }
                }

                if (accountId != null && accountId != '') {
                    // Query affiliations related to the account
                    Map<Id, US_WSREMS__Affiliation__c> afflMap = new Map<Id, US_WSREMS__Affiliation__c>([
                        SELECT Id, US_WSREMS__Authorized_Representative__c,US_WSREMS__Pharmacy_User__c, US_WSREMS__User_Role__c,US_WSREMS__Pharmacy__c
                        FROM US_WSREMS__Affiliation__c
                        WHERE (US_WSREMS__Health_Care_Setting__c = :accountId OR US_WSREMS__Pharmacy__c = :accountId OR US_WSREMS__PPharmacy__c = :accountId OR US_WSREMS__Distributor__c = : accountId)
                        AND US_WSREMS__isActive__c = true
                    ]);

                    List<Id> authorizedRepresentatives = new List<Id>();
                    Map<String, Id> afflUserRoleMap = new Map<String, Id>();

                    for (US_WSREMS__Affiliation__c affl : afflMap.values()) {
                        if(affl.US_WSREMS__Pharmacy__c != null){
                            authorizedRepresentatives.add(affl.US_WSREMS__Pharmacy_User__c);
                            afflUserRoleMap.put(affl.US_WSREMS__User_Role__c, affl.US_WSREMS__Pharmacy_User__c);
                            if (affl.US_WSREMS__Pharmacy_User__c != null) {
                                authorizedRepresentatives.add(affl.US_WSREMS__Pharmacy_User__c);
                            }
                        }else{
                            afflUserRoleMap.put(affl.US_WSREMS__User_Role__c, affl.US_WSREMS__Authorized_Representative__c);
                            if (affl.US_WSREMS__Authorized_Representative__c != null) {
                                authorizedRepresentatives.add(affl.US_WSREMS__Authorized_Representative__c);
                            }
                        }
                        // Ensure that the Authorized_Representative__c is not null to avoid adding nulls to the list

                    }

                    dynamicFieldStr = String.join(new List<String>(dynamicFieldSet), ',');
                    String dynamicQueryStr = 'SELECT ' + dynamicFieldStr + ' FROM Account WHERE Id IN :authorizedRepresentatives';

                    sObjectRecList = Database.query(dynamicQueryStr);

                    if (sObjectRecList.size() > 0) {
                        for (SObject obj : sObjectRecList) {
                            for (US_WSREMS__Automation_Configuration__c mdt : fieldMappingList) {
                                if (afflUserRoleMap.get(mdt.US_WSREMS__Request_Type__c) == obj.Id) {
                                    String FieldValue = String.valueOf(obj.get(mdt.US_WSREMS__Target_Field__c));
                                    TargetFieldToValueMap.put(mdt.US_WSREMS__Source_Field__c, String.isBlank(FieldValue) ? '' : FieldValue);
                                }
                            }
                        }
                    }
                } else {
                    for (String Field : TargetSourceMap.keySet()) {
                        TargetFieldToValueMap.put(Field, '');
                    }
                }
            }
        }

        return TargetFieldToValueMap;
    }


   
    /**
     * Updates affiliations and related account based on changes in case fields.
     *
     * @param caseId The ID of the case being updated.
     */
    @AuraEnabled
    public static void changeARUpdate(List<Case> newCaseList ,Map<Id,Case> oldCaseMap){

        try {
            if(!(oldCaseMap == null || oldCaseMap.size() == 0)){
                REMSCaseTriggerHandler.prePopulateCaseFields(newCaseList,oldCaseMap);
            }
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeNameId(REMSAppLiterals.CASE_OBJECT).get(CHANGE_AR);
            Set<Id> participantIds = new Set<Id>();
            List<Case> changeARCase = new List<Case>();
List<Case> changeARFilterCases = new List<Case>();
            //Filtering Change AR case
            for (Case c : newCaseList) {
                // Also check if the necessary fields are not null
                if (c.RecordTypeId == caseRecordTypeId ) {
                        participantIds.add(c.US_WSREMS__Participant__c);
                        changeARFilterCases.add(c);
                }
            }
            // Query to get Account Id and RecordType.DeveloperName
        List<Account> accountList = [
            SELECT Id, RecordType.Name, RecordType.DeveloperName,US_WSREMS__REMS_Program__r.Name
            FROM Account
            WHERE Id IN :participantIds
        ];
        
        // Query Service Config to get the KA applicable or NOT 
        List<US_WSREMS__REMS_Service_Configuration__mdt> serviceConfigList = [SELECT Id, US_WSREMS__Case_Record_Type__c, US_WSREMS__Case_Status__c, US_WSREMS__Case_Outcome__c,US_WSREMS__Account_Record_Type__c,
                                                                    US_WSREMS__Program_Configuration__c, US_WSREMS__Program_Configuration__r.Label,US_WSREMS__SkipKA__c,US_WSREMS__Participant_Type__c
                                                                    FROM US_WSREMS__REMS_Service_Configuration__mdt    
                                                                    WHERE US_WSREMS__Case_Record_Type__c =: REMSAppLiterals.SERVICE_RECTYPE_CHANGE_AUTHORIZED_REPRESENTATIVE];
        
         Map<String, Boolean> serviceRecordTypeMap = new Map<String, Boolean>();
         Map<String, String> serviceProgramRecordTypeMap = new Map<String, String>();
         
         for(US_WSREMS__REMS_Service_Configuration__mdt s:serviceConfigList){
           serviceRecordTypeMap.put(s.US_WSREMS__Participant_Type__c + s.US_WSREMS__Program_Configuration__r.Label,s.US_WSREMS__SkipKA__c);
           serviceProgramRecordTypeMap.put(s.US_WSREMS__Program_Configuration__r.Label,s.US_WSREMS__Participant_Type__c);
         }
         List<String> serviceValues = New List<String>(serviceRecordTypeMap.keySet());
                 
        // Create a map with Account Id as the key and RecordType.DeveloperName as the value
        Map<Id, String> accountRecordTypeMap = new Map<Id, String>();
        Map<Id, String> accountRecordTypeMapWithProgram = new Map<Id, String>();
        for (Account acc : accountList) {
            accountRecordTypeMap.put(acc.Id, acc.RecordType.DeveloperName);
            accountRecordTypeMapWithProgram.put(acc.Id, acc.RecordType.Name + acc.US_WSREMS__REMS_Program__r.Name);
        }

        //Setting the Case Status
        for (Case c : changeARFilterCases) {
            //KA Skip logic based on service configuration contains KA SKIP TRUE or FALSE with respective to program
            if(serviceValues.contains(accountRecordTypeMapWithProgram.get(c.US_WSREMS__Participant__c))){
            if((serviceRecordTypeMap.get(accountRecordTypeMapWithProgram.get(c.US_WSREMS__Participant__c)) ||  c.US_WSREMS__KA_New_Primary_AR__c == REMSAppLiterals.PASSED) 
                                         && c.US_WSREMS__AR_Signature_New_Primary_AR__c == PRESCRIBER_SIGNATURE_YES && c.US_WSREMS__AR_Signature_Date_New_Primary_AR__c != null)
                {
                    c.status = STATUS_COMPLETE;
                    c.US_WSREMS__Outcome__c = STATUS_COMPLETE;
                }
                else if(c.US_WSREMS__Authorized_Representative_New_Primary_AR__c == null && c.US_WSREMS__AR_New_Secondary_AR__c != null)
                {
                    c.status = STATUS_COMPLETE;
                    c.US_WSREMS__Outcome__c = STATUS_COMPLETE;
                }
                else{
                    c.status = STATUS_DRAFT;
                }
                }
			}
            //Filtering Change AR case
            for (Case c : changeARFilterCases) {
                // Also check if the necessary fields are not null
                if (c.RecordTypeId == caseRecordTypeId ) {
                    if (oldCaseMap == null || oldCaseMap.size() == 0){
                        participantIds.add(c.US_WSREMS__Participant__c);
                        changeARCase.add(c);
                    }else if(c.Status != oldCaseMap.get(c.Id).Status){
                        changeARCase.add(c);
                        participantIds.add(c.US_WSREMS__Participant__c);
                    }
                }
            }


            newCaseList= changeARCase;
            //Get Affilation details
            Map<Id, US_WSREMS__Affiliation__c> afflMap = new Map<Id, US_WSREMS__Affiliation__c>([
                SELECT Id,US_WSREMS__IsActive__c, US_WSREMS__Authorized_Representative__c,US_WSREMS__Authorized_Representative__r.PersonContactId, US_WSREMS__User_Role__c,US_WSREMS__Health_Care_Setting__c,US_WSREMS__Pharmacy__c,US_WSREMS__Distributor__c,US_WSREMS__Pharmacy_User__c
                FROM US_WSREMS__Affiliation__c
                WHERE (US_WSREMS__Health_Care_Setting__c IN :participantIds OR US_WSREMS__Pharmacy__c IN :participantIds OR US_WSREMS__PPharmacy__c IN :participantIds OR US_WSREMS__Distributor__c IN :participantIds)
            ]); 

            // Creating the map with User_Role__c as key and Authorized_Representative__c as value
            Map<String, Id> userRoleToAuthRepMap = new Map<String, Id>();
            // Create a map with Authorized_Representative__c as key and Affiliation__c as value
            Map<Id, US_WSREMS__Affiliation__c> activeAffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
            Map<Id, US_WSREMS__Affiliation__c> fullAffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();

            for (US_WSREMS__Affiliation__c aff : afflMap.values()) {
                if(aff.US_WSREMS__Pharmacy__c != null){
                    if(aff.US_WSREMS__IsActive__c){
                        userRoleToAuthRepMap.put(aff.US_WSREMS__User_Role__c, aff.US_WSREMS__Pharmacy_User__c);
                        activeAffiliationMap.put(aff.US_WSREMS__Pharmacy_User__c, aff);
                    }
                    fullAffiliationMap.put(aff.US_WSREMS__Pharmacy_User__c, aff);
                }else{
                    if(aff.US_WSREMS__IsActive__c){
                        userRoleToAuthRepMap.put(aff.US_WSREMS__User_Role__c, aff.US_WSREMS__Authorized_Representative__c);
                        activeAffiliationMap.put(aff.US_WSREMS__Authorized_Representative__c, aff);
                    }
                    fullAffiliationMap.put(aff.US_WSREMS__Authorized_Representative__c, aff);
                }


            }

            //Throwing Error
            for (Case c : newCaseList) {
                // 1.Throwing Error if both AR are same
                if (c.US_WSREMS__Authorized_Representative_New_Primary_AR__c != null && c.US_WSREMS__AR_New_Secondary_AR__c != null && c.US_WSREMS__Authorized_Representative_New_Primary_AR__c == c.US_WSREMS__AR_New_Secondary_AR__c) {
                    c.addError('Primary and Secondary Cannot be same');
                }
                //2.If primary is selected as active secondary AR
                // if (userRoleToAuthRepMap.get(SECONDARY_AR) == c.Authorized_Representative_New_Primary_AR__c && c.AR_New_Secondary_AR__c == null ) {
                //     c.addError('Selected Primary AR is already active as Secondary AR');
                // }
                //3.If secondary is selected as active primary AR
                if (userRoleToAuthRepMap.get(PRIMARY_AR) == c.US_WSREMS__AR_New_Secondary_AR__c && c.US_WSREMS__Authorized_Representative_New_Primary_AR__c == null && c.US_WSREMS__AR_New_Secondary_AR__c != null) {
                    c.addError('Selected Secondary AR is already active as Primary AR');
                }
                if(participantIds.size() == 0 ){ 
                    c.addError('No Participant');
                    return;
                }
            }
            //Creating REMS service
            if((oldCaseMap == null || oldCaseMap.size() == 0)){
                createAndAssignService(newCaseList);
            }
            if(participantIds.size() == 0 ){ 
                                return;
            }
        
            Id oldPrimID = null;
            Id oldSecID = null;
            Id recordTypeId = REMSUtils.retrieveRecTypeNameId(REMSAppLiterals.AFFILIATION_OBJ).get(AUTH_REP_AFFILATION);
            Id pharRecordTypeId = REMSUtils.retrieveRecTypeNameId(REMSAppLiterals.AFFILIATION_OBJ).get(PHARMACY_AUTH_REP_AFFILATION);

            List<US_WSREMS__Affiliation__c> affList = new List<US_WSREMS__Affiliation__c> ();
            // Compare Case AR fields with Affiliation details
            for (Case c : newCaseList) {
                if (c.Status == STATUS_COMPLETE && (c.US_WSREMS__Authorized_Representative_New_Primary_AR__c != null || c.US_WSREMS__AR_New_Secondary_AR__c != null)) {
                    
                    //Primary Affilation
                    if(c.US_WSREMS__Authorized_Representative_New_Primary_AR__c != null ){
                        //Creating or modifing Primary Affiliation
                        String affId = (fullAffiliationMap.get(c.US_WSREMS__Authorized_Representative_New_Primary_AR__c)) != null ? fullAffiliationMap.get(c.US_WSREMS__Authorized_Representative_New_Primary_AR__c).Id : null;
                        US_WSREMS__Affiliation__c tempAff = new US_WSREMS__Affiliation__c(id = affId);
                        tempAff.US_WSREMS__User_Role__c = PRIMARY_AR;
                        tempAff.US_WSREMS__isActive__c = true;
                        tempAff.US_WSREMS__Start_Date__c = Date.today();
                        tempAff.US_WSREMS__End_Date__c = null;
                        if(accountRecordTypeMap.get(c.US_WSREMS__Participant__c)  == HEALTHCARE_SETTING){
                            tempAff.RecordTypeId = recordTypeId;
                            tempAff.US_WSREMS__Health_Care_Setting__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__Authorized_Representative__c = c.US_WSREMS__Authorized_Representative_New_Primary_AR__c;
                        }else if(accountRecordTypeMap.get(c.US_WSREMS__Participant__c)  == DISTRIBUTOR_REC_TYPE){
                            tempAff.RecordTypeId = recordTypeId;
                            tempAff.US_WSREMS__Distributor__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__Authorized_Representative__c = c.US_WSREMS__Authorized_Representative_New_Primary_AR__c;
                        }else{
                            tempAff.RecordTypeId = pharRecordTypeId;
                            tempAff.US_WSREMS__Pharmacy__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__PPharmacy__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__Pharmacy_User__c = c.US_WSREMS__Authorized_Representative_New_Primary_AR__c;
                        }
                        tempAff.US_WSREMS__REMSProgram__c = c.US_WSREMS__REMS_Program__c;
                        affList.add(tempAff);
                        //Deactivating exixsting aff

                        if(c.US_WSREMS__Authorized_Representative_New_Primary_AR__c != userRoleToAuthRepMap.get(PRIMARY_AR)  && c.US_WSREMS__AR_New_Secondary_AR__c != userRoleToAuthRepMap.get(PRIMARY_AR)  && userRoleToAuthRepMap.get(PRIMARY_AR) != null){
                            affId = (activeAffiliationMap.get(userRoleToAuthRepMap.get(PRIMARY_AR))) != null ? activeAffiliationMap.get(userRoleToAuthRepMap.get(PRIMARY_AR)).Id : null;
                            oldPrimID = (activeAffiliationMap.get(userRoleToAuthRepMap.get(PRIMARY_AR))) != null ? activeAffiliationMap.get(userRoleToAuthRepMap.get(PRIMARY_AR)).US_WSREMS__Authorized_Representative__r.PersonContactId : null;
                            US_WSREMS__Affiliation__c oldAff = new US_WSREMS__Affiliation__c(id =affId);
                            oldAff.US_WSREMS__isActive__c = false;
                            oldAff.US_WSREMS__End_Date__c = Date.today();
                            affList.add(oldAff);
                        }
                    }

                    //Secondary Affilation
                    if(c.US_WSREMS__AR_New_Secondary_AR__c != null ){
                        //Creating or modifing Primary Affiliation
                        String affId = (fullAffiliationMap.get(c.US_WSREMS__AR_New_Secondary_AR__c)) != null ? fullAffiliationMap.get(c.US_WSREMS__AR_New_Secondary_AR__c).Id : null;
                        US_WSREMS__Affiliation__c tempAff = new US_WSREMS__Affiliation__c(id = affId);
                        tempAff.US_WSREMS__User_Role__c = SECONDARY_AR;
                        tempAff.US_WSREMS__isActive__c = true;
                        tempAff.US_WSREMS__Start_Date__c = Date.today();
                        tempAff.US_WSREMS__End_Date__c = null;
                        if(accountRecordTypeMap.get(c.US_WSREMS__Participant__c)  == HEALTHCARE_SETTING){
                            tempAff.RecordTypeId = recordTypeId;
                            tempAff.US_WSREMS__Health_Care_Setting__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__Authorized_Representative__c = c.US_WSREMS__AR_New_Secondary_AR__c;
                        }else if(accountRecordTypeMap.get(c.US_WSREMS__Participant__c)  == DISTRIBUTOR_REC_TYPE){
                            tempAff.RecordTypeId = recordTypeId;
                            tempAff.US_WSREMS__Distributor__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__Authorized_Representative__c = c.US_WSREMS__AR_New_Secondary_AR__c;
                        }else{
                            tempAff.RecordTypeId = pharRecordTypeId;
                            tempAff.US_WSREMS__Pharmacy__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__PPharmacy__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__Pharmacy_User__c = c.US_WSREMS__AR_New_Secondary_AR__c;
                        }
                        tempAff.US_WSREMS__REMSProgram__c = c.US_WSREMS__REMS_Program__c;
                        affList.add(tempAff);
                        //Deactivating exixsting aff
                        if(c.US_WSREMS__AR_New_Secondary_AR__c != userRoleToAuthRepMap.get(SECONDARY_AR) && c.US_WSREMS__Authorized_Representative_New_Primary_AR__c != userRoleToAuthRepMap.get(SECONDARY_AR) && userRoleToAuthRepMap.get(SECONDARY_AR) != null){
                            affId = (activeAffiliationMap.get(userRoleToAuthRepMap.get(SECONDARY_AR))) != null ? activeAffiliationMap.get(userRoleToAuthRepMap.get(SECONDARY_AR)).Id : null;
                            oldSecID = (activeAffiliationMap.get(userRoleToAuthRepMap.get(SECONDARY_AR))) != null ? activeAffiliationMap.get(userRoleToAuthRepMap.get(SECONDARY_AR)).US_WSREMS__Authorized_Representative__r.PersonContactId : null;
                            US_WSREMS__Affiliation__c oldAff = new US_WSREMS__Affiliation__c(id =affId);
                            oldAff.US_WSREMS__isActive__c = false;
                            oldAff.US_WSREMS__End_Date__c = Date.today();
                            affList.add(oldAff);
                        }
                    }
                }else if (c.Status == STATUS_DRAFT && (c.US_WSREMS__Authorized_Representative_New_Primary_AR__c != null || c.US_WSREMS__AR_New_Secondary_AR__c != null)) {
                    if(c.US_WSREMS__Authorized_Representative_New_Primary_AR__c!= null && activeAffiliationMap.get(c.US_WSREMS__Authorized_Representative_New_Primary_AR__c) == null){
                        String affId = (fullAffiliationMap.get(c.US_WSREMS__Authorized_Representative_New_Primary_AR__c)) != null ? fullAffiliationMap.get(c.US_WSREMS__Authorized_Representative_New_Primary_AR__c).Id : null;
                        US_WSREMS__Affiliation__c tempAff = new US_WSREMS__Affiliation__c(Id=affId);
                        //For health care setting
                        if(accountRecordTypeMap.get(c.US_WSREMS__Participant__c)  == HEALTHCARE_SETTING){
                            tempAff.RecordTypeId = recordTypeId;
                            tempAff.US_WSREMS__Health_Care_Setting__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__Authorized_Representative__c = c.US_WSREMS__Authorized_Representative_New_Primary_AR__c;
                        }else if(accountRecordTypeMap.get(c.US_WSREMS__Participant__c)  == DISTRIBUTOR_REC_TYPE){
                            tempAff.RecordTypeId = recordTypeId;
                            tempAff.US_WSREMS__Authorized_Representative__c = c.US_WSREMS__Authorized_Representative_New_Primary_AR__c;
                            tempAff.US_WSREMS__Distributor__c = c.US_WSREMS__Participant__c;
                        }else{
                            tempAff.RecordTypeId = pharRecordTypeId;
                            tempAff.US_WSREMS__Pharmacy__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__PPharmacy__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__Pharmacy_User__c = c.US_WSREMS__Authorized_Representative_New_Primary_AR__c;
                        }
                        tempAff.US_WSREMS__isActive__c = false;
                        tempAff.US_WSREMS__User_Role__c = PRIMARY_AR;
                        tempAff.US_WSREMS__REMSProgram__c = c.US_WSREMS__REMS_Program__c;
                        affList.add(tempAff);
                    }
                    if(c.US_WSREMS__AR_New_Secondary_AR__c!= null && activeAffiliationMap.get(c.US_WSREMS__AR_New_Secondary_AR__c) == null){
                        String affId = (fullAffiliationMap.get(c.US_WSREMS__AR_New_Secondary_AR__c)) != null ? fullAffiliationMap.get(c.US_WSREMS__AR_New_Secondary_AR__c).Id : null;
                        US_WSREMS__Affiliation__c tempAff = new US_WSREMS__Affiliation__c(Id=affId);
                        tempAff.RecordTypeId = recordTypeId;
                        //For health care setting
                        if(accountRecordTypeMap.get(c.US_WSREMS__Participant__c)  == HEALTHCARE_SETTING){
                            tempAff.RecordTypeId = recordTypeId;
                            tempAff.US_WSREMS__Health_Care_Setting__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__Authorized_Representative__c = c.US_WSREMS__AR_New_Secondary_AR__c;
                        }else if(accountRecordTypeMap.get(c.US_WSREMS__Participant__c)  == DISTRIBUTOR_REC_TYPE){
                            tempAff.RecordTypeId = recordTypeId;
                            tempAff.US_WSREMS__Distributor__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__Authorized_Representative__c = c.US_WSREMS__AR_New_Secondary_AR__c;
                        }else{
                            tempAff.RecordTypeId = pharRecordTypeId;
                            tempAff.US_WSREMS__Pharmacy__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__PPharmacy__c = c.US_WSREMS__Participant__c;
                            tempAff.US_WSREMS__Pharmacy_User__c = c.US_WSREMS__AR_New_Secondary_AR__c;
                        }
                        tempAff.US_WSREMS__isActive__c = false;
                        tempAff.US_WSREMS__User_Role__c = SECONDARY_AR;
                        tempAff.US_WSREMS__REMSProgram__c = c.US_WSREMS__REMS_Program__c;
                        affList.add(tempAff);
                }

                }

            }
        
            upsert affList;
            //1916 change
            List<US_WSREMS__Automation_Configuration__c> caseConfigurationList = [SELECT id,US_WSREMS__Verification_Expiration_Applies__c,US_WSREMS__Number_Of_Years_Verification_Valid__c,US_WSREMS__Verification_Agent_Task_Days_Before__c,US_WSREMS__Verification_Reminder_Days__c,US_WSREMS__RecertificationAgentTaskDaysBefore__c,US_WSREMS__RecertificationReminderDays__c,US_WSREMS__REMSCertificationExpirationApplies__c,US_WSREMS__NumberOfYearsCertificationValid__c,US_WSREMS__Object__c, US_WSREMS__Case_Record_Type__c, US_WSREMS__Do_we_need_to_check_incomplete_reason__c, US_WSREMS__REMS_Program__c,
                                                                    US_WSREMS__Case_Status__c, US_WSREMS__Case_Outcome__c, US_WSREMS__Account_Status__c, US_WSREMS__Account_Sub_Status__c, US_WSREMS__Type_of_Status__c, 
                                                                    US_WSREMS__Service_Status__c, US_WSREMS__Service_Outcome__c, US_WSREMS__Channel__c, US_WSREMS__Service_Path__c, US_WSREMS__Service_Stage__c,
                                                                    US_WSREMS__Date_Enrolled__c, US_WSREMS__Update_Signature__c, US_WSREMS__Update_AR_Account__c, US_WSREMS__KA_Parent_Reference__c, US_WSREMS__KA_Passed__c
                                                                    FROM  US_WSREMS__Automation_Configuration__c WHERE US_WSREMS__REMS_Program__c =: newCaseList[0].US_WSREMS__REMS_ID__c
                                                                    AND US_WSREMS__Case_Status__c =: newCaseList[0].US_WSREMS__Outcome__c AND US_WSREMS__Case_Outcome__c = : newCaseList[0].Status AND US_WSREMS__Case_Record_Type__c =:newCaseList[0].US_WSREMS__Record_Type_Name__c];
            if(!newCaseList.isEmpty()){
                Account acc = new Account(id = newCaseList[0].US_WSREMS__Participant__c);
                for(US_WSREMS__Affiliation__c af:affList){
                    if(af.US_WSREMS__User_Role__c == PRIMARY_AR && af.US_WSREMS__IsActive__c){
                        acc.US_WSREMS__Authorized_Representative__c = af.US_WSREMS__Authorized_Representative__c == null ? af.US_WSREMS__Pharmacy_User__c: af.US_WSREMS__Authorized_Representative__c;
                        acc.US_WSREMS__Prescriber_Signature__c = PRESCRIBER_SIGNATURE_YES;
                        acc.US_WSREMS__Prescriber_Signature_Date__c = newCaseList[0].US_WSREMS__AR_Signature_Date_New_Primary_AR__c;
                       //1916 change
                        if(caseConfigurationList.size()>0){
                            if(caseConfigurationList[0].US_WSREMS__Number_Of_Years_Verification_Valid__c != null &&
                               caseConfigurationList[0].US_WSREMS__Verification_Expiration_Applies__c == true &&
                               caseConfigurationList[0].US_WSREMS__Verification_Reminder_Days__c != null &&
                               caseConfigurationList[0].US_WSREMS__Verification_Agent_Task_Days_Before__c != null ){
                                   if(REMSAppLiterals.CASE_ENROLL_REENROLL_RECTYPE_SET_Certification.contains(caseConfigurationList[0].US_WSREMS__Case_Record_Type__c)){
                                       acc.US_WSREMS__VerificationComplete__c=true;
                                       acc.US_WSREMS__VerificationDueDate__c=system.now().addYears(integer.valueof(caseConfigurationList[0].US_WSREMS__Number_Of_Years_Verification_Valid__c));
                                       acc.US_WSREMS__VerificationReminderDate__c=acc.US_WSREMS__VerificationDueDate__c.addDays(- integer.valueof(caseConfigurationList[0].US_WSREMS__Verification_Reminder_Days__c));
                                       acc.US_WSREMS__VerificationAgentTaskDate__c=acc.US_WSREMS__VerificationDueDate__c.addDays(- integer.valueof(caseConfigurationList[0].US_WSREMS__Verification_Agent_Task_Days_Before__c));
                                   }
                                   else{
                                       acc.US_WSREMS__VerificationComplete__c=false;
                                       acc.US_WSREMS__VerificationDueDate__c=system.now().addYears(integer.valueof(caseConfigurationList[0].US_WSREMS__Number_Of_Years_Verification_Valid__c));
                                       acc.US_WSREMS__VerificationReminderDate__c=acc.US_WSREMS__VerificationDueDate__c.addDays(- integer.valueof(caseConfigurationList[0].US_WSREMS__Verification_Reminder_Days__c));
                                       acc.US_WSREMS__VerificationAgentTaskDate__c=acc.US_WSREMS__VerificationDueDate__c.addDays(- integer.valueof(caseConfigurationList[0].US_WSREMS__Verification_Agent_Task_Days_Before__c));
                                   }
                            }
                            //Re certification
                            if(caseConfigurationList[0].US_WSREMS__REMSCertificationExpirationApplies__c==true && caseConfigurationList[0].US_WSREMS__NumberOfYearsCertificationValid__c!=null &&
                            caseConfigurationList[0].US_WSREMS__RecertificationReminderDays__c!=null && caseConfigurationList[0].US_WSREMS__RecertificationAgentTaskDaysBefore__c!=null){
                                if(REMSAppLiterals.CASE_ENROLL_REENROLL_RECTYPE_SET_Certification.contains(caseConfigurationList[0].US_WSREMS__Case_Record_Type__c)){
                                    acc.US_WSREMS__Recertification_Complete__c=true;
                                    acc.US_WSREMS__Recertification_Due_Date__c=system.now().addYears(integer.valueof(caseConfigurationList[0].US_WSREMS__NumberOfYearsCertificationValid__c));
                                    acc.US_WSREMS__ReCertification_Reminder_Date__c=acc.US_WSREMS__Recertification_Due_Date__c.addDays(- integer.valueof(caseConfigurationList[0].US_WSREMS__RecertificationReminderDays__c));
                                    acc.US_WSREMS__ReCertification_Agent_Task_Date__c=acc.US_WSREMS__Recertification_Due_Date__c.addDays(- integer.valueof(caseConfigurationList[0].US_WSREMS__RecertificationAgentTaskDaysBefore__c));
                                }else{
                                    acc.US_WSREMS__Recertification_Complete__c=false;
                                    acc.US_WSREMS__Recertification_Due_Date__c=system.now().addYears(integer.valueof(caseConfigurationList[0].US_WSREMS__NumberOfYearsCertificationValid__c));
                                    acc.US_WSREMS__ReCertification_Reminder_Date__c=acc.US_WSREMS__Recertification_Due_Date__c.addDays(- integer.valueof(caseConfigurationList[0].US_WSREMS__RecertificationReminderDays__c));
                                    acc.US_WSREMS__ReCertification_Agent_Task_Date__c=acc.US_WSREMS__Recertification_Due_Date__c.addDays(- integer.valueof(caseConfigurationList[0].US_WSREMS__RecertificationAgentTaskDaysBefore__c));
                                }                            
                            }
                        }

                    }
                }
    
                if(!Test.isRunningTest()){
                    update acc;
                }
    
                if(oldPrimID != null){
                    deactivateSingleAffiliationUser(oldPrimID);
                }
                if(oldSecID != null){
                    deactivateSingleAffiliationUser(oldSecID);
                }
            }
 
            
        }catch(exception e){
            System.debug(e.getMessage()+':::'+e.getStackTraceString());
        }        
    }
    /**
     * This method deactivates a User associated with a single Affiliation record.
     * It checks if the User has any active affiliations and deactivates the User if no active affiliations are found.
     *
     * @param contactId The ID of the contact associated with the User to be deactivated.
     */
    @Future
    public static void deactivateSingleAffiliationUser(String contactId) {
        // Query to get active affiliations for the given contact ID
        Map<Id, US_WSREMS__Affiliation__c> afflMap = new Map<Id, US_WSREMS__Affiliation__c>([
            SELECT Id, US_WSREMS__Authorized_Representative__c, US_WSREMS__User_Role__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Pharmacy__c
            FROM US_WSREMS__Affiliation__c
            WHERE US_WSREMS__Authorized_Representative__r.PersonContactId = :contactId
            AND US_WSREMS__isActive__c = true
        ]); 

        // Check if there are no active affiliations
        if (afflMap.size() == 0) {
            // Query to get the User associated with the contact ID
            List<User> users = REMSUtils.getActiveUserByContactId(contactId);
            
            // Check if the User exists and is currently active
            if (!users.isEmpty() && users[0].IsActive) {
                // Get the first User record from the list
                User userToDeactivate = users[0];
                
                // Set the User's IsActive field to false to deactivate the User
                userToDeactivate.IsActive = false;

                // Update the User record in the database
                update userToDeactivate;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getAccountStatus(String accountId) {
        try {
            Account acc = [SELECT US_WSREMS__Status__c FROM Account WHERE Id = :accountId LIMIT 1];
            return acc.US_WSREMS__Status__c; 
        } catch (Exception e) {
            // Handle the case where the query returns no results or other errors
            return 'Error retrieving status';
        }
    }
    /**
     * This method creates and assigns a service to a case if certain conditions are met.
     *
     * @param newCaseList A list of Case records to process. The first case in the list will be processed.
     */
    public static void createAndAssignService(List<Case> newCaseList) {
        try {
            if (newCaseList != null && !newCaseList.isEmpty()) {
                if(newCaseList[0].US_WSREMS__REMS_Service_Summary__c == null){
                    String participantLabel = [select US_WSREMS__Recordtype_Label__c from Account Where id = :newCaseList[0].US_WSREMS__Participant__c limit 1].US_WSREMS__Recordtype_Label__c;
                    Id serviceId = OCRFormCtrl.createEnrollmentService(
                        newCaseList[0].US_WSREMS__REMS_Program__c,
                        newCaseList[0].US_WSREMS__Participant__c,participantLabel,
                        CHANGE_AR_RECORD_TYPE
                    );
                    newCaseList[0].US_WSREMS__REMS_Service_Summary__c = serviceId;
                }
            }
            
        }catch(exception e){
            System.debug(e.getMessage()+':::'+e.getStackTraceString());
        }   
    }
}