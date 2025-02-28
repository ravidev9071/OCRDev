public class SYN_REMSBigObjectDataInsertProcess
{
    public static void processInfo(list<sobject> lstObjData, string objectAPIName, string dataActionType)
    {
        map<string,BigObject_Data_Process_Setings__c> mapSettings = new map<string,BigObject_Data_Process_Setings__c>();
        string sourceObjApi;
        string targetObjApi;
        string masterSettingsId;
        for(BigObject_Data_Process_Setings__c bigSettings: [select Active__c, Active_Mapping_Process__c, Source_Object_API_Name__c, Source_Object_Name__c, Target_Object_API_Name__c, Target_Object_Name__c from BigObject_Data_Process_Setings__c where Active__c=:true])
        {
            if(bigSettings.Source_Object_API_Name__c == objectAPIName && bigSettings.active__c==True)
            {
               mapSettings.put(bigSettings.Source_Object_API_Name__c,bigSettings);
               masterSettingsId = bigSettings.id;
                
                
               sourceObjApi =  bigSettings.Source_Object_API_Name__c;
               targetObjApi =  bigSettings.Target_Object_API_Name__c;
                
            }
        }
        map<string,BigObject_Field_Mapping__c> mapFieldMapping = new map<string,BigObject_Field_Mapping__c>();
        list<BigObject_Field_Mapping__c> lstFieldMapping = new list<BigObject_Field_Mapping__c>();
        
        for(BigObject_Field_Mapping__c fieldMap: [select Source_Field_API__c, Target_Field_API__c, IsDefault_Data_Type__c, Active__c, BigObject_Data_Process_Setings__c from BigObject_Field_Mapping__c where BigObject_Data_Process_Setings__c=:masterSettingsId and active__c=:true])
        {
            lstFieldMapping.add(fieldMap);
        }
        list<sObject> lstTargetData = new list<sObject>();
        if(!string.isBlank(sourceObjApi) && !string.isBlank(targetObjApi))
        {
            Type typSObject = Type.forName(targetObjApi); 
            Type typLstSObject = Type.ForName('List<' + targetObjApi + '>');
            lstTargetData = (List<SObject>)typLstSObject.NewInstance();
        
            for(sobject updatedData: lstObjData)
            {
                sObject targetData = Schema.getGlobalDescribe().get(targetObjApi).newSObject();
                for(BigObject_Field_Mapping__c fieldMap: lstFieldMapping)
                {
                    if(!string.isBlank(fieldMap.Source_Field_API__c) && !string.isBlank(fieldMap.Target_Field_API__c))
                    {
                        if(fieldMap.IsDefault_Data_Type__c==True)
                        {
                            if(string.valueOf(updatedData.get(fieldMap.Source_Field_API__c))!=null && !string.isBlank(string.valueOf(updatedData.get(fieldMap.Source_Field_API__c))))
                            {
                                targetData.put(fieldMap.Target_Field_API__c, updatedData.get(fieldMap.Source_Field_API__c));
                            }
                        }
                        else
                        {
                            If(fieldMap.Target_Field_API__c=='SystemModstampExId__c')
                            {
                                if(string.valueOf(updatedData.get(fieldMap.Source_Field_API__c))!=null && !string.isBlank(string.valueOf(updatedData.get(fieldMap.Source_Field_API__c))))
                                {
                                    targetData.put(fieldMap.Target_Field_API__c, string.valueOf(updatedData.id+''+updatedData.get(fieldMap.Source_Field_API__c)));
                                    system.debug('------external ID----'+updatedData.id);
                                }    
                            }
                            else
                            If(fieldMap.Target_Field_API__c=='SystemModstampActionType__c')
                            {
                                if(string.valueOf(updatedData.get(fieldMap.Source_Field_API__c))!=null && !string.isBlank(string.valueOf(updatedData.get(fieldMap.Source_Field_API__c))))
                                {
                                    system.debug('------Action Type----'+dataActionType);
                                    targetData.put(fieldMap.Target_Field_API__c, dataActionType);
                                }    
                            }
                            else
                            if(string.valueOf(updatedData.get(fieldMap.Source_Field_API__c))!=null && !string.isBlank(string.valueOf(updatedData.get(fieldMap.Source_Field_API__c))))
                            {
                                targetData.put(fieldMap.Target_Field_API__c, string.valueOf(updatedData.get(fieldMap.Source_Field_API__c)));
                            }
                            
                        }
                    }
                }
                lstTargetData.add(targetData);
            }    
        }
        if(!lstTargetData.isEmpty() && !Test.isRunningTest())
        {
            database.insertImmediate(lstTargetData);
        }
        
    }
}