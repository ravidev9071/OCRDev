/**
* @File Name          : SYN_TaskTriggerHandler.cls
* @Description        : This trigger handler is responsible for handling the after update event for Task objects.
*                       This handler is associated with the  SYN_TaskTrigger trigger.
* @Trigger            : SYN_TaskTrigger
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 2.0       01/16/2024      Dnyaneshwar Gothakade (Wilco)    handleAfterUpdate : Line No 47-74
*                                                            This block of code Updates the 'Second_Review__c' field on DocumentCheckListItem based
*                                                            on the status of the Task related to Clozapine REMS program.
*/

public with sharing class SYN_TaskTriggerHandler {

    public static void handleAfterUpdate(List<Task> newTasks, Map<Id, Task> oldMap) {
        Map<String, SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
        if (mapBigObjectSettings.containsKey('Task') && mapBigObjectSettings.get('Task').IsActive__c == true && !Test.isRunningTest()) {
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(newTasks, 'Task', 'Update');
            System.enqueueJob(qe);
        }

        List<DocumentCheckListItem> updateDocCheckListItem = new List<DocumentCheckListItem>();
        String documentDetailRecordID = System.Label.DocumentDetail_Record_ID;
        for (Task t : newTasks) {
            if(t.US_WSREMS__Program_Name__c  == 'Clozapine REMS' && String.valueOf(t.WhatId).startsWith(documentDetailRecordID) ){
                if (t.Status == 'Completed' && oldMap != null && oldMap.get(t.Id).Status != 'Completed') {
                    DocumentCheckListItem dc = new DocumentCheckListItem(Id = t.WhatId, Second_Review__c = true);
                    updateDocCheckListItem.add(dc);
                } else if ((t.Status == 'In Progress' || t.Status == 'Not Started') && oldMap != null && oldMap.get(t.Id).Status == 'Completed') {
                    DocumentCheckListItem dc1 = new DocumentCheckListItem(Id = t.WhatId, Second_Review__c = false);
                    updateDocCheckListItem.add(dc1);
                }
            }
        }
        if (!updateDocCheckListItem.isEmpty()) {
            try {
                update updateDocCheckListItem;
            } catch (Exception e) {
                // Handle exception
            }
        }
    }
}