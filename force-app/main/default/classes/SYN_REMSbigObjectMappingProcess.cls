public class SYN_REMSbigObjectMappingProcess
{
        public static void processInfo(string objectAPIName)
        {
            map<string,BigObject_Data_Process_Setings__c> mapSettings = new map<string,BigObject_Data_Process_Setings__c>();
            string sourceObjApi;
            string targetObjApi;
            //if(!lstBODPS.isEmpty() && !lstBODPS.isEmpty())
            {
                for(BigObject_Data_Process_Setings__c bigSettings: [select Active__c, Active_Mapping_Process__c, Source_Object_API_Name__c, Source_Object_Name__c, Target_Object_API_Name__c, Target_Object_Name__c from BigObject_Data_Process_Setings__c where Source_Object_API_Name__c=:objectAPIName and Active__c=:true])
                {
                    if(bigSettings.Source_Object_API_Name__c == objectAPIName && bigSettings.active__c==True)
                    {
                       mapSettings.put(bigSettings.Source_Object_API_Name__c,bigSettings);
                       sourceObjApi =  bigSettings.Source_Object_API_Name__c;
                       targetObjApi =  bigSettings.Target_Object_API_Name__c;  
                    }
                }
            }
            if(!string.isBlank(sourceObjApi) && !string.isBlank(targetObjApi))
            {
                map<string,Schema.DescribeFieldResult> mapSourceFields = new map<string,Schema.DescribeFieldResult>();
                if(!string.isBlank(sourceObjApi))
                {
                    SObjectType objectType = Schema.getGlobalDescribe().get(sourceObjApi);
                    Schema.DescribeSObjectResult ob = objectType.getDescribe();
                    List<Schema.SObjectField>  sObjectFields = SYN_REMSBigObjectMetaDataService.getObjectFields(objectAPIName);
                    for(Schema.SObjectField ft : sObjectFields)
                    {
                        Schema.DescribeFieldResult fd = ft.getDescribe();
                        mapSourceFields.put(fd.getName(),fd);
                    }
                }
                map<string,Schema.DescribeFieldResult> mapTargetFields = new map<string,Schema.DescribeFieldResult>();
                if(!string.isBlank(targetObjApi))
                {
                    system.debug('------targetObjApi-------'+targetObjApi);
                    SObjectType objectType = Schema.getGlobalDescribe().get(sourceObjApi);
                    Schema.DescribeSObjectResult ob = objectType.getDescribe();
                    List<Schema.SObjectField>  sObjectFields = SYN_REMSBigObjectMetaDataService.getObjectFields(targetObjApi);
                    for(Schema.SObjectField ft : sObjectFields)
                    {
                        Schema.DescribeFieldResult fd = ft.getDescribe();
                        mapTargetFields.put(fd.getName(),fd);
                    }
                }
                
                Map<string,string> mapPackagePrefix = new map<string,string>();
                for(SYN_REMSBigObjectPrefixNames__mdt bigPrefix : SYN_REMSBigObjectPrefixNames__mdt.getAll().values())
                {
                    system.debug('-----bigPrefix.Package_Prefix__c----'+bigPrefix.Package_Prefix__c);
                    mapPackagePrefix.put(bigPrefix.Package_Prefix__c, bigPrefix.Package_Prefix__c);
                }
                
                list<BigObject_Field_Mapping__c > lstBigMappingFieldsData = new list<BigObject_Field_Mapping__c >();
                if(!mapSourceFields.isEmpty() && !mapTargetFields.isEmpty())
                {
                    for(string keyValue : mapSourceFields.KeySet())
                    {
                        string targetKeyValue;
                        if(keyValue.Contains('__c'))
                        {
                            targetKeyValue = keyValue;
                        }
                        else
                        {
                            targetKeyValue = keyValue+''+'__c';
                        }
                        
                        for(string prefixValue: mapPackagePrefix.KeySet())
                        {
                            system.debug('-----prefixValue----'+prefixValue);
                            if(targetKeyValue.Contains(prefixValue))
                            {
                               targetKeyValue = targetKeyValue.remove(prefixValue); 
                               system.debug('-----targetKeyValue----'+targetKeyValue);
                            }
                        }
                        
                        BigObject_Field_Mapping__c mapFieldValues = new BigObject_Field_Mapping__c();
                        mapFieldValues.BigObject_Data_Process_Setings__c = mapSettings.get(sourceObjApi).id;
                        mapFieldValues.Source_Field_API__c = keyValue;
                        mapFieldValues.Active__c = True;
                        if(mapTargetFields.KeySet().Contains(targetKeyValue))
                        {
                            mapFieldValues.Target_Field_API__c = targetKeyValue; 
                            if(mapSourceFields.get(keyValue).getType() == mapTargetFields.get(targetKeyValue).getType())
                            {
                                mapFieldValues.IsDefault_Data_Type__c = True;
                            }   
                        }
                        lstBigMappingFieldsData.add(mapFieldValues);
                        if(keyValue=='SystemModstamp')
                        {
                            BigObject_Field_Mapping__c mapExterValues = new BigObject_Field_Mapping__c();
                            mapExterValues.BigObject_Data_Process_Setings__c = mapSettings.get(sourceObjApi).id;
                            mapExterValues.Source_Field_API__c = keyValue;
                            mapExterValues.Active__c = True;
                            string externalFieldValue = keyValue+''+'ExId__c';
                            if(mapTargetFields.KeySet().Contains(externalFieldValue))
                            {
                                mapExterValues.Target_Field_API__c = externalFieldValue; 
                                mapExterValues.IsRequired_Field__c = True; 
                                mapExterValues.IsDefault_Data_Type__c = False;
                            }
                            lstBigMappingFieldsData.add(mapExterValues);
                            
                            BigObject_Field_Mapping__c mapExterValues2 = new BigObject_Field_Mapping__c();
                            mapExterValues2.BigObject_Data_Process_Setings__c = mapSettings.get(sourceObjApi).id;
                            mapExterValues2.Source_Field_API__c = keyValue;
                            mapExterValues2.Active__c = True;
                            string externalFieldValue2 = keyValue+''+'ActionType__c';
                            if(mapTargetFields.KeySet().Contains(externalFieldValue2))
                            {
                                mapExterValues2.Target_Field_API__c = externalFieldValue2; 
                                mapExterValues2.IsRequired_Field__c = True; 
                                mapExterValues2.IsDefault_Data_Type__c = False;
                            }
                            lstBigMappingFieldsData.add(mapExterValues2);
                            
                            
                        }
                        
                    }
                }
                if(!lstBigMappingFieldsData.isEmpty())
                {
                   database.insert(lstBigMappingFieldsData,false);
                }
            }
            
            
        } 
}