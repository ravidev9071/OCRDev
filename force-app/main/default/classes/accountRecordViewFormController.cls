/**
* @File Name          : accountRecordViewFormController.cls
* @Description        : This class provides methods to fetch information about a specific record, including its object and record type details,
and additional field values based on configured mappings.
* @TestClass          : accountRecordViewFormControllerTest
* @Author             : Citiustech
* @Modification Log   :
* Ver       Date               Developer                       Modification
* 1.0      16-11-2023            Pavani                 Initial Implementation.
**/
public with sharing class accountRecordViewFormController {
        
    /*********************************************************************************************************************************************************
    * Method Name          : recordViewFormData
    * @Description         : Retrieves information related to a record identified by recordId.
    @param recordId The ID of the record for which data is requested.
    @return A map containing information about the record
    * @CreatedDate         : 16th Nov 2023
    * @Author              : Pavani
    **********************************************************************************************************************************************************/
        @AuraEnabled(cacheable=true)
        public static Map<String, List<REMSUtils.WrapperClass>> recordViewFormData(String recordId,String requestorType, String sourceType) {
            Map<String, List<REMSUtils.WrapperClass>> serviceFieldMap = new Map<String, List<REMSUtils.WrapperClass>>();
            if (String.isBlank(recordId)) {
                return serviceFieldMap;
            }
            
            // To get Object Name
            String objectName = getObjectNameFromRecordId(recordId);
            
            // To get Record Type Name from query
             String queryString = 'SELECT Id, RecordType.DeveloperName FROM ' + objectName + ' WHERE Id = :recordId';
            SObject recordTypeInfo;
            try {
                recordTypeInfo = Database.query(queryString);
            } catch (Exception e) {
                // Handle the exception appropriately
                return serviceFieldMap;
            }
            
            Id recordTypeId = (Id) recordTypeInfo.get('RecordTypeId');
            String recordType = getRecordTypeNameById(objectName, recordTypeId);
            
            List<Account> accList;
            try {
                accList = [SELECT Id, US_WSREMS__Program_Picklist__c, US_WSREMS__REMS_Program__c, US_WSREMS__REMS_Program__r.Name FROM Account WHERE Id = :recordId AND RecordType.DeveloperName = :recordType AND US_WSREMS__Program_Picklist__c != '' LIMIT 1];
            } catch (Exception e) {
                // Handle the exception appropriately
                return serviceFieldMap;
            }
            
            if (accList != null && !accList.isEmpty()) {
                serviceFieldMap = REMSUtils.getData(recordId, objectName, recordType, accList[0].US_WSREMS__Program_Picklist__c, requestorType, sourceType);  
                serviceFieldMap = NewAccountFormCls.getSectionFields(serviceFieldMap);     
            }
            return serviceFieldMap;
        }
        
    /********************************************************************************************************************************************************
    * Method Name          : getRecordTypeNameById
    * @Description         : Gets the record type name for a given object and record type ID
    * @CreatedDate         : 16th Nov 2023
    * @Author              : Pavani
    **********************************************************************************************************************************************************/
        public static String getRecordTypeNameById(String objectName, Id recordTypeId) {
                return REMSUtils.retrieveRecTypeIdDeveloperName(objectName).get(recordTypeId);
        }
    
    /********************************************************************************************************************************************************
    * Method Name          : getObjectNameFromRecordId
    * @Description         : Retrieves the API name of the object associated with a given record ID
    * @CreatedDate         : 16th Nov 2023
    * @Author              : Pavani
    **********************************************************************************************************************************************************/
        
        public static String getObjectNameFromRecordId(Id recordId) {
            String objectApiName = '';
            if (String.isNotBlank(recordId)) {
                objectApiName = recordId.getSObjectType().getDescribe().getName();
            }
            return objectApiName;
        }
        /********************************************************************************************************************************************************
    * Method Name          : recordViewFormData
    * @Description         : Retrieves information related to a record identified by recordId.
    @param recordId        :The ID of the record for which data is requested.
    @return                :A map containing information about the record
    * @CreatedDate         : 1st Dec 2023
    * @Author              : Sukanya
    **********************************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String, List<REMSUtils.WrapperClass>> caseRecordViewFormData(String recordId,String requestorType, String sourceType) {
        Map<String, List<REMSUtils.WrapperClass>> servicesFieldMap = new Map<String, List<REMSUtils.WrapperClass>>();
        
        if (String.isBlank(recordId)) {
            return servicesFieldMap;
        }
        
        // To get Object Name
        String objectApiName = getObjectNameFromRecordId(recordId);
        
        // To get Record Type Name from query
        String queryString = 'SELECT Id, RecordType.DeveloperName FROM ' + objectApiName + ' WHERE Id = :recordId';
        SObject recordTypeInfo;
        try {
            recordTypeInfo = Database.query(queryString);
        } catch (Exception e) {
            // Handle the exception appropriately
            return servicesFieldMap;
        }
        
        Id caseRecordTypeId = (Id) recordTypeInfo.get('RecordTypeId');
        String caseRecordType = getRecordTypeNameById(objectApiName, caseRecordTypeId);
        List<Case> caseList;
        try {
            caseList = [select Id,Status,US_WSREMS__Service_Requestor_Type__c,US_WSREMS__Service_Type__c,US_WSREMS__Program_Name__c,US_WSREMS__Requestor_Type__c,US_WSREMS__Program_Picklist__c,US_WSREMS__REMS_Program__c, US_WSREMS__REMS_Program__r.Name from Case WHERE Id = :recordId];
    
        } catch (Exception e) {
            // Handle the exception appropriately
            return servicesFieldMap;
        }
        
        if (caseList != null && !caseList.isEmpty()) {
            requestorType = caseList[0].US_WSREMS__Service_Requestor_Type__c;
            servicesFieldMap = REMSUtils.getData(recordId, objectApiName, caseRecordType, caseList[0].US_WSREMS__Program_Name__c,requestorType,sourceType);
            servicesFieldMap = NewAccountFormCls.getSectionFields(servicesFieldMap);
        }
            return servicesFieldMap;
    }
        /*****************************************************************************************************************************************************
         * ************************************************************************************************************************************************************************/
        @AuraEnabled
      public static boolean getEnrollmentCaseForAccount (Id accountRecordId,String recordTypeNmae){
        boolean enrollmentExist = false ;
        if(String.isNotBlank(accountRecordId)){
            List<Case> caseList = [SELECT Id , US_WSREMS__Participant__c FROM Case WHERE US_WSREMS__Participant__c = : accountRecordId AND RecordType.DeveloperName =: recordTypeNmae];
            if(caseList.size() > 0){
               enrollmentExist = true ;
            }
        }
        return enrollmentExist ;
    }
    }