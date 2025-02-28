/*
Author : Wilcosource
*/

public with sharing class REMSUtilitycls {
    public static final String CASE_INFORMATION = 'Case Information';
    public static final String CUSTOM_LINKS = 'Custom Links';
    public static final String PHARMACY_REGISTRATION_ID = 'Pharmacy_Registration';
    public static Map<String,Id> retrieveRecTypeNameId(String objectName){
        Map<String,Id> recordTypeNameIdMap = new Map<String,Id>();
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(REMSAppLiterals.NAMESPACE_STRING+objectName).getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = objectSchema.getRecordTypeInfosByName();
        for(String rectypeName:recordTypeInfoMap.keyset()){
            if(recordTypeInfoMap.get(rectypeName).isAvailable() && recordTypeInfoMap.get(rectypeName).getDeveloperName()!='Master' && !recordTypeInfoMap.get(rectypeName).isMaster())
                recordTypeNameIdMap.put(rectypeName,recordTypeInfoMap.get(rectypeName).getRecordTypeId());            
        }
        return recordTypeNameIdMap;
    }
}