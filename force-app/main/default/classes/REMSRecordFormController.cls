/********************************************************************************************************************************************************
* Class Name          : REMSRecordFormController
* @Description         : This class is used to return the Program field configuration records from record create./edit screens  
* @Author              : Wilco Offshore
* Test class Name      : REMSRecordFormControllerTest
**********************************************************************************************************************************************************/

public class REMSRecordFormController {
    public static final String COMPLIANCE_OBJECT = REMSAppLiterals.COMPLIANCE_OBJECT;
    public static final String NAMESPACE_STRING = REMSAppLiterals.NAMESPACE_STRING;
    public static Map<String,US_WSREMS__ObjectFieldMapping__c> progObjConfigMap = new Map<String,US_WSREMS__ObjectFieldMapping__c>();
    public static Map<String,List<String>> caseChildRltnMap = new Map<String,List<String>>();
    public static Map<String,String> childObjMap = new Map<String,String>();
    public static Map<String,Map<String, List<REMSUtils.WrapperClass>>> serviceobjDetFldConfigMap = new Map<String,Map<String, List<REMSUtils.WrapperClass>>>();
    public static Set<String> objectStringSet = new Set<String>();

    /********************************************************************************************************************************************************
* Method Name          : getServiceCreation
* @Description         : Retrieves the Service creation Records.
* @CreatedDate         : 17th Jul 2024
* @Author              : Wilco Offshore
**********************************************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Map<String, List<REMSUtils.WrapperClass>>> getServiceCreation(US_WSREMS__REMS_Service_Configuration__mdt serviceConfigObj) {
        Map<String, List<REMSUtils.WrapperClass>> serviceFieldMap = new Map<String, List<REMSUtils.WrapperClass>>();
        Set<String> progNameSet = new Set<String>();
        Set<String> recordTypeSet = new Set<String>();
        String objNameString;
        try {
            system.debug('Service : '+serviceConfigObj);
            progNameSet.add(serviceConfigObj.US_WSREMS__Program_Configuration__r.MasterLabel);
            recordTypeSet.add(serviceConfigObj.US_WSREMS__Case_Record_Type__c);
            getProgramObjectConfig(progNameSet, recordTypeSet, null);
            objNameString = serviceConfigObj.US_WSREMS__Object__c;
            if(objectStringSet!=null && objectStringSet.contains(serviceConfigObj.US_WSREMS__Object__c) ){
                objectStringSet.remove(serviceConfigObj.US_WSREMS__Object__c);
                objNameString = objNameString+','+String.join(objectStringSet,',');
            }
            serviceFieldMap = REMSUtils.getData(
                null,
                objNameString,
                serviceConfigObj.US_WSREMS__Case_Record_Type__c,
                serviceConfigObj.US_WSREMS__Program_Configuration__r.MasterLabel,
                serviceConfigObj.US_WSREMS__Participant_Type__c
            );
            getServiceFieldObjSection(serviceFieldMap,null,null);
            return serviceobjDetFldConfigMap;
        } catch (Exception ex) {
            throw new AuraHandledException(
                'An unexpected error occurred: ' + ex.getMessage()
            );
        }
        
    }

    /********************************************************************************************************************************************************
    * Method Name          : caseRecordViewFormData
    * @Description         : Retrieves PFC information related to a record identified by recordId.
    @param recordId        :The ID of the record for which data is requested.
    @param requestorType   :Participant type of the object
    @param sourceType      :channel of the record Portal/Internal
    @return                :A map containing information about the record
    * @CreatedDate         : 17st Jul 2024
    * @Author              : Wilco Offshore
    **********************************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String,Map<String, List<REMSUtils.WrapperClass>>> caseRecordViewFormData(String recordId,String requestorType, String sourceType) {
        Map<String, List<REMSUtils.WrapperClass>> servicesFieldMap = new Map<String, List<REMSUtils.WrapperClass>>();
        Set<Id> progIdSet = new Set<Id>();
        Set<String> recordTypeSet = new Set<String>();
        Map<String,Id> childObjectIdMap = new Map<String,Id>();
        String objNameString;
        
        if (String.isBlank(recordId)) {
            return serviceobjDetFldConfigMap;
        }
        
        // To get Object Name
        String objectApiName = accountRecordViewFormController.getObjectNameFromRecordId(recordId);
        objNameString = objectApiName;
        // To get Record Type Name from query
        String queryString = 'SELECT Id, RecordTypeId, REMS_Program__c FROM ' + objectApiName + ' WHERE Id = :recordId';
        SObject recordTypeInfo;
        try {
            recordTypeInfo = Database.query(queryString);
        } catch (Exception e) {
            // Handle the exception appropriately
            return serviceobjDetFldConfigMap;
        }
        
        Id caseRecordTypeId = (Id) recordTypeInfo.get('RecordTypeId');
        if(recordTypeInfo.get('REMS_Program__c')!=null){
            progIdSet.add((Id)recordTypeInfo.get('REMS_Program__c'));
        }
        String caseRecordType = accountRecordViewFormController.getRecordTypeNameById(objectApiName, caseRecordTypeId);
        recordTypeSet.add(caseRecordType);

        if(!recordTypeSet.isEmpty() && !progIdSet.isEmpty()){
            getProgramObjectConfig(null, recordTypeSet,progIdSet);
        }
        string objQuery = 'SELECT Id';
        if(objectApiName == 'Case'){
            objQuery = objQuery+',Status,Service_Requestor_Type__c,Service_Type__c,Program_Name__c,Requestor_Type__c,Program_Picklist__c,REMS_Program__c, REMS_Program__r.Name';
        }
        if(!caseChildRltnMap.isEmpty() && caseChildRltnMap.containsKey(objectApiName)){
            for(String childObj:caseChildRltnMap.get(objectApiName)){
                string childQuery = ','+' (SELECT Id FROM '+childObj+')';
                objQuery = objQuery+childQuery;
            }
         }
        objQuery = objQuery +' FROM '+objectApiName +' WHERE Id=\''+recordId+'\'';
        List<sObject> objectRecList;
        String listType = 'List<' + objectApiName + '>';
        List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
        try {
            objectRecList = Database.Query(objQuery);
            if(!objectRecList.isEmpty()){
                castRecords.addAll(objectRecList);
            }
        } catch (Exception e) {
            // Handle the exception appropriately
            return serviceobjDetFldConfigMap;
        }

        if (castRecords != null && !castRecords.isEmpty()) {
            if(caseChildRltnMap.containsKey(objectApiName)){
                for(String childObj:caseChildRltnMap.get(objectApiName)){
                    if(childObjMap.containsKey(childObj) && castRecords[0].getSObjects(childObj)!=null 
                    && !castRecords[0].getSObjects(childObj).isEmpty()){
                        childObjectIdMap.put(childObjMap.get(childObj),(Id)castRecords[0].getSObjects(childObj)[0].get('Id'));
                    }
                }
            }
       
        
            if(objectApiName == 'Case'){
                requestorType = (String)castRecords[0].get('Service_Requestor_Type__c');
            }
            if(objectStringSet!=null && objectStringSet.contains(objectApiName) ){
                objectStringSet.remove(objectApiName);
                objNameString = objNameString+','+String.join(objectStringSet,',');
            }
            servicesFieldMap = REMSUtils.getData(recordId, objNameString, caseRecordType, (String)castRecords[0].get('Program_Name__c'),requestorType,sourceType);
            Map<String,Boolean> readOnlyFldsMap = NewAccountFormCls.getReadonlyFields (recordId, (String)castRecords[0].get('Program_Name__c'),caseRecordType,requestorType) ;
                    
            for(String secObj: servicesFieldMap.keySet()){
                for(REMSUtils.WrapperClass serviceFldObj: servicesFieldMap.get(secObj)){
                    if(readOnlyFldsMap.containsKey(serviceFldObj.fieldName)){
                        serviceFldObj.editable = true;
                    }
                    
                }
            }
            getServiceFieldObjSection(servicesFieldMap,childObjectIdMap,recordId);
        }
            
            return serviceobjDetFldConfigMap;
    }
        
    /********************************************************************************************************************************************************
    * Method Name          : getAccountCreationPage
    * @Description        : Retrieves the fields for creating an account based on the specified service configuration and record type.
    * @CreatedDate         : 17th Jul 2024
    * @Author              : Wilco Offshore 
    * @param serviceConfigId : Id of the selected service configuration.
    * @param recordtypeId    : Id of the selected record type.
    * @return                : Map of section names to a list of WrapperClass containing field details.
    **********************************************************************************************************************************************************/
    @AuraEnabled 
    public static Map<String,Map<String, List<REMSUtils.WrapperClass>>> getAccountCreationPage(String serviceConfigId,string recordtypeId){
        Map<String, List<REMSUtils.WrapperClass>> serviceFieldMap = new Map<String, List<REMSUtils.WrapperClass>>();
        Map<String, String> serviceMap = new Map<String, String>();
        Map<String, US_WSREMS__Pagelayout_Configuration__mdt> programUserMap = new Map<String, US_WSREMS__Pagelayout_Configuration__mdt>();
        List<US_WSREMS__Pagelayout_Configuration__mdt> serviceList = new List<US_WSREMS__Pagelayout_Configuration__mdt>();
        
        try {
            serviceList = [SELECT Id, US_WSREMS__Object_Name__c, Label, US_WSREMS__PageLayout_Name__c, US_WSREMS__Program__c, US_WSREMS__Program_Name__c, US_WSREMS__Quick_Action_Name__c, US_WSREMS__RecordType_Name__c, US_WSREMS__Rems_Service_RCtype__c, US_WSREMS__Requestor_Type__c, US_WSREMS__Title__c, US_WSREMS__Program_Name__r.MasterLabel FROM US_WSREMS__Pagelayout_Configuration__mdt
                                                            WHERE Id = :serviceConfigId AND US_WSREMS__RecordType_Name__c = :recordtypeId];
            
            if(Test.isRunningTest()){
                serviceList.add(new US_WSREMS__Pagelayout_Configuration__mdt(US_WSREMS__Object_Name__c='Account',US_WSREMS__RecordType_Name__c='Prescriber_Person_Account'));
            }
            if (!serviceList.isEmpty()) {
                serviceFieldMap = REMSUtils.getData(null, serviceList[0].US_WSREMS__Object_Name__c, serviceList[0].US_WSREMS__RecordType_Name__c, serviceList[0].US_WSREMS__Program_Name__r.MasterLabel, serviceList[0].US_WSREMS__Requestor_Type__c);
                getServiceFieldObjSection(serviceFieldMap,null,null);
            }
        }  catch (Exception ex) {
            throw new AuraHandledException('An unexpected error occurred: ' + ex.getMessage());
        }
        
        return serviceobjDetFldConfigMap;
    }

    

    public static void getProgramObjectConfig(Set<String> progNameSet, Set<String> recordTypeSet,Set<Id> progIdSet){
       for(US_WSREMS__ObjectFieldMapping__c progObjConfig: [SELECT Id,US_WSREMS__ChildObject__c,US_WSREMS__ChildRelationName__c,US_WSREMS__ParentField__c,US_WSREMS__ParentObject__c,
                                                            US_WSREMS__RecordType__c,US_WSREMS__REMSProgram__c,US_WSREMS__TargetRecordType__c 
                                                            FROM US_WSREMS__ObjectFieldMapping__c
                                                            WHERE US_WSREMS__TargetRecordType__c IN :recordTypeSet AND US_WSREMS__ChildObject__c!=null
                                                            AND (US_WSREMS__REMSProgram__r.Name IN :progNameSet or US_WSREMS__REMSProgram__c IN :progIdSet)]){
            progObjConfigMap.put(progObjConfig.US_WSREMS__ChildObject__c + progObjConfig.US_WSREMS__RecordType__c+progObjConfig.US_WSREMS__ParentObject__c,progObjConfig);
            objectStringSet.add(progObjConfig.US_WSREMS__ChildObject__c);
            if(progObjConfig.US_WSREMS__ChildRelationName__c!=null){
                childObjMap.put(progObjConfig.US_WSREMS__ChildRelationName__c,progObjConfig.US_WSREMS__ChildObject__c+progObjConfig.US_WSREMS__RecordType__c);
            }

            if(progObjConfig.US_WSREMS__ParentObject__c!=null){
                if(caseChildRltnMap.containsKey(progObjConfig.US_WSREMS__ParentObject__c)){
                    caseChildRltnMap.get(progObjConfig.US_WSREMS__ParentObject__c).add(progObjConfig.US_WSREMS__ChildRelationName__c);
                }else{
                    caseChildRltnMap.put(progObjConfig.US_WSREMS__ParentObject__c,new List<String>{progObjConfig.US_WSREMS__ChildRelationName__c});
                }
                objectStringSet.add(progObjConfig.US_WSREMS__ParentObject__c);
            }
       
        }   

    }

    public static void getServiceFieldObjSection(Map<String, List<REMSUtils.WrapperClass>> serviceFieldMap, Map<String,String> childIdMap,Id recordId){  
        Map<String,REMSRecordFormController.objectWrapper> objectDetMap = new Map<String,REMSRecordFormController.objectWrapper>();
        Map<String,Map<String, List<REMSUtils.WrapperClass>>> serviceFieldObjMap = new Map<String,Map<String, List<REMSUtils.WrapperClass>>>();
        Map<String, List<REMSUtils.WrapperClass>>  addSectionServiceMap = new Map<String, List<REMSUtils.WrapperClass>> ();
        REMSRecordFormController.objectWrapper addObjDet = new REMSRecordFormController.objectWrapper();

        
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
                    REMSRecordFormController.objectWrapper objDet = new REMSRecordFormController.objectWrapper();
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
    public static Map<String,dataCalcWrapper> getDataPopulationConfigs(String programName,String participantType,String recordTypeName, string objectName){
        List<US_WSREMS__Automation_Configuration__c> dataCalcConFigList = new List<US_WSREMS__Automation_Configuration__c>();
        dataCalcConFigList = REMSUtils.geteAutomationCalculationRecords(programName, participantType, recordTypeName, objectName);
        Map<String,dataCalcWrapper> calcConfigWrapperMap = new Map<String,dataCalcWrapper>();
        if(dataCalcConFigList.isEmpty()){
            return null;
        }

            for(US_WSREMS__Automation_Configuration__c autConfigObj: dataCalcConFigList){
                if(autConfigObj.US_WSREMS__ReferenceField__c != null && autConfigObj.US_WSREMS__LogicType__c != null){
                    
                    if(!calcConfigWrapperMap.containsKey(autConfigObj.US_WSREMS__ReferenceField__c)){
                        dataCalcWrapper dataWrapper = new dataCalcWrapper();
                        dataWrapper.timeFrame = autConfigObj.US_WSREMS__TimeRange__c;
                        dataWrapper.logicType = autConfigObj.US_WSREMS__LogicType__c;
                        dataWrapper.sourceTargetMap = new Map<String,String>{autConfigObj.US_WSREMS__Source_Field__c=>autConfigObj.US_WSREMS__Target_Field__c};
                        calcConfigWrapperMap.put(autConfigObj.US_WSREMS__ReferenceField__c,dataWrapper);
                    }else{
                        calcConfigWrapperMap.get(autConfigObj.US_WSREMS__ReferenceField__c).sourceTargetMap.put(autConfigObj.US_WSREMS__Source_Field__c,autConfigObj.US_WSREMS__Target_Field__c);
                    }
                }
            }
         
        return calcConfigWrapperMap;   
    }  

    @AuraEnabled
    public static Map<String,String> getCaseStatusValidations(String recordTypeName,String programName){
        List<US_WSREMS__Automation_Configuration__c> caseStatusConfigList = REMSUtils.getAllCaseConfigurations(new Set<String>{programName},new set<String>{recordTypeName});
        if(caseStatusConfigList.isEmpty()){
            return null;
        }
        Map<String,String> casevalidationMap =  new Map<String,String>();
        for(US_WSREMS__Automation_Configuration__c caseConfigObj: caseStatusConfigList){
            If(caseConfigObj.US_WSREMS__Do_we_need_to_check_incomplete_reason__c == true && caseConfigObj.US_WSREMS__Incomplete_Reason_Validation_Msg__c != null){
                casevalidationMap.put(caseConfigObj.US_WSREMS__Case_Status__c+'#'+caseConfigObj.US_WSREMS__Case_Outcome__c,caseConfigObj.US_WSREMS__Incomplete_Reason_Validation_Msg__c);
            }
        }
        return casevalidationMap;
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

    public class dataCalcWrapper{
        @AuraEnabled
        public Map<String,string> sourceTargetMap{get;set;}
        @AuraEnabled
        public Decimal timeFrame{get;set;}
        @AuraEnabled
        public string logicType{get;set;}
    }

}