public with sharing class  caseTriggerHandler
{
    public static void caseFollowupTaskCreate(list<case> lstCaseInfo)
    {
        list<string> lstCaseIds = new list<string>();
        for(case caseinfo: lstCaseInfo) 
        {
            lstCaseIds.add(caseinfo.US_WSREMS__REMS_Service_Summary__c);
        }
        
        map<string,US_WSREMS__REMS_Service_Summary__c> mapServiceInfo = new map<string,US_WSREMS__REMS_Service_Summary__c>();
        for(US_WSREMS__REMS_Service_Summary__c serviceInfo: [select id, US_WSREMS__Participant__c,US_WSREMS__Participant__r.PersonContactId, RecordType.Name,US_WSREMS__REMSProgram__c, US_WSREMS__REMSProgram__r.name from US_WSREMS__REMS_Service_Summary__c where id IN: lstCaseIds])
        {
            mapServiceInfo.put(serviceInfo.id,serviceInfo);
        }
        
        map<string,Follow_Up_Call_Setup__mdt> mapMetadata = new map<string,Follow_Up_Call_Setup__mdt>();
        list<string> lstQueueNames = new list<string>();
        for(Follow_Up_Call_Setup__mdt metaInfo: Follow_Up_Call_Setup__mdt.getAll().values())
        {
            string mapKey = metaInfo.REMS_Program__c+''+metaInfo.REMS_Service__c+''+metaInfo.Outcome__c+''+metaInfo.Outcome_Reason__c;
            mapMetadata.put(mapKey, metaInfo);
            lstQueueNames.add(metaInfo.Assigned_To__c);
        }
        map<string,string> mapQueues = new map<string,string>();
        if(!lstQueueNames.isEmpty())
        {
            for(group queGroup: [select id, name from group where type=:'Queue' and name IN: lstQueueNames])
            {
                mapQueues.put(queGroup.name,queGroup.id);
            }
        }
        list<task> lstTaskInfo = new list<task>();
        for(case caseinfo: lstCaseInfo)
        {
            if(mapServiceInfo.KeySet().Contains(caseinfo.US_WSREMS__REMS_Service_Summary__c))
            {
                string mapKey =  mapServiceInfo.get(caseinfo.US_WSREMS__REMS_Service_Summary__c).US_WSREMS__REMSProgram__r.name +''+mapServiceInfo.get(caseinfo.US_WSREMS__REMS_Service_Summary__c).RecordType.Name+''+caseinfo.US_WSREMS__Call_Outcome__c+''+caseinfo.US_WSREMS__Call_Outcome_Reason__c;
                
                if(mapMetadata.KeySet().Contains(mapKey))
                {
                    
                    {
                        {
                           if(!string.isBlank(string.valueOf(mapMetadata.get(mapKey).Follow_Up_Days__c)))
                           {
                                 Task tsk = new Task();
                                 if(!string.isBlank(mapMetadata.get(mapKey).Subject__c))
                                 {
                                     tsk.Subject = mapMetadata.get(mapKey).Subject__c;
                                 }
                                 else
                                 {
                                     tsk.Subject = 'Test Task';
                                 }
                                 if(!string.isBlank(mapServiceInfo.get(caseinfo.US_WSREMS__REMS_Service_Summary__c).US_WSREMS__Participant__r.PersonContactId))
                                 {
                                     tsk.whoid = mapServiceInfo.get(caseinfo.US_WSREMS__REMS_Service_Summary__c).US_WSREMS__Participant__r.PersonContactId;
                                     tsk.Related_to_Account__c = mapServiceInfo.get(caseinfo.US_WSREMS__REMS_Service_Summary__c).US_WSREMS__Participant__c;
                                 }
                                 tsk.Program_Name__c = mapServiceInfo.get(caseinfo.US_WSREMS__REMS_Service_Summary__c).US_WSREMS__REMSProgram__c;
                                 tsk.Status = 'Not Started';
                                 tsk.Priority = 'Normal';
                                 tsk.Type = 'Call';
                                 tsk.Type_of_Outbound_Call__c = 'Follow-up';
                                  
                                 tsk.ActivityDate = system.today().addDays(integer.valueOf(mapMetadata.get(mapKey).Follow_Up_Days__c));
                                 tsk.WhatId = caseinfo.ID;
                                 if(mapQueues.KeySet().Contains(mapMetadata.get(mapKey).Assigned_To__c))
                                 {
                                     tsk.OwnerId = mapQueues.get(mapMetadata.get(mapKey).Assigned_To__c);
                                 }
                                 //mapMetadata.get(mapKey).Assigned_To__c;
                                 lstTaskInfo.add(tsk);
                           }
                       } 
                    }
                }
            } 
        }
        if(!lstTaskInfo.isEmpty())
        {
            database.insert(lstTaskInfo,false);
        }
    }
}