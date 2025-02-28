/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-25-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class REMSUtility { 
    public static Map<String,Id> retrieveRecTypeNameId(String objectName){
        Map<String,Id> recordTypeNameIdMap = new Map<String,Id>();
        String updatedStringName = isCustomObject(objectName) ? OCRREMSAppLiterals.NAMESPACE_STRING+objectName : objectName;
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(updatedStringName).getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = objectSchema.getRecordTypeInfosByName();
        for(String rectypeName:recordTypeInfoMap.keyset()){
            if(recordTypeInfoMap.get(rectypeName).getDeveloperName()!='Master' && !recordTypeInfoMap.get(rectypeName).isMaster())
                recordTypeNameIdMap.put(rectypeName,recordTypeInfoMap.get(rectypeName).getRecordTypeId());            
        }
        return recordTypeNameIdMap;
    }
    
    public static Map<String,Id> retrieveRecTypeDeveloperNameId(String objectName){
        Map<String,Id> recordTypeDevNameIdMap = new Map<String,Id>();
        String updatedStringName = isCustomObject(objectName) ? OCRREMSAppLiterals.NAMESPACE_STRING+objectName : objectName;
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(updatedStringName).getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = objectSchema.getRecordTypeInfosByName();
        for(String rectypeName:recordTypeInfoMap.keyset()){
            if(recordTypeInfoMap.get(rectypeName).getDeveloperName()!='Master' && !recordTypeInfoMap.get(rectypeName).isMaster())
                recordTypeDevNameIdMap.put(recordTypeInfoMap.get(rectypeName).getDeveloperName(),recordTypeInfoMap.get(rectypeName).getRecordTypeId());            
        }
        return recordTypeDevNameIdMap;
    }
    public static Map<String,Id> retrieveRecTypeDeveloperNameId_Product(String objectName){
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
    //This method is added by Dileep Gurram to fetch map of recordId and developername
    public static Map<Id,String> retrieveRecTypeIdDeveloperName_Product(String objectName){
       Map<Id,String> recordTypeDevNameIdMap = new Map<Id,String>();
        String updatedStringName = isCustomObject(objectName) ? OCRREMSAppLiterals.NAMESPACE_STRING+objectName : objectName;
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(updatedStringName).getDescribe();
        List<Schema.RecordTypeInfo> recTypeInfoList = objectSchema.getRecordTypeInfos();
        for(Schema.RecordTypeInfo recTypeInfoObj:recTypeInfoList){
            if(recTypeInfoObj.isAvailable() && recTypeInfoObj.getDeveloperName()!='Master' && !recTypeInfoObj.isMaster())
                recordTypeDevNameIdMap.put(recTypeInfoObj.getRecordTypeId(),recTypeInfoObj.getDeveloperName());            
        }
        return recordTypeDevNameIdMap;
    }
    public static Map<String,Schema.RecordTypeInfo> getRecordTypeNameAndSchema(String objectName){
       Map<String,Schema.RecordTypeInfo> recordTypeDevNameIdMap = new Map<String,Schema.RecordTypeInfo>();
        String updatedStringName = isCustomObject(objectName) ? OCRREMSAppLiterals.NAMESPACE_STRING+objectName : objectName;
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(updatedStringName).getDescribe();
        List<Schema.RecordTypeInfo> recTypeInfoList = objectSchema.getRecordTypeInfos();
        for(Schema.RecordTypeInfo recTypeInfoObj:recTypeInfoList){
            if(recTypeInfoObj.isAvailable() && recTypeInfoObj.getDeveloperName()!='Master' && !recTypeInfoObj.isMaster())
                recordTypeDevNameIdMap.put(recTypeInfoObj.getDeveloperName(),recTypeInfoObj);            
        }
        return recordTypeDevNameIdMap;
    }
    
    
    public static Map<Id,String> retrieveRecTypeIdDeveloperName(String objectName){
        Map<Id,String> recordTypeIdDevNameMap = new Map<Id,String>();
        String updatedStringName = isCustomObject(objectName) ? OCRREMSAppLiterals.NAMESPACE_STRING+objectName : objectName;
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(updatedStringName).getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = objectSchema.getRecordTypeInfosByName();
        for(String rectypeName:recordTypeInfoMap.keyset()){
            if(recordTypeInfoMap.get(rectypeName).getDeveloperName()!='Master' && !recordTypeInfoMap.get(rectypeName).isMaster())
                recordTypeIdDevNameMap.put(recordTypeInfoMap.get(rectypeName).getRecordTypeId(),recordTypeInfoMap.get(rectypeName).getDeveloperName());            
        }
        return recordTypeIdDevNameMap;
    }
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

    public static Boolean isCustomObject (string sObjectNameString) {
        return sObjectNameString.endsWithIgnoreCase('__c');
    }

    public static boolean validateCustomPermission(String customPermissionName){
        return FeatureManagement.checkPermission(customPermissionName);
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