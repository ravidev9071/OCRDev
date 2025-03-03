/**
* @File Name          : ORCFormCtrl.cls
* @Description        : This controller help to get Dynamic PageLayout and Create Account and Services and Case record .
* @TestClass          : 
* @Author             : Citiustech
* @Modification Log   :
* Ver       Date               Developer                       Modification
* 1.0    15-0-205              Phool Chandra          Initial Implementation.
**/
public with sharing class OCRFormCtrl {
    public static Map<String,US_WSREMS__ObjectFieldMapping__c> progObjConfigMap = new Map<String,US_WSREMS__ObjectFieldMapping__c>();
    public static Map<String,Map<String, List<REMSUtils.WrapperClass>>> serviceobjDetFldConfigMap = new Map<String,Map<String, List<REMSUtils.WrapperClass>>>();
    public static final String NAMESPACE_STRING = REMSAppLiterals.NAMESPACE_STRING;
    
    
    /********************************************************************************************************************************************************
* Method Name          : getStageHeaderDetails
* @Description         : Retrieving stage Header records.
* @CreatedDate         : 17th Feb 2025
* @Author              : Chandra 
**********************************************************************************************************************************************************/
    @AuraEnabled 
    public static List<StagingHeader__c> getStageHeaderDetails(Id documentCheckLsId){
        List<StagingHeader__c> stgHeadr = [SELECT Id,RequestorType__c,ServiceType__c FROM StagingHeader__c WHERE DocDetail__c=:documentCheckLsId limit 1];
        return stgHeadr;
    }
    
    
    /********************************************************************************************************************************************************
* Method Name          : getStakeholderrecord
* @Description         : Retrieves account data
* @CreatedDate         : 18th Feb 2025
* @Author              : Chandra
**********************************************************************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static Account getStakeholderrecord(Id accountId) {
        List<Account> accountList = new List<Account>();
        try{
            accountList = [SELECT US_WSREMS__REMS_Program__c,US_WSREMS__Program_Picklist__c,US_WSREMS__Recordtype_Label__c FROM Account WHERE Id=:accountId];
            if(!accountList.isEmpty()){
                return accountList[0];
            }
        }
        catch (Exception ex) {
            throw new AuraHandledException(
                'An unexpected error occurred: ' + ex.getMessage()
            );
        }
        return null;
    }
    
    
    /********************************************************************************************************************************************************
*  Method Name: createAccount
*  Parameters: String caseRecordId, String serviceReqType, String servicerecordType, String TarObject, String TarRecordType, string programName
*  Description: This method creates an account based on the provided parameters and updates the associated case record.
*  Created Date: 15 Nov, 2023
*  Developers: Sukanya 
**********************************************************************************************************************************************************/
    @AuraEnabled
    public static String createAccount(String caseRecordId, String serviceReqType, String servicerecordType, String TarObject, String TarRecordType, String programName) {
        try {
            List<Account> actList = getAccounts(caseRecordId, serviceReqType, servicerecordType, TarObject, TarRecordType, programName);
            Database.SaveResult[] srList = Database.insert(actList, false);
            string accountId;
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    accountId = sr.getId();
                }else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) { 
                        System.debug(err.getMessage());            
                    }
                } 
            }
            updateCase(caseRecordId,accountId);
            return accountId;
        } catch (Exception ex) {
            System.debug(ex.getMessage()+':::'+ex.getStackTraceString());
            throw new AuraHandledException('An unexpected error occurred: ' + ex.getMessage());
        }
    }
    
    private static List<Account> getAccounts(String caseRecordId, String serviceReqType, String servicerecordType, String TarObject, String TarRecordType, String programName){
        List<Account> actList = new List<Account>();
        String srecodtypeName = [SELECT Name, DeveloperName FROM RecordType WHERE Id = :TarRecordType LIMIT 1].DeveloperName;
        
        List<FieldConfig__c> fieldMappingList = [SELECT SourceObject__c, SourceField__c, SourceRecordType__c,TargetObjField__c,TargetObj__c, TargetObjRecordType__c FROM FieldConfig__c
                                                 WHERE  SourceObject__c = : TarObject AND REMSProgram__r.Name=:programName AND SourceRecordType__c =: srecodtypeName AND TargetObjRecordType__c!=null AND TargetObjField__c!=null AND SourceField__c!=null AND  IsActive__c = TRUE];
        
        Map<String, String> TargetSourceMap = new Map<String, String>();
        Set<String> dynamicFieldSet = new Set<String>();
        
        for (FieldConfig__c mdt : fieldMappingList) {
            TargetSourceMap.put(mdt.TargetObjField__c, mdt.SourceField__c);
            dynamicFieldSet.add(mdt.SourceField__c);
        }
        
        List<SObject> sObjectRecList = new List<SObject>();
        Map<String, String> TargetFieldToValueMap = new Map<String, String>();
        
        String dynamicFieldStr = String.join(new List<String>(dynamicFieldSet), ',');
        String dynamicQueryStr = 'SELECT ' + dynamicFieldStr + ' FROM Case WHERE Id = :caseRecordId';
        
        sObjectRecList = Database.query(dynamicQueryStr);
        
        for (String Field : TargetSourceMap.KeySet()) {
            String Value = TargetSourceMap.get(Field);
            String FieldValue = String.valueOf(sObjectRecList[0].get(Value));
            TargetFieldToValueMap.put(Field, String.isBlank(FieldValue) ? ' ' : FieldValue);
        }
        system.debug('++++fieldmappingLIst'+fieldMappingList[0]);
        Account acc = new Account();
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SobjectType ='Account' AND DeveloperName = : fieldMappingList[0].TargetObjRecordType__c LIMIT 1].Id;
        acc.RecordTypeId = recordTypeId;
        for (String fld : TargetFieldToValueMap.keySet()) {
            if (Schema.getGlobalDescribe().get(acc.getSObjectType().getDescribe().getName()).getDescribe().fields.getMap().get(fld).getDescribe().getType() == Schema.DisplayType.Date) {
                try {
                    if(TargetFieldToValueMap.get(fld) != null){
                        Date dateValue = Date.valueOf(TargetFieldToValueMap.get(fld));
                        acc.put(fld, dateValue);
                    }
                } catch (Exception e) {
                    acc.put(fld, null);
                }
            }else if (Schema.getGlobalDescribe().get(acc.getSObjectType().getDescribe().getName()).getDescribe().fields.getMap().get(fld).getDescribe().getType() == Schema.DisplayType.Boolean) {
                try {
                    if(TargetFieldToValueMap.get(fld) != null){
                        Boolean booleanValue = Boolean.valueOf(TargetFieldToValueMap.get(fld));
                        acc.put(fld, booleanValue);
                    }
                } catch (Exception e) {
                    acc.put(fld, null);
                }
            } else {
                if(TargetFieldToValueMap.get(fld)!=null){
                    acc.put(fld, TargetFieldToValueMap.get(fld));
                }
            }
        }
        System.debug('acc:::: '+acc);
        actList.add(acc);
        return actList;
    }
    
    /********************************************************************************************************************************************************
* Method Name: updateCase
* Parameters: String caseRecordId, Id accountId, Id remsSummaryId
* Description: This private method updates a Case record with the specified participant and REMS service summary IDs.
*              It is used in the process of creating an Account and associating it with a Case.
* Created Date: [Insert Date]
* Developers: [Insert Developer Names]
**********************************************************************************************************************************************************/
    @AuraEnabled
    public static void updateCase(String caseRecordId, Id accountId) {
        try {
            
            
            List<US_WSREMS__REMS_Service_Summary__c> remsSummaryList = [SELECT Id,US_WSREMS__Requestor_Type__c,US_WSREMS__REMSProgram__c,US_WSREMS__REMSProgram__r.Name, RecordtypeId, RecordType.DeveloperName,US_WSREMS__Participant__c  FROM US_WSREMS__REMS_Service_Summary__c WHERE US_WSREMS__Participant__c  = :accountId LIMIT 1];
          
            if(!remsSummaryList.isEmpty()){
                Account accObj = [Select Id,US_WSREMS__REMS_ID__c from Account where Id=:accountId limit 1];
                Case cs = new Case(Id = caseRecordId);
                 cs.US_WSREMS__Participant__c = accountId;
                cs.US_WSREMS__REMS_Service_Summary__c = remsSummaryList[0].Id;
                if(remsSummaryList[0].RecordType.DeveloperName !='Enrollment'){
                    cs.Status = 'Complete';
                    cs.US_WSREMS__Outcome__c = 'Complete';
                }
                cs.US_WSREMS__REMS_ID__c = accObj.US_WSREMS__REMS_ID__c;
                update cs;
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage()+':::'+ex.getStackTraceString());
            throw new AuraHandledException('Error updating Case: ' + ex.getMessage());
        }
    }
    
    /********************************************************************************************************************************************************
* Method Name          : getServiceCreation
* @Description         : Retrieves the Service creation Records.
* @CreatedDate         : 15th Feb 2025
* @Author              : Chandra
**********************************************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Map<String, List<REMSUtils.WrapperClass>>> getServiceCreation(US_WSREMS__REMS_Service_Configuration__mdt serviceConfigObj,String documentCheckListId) {
        System.debug('serviceConfigObj:::'+serviceConfigObj);
        Map<String, List<REMSUtils.WrapperClass>> serviceFieldMap = new Map<String, List<REMSUtils.WrapperClass>>();
        Map<String, String> serviceMap = new Map<String, String>();
        try {
            serviceFieldMap = REMSUtils.getData(
                documentCheckListId,
                serviceConfigObj.US_WSREMS__Object__c,
                serviceConfigObj.US_WSREMS__Case_Record_Type__c,
                serviceConfigObj.US_WSREMS__Program_Configuration__r.MasterLabel,
                serviceConfigObj.US_WSREMS__Participant_Type__c
            );
            
            getServiceFieldObjSection(serviceFieldMap,null,null);
        } catch (Exception ex) {
            throw new AuraHandledException(
                'An unexpected error occurred: ' + ex.getMessage()
            );
        }
        
        return serviceobjDetFldConfigMap;
    }
    
    /********************************************************************************************************************************************************
* Method Name            : getServiceConfigRecords
* @Description           : Retrieves the NPI Status change for a specific participant type, service type, and program name.
* @param participantType : The type of participant for filtering records.
* @param serviceType     : The type of service for filtering records.
* @param programName     : The name of the program for filtering records.
* @return                : An instance of REMS_Service_Configuration__mdt containing the retrieved information.
* @CreatedDate           : 9th Feb 2025
* @Author                : Chandra
**********************************************************************************************************************************************************/
    
    @AuraEnabled
    public static US_WSREMS__REMS_Service_Configuration__mdt getServiceConfigRecords(String participantType,String serviceType,String programName) {
        
        return  [SELECT Id, US_WSREMS__Object__c,US_WSREMS__Eligible_Status__c,US_WSREMS__Case_Status__c, US_WSREMS__Service_Type__c, US_WSREMS__Case_Record_Type__c, US_WSREMS__Program_Configuration__c, US_WSREMS__Program_Configuration__r.MasterLabel, 
                 US_WSREMS__Participant_Type__c,US_WSREMS__Title__c,US_WSREMS__Participant_Field__c,US_WSREMS__Account_Record_Type__c,US_WSREMS__Service_Record_Type__c, US_WSREMS__Validate_AR_Info__c,
                 US_WSREMS__Validate_NPI__c,US_WSREMS__Upload_Attachments__c, US_WSREMS__Sub_Participant_Type__c,US_WSREMS__Requestor_Type__c,US_WSREMS__Override_Requestor_Type__c,US_WSREMS__SwitchtoNewCaseCmp__c,
                 US_WSREMS__Validate_Dupcheck__c,US_WSREMS__Warning_Message__c, US_WSREMS__Allow_Duplicate_NPI__c
                 FROM US_WSREMS__REMS_Service_Configuration__mdt 
                 WHERE US_WSREMS__Participant_Type__c = :participantType
                 AND US_WSREMS__Service_Type__c = :serviceType
                 AND  US_WSREMS__Program_Configuration__r.MasterLabel =: programName LIMIT 1];
    }
    
    
    /********************************************************************************************************************************************************
* Method Name          : validateNpiStatus
* @Description         : Retrieves the NPI Status change.
* @CreatedDate         : 15th Feb 2025
* @Author              : Chandra
**********************************************************************************************************************************************************/
    @AuraEnabled
    public static Boolean validateNpiStatus(String npiValue) {
        Boolean isValidNpi = false;
        List<HealthcareProviderNpi> healthCareNpi = [
            SELECT Id, Npi
            FROM HealthcareProviderNpi
            WHERE Npi = :npiValue
            LIMIT 1
        ];
        if (!healthCareNpi?.isEmpty()) {
            if (healthCareNpi[0].Npi == npiValue) {
                isValidNpi = true;
            }
        }
        return isValidNpi;
    }
    
    /********************************************************************************************************************************************************
* Method Name          : fetchRecordTypeId
* @Description         : Retrieves the RecordTypeId.
* @CreatedDate         : 15th Feb 2025
* @Author              : Chandra
**********************************************************************************************************************************************************/
    @AuraEnabled
    public static String fetchRecordTypeId(
        String recordTypeName,
        String objectName
    ) {
        return REMSUtils.retrieveRecTypeDeveloperNameId(objectName).get(recordTypeName);
    }
    
    /********************************************************************************************************************************************************
* Method Name          : getCaseFieldAndValueMap
* @Description         : Retrieves the Case Fields with its values.
* @CreatedDate         : 15th Feb 2025
* @Author              : Chandra
**********************************************************************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> getCaseFieldAndValueMap(String accountId,String requestorType,String targetObject,String sourceObject,String sourceRecordType,String parentFieldType,String programName,Boolean overrideReqType) {
        List<Account> actList = new List<Account>();
        List<SObject> sObjectRecList = new List<SObject>();
        Map<String, String> TargetFieldToValueMap = new Map<String, String>();
        Map<String, String> TargetSourceMap = new Map<String, String>();
        Set<String> dynamicFieldSet = new Set<String>();
        if(overrideReqType == true && !String.isBlank(accountId)){
            actList = [SELECT Id,Recordtype.Name FROM Account WHERE Id=:accountId];
            requestorType = actList[0].Recordtype.Name;
        }
        List<US_WSREMS__Field_Mapping_Config__mdt> fieldMappingList = [SELECT US_WSREMS__Source_Object__c,US_WSREMS__Source_Field__c,US_WSREMS__Target_Field__c,US_WSREMS__Target_Object__c,US_WSREMS__Target_RecordType_Name__c,US_WSREMS__Source_RecordType_Name__c,US_WSREMS__Parent_Field__c,US_WSREMS__IsActive__c,US_WSREMS__Order__c
                                                                       FROM US_WSREMS__Field_Mapping_Config__mdt WHERE US_WSREMS__Source_Object__c = :sourceObject AND US_WSREMS__Program__r.MasterLabel = :programName AND US_WSREMS__Target_Object__c = :targetObject AND US_WSREMS__Request_Type__c = :requestorType
                                                                       AND US_WSREMS__Source_RecordType_Name__c = :sourceRecordType AND US_WSREMS__Parent_Field__c = :parentFieldType AND US_WSREMS__IsActive__c =: true ORDER By US_WSREMS__Order__c];
        for (US_WSREMS__Field_Mapping_Config__mdt mdt : fieldMappingList) {
            TargetSourceMap.put(mdt.US_WSREMS__Source_Field__c, mdt.US_WSREMS__Target_Field__c);
            dynamicFieldSet.add(mdt.US_WSREMS__Target_Field__c);
        }
        System.debug(fieldMappingList);
        String dynamicFieldStr = String.join( new List<String>(dynamicFieldSet),',' );
        if(accountId!=null && accountId!=''){
            String dynamicQueryStr = 'SELECT ' + dynamicFieldStr + ' FROM Account WHERE Id = :accountId';
            System.debug(dynamicQueryStr);
            sObjectRecList = Database.query(dynamicQueryStr);
            for (String Field : TargetSourceMap.KeySet()) {
                
                String FieldValue = String.valueOf(
                    sObjectRecList[0].get(TargetSourceMap.get(Field))
                );
                TargetFieldToValueMap.put(Field ,  String.isBlank(FieldValue) ? '': FieldValue);
            }   
        }else{
            for (String Field : TargetSourceMap.KeySet()) {
                TargetFieldToValueMap.put(Field ,  '');
            }
        }
        return TargetFieldToValueMap;
    }
    
    
    /********************************************************************************************************************************************************
* Method Name          : createEnrollmentService
* @Description         : This method creates the Enrollment Service.
* @CreatedDate         : 15th Feb 2025
* @Author              : Chandra
**********************************************************************************************************************************************************/
    @AuraEnabled
    public static String createEnrollmentService(
        String programId,
        String accountId,
        String participantType,
        String ServiceRecordTypeName
    ) {
        try{
            US_WSREMS__REMS_Service_Summary__c serviceRecord = new US_WSREMS__REMS_Service_Summary__c();
            serviceRecord.US_WSREMS__REMSProgram__c = programId;
            serviceRecord.US_WSREMS__Participant__c = accountId;
            serviceRecord.US_WSREMS__Requestor_Type__c = participantType;
            serviceRecord.RecordTypeId = fetchRecordTypeId(
                ServiceRecordTypeName,
                'REMS_Service_Summary__c'
            );
            System.debug(LoggingLevel.Debug,'Service Record:: =>'+serviceRecord);
            insert serviceRecord;
            return serviceRecord.Id ;
        } catch (Exception ex) {
            System.debug('Line No error: '+ex.getLineNumber());
            throw new AuraHandledException(
                'An unexpected error occurred: ' + ex.getMessage()
            );
        }
    }
    
    /********************************************************************************************************************************************************
MethodName : getNameSpace
Description: This method will to get Namespace
CreatedDate: 10 Oct, 2023
***********************************************************************************************************************************************************/ 
    @AuraEnabled    
    public static String getNameSpace(){
        String NameSpace_Str = OCRREMSAppLiterals.NAMESPACE_STRING;
        return NameSpace_Str;
    } 
    
    
    @AuraEnabled(cacheable=true)
    public static List<String> getPermissionSets() {
        String currentUserId = UserInfo.getUserId();
        List<String> permissionSetNames = new List<String>();
        for (PermissionSetAssignment assignment : [SELECT PermissionSet.Name
                                                   FROM PermissionSetAssignment
                                                   WHERE AssigneeId = :currentUserId]) {
                                                       permissionSetNames.add(assignment.PermissionSet.Name);
                                                   }
        return permissionSetNames;
    }
    
    /********************************************************************************************************************************************************
MethodName : checkNPIDuplicate
Description: This method retrieves the checkNPIDuplicate.
CreatedDate: 18 Feb 2025

***********************************************************************************************************************************************************/
    @AuraEnabled
    public static Boolean checkNPIDuplicate(String NPIValue, String recordType, String program){
        Boolean checkNPIDuplicate = false;
        try {
            if(NPIValue.length() ==10){
                List<Account> accounts = new List<Account>([SELECT Id,Name,US_WSREMS__National_Provider_Identifier__c FROM Account WHERE US_WSREMS__National_Provider_Identifier__c=:NPIValue AND US_WSREMS__Recordtype_Label__c = :recordType AND US_WSREMS__REMS_Program__c = :program LIMIT 1]);
                if(accounts.size() > 0) return checkNPIDuplicate=true;
            }
            
        } catch (Exception e) {
            checkNPIDuplicate=false;
            throw new AuraHandledException(e.getMessage());
        }
        return checkNPIDuplicate;
    }
    
    
    
    
    
    /**
     * Method: getReadOnlyFields
     * 
     * This method retrieves all read-only fields for a specified Salesforce object and outputs them to the debug log.
     * It uses the Schema class to retrieve field-level metadata and checks if a field is read-only.
     * 
     * @param objectName: The API name of the Salesforce object (e.g., 'Account').
     */
     @AuraEnabled
    public static List<String> getReadOnlyFields(String objectName) {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
        List<String> readOnlyFields = new List<String>();
        for (String fieldName : fieldsMap.keySet()) {
            // Get the metadata for each field
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
            
            // Check if the field is not updateable (i.e., read-only)
            if (!fieldDescribe.isUpdateable()) {
                
                readOnlyFields.add(fieldName);
            }
        }
         return readOnlyFields;
     }
    
    /********************************************************************************************************************************************************
MethodName : getAssessmentResponse
Description: This method retrieves Assessment Submission Result based on Account Id.
CreatedDate: 18 Feb 2024
@Author    : Sukanya

Reivew Needed: Yes
**************************************************************************************************************/
 
    
    
    @AuraEnabled(cacheable=true)
    public static String getAssessmentResponse(String accountId) {
        try{
            List<Account> actObjList =[SELECT Id FROM Account WHERE Id=:accountId LIMIT 1];
            if(!actObjList.isEmpty()){
                List<Case> caseObjList =[SELECT Id, US_WSREMS__First_Name__c, US_WSREMS__Last_Name__c,US_WSREMS__REMS_Program__c,US_WSREMS__Service_Requestor_Type__c FROM Case WHERE US_WSREMS__Participant__c =:actObjList[0].Id AND Recordtype.DeveloperName=:OCRREMSAPPLITERALS.CASE_RECORDTYPE_KNOWLEDGE_ASSESSMENT ORDER BY CreatedDate DESC LIMIT 1];
                
                if(caseObjList.isEmpty()){
                    return null;
                }
                
                List<US_WSREMS__Assessment__c> assessmentList= [SELECT id, Name FROM US_WSREMS__Assessment__c 
                                                                WHERE US_WSREMS__REMS_Program__c= :caseObjList[0].US_WSREMS__REMS_Program__c 
                                                                AND US_WSREMS__Participant_Type__c = :caseObjList[0].US_WSREMS__Service_Requestor_Type__c LIMIT 1];
                if(assessmentList.isEmpty()){
                    return null;
                }
                
                List<US_WSREMS__Assessment_Submission__c> recentSubmissionList = new  List<US_WSREMS__Assessment_Submission__c>();
                recentSubmissionList= [SELECT Id,Name, US_WSREMS__Assessment_Result__c, US_WSREMS__Assessment__r.Name
                                       FROM US_WSREMS__Assessment_Submission__c
                                       WHERE US_WSREMS__Case__c=:caseObjList[0].Id 
                                       AND US_WSREMS__Assessment__c=:assessmentList[0].Id
                                       ORDER BY CreatedDate desc LIMIT 1];                 
                if(!recentSubmissionList.isEmpty()){
                    return recentSubmissionList[0].US_WSREMS__Assessment_Result__c;
                }else {
                    return 'Not Started';
                }   
            }else{
                return 'Not Started';
            }
            
        }
        catch (Exception ex) {
            throw new AuraHandledException('An unexpected error occurred: ' + ex.getMessage());   
        }                                
    }
    
    
    /****************************************************************************************************
MethodName : getPrimaryARDetails
Description: This method retrieves the primary Affiliation Record details based on the provided Account Id, Program Name, and Case Record Type Name.
CreatedDate: 22 Mar 2024
@Author    : Devara Moses
* **********************************************************************************************/
    @AuraEnabled
    public static Map<String,String> getPrimaryARDetails(Id accountId, String programName, String caseRecordtypeName,String participantType){
        US_WSREMS__Affiliation_Setup_Configuration__mdt affConfigObj;
        List<US_WSREMS__Affiliation_Setup_Configuration__mdt> affConfigList = new List<US_WSREMS__Affiliation_Setup_Configuration__mdt>();
        List<US_WSREMS__Affiliation__c> arAffList = new List<US_WSREMS__Affiliation__c>();
        Map<String,String> affiliationARMap = new Map<String,String>();
        affConfigList = REMSUtils.geteAffiliationSetupRecords(caseRecordtypeName, programName,participantType);
        if(!affConfigList.isEmpty()){ 
            affConfigObj = affConfigList[0];
        }
        if(Test.isRunningTest()) {
            affConfigObj = new US_WSREMS__Affiliation_Setup_Configuration__mdt(
                US_WSREMS__Affiliated_Target_Field__c = 'US_WSREMS__Pharmacy_User__c',
                US_WSREMS__Affiliation_Parent_Field__c = 'US_WSREMS__Pharmacy__c',
                US_WSREMS__Affiliation_Reference_Field__c = 'US_WSREMS__Participant__c',
                US_WSREMS__Affiliation_Source_Field__c = 'US_WSREMS__Prescriber_Delegate__c',
                US_WSREMS__Affiliation_Source_Record_Type__c = 'Prescriber_enrollment',
                US_WSREMS__Affiliation_Target_Record_Type__c = 'Prescriber_Delegate_Affiliation'
            );
        }
        if(affConfigObj!=null){
            String affQuery;
            affQuery  = 'Select Id, '+affConfigObj.US_WSREMS__Affiliated_Target_Field__c+' FROM US_WSREMS__Affiliation__c WHERE '+affConfigObj.US_WSREMS__Affiliation_Parent_Field__c+' = :accountId And US_WSREMS__User_Role__c=\''+OCRREMSAppLiterals.PRIMARY_AR_ROLE+'\' order by lastmodifieddate desc Limit 1';
            if(caseRecordtypeName == OCRREMSAppLiterals.REMS_RECTYPE_RECERTIFICATION){
                affQuery = 'Select Id, '+affConfigObj.US_WSREMS__Affiliated_Target_Field__c+' FROM US_WSREMS__Affiliation__c WHERE '+affConfigObj.US_WSREMS__Affiliation_Parent_Field__c+' = :accountId and US_WSREMS__isActive__c = true AND '+affConfigObj.US_WSREMS__Affiliated_Target_Field__c+'!= NULL order by lastmodifieddate desc Limit 1';
            }
            System.debug(affQuery);
            arAffList = Database.query(affQuery); 
            if(!arAffList.isEmpty()){
                affiliationARMap.put(affConfigObj.US_WSREMS__Affiliation_Source_Field__c, (String)arAffList[0].get(affConfigObj.US_WSREMS__Affiliated_Target_Field__c));
                return affiliationARMap;
            }
        }
        return null;
    }
    
    
    public static void getServiceFieldObjSection(Map<String, List<REMSUtils.WrapperClass>> serviceFieldMap, Map<String,String> childIdMap,Id recordId){  
        Map<String,REMSUtils.objectWrapper> objectDetMap = new Map<String,REMSUtils.objectWrapper>();
        Map<String,Map<String, List<REMSUtils.WrapperClass>>> serviceFieldObjMap = new Map<String,Map<String, List<REMSUtils.WrapperClass>>>();
        Map<String, List<REMSUtils.WrapperClass>>  addSectionServiceMap = new Map<String, List<REMSUtils.WrapperClass>> ();
        REMSUtils.objectWrapper addObjDet = new REMSUtils.objectWrapper();
        
        
        for(String secObj: serviceFieldMap.keySet()){
            if(secObj.contains('#')){
                String sectionName = secObj.split('#')[0];
                String objectName = secObj.split('#')[1];
                String recordTypeName = secObj.split('#')[2];
                String additionalSec = secObj.split('#')[3];
                if(serviceFieldObjMap.containsKey(objectName+recordTypeName) && additionalSec == 'False'){
                    serviceFieldObjMap.get(objectName+recordTypeName).put(sectionName,serviceFieldMap.get(secObj));
                }else{
                    Map<String, List<REMSUtils.WrapperClass>>  sectionServiceMap = new Map<String, List<REMSUtils.WrapperClass>> ();
                    if(additionalSec == 'False'){
                        sectionServiceMap.put(sectionName,serviceFieldMap.get(secObj));
                        serviceFieldObjMap.put(objectName+recordTypeName,sectionServiceMap);
                    }else{
                        addSectionServiceMap.put(sectionName,serviceFieldMap.get(secObj));
                    }
                    REMSUtils.objectWrapper objDet = new REMSUtils.objectWrapper();
                    objDet.objectName = objectName;
                    objDet.recordTypeId = REMSUtils.retrieveRecTypeDeveloperNameId(objectName).get(recordTypeName);
                    objDet.objRecordId = recordId!=null ? recordId : null;
                    objDet.additionalInfoSec = false;
                    if(objectName != 'Case'){
                        if(childIdMap!=null && childIdMap.containsKey(objectName+recordTypeName)){
                            objDet.objRecordId = childIdMap.get(objectName+recordTypeName);
                        }
                        if(progObjConfigMap.containsKey(objectName+recordTypeName+'Case')){
                            objDet.caseApi = progObjConfigMap.get(objectName+recordTypeName+'Case').US_WSREMS__ParentField__c;
                        }
                        if(progObjConfigMap.containsKey(objectName+recordTypeName+'Account')){
                            objDet.accountApi = progObjConfigMap.get(objectName+recordTypeName+'Account').US_WSREMS__ParentField__c;
                        }
                        if(progObjConfigMap.containsKey(objectName+recordTypeName+NAMESPACE_STRING+'US_WSREMS__REMS_Program__c')){
                            objDet.programApi = progObjConfigMap.get(objectName+recordTypeName+'US_WSREMS__REMS_Program__c').US_WSREMS__ParentField__c;
                        }
                        
                    }
                    
                    if(additionalSec == 'True'){
                        objDet.additionalInfoSec = true;
                        addObjDet = objDet;
                    }else{
                        objectDetMap.put(objectName+recordTypeName,objDet);
                    }
                    
                }
            }
        }
        
        for(String objRecString: objectDetMap.keySet()){
            if(objRecString!=null && serviceFieldObjMap.containsKey(objRecString)){            
                serviceobjDetFldConfigMap.put(JSON.serialize(objectDetMap.get(objRecString)),serviceFieldObjMap.get(objRecString));
            }
            
        }
        if(addObjDet.objectName!=null){
            serviceobjDetFldConfigMap.put(JSON.serialize(addObjDet),addSectionServiceMap);
        }
    }
    
    
    @AuraEnabled
    public static String updateSubstakeholder(Id caseId, Map<String,Object> parentFldSet, String programName, String requestorTypeName, String recordTypeName){
        List<US_WSREMS__Field_Mapping_Config__mdt> relatedfldMapList = new List<US_WSREMS__Field_Mapping_Config__mdt>();
        if(!parentFldSet.keyset().isEmpty() && caseId!=null){
            relatedfldMapList = getRealtedFieldMappingConfig(parentFldSet.keyset(), programName, requestorTypeName, recordTypeName);
            String caseQueryFields;
            String caseQuery;
            Case caseObj;
            Map<String,Account> parentChildFldsMap = new Map<String,Account>();
            if(!relatedfldMapList.isEmpty()){
                for(US_WSREMS__Field_Mapping_Config__mdt fldMapObj: relatedfldMapList){
                    if(fldMapObj.US_WSREMS__Source_Field__c!=null){
                        caseQueryFields = caseQueryFields!=null?caseQueryFields+','+fldMapObj.US_WSREMS__Source_Field__c:fldMapObj.US_WSREMS__Source_Field__c;
                    }
                }
                
                caseQuery = 'SELECT Id, '+caseQueryFields+' FROM Case WHERE Id=:caseId';
                caseObj = Database.Query(caseQuery);
                for(US_WSREMS__Field_Mapping_Config__mdt fldMapObj: relatedfldMapList){
                    if(fldMapObj.US_WSREMS__Source_Field__c!=null && fldMapObj.US_WSREMS__Target_Field__c!=null){
                        if(parentChildFldsMap.containsKey(fldMapObj.US_WSREMS__Parent_Field__c)){
                            parentChildFldsMap.get(fldMapObj.US_WSREMS__Parent_Field__c).put(fldMapObj.US_WSREMS__Target_Field__c,caseObj.get(fldMapObj.US_WSREMS__Source_Field__c));
                        }else{
                            Account subStakeObj = new Account();
                            subStakeObj.put('Id',parentFldSet.get(fldMapObj.US_WSREMS__Parent_Field__c));
                            subStakeObj.put(fldMapObj.US_WSREMS__Target_Field__c,caseObj.get(fldMapObj.US_WSREMS__Source_Field__c));
                            parentChildFldsMap.put(fldMapObj.US_WSREMS__Parent_Field__c,subStakeObj);
                        }
                    }
                }
            }
            if(!parentChildFldsMap.isEmpty()){        
                update parentChildFldsMap.values();
            }
        }
        return 'Success';
    }
    public static List<US_WSREMS__Field_Mapping_Config__mdt> getRealtedFieldMappingConfig(Set<String> parentFldSet, String programName, String requestorTypeName, String recordTypeName){
        List<US_WSREMS__Field_Mapping_Config__mdt> fldMapList = new List<US_WSREMS__Field_Mapping_Config__mdt>();
        fldMapList = [SELECT Id,US_WSREMS__Source_Field__c,US_WSREMS__Target_Field__c,US_WSREMS__Parent_Field__c from US_WSREMS__Field_Mapping_Config__mdt WHERE US_WSREMS__Parent_Field__c in :parentFldSet
                      AND US_WSREMS__Program__r.MasterLabel = :programName AND US_WSREMS__Request_Type__c=:requestorTypeName AND US_WSREMS__Source_RecordType_Name__c=:recordTypeName];
        return fldMapList;
    }
    
    /********************************************************************************************************************************************************
* Method Name          : getCasesForStakeholder
* @Description         : Retrieves the cases for given accountId
* @CreatedDate         : 25 Apr 2024
* @Author              : Amrit
**********************************************************************************************************************************************************/
    @AuraEnabled
    public static List<Case> getCasesForStakeholder(Id accountId, US_WSREMS__REMS_Service_Configuration__mdt serviceConfigObj) {
        List<Case> cases = new List<Case>([SELECT Id,CaseNumber FROM Case WHERE US_WSREMS__Participant__c = :accountId AND Status NOT IN('Complete','Cancelled') AND RecordType.DeveloperName = :serviceConfigObj.US_WSREMS__Case_Record_Type__c]);
        return cases;
    }
    
    /**
* Creates a new account based on the provided field values and mappings.
*
* @param fieldValues         A map containing field names and their corresponding values.
* @param tarObject           The target Salesforce object.
* @param sourceRecordType    The record type of the source object.
* @param servicerecordType   The record type of the service.
* @param sourceObject        The source Salesforce object.
* @param programName         The name of the program.
* @param parentFieldType     The parent field type.
* @return                    The ID of the newly created account.
*/
    @AuraEnabled
    public static String createARAccount(Map<String, String> fieldValues, String tarObject, String sourceRecordType, String servicerecordType, String sourceObject, String programName, String parentFieldType) {
        try {
            // Query field mappings based on input parameters
            List<US_WSREMS__Automation_Configuration__c> fieldMappingList = [SELECT US_WSREMS__Source_Object__c, US_WSREMS__Source_Field__c, US_WSREMS__Source_RecordType_Name__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c, US_WSREMS__Target_RecordType_Name__c FROM US_WSREMS__Automation_Configuration__c
                                                                             WHERE US_WSREMS__Target_Object__c = :tarObject AND US_WSREMS__Source_Object__c = :sourceObject AND US_WSREMS__REMS_Program__r.Name = :programName AND US_WSREMS__Source_RecordType_Name__c = :sourceRecordType AND US_WSREMS__Target_RecordType_Name__c != null AND US_WSREMS__Parent_Field__c = :parentFieldType];
            
            Map<String, String> TargetSourceMap = new Map<String, String>();
            Set<String> dynamicFieldSet = new Set<String>();
            
            // Populate TargetSourceMap and dynamicFieldSet
            for (US_WSREMS__Automation_Configuration__c mdt : fieldMappingList) {
                TargetSourceMap.put(mdt.US_WSREMS__Target_Field__c, mdt.US_WSREMS__Source_Field__c);
                dynamicFieldSet.add(mdt.US_WSREMS__Source_Field__c);
            }
            
            Map<String, String> TargetFieldToValueMap = new Map<String, String>();
            
            // Populate TargetFieldToValueMap with field values based on mappings and provided values
            for (String Field : TargetSourceMap.keySet()) {
                String Value = TargetSourceMap.get(Field);
                String FieldValue = String.valueOf(fieldValues.get(Value));
                TargetFieldToValueMap.put(Field, String.isBlank(FieldValue) ? ' ' : FieldValue);
            }
            
            Account acc = new Account();
            // Set record type ID based on the first field mapping's target record type name
            Id recordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = :REMSUtils.ACCOUNT_SOBJECT_TYPE AND DeveloperName = :fieldMappingList[0].US_WSREMS__Target_RecordType_Name__c LIMIT 1].Id;
            acc.RecordTypeId = recordTypeId;
            
            // Populate account fields with values from TargetFieldToValueMap
            for (String fld : TargetFieldToValueMap.keySet()) {
                if (Schema.getGlobalDescribe().get(acc.getSObjectType().getDescribe().getName()).getDescribe().fields.getMap().get(fld).getDescribe().getType() == Schema.DisplayType.Date) {
                    try {
                        if (TargetFieldToValueMap.get(fld) != null) {
                            Date dateValue = Date.valueOf(TargetFieldToValueMap.get(fld));
                            acc.put(fld, dateValue);
                        }
                    } catch (Exception e) {
                        acc.put(fld, null);
                    }
                } else if (Schema.getGlobalDescribe().get(acc.getSObjectType().getDescribe().getName()).getDescribe().fields.getMap().get(fld).getDescribe().getType() == Schema.DisplayType.Boolean) {
                    try {
                        if (TargetFieldToValueMap.get(fld) != null) {
                            Boolean booleanValue = Boolean.valueOf(TargetFieldToValueMap.get(fld));
                            acc.put(fld, booleanValue);
                        }
                    } catch (Exception e) {
                        acc.put(fld, null);
                    }
                } else {
                    acc.put(fld, TargetFieldToValueMap.get(fld));
                }
            }
            
            List<Account> actList = new List<Account>();
            actList.add(acc);
            
            // Insert the new account
            Database.SaveResult[] srList = Database.insert(actList, false);
            String accountId;
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    accountId = sr.getId();
                } else {
                    // Log errors if the operation failed
                    for (Database.Error err : sr.getErrors()) {
                        
                    }
                }
            }
            return accountId;
        } catch (Exception ex) {
            // Catch and handle any exceptions
            
            throw new AuraHandledException('An unexpected error occurred: ' + ex.getMessage());
        }
    }
    
    public static Map<String,List<REMSUtils.WrapperClass>>  getSectionFields(Map<String,List<REMSUtils.WrapperClass>> serviceFieldMap){
        Map<String,List<REMSUtils.WrapperClass>> secFldConfigMap = new Map<String,List<REMSUtils.WrapperClass>> ();
        for(String secObj: serviceFieldMap.keySet()){
            if(secObj.contains('#')){
                List<String> secObjDetList = new List<String>();
                String sectionName;
                String objectName;
                String recordTypeName;
                secObjDetList = secObj.split('#');
                if(!secObjDetList.isEmpty()){
                    sectionName = secObjDetList[0];
                    objectName = secObjDetList[1];
                    recordTypeName = secObjDetList[2];
                }
                if(secFldConfigMap.containsKey(sectionName)){
                    secFldConfigMap.get(sectionName).addall(serviceFieldMap.get(secObj));
                }else{
                    secFldConfigMap.put(sectionName,serviceFieldMap.get(secObj));
                }
            }
        }
        return secFldConfigMap;
    }
    /********************************************************************************************************************************************************
* Wrapper Class: WrapperClass
* Description: This inner class represents a wrapper for fields and configurations used in the Lightning component.
* Developers: Sukanya 
**********************************************************************************************************************************************************/
    
    public class WrapperClass{
        @AuraEnabled
        public String fieldType{get;set;}
        @AuraEnabled
        public String fieldLabel{get;set;}
        @AuraEnabled
        public String fieldAPIName{get;set;}
        @AuraEnabled 
        public List<String> pickListValues{get;set;}
        @AuraEnabled
        public Boolean required{get;set;}
        @AuraEnabled
        public Boolean visible{get;set;}
        @AuraEnabled
        public Boolean editable{get;set;}
        @AuraEnabled
        public String objectName{get;set;}
        @AuraEnabled
        public String recordType{get;set;}
        @AuraEnabled
        public String programCode{get;set;}
        @AuraEnabled
        public String sectionName{get;set;}
        @AuraEnabled
        public Integer order{get;set;}
        @AuraEnabled
        public String fieldName{get;set;}
        @AuraEnabled
        public String fieldValue{get;set;}
        @AuraEnabled
        public Boolean softrequired{get;set;}
    } 
    
    public class DuplicateDataWrapperCls{
        @AuraEnabled
        public string fieldName{get;set;}
        @AuraEnabled
        public string duplicateAffPrimaryPtcpant{get;set;}
        @AuraEnabled
        public string duplicateParentRef{get;set;}
        @AuraEnabled
        public string duplicateParentEmailMap{get;set;}
        @AuraEnabled
        public string fieldvalue{get;set;}
    }
    
    
}