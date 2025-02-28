trigger SYN_TaskTrigger on Task (before Insert,After Insert, After Update,Before delete) {

    if(Trigger.isBefore && Trigger.isInsert){
        Set<Id> parentIds = new Set<Id>();
        Set<Id> queueSet=new Set<Id>();
        List<Task> escalation_tasks = new List<Task>();
        Map<String,Id> queueNameSet=new Map<String,Id>();
        for(Task taskObj:trigger.New){

            if(taskObj.Type == 'Call'){
                queueSet.add(taskObj.Program_Name__c);

            }else if(taskObj.Type == 'Escalation' && !string.isBlank(taskObj.SYN_Escalation_Type__c) && !taskObj.SYN_Escalation_Type__c.contains('RCA') && !taskObj.SYN_Escalation_Type__c.contains('Event') && !string.isBlank(taskObj.Subject) && !taskObj.Subject.contains('Reproductive')){
                escalation_tasks.add(taskObj);
            }

            if(taskObj.Subject == 'Non Compliance Investigation Complete'){
                parentIds.add(taskObj.WhatId);
            }


        }

        if(escalation_tasks!=null && !escalation_tasks.isEmpty()){
            Group grpObj=[select Id,Name from Group where Type = 'Queue' AND Name=:SYN_Utilitycls.Escalation_queue_name];
            for(Task t:escalation_tasks){
                if(t.US_WSREMS__Program_Name__c != SYN_Utilitycls.MACI_PROGRAM_NAME){
                    t.OwnerId=grpObj.Id;
                }
            }

        }
        for(US_WSREMS__REMS_Program__c prg:[select id,QueueName__c from US_WSREMS__REMS_Program__c where id in :queueSet ]){
            queueNameSet.put(prg.QueueName__c,prg.Id);
        }
        Map<Id,Id> queueNameMap=new Map<Id,Id>();
        for(Group groupObj : [ select Id,Name from Group where Type = 'Queue' AND Name IN :queueNameSet.keyset()]){
            if(queueNameSet.containsKey(groupObj.Name)){
                queueNameMap.put(queueNameSet.get(groupObj.Name),groupObj.Id);
            }

        }
        for(Task t:Trigger.New){
            if(queueNameMap.containsKey(t.Program_Name__c)){
                t.OwnerId=queueNameMap.get(t.Program_Name__c);
            }
        }

        if(!parentIds.isEmpty()){
            Map<Id,US_WSREMS__REMS_Service_Summary__c> remsMap= new map<Id,US_WSREMS__REMS_Service_Summary__c>([SELECT Id, US_WSREMS__REMSProgram__c, US_WSREMS__REMSProgram__r.Name FROM US_WSREMS__REMS_Service_Summary__c
                                                                                                                WHERE Id =: parentIds AND US_WSREMS__REMSProgram__c != null AND US_WSREMS__REMSProgram__r.Name = 'Macitentan REMS']);

            if(remsMap != null){
                Group grup =[select Id,Name from Group where Type = 'Queue' AND Name=:SYN_Utilitycls.Escalation_queue_name];
                for(Task t:trigger.New){
                    if(t.Subject == 'Non Compliance Investigation Complete' && t.WhatId != null && remsMap.containsKey(t.WhatId)){
                        t.Type = 'Escalation';
                        t.REMS_Program__c = 'Macitentan REMS ';
                        t.SYN_Escalation_Type__c = 'Potential Noncompliance Identified';
                        t.ownerId = grup.id;
                    }
                    //if(t.US_WSREMS__Program_Name__c == SYN_Utilitycls.MACI_PROGRAM_NAME){
                    //   t.ownerId = Label.Macitentan_Escalation_Queue;
                    //}
                }
            }


        }

    }

    //After Insert
    if(trigger.isAfter && trigger.isInsert){
        map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
        if(mapBigObjectSettings.KeySet().Contains('Task') && mapBigObjectSettings.get('Task').IsActive__c==True && (!Test.isRunningTest()))
        {
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'Task','Insert');
            system.enqueueJob(qe);
        }
    }

    //After update
    if(trigger.isAfter && trigger.isUpdate){
        SYN_TaskTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
     }

    //Before delete
    if(trigger.isBefore && trigger.isDelete){
        map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
        if(mapBigObjectSettings.KeySet().Contains('Task') && mapBigObjectSettings.get('Task').IsActive__c==True && (!Test.isRunningTest()))
        {
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.old,'Task','Delete');
            system.enqueueJob(qe);
        }
    }

}