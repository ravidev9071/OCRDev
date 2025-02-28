public class SYN_IncontactUtility {
 public static final String CASE_INFORMATION = 'Case Information';
    public static final String CUSTOM_LINKS = 'Custom Links';
    public static final String TASK = 'Task';
    public static final String REMS_Service = 'US_WSREMS__REMS_Service_Summary__c';
    public static final String Account = 'Account';
   	public static final String Outbound_Communication = 'Outbound_Communication';
    public static final String PHARMACY_REGISTRATION_LAYOUT = 'Case-Pharmacy Registration';
    public static final String PHARMACY_REGISTRATION_ID = 'Pharmacy_Registration';
    public static Map<String,Id> retrieveRecTypeNameId(String objectName){
        Map<String,Id> recordTypeNameIdMap = new Map<String,Id>();
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = objectSchema.getRecordTypeInfosByName();
        for(String rectypeName:recordTypeInfoMap.keyset()){
            if(recordTypeInfoMap.get(rectypeName).isAvailable() && recordTypeInfoMap.get(rectypeName).getDeveloperName()!='Master' && !recordTypeInfoMap.get(rectypeName).isMaster())
                recordTypeNameIdMap.put(rectypeName,recordTypeInfoMap.get(rectypeName).getRecordTypeId());            
        }
        return recordTypeNameIdMap;
    }
}