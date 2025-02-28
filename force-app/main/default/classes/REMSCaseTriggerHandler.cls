/**
* ClassName: REMSCaseTriggerHandler
* Created By: Priya
* CreatedDate: 25th August, 2021
* Description: This class is being used as the Handler for Case Trigger
*/
public without sharing class REMSCaseTriggerHandler {
    
    /**
* methodName: preventDuplicateCaseCreation
* createddate: 25th August, 2021
* createdby: Priya
* lastmodifiedby: -- NONE--
* JIRATicket: PPP-249
* description: This method will run on Before Insert context and will prevent user from creating multiple cases for same REMS Service and Stage
*/
    public static void preventDuplicateCaseCreation(List<Case> newCaseList){
        //Variable Declaration
        Map<String, Case> uniquekeyToCaseMap = new Map<String, Case>();
        Set<Id> remsServiceIdsSet = new Set<Id>();
        Set<Id> caseRTIdsSet = new Set<Id>();
        Set<String> stagesSet = new Set<String>();
        try {
            for(Case newCaseObject : newCaseList){
                if(newCaseObject.US_WSREMS__REMS_Service_Summary__c != null && newCaseObject.US_WSREMS__REMS_Service_Stage__c != null){
                    remsServiceIdsSet.add(newCaseObject.US_WSREMS__REMS_Service_Summary__c);
                    caseRTIdsSet.add(newCaseObject.RecordTypeId);
                    stagesSet.add(newCaseObject.US_WSREMS__REMS_Service_Stage__c);
                    //Unique key by using CaseRecordTypeId, REMSServiceId and REMS service Stage
                    String uniqueKey = newCaseObject.RecordTypeId+'$$'+ newCaseObject.US_WSREMS__REMS_Service_Summary__c+'$$'+ newCaseObject.US_WSREMS__REMS_Service_Stage__c;
                    if(!uniquekeyToCaseMap.containsKey(uniqueKey)){
                        uniquekeyToCaseMap.put(uniqueKey, newCaseObject);
                    }
                    else{
                        newCaseObject.addError(System.Label.Duplicate_Case_in_the_Load);
                    }
                    
                }
            }
            
            //Query over existing cases
            for(Case existingCase : [SELECT Id,US_WSREMS__REMS_Service_Summary__c, RecordTypeId, US_WSREMS__REMS_Service_Stage__c 
                                     FROM Case 
                                     WHERE  US_WSREMS__REMS_Service_Summary__c IN: remsServiceIdsSet AND RecordTypeId IN: caseRTIdsSet AND US_WSREMS__REMS_Service_Stage__c IN: stagesSet WITH SECURITY_ENFORCED]){
                                         String uniqueKeyFromExistingCase = existingCase.RecordTypeId+'$$'+ existingCase.US_WSREMS__REMS_Service_Summary__c+'$$'+ existingCase.US_WSREMS__REMS_Service_Stage__c;
                                         if(uniquekeyToCaseMap.containsKey(uniqueKeyFromExistingCase)){
                                             uniquekeyToCaseMap.get(uniqueKeyFromExistingCase).addError(System.Label.Duplicate_Case_For_REMS_Service);
                                         }
                                     }
        }
        catch (Exception e) {
            REMSLoggerUtility.customLogs(e,'Exception while processing prevent case creation');
        }    
        
    }
    public static void checkServiceIsCompleted(List<Case> newCaseList)
    {
        Set<Id> serviceSummaryIdSet = new Set<Id>();
        Map<Id, US_WSREMS__REMS_Service_Summary__c > RssMap = new Map<Id, US_WSREMS__REMS_Service_Summary__c>();
        try {
            for (Case newCaseObject : newCaseList){
                if(newCaseObject.US_WSREMS__REMS_Service_Summary__c != null){
                    serviceSummaryIdSet.add(newCaseObject.US_WSREMS__REMS_Service_Summary__c);
                }
            }
            
            for (US_WSREMS__REMS_Service_Summary__c rss : [SELECT id,US_WSREMS__Path_Complete__c,US_WSREMS__Path_Stage_Name__c
                                                FROM US_WSREMS__REMS_Service_Summary__c
                                                WHERE id In : serviceSummaryIdSet WITH SECURITY_ENFORCED]){
                                                    RssMap.put(rss.id , rss);
                                                    
                                                }
            
            for (Case newCaseObject : newCaseList){
                if(newCaseObject.US_WSREMS__REMS_Service_Summary__c != null){
                    US_WSREMS__REMS_Service_Summary__c rssObj = RssMap.get(newCaseObject.US_WSREMS__REMS_Service_Summary__c);
                    if (rssObj.US_WSREMS__Path_Complete__c == true && rssObj.US_WSREMS__Path_Stage_Name__c==System.Label.Service_Closure_Value){
                        newCaseObject.addError(System.Label.Resticted_case_on_closed_Service);
                    }  
                }
            }
        }
        catch (Exception e) {
            REMSLoggerUtility.customLogs(e,'Exception while checking service is completed or not');
        }
        
        
    }
    public static void createSharingRecs(List<Case> caseList){
        
        Map<String,String> programIdVSGroupIdRead = New Map<String,String>();
        Map<String,String> programIdVSGroupIdReadEdit = New Map<String,String>();
        Map<String,US_WSREMS__Apexsharingconfig__c> programIdVSCustomSettingRec = New Map<String,US_WSREMS__Apexsharingconfig__c>();
        List<CaseShare> shareList = new List<CaseShare>();
        try {
            for(US_WSREMS__Apexsharingconfig__c csr : US_WSREMS__Apexsharingconfig__c.getAll().values())
            {
                if(csr.US_WSREMS__Read_Access__c == True)
                {
                    programIdVSGroupIdRead.put(csr.US_WSREMS__Program_Id__c,csr.US_WSREMS__Group_Id__c);
                }
                else
                {
                    programIdVSGroupIdReadEdit.put(csr.US_WSREMS__Program_Id__c,csr.US_WSREMS__Group_Id__c);
                }
            } 
            
            for(Case acc: caseList){
                if(programIdVSGroupIdRead.KeySet().Contains(acc.US_WSREMS__REMS_Program__c)){
                    CaseShare caseShare = new CaseShare(CaseId = acc.Id,UserOrGroupId = programIdVSGroupIdRead.get(acc.US_WSREMS__REMS_Program__c),
                                                        CaseAccessLevel = 'Read');
                    shareList.add(caseShare);
                }
                if(programIdVSGroupIdReadEdit.KeySet().Contains(acc.US_WSREMS__REMS_Program__c)){
                    CaseShare caseShare = new CaseShare(CaseId = acc.Id,UserOrGroupId = programIdVSGroupIdReadEdit.get(acc.US_WSREMS__REMS_Program__c),
                                                        CaseAccessLevel = 'Edit');
                    shareList.add(caseShare);
                }     
            }
            // DML statement  
            SObjectAccessDecision decision =    Security.stripInaccessible(AccessType.CREATABLE,shareList);
            if (!decision.getRecords().isEmpty()) {
                Database.insert(decision.getRecords(), false);       
            }
        }
        catch (Exception e) {
            REMSLoggerUtility.customLogs(e,'Exception while creating sharing records');
        }
        
    }
    
    // New Logic
    Private static final string caseObj = REMSAppLiterals.CASE_OBJECT;
    Private static final string CompleteStatus = System.Label.Case_Close_Status;
    
    private
        static final Map<Id, String> mapRemsRecordTypesById =
        REMSUtils.retrieveRecTypeIdDeveloperName(REMSAppLiterals.SERVICE_SUMMARY_OBJ);
    private
        static final Map<String, Id> mapRemsRecordTypesByDeveloperName =
        REMSUtils.retrieveRecTypeDeveloperNameId(REMSAppLiterals.SERVICE_SUMMARY_OBJ);
    private
        static final Map<Id, String> mapCaseRecordTypesById =
        REMSUtils.retrieveRecTypeIdDeveloperName(REMSAppLiterals.CASE_OBJECT);
    Private 
        static final Map<String, Schema.SObjectField> caseFieldAPItoLabelMap =
        Schema.getGlobalDescribe().get(caseObj).getDescribe().fields.getMap();
    
    Public static Map<String,String> errorMap = new Map<String,String>();
    public static string incompleteFields = '';
    
    public static void customValidation(List<Case> newCaseLst){
        
        Map<string, US_WSREMS__REMS_Objvalidation_and_status_automation__mdt> customValidationMap = new map<String, US_WSREMS__REMS_Objvalidation_and_status_automation__mdt>();
        set<Id> remsServiceId = new set<Id>();
        Map<Id,Id> remsIdtoRctyIdMap = new Map<Id,Id>();
        Set<String> programNameSet = new Set<String>();       
        Map<Id,String> serviceIdProgNameMap = new Map<Id,String>();
        
        try {
            for (case cseObj: newCaseLst ){
                if (cseObj.US_WSREMS__REMS_Service_Summary__c  == null){
                    continue;
                }
                remsServiceId.add(cseObj.US_WSREMS__REMS_Service_Summary__c);
            }
            for (US_WSREMS__REMS_Service_Summary__c remsServiceObj: [select id , recordtypeId,US_WSREMS__REMSProgram__c,US_WSREMS__REMSProgram__r.Name from US_WSREMS__REMS_Service_Summary__c where Id In:remsServiceId WITH SECURITY_ENFORCED]){
                remsIdtoRctyIdMap.put(remsServiceObj.id, remsServiceObj.RecordTypeId);
                programNameSet.add(remsServiceObj.US_WSREMS__REMSProgram__r.Name);
                
                serviceIdProgNameMap.put(remsServiceObj.Id,remsServiceObj.US_WSREMS__REMSProgram__r.Name);
            }
            
            List<String> requireFields = new List<String>();
            customValidationMap = createCustomValidationMap(caseObj,programNameSet, requireFields);
            for (case cseObj: newCaseLst ){
                if (cseObj.US_WSREMS__REMS_Service_Summary__c  == null){
                    continue;
                }
                String uniqueKey = mapCaseRecordTypesById.get(cseObj.RecordTypeId) 
                    +'$$'+mapRemsRecordTypesById.get(remsIdtoRctyIdMap.get(cseObj.US_WSREMS__REMS_Service_Summary__c))
                    +'$$'+serviceIdProgNameMap.get(cseObj.US_WSREMS__REMS_Service_Summary__c);  
                
                List<String> requiredFieldLst = customValidationMap.get(uniqueKey)?.US_WSREMS__Required_fields__c.deleteWhitespace().split(';');
                string errorMsg = '';
                
                if (requiredFieldLst == null || requiredFieldLst.isEmpty()){
                    return;
                }       
                for (string field : requireFields ){
                    if (String.isBlank(String.valueOf(cseObj.get(field))) || String.valueOf(cseObj.get(field)) == 'false'){
                        if(caseFieldAPItoLabelMap.containsKey(field)){ 
                            errorMsg += caseFieldAPItoLabelMap.get(field).getDescribe().getLabel()+';';
                        }
                    }
                }
                if(string.isBlank(errorMsg) && cseObj.Status == CompleteStatus){
                    cseObj.Incomplete_Reasons__c = null;                  
                } else if(string.isNotBlank(errorMsg) && cseObj.Status == CompleteStatus){
                    cseObj.addError(customValidationMap.get(uniqueKey).US_WSREMS__ErrorMsg__c+': '+errorMsg.removeEnd(';') );                  
                }else if(string.isNotBlank(errorMsg)){
                    cseObj.US_WSREMS__Incomplete_Reasons__c = errorMsg;
                }else if(string.isBlank(errorMsg)){
                    cseObj.US_WSREMS__Incomplete_Reasons__c = errorMsg;
                }             
            }
        }
        catch (Exception e) {
            REMSLoggerUtility.customLogs(e,'Exception while processing custom validation');
        }      
        
    }
    private static Map<string, List<String>> createProgramBasedCustomValidationMap(String ObjectAPI,Set<String> progamNames){
        Map<string, List<String>> customValidationMap = new map<String, List<String>>();
        errorMap  = new Map<String,String>();
        for (US_WSREMS__REMS_Objvalidation_and_status_automation__mdt objVaL_mdt : [SELECT US_WSREMS__Object_API_Name__c, US_WSREMS__Object_recordType_DevName__c,US_WSREMS__Rems_Service_RCtype__c, US_WSREMS__Required_fields__c, US_WSREMS__ErrorMsg__c
                                                                         FROM US_WSREMS__REMS_Objvalidation_and_status_automation__mdt
                                                                         where US_WSREMS__Object_API_Name__c =: ObjectAPI AND US_WSREMS__Program__c != null AND US_WSREMS__Program__r.MasterLabel = : progamNames AND US_WSREMS__IsActive__c = true]){
                                                                             String uniqueKeyStr = objVaL_mdt.US_WSREMS__Object_recordType_DevName__c+'$$'+objVaL_mdt.US_WSREMS__Rems_Service_RCtype__c;
                                                                             if(!customValidationMap.containsKey(uniqueKeyStr)){
                                                                                 customValidationMap.put(uniqueKeyStr,new List<String> {objVaL_mdt.US_WSREMS__Required_fields__c});
                                                                                 errorMap.put(uniqueKeyStr,objVaL_mdt.US_WSREMS__ErrorMsg__c);
                                                                             }else{
                                                                                 customValidationMap.get(uniqueKeyStr).add(objVaL_mdt.US_WSREMS__Required_fields__c);
                                                                             }
                                                                         }
        return customValidationMap;
    }
    
    private static Map<string, US_WSREMS__REMS_Objvalidation_and_status_automation__mdt> createCustomValidationMap(String ObjectAPI, Set<String> programNameSet, List<String> requireFields){
        Map<string, US_WSREMS__REMS_Objvalidation_and_status_automation__mdt> customValidationMap = new map<String, US_WSREMS__REMS_Objvalidation_and_status_automation__mdt>();
        try {String fieldWithNameSpace = REMSAppLiterals.NAMESPACE_STRING;
             for (US_WSREMS__REMS_Objvalidation_and_status_automation__mdt objVaL_mdt : [select US_WSREMS__Object_API_Name__c , US_WSREMS__Object_recordType_DevName__c ,US_WSREMS__Rems_Service_RCtype__c , 
                                                                              US_WSREMS__Required_fields__c, US_WSREMS__ErrorMsg__c,US_WSREMS__Program__c,US_WSREMS__Program__r.Label   
                                                                              FROM US_WSREMS__REMS_Objvalidation_and_status_automation__mdt 
                                                                              where US_WSREMS__Object_API_Name__c =: ObjectAPI AND  US_WSREMS__IsActive__c = true 
                                                                              AND US_WSREMS__Program__r.Label IN:programNameSet ]){
                                                                                  String uniqueKeyStr = objVaL_mdt.US_WSREMS__Object_recordType_DevName__c+'$$'+objVaL_mdt.US_WSREMS__Rems_Service_RCtype__c+'$$'+objVaL_mdt.US_WSREMS__Program__r.Label;
                                                                                  customValidationMap.put(uniqueKeyStr, objVaL_mdt);              
                                                                                  requireFields.add(fieldWithNameSpace+objVaL_mdt.US_WSREMS__Required_fields__c);
                                                                              }
             return customValidationMap;
            }
        catch (Exception e) {
            REMSLoggerUtility.customLogs(e,'Exception while creating custom validation map');
        }
        return null;
    }
    public static void handleAfterUpdate(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
        if(REMSAvoidRecursiveCls.stop_accountUpdate==false)
            updateStakeHolderAccounts(newCaseMap, oldCaseMap);    
    }  
    public static void updateStakeHolderAccounts(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
        Set<Id> programIdSet = new Set<Id>();
        Set<String> accountCaseRecordTypes = new Set<String>{
            'Pharmacy_Account','Prescriber_Person_Account','Prescribing_Institution_Account','Pharmacy_Participant_Account','SYN_Patient_Person_Account',
                'General_Contact','SYN_Distributor_Account'
                };
                    
                    List<Case> filteredCases = new List<Case>();
        try {
            for(Case caseRec : newCaseMap.values()){
                
                String caseRecTypeDevName = mapCaseRecordTypesById.get(caseRec.RecordTypeId);
                if(accountCaseRecordTypes.contains(caseRecTypeDevName)){
                    
                    filteredCases.add(caseRec); 
                    if(caseRec.US_WSREMS__REMS_Program__c!=null){
                        programIdSet.add(caseRec.US_WSREMS__REMS_Program__c);
                    }
                }
            }
            
            if(!filteredCases.isEmpty()){              
                List<Account> accListToInsert = New List<Account>();
                Account stakeHolderAccount = new Account();      
                Id prescriberCaseRecordTypeId = REMSUtils.retrieveRecTypeDeveloperNameId(REMSAppLiterals.CASE_OBJECT).get('Prescriber_Person_Account');       
                Id presInstrecordTypeId = REMSUtils.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get('Prescribing_Institution');        
                Map<String,String> sourceAndTargetFieldMapping = new Map<String,String>();
                Map<String,Object> CaseFieldsVsValuesMap = New Map<String,Object>();
                Map<String,Object> AccFieldsAPIVsCaseFieldValuesMap = New Map<String,Object>(); //Not used yet             
                Map<Id,String> mapofCaseRecordTypeIdandName = REMSUtils.retrieveRecTypeIdDeveloperName(REMSAppLiterals.CASE_OBJECT);  
                if(programIdSet!=null && programIdSet.size()>0){
                    Map<Id,US_WSREMS__REMS_Program__c> programMap = new Map<Id,US_WSREMS__REMS_Program__c>();
                    List<US_WSREMS__Field_Mapping_Config__mdt> fieldMappingList = new  List<US_WSREMS__Field_Mapping_Config__mdt>();        
                    Map<String, Map<String, String>> recordTypeAndFieldMapping = new Map<String, Map<String, String>>(); 
                    Set<String> programNameSet = new Set<String>();
                    for(US_WSREMS__REMS_Program__c programObj:[SELECT Id, Name FROM US_WSREMS__REMS_Program__c WHERE Id IN:programIdSet]){
                        programMap.put(programObj.Id,programObj);
                        programNameSet.add(programObj.Name);
                    }
                    
                    fieldMappingList = getSourceAndTargetFieldMapping(programNameSet);   
                    for(US_WSREMS__Field_Mapping_Config__mdt fm : fieldMappingList){
                        
                        if(!recordTypeAndFieldMapping.containsKey(fm.US_WSREMS__Source_RecordType_Name__c+'#'+fm.US_WSREMS__Program__r.Label)){
                            
                            recordTypeAndFieldMapping.put(fm.US_WSREMS__Source_RecordType_Name__c+'#'+fm.US_WSREMS__Program__r.Label, new Map<String, String>());
                        }
                        
                        Map<String, String> tempMap = recordTypeAndFieldMapping.get(fm.US_WSREMS__Source_RecordType_Name__c+'#'+fm.US_WSREMS__Program__r.Label);                            
                        tempMap.put(fm.US_WSREMS__Source_Field__c, fm.US_WSREMS__Target_Field__c);
                        recordTypeAndFieldMapping.put(fm.US_WSREMS__Source_RecordType_Name__c+'#'+fm.US_WSREMS__Program__r.Label, tempMap);
                    } 
                    
                    for(Case cs: filteredCases){
                        
                        stakeHolderAccount = New Account();
                        
                        if(cs.US_WSREMS__Participant__c != NULL ){
                            
                            stakeHolderAccount.Id = cs.US_WSREMS__Participant__c;
                            
                            CaseFieldsVsValuesMap = New Map<String,Object>();
                            String recDevName = mapofCaseRecordTypeIdandName.get(cs.RecordTypeId);
                            String keyStr = recDevName+'#'+programMap.get(cs.US_WSREMS__REMS_Program__c).Name;
                            sourceAndTargetFieldMapping = recordTypeAndFieldMapping.get(keyStr);
                            if (sourceAndTargetFieldMapping != null) {
                                for(String cs1 : sourceAndTargetFieldMapping.keySet()){
                                    
                                    CaseFieldsVsValuesMap.put(cs1, cs.get(cs1));                
                                }
                                
                                for(String cs1 : sourceAndTargetFieldMapping.keySet()){
                                    
                                    stakeHolderAccount.put(sourceAndTargetFieldMapping.get(cs1), CaseFieldsVsValuesMap.get(cs1));
                                }
                            }
                            
                            
                            
                            if((cs.RecordTypeId == prescriberCaseRecordTypeId) ){                    
                                
                                stakeHolderAccount.ShippingStreet = cs.US_WSREMS__Address_Line_1__c;
                                stakeHolderAccount.US_WSREMS__REMS_Shipping_Address_2__c = cs.US_WSREMS__Address_Line_2__c;
                                stakeHolderAccount.ShippingCity=cs.US_WSREMS__City__c;
                                stakeHolderAccount.ShippingState = cs.US_WSREMS__State__c;
                                stakeHolderAccount.ShippingPostalCode=cs.US_WSREMS__REMS_Zip_Code__c;
                                stakeHolderAccount.ShippingCountry=cs.US_WSREMS__REMS_Country__c;
                                stakeHolderAccount.Phone = cs.US_WSREMS__Phone__c;
                                stakeHolderAccount.FAX = cs.US_WSREMS__Fax__c;
                                stakeHolderAccount.US_WSREMS__Ext__c = cs.US_WSREMS__REMS_Ext__c;
                                stakeHolderAccount.US_WSREMS__Email__c = cs.US_WSREMS__Email__c;
                                stakeHolderAccount.US_WSREMS__Preferred_Contact_Method__c = cs.US_WSREMS__Preferred_Contact_Method__c;
                            }                     
                            accListToInsert.add(stakeHolderAccount);
                        }
                    }
                    
                    
                    if(!accListToInsert.isEmpty()){
                        // DML statement
                        SObjectAccessDecision groupDecission =    Security.stripInaccessible(AccessType.UPDATABLE,accListToInsert);
                        
                        if (!groupDecission.getRecords().isEmpty()) {
                            List<Database.SaveResult> accInserted = Database.update(groupDecission.getRecords(), false);       
                        }
                    } 
                }          
                
            }        
        }
        catch (Exception e) {
            REMSLoggerUtility.customLogs(e,'Exception while updating stack holder accounts');
        }
        
    }
    public static List<US_WSREMS__Field_Mapping_Config__mdt> getSourceAndTargetFieldMapping(Set<String> programNameSet){
        
        return [SELECT US_WSREMS__Source_Field__c, US_WSREMS__Source_Object__c,US_WSREMS__Source_RecordType_Name__c,US_WSREMS__Target_Field__c,US_WSREMS__Target_Object__c,
                US_WSREMS__Target_RecordType_Name__c, US_WSREMS__Program__r.Label  
                FROM US_WSREMS__Field_Mapping_Config__mdt 
                WHERE US_WSREMS__Is_Account_Creation__c = true AND US_WSREMS__IsActive__c = true 
                AND US_WSREMS__Program__r.Label IN:programNameSet];
    }
    Public static void completeCasestatusOnInsert(List<Case>newList){
        Set<Id> ParticipantIdLst = new Set<Id>();
        for (case cse : newList){
            if( cse.Status == System.Label.Case_Close_Status){
                ParticipantIdLst.add(cse.US_WSREMS__Participant__c);
            }
        }
        if (!ParticipantIdLst.isEmpty()){
            completeCasestatus(ParticipantIdLst);
        }
    }
    Public static void completeCasestatusOnUpdate(List<Case>newList , Map<Id,Case> oldMap){
        Set<Id> ParticipantIdLst = new Set<Id>();
        for (case cse : newList){
            if(cse.Status != oldMap.get(cse.id).Status && cse.Status == System.Label.Case_Close_Status ){
                ParticipantIdLst.add(cse.US_WSREMS__Participant__c);
            }
        }
        if (!ParticipantIdLst.isEmpty()){
            completeCasestatus(ParticipantIdLst);
        }
        
    }
    public static void completeCasestatus( Set<Id> ParticipantIdLst  ){
        List<US_WSREMS__REMS_Service_Summary__c> closeRemsServiceLst = new List<US_WSREMS__REMS_Service_Summary__c>();
        
        try {
            for ( US_WSREMS__REMS_Service_Summary__c  REMSS : [select id , US_WSREMS__StageName__c,US_WSREMS__Status__c,US_WSREMS__Path_Complete__c  from US_WSREMS__REMS_Service_Summary__c where recordtypeId =: mapRemsRecordTypesByDeveloperName.get('Participant_Enrollment')
                                                    and US_WSREMS__Participant__c In: ParticipantIdLst WITH SECURITY_ENFORCED]){
                                                        //REMSS.StageName__c = 'closed'; 
                                                        REMSS.US_WSREMS__Path_Stage_Name__c  = System.Label.Service_Closure_Value;
                                                        REMSS.US_WSREMS__Status__c = System.Label.Service_Closure_Value;
                                                        REMSS.US_WSREMS__Path_Complete__c = true;
                                                        
                                                        closeRemsServiceLst.add(REMSS);            
                                                    }
            
            if (!closeRemsServiceLst.isEmpty() && REMSAvoidRecursiveCls.stop_serviceupdateFromPortal==false){
                // DML statement
                SObjectAccessDecision groupDecission =    Security.stripInaccessible(AccessType.UPDATABLE,closeRemsServiceLst);
                
                if (!groupDecission.getRecords().isEmpty()) {
                    Database.update(groupDecission.getRecords(), false);       
                }
            }
        }
        catch (Exception e) {
            REMSLoggerUtility.customLogs(e,'Exception while processing complete case status');
        }
        
    }
    public static void updateCaseDateonComplete(List<Case> newCase, Map<Id, Case> oldMap) {
        Id patientPregnancyTestCaseRecordTypeId = REMSUtils.retrieveRecTypeDeveloperNameId(REMSAppLiterals.CASE_OBJECT).get('Patient_Pregnancy_Test');
        
        List<Case> caseToUpdate = new List<Case>();
        
        for (Case c : newCase) {
            if (c.Status == System.Label.Case_Close_Status && ((oldMap != null && oldMap.get(c.Id).Status != System.Label.Case_Close_Status) || oldMap == null) ){
                if (c.RecordTypeId == patientPregnancyTestCaseRecordTypeId) {
                    c.Date_of_Confirmation__c = System.today();
                    caseToUpdate.add(c);
                }
            }
        }
    } 
    Public static void prePopulateProgramName(List<Case> newCaseList){

        Set<string> programName = new Set<string>();
        Map<string,US_WSREMS__REMS_Program__c> remsProgramMap = new Map<string,US_WSREMS__REMS_Program__c>();
        for(case cs : newCaseList){
            if(cs.US_WSREMS__Program_Picklist__c!=null && cs.US_WSREMS__REMS_Program__c == null){
                programName.add(cs.US_WSREMS__Program_Picklist__c);
            }
        }
        for(US_WSREMS__REMS_Program__c rp: [SELECT Id,Name FROM US_WSREMS__REMS_Program__c WHERE Name IN : programName AND US_WSREMS__Status__c ='Active' WITH SECURITY_ENFORCED]){
            remsProgramMap.put(rp.Name,rp);
        }
        for(case cs : newCaseList){
            if(cs.US_WSREMS__Program_Picklist__c!=null && cs.US_WSREMS__REMS_Program__c == null && remsProgramMap.containsKey(cs.US_WSREMS__Program_Picklist__c)){
                cs.US_WSREMS__REMS_Program__c =  remsProgramMap.get(cs.US_WSREMS__Program_Picklist__c).Id;
            }
        }
    }

    public static void prePopulateCaseFields(List<Case> newCaseList,Map<Id,Case> oldCaseMap){
        Map<string,string> caseRecordTypeMap = new Map<String,String>();
        Set<String> recordTypeName = new Set<String>();
        Set<String> requestorTypes = new Set<String>();
        Set<Id> programId = new Set<Id>();
        Set<String> caseStatus = new Set<String>();
        Set<String> caseOutcome = new Set<String>();
        Map<Id,String> retrieveRecTypeIdDeveloperName = new Map<Id,String>();
        Set<String> errorStringSet = new Set<String>();
        retrieveRecTypeIdDeveloperName = REMSUtils.retrieveRecTypeIdDeveloperName(REMSAppLiterals.CASE_OBJECT);
          for(case cs : newCaseList){
                     String recordTypeDeveloperName= retrieveRecTypeIdDeveloperName.get(cs.RecordTypeId);
                     recordTypeName.add(recordTypeDeveloperName);
                     programId.add(cs.US_WSREMS__REMS_Program__c);
                     caseRecordTypeMap.put(recordTypeDeveloperName,cs.US_WSREMS__REMS_Program__c);
                 	 requestorTypes.add(cs.US_WSREMS__Service_Requestor_Type__c);
                      caseStatus.add(cs.Status);
                 	 caseOutcome.add(cs.US_WSREMS__Outcome__c);
            }
            
            Map<Id,US_WSREMS__REMS_Program__c> programMap = getProgramMap(programId);
            Map<String,US_WSREMS__REMS_Service_Configuration__mdt> caseStatusMap = getCaseStatusConfigMap(caseRecordTypeMap,programMap);
            List<US_WSREMS__Program_Fields_Configuration__c> programFieldsList = getProgramFields(recordTypeName,programId,requestorTypes);
            Set<String> queryFldSet = new Set<String>();
            String caseProgramQry = 'SELECT Id,Case__c ';
            Map<Id,US_WSREMS__CaseProgram__c> caseProgramParentMap = new Map<Id,US_WSREMS__CaseProgram__c>();
        	if(!programFieldsList.isEmpty()){
                for(US_WSREMS__Program_Fields_Configuration__c pfcObj: programFieldsList){
                    if(pfcObj.US_WSREMS__ReferenceObject__c!=null 
                       && pfcObj.US_WSREMS__Target_Object_Field__c!=null && pfcObj.US_WSREMS__Target_Object_Field__c!=REMSAppLiterals.NAMESPACE_STRING+'Case__c'){
                        queryFldSet.add(pfcObj.US_WSREMS__Target_Object_Field__c);
                    }
                }
                if(!queryFldSet.isEmpty()){
                    for(String quryFld: queryFldSet){
                        caseProgramQry = caseProgramQry+','+quryFld;
                    }
                    caseProgramQry = caseProgramQry+' FROM CaseProgram__c WHERE Case__c IN :newCaseList ORDER BY LastModifiedDate desc';
                    for(US_WSREMS__CaseProgram__c caseProgObj: Database.Query(caseProgramQry)){
                        if(!caseProgramParentMap.containsKey(caseProgObj.US_WSREMS__Case__c)){
                            caseProgramParentMap.put(caseProgObj.US_WSREMS__Case__c,caseProgObj);
                        }
                    }
                }
    		}
            if(programMap != null){
                 for(Case c : newCaseList){
                 
                     String recordTypeDeveloperName= retrieveRecTypeIdDeveloperName.get(c.RecordTypeId);
                     
                     if(oldCaseMap == null){
                        // Prepoulate the program field
                            if(c.US_WSREMS__Program_Picklist__c != null && programMap.containsKey(c.US_WSREMS__REMS_Program__c)){
                                c.US_WSREMS__Program_Picklist__c = programMap.get(c.US_WSREMS__REMS_Program__c).Name;
                            }
                         // prepoulate the status and out come
                         if(caseStatusMap != null && caseStatusMap.containsKey(recordTypeDeveloperName+c.US_WSREMS__Program_Picklist__c)){
                             US_WSREMS__REMS_Service_Configuration__mdt sc = caseStatusMap.get(recordTypeDeveloperName+c.US_WSREMS__Program_Picklist__c);
                             if(REMSAvoidRecursiveCls.stop_accountUpdate = False){
                             if(sc.US_WSREMS__Case_Status__c != null && sc.US_WSREMS__Case_Status__c != '' && c.Status!=REMSAPPLiterals.COMPLETE){
                                 c.Status = sc.US_WSREMS__Case_Status__c;
                             }
                             if(sc.US_WSREMS__Case_Outcome__c!= null && sc.US_WSREMS__Case_Outcome__c!= '' && c.US_WSREMS__Outcome__c!=REMSAPPLiterals.COMPLETE){
                                 c.US_WSREMS__Outcome__c = sc.US_WSREMS__Case_Outcome__c;
                             }
                            }
         
                         }
                     }
                         
                     String errMsg = '';
                     if(programFieldsList == null){
                         return;
                     }
                     for(US_WSREMS__Program_Fields_Configuration__c pf : programFieldsList){
                         if(pf.US_WSREMS__Target_Object_Record_Type__c == recordTypeDeveloperName && pf.US_WSREMS__REMS_Program__c == c.US_WSREMS__REMS_Program__c && pf.US_WSREMS__Requestor_Type__c == c.US_WSREMS__Service_Requestor_Type__c){
                            String sourceFieldValue ;
                            if(pf.US_WSREMS__ReferenceObject__c!=null && pf.US_WSREMS__ReferenceObject__c == REMSAppLiterals.NAMESPACE_STRING+'CaseProgram__c'
                              && !caseProgramParentMap.isEmpty() && caseProgramParentMap.containsKey(c.Id)){
                                sourceFieldValue = String.valueOf(caseProgramParentMap.get(c.Id).get(pf.US_WSREMS__Target_Object_Field__c));
                            }
                            
                            if(pf.US_WSREMS__ReferenceObject__c ==null){
                                sourceFieldValue = String.valueOf(c.get(pf.US_WSREMS__Target_Object_Field__c));
                            }
                            if(sourceFieldValue == null || sourceFieldValue == '' || (pf.US_WSREMS__Incomplete_Value__c != null && pf.US_WSREMS__Incomplete_Value__c.contains(sourceFieldValue))){
                             if(pf.US_WSREMS__Validation_Label__c != null){
                                 errorStringSet.add(pf.US_WSREMS__Validation_Label__c);
}else{
                                errorStringSet.add(pf.US_WSREMS__Target_Object_Field_Label__c);
                            }
                                 
                             }
                         }
                     }
                     
                     if(!errorStringSet.isEmpty()){
                        for(String errStr: errorStringSet){
                            errMsg = errMsg!=null?errMsg+errStr+';':errStr+';';
                        }
                        
                    }
                     c.US_WSREMS__Incomplete_Reasons__c = errMsg;
                   
                         if(c.US_WSREMS__Incomplete_Reasons__c != null && c.US_WSREMS__Incomplete_Reasons__c != ''  && c.Status =='Complete'

                            && ((c.US_WSREMS__Channel__c!=REMSAppLiterals.CASE_CHANNEL_PORTAL) || (recordTypeDeveloperName == REMSAppLiterals.SERVICE_RECTYPE_CHANGE_AUTHORIZED_REPRESENTATIVE)||
                                (c.US_WSREMS__Channel__c == REMSAppLiterals.CASE_CHANNEL_PORTAL && recordTypeDeveloperName == REMSAppLiterals.CASE_RECORDTYPE_OUTPATIENT_PHARMACY_ENROLLMENT)) ){
                             c.AddError(Label.casesoftrequiredfields);
                         }
                         if (recordTypeDeveloperName == REMSAppLiterals.CASE_RECORDTYPE_KNOWLEDGE_ASSESSMENT && c.Status == REMSAppLiterals.CASE_STATUS_COMPLETED) {
                            List<US_WSREMS__Assessment_Submission__c> submissions = queryAssessmentSubmissions(c.Id);
                            if (!submissions.isEmpty()) {
                                for (US_WSREMS__Assessment_Submission__c submission : submissions) {
                                    if (submission.US_WSREMS__Assessment_Result__c == REMSAppLiterals.FAILED) {
                                        c.AddError(Label.KnowledgeAssessmentFail);
                                    }
                                }
                            }
                        }
                
                 }
                
                if(REMSAvoidRecursiveCls.stop_accountUpdate == False){
                   	caseAutomationController.AssignCaseStatus(newCaseList,programId,recordTypeName);
                    caseAutomationController.updateCaseStatus(newCaseList,programId,recordTypeName);
                    caseAutomationController.checkCaseStatus(newCaseList,programId,recordTypeName,caseStatus,caseOutcome);
                 }
             }
             
        }
/********************************************************************************************************************************************************
MethodName : queryAssessmentSubmissions
Description: This method retrieves Assessment Submission based on Case Id.
CreatedDate: 18 Feb 2024
@Author    : Sukanya
**************************************************************************************************************/

    public static List<US_WSREMS__Assessment_Submission__c> queryAssessmentSubmissions(Id caseId) {
        return [SELECT Id, Name, US_WSREMS__Assessment_Result__c
                FROM US_WSREMS__Assessment_Submission__c
                WHERE US_WSREMS__Case__c = :caseId ORDER BY CreatedDate desc LIMIT 1];
    }   

    public static Map<Id,US_WSREMS__REMS_Program__c> getProgramMap(Set<Id> programIds){
        Map<Id,US_WSREMS__REMS_Program__c> programMap = new Map<Id,US_WSREMS__REMS_Program__c>([SELECT Id,Name FROM US_WSREMS__REMS_Program__c WHERE Id IN : programIds AND US_WSREMS__Status__c ='Active' WITH SECURITY_ENFORCED]);   
        return programMap;  
    }


    public static Map<String,US_WSREMS__REMS_Service_Configuration__mdt> getCaseStatusConfigMap(Map<String,Id> recordTypeMap, Map<Id,US_WSREMS__REMS_Program__c> programMap){
        Set<String> recordTypes = new Set<String>(recordTypeMap.keySet());
            Map<String,US_WSREMS__REMS_Service_Configuration__mdt> statusConfigMap = new Map<String,US_WSREMS__REMS_Service_Configuration__mdt>();
            List<US_WSREMS__REMS_Service_Configuration__mdt> serviceConfigList = [SELECT Id, US_WSREMS__Case_Record_Type__c, US_WSREMS__Case_Status__c, US_WSREMS__Case_Outcome__c,
                                                                        US_WSREMS__Program_Configuration__c, US_WSREMS__Program_Configuration__r.Label
                                                                        FROM US_WSREMS__REMS_Service_Configuration__mdt    
                                                                        WHERE US_WSREMS__Object__c = 'Case' AND US_WSREMS__Case_Record_Type__c =: recordTypeMap.keySet()];
            if(serviceConfigList.isEmpty()){
                return statusConfigMap;
            }                                                          
            
            for(US_WSREMS__REMS_Service_Configuration__mdt sc: serviceConfigList){
                if(recordTypeMap.containsKey(sc.US_WSREMS__Case_Record_Type__c) && programMap.containsKey(recordTypeMap.get(sc.US_WSREMS__Case_Record_Type__c)) 
                && programMap.get(recordTypeMap.get(sc.US_WSREMS__Case_Record_Type__c)).Name == sc.US_WSREMS__Program_Configuration__r.Label){
                    statusConfigMap.put(sc.US_WSREMS__Case_Record_Type__c+sc.US_WSREMS__Program_Configuration__r.Label,sc);
                }
            } 
            return statusConfigMap;  
                                                                    
        }
       
    Public static List<US_WSREMS__Program_Fields_Configuration__c> getProgramFields(Set<String>recordTypeNames, Set<Id> programIds, Set<String> requestorTypeName){
        List<US_WSREMS__Program_Fields_Configuration__c> programFieldsConfigList= new List<US_WSREMS__Program_Fields_Configuration__c>();
       List<US_WSREMS__Program_Fields_Configuration__c> programFieldsList = [SELECT Id,
                                                                            US_WSREMS__Target_Object_Field__c,
                                                                            US_WSREMS__Target_Object_Field_Label__c,
                                                                            US_WSREMS__Target_Object_Record_Type__c,
                                                                            US_WSREMS__REMS_Program__c,
                                                                            US_WSREMS__Target_Object__c,
                                                                            US_WSREMS__Section_Name__c,
                                                                            US_WSREMS__Validation_Label__c,US_WSREMS__Incomplete_Value__c,
                                                                  			US_WSREMS__Requestor_Type__c,US_WSREMS__ReferenceObject__c
                                                                            FROM US_WSREMS__Program_Fields_Configuration__c 
                                                                            WHERE US_WSREMS__Target_Object_Record_Type__c IN : recordTypeNames
                                                                            AND US_WSREMS__Target_Object__c = :REMSAppLiterals.CASE_OBJECT
                                                                            AND US_WSREMS__REMS_Program__c IN : programIds 
                                                                            AND US_WSREMS__Requestor_Type__c in :requestorTypeName
                                                                            AND (US_WSREMS__Soft_Required__c = true OR(US_WSREMS__Incomplete_Value__c!= null AND US_WSREMS__Incomplete_Value__c !=''))];
        if(programFieldsList.isEmpty()){
            return programFieldsConfigList;
       } 
       for(US_WSREMS__Program_Fields_Configuration__c pfc : programFieldsList){
               programFieldsConfigList.add(pfc);
           
        }                                                              
        return programFieldsConfigList; 
    }

    /*            New Methods */
    public static void updateStackHolderAccountStatus(List<Case> newCaseList,Map<Id,Case> oldCaseMap){
            Set<String> recordTypeName = new Set<String>();
            Set<Id> programId = new Set<Id>();
            Set<String> programName = new Set<String>();
            Set<String> caseStatus = new Set<String>();
            Set<String> caseOutcome = new Set<String>();
                
                Map<Id,String> recordTypeIdDevNameMap = REMSUtils.retrieveRecTypeIdDeveloperName(REMSAppLiterals.CASE_OBJECT);
             
        for(Case cs : newCaseList){
            if((oldCaseMap == null || (oldCaseMap != null && (cs.Status != oldCaseMap.get(cs.Id).Status 
            || cs.US_WSREMS__Participant__c != oldCaseMap.get(cs.Id).US_WSREMS__Participant__c || cs.US_WSREMS__REMS_Service_Summary__c != oldCaseMap.get(cs.Id).US_WSREMS__REMS_Service_Summary__c)))){
           String recordTypeDeveloperName = recordTypeIdDevNameMap.get(cs.RecordTypeId);
                recordTypeName.add(recordTypeDeveloperName);
                programId.add(cs.US_WSREMS__REMS_Program__c);
                programName.add(cs.US_WSREMS__Program_Picklist__c);
                caseStatus.add(cs.Status);
                caseOutcome.add(cs.US_WSREMS__Outcome__c);  
            }
        }
        
        if(!caseStatus.isEmpty()){
            caseAutomationController.updateAccountStatus(newCaseList,programId,recordTypeName,caseStatus,caseOutcome);
        }
    
    }

    /*public static void updateStackHolderAccountStatus(List<Case> newCaseList,Map<Id,Case> oldCaseMap){
        Map<String,String> caseRecordTypeMap = new Map<String,String>();
        Set<String> serviceConfigRecordType = new Set<String>();
        List<Account> accountListToUpdate = new List<Account>();
        for(Case c : newCaseList){
            if((c.Status == REMSAppLiterals.DRAFT || c.Status == REMSAppLiterals.COMPLETE) && (oldCaseMap == null || (oldCaseMap != null && (c.Status != oldCaseMap.get(c.Id).Status || c.Participant__c != oldCaseMap.get(c.Id).Participant__c)))){
                caseRecordTypeMap.put(c.Record_Type_Name__c,c.Program_Name__c);
            }
        }
         if(caseRecordTypeMap == null){
             return;
         }
         
         List<REMS_Service_Configuration__mdt> serviceConfigList = [SELECT Id, 
                                                                           Case_Record_Type__c,
                                                                           Program_Configuration__c,
                                                                           Program_Configuration__r.Label 
                                                                           FROM REMS_Service_Configuration__mdt
                                                                           WHERE Case_Record_Type__c IN : caseRecordTypeMap.KeySet() and Service_Type__c!=:REMSAPPLITERALS.DISENROLLMENT_SERVICE] ;
          if(serviceConfigList.isEmpty()){
              return;
          } 
          
          for(REMS_Service_Configuration__mdt rs : serviceConfigList){
              if(caseRecordTypeMap.containsKey(rs.Case_Record_Type__c) && caseRecordTypeMap.get(rs.Case_Record_Type__c) == rs.Program_Configuration__r.Label){
                  serviceConfigRecordType.add(rs.Case_Record_Type__c+rs.Program_Configuration__r.Label);
              }
          } 
          
          if(serviceConfigRecordType.isEmpty()){
              return;
          }  
          Set<String> allAccountId = new Set<String>();
            for(Case cs : newCaseList){
                if(cs.Participant__c != null && (cs.Status == REMSAppLiterals.DRAFT || cs.Status == REMSAppLiterals.COMPLETE) && serviceConfigRecordType.contains(cs.Record_Type_Name__c+cs.Program_Name__c)){
                    allAccountId.add(cs.Participant__c);
                }
            }
            Map<String,Account> accountMap = new Map<String,Account>();
            for(Account records : [SELECT Id, Status__c ,Prescriber_Signature__c,Prescriber_Signature_Date__c FROM ACCOUNT WHERE ID IN : allAccountId] ) {
                accountMap.put(records.Id,records);
            }
            Map<String,String> accountAROutPatientMap = new Map<String,String>();
            for(Affiliation__c record :[SELECT Id,Pharmacy__c ,Pharmacy_User__c FROM Affiliation__c WHERE Pharmacy__c IN : allAccountId AND Pharmacy_User__r.Channel__c =: REMSAppLiterals.CASE_CHANNEL_PORTAL and Pharmacy_User__c != null ] ) {
                accountAROutPatientMap.put(record.Pharmacy__c, record.Pharmacy_User__c);
            }
          
          for(Case cs : newCaseList){
            if(cs.Participant__c != null && (cs.Status == REMSAppLiterals.DRAFT || cs.Status == REMSAppLiterals.COMPLETE) && serviceConfigRecordType.contains(cs.Record_Type_Name__c+cs.Program_Name__c)){
                Account acc = new Account(Id = cs.Participant__c);
                if(cs.Status == REMSAppLiterals.DRAFT && (REMSAPPLiterals.CASE_ENROLL_REENROLL_RECTYPE_SET.contains(cs.Record_Type_Name__c ))){
                    if(cs.Record_Type_Name__c.contains('Reenrollment')){
                        acc.Sub_Status__c = '';
                    } 
                    acc.Status__c = REMSAppLiterals.PENDING_STATUS;
                }else if(cs.Status == REMSAppLiterals.COMPLETE && (REMSAPPLiterals.CASE_ENROLL_REENROLL_RECTYPE_SET.contains(cs.Record_Type_Name__c ))){
                    acc.Status__c = REMSAppLiterals.CERTIFIED;
                    if( accountAROutPatientMap.containsKey(cs.Participant__c)) {
                        accountListToUpdate.add(updateAccountStatusAndDetails(accountAROutPatientMap.get(cs.Participant__c)));
                    }
                     acc.Prescriber_Signature__c = cs.Prescriber_Signature__c!=null ? cs.Prescriber_Signature__c : accountMap.get(cs.Participant__c).Prescriber_Signature__c ;
                     acc.Prescriber_Signature__c = cs.Signature__c!=null ? cs.Signature__c : accountMap.get(cs.Participant__c).Prescriber_Signature__c ;
                     acc.Prescriber_Signature_Date__c = cs.Signature_Date_Pharmacist__c != null ? cs.Signature_Date_Pharmacist__c : accountMap.get(cs.Participant__c).Prescriber_Signature_Date__c;
                }
                accountListToUpdate.add(acc);
               
            }
         }
         
         if(!accountListToUpdate.isEmpty()){
             try{
                 update accountListToUpdate;
             }catch(exception e){
                 system.debug('--Error---'+e.getMessage());
             }
         }
                                                                       
            
    }*/
    Public static void updateAccountStatus(List<Case> newCaseList,Map<Id,Case> oldCaseMap){
          
      Map<string,string> caseRecordTypeMap = new Map<String,String>();
      List<Case> prescriberReenrollmentCases = new List<Case>();
      Map<String,String> filedMap = new Map<String,String>();
       Set<String> programName = new Set<String>();
       string referenceField= '';
       for(case cs : newCaseList){
           caseRecordTypeMap.put(cs.US_WSREMS__Record_Type_Name__c,cs.US_WSREMS__Program_Name__c);
           if(cs.US_WSREMS__Record_Type_Name__c == 'Prescriber_Reenrollment' && (cs.US_WSREMS__Annual_Recertification_Reenrollment__c == 'Yes' || cs.US_WSREMS__Annual_Recertification_Reenrollment__c == 'No') 
              && (oldCaseMap == null  || (oldCaseMap != null && (cs.US_WSREMS__Annual_Recertification_Reenrollment__c != oldCaseMap.get(cs.Id).US_WSREMS__Annual_Recertification_Reenrollment__c 
                                                                 || cs.US_WSREMS__REMS_Service_Summary__c!= oldCaseMap.get(cs.Id).US_WSREMS__REMS_Service_Summary__c
                                                                 || cs.Status!=oldCaseMap.get(cs.Id).Status)) )){
               prescriberReenrollmentCases.add(cs);
               programName.add(cs.US_WSREMS__Program_Name__c);
               referenceField='Annual_Recertification_Reenrollment__c';
           }
           if(cs.US_WSREMS__Record_Type_Name__c == REMSAppLiterals.CASE_RECTYPE_PRESCRIBER_ENROLLMENT && cs.Status == 'Complete' && cs.US_WSREMS__REMS_Service_Summary__c != null && (oldCaseMap == null || (oldCaseMap != null && (cs.Status != oldCaseMap.get(cs.Id).Status || cs.US_WSREMS__REMS_Service_Summary__c != oldCaseMap.get(cs.Id).US_WSREMS__REMS_Service_Summary__c)))){
               prescriberReenrollmentCases.add(cs);
               programName.add(cs.US_WSREMS__Program_Name__c);
               referenceField='Status';
           }
           if(cs.US_WSREMS__Record_Type_Name__c == REMSAppLiterals.CASE_RECTYPE_HCS_ENROLLMENT && cs.Status == REMSAppLiterals.COMPLETE && cs.US_WSREMS__REMS_Service_Summary__c != null && (oldCaseMap == null || (oldCaseMap != null && (cs.Status != oldCaseMap.get(cs.Id).Status || cs.US_WSREMS__REMS_Service_Summary__c != oldCaseMap.get(cs.Id).US_WSREMS__REMS_Service_Summary__c)))){
            prescriberReenrollmentCases.add(cs);
            programName.add(cs.US_WSREMS__Program_Name__c);
            referenceField='Outcome__c';
        }

        if((cs.US_WSREMS__Record_Type_Name__c ==REMSAppLiterals.CASE_RECORDTYPE_HCS_REENROLLMENT || cs.US_WSREMS__Record_Type_Name__c ==REMSAppLiterals.CASE_RECORDTYPE_INPATIENT_PHARMACY_ENROLLMENT 
                   || cs.US_WSREMS__Record_Type_Name__c ==REMSAppLiterals.CASE_RECORDTYPE_OUTPATIENT_PHARMACY_REENROLLMENT || cs.US_WSREMS__Record_Type_Name__c == REMSAppLiterals.CASE_RECORDTYPE_OUTPATIENT_PHARMACY_ENROLLMENT || cs.US_WSREMS__Record_Type_Name__c == REMSAppLiterals.CASE_RECORDTYPE_DISTRIBUTOR_ENROLLMENT|| cs.US_WSREMS__Record_Type_Name__c ==REMSAppLiterals.CASE_RECORDTYPE_INPATIENT_PHARMACY_REENROLLMENT) 
                   && cs.Status == REMSAppLiterals.CASE_STATUS_COMPLETED && cs.US_WSREMS__REMS_Service_Summary__c != null && (oldCaseMap == null || (oldCaseMap != null && (cs.Status != oldCaseMap.get(cs.Id).Status || cs.US_WSREMS__REMS_Service_Summary__c != oldCaseMap.get(cs.Id).US_WSREMS__REMS_Service_Summary__c)))){
            prescriberReenrollmentCases.add(cs);                  
          programName.add(cs.US_WSREMS__Program_Name__c);
          referenceField= REMSAppLiterals.CASE_REFERENCEField;
            }
       }
       
       if(!prescriberReenrollmentCases.isEmpty()){
           REMSAutomationCommunicationUtility.sendNotification(prescriberReenrollmentCases,programName,referenceField);
       }

  }

    //REMSBO-1076 Method to update Case owner
    public static void updateRecordOwner(List<Case> newCaseList){
        for (Case cs: newCaseList) {
        if(cs.US_WSREMS__REMS_Program__c != null){
            US_WSREMS__Default_Record_Owner__c drc = US_WSREMS__Default_Record_Owner__c.getValues(cs.US_WSREMS__REMS_Program__c);
            if(drc!=null){
            if(cs.OwnerId  != drc.US_WSREMS__Record_Owner_Id__c){
                cs.US_WSREMS__Record_Owner__c = cs.OwnerId;
                cs.OwnerId = drc.US_WSREMS__Record_Owner_Id__c;
            }
            }
        }
        }   
    } 
}