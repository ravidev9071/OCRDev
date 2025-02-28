/*****************************************************************************************************************
        * Class Name           : Piasky_AutomatedTaskCreation
        * @Description         : Creates the task for Case object BT1005-112
        * @Author              : Dilbag Singh
        * @CreatedDate         : 11-06-2024
*****************************************************************************************************************/
public without sharing class Piasky_AutomatedTaskCreation { 
    
    public static Id Task_Manual_rctypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Manual_Task').getRecordTypeId();   
    
/*****************************************************************************************************************
        * Method Name          : createNoncomplainceTask
        * @Description         : Creates the task for Non-Compliance and PAE/PC/MIPAE/PC/MI case if certain comditions are met. BT1005-112 
        * @Author              : Dilbag Singh
        * @CreatedDate         : 11-06-2024
        * @param caseList      : Triggered Case List
        * @param oldCaseList   : List of old cases
        * @param triggerContext: value is false if case is inserted, and true if case is updated
        * @return              : null
*****************************************************************************************************************/
    
    public static void createNoncomplainceTask(list<Case> caseList, Map<Id,Case> oldCaseList, boolean triggerContext, String programName){
        List<Task> newTasks = new List<Task>();
        Map<Id,Case> caseMap = New Map<Id,Case>([Select Id,Prescriber_Status__c,US_WSREMS__Is_Portal__c, US_WSREMS__REMS_Program__c, RecordType.developerName, Status, US_WSREMS__Program_Name__c, US_WSREMS__Participant__c, US_WSREMS__Participant__r.IsPersonAccount, US_WSREMS__Participant__r.PersonContactId, US_WSREMS__Outcome__c, US_WSREMS__Status__c, US_WSREMS__REMS_Service_Summary__c, US_WSREMS__REMS_Service_Summary__r.RecordType.Name, US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Status__c from case where Id in: caseList]);
        Group taskOwner = [SELECT Id FROM Group WHERE DeveloperName =: SYN_Utilitycls.PiaSky_REMS_Task_Queue AND Type = 'Queue' LIMIT 1];
        Date dueDateBusiness = SYN_CaseTriggerHelper.getNextBusinessDate(System.now(), System.Label.PiaSky_Business_Hours_Name);
        Date dueDate = system.today();
        for(Case cas: caseMap.values()){
            if(cas.US_WSREMS__Program_Name__c == programName){//BT1005-376
                if(  cas.US_WSREMS__Outcome__c == 'Confirmed Non-compliance activity'
                   && cas.recordtype.developername == 'Non_Compliance'
                  ){string noncomplianceMessage = 'A non compliance event has been confirmed.Please document the details in trackwise '+system.now();
                      if(!triggerContext){
                          newTasks.add(createTask(taskOwner.Id, 'Noncompliance TrackWise Documentation', cas.id, dueDate, 'In Progress',noncomplianceMessage, cas.US_WSREMS__REMS_Program__c, cas.US_WSREMS__Program_Name__c));
                      }
                      else if(triggerContext && cas.US_WSREMS__Outcome__c != oldCaseList.get(cas.Id).US_WSREMS__Outcome__c){
                          newTasks.add(createTask(taskOwner.Id, 'Noncompliance TrackWise Documentation', cas.id, dueDate, 'In Progress',noncomplianceMessage, cas.US_WSREMS__REMS_Program__c, cas.US_WSREMS__Program_Name__c));
                      }
                  }
                //BT1005-378
                if(!triggerContext && cas.RecordType.developername == 'Non_Compliance'){
                    if(cas.Status == 'Draft' ){
                        string potentialTaskMessage = 'A noncompliance event has been suspected.Please investigate the event and confirm if non compliance occured '+system.now();
                        newTasks.add(createTask(taskOwner.Id, 'Potential Noncompliance Follow-up', cas.id, null, null,potentialTaskMessage, cas.US_WSREMS__REMS_Program__c, cas.US_WSREMS__Program_Name__c));
                        
                    }
                } 
                //BT1005-746
                 if(!triggerContext && cas.RecordType.developername == 'PDA' && cas.US_WSREMS__Is_Portal__c != true){
                    if(cas.Prescriber_Status__c != 'Certified' ){
            			string potentialTaskMessage = 'RDA rejection for prescriber not found/certified. Please follow up for additional information and prescriber certification.';
                        newTasks.add(createTask(taskOwner.Id, 'RDA Request Follow-up', cas.id, dueDate,'In Progress',potentialTaskMessage, cas.US_WSREMS__REMS_Program__c, cas.US_WSREMS__Program_Name__c));
                        
                    }
                }

                //BT1005-374
                if(triggerContext && cas.RecordType.developername == 'PAE' && cas.Status == 'Sent to Sponsor' && cas.Status != oldCaseList.get(cas.Id).Status){
                    String tasknotes = 'CC follow up for Adverse Event acknowledgement '+system.now();
                    if(dueDateBusiness == System.today()){
                        dueDateBusiness = dueDateBusiness.addDays(1);
                    }
                    newTasks.add(createTask(taskOwner.Id, 'Adverse Event Acknowledgement Follow Up', cas.id, dueDateBusiness, 'In Progress',tasknotes, cas.US_WSREMS__REMS_Program__c, cas.US_WSREMS__Program_Name__c));
                }
            }
            
        }
        if (!newTasks.isEmpty()) {
            insert newTasks;
        }
    }
    /*****************************************************************************************************************
* Method Name          : createRemsCaseRelatedTasks
* @Description         : Creates the task for disenrollement of prescriber/HCP if they are affiliated to single HCP/prescriber which is disenrolled already.
* @Author              : Dilbag Singh
* @CreatedDate         : 11-06-2024
* @param caseList      : Triggered Case List
* @param oldCaseList   : List of old cases
* @param triggerContext: value is false if case is inserted, and true if case is updated
* @return              : null
*****************************************************************************************************************/
    
    public static void createRemsCaseRelatedTasks(list<Case> newCaseList, Map<Id,Case> oldSCaseList, string programName, string caseRecordtype){
        Map<Id, Case> getHCPAccount = new Map<Id, Case>();
        Map<Id, Case> getHCSAccount = new Map<Id, Case>();
        string disEnrollRecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deactivation').getRecordTypeId();
        for(Case cas : newCaseList){
            if(cas.RecordTypeId == disEnrollRecordTypeId && cas.US_WSREMS__Program_Name__c.contains(programName) && cas.Status == 'Complete' ){
                if(cas.US_WSREMS__Participant__c != null && cas.US_WSREMS__Requestor_Type__c == 'Prescriber'){
                    getHCPAccount.put(cas.US_WSREMS__Participant__c, cas);
                }else if(cas.US_WSREMS__Participant__c != null && cas.US_WSREMS__Requestor_Type__c == 'Health Care Setting'){
                    getHCSAccount.put(cas.US_WSREMS__Participant__c, cas);
                }
            }
        }
        if(!getHCPAccount.isEmpty()){
            checkDeactivatedAcc(getHCPAccount,'Prescriber',programName);
        }
        if(!getHCSAccount.isEmpty()){
            checkDeactivatedAcc(getHCSAccount,'Health Care Setting',programName);
        }
    }
    
    public static void checkDeactivatedAcc(Map<Id, Case> affAccCaseMap, string requesterType,string programName){
        string subject = 'Alert HCP affiliated HCS was disenrolled';
        string status = 'Draft';
        String notes = 'Alert HCP that their only affiliated HCS '
            +'has been disenrolled and their status will change to disenroll unless the affiliate to a certified HCS.';
        Date dueDate = system.today();
        List<Task> newTasks = new List<Task>();
        Map<Id,List<US_WSREMS__Affiliation__c>> affiliationMap = new Map<Id, List<US_WSREMS__Affiliation__c>>();
        set<Id> setAccountIds = new set<Id>();
        setAccountIds.addAll(affAccCaseMap.keySet());
        String programQueue = programName == SYN_Utilitycls.AVEED_PROGRAM_NAME ? SYN_Utilitycls.AVEED_TaskQueueName : SYN_Utilitycls.XIAFLEX_QueueName;
        Group taskOwner = [SELECT Id FROM Group WHERE DeveloperName =: programQueue AND Type = 'Queue' LIMIT 1];
        String recordTypeName = 'Prescriber Affiliation';
        String query = 'Select Id, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Office_Contact__c, US_WSREMS__Pharmacy__c, US_WSREMS__Pharmacy__r.US_WSREMS__Status__c, US_WSREMS__Prescriber__c, US_WSREMS__Prescriber__r.US_WSREMS__Status__c, RecordType.Name from US_WSREMS__Affiliation__c Where RecordType.Name =: recordTypeName ';
        if(requesterType == 'Health Care Setting'){
            query += ' AND US_WSREMS__Health_Care_Setting__c In: setAccountIds ';
        } else if(requesterType == 'Prescriber'){  
            query += ' AND US_WSREMS__Prescriber__c In: setAccountIds ';
        }
        List<US_WSREMS__Affiliation__c> affiliationList = Database.query(query);
        if(!affiliationList.isEmpty() && affiliationList.size() < 2) {
            if(affiliationList[0].RecordType.Name == 'Prescriber Affiliation' &&  affiliationList[0].US_WSREMS__Health_Care_Setting__c != null && affiliationList[0].US_WSREMS__Prescriber__c != null){
                
                if(requesterType == 'Health Care Setting'){
                    case caseobj =  affAccCaseMap.get(affiliationList[0].US_WSREMS__Health_Care_Setting__c);   
                    newTasks.add(createTask(taskOwner.Id, subject, caseobj.id, dueDate, status,notes,caseobj.US_WSREMS__REMS_Program__c,programName));
                    
                }else if(requesterType == 'Prescriber'){
                    case caseobj =  affAccCaseMap.get(affiliationList[0].US_WSREMS__Prescriber__c);   
                    newTasks.add(createTask(taskOwner.Id, subject, caseobj.id, dueDate, status,notes,caseobj.US_WSREMS__REMS_Program__c,programName));
                }
            } 
        }else {
            return;
        }
        if (!newTasks.isEmpty()) { 
            for(task taskRec : newTasks){
                taskRec.Priority = 'High';
            }
        }
        if (!newTasks.isEmpty()) {
            insert newTasks;
        }
    }
    /*****************************************************************************************************************
* Method Name          : createTask
* @Description         : returns the task with values according to the parameters passed.
* @Author              : Dilbag Singh
* @CreatedDate         : 11-06-2024
* @param caseRec       : Case record for which task should be created
* @param ownerId       : Owner Id
* @param subject       : Subject for the Task
* @param relatedToId   : Id to which the task is related to
* @param dueDate       : Due date passed in the task
* @return              : Task with the values according to the passed parameters' values
*****************************************************************************************************************/
    
    public static Task createTask(Id ownerId, String subject, Id relatedToId, Date dueDate, String status,string notes, Id programId, String programName) {
        Task task = new Task(
            RecordTypeId = Task_Manual_rctypeId,
            WhatId = relatedToId,
            ActivityDate = dueDate,
            Type = 'Other',
            OwnerId = ownerId,
            Subject = subject,
            Program_Name__c = programId,
            REMS_Program__c = programName,
            Description = notes
        );	
        if(status!= null){
            task.Status = status;
        }
        return task;
    } 
    
}