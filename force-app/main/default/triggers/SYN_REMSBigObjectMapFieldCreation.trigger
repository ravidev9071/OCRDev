trigger SYN_REMSBigObjectMapFieldCreation on BigObject_Data_Process_Setings__c (after insert, after update) 
{
    if(trigger.isInsert)
    {
        string objectAPI;
        boolean activateMapProcess;
        boolean createBigObject;
        boolean isBigObjectCreated;
        for(BigObject_Data_Process_Setings__c bigData: trigger.new)
        {
            if(!string.isBlank(bigData.Source_Object_API_Name__c))
            {
                objectAPI = bigData.Source_Object_API_Name__c;
                if(bigData.Create_BigObject__c==True)
                {
                    createBigObject = True;
                }
                if(bigData.isBigObject_Created__c==False)
                {
                    isBigObjectCreated = False;
                }
                 
            }
            if(bigData.Active_Mapping_Process__c==True )
            {
                activateMapProcess = True;
                
            }
        }
        if(!string.isBlank(objectAPI) && activateMapProcess==True)
        {
            SYN_REMSbigObjectMappingProcess.processInfo(objectAPI);
        }
        
        System.debug('------BigObject Process-----');
        System.debug('------BigObject Process-----'+objectAPI);
        System.debug('------BigObject Process-----'+isBigObjectCreated);
        System.debug('------BigObject Process-----'+createBigObject);
        if(!string.isBlank(objectAPI) &&  isBigObjectCreated==False && createBigObject==True)
        {
            System.debug('------BigObject Process-----');
            SYN_REMSbigObjectCreateProcessQueuable processBigObject = new SYN_REMSbigObjectCreateProcessQueuable(objectAPI);
            System.enqueueJob(processBigObject);
        }
        
    }
    if(trigger.isUpdate)
    {
        string objectAPI;
        boolean activateMapProcess;
        list<id> lstIds = new list<id>();
        boolean createBigObject;
        boolean isBigObjectCreated;
        for(BigObject_Data_Process_Setings__c bigData: trigger.new)
        {
            BigObject_Data_Process_Setings__c oldData = trigger.oldmap.get(bigData.id);
            if(!string.isBlank(bigData.Source_Object_API_Name__c))
            {
                objectAPI = bigData.Source_Object_API_Name__c;
            }
            if(bigData.Active_Mapping_Process__c==True && oldData.Active_Mapping_Process__c!=bigData.Active_Mapping_Process__c)
            {
                activateMapProcess = True;
                
            }
            if(bigData.Active_Mapping_Process__c==False && oldData.Active_Mapping_Process__c!=bigData.Active_Mapping_Process__c)
            {
                lstIds.add(bigData.id);
            }
            if(bigData.Create_BigObject__c==True)
            {
                createBigObject = True;
            }
            if(bigData.isBigObject_Created__c==False)
            {
                isBigObjectCreated = False;
            }
        }
        if(!string.isBlank(objectAPI) && activateMapProcess==True)
        {
            SYN_REMSbigObjectMappingProcess.processInfo(objectAPI);
        }
        else
        if(!lstIds.IsEmpty())
        {
            list<BigObject_Field_Mapping__c> lstDelete = new list<BigObject_Field_Mapping__c>();
            for(BigObject_Field_Mapping__c deleteRecords : [select id from BigObject_Field_Mapping__c where BigObject_Data_Process_Setings__c IN: lstIds])
            {
                lstDelete.add(deleteRecords);
            }
            if(!lstDelete.isEmpty())
            {
                delete lstDelete;
            }
        }
        System.debug('------BigObject Process-----');
        System.debug('------BigObject Process-----'+objectAPI);
        System.debug('------BigObject Process-----'+isBigObjectCreated);
        System.debug('------BigObject Process-----'+createBigObject);
        if(!string.isBlank(objectAPI) &&  isBigObjectCreated==False && createBigObject==True)
        {
            System.debug('------BigObject Process-----');
            SYN_REMSbigObjectCreateProcessQueuable processBigObject = new SYN_REMSbigObjectCreateProcessQueuable(objectAPI);
            System.enqueueJob(processBigObject);
        }
        
    }
}