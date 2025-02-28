/**
 * @Class             : REMSBigObjectMetaDataService
 * @description       : Class to create big object metadata based on custom object metadata values
 * @author            : bhaskar
 * @group             : 
 * @last modified on  : 01-27-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SYN_REMSBigObjectMetaDataService
{
    
    public static void createBigObjectMetadata(String objectAPIName)
    {

        MetadataService.MetadataPort service = new MetadataService.MetadataPort();  
        service.SessionHeader = new MetadataService.SessionHeader_element();  
        service.SessionHeader.sessionId = UserInfo.getSessionId();  
        
        //AllOrNoneHeader is mandatory for Big Object  
        service.AllOrNoneHeader = new MetadataService.AllOrNoneHeader_element();  
        service.AllOrNoneHeader.allOrNone = true; //this is required for Big Objects  
        
        //collect defined packages installed prefix values
        Map<string,string> mapPackagePrefix = new map<string,string>();
        for(SYN_REMSBigObjectPrefixNames__mdt bigPrefix : SYN_REMSBigObjectPrefixNames__mdt.getAll().values())
        {
            system.debug('-----bigPrefix.Package_Prefix__c----'+bigPrefix.Package_Prefix__c);
            mapPackagePrefix.put(bigPrefix.Package_Prefix__c, bigPrefix.Package_Prefix__c);
        }
        
        //define Big Object  
        String bigObjectAPIName = objectAPIName.removeEnd('__c')+'BigObject';
        for(string prefixValue: mapPackagePrefix.KeySet())
        {
            system.debug('-----prefixValue----'+prefixValue);
            if(bigObjectAPIName.Contains(prefixValue))
            {
               bigObjectAPIName = bigObjectAPIName.remove(prefixValue); 
               system.debug('-----bigObjectAPIName----'+bigObjectAPIName);
            }
        }
        MetadataService.CustomObject bigObject = new MetadataService.CustomObject();  
        bigObject.fullName = bigObjectAPIName+'__b';  
        bigObject.label = bigObjectAPIName;  
        bigObject.pluralLabel = bigObjectAPIName;  
        bigObject.deploymentStatus = 'Deployed'; //Make it Deployed if you need
        
        List<MetadataService.CustomField> lstCustomFields = new List<MetadataService.CustomField>();  
        
        //define Text Field  
        List<Schema.SObjectField>  sObjectFields = getObjectFields(objectAPIName);

        list<string> fieldAPINames = new list<string>();
        
        Map<String, String> mapBigObjectBlockList = new Map<string,string>();
        for(SYN_REMSBigObjectFieldsBlockList__mdt bigobjBlockList: SYN_REMSBigObjectFieldsBlockList__mdt.getAll().values())
        {
            mapBigObjectBlockList.put(bigobjBlockList.API_Name__c, bigobjBlockList.API_Name__c);
        }
        
        for (Schema.SObjectField ft : sObjectFields)
        { 
            Schema.DescribeFieldResult fd = ft.getDescribe();
            if(!mapBigObjectBlockList.KeySet().Contains(fd.getName()))
            {
                MetadataService.CustomField fieldObj = new MetadataService.CustomField();  
                system.debug('------------'+fd.getLabel());
                fieldObj.label = fd.getLabel();
                system.debug('------------'+fd.getName());
                if(string.valueOf(fd.getName()).contains('__c'))
                {
                    fieldObj.fullName = fd.getName();  
                    for(string prefixValue: mapPackagePrefix.KeySet())
                    {
                        system.debug('-----prefixValue------'+prefixValue);
                        if(fd.getName().Contains(prefixValue))
                        {
                            fieldObj.fullName = fd.getName().remove(prefixValue);    
                            system.debug('-----fieldObj.fullName------'+fieldObj.fullName);
                        }
                        system.debug('-----fieldObj.fullName------'+fieldObj.fullName);
                    }
                }
                else
                {
                    fieldObj.fullName = fd.getName()+''+'__c'; 
                    for(string prefixValue: mapPackagePrefix.KeySet())
                    {
                        
                        if(fieldObj.fullName.Contains(prefixValue))
                        {
                            fieldObj.fullName = fieldObj.fullName.remove(prefixValue);    
                        }
                        system.debug('-----fieldObj.fullName------'+fieldObj.fullName);
                    } 
                }
                 string objectRelation;
                if(!string.isBlank(string.valueOf(fd.getReferenceTo())))
                {
                    for(Schema.SObjectType objRe: fd.getReferenceTo())
                    {
                        objectRelation = string.valueOf(objRe);
                    }
                }
                system.debug('----fd.getType()--------'+fd.getType());
                system.debug('----fd.getLength()--------'+fd.getLength());
                
                if(string.valueOf(fd.getType())=='REFERENCE' && objectRelation!='RecordType')
                {
                    fieldObj.type_x = 'Lookup'; 
                    fieldObj.referenceTo = objectRelation;
                    if(!string.isBlank(string.valueOf(fd.getRelationshipName())))
                    {
                        fieldObj.relationshipLabel = string.valueOf(fd.getRelationshipName());
                    }
                    else
                    {
                        fieldObj.relationshipLabel = objectRelation;
                    }
                    fieldObj.relationshipName = bigObjectAPIName; 
                }
                else
                if(string.valueOf(fd.getType())=='DATETIME')
                {
                    fieldObj.type_x = 'DateTime'; 
                }
                else
                if(string.valueOf(fd.getType())=='Number')
                {
                    fieldObj.type_x = 'Number'; 
                    if(fd.getLength()>0)
                    {
                        fieldObj.length = fd.getLength();  
                    }
                    else
                    {
                        fieldObj.length = 50;  
                    }
                }
                else
                if(string.valueOf(fd.getType())=='EMAIL')
                {
                    fieldObj.type_x = 'Email'; 
                    
                }
                else
                if(string.valueOf(fd.getType())=='PHONE')
                {
                    fieldObj.type_x = 'Phone'; 
                    
                }
                else
                if(string.valueOf(fd.getType())=='URL')
                {
                    fieldObj.type_x = 'Url';
                }
                else
                if(string.valueOf(fd.getType())=='TEXTAREA' || ((string.valueOf(fd.getType())=='STRING' || string.valueOf(fd.getType())=='MULTIPICKLIST') && fd.getLength()>255))
                {
                    fieldObj.type_x = 'LongTextArea';
                    if(fd.getLength()>255)
                    {
                        fieldObj.length = fd.getLength();  
                    }
                    else
                    {
                        fieldObj.length = 300;  
                    }
                    fieldObj.visibleLines = 5;
                }
                else
                {
                    fieldObj.type_x = 'Text'; 
                    if(fd.getLength()>0)
                    {
                        fieldObj.length = fd.getLength();  
                    }
                    else
                    {
                        fieldObj.length = 50;  
                    }
                    
                }
                system.debug('------fieldObj.length------'+fieldObj.length);
                system.debug('------fieldObj.type_x------'+fieldObj.type_x);
                fieldObj.required = false;
                
                lstCustomFields.add(fieldObj);
                if(fd.getName()=='SystemModstamp')
                {
                    MetadataService.CustomField fieldExternal = new MetadataService.CustomField();
                    fieldExternal.label = fd.getLabel();   
                    fieldExternal.fullName = fd.getName()+''+'ExId__c';  
                    fieldExternal.type_x = 'Text'; 
                     fieldExternal.length = 50;  
                    fieldExternal.required = true;
                    system.debug('-----fieldExternal.fullName-----'+fieldExternal.fullName);
                     fieldAPINames.add(fieldExternal.fullName);
                    lstCustomFields.add(fieldExternal);
                    
                    MetadataService.CustomField fieldExternal2 = new MetadataService.CustomField();
                    fieldExternal2.label = fd.getLabel();   
                    fieldExternal2.fullName = fd.getName()+''+'ActionType__c';  
                    fieldExternal2.type_x = 'Text'; 
                     fieldExternal2.length = 50;  
                    fieldExternal2.required = true;
                    system.debug('-----fieldExternal.fullName-----'+fieldExternal2.fullName);
                    fieldAPINames.add(fieldExternal2.fullName);
                    lstCustomFields.add(fieldExternal2);  
                }
            }
        } 
        bigObject.fields = lstCustomFields;  
        List<MetadataService.Index> lstIndex = new List<MetadataService.Index>();
        MetadataService.Index indexObj = new MetadataService.Index();  
        indexObj.label = bigObjectAPIName+'Index';  
        indexObj.fullName = bigObjectAPIName+'Index';          
         
        
        //define index field and add it to index  
        List<MetadataService.IndexField> lstIndexFields = new List<MetadataService.IndexField>();  
        if(!fieldAPINames.isEmpty())
        {
            for(string fieldName : fieldAPINames)
            {
                
                MetadataService.IndexField indfl = new MetadataService.IndexField(); 
                indfl.name = fieldName;  
                indfl.sortDirection = 'ASC';
                lstIndexFields.add(indfl); 
            }
        }
        
        indexObj.fields = lstIndexFields;  
        lstIndex.add(indexObj); 
        
        bigObject.indexes = lstIndex;         
        //finally create Big Object with Index field  
        List<MetadataService.SaveResult> saveResults = service.createMetadata(new MetadataService.Metadata[] { bigObject});         
        
        BigObject_Data_Process_Setings__c updateBigObject = new BigObject_Data_Process_Setings__c();
        for(BigObject_Data_Process_Setings__c bigSettings: [select id, Active__c, Active_Mapping_Process__c, Source_Object_API_Name__c, Source_Object_Name__c, Target_Object_API_Name__c, Target_Object_Name__c, BigObject_Status__c, Create_BigObject__c, isBigObject_Created__c from BigObject_Data_Process_Setings__c where Source_Object_API_Name__c=:objectAPIName and Create_BigObject__c=:true])
        {
            updateBigObject =  bigSettings;
        }
       //MetadataService.SaveResult saveResult = saveResults[0];  
       for(MetadataService.SaveResult saveResult: saveResults)
       {
        
            if(saveResult.success) 
            {
                updateBigObject.BigObject_Status__c = 'Success';
                updateBigObject.isBigObject_Created__c = True;
                updateBigObject.Target_Object_Name__c = bigObjectAPIName;
                updateBigObject.Target_Object_API_Name__c = bigObjectAPIName+'__b';
                    
                
            }
            else
            If(saveResult==null)
            {
                updateBigObject.BigObject_Status__c = 'Failed';
                updateBigObject.isBigObject_Created__c = False;
            }
            
                  
            // Construct error message   
            if(saveResult.errors!=null)  
            {  
                System.debug('errors=' + JSON.serialize(saveResult.errors));  
                List<String> messages = new List<String>();  
                messages.add(  
                    (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +  
                    'occured processing component ' + saveResult.fullName + '.');  
                for(MetadataService.Error error : saveResult.errors)  
                    messages.add(  
                        error.message + ' (' + error.statusCode + ').' +  
                        ( error.fields!=null && error.fields.size()>0 ?  
                         ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );  
                if(messages.size()>0)  
                
                System.debug(String.join(messages, ' '));
                updateBigObject.BigObject_Status__c = 'Failed';
                updateBigObject.isBigObject_Created__c = False;  
            }  
            if(!saveResult.success)  
                System.debug('Request failed with no specified error.'); 
                
        }
        
        if(updateBigObject!=null && !string.isBlank(updateBigObject.id))
        {
            update updateBigObject;
            return;
        }
    }

    public static List<Schema.SObjectField> getObjectFields(String objectName)
    {
     
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> items = Schema.getGlobalDescribe().get(objectName).getDescribe().Fields.getMap();
        List<Schema.SObjectField> fieldsMetaData = new List<Schema.SObjectField>();
     
        if (items != null){
            fieldsMetaData = items.values();
        }     
        return fieldsMetaData;
    } 
    
}