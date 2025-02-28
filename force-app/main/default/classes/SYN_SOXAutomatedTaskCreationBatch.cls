/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-29-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
Public class SYN_SOXAutomatedTaskCreationBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    
    Date one_day_before;
    Date three_days_before;
    Date five_days_before;
	Date nine_days_before;
    Date ten_days_before;
	
    Public static List<Date> dateRange; 
    Map<String,Id> queueNameMap;
    Id recordTypeId; 
    Id TaskManualRecordtypeId;
    Id bHoursId;
    public String prgName;
    public SYN_SOXAutomatedTaskCreationBatch(String programName){        
    	prgName = programName;
    }
    
    Map<String, List<String>> programAndRestirctedService = new Map<String, List<String>>{
        'Sodium Oxybate REMS' => new List<String>{'Inbound_Communication','Outbound_Communication','Participant_Account_Creation','Non_Compliance'},
        'Macitentan REMS' => new List<String>{'Inbound_Communication','Outbound_Communication','Participant_Account_Creation','Non_Compliance','Change_Authorized_Representative',
                                               'Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification','PAE_PC_MI','Patient_Counseling_Checklist',
                                               'Patient_Pregnancy_Test','Pre_Dispense_Authorization','Record_Transfer','Disenrollment','Change_of_Information','RCA_Communication'}         
    };      
    
    Map<String, Map<String, String>> allProgamAndQueueMap = new Map<String, Map<String, String>>{
        'Sodium Oxybate REMS' => new Map<String, String>{'Task' => 'SOX Task Queue', 'Call' => 'SOX REMS Call Queue'},
        'Macitentan REMS' => new Map<String, String>{'Task' => 'Macitentan REMS Task Queue', 'Call' => 'Macitentan REMS Call Queue'}       
    };
        
    Map<String, String> programAndBusinessHours = new Map<String, String>{
        'Sodium Oxybate REMS' => System.Label.SOXBusinessHoursName,
        'Macitentan REMS' => System.Label.MACIBusinessHoursName       
    };   
    
    public Map<String, String> currentProgramAndQueue ;
	public Map<String, List<Date>> programAndDateRange;
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        List<String> serviceRecordtype = programAndRestirctedService.get(prgName);  
        String businessHours = programAndBusinessHours.get(prgName);
        currentProgramAndQueue = allProgamAndQueueMap.get(prgName);
        List<String> queueList = currentProgramAndQueue.values();        
        Map<Id,RecordType> recordTypeList=new Map<Id,RecordType>([select id,Name from RecordType where sObjectType='US_WSREMS__REMS_Service_Summary__c' and developerName IN :serviceRecordtype]);
        Set<Id> recIds = recordTypeList.keySet();
        bHoursId = Id.valueof(SYN_CommonUtility.getBusinessHoursId(businessHours));        
       	queueNameMap=new Map<String,Id>();
        
        for(Group groupObj : [ select Id,Name from Group where Type = 'Queue' AND Name IN :queueList]){
            queueNameMap.put(groupObj.Name,groupObj.Id);
        }
        recordTypeId =Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Call_Task').getRecordTypeId();
        TaskManualRecordtypeId = Schema.SObjectType.task.getRecordTypeInfosByDeveloperName().get('Manual_Task').getRecordTypeId();
        //queueName=queGroup.id;
        SYN_SOXAutomatedTaskUtility soxutility = new SYN_SOXAutomatedTaskUtility();
        Map<String, Time> sox_startHours = SYN_CommonUtility.getBusinessStartHours(businessHours);       
        
        Datetime currentDate = soxutility.getcurrentDate(sox_startHours);        
        one_day_before = (soxutility.SubtractDays(currentDate,1, businessHours)).date();
        three_days_before = soxutility.SubtractDays(currentDate,3, businessHours).date();
        five_days_before = soxutility.SubtractDays(currentDate,5, businessHours).date();
		nine_days_before = soxutility.SubtractDays(currentDate,9, businessHours).date();
        ten_days_before = soxutility.SubtractDays(currentDate,10, businessHours).date();
		
		programAndDateRange = new Map<String, List<date>>{
			'Sodium Oxybate REMS' => new List<Date>{one_day_before,three_days_before,five_days_before,ten_days_before},
			'Macitentan REMS' => new List<Date>{one_day_before,three_days_before,five_days_before, nine_days_before, ten_days_before}
		};
            
        dateRange =  programAndDateRange.get(prgName);    
            
        String draft = 'draft';        
        String query='select id,US_WSREMS__REMS_Service_Summary__c,CreatedDate,US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Program__r.Name,US_WSREMS__REMS_Service_Summary__r.recordtypeId,US_WSREMS__Participant__r.PersonContactId,REMS_Project_Code__c from case where DAY_ONLY(CreatedDate) IN : dateRange and status= :draft and US_WSREMS__REMS_Service_Summary__r.recordtypeId NOT IN :recIds and US_WSREMS__REMS_Service_Summary__c !=null';
        
        return Database.getQueryLocator(query);
    }
     
    Public void execute(Database.BatchableContext BC, List<Case> scope) {
        List<Id> remsserviceIds=new List<Id>();
        Map<Id,List<Task>> taskmap=new Map<Id,List<Task>>();
        for(Case caseObject :Scope){ 
            remsserviceIds.add(caseObject.US_WSREMS__REMS_Service_Summary__c);
        }
        List<Task> taskList=[select id,WhatId from Task where WhatId IN:remsserviceIds and type IN ('Call','Other') and status IN ('Draft','Pending') ];
        for(Task t:taskList){
            if(taskmap.containsKey(t.whatId)){
                List<Task> oldTask=taskmap.get(t.whatId);
                oldTask.add(t);
                taskmap.put(t.WhatId,oldTask);
            }else{
                
                List<Task> newTask = new List<Task>();
                newTask.add(t);
                taskmap.put(t.WhatId,newTask);                
            }
            
        }
		
        List<Task> task_insertlist=new List<Task>();
        for(Case caseObj1 : scope){
		
            if(!taskmap.containsKey(caseObj1.US_WSREMS__REMS_Service_Summary__c)){
                
                if(caseObj1.REMS_Project_Code__c == '7433' && (caseObj1.CreatedDate.date() == three_days_before || caseObj1.CreatedDate.date() == five_days_before ||(prgName == 'Macitentan REMS' && caseObj1.CreatedDate.date() == nine_days_before ))){
                    
                    task_insertlist.add(SYN_SOXAutomatedTaskUtility.createFollowupTask(caseObj1,queueNameMap.get(currentProgramAndQueue.get('Call')), recordTypeId, bHoursId));                    
                }
                
                if(caseObj1.CreatedDate.date() == ten_days_before && caseObj1.REMS_Project_Code__c=='7433' ){
				
                    task_insertlist.add(SYN_SOXAutomatedTaskUtility.createDueDiligenceTask(caseObj1,queueNameMap.get(currentProgramAndQueue.get('Task')),TaskManualRecordtypeId,bHoursId));
                } 
            }   
        }        
        
        if(!task_insertList.isEmpty()){
		
           Database.insert(task_insertlist, true);
        }
        
    }
	
    public  void finish(Database.BatchableContext BC) {
        
    }
    
    public void execute( SchedulableContext context ) {		
        /* 
        String sch1 = '0 4 * * * ?';
        SYN_SOXAutomatedTaskCreationBatch soxAutoTask = new SYN_SOXAutomatedTaskCreationBatch('Sodium Oxybate REMS');
        system.schedule('SOX Automated Task Job', sch3, soxAutoTask);
        
        String sch2 = '0 5 * * * ?';
        SYN_SOXAutomatedTaskCreationBatch soxAutoTask2 = new SYN_SOXAutomatedTaskCreationBatch('Macitentan REMS');
        system.schedule('Maci Automated Task Job', sch2, soxAutoTask2);
        */
        Database.executeBatch(new SYN_SOXAutomatedTaskCreationBatch(prgName));         
    }    
}