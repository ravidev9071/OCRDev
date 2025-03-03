global without sharing class REMSUtils {
/********************************************************************************************************************************************************
* Class Name          : REMSUtils
* @Description         : This Apex class will provide static methods to use across all the apex classes'  
* @Author              : Naresh
* Test class Name      : REMSUtils_Test
**********************************************************************************************************************************************************/
    public static final String NAMESPACE_PREFIX = OCRREMSAppLiterals.NAMESPACE_STRING.removeEnd('__');
    public static final String ACCOUNT_SOBJECT_TYPE = 'Account';

    public static Map<String,US_WSREMS__Field_View_Configuration__mdt> depFldConfigMap = new Map<String,US_WSREMS__Field_View_Configuration__mdt>();
    /********************************************************************************************************************************************************
    * Method Name          : retrieveRecTypeNameId
    * @Description         : Retrieves a map of Record Type names and their corresponding Record Type Ids for a given object..  
    * @Author              : Naresh
    **********************************************************************************************************************************************************/
    public static Map<String,Id> retrieveRecTypeNameId(String objectName){
        Map<String,Id> recordTypeNameIdMap = new Map<String,Id>();
        String updatedStringName = isCustomObject(objectName) ? OCRREMSAppLiterals.NAMESPACE_STRING+objectName : objectName;
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(updatedStringName).getDescribe();
        List<Schema.RecordTypeInfo> recTypeInfoList = objectSchema.getRecordTypeInfos();
        for(Schema.RecordTypeInfo recTypeInfoObj:recTypeInfoList){
            if(recTypeInfoObj.isAvailable() && recTypeInfoObj.getDeveloperName()!='Master' && !recTypeInfoObj.isMaster())
                recordTypeNameIdMap.put(recTypeInfoObj.getName(),recTypeInfoObj.getRecordTypeId());            
        }

        return recordTypeNameIdMap;
    }
    /********************************************************************************************************************************************************
    * Method Name          : retrieveRecTypeDeveloperNameId
    * @Description         : Retrieves a map of Record Type developer names and their corresponding Record Type Ids for a given object.  
    * @Author              : Naresh
    **********************************************************************************************************************************************************/   
    public static Map<String,Id> retrieveRecTypeDeveloperNameId(String objectName){
        Map<String,Id> recordTypeDevNameIdMap = new Map<String,Id>();
        String updatedStringName = isCustomObject(objectName) ? OCRREMSAppLiterals.NAMESPACE_STRING+objectName : objectName;
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(updatedStringName).getDescribe();
        List<Schema.RecordTypeInfo> recTypeInfoList = objectSchema.getRecordTypeInfos();
        for(Schema.RecordTypeInfo recTypeInfoObj:recTypeInfoList){
            if(recTypeInfoObj.isAvailable() && recTypeInfoObj.getDeveloperName()!='Master' && !recTypeInfoObj.isMaster())
                recordTypeDevNameIdMap.put(recTypeInfoObj.getDeveloperName(),recTypeInfoObj.getRecordTypeId());            
        }
        return recordTypeDevNameIdMap;
    }
    /********************************************************************************************************************************************************
    * Method Name          : retrieveRecTypeIdDeveloperName
    * @Description         : Retrieves a map of Record Type Ids and their corresponding developer names for a given object.  
    * @Author              : Naresh
    **********************************************************************************************************************************************************/
    public static Map<Id,String> retrieveRecTypeIdDeveloperName(String objectName){
        Map<Id,String> recordTypeIdDevNameMap = new Map<Id,String>();
        String updatedStringName = isCustomObject(objectName) ? OCRREMSAppLiterals.NAMESPACE_STRING+objectName : objectName;
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(updatedStringName).getDescribe();
        List<Schema.RecordTypeInfo> recTypeInfoList = objectSchema.getRecordTypeInfos();
        for(Schema.RecordTypeInfo recTypeInfoObj:recTypeInfoList){
            if(recTypeInfoObj.isAvailable() && recTypeInfoObj.getDeveloperName()!='Master' && !recTypeInfoObj.isMaster())
                recordTypeIdDevNameMap.put(recTypeInfoObj.getRecordTypeId(),recTypeInfoObj.getDeveloperName());            
        }
        return recordTypeIdDevNameMap;
    }
    /********************************************************************************************************************************************************
    * Method Name          : retrieveRecTypeIdDeveloperName
    * @Description         : Retrieves a map of Record Type Ids and their corresponding developer names for a given object.  
    * @Author              : Naresh
    **********************************************************************************************************************************************************/
    public static Map<Id,String> retrieveRecTypeIdName(String objectName){
        Map<Id,String> recordTypeIdNameMap = new Map<Id,String>();
        String updatedStringName = isCustomObject(objectName) ? OCRREMSAppLiterals.NAMESPACE_STRING+objectName : objectName;
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(updatedStringName).getDescribe();
        List<Schema.RecordTypeInfo> recTypeInfoList = objectSchema.getRecordTypeInfos();
        for(Schema.RecordTypeInfo recTypeInfoObj:recTypeInfoList){
            if(recTypeInfoObj.isAvailable() && recTypeInfoObj.getDeveloperName()!='Master' && !recTypeInfoObj.isMaster())
                recordTypeIdNameMap.put(recTypeInfoObj.getRecordTypeId(),recTypeInfoObj.getName());            
        }
        return recordTypeIdNameMap;
    }
    /********************************************************************************************************************************************************
* Method Name          : isFieldAccessible
* @Description         : Checks if a field on a given object is accessible by the current user.  
* @Author              : Naresh
**********************************************************************************************************************************************************/
    public static Boolean isFieldAccessible(String objectName, string field){  
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String updatedStringName = isCustomObject(objectName) ? OCRREMSAppLiterals.NAMESPACE_STRING+objectName : objectName;
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(updatedStringName).getDescribe().fields.getMap();
        
        for(String fieldName : fieldMap.keySet()) {
            if(!field.contains(OCRREMSAppLiterals.NAMESPACE_STRING+fieldName)){
                continue; 
            }
            if(!(fieldMap.get(OCRREMSAppLiterals.NAMESPACE_STRING+fieldName).getDescribe().isAccessible()))
            {
                return false;
            }
        }
        return true;
    }
    /********************************************************************************************************************************************************
* Method Name          : isFieldCreateableAndUpdateable
* @Description         : Checks if a field on a given object is both createable and updateable by the current user.  
* @Author              : Naresh
**********************************************************************************************************************************************************/
    public static Boolean isFieldCreateableAndUpdateable(String objectName, string field){  
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String updatedStringName = isCustomObject(objectName) ? OCRREMSAppLiterals.NAMESPACE_STRING+objectName : objectName;
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(updatedStringName).getDescribe().fields.getMap();
        
        for(String fieldName : fieldMap.keySet()) {
            if(!field.contains(OCRREMSAppLiterals.NAMESPACE_STRING+fieldName)){
                continue; 
            }
            if(!(fieldMap.get(OCRREMSAppLiterals.NAMESPACE_STRING+fieldName).getDescribe().isUpdateable() && 
                 fieldMap.get(OCRREMSAppLiterals.NAMESPACE_STRING+fieldName).getDescribe().isCreateable())) {
                     return false;
                 }
        }
        return true;
    }
    /********************************************************************************************************************************************************
* Method Name          : createSharingRecs
* @Description         : Creates record sharing based on custom settings for read and edit access.  
* @Author              : Naresh
**********************************************************************************************************************************************************/  
    global static void createSharingRecs(Map<String,List<sObject>> programIdvsObjRecs, String shareObj){        
        Map<String,String> programIdVSGroupIdRead = New Map<String,String>();
        Map<String,String> programIdVSGroupIdReadEdit = New Map<String,String>();
        Map<String,US_WSREMS__Apexsharingconfig__c> programIdVSCustomSettingRec = New Map<String,US_WSREMS__Apexsharingconfig__c>();
        list<SObject> lstObjects = new list<SObject>();
        SObjectType objectType = Schema.getGlobalDescribe().get(shareObj);
        
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
        
        //Proceed to record sharing if the custom settings are found in the map...
        for(Id objectId : programIdvsObjRecs.keyset())
        {
            for(SObject rec : programIdvsObjRecs.get(objectId))
            {
                //Share record creation for Read Access only....
                if(programIdVSGroupIdRead.KeySet().Contains(objectId) && objectType!=null)
                { 
                    SObject shareRecord = objectType.newsObject();
                    shareRecord.put('ParentId', rec.Id);
                    shareRecord.put('UserOrGroupId', programIdVSGroupIdRead.get(objectId));
                    shareRecord.put('AccessLevel', 'Read');   
                    lstObjects.add(shareRecord);    
                }
                
                //Share record for Edit Access...
                if(programIdVSGroupIdReadEdit.KeySet().Contains(objectId) && objectType!=null)
                {
                    SObject shareRecordEdit = objectType.newsObject();
                    shareRecordEdit.put('ParentId', rec.Id);
                    shareRecordEdit.put('UserOrGroupId', programIdVSGroupIdReadEdit.get(objectId));
                    shareRecordEdit.put('AccessLevel', 'Edit');
                    lstObjects.add(shareRecordEdit);
                }
            }
        }

        // DML statement
       
        SObjectAccessDecision groupDecission =    Security.stripInaccessible(AccessType.CREATABLE,lstObjects);
        if (!groupDecission.getRecords().isEmpty()) {
            Database.insert(groupDecission.getRecords(), false);       
        }
        
        
    }  
    /********************************************************************************************************************************************************
* Method Name          : isCustomObject
* @Description         : This method helps to check the current object is standard or custom  
* @Author              : Naresh
**********************************************************************************************************************************************************/     
    public static Boolean isCustomObject (string sObjectNameString) {
        return sObjectNameString.endsWithIgnoreCase('__c');
    }
    /********************************************************************************************************************************************************
* Method Name          : validateCustomPermission
* @Description         : This method helps to validate the custom permissions on profile level 
* @Author              : Naresh
**********************************************************************************************************************************************************/ 
    
    public static boolean validateCustomPermission(String customPermissionName){
        return FeatureManagement.checkPermission(customPermissionName);
    }
    /********************************************************************************************************************************************************
* Method Name          : getProgramServiceConfig
* @Description         : Retrieves a list of program service configurations based on program names and service record type developer names.
* @Author              : Naresh
**********************************************************************************************************************************************************/   
    public static List<US_WSREMS__Program_Service_Config__mdt> getProgramServiceConfig (Set<String> programNameSet, Set<String> serviceRecTypeDevNameSet){
        List<US_WSREMS__Program_Service_Config__mdt> programServiceConfigList = new List<US_WSREMS__Program_Service_Config__mdt>();
        programServiceConfigList = [Select US_WSREMS__Program__r.MasterLabel,US_WSREMS__Record_Type_Dev_Name__c,US_WSREMS__Bypass_Duplicate_Check_Statuses__c
                                    ,US_WSREMS__Validate_Open_Cases__c,US_WSREMS__Validate_Open_Tasks__c,US_WSREMS__Validate_Service_Outcome__c
                                    FROM US_WSREMS__Program_Service_Config__mdt where US_WSREMS__Is_Active__c=true and US_WSREMS__Program__r.MasterLabel IN :programNameSet
                                    AND US_WSREMS__Record_Type_Dev_Name__c IN : serviceRecTypeDevNameSet
                                    WITH SECURITY_ENFORCED];
        return programServiceConfigList;
    }
    /********************************************************************************************************************************************************
* Method Name          : getSobjectAllFields
* @Description         : Retrieves a map of field names and labels for all fields on a given object. Id.
* @Author              : Naresh
**********************************************************************************************************************************************************/   
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getSobjectAllFields(String objname){
        Map<String,String> fieldNameMap = new Map<String,String>();
        if(objname!=null && objname!=''){
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType sobjType = gd.get(objname);
            Schema.DescribeSObjectResult describeResult = sobjType.getDescribe();
            Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
            for(string str: fieldsMap.keySet()){
                fieldNameMap.put(fieldsMap.get(str).getDescribe().getName(),fieldsMap.get(str).getDescribe().getLabel());
            }
        }
        return fieldNameMap;
    }
    /********************************************************************************************************************************************************
* Method Name          : getProgramServiceConfigRecord
* @Description         : Retrieves a specific program service configuration record based on program Id and service record type Id.
* @Author              : Naresh
**********************************************************************************************************************************************************/     
    @AuraEnabled(cacheable=true)
    public static List<US_WSREMS__REMS_Program_Service_Config__c> getProgramServiceConfigRecord (String programId, String serviceRecTypeId) {
        List<US_WSREMS__REMS_Program_Service_Config__c> programServiceConfigRec = [SELECT id,US_WSREMS__REMS_Program__c,US_WSREMS__Service_API_Name__c,US_WSREMS__Requestor_Type__c,US_WSREMS__Multi_Authorized_Representative__c
                                                                  ,US_WSREMS__Service_Name__c,US_WSREMS__Stage_Names__c,US_WSREMS__Description__c, US_WSREMS__RDA_Status__c,US_WSREMS__Outcome_Status__c,US_WSREMS__All_child_cases_should_be_closed__c,
                                                                  US_WSREMS__All_tasks_in_case_should_be_closed__c, US_WSREMS__All_tasks_in_RSS_should_be_closed__c, US_WSREMS__Service_Status__c, US_WSREMS__Service_Outcome__c,
                                                                  US_WSREMS__Configure_Reparenting_Service_Names__c,US_WSREMS__Configure_Reparenting_Service_Ids__c,US_WSREMS__PharmacyViewFields__c,US_WSREMS__PrescriberViewFields__c,
                                                                  US_WSREMS__PharmacyUserViewFields__c,US_WSREMS__PatientViewFields__c,US_WSREMS__PrescriberInstutionViewFields__c,US_WSREMS__PrescriberDelegateViewFields__c,US_WSREMS__AuthorizedRepresentativeViewFields__c,
                                                                  US_WSREMS__DistributorViewFields__c,US_WSREMS__PharmacyParticipantViewFields__c,US_WSREMS__PharmacyStaffViewFields__c,US_WSREMS__GeneralContactViewFields__c,
                                                                  US_WSREMS__AuthorizedRepresentativeMiniViewFields__c,US_WSREMS__PatientMiniViewFields__c,US_WSREMS__PharmacyMiniViewFields__c,US_WSREMS__PharmacyUserMiniViewFields__c,US_WSREMS__PrescriberInstitutionMiniViewFields__c,
                                                                  US_WSREMS__PrescriberDelegateMiniViewFields__c,US_WSREMS__PrescriberMiniViewFields__c,US_WSREMS__DistributorMiniViewFields__c,US_WSREMS__PharmacyParticipantMiniViewFields__c,US_WSREMS__PharmacyStaffMiniViewFields__c,
                                                                  US_WSREMS__GeneralContactMiniViewFields__c
                                                                  FROM US_WSREMS__REMS_Program_Service_Config__c WHERE US_WSREMS__REMS_Program__c= :String.escapeSingleQuotes(programId) AND US_WSREMS__Service_API_Name__c= :String.escapeSingleQuotes(serviceRecTypeId)];
        return programServiceConfigRec;
    }
  /********************************************************************************************************************************************************
    * Method Name          : Overloading method for getData
    * @Description         : Retrieves data for a set of objects, given a record Id, object names, target record type, program name, and requestor type.
    * @CreatedDate         : 31st Jan 2024
    * @Author              : Suresh 
    **********************************************************************************************************************************************************/
   //@AuraEnabled(cacheable=true)
    public static Map<String, List<WrapperClass>> getData(String recordId, String objectNames, String targetRecordType, String programName, String requetoryType) {
        return getData(recordId, objectNames, targetRecordType, programName, requetoryType, null);
    }
    /********************************************************************************************************************************************************
    * Method Name          : getData
    * @Description         : Retrieves data for a set of objects, given a record Id, object names, target record type, program name, and requestor type, sourceTpye.
    * @CreatedDate         : 16th Nov 2023
    * @Author              : Sukanya 
    **********************************************************************************************************************************************************/ 
    @AuraEnabled(cacheable=true)
    public static Map<String, List<WrapperClass>> getData(String recordId, String objectNames, String targetRecordType, String programName, String requetoryType, String sourceType) {
        
        Map<String, List<WrapperClass>> seactionMap = new Map<String, List<WrapperClass>>();
        Map<String,String> stagingKeyValueMap=getGetStagingData(recordId);
        List<String> objects = objectNames.split(',');
        objectNames = objects[0];
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMapTemp;
        Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField>();
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        Map<String, FieldConfig__c> programMap = new Map<String, FieldConfig__c>();
        Map<String, String> fieldNameMap = new Map<String, String>();
        List<WrapperClass> wrapperList = new List<WrapperClass>();
        Map<String, String> fieldValueMap = new Map<String, String>();
        Id recordTypeId;
         try {
            
            for (String s : objects) {
                Schema.SObjectType objectSchema = schemaMap.get(s);
                fieldMapTemp = objectSchema.getDescribe().fields.getMap();
                fieldMap.putAll(fieldMapTemp); 
            }
            
            for (Schema.SObjectField field : fieldMap.values()) {
                DescribeFieldResult fieldDesc = field.getDescribe();
                String fieldName = fieldDesc.getName();
                fieldNameMap.put(fieldName, fieldName.toLowerCase());
            }
            
            programMap = getRecords(objectNames, targetRecordType, programName, requetoryType, sourceType);
            for (String fieldName : fieldMap.keySet()) {
                if (String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) == 'PICKLIST' || String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) == 'MULTIPICKLIST') {
                    List<Schema.PicklistEntry> values = fieldMap.get(fieldName).getDescribe().getPickListValues();
                    if (String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) == 'PICKLIST') {
                        picklistMap.put(fieldName, new List<String>{'--None--'});
                    }
                    for (Schema.PicklistEntry a : values) {
                        if (!picklistMap.containsKey(fieldName)) {
                            picklistMap.put(fieldName, new List<String>{a.getValue()});
                        } else {
                            picklistMap.get(fieldName).add(a.getValue());
                        }
                    }
                }
            }
            for (String fName : programMap.keySet()) {
                
                String key=programMap.get(fName).StagingKey__c;
                 System.debug('key top'+key);
                String targetf=programMap.get(fName).TargetObjField__c;
                key=key!=null?key.replace('.','_'):'';
               
                    String targetfield = fName.substringBefore(';'); 
                    String fieldName = fieldNameMap.get(targetfield);
                    
                if (!targetfield.contains('emptyField') && !String.isEmpty(fieldName) && fieldMap.keySet().contains(fieldName)) {
                        WrapperClass wrap = new WrapperClass();
                        string section = fName.substringAfterLast(';');
                       // wrap.fieldValue=stagingKeyValueMap.get(String.valueOf(programMap.get(fName).StagingKey__c)+section);
                       wrap.fieldValue=stagingKeyValueMap.containsKey(key)?stagingKeyValueMap.get(key):'';

                        if (programMap.get(fName).TargetObjFieldLabel__c != null) {
                            wrap.fieldLabel = programMap.get(fName).TargetObjFieldLabel__c;
                        } else {
                            wrap.fieldLabel = String.valueOf(fieldMap.get(fieldName).getDescribe().getLabel());
                        }
                      
                        wrap.fieldType = String.valueOf(fieldMap.get(fieldName).getDescribe().getType());
                        wrap.fieldAPIName = fName;
                        
                        wrap.fieldName = fName.substringBefore(';');
                        if (fieldValueMap != null && fieldValueMap.containsKey(wrap.fieldName)) {
                            wrap.fieldValue = fieldValueMap.get(wrap.fieldName);
                        }
                        
                        if (fieldName == OCRREMSAppLiterals.NAMESPACE_STRING + 'Program_Picklist__c') {
                            wrap.fieldValue = programName;
                        }
                        
                        
                        wrap.sectionName = section;
                        wrap.fieldDataType = programMap.get(fName).FieldType__c;
                        wrap.inCompleteValue = programMap.get(fName).IncompleteValue__c; 
                        wrap.disableRelatedFields = programMap.get(fName).DisabledRelatedFields__c;
                        wrap.updateRelatedFields = programMap.get(fName).UpdateSubstakeholder__c;
                        wrap.reParent = programMap.get(fName).Reparent__c;
                        wrap.requestorType = programMap.get(fName).RequestorType__c;
                        wrap.dependentField = programMap.get(fName).DependentField__c != null ? programMap.get(fName).DependentField__r.TargetObjField__c : '';
                        wrap.dependentValue = programMap.get(fName).DependentField__c;
                        wrap.required = programMap.get(fName).Required__c;
                        wrap.softrequired = programMap.get(fName).SoftRequired__c;
                        wrap.visible = programMap.get(fName).Visible__c;
                        wrap.editable = programMap.get(fName).Editable__c;
                        wrap.validationMsg = programMap.get(fName).ValidationMessage__c;
                       // wrap.permissionSet = programMap.get(fName).US_WSREMS__Required_Permission_Set__c;
                        wrap.isParticipant = programMap.get(fName).DefaultParent__c;
                        wrap.referenceObject = programMap.get(fName).RefObject__c;
                        wrap.referenceRecType = programMap.get(fName).RefRecordType__c;
                        wrap.additionalSection = programMap.get(fName).AdditionalSection__c;
                        wrap.helpText = programMap.get(fName).HelpText__c;
                        wrap.isHelpText = wrap.helpText!=null?True:False;
                        
                       if (wrap.fieldType == 'PICKLIST' || wrap.fieldType == 'MULTIPICKLIST') {
                            wrap.pickListValues = picklistMap.get(fieldName);
                        }
                        wrap.objectName = programMap.get(fName).TargetObj__c;
                        wrap.recordType = programMap.get(fName).TargetObjRecordType__c;
                        wrap.tittle = programMap.get(fName).Title__c;
                        wrap.additionalFieldValidation = programMap.get(fName).AdditionalFieldValidation__c; 
                        wrap.validationReferenceField =  programMap.get(fName).ValidationRefeField__c; 
                        wrap.order = Integer.valueOf(programMap.get(fName).Order__c);
                        if(wrap.referenceObject == null && wrap.objectName != null){
                            wrap.referenceObject = wrap.objectName;
                        }
                        if(wrap.referenceRecType == null && wrap.recordType != null){
                            wrap.referenceRecType = wrap.recordType;
                        }

                        if (!seactionMap.containsKey(wrap.sectionName+'#'+wrap.referenceObject+'#'+wrap.referenceRecType+'#'+wrap.additionalSection) && wrap.visible == true) {
                            seactionMap.put(wrap.sectionName+'#'+wrap.referenceObject+'#'+wrap.referenceRecType+'#'+wrap.additionalSection, new List<WrapperClass>{wrap});
                        } else if (seactionMap.containsKey(wrap.sectionName+'#'+wrap.referenceObject+'#'+wrap.referenceRecType+'#'+wrap.additionalSection)) {
                            seactionMap.get(wrap.sectionName+'#'+wrap.referenceObject+'#'+wrap.referenceRecType+'#'+wrap.additionalSection).add(wrap);
                        }
                        wrapperList.add(wrap);
                    } else if (targetfield.contains('emptyField')) {
                        WrapperClass wrap = new WrapperClass();
                        wrap.objectName = programMap.get(fName).TargetObj__c;
                        wrap.recordType = programMap.get(fName).TargetObjRecordType__c;
                        wrap.referenceObject = programMap.get(fName).RefObject__c;
                        wrap.referenceRecType = programMap.get(fName).RefRecordType__c;
                        wrap.additionalSection = programMap.get(fName).AdditionalSection__c;

                        wrap.isUpload = programMap.get(fName).UploadAttachments__c;
                        string section = fName.substringAfterLast(';');
 
                        if(wrap.isUpload) {
                            wrap.required = programMap.get(fName).Required__c;
                            wrap.softrequired = programMap.get(fName).SoftRequired__c;
                            wrap.visible = programMap.get(fName).Visible__c;
                            wrap.editable = programMap.get(fName).Editable__c;
                            wrap.tittle = programMap.get(fName).Title__c;
                            wrap.sectionName = section;
                            wrap.fieldLabel = programMap.get(fName).TargetObjFieldLabel__c;
                        
                        } else {
                            wrap.fieldName = '';
                        wrap.sectionName = section;
                        wrap.visible = programMap.get(fName).Visible__c;
                        wrap.order = Integer.valueOf(programMap.get(fName).Order__c);
                        }   
                        if(wrap.referenceObject == null && wrap.objectName != null){
                            wrap.referenceObject = wrap.objectName;
                        }
                        if(wrap.referenceRecType == null && wrap.recordType != null){
                            wrap.referenceRecType = wrap.recordType;
                        }
                        
                        if (!seactionMap.containsKey(wrap.sectionName+'#'+wrap.referenceObject+'#'+wrap.referenceRecType+'#'+wrap.additionalSection) && wrap.visible == true) {
                            seactionMap.put(wrap.sectionName+'#'+wrap.referenceObject+'#'+wrap.referenceRecType+'#'+wrap.additionalSection, new List<WrapperClass>{wrap});
                        } else if (seactionMap.containsKey(wrap.sectionName+'#'+wrap.referenceObject+'#'+wrap.referenceRecType+'#'+wrap.additionalSection)) {
                            seactionMap.get(wrap.sectionName+'#'+wrap.referenceObject+'#'+wrap.referenceRecType+'#'+wrap.additionalSection).add(wrap);
                        }
                        wrapperList.add(wrap);

                        if(wrap.isUpload) {
                            break;
                        }
                    }
             }
        }  catch (Exception ex) {
            System.debug('getData  '+ex.getLineNUmber());
            throw new AuraHandledException('An unexpected error occurred in getRecords method: ' + ex.getStackTraceString());
        }
        return seactionMap;
    }
    
    /********************************************************************************************************************************************************
* Method Name          : getGetStagingData
* @Description         : Retrieves Key value field data from Staging Details.
* @CreatedDate         : 12th Feb 2025
* @Author              : Phool Chandra
**********************************************************************************************************************************************************/ 
    public static Map<String,String> getGetStagingData(Id docChkLstId){
        Map<String,String> keyValMap=new Map<String,String>();
        List<StagingDetail__c> stgnDetList=new List<StagingDetail__c>([SELECT ID,Key__c,value__c,SectionHeader__c FROM StagingDetail__c where StagingHeader__r.DocDetail__c=:docChkLstId]);
      for(StagingDetail__c stgnDet:stgnDetList){
           // keyValMap.put(stgnDet.key__c+stgnDet.SectionHeader__c,stgnDet.value__c);
              String key=stgnDet.key__c!=null?stgnDet.key__c.replace('.','_'):'';
          if(key!=''){
			  keyValMap.put(key,stgnDet.value__c);
          }
        }
        return keyValMap;
    }
    
 /********************************************************************************************************************************************************
* Method Name          : getFieldVisibilityRecords
* @Description         : Retrieves field view configurations based on object name, record type name, program name, Account status and status value.
* @CreatedDate         : 15th Mar 2024
* @Author              : Asifa
**********************************************************************************************************************************************************/ 
public static List<US_WSREMS__Field_View_Configuration__mdt> getFieldVisibilityRecords(String recTypeDevName, String progName,String refFld,String refFldVal){
    List<US_WSREMS__Field_View_Configuration__mdt> requiredFldConfigList = new List<US_WSREMS__Field_View_Configuration__mdt>();
        requiredFldConfigList = [SELECT Id,DeveloperName,US_WSREMS__Active__c,US_WSREMS__Dependent_Field__c,US_WSREMS__Object_Name__c,US_WSREMS__Program_Name__c,US_WSREMS__Record_Type__c,US_WSREMS__Reference_Field__c,
                                         US_WSREMS__Reference_Field_value__c,US_WSREMS__Visible__c,US_WSREMS__Disabled__c FROM US_WSREMS__Field_View_Configuration__mdt WHERE US_WSREMS__Object_Name__c=:OCRREMSAppLiterals.ACCOUNT_OBJECT
                                         AND US_WSREMS__Record_Type__c=:recTypeDevName AND US_WSREMS__Program_Name__r.MasterLabel=:progName
                                         AND US_WSREMS__Reference_Field__c=:refFld AND US_WSREMS__Reference_Field_value__c=:refFldVal AND US_WSREMS__Active__c= true
                                        ];
        return requiredFldConfigList;
    }

    /********************************************************************************************************************************************************
* Method Name          : getRecords
* @Description         : Retrieves program field configurations based on object name, record type name, program name, and requestor type.
* @CreatedDate         : 16th Nov 2023
* @Author              : Pavani
**********************************************************************************************************************************************************/    
    public static Map<String, FieldConfig__c> getRecords(String objectName, String recordTypeName, String ProgramName, String requestorType, String sourceType) {
        try {
            Map<String, FieldConfig__c> programMap = new Map<String, FieldConfig__c>();
            Integer i = 0;

             String queryString = 'SELECT Id, REMSProgram__r.Name,StagingKey__c, TargetObj__c, TargetObjField__c, TargetObjFieldLabel__c,DependentValue__c,DependentField__c, DependentField__r.TargetObjField__c,Title__c,Editable__c,Visible__c, Required__c,TargetObjRecordType__c, Order__c, SectionName__c,FieldType__c,SoftRequired__c,RequestorType__c,IncompleteValue__c ,AdditionalFieldValidation__c ,ValidationRefeField__c ,DisabledRelatedFields__c,UploadAttachments__c,UpdateSubstakeholder__c,ValidationMessage__c,Reparent__c,SourceType__c,DefaultParent__c,RefObject__c,RefRecordType__c, AdditionalSection__c,HelpText__c  ' +
                'FROM FieldConfig__c ' +
                'WHERE REMSProgram__r.Name = :ProgramName AND TargetObj__c = :ObjectName AND TargetObjRecordType__c = :recordTypeName';
            
            if (String.isNotBlank(requestorType)) {
                queryString += ' AND RequestorType__c = :requestorType';
            }
             if (String.isNotBlank(sourceType)) {
                queryString += ' AND SourceType__c = :sourceType';
            }
            
           if (String.isBlank(sourceType)) {
               queryString += ' AND SourceType__c = : sourceType';
            } 
            
            queryString += ' ORDER BY SectionOrder__c, Order__c';
            List<FieldConfig__c> programFieldsList = Database.query(queryString);
            System.debug('programFieldsList==> '+programFieldsList.size());
            if (programFieldsList != null && !programFieldsList.isEmpty()) {
                for (FieldConfig__c pc : programFieldsList) {
                    String key = pc.TargetObjField__c != null ?
                        pc.TargetObjField__c + ';' + pc.TargetObjRecordType__c + ';' + pc.SectionName__c :
                    'emptyField' + i++ + ';' + pc.TargetObjRecordType__c + ';' + pc.SectionName__c;
                    
                    programMap.put(key, pc);
                }
            } else {
                throw new AuraHandledException('No records found for the specified criteria.');
            }
            
            return programMap;
        } catch (Exception ex) {
            System.debug('getrecords '+ex.getLineNUmber());
            throw new AuraHandledException('An unexpected error occurred in getRecords method: ' + ex.getMessage());
        }
    }
    
    /********************************************************************************************************************************************************
* Method Name          : getCurrentUserProgram
* @Description         : Retrieves the current user's program based on the active Program Users.
* @CreatedDate         : 15th Nov 2023
* @Author              : Sukanya 
**********************************************************************************************************************************************************/
    @AuraEnabled 
    public static List<US_WSREMS__Program_Users__c> getCurrentUserPrograms(){
        try {
            List<US_WSREMS__Program_Users__c> programusersList = [SELECT Id, US_WSREMS__REMS_Program__c, US_WSREMS__REMS_Program__r.Name, US_WSREMS__Is_Active__c
                                                       FROM US_WSREMS__Program_Users__c WHERE US_WSREMS__User__c != null AND US_WSREMS__User__c = :UserInfo.getUserId() AND US_WSREMS__Is_Active__c = true LIMIT 1]; 
            return programusersList;    
        } catch (QueryException e) {
            throw new AuraHandledException('Error fetching current user\'s program: ' + e.getMessage());
        }        
    }

/*****************************************************************************************************************
    * Method Name          : getCurrentUser
    * @Description         : To get current logged in user record
    * @Author              : 
    * @CreatedDate         :  27-03-2024
    * @param               : 
    * @return              : User
*****************************************************************************************************************/
public static User getCurrentUser() {
    try {
        User userObj = [SELECT Id,Contact.AccountId,Contact.Account.US_WSREMS__PortalStage__c,Account.US_WSREMS__PortalStage__c FROM User where Id = :UserInfo.getUserId()];

        return userObj;
    } catch (Exception ex) {
        System.debug('getrecords '+ex.getLineNUmber());
        throw new AuraHandledException('An unexpected error occurred in getRecords method: ' + ex.getMessage());
    }
}

/*********************************************************************************************************************************************************
* Method Name          : saveModifiedData
* @Description         : This method is used to save changed account details.
@param recordId The ID of the account record and modified fields as key and modified data as value.
@return a contact
* @CreatedDate         : 1 Jan 2023
* @Author              : Sukanya
**********************************************************************************************************************************************************/
    
@AuraEnabled
public static string saveModifiedData(String recordId, Map<String, String> modifiedData) {
    try {
        if(modifiedData == null || string.isEmpty(recordId)){
            return null;
        }
        Account userAccount= [SELECT Id, Name,US_WSREMS__REMS_Program__c,US_WSREMS__FaxId__c,US_WSREMS__Record_Type_Name__c,US_WSREMS__REMS_Program__r.Name, RecordType.Name,US_WSREMS__REMS_ID__c FROM Account WHERE Id = :recordId LIMIT 1];
        Map<String,US_WSREMS__Field_Mapping_Config__mdt> fieldMappingMap = getFieldMappingList(userAccount);
        if(fieldMappingMap == null){
            return null;
        }
        Set<String> fieldNames = fieldMappingMap.keySet();
        String query = 'SELECT US_WSREMS__Record_Type_Name__c,' + String.join(new List<String>(fieldNames), ', ') + ' FROM Account WHERE Id = :recordId LIMIT 1';
        List<Account> originalData= Database.query(query);
        Boolean isDataChanged = false;
        for(string fieldName : modifiedData.keySet()){
            if(fieldMappingMap.containsKey(fieldName) && originalData[0].get(fieldName) != modifiedData.get(fieldName)){
                isDataChanged = true;
            }
        }
        
        if(isDataChanged) {
            Account accObj = new Account(Id = originalData[0].Id);
            for (String fieldName : fieldNames) {
                accObj.put(fieldName, originalData[0].get(fieldName));
                if(modifiedData.containsKey(fieldName) && originalData[0].get(fieldName) != modifiedData.get(fieldName)){
                    accObj.put(fieldName, modifiedData.get(fieldName));    
                }
            }
            update accObj;
            
            String serviceId = createRemsService(userAccount);
            String caseId = createCase(accObj,fieldMappingMap,userAccount.RecordType.Name,userAccount.US_WSREMS__REMS_ID__c);
            updateChangeOfInformationCase(caseId,serviceId);
            if(userAccount.US_WSREMS__FaxId__c !=null){
                try{
                    DocumentChecklistItem dcl = new DocumentChecklistItem();
                    dcl.Id = userAccount.US_WSREMS__FaxId__c;
                    dcl.US_WSREMS__Case__c = caseId;
                    dcl.US_WSREMS__REMS_Service__c = serviceId;
                    dcl.US_WSREMS__REMS_Account__c = userAccount.Id;
                    update dcl; 
                }catch(exception ex){
                    system.debug('Error '+ex.getMessage());
                }
                
             }
        }
        return 'Success';
        
    }catch (QueryException e) {
        throw new AuraHandledException('Error: ' + e.getMessage()+e.getstacktracestring());
    }  
}

/*********************************************************************************************************************************************************
* Method Name          : createRemsService
* @Description         : This method is used to create REMS Service record.
* @param account record.
* @return a Rems Service record Id
* @CreatedDate         : 1 Jan 2023
* @Author              : Sukanya
**********************************************************************************************************************************************************/

public static string createRemsService(Account accObj){
    try {
        Id serviceRecordTypeId = retrieveRecTypeNameId(OCRREMSAppLiterals.SERVICE_SUMMARY_OBJ).get('Change of Information');
        US_WSREMS__REMS_Service_Summary__c rsObj = new US_WSREMS__REMS_Service_Summary__c(
        US_WSREMS__Participant__c = accObj.Id,
        US_WSREMS__Status__c = 'Closed',
        US_WSREMS__Service_Outcome__c = 'Successful',
        RecordTypeId=serviceRecordTypeId,
        US_WSREMS__Requestor_Type__c = accObj.RecordType.Name,
        US_WSREMS__Path_Stage_Name__c = 'Closed',
        US_WSREMS__REMSProgram__c = accObj.US_WSREMS__REMS_Program__c,
        US_WSREMS__Path_Complete__c = true
        );
        insert rsObj; 
        return rsObj.Id;
    }catch (Exception e) {
      //  REMSLoggerUtility.customLogs(e,'Exception while retreving lookup records.');
        throw new AuraHandledException(e.getMessage());         
    }
}

/*********************************************************************************************************************************************************
* Method Name          : getFieldMappingList
* @Description         : This method is used to get Field_Mapping_Config__mdt custom metadata records
* @param account record.
* @return a map of custom metadata records.
* @CreatedDate         : 1 Jan 2023
* @Author              : Sukanya
**********************************************************************************************************************************************************/

public static Map<String,US_WSREMS__Field_Mapping_Config__mdt> getFieldMappingList(Account accObj){
    Map<String,US_WSREMS__Field_Mapping_Config__mdt> fieldMappingMap = new Map<String,US_WSREMS__Field_Mapping_Config__mdt>();
    List<US_WSREMS__Field_Mapping_Config__mdt> fieldMappingList = [SELECT Id,US_WSREMS__Source_Object__c,US_WSREMS__Target_Object__c,US_WSREMS__Program__r.Label,US_WSREMS__Source_Field__c,US_WSREMS__Target_Field__c,US_WSREMS__Target_RecordType_Name__c  
                                                                  FROM US_WSREMS__Field_Mapping_Config__mdt WHERE US_WSREMS__Source_RecordType_Name__c =: accObj.US_WSREMS__Record_Type_Name__c 
                                                                  AND US_WSREMS__Program__r.Label =: accObj.US_WSREMS__REMS_Program__r.Name 
                                                                  AND US_WSREMS__Request_Type__c = 'Change of Information' AND US_WSREMS__IsActive__c = true];
      if(fieldMappingList.isEmpty()){
        return null;
    }
    
    for(US_WSREMS__Field_Mapping_Config__mdt fmcObj : fieldMappingList){
        fieldMappingMap.put(fmcObj.US_WSREMS__Source_Field__c,fmcObj);
    }
    return fieldMappingMap ;
}

/*********************************************************************************************************************************************************
* Method Name          : createCase
* @Description         : This method is used to create Case
* @param account record and custom metadata records.
* @return a case record Id.
* @CreatedDate         : 1 Jan 2023
* @Author              : Sukanya
**********************************************************************************************************************************************************/

public static string createCase(Account accObj, Map<String,US_WSREMS__Field_Mapping_Config__mdt> fieldMappingMap,String requestorType,String remsId){
    String caseRecordTypeDeveloperName;
    case newCase = new case();                                                       
    if(!fieldMappingMap.IsEmpty()){
        // Iterate metadata records to assign Case fields data based on Account field mapping
        for(string sourceField: fieldMappingMap.keySet()){
            newCase.put(fieldMappingMap.get(sourceField).US_WSREMS__Target_Field__c, accObj.get(sourceField));
            caseRecordTypeDeveloperName =  fieldMappingMap.get(sourceField).US_WSREMS__Target_RecordType_Name__c;
        }
    }
    if(caseRecordTypeDeveloperName != null){
        Id caseRecordTypeId = REMSUtils.retrieveRecTypeDeveloperNameId(OCRREMSAppLiterals.CASE_OBJECT).get(caseRecordTypeDeveloperName);
        newCase.RecordTypeId=caseRecordTypeId;
    }
    newCase.Status = 'Complete';
    newCase.US_WSREMS__Outcome__c = 'Complete';
    newCase.AccountId = accObj.Id;
    newCase.US_WSREMS__Participant__c = accObj.Id;
    newCase.US_WSREMS__X1_Participant__c = accObj.Id;
    newCase.US_WSREMS__Requestor_Type__c = requestorType;
    newCase.US_WSREMS__REMS_ID__c = remsId;
  
    insert newCase;
    return newCase.Id;
}

/*********************************************************************************************************************************************************
* Method Name          : updateChangeOfInformationCase
* @Description         : This method is used to update Case with Rems Service Id
* @param case Id and Rems Service Id.
* @CreatedDate         : 1 Jan 2023
* @Author              : Sukanya
**********************************************************************************************************************************************************/

public static void updateChangeOfInformationCase(string caseId, string serviceId){
    Case newCase = new Case(Id= caseId);
    newCase.US_WSREMS__REMS_Service_Summary__c = serviceId;
    update newCase;
}
    /*********************************************************************************************************************************************************
* Method Name          : getUsersAccount
* @Description         : Retrieves portal account of the logged in user.
@return a contact
* @CreatedDate         : 21th Dec 2023
* @Author              : Deepthi
**********************************************************************************************************************************************************/
    @AuraEnabled
    public static contact getUsersAccount() {
        contact con;
        List<User> usr = [select Id,ContactId from User where Id = :UserInfo.getUserId()];
        // Get Account based on Contact present in logged in User
        List<Contact> conRec = [select Id,Accountid,Name,Account.US_WSREMS__National_Provider_Identifier__c from contact where Id = :usr[0].ContactId];
        if(!conRec.IsEmpty()){
            con = conRec[0];
        }
        return con;
    }
    
/********************************************************************************************************************************************************
* Method Name          : getSettingMetadata
* @Description         : Retrieves the field values from metadata.
* @CreatedDate         : 9th Jan 2024
* @Author              : Shikha
**********************************************************************************************************************************************************/
    @AuraEnabled 
    Public static List<US_WSREMS__REMS_CorrespondenceSettings__mdt> getSettingMetadata(US_WSREMS__Assessment_Submission__c oSubmission){
        List<US_WSREMS__REMS_CorrespondenceSettings__mdt> settingsMetadata = [SELECT Id, US_WSREMS__From__c,DeveloperName, US_WSREMS__BCC_Email__c, US_WSREMS__Template_Name__c,US_WSREMS__Active__c,US_WSREMS__Program_Configuration__r.Label,US_WSREMS__Result__c
                                                                   FROM US_WSREMS__REMS_CorrespondenceSettings__mdt
                                                                   WHERE US_WSREMS__Result__c=:oSubmission.US_WSREMS__Assessment_Result__c AND
                                                                   US_WSREMS__Active__c=true AND
                                                                   US_WSREMS__Program_Configuration__r.Label = :oSubmission.US_WSREMS__Case__r.US_WSREMS__REMS_Program__r.Name];
 
        return settingsMetadata;
    }
/********************************************************************************************************************************************************
* Method Name          : getEmailTemplate
* @Description         : Retrieves email template name.
* @CreatedDate         : 9th Jan 2024
* @Author              : Shikha
**********************************************************************************************************************************************************/
    @AuraEnabled 
   public static EmailTemplate getEmailTemplate(string templateName){
        EmailTemplate et= [SELECT Id,Subject,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName=:templateName LIMIT 1];
        return et;
    }
/********************************************************************************************************************************************************
* Method Name          : getOrgWideEmail
* @Description         : Retrieves Organization email Address.
* @CreatedDate         : 9th Jan 2024
* @Author              : Shikha
**********************************************************************************************************************************************************/
    @AuraEnabled
    public static OrgWideEmailAddress[] getOrgWideEmail(string fromAddress){
        OrgWideEmailAddress[] owea =[SELECT Id FROM OrgWideEmailAddress WHERE Address =:fromAddress];
        return owea;
    }

 /*********************************************************************************************************************************************************
* Method Name          : getEsigProgFldConfigRecords
* @Description         : This method is used to get Program Field Configurations for E-zsignature
@param recordId 
@return List of Program Field Configurations
* @CreatedDate         : 18 Mar 24
* @Author              : Divya G
*********************************************************************************************************************************************************/
Public static List<US_WSREMS__Program_Fields_Configuration__c> getEsigProgFldConfigRecords(String recordTypeDevName, String objectName, String progName,Boolean eSigFlds){
    List<US_WSREMS__Program_Fields_Configuration__c> progConfigList = new List<US_WSREMS__Program_Fields_Configuration__c>();
    progConfigList = [SELECT Id,US_WSREMS__Target_Object_Field__c,
                      US_WSREMS__Target_Object_Field_Label__c,
                      US_WSREMS__Target_Object_Record_Type__c,
                      US_WSREMS__REMS_Program__c,
                      US_WSREMS__Target_Object__c,
                      US_WSREMS__Section_Name__c,
                      US_WSREMS__Incomplete_Value__c
                      FROM US_WSREMS__Program_Fields_Configuration__c 
                      WHERE US_WSREMS__Target_Object_Record_Type__c=:recordTypeDevName
                      AND US_WSREMS__Target_Object__c = :objectName
                      AND US_WSREMS__REMS_Program__r.Name=:progName
                      AND US_WSREMS__Missing_Information__c = :eSigFlds
                      AND US_WSREMS__Incomplete_Value__c != null
                      WITH SECURITY_ENFORCED];
    return progConfigList;
}
 /*********************************************************************************************************************************************************
    * Method Name          : getCurrentCaseData
    * @Description         : This method is used to get Case Records
    @param recordId 
    @return Case Record
    * @CreatedDate         : 18 Mar 24
    * @Author              : Divya G
    *********************************************************************************************************************************************************/
    Public Static Case getCaseData(String caseQuery,Set<String> caseQueryFldSet,Id caseId){
        Case currentCase;
        for(String fldName:caseQueryFldSet){
            caseQuery = caseQuery+','+fldName;
        } 
        caseQuery = caseQuery+' FROM Case WHERE Id=\''+caseId+'\' LIMIT 1';
        currentCase = Database.Query(caseQuery);
            return currentCase;
        }
    
    /********************************************************************************************************************************************************
    * Method Name          : geteSignSettRecords
    * @Description         : Retrieves the Esignature records frommetadata.
    * @CreatedDate         : 18th Mar 2024
    * @Author              : Divya G
    **********************************************************************************************************************************************************/
    Public static List<US_WSREMS__REMS_CorrespondenceSettings__mdt> geteSignSettRecords(String objName,Case currentCase, Set<String> refFields){
        List<US_WSREMS__REMS_CorrespondenceSettings__mdt> settingsMetadata = [SELECT Id, DeveloperName, Label, US_WSREMS__Active__c, US_WSREMS__From__c, US_WSREMS__Object_Name__c,
                                                                 US_WSREMS__Program_Configuration__c,US_WSREMS__Program_Configuration__r.Label, US_WSREMS__Recipient_Email_Field__c, 
                                                                 US_WSREMS__Recipient_Type__c, US_WSREMS__Template_Name__c, US_WSREMS__Type__c,US_WSREMS__Record_Type_Developer_Name__c,US_WSREMS__BCC_Email__c,US_WSREMS__Relationship_Field__c,
                                                                 US_WSREMS__Case_Status__c,US_WSREMS__Reference_Field__c,US_WSREMS__Reference_Field_Value__c
                                                                 FROM US_WSREMS__REMS_CorrespondenceSettings__mdt
                                                                 WHERE US_WSREMS__Object_Name__c = :objName
                                                                 AND US_WSREMS__Record_Type_Developer_Name__c = :currentCase.US_WSREMS__Record_Type_Name__c
                                                                 AND US_WSREMS__Program_Configuration__r.Label = :currentCase.US_WSREMS__Program_Name__c 
                                                                 AND US_WSREMS__Reference_Field__c IN :refFields
                                                                 AND US_WSREMS__Recipient_Email_Field__c != null
                                                                 AND US_WSREMS__E_Signature__c= true
                                                                 AND US_WSREMS__Active__c=true];
        
        return settingsMetadata;
    }
    
    /********************************************************************************************************************************************************
    * Method Name          : getTemplateeSignSettRecords
    * @Description         : Retrieves the Esignature records frommetadata.
    * @CreatedDate         : 18th Mar 2024
    * @Author              : Divya G
    **********************************************************************************************************************************************************/
    Public static List<US_WSREMS__REMS_CorrespondenceSettings__mdt> getTemplateeSignSettRecords(String progamName, Set<String> refFields){
        List<US_WSREMS__REMS_CorrespondenceSettings__mdt> settingsMetadata = [SELECT Id, DeveloperName, Label, US_WSREMS__Active__c, US_WSREMS__From__c, US_WSREMS__Object_Name__c,
                              US_WSREMS__Program_Configuration__c,US_WSREMS__Program_Configuration__r.Label, US_WSREMS__Recipient_Email_Field__c, 
                              US_WSREMS__Recipient_Type__c, US_WSREMS__Template_Name__c, US_WSREMS__Type__c,US_WSREMS__Record_Type_Developer_Name__c,US_WSREMS__BCC_Email__c,US_WSREMS__Relationship_Field__c,
                              US_WSREMS__Case_Status__c,US_WSREMS__Reference_Field__c,US_WSREMS__Reference_Field_Value__c FROM US_WSREMS__REMS_CorrespondenceSettings__mdt 
                              WHERE US_WSREMS__Active__c = TRUE AND US_WSREMS__Program_Configuration__r.Label = : progamName AND US_WSREMS__Reference_Field__c IN :refFields AND US_WSREMS__Template_Name__c != null];
        
        return settingsMetadata;
    }

    /********************************************************************************************************************************************************
    * Method Name          : geteSignUrlSettRecords
    * @Description         : Retrieves the Esignature records with url frommetadata.
    * @CreatedDate         : 18th Mar 2024
    * @Author              : Divya G
    **********************************************************************************************************************************************************/
    Public static List<US_WSREMS__REMS_CorrespondenceSettings__mdt> geteSignUrlSettRecords(Case currentCase){
        List<US_WSREMS__REMS_CorrespondenceSettings__mdt> settingsMetadata = [SELECT Id, DeveloperName, Label, US_WSREMS__Active__c, US_WSREMS__From__c, US_WSREMS__Object_Name__c,
                                                                 US_WSREMS__Program_Configuration__c,US_WSREMS__Program_Configuration__r.Label, US_WSREMS__Recipient_Email_Field__c, 
                                                                 US_WSREMS__Recipient_Type__c, US_WSREMS__Template_Name__c, US_WSREMS__Type__c,US_WSREMS__Record_Type_Developer_Name__c,US_WSREMS__BCC_Email__c,US_WSREMS__Relationship_Field__c,
                                                                 US_WSREMS__Case_Status__c,US_WSREMS__Reference_Field__c,US_WSREMS__Reference_Field_Value__c,US_WSREMS__E_Sign_Url__c
                                                                 FROM US_WSREMS__REMS_CorrespondenceSettings__mdt
                                                                 WHERE US_WSREMS__Object_Name__c = :OCRREMSAppLiterals.CASE_OBJECT
                                                                 AND US_WSREMS__Record_Type_Developer_Name__c = :currentCase.US_WSREMS__Record_Type_Name__c
                                                                 AND US_WSREMS__Program_Configuration__r.Label = :currentCase.US_WSREMS__Program_Name__c 
                                                                 AND US_WSREMS__E_Signature__c = true
                                                                 AND US_WSREMS__E_Sign_Url__c != null 
                                                                 WITH SECURITY_ENFORCED];
        
        return settingsMetadata;
    }

    /********************************************************************************************************************************************************
    * Method Name          : getAffiliationSetupRecords
    * @Description         : Retrieves the Affiliation Setup Configuration records
    * @CreatedDate         : 25th Mar 2024
    * @Author              : Moses Devara
    **********************************************************************************************************************************************************/
    Public static List<US_WSREMS__Affiliation_Setup_Configuration__mdt> geteAffiliationSetupRecords(String recordTypeName, String programName, String participantType){
        List<US_WSREMS__Affiliation_Setup_Configuration__mdt> affiliationSetupList = [SELECT Id, MasterLabel, DeveloperName, US_WSREMS__Affiliated_Target_Field__c, US_WSREMS__Affiliation_Parent_Field__c,
                                                                           US_WSREMS__Affiliation_Target_Record_Type__c, US_WSREMS__Affiliation_Source_Record_Type__c,
                                                                           US_WSREMS__Affiliation_Source_Field__c, US_WSREMS__Affiliation_Reference_Field__c, US_WSREMS__Affiliation_Program__c,US_WSREMS__Participant_Type__c,
                                                                           US_WSREMS__Affiliation_Program__r.MasterLabel 
                                                                           FROM US_WSREMS__Affiliation_Setup_Configuration__mdt
                                                                           WHERE US_WSREMS__Affiliation_Source_Record_Type__c = :recordTypeName AND 
                                                                           US_WSREMS__Affiliation_Program__r.MasterLabel = :programName AND US_WSREMS__Participant_Type__c =:participantType];
        
        return affiliationSetupList;
    }

    /********************************************************************************************************************************************************
    * Method Name          : getActiveUserByContactId
    * @Description         : Retrieves the Active user by contactId
    * @CreatedDate         : 28th May 2024
    * @Author              : Mari
    **********************************************************************************************************************************************************/
    public static List<User> getActiveUserByContactId(Id contactId) {
        List<User> activeUser = [SELECT Id, IsActive FROM User WHERE ContactId = :contactId AND IsActive = true];
        return activeUser;
    }
    /********************************************************************************************************************************************************
    * Method Name          : getAccount
    * @Description         : Retrieves the Account by accountid
    * @CreatedDate         : 3rd June 2024
    * @Author              : Rajesh
    **********************************************************************************************************************************************************/
        public static Account getAccount(id GenericRecId){
            return [SELECT id,name,phone,US_WSREMS__Phone_Number__c,US_WSREMS__Record_Type_Name__c,US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Program__r.name,
                    RecordType.name,RecordType.developername 
                    FROM account WHERE id=:GenericRecId];
        }
        /********************************************************************************************************************************************************
    * Method Name          : getCase
    * @Description         : Retrieves the Case by CaseId
    * @CreatedDate         : 3rd June 2024
    * @Author              : Rajesh
    **********************************************************************************************************************************************************/
        public static Case getCase(id GenericRecId){
            return [SELECT id,AccountId,US_WSREMS__Participant__c,recordtype.developername FROM case WHERE id=:GenericRecId];
        }
        /********************************************************************************************************************************************************
    * Method Name          : getTask
    * @Description         : Retrieves the Task by TaskId
    * @CreatedDate         : 3rd June 2024
    * @Author              : Rajesh
    **********************************************************************************************************************************************************/
        public static Task getTask(id GenericRecId){
            return [SELECT id,WhatId FROM task WHERE id=:GenericRecId];
        } 
        /********************************************************************************************************************************************************
    * Method Name          : getAffiliationConfigurationWrap
    * @Description         : Retrieves the Wrapper Affiliation Setup Configuration records
    * @CreatedDate         : 3rd Mar 2024
    * @Author              : Rajesh
    **********************************************************************************************************************************************************/
        public static affiliationSetupConfigurationWrap getAffiliationConfigurationWrap(string accountRecType,String programName){
            affiliationSetupConfigurationWrap cofWrap=new affiliationSetupConfigurationWrap();
            List<US_WSREMS__Affiliation_Setup_Configuration__mdt> affiliationList = new List<US_WSREMS__Affiliation_Setup_Configuration__mdt>();
            affiliationList = [SELECT Id,US_WSREMS__Affiliation_Source_Record_Type__c,US_WSREMS__Account_Record_Type__c,US_WSREMS__Affiliation_Parent_Field__c,
                               US_WSREMS__Affiliated_Target_Field__c 
                               FROM US_WSREMS__Affiliation_Setup_Configuration__mdt
                               WHERE US_WSREMS__Account_Record_Type__c = :accountRecType and US_WSREMS__Affiliation_Program__r.MasterLabel = :programName];
            map<string,US_WSREMS__Affiliation_Setup_Configuration__mdt> mapmeta=new map<string,US_WSREMS__Affiliation_Setup_Configuration__mdt>();
            map<string,set<string>> mapaccounttargetfields=new map<string,set<string>>();
            set<string> targefields=new set<string>();
            set<string> targetFieldsSet=new set<string>();
            for(US_WSREMS__Affiliation_Setup_Configuration__mdt mdt:affiliationList){
                targetFieldsSet.add(mdt.US_WSREMS__Affiliated_Target_Field__c);
                mapmeta.put(mdt.US_WSREMS__Account_Record_Type__c,mdt);
                if(mapaccounttargetfields.containsKey(mdt.US_WSREMS__Affiliation_Parent_Field__c)){
                    targefields= mapaccounttargetfields.get(mdt.US_WSREMS__Affiliation_Parent_Field__c);
                    targefields.add(mdt.US_WSREMS__Affiliated_Target_Field__c);
                    mapaccounttargetfields.put(mdt.US_WSREMS__Affiliation_Parent_Field__c, targefields); 
                } else {
                    targefields= new set<string>();
                    targefields.add(mdt.US_WSREMS__Affiliated_Target_Field__c);
                    mapaccounttargetfields.put(mdt.US_WSREMS__Affiliation_Parent_Field__c, targefields);
                }
            }
            cofWrap.mapmeta=mapmeta;
            cofWrap.targetFieldsSet=targetFieldsSet;
            cofWrap.mapaccounttargetfields=mapaccounttargetfields;
            return cofWrap;
        } 
        public class affiliationSetupConfigurationWrap{
            @AuraEnabled
            public map<string,US_WSREMS__Affiliation_Setup_Configuration__mdt> mapmeta{get;set;}
            @AuraEnabled
            public map<string,set<string>> mapaccounttargetfields{get;set;}
            @AuraEnabled
            public set<string> targetFieldsSet{get;set;}
            public affiliationSetupConfigurationWrap(){
                mapMeta=new map<string,US_WSREMS__Affiliation_Setup_Configuration__mdt>();
                mapaccounttargetfields=new map<string,set<string>>();
                targetFieldsSet=new set<string>();
            }
        }
            /********************************************************************************************************************************************************
    * Method Name          : getDataCalcMapping
    * @Description         : Retrieves the CalculationConfiguration records from Automation Configuration Object
    * @CreatedDate         : 05th Sep 2024
    * @Author              : Wilco Offshore
    **********************************************************************************************************************************************************/
    Public static List<US_WSREMS__Automation_Configuration__c> geteAutomationCalculationRecords(String programName,String participantType,String recordTypeName, string objectName){
        List<US_WSREMS__Automation_Configuration__c> dataCalcConFigList = [SELECT Id, US_WSREMS__REMS_Program__c, US_WSREMS__Case_Record_Type__c, US_WSREMS__Request_Type__c, US_WSREMS__Target_Object__c,US_WSREMS__Source_Field__c,
                                                                    US_WSREMS__Target_Field__c, US_WSREMS__ReferenceField__c, US_WSREMS__LogicType__c ,US_WSREMS__TimeRange__c 
                                                                           FROM US_WSREMS__Automation_Configuration__c
                                                                           WHERE US_WSREMS__Case_Record_Type__c = :recordTypeName AND 
                                                                           US_WSREMS__REMS_Program__r.Name = :programName AND 
                                                                           (US_WSREMS__Request_Type__c = :participantType OR US_WSREMS__Request_Type__c = null) AND 
                                                                           US_WSREMS__Target_Object__c = :objectName AND 
                                                                           US_WSREMS__Record_Type_Name__c = 'Data_Calculation_Configuration'];
        
        return dataCalcConFigList;
    }

    /********************************************************************************************************************************************************
    * Method Name          : getCaseStatusConfigurations
    * @Description         : Retrieves the Case Status Configuration records from Automation Configuration Object
    * @CreatedDate         : 09th Sep 2024
    * @Author              : Wilco Offshore
    **********************************************************************************************************************************************************/
    Public static List<US_WSREMS__Automation_Configuration__c> getCaseStatusConfigurations(Set<String> programNameSet,Set<String> recTypeNameSet,Set<String> statusSet, set<String> outcomeSet,Set<Id> progIdSet){
        List<US_WSREMS__Automation_Configuration__c> caseStatusConfigList = [SELECT Id, US_WSREMS__Object__c, US_WSREMS__Case_Record_Type__c, US_WSREMS__Do_we_need_to_check_incomplete_reason__c, US_WSREMS__REMS_Program__c,US_WSREMS__Incomplete_Reason_Validation_Msg__c,
                                                                    US_WSREMS__Case_Status__c, US_WSREMS__Case_Outcome__c, US_WSREMS__Channel__c,US_WSREMS__Hold_Account__c, US_WSREMS__SendEmailToSponser__c,US_WSREMS__PAENumDays2RemindSponsor__c  FROM  US_WSREMS__Automation_Configuration__c WHERE (US_WSREMS__REMS_Program__c IN : progIdSet
                                                                    OR US_WSREMS__REMS_Program__r.Name IN :programNameSet)
                                                                    AND US_WSREMS__Case_Status__c IN : statusSet AND US_WSREMS__Case_Outcome__c IN : outcomeSet AND US_WSREMS__Case_Record_Type__c in : recTypeNameSet];
        
        return caseStatusConfigList;
    }

    /********************************************************************************************************************************************************
    * Method Name          : getAllCaseConfigurations
    * @Description         : Retrieves the Case Status Configuration records from Automation Configuration Object
    * @CreatedDate         : 09th Sep 2024
    * @Author              : Wilco Offshore
    **********************************************************************************************************************************************************/
    Public static List<US_WSREMS__Automation_Configuration__c> getAllCaseConfigurations(Set<String> programNameSet,Set<String> recTypeNameSet){
        List<US_WSREMS__Automation_Configuration__c> caseStatusConfigList = [SELECT Id, US_WSREMS__Object__c, US_WSREMS__Case_Record_Type__c, US_WSREMS__Do_we_need_to_check_incomplete_reason__c, US_WSREMS__REMS_Program__c,US_WSREMS__Incomplete_Reason_Validation_Msg__c,
                                                                    US_WSREMS__Case_Status__c, US_WSREMS__Case_Outcome__c, US_WSREMS__Channel__c,US_WSREMS__Hold_Account__c  FROM  US_WSREMS__Automation_Configuration__c WHERE US_WSREMS__REMS_Program__r.Name IN :programNameSet
                                                                    AND US_WSREMS__Case_Record_Type__c in : recTypeNameSet
                                                                    AND RecordType.DeveloperName = 'Status_Configuration'];
        
        return caseStatusConfigList;
        }
 /********************************************************************************************************************************************************
    * Method Name          : getAllCaseProgramRecords
    * @Description         : Retrieves the Case Program records for case record
    * @CreatedDate         : 17th Sep 2024
    * @Author              : Wilco Offshore
    **********************************************************************************************************************************************************/
    @AuraEnabled
    Public static Map<String,Id> getAllCaseProgramLinkedToCase(Id caseId,String progName){
        Map<String,Id> caseprogramMap = new Map<String,Id>();
        for(US_WSREMS__CaseProgram__c caseProgObj:[SELECT Id, RecordTypeId FROM US_WSREMS__CaseProgram__c WHERE US_WSREMS__Case__c = :caseId AND US_WSREMS__REMSProgram__r.Name=:progName]){
            caseprogramMap.put(caseProgObj.RecordTypeId,caseProgObj.Id);
        }       
        return caseprogramMap;
    }
      /********************************************************************************************************************************************************
    * Method Name          : getBusinessHoursMap
    * @Description         : Getting the Bussines hours with the Program.
    * @CreatedDate         : 19th Sep 2024
    * @Author              : Wilco Offshore
    **********************************************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,BusinessHours> getBusinessHoursMap(){
        Map<String, BusinessHours> businessHoursMap = new Map<String, BusinessHours>();
        for(BusinessHours bh : [SELECT Id, Name FROM BusinessHours WHERE IsActive = TRUE LIMIT 49999]){
            businessHoursMap.put(bh.Name, bh);
        }
        return businessHoursMap;
    }
     public class objectWrapper{
        @AuraEnabled
        public string objectName{get;set;}
        @AuraEnabled
        public string recordTypeId{get;set;}
        @AuraEnabled
        public string objRecordId{get;set;}
        @AuraEnabled
        public string caseApi{get;set;}
        @AuraEnabled
        public string accountApi{get;set;}
        @AuraEnabled
        public string programApi{get;set;}
        @AuraEnabled
        public Boolean additionalInfoSec{get;set;}
    }

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
         @AuraEnabled
        public String dependentValue{get;set;}
        @AuraEnabled
        public String dependentField{get;set;}
        @AuraEnabled
        public String requestorType{get;set;}
        @AuraEnabled
        public String tittle{get;set;}
        @AuraEnabled
        public String fieldDataType{get;set;}
        @AuraEnabled
        public String inCompleteValue{get;set;}
        @AuraEnabled
        public Boolean additionalFieldValidation{get;set;}
        @AuraEnabled
        public String validationReferenceField{get;set;}
        @AuraEnabled
        public Boolean isUpload{get;set;}
        @AuraEnabled
        public Boolean disableRelatedFields{get;set;}
        @AuraEnabled
        public String validationMsg{get;set;}
         @AuraEnabled
        public Boolean updateRelatedFields{get;set;}
        @AuraEnabled
        public Boolean reParent{get;set;}
        @AuraEnabled
        public String permissionSet{get;set;}
        @AuraEnabled
        public Boolean isParticipant{get;set;}
        @AuraEnabled
        public String referenceObject{get;set;}
        @AuraEnabled
        public String referenceRecType{get;set;}
        @AuraEnabled
        public Boolean additionalSection{get;set;}
        @AuraEnabled
        public String helpText{get;set;}
        @AuraEnabled
        public Boolean isHelpText{get;set;}        
    }
    
 
}