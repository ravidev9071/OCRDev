/*****************************************************************************************************************
* Class Name           : Tryvio_AutomatedTaskCreation
* @Description         : Creates the task for Case object 
* @Author              : Amrit Jain
* @CreatedDate         : 19-06-2024
*****************************************************************************************************************/
public without sharing class Tryvio_AutomatedTaskCreation {
    public static Id Task_Manual_rctypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Manual_Task').getRecordTypeId();

    private static String strTryvioProgram = 'TRYVIO REMS';
    /*****************************************************************************************************************
    * Method Name          : createNoncomplainceTask
    * @Description         : Creates the task for Non-Compliance and PAE/PC/MIPAE/PC/MI case if certain comditions are met. 
    * @Author              : Amrit Jain
    * @CreatedDate         : 19-06-2024
    * @param caseList      : Triggered Case List
    * @param oldCaseList   : List of old cases
    * @param triggerContext: value is false if case is inserted, and true if case is updated
    * @return              : null
    ****************************************************************************************************************
    */
    public static void createNoncomplainceTask(list<Case> caseList, Map<Id,Case> oldCaseList, boolean triggerContext, String programName){
        List<Task> newTasks = new List<Task>();
        Map<Id,Case> caseMap = New Map<Id,Case>([Select Id, RecordType.developerName, Status, US_WSREMS__Program_Name__c, US_WSREMS__Outcome__c, US_WSREMS__Status__c, US_WSREMS__REMS_Service_Summary__c, US_WSREMS__REMS_Service_Summary__r.RecordType.Name, US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Status__c, US_WSREMS__REMS_Program__c, OwnerId from case where Id in: caseList]);
        Date dueDate = System.today();
        for(Case cas: caseMap.values()){
            if(cas.US_WSREMS__Program_Name__c == programName){
                if(  cas.US_WSREMS__Outcome__c == 'Confirmed Non-compliance activity'
                    && cas.recordtype.developername == 'Non_Compliance'){
                    String noncomplianceMessage = 'A noncompliance event has been confirmed. Please document the details in Trackwise';
                    if(!triggerContext){
                        newTasks.add(createTask(cas, cas.OwnerId, 'Noncompliance TrackWise Documentation', cas.id, dueDate, 'In Progress',noncomplianceMessage));
                    }
                    else if(triggerContext && cas.US_WSREMS__Outcome__c != oldCaseList.get(cas.Id).US_WSREMS__Outcome__c){
                        newTasks.add(createTask(cas, cas.OwnerId, 'Noncompliance TrackWise Documentation', cas.id, dueDate, 'In Progress',noncomplianceMessage));
                    }
                }
                    
                if(!triggerContext && cas.RecordType.developername == 'Non_Compliance'){
                    string potentialTaskMessage = 'A noncompliance event has been suspected.Please investigate the event and confirm if non compliance occured ';
                    newTasks.add(createTask(cas, cas.OwnerId, 'Potential Noncompliance Follow-up', cas.id, null, null,potentialTaskMessage));
                }
                if(triggerContext && cas.RecordType.developername == 'PAE' && cas.Status == 'Sent to Sponsor' && cas.US_WSREMS__Outcome__c == 'Acknowledgment Pending'){
                    String tasknotes = 'CC follow up for Adverse Event acknowledgement';
                    newTasks.add(createTask(cas, cas.OwnerId, 'Adverse Event Acknowledgement Follow Up', cas.id, dueDate, 'In Progress',tasknotes));
                }
            }
        }
        if (!newTasks.isEmpty()) {
            insert newTasks;
        }
    }
    /*****************************************************************************************************************
    * Method Name          : createTask
    * @Description         : returns the task with values according to the parameters passed.
    * @Author              : Amrit Jain
    * @CreatedDate         : 19-06-2024
    * @param caseRec       : Case record for which task should be created
    * @param ownerId       : Owner Id
    * @param subject       : Subject for the Task
    * @param relatedToId   : Id to which the task is related to
    * @param dueDate       : Due date passed in the task
    * @return              : Task with the values according to the passed parameters' values
    *****************************************************************************************************************/
    public static Task createTask(Case caseRec, Id ownerId, String subject, Id relatedToId, Date dueDate, String status,string notes) {
        Task task = new Task(
            RecordTypeId = Task_Manual_rctypeId, // Confirm the rec type with the client
            WhatId = relatedToId,
            ActivityDate = dueDate,
            Type = 'Other',
            OwnerId = ownerId,
            Subject = subject,
            Description = notes,
            Program_Name__c = caseRec.US_WSREMS__REMS_Program__c,
            REMS_Program__c = strTryvioProgram
        );			
        if(status!= null){
            task.Status = status;
        }
        return task;
    }
}