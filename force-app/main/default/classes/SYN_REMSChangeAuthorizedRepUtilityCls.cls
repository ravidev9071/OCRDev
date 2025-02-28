public class SYN_REMSChangeAuthorizedRepUtilityCls {
public static final String CASE_INFORMATION = 'Case Information';
    public static final String CUSTOM_LINKS = 'Custom Links';
    public static final String CHANGE_AUTHORIZED_REPRESENTATIVE_LAYOUT = System.Label.US_WSREMS.Change_Authorized_Representative_Layout; //Case-US_WSREMS__Change Authorized Representative 
    public static final String CHANGE_AUTHORIZED_REPRESENTATIVE_ID = 'Change_Authorized_Representative';
    public static Map<String,Id> retrieveRecTypeNameId(String objectName){
        Map<String,Id> recordTypeNameIdMap = new Map<String,Id>();
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(SYN_AppLiterals.NAMESPACE_STRING+objectName).getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = objectSchema.getRecordTypeInfosByName();
        for(String rectypeName:recordTypeInfoMap.keyset()){
            if(recordTypeInfoMap.get(rectypeName).isAvailable() && recordTypeInfoMap.get(rectypeName).getDeveloperName()!='Master' && !recordTypeInfoMap.get(rectypeName).isMaster())
                recordTypeNameIdMap.put(rectypeName,recordTypeInfoMap.get(rectypeName).getRecordTypeId());            
        }
        return recordTypeNameIdMap;
    }
}