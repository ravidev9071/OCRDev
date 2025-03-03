/**
* @Description        : This class is used to get Duplicates Sub Stake Holders information and create new Account if No Accounts not found.
* @TestClass          : RREMSAccountCreation_Test
* @Author             : 
* @Modification Log   : 
* Ver       Date            Developer                   Modification
*                           Chandra                 Initial Implementation.
**/
 public with sharing class OCRRemsAccountCreation {
    @AuraEnabled(cacheable=true)
    public static List<US_WSREMS__REMS_Duplicate_Config__mdt> getAccountfieldMapping(){
        List<US_WSREMS__REMS_Duplicate_Config__mdt> getAccountfieldsMapping = new List<US_WSREMS__REMS_Duplicate_Config__mdt>();
        try {
            getAccountfieldsMapping =  [SELECT Id, Label, US_WSREMS__Source_Reference_Field__c,US_WSREMS__Target_Specific_Fields__c,US_WSREMS__Requestor_Type__c,US_WSREMS__Case_RecordTypeName__c, US_WSREMS__Participant_Type__c,US_WSREMS__Display_Fields__c,
                                        US_WSREMS__IsActive__c, US_WSREMS__Account_RecordTypeName__c,US_WSREMS__Account_FieldApiNames__c,US_WSREMS__TargetFieldsJSON__c,US_WSREMS__DataTable_Column__c,US_WSREMS__Main_Stakeholder_Account__c,
                                        US_WSREMS__Dublicate_Matching_Fields_JSON__c,US_WSREMS__Target_Object__c,US_WSREMS__Condition_Logic__c,US_WSREMS__Program__c,US_WSREMS__Program__r.MasterLabel, US_WSREMS__Title__c
                                        
                                        FROM US_WSREMS__REMS_Duplicate_Config__mdt WHERE US_WSREMS__IsActive__c=true];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return getAccountfieldsMapping;
    }
    /********************************************************************************************************************************************************
* Method Name          : createSubStakeHolderAccounts
* @Description         : Created Sub Stake Holders Rcords.
* @CreatedDate         : 
* @Author              : Jakeer
**********************************************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,String> createSubStakeHolderAccounts(List<AccountfieldMappingWrapper> fieldMapValue, String RequestRecordType, Id programId, String programName,String channel){
        
        Map<String,US_WSREMS__REMS_Duplicate_Config__mdt> getAccountCreationMdt =new Map<String,US_WSREMS__REMS_Duplicate_Config__mdt>();
        if(!Test.isRunningTest()){
            for(US_WSREMS__REMS_Duplicate_Config__mdt accconfig: [SELECT Id, Label, US_WSREMS__Source_Reference_Field__c, US_WSREMS__Target_Specific_Fields__c, US_WSREMS__TargetFieldsJSON__c,US_WSREMS__Requestor_Type__c,
                                                                  US_WSREMS__IsActive__c, US_WSREMS__Account_RecordTypeName__c,US_WSREMS__Account_FieldApiNames__c,US_WSREMS__Case_RecordTypeName__c 
                                                                  FROM US_WSREMS__REMS_Duplicate_Config__mdt WHERE US_WSREMS__Requestor_Type__c=: RequestRecordType AND US_WSREMS__Program__r.MasterLabel = :programName AND  US_WSREMS__IsActive__c=true]){
                                                                      if(String.isNotBlank(accconfig.US_WSREMS__Source_Reference_Field__c))  
                                                                          getAccountCreationMdt.put(accconfig.US_WSREMS__Source_Reference_Field__c,accconfig);
                                                                  }
        }else{
            getAccountCreationMdt.put('Facility__c', new US_WSREMS__REMS_Duplicate_Config__mdt(
                US_WSREMS__TargetFieldsJSON__c = '{"Facility_Account":{"US_WSREMS__Clinic_Facility_Name__c":"Name","US_WSREMS__REMS_Office_Contact_Phone__c":"Phone","US_WSREMS__Zip__c":"US_WSREMS__Zip__c","US_WSREMS__Affiliated_Hospital__c":"US_WSREMS__Affiliated_Hospital__c","US_WSREMS__Ext__c":"US_WSREMS__Alternate_Phone__c","US_WSREMS__Participant_Fax__c":"US_WSREMS__Fax_Alternate__c","US_WSREMS__Shipping_Address_Line_1__c":"US_WSREMS__Address_Line_1__c","US_WSREMS__Shipping_Address_Line_2__c":"US_WSREMS__Address_Line_2__c","US_WSREMS__Participant_City__c":"US_WSREMS__City__c","US_WSREMS__State__c":"US_WSREMS__State__c"}}',
                US_WSREMS__Account_RecordTypeName__c = 'Facility_Account',
                US_WSREMS__Target_Specific_Fields__c = 'US_WSREMS__Clinic_Facility_Name__c,US_WSREMS__Zip__c,US_WSREMS__Affiliated_Hospital__c,US_WSREMS__REMS_Office_Contact_Phone__c,US_WSREMS__REMS_Ext_Office_Contact_Phone__c,US_WSREMS__Participant_Fax__c,US_WSREMS__REMS_Ext_Office_Contact_Phone__c,US_WSREMS__Address_Line_2__c,US_WSREMS__Participant_City__c,US_WSREMS__State__c,US_WSREMS__Shipping_Address_Line_1__c,US_WSREMS__Shipping_Address_Line_2__c,US_WSREMS__REMS_Alternate_Phone_Ext__c,US_WSREMS__Ext__c',
                US_WSREMS__Source_Reference_Field__c  = 'US_WSREMS__Facility__c',
                US_WSREMS__Case_RecordTypeName__c = 'Facility_Account'
            )
                                     );
        }                                                 
        Map<String,Map<String,String>> storeApiValues = new Map<String,Map<String,String>>();
        Map<String,String> getRecordTypes = REMSUtils.retrieveRecTypeDeveloperNameId('Account');
        Map<String,String> getCaseRecordTypes = REMSUtils.retrieveRecTypeDeveloperNameId('case');
        List<Account> insertAccountlist = new List<Account>();
                System.debug('storeApiValues '+fieldMapValue);

        for(AccountfieldMappingWrapper afm: fieldMapValue){
            if(storeApiValues.containsKey(afm.recordtype)){
                storeApiValues.get(afm.recordtype).put(afm.fieldApiName,afm.feildValue);
            }else{
                Map<String,String> apivalues = new Map<String,String>();
                apivalues.put(afm.fieldApiName,afm.feildValue);
                storeApiValues.put(afm.recordtype,apivalues);
            }
        }
        List<String> sourceRefFields = new List<String>();
        Map<String,String> fieldValues = new Map<String,String>();
        System.debug('storeApiValues '+storeApiValues);
        for(String afm: storeApiValues.keyset()){
            if(getAccountCreationMdt.containskey(afm)){
                US_WSREMS__REMS_Duplicate_Config__mdt AccountCreationconfig = getAccountCreationMdt.get(afm);
                Map<String,Object> result =((Map<String, Object>)JSON.deserializeUntyped(AccountCreationconfig.US_WSREMS__TargetFieldsJSON__c));
                if(result.containskey(AccountCreationconfig.US_WSREMS__Account_RecordTypeName__c)){
                    Map<String,Object> getMapFields= (Map<String, Object>) result.get(AccountCreationconfig.US_WSREMS__Account_RecordTypeName__c);
                    Map<String,String> MappingAccountFields = new Map<String,String>();
                    Map<String,String> getfeildApiNames = storeApiValues.get(afm);
                    for(String st: AccountCreationconfig.US_WSREMS__Target_Specific_Fields__c.split(',')){
                        MappingAccountFields.put(st,(String)getMapFields.get(st));
                    }
                    Account acc = new Account();
                    for(String st: MappingAccountFields.keyset()){
                        if(MappingAccountFields.get(st)!=null){
                            acc.put(MappingAccountFields.get(st),getfeildApiNames.get(st));
                        }
                    }
                    acc.put('RecordTypeId',getRecordTypes.get(AccountCreationconfig.US_WSREMS__Account_RecordTypeName__c));
                    acc.put('US_WSREMS__REMS_Program__c',programId);
                    acc.put('US_WSREMS__Program_Picklist__c',programName);
                    acc.put('US_WSREMS__Channel__c',channel);
                    String tmp = addNamespace(AccountCreationconfig.US_WSREMS__Source_Reference_Field__c);
                    fieldValues.put(tmp+'-'+getRecordTypes.get(AccountCreationconfig.US_WSREMS__Account_RecordTypeName__c),tmp+'-'+getCaseRecordTypes.get(AccountCreationconfig.US_WSREMS__Case_RecordTypeName__c));
                    sourceRefFields.add(tmp);
                    insertAccountlist.add(acc);
                }
            }
        }
        set<Id> successInsertedAccountIds = new set<Id>();
        System.debug('insertAccountlist'+insertAccountlist);
        if(!insertAccountlist.isEmpty()){
            try{
                // DML statement  
                SObjectAccessDecision decision =    Security.stripInaccessible(AccessType.CREATABLE,insertAccountlist);
                if (!decision.getRecords().isEmpty()) {
                    Database.SaveResult[] srList = Database.insert(insertAccountlist, false); 
                    // Iterate through each returned result
                    Integer i = 0;
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            successInsertedAccountIds.add(sr.getId());
                        }else{
                            sourceRefFields.remove(i);
                            for(Database.Error objErr : sr.getErrors()) {
                                System.debug('Error has occurred.' + objErr.getStatusCode() + ': ' + objErr.getMessage());
                            }
                        }    
                        i++;  
                    }
                }                
            }catch(exception e){
                system.debug('Error---'+e.getMessage());
            }
        }
        Map<String,String> AccountIdsMap = new Map<String,String>();
        if(!successInsertedAccountIds.isEmpty()){
            Integer i=0;
              for(Account acc: [select id,RecordTypeId,RecordType.DeveloperName from Account WHERE Id IN:successInsertedAccountIds]){
                String tmp = sourceRefFields[i];
                if(fieldValues.containskey(tmp+'-'+acc.RecordTypeId)){
                    AccountIdsMap.put(fieldValues.get(tmp+'-'+acc.RecordTypeId),acc.Id);
                }
                i++;
            }
        }
        
        return AccountIdsMap;
    }
    
    
    @AuraEnabled
    public static void createSubstakeHolderCase(Id accountId, US_WSREMS__REMS_Duplicate_Config__mdt config){
        Map<String,String> accountToCaseFields = new Map<String,String>();
        Map<String,String> getCaseRecordTypes = REMSUtils.retrieveRecTypeDeveloperNameId('case');
        List<US_WSREMS__REMS_Service_Summary__c> serviceSumList = new List<US_WSREMS__REMS_Service_Summary__c>();
        serviceSumList = [SELECT Id FROM US_WSREMS__REMS_Service_Summary__c WHERE US_WSREMS__Participant__c=:accountId AND 
                          RecordType.DeveloperName = :OCRREMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT order by LastModifiedDate desc];
        if(Test.isRunningTest()){
            accountToCaseFields.put('Name','US_WSREMS__Last_Name__c');
        }else{
            for(US_WSREMS__Field_Mapping_Config__mdt fieldMappingConfig : [SELECT Id,US_WSREMS__Source_Field__c,US_WSREMS__Target_Field__c,US_WSREMS__Source_RecordType_Name__c,US_WSREMS__Target_RecordType_Name__c FROM US_WSREMS__Field_Mapping_Config__mdt WHERE US_WSREMS__Source_RecordType_Name__c  = :config.US_WSREMS__Case_RecordTypeName__c AND US_WSREMS__Source_Object__c = 'Case' AND US_WSREMS__Target_Object__c = 'Account' AND US_WSREMS__IsActive__c = TRUE AND US_WSREMS__Program__c = :config.US_WSREMS__Program__c AND US_WSREMS__Target_RecordType_Name__c =: config.US_WSREMS__Account_RecordTypeName__c]){
                if(!accountToCaseFields.containsKey(fieldMappingConfig.US_WSREMS__Target_Field__c)){
                    accountToCaseFields.put(fieldMappingConfig.US_WSREMS__Target_Field__c,fieldMappingConfig.US_WSREMS__Source_Field__c);
                }
            }
        }
        String query = 'SELECT Id, '+String.join(new List<String>(accountToCaseFields.keySet()),',')+ ' FROM Account WHERE Id =: accountId';
        Case newCase = new Case();
        newCase.put('US_WSREMS__Participant__c',accountId);
        if(!serviceSumList.isEmpty()){
            newCase.put('US_WSREMS__REMS_Service_Summary__c',serviceSumList[0].Id);
        }
        if(Test.isRunningTest()){
            newCase.RecordTypeId = getCaseRecordTypes.get('Facility_Account');
        }
        else{
            newCase.RecordTypeId = getCaseRecordTypes.get(config.US_WSREMS__Case_RecordTypeName__c);
        }
        for(Account account : Database.query(query)){
            for(String accountField : accountToCaseFields.keySet()){
                if(accountToCaseFields.containsKey(accountField) && account.get(accountField) != null)
                    newCase.put(accountToCaseFields.get(accountField),account.get(accountField));
            }
        }
        newCase.Status = 'Complete';
        newCase.US_WSREMS__Outcome__c = 'Complete';
        insert newCase;
    }
    
    @AuraEnabled
    public static Map<String,List<Account>> checkDuplicate(String duplicateConfig, Map<String, String> fieldValues, String programId){
        Map<String,List<Account>> response = new Map<String,List<Account>>();
        List<US_WSREMS__REMS_Duplicate_Config__mdt>  configs  = (List<US_WSREMS__REMS_Duplicate_Config__mdt> )JSON.deserialize(duplicateConfig, List<US_WSREMS__REMS_Duplicate_Config__mdt>.class);
        for(US_WSREMS__REMS_Duplicate_Config__mdt config : configs){
            if(config != null){
                Set<String> displayFieldSet = new Set<String>();
                String soqlQuery = '';
                if(config.US_WSREMS__Display_Fields__c != null || config.US_WSREMS__Dublicate_Matching_Fields_JSON__c != null){
                    Set<String> tempDisplayFieldSet = new Set<String>(config.US_WSREMS__Display_Fields__c.split(','));
                    displayFieldSet.addAll(tempDisplayFieldSet);
                    
                    // Deserialize matching criteria JSON
                    String matchingCriteriaJson = config.US_WSREMS__Dublicate_Matching_Fields_JSON__c;
                    List<MatchingCriterion> matchingCriteriaList = (List<MatchingCriterion>) JSON.deserialize(matchingCriteriaJson, List<MatchingCriterion>.class);
                    String conditionlogic = '('+config.US_WSREMS__Condition_Logic__c+')';
                    
                    // Build SOQL WHERE clause based on matching criteria
                    soqlQuery += '( ';
                    for (Integer i = 0; i < matchingCriteriaList.size(); i++) {
                        MatchingCriterion matchingCriterion = matchingCriteriaList[i];
                        String targetField = addNamespace(matchingCriterion.target_field);
                        String matchingCondition = matchingCriterion.matching_condition;
                        //String sourceFieldValue = 'test';
                        String sourceFieldValue = fieldValues.get(addNamespace(matchingCriterion.source_field));
                        if(matchingCriterion.datatype == 'date' && (String.isBlank(sourceFieldValue) || sourceFieldValue == 'null')){
                            sourceFieldValue = null;
                        }else if(sourceFieldValue == null || sourceFieldValue == 'null'){
                            sourceFieldValue = '';
                        }
                        String tempQuery = '';
                        if(matchingCriterion.datatype == 'date'){
                            tempQuery= ' '+targetField + ' ' + matchingCondition + ' ' + sourceFieldValue+' ';
                            
                        }else if (matchingCondition.equalsIgnoreCase('LIKE')) {
                            tempQuery= ' '+targetField + ' LIKE \'%' + sourceFieldValue + '%\' ';
                        } else {
                            tempQuery= ' '+targetField + ' ' + matchingCondition + ' \'' + sourceFieldValue+'\' ';
                        }
                        //soqlQuery+= tempQuery;
                        String tmp = '['+matchingCriterion.criteria_id+']';
                        conditionlogic = conditionlogic.replace(tmp,tempQuery);
                        
                        if (i < matchingCriteriaList.size() - 1) {
                            //soqlQuery += ' AND ';
                        }
                        else{
                            conditionlogic += ' AND RecordType.DeveloperName ='+ ' \'' +config.US_WSREMS__Account_RecordTypeName__c+'\' ' + ' AND (US_WSREMS__REMS_Program__c =:programId) ';
                        }
                    }
                    soqlQuery += conditionlogic;
                    soqlQuery += ' ) ';
                    
                    String displayFieldsQuery = String.join(new List<String>(displayFieldSet), ', ');
                    soqlQuery = 'SELECT RecordType.DeveloperName,' + addNamespace(displayFieldsQuery) + ' FROM '+config.US_WSREMS__Target_Object__c+' WHERE ' + soqlQuery ;
                    if(config.US_WSREMS__Main_Stakeholder_Account__c){
                        response.put('mainstake',Database.query(soqlQuery));
                    }else{
                        response.put(config.US_WSREMS__Source_Reference_Field__c,Database.query(soqlQuery));
                    }
                }
            }
        }
        return response;
    }
    
    /**
* Method to perform duplicate checkup.
* @param programCode The program code.
* @param stakeholder The stakeholder type.
* @param recordType The record type.
* @param fieldValues Map containing field values.
* @return List of duplicate records with label names of the display fields.
*/
    @AuraEnabled
    public static Map<String, List<Account>> performDuplicateCheckup(String RequestRecordType, String programName, String programId, Map<String, String> fieldValues) {
        // Retrieve matching criteria configurations from Custom Metadata Type
        List<US_WSREMS__REMS_Duplicate_Config__mdt> matchingConfigurations = [SELECT Id, Label, US_WSREMS__Source_Reference_Field__c, US_WSREMS__Target_Specific_Fields__c, US_WSREMS__Case_RecordTypeName__c,US_WSREMS__Display_Fields__c,
                                                                              US_WSREMS__IsActive__c, US_WSREMS__Account_RecordTypeName__c,US_WSREMS__Account_FieldApiNames__c ,US_WSREMS__Dublicate_Matching_Fields_JSON__c,US_WSREMS__Target_Object__c,US_WSREMS__Condition_Logic__c
                                                                              FROM US_WSREMS__REMS_Duplicate_Config__mdt WHERE US_WSREMS__Program__r.MasterLabel = :programName AND US_WSREMS__Requestor_Type__c=: RequestRecordType AND US_WSREMS__IsActive__c=true];
        List<Map<String, Object>> duplicateRecords = new List<Map<String, Object>>();
        Map<String,List<Account>> getAccounts = new Map<String,List<Account>>();
        US_WSREMS__REMS_Duplicate_Config__mdt matchedConfig;
        try {
            if (!matchingConfigurations.isEmpty()) {
                Set<String> displayFieldSet = new Set<String>();
                String soqlQuery = '';
                // Execute dynamic SOQL query
                for (Integer j = 0; j < matchingConfigurations.size(); j++) {
                    
                    US_WSREMS__REMS_Duplicate_Config__mdt config = matchingConfigurations[j];
                    if(config.US_WSREMS__Display_Fields__c == null || config.US_WSREMS__Dublicate_Matching_Fields_JSON__c == null){
                        continue;
                    }
                    matchedConfig =  matchingConfigurations[j];
                    Set<String> tempDisplayFieldSet = new Set<String>(config.US_WSREMS__Display_Fields__c.split(','));
                    displayFieldSet.addAll(tempDisplayFieldSet);
                    
                    // Deserialize matching criteria JSON
                    String matchingCriteriaJson = config.US_WSREMS__Dublicate_Matching_Fields_JSON__c;
                    List<MatchingCriterion> matchingCriteriaList = (List<MatchingCriterion>) JSON.deserialize(matchingCriteriaJson, List<MatchingCriterion>.class);
                    String conditionlogic = '('+config.US_WSREMS__Condition_Logic__c+')';
                    
                    // Build SOQL WHERE clause based on matching criteria
                    soqlQuery += '( ';
                    for (Integer i = 0; i < matchingCriteriaList.size(); i++) {
                        MatchingCriterion matchingCriterion = matchingCriteriaList[i];
                        String targetField = addNamespace(matchingCriterion.target_field);
                        String matchingCondition = matchingCriterion.matching_condition;
                        //String sourceFieldValue = 'test';
                        String sourceFieldValue = fieldValues.get(addNamespace(matchingCriterion.source_field));
                        if(sourceFieldValue == null || sourceFieldValue == 'null'){
                            sourceFieldValue = '';
                        }                   
                        String tempQuery = '';
                        if(matchingCriterion.datatype == 'date'){
                            tempQuery= ' '+targetField + ' ' + matchingCondition + ' ' + sourceFieldValue+' ';
                            
                        }else if (matchingCondition.equalsIgnoreCase('LIKE')) {
                            tempQuery= ' '+targetField + ' LIKE \'%' + sourceFieldValue + '%\' ';
                        } else {    
                            tempQuery= ' '+targetField + ' ' + matchingCondition + ' \'' + sourceFieldValue+'\' ';
                        }
                        //soqlQuery+= tempQuery;
                        String tmp = '['+matchingCriterion.criteria_id+']';
                        conditionlogic = conditionlogic.replace(tmp,tempQuery);
                        
                        if (i < matchingCriteriaList.size() - 1) {
                            //soqlQuery += ' AND ';
                        }
                        else{
                            conditionlogic += ' AND RecordType.DeveloperName ='+ ' \'' +config.US_WSREMS__Account_RecordTypeName__c+'\' ' + ' AND (US_WSREMS__REMS_Program__c =:programId) ';
                        }
                    }
                    soqlQuery += conditionlogic;
                    
                    
                    if (j < matchingConfigurations.size() - 1) {
                        soqlQuery += ') OR ';
                    }else{
                        soqlQuery += ' ) ';
                    }
                    
                }
                // Construct the SELECT clause of the SOQL query using the joined display fields
                String displayFieldsQuery = String.join(new List<String>(displayFieldSet), ', ');
                
                // Concatenate the SELECT and WHERE clauses to form the complete SOQL query
                soqlQuery = 'SELECT RecordType.DeveloperName,' + addNamespace(displayFieldsQuery) + ' FROM '+matchedConfig.US_WSREMS__Target_Object__c+' WHERE ' + soqlQuery ;
                
                for(Account acc: Database.query(soqlQuery)){
                    if(getAccounts.containskey(acc.RecordType.DeveloperName)){
                        getAccounts.get(acc.RecordType.DeveloperName).add(acc);
                    }else{
                        List<Account> accs = new List<Account>();
                        accs.add(acc);
                        getAccounts.put(acc.RecordType.DeveloperName,accs);
                    }
                }
                
                
            }
        } catch (Exception e) {
            String errorMessage = 'Error executing dynamic query: ' + e.getMessage() + '\nStack Trace: ' + e.getStackTraceString();
            System.debug(errorMessage);
        }
        
        return getAccounts;
    }
/********************************************************************************************************************************************************
* Method Name          : getAccountStatus
* @Description         : Checking selected StakeHolder Status
* @CreatedDate         : 24-Feb-2025
* @Author              : Chandra
**********************************************************************************************************************************************************/
     @AuraEnabled
     public static String getStakeHolderStatus(Id accountId){
         return [SELECT US_WSREMS__Status__c FROM Account WHERE Id=:accountId limit 1]?.US_WSREMS__Status__c;
     }  
    
    
 /********************************************************************************************************************************************************
* Method Name          : AccountfieldMappingWrapper
* @Description         : map feilds values and Api names from JS to Apex
* @CreatedDate         : 
* @Author              : Jakeer
**********************************************************************************************************************************************************/
    public class AccountfieldMappingWrapper{
        @AuraEnabled
        public String recordtype{ get; set;}
        @AuraEnabled
        public String fieldApiName{ get; set;}
        @AuraEnabled
        public String feildValue{ get; set;}
        public AccountfieldMappingWrapper(){
            recordtype='';fieldApiName='';feildValue='';
        }
        /********************************************************************************************************************************************************
* Method Name          : AccountfieldMappingWrapper
* @Description         : map feilds values and Api names from JS to Apex
* @CreatedDate         : 
* @Author              : Jakeer
**********************************************************************************************************************************************************/
        public AccountfieldMappingWrapper(String recordtype,String fieldApiName, String feildValue){
            this.recordtype = recordtype;
            this.fieldApiName = fieldApiName;
            this.feildValue = feildValue;
        }
    }
    
    public static String addNamespace(String fieldNames) {
        String namespacePrefix = OCRREMSAppLiterals.NAMESPACE_STRING;
        List<String> fieldList = new List<String>();
        
        // Split the comma-separated field names String into a list
        if (String.isNotBlank(fieldNames)) {
            fieldList = fieldNames.split(',');
        }
        
        List<String> namespacedFieldList = new List<String>();
        
        // Add namespace prefix to each field name in the list
        for (String fieldName : fieldList) {
            if (String.isNotBlank(namespacePrefix) && fieldName.contains('__') && !fieldName.startsWithIgnoreCase('SYN_')) {
                namespacedFieldList.add(namespacePrefix +  fieldName.trim());
            } else {
                // If namespace prefix is blank or null, or if the field already contains a '__', add the field name as is
                namespacedFieldList.add(fieldName.trim());
            }
        }
        
        // Join the list of namespaced field names into a comma-separated String
        return String.join(namespacedFieldList, ', ');
    }
    public class MatchingCriterion {
        public String target_field;
        public String source_field;
        public String matching_condition;
        public String criteria_id;
        public String datatype;
    }
    
    
    
    
}