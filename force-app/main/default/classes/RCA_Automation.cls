/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-28-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class RCA_Automation {

    public static Id RSS_RCA_rctypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('RCA_Communication').getRecordTypeId();
    public static Id Task_Manual_rctypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Manual_Task').getRecordTypeId();
    public static String Patient_RSS_reqType = 'Patient';
    public static String Open_RSS_Status = 'Open';
    public static String Draft_Case_status = 'Draft';
    private static final Map <String, schema.RecordtypeInfo> mapCaseRCTypesByDevName = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName();
    //private static Id Maci_Escalation_QueueId = [select id from Group where Type = 'Queue' AND DeveloperName ='Macitentan_Escalation_Queue' limit 1].id; 
    private static Id Maci_Escalation_QueueId = SYN_CommonUtility.getMaciEscQueue();
    
    private static String Maci_programStr = System.label.Macitentan_REMS_Program_Name;
    private static Map<Id, Account> accountIdMap;
    
    public static void case_RCA(String Type , List<Case> RCA_cases){
        System.debug('::::Queue Query 22:::');
        String Maci_programStr = System.label.Macitentan_REMS_Program_Name;
        Id CaseTI_RCTypeId = mapCaseRCTypesByDevName.get('Treatment_InterruptionRCA').getrecordTypeId();
        Id CasePreg_RCTypeId = mapCaseRCTypesByDevName.get('PregnancyRCA').getrecordTypeId();
        Id CaseMisClass_RCTypeId = mapCaseRCTypesByDevName.get('MisclassificationRCA').getrecordTypeId();
        Task task_RCA;
        US_WSREMS__REMS_Service_Summary__c rss_RCA;
        case case_RCA;
        Map<String, case> mapRSSKeyCase = new Map<String, Case>();
        Map<String, US_WSREMS__REMS_Service_Summary__c> mapRSSKeyValue = new Map<String, US_WSREMS__REMS_Service_Summary__c> ();
        Map<String, US_WSREMS__REMS_Service_Summary__c> mapExtRSSKeyValue = new Map<String, US_WSREMS__REMS_Service_Summary__c> ();
        Map<String, Task> mapTaskKeyValue = new Map<String, Task> ();
        Set<Id> accountIdSet = new Set<Id>();
        for (case RCA_case : RCA_cases){
            if(RCA_case.US_WSREMS__Patient__c != null) {
                accountIdSet.add(RCA_case.US_WSREMS__Patient__c);
            }
        }
        if(accountIdSet.size() > 0) {
            accountIdMap = new Map<Id, Account>([Select id, SYN_Ref_Id__c from Account where Id IN : accountIdSet]);
        }
        	
        for (case RCA_case : RCA_cases){
            
            if (Type == 'Treatment_Interruption'){
                
                rss_RCA = createRCA_Service (RCA_case.US_WSREMS__REMS_Program__c ,RSS_RCA_rctypeId, Patient_RSS_reqType, RCA_case.US_WSREMS__Patient__c ,Open_RSS_Status);
                task_RCA = createRCA_Task('Escalation' , 'Treatment Interruption RCA Follow Up', RCA_case.US_WSREMS__REMS_Program__c ,System.today(),Maci_Escalation_QueueId , 'Treatment Interruption RCA Escalation Task' , SYN_CaseTriggerHanlder.participantIdtoPersonAccMap.get(RCA_case.US_WSREMS__Patient__c) );
                case_RCA = createRCA_Case(CaseTI_RCTypeId, Draft_Case_status ,RCA_case.US_WSREMS__Patient__c ,RCA_case, Maci_programStr+'-Treatment_InterruptionRCA' );
            
                
                
            }else if (Type == 'Pregnancy'){
                
                rss_RCA = createRCA_Service (RCA_case.US_WSREMS__REMS_Program__c, RSS_RCA_rctypeId, Patient_RSS_reqType, RCA_case.US_WSREMS__Patient__c ,Open_RSS_Status);
                task_RCA = createRCA_Task('Escalation' , 'Pregnancy RCA Follow-Up', RCA_case.US_WSREMS__REMS_Program__c ,System.today(),Maci_Escalation_QueueId , 'Pregnancy RCA Escalation Task' , SYN_CaseTriggerHanlder.participantIdtoPersonAccMap.get(RCA_case.US_WSREMS__Patient__c));
                case_RCA = createRCA_Case(CasePreg_RCTypeId, Draft_Case_status ,RCA_case.US_WSREMS__Patient__c , RCA_case, Maci_programStr+'-PregnancyRCA' );
                
            }else if (Type == 'Misclassification'){
                
                rss_RCA = createRCA_Service (RCA_case.US_WSREMS__REMS_Program__c ,RSS_RCA_rctypeId, Patient_RSS_reqType, RCA_case.US_WSREMS__Patient__c ,Open_RSS_Status);  
                task_RCA = createRCA_Task('Escalation' , 'Reproductive Misclassification RCA Follow-Up', RCA_case.US_WSREMS__REMS_Program__c ,System.today(),Maci_Escalation_QueueId,'Misclassification RCA Escalation Task' , SYN_CaseTriggerHanlder.participantIdtoPersonAccMap.get(RCA_case.US_WSREMS__Patient__c) );
                case_RCA = createRCA_Case(CaseMisClass_RCTypeId, Draft_Case_status ,RCA_case.US_WSREMS__Patient__c , RCA_case, Maci_programStr+'-MisclassificationRCA' );
                
            }
            US_WSREMS__REMS_Service_Summary__c extRSS = new US_WSREMS__REMS_Service_Summary__c();
            extRSS.id = RCA_case.US_WSREMS__REMS_Service_Summary__c;
            
            mapRSSKeyValue.put(RCA_case.US_WSREMS__Patient__c+'-'+RCA_case.id , rss_RCA);
            mapExtRSSKeyValue.put(RCA_case.US_WSREMS__Patient__c+'-'+RCA_case.id, extRSS);
            mapRSSKeyCase.put(RCA_case.US_WSREMS__Patient__c+'-'+RCA_case.id , case_RCA );
            mapTaskKeyValue.put(RCA_case.US_WSREMS__Patient__c+'-'+RCA_case.id , task_RCA);
            
        }
        
            Insert mapRSSKeyValue.values();
            
            for (string uniqueKey : mapRSSKeyCase.keySet()){
                Id RemsServiceId = mapRSSKeyValue.get(uniqueKey)?.id;
                  mapRSSKeyCase.get(uniqueKey).US_WSREMS__REMS_Service_Summary__c  = RemsServiceId;
                  mapTaskKeyValue.get(uniqueKey).WhatId = RemsServiceId;
                  mapExtRSSKeyValue.get(uniqueKey).US_WSREMS__Related_REMS_Services__c = RemsServiceId;
            }
            
            Insert mapRSSKeyCase.values();
            Insert mapTaskKeyValue.values();
            update mapExtRSSKeyValue.values();
          
        
    }
    
    public static US_WSREMS__REMS_Service_Summary__c createRCA_Service(Id ProgId ,Id RSS_recordtypeId, String requestorType, Id participantId , String Status ){
        
        US_WSREMS__REMS_Service_Summary__c RSS_RCA = new US_WSREMS__REMS_Service_Summary__c();
        RSS_RCA.RecordTypeId = RSS_recordtypeId;
        RSS_RCA.US_WSREMS__REMSProgram__c = ProgId;
		RSS_RCA.US_WSREMS__Requestor_Type__c = 'Patient';
        RSS_RCA.US_WSREMS__Participant__c = participantId;
        RSS_RCA.US_WSREMS__Status__c = Status;
        
        return RSS_RCA;
    }
    
    public static Task createRCA_Task (String Type, String Escalation, Id programId , Date DueDate, Id AssignToId , String TaskSub , Id ContactId){
        Task Task_RCA = new Task();
        Task_RCA.RecordTypeId = Task_Manual_rctypeId;
        Task_RCA.Type = Type;
        Task_RCA.SYN_Escalation_Type__c = Escalation;
        Task_RCA.Program_Name__c = programId;
        Task_RCA.ActivityDate = DueDate;
        Task_RCA.OwnerId  = AssignToId;
        Task_RCA.REMS_Program__c = 'Macitentan REMS';
        Task_RCA.Subject = TaskSub;
        Task_RCA.whoId = ContactId;
        return Task_RCA;
        
    }
    
    public static case createRCA_Case (Id cseRecordTypeId, String Status ,Id participantId, Case extCase, String ProgramRecordTypeControl  ){
        
        Case Case_RCA = new case();
        Case_RCA.RecordTypeId = cseRecordTypeId;
        Case_RCA.US_WSREMS__Participant__c = participantId;
        Case_RCA.US_WSREMS__Patient__c = participantId;
        Case_RCA.Status = Status;
        Case_RCA.US_WSREMS__First_Name__c = extCase.US_WSREMS__First_Name__c;
        Case_RCA.US_WSREMS__Last_Name__c = extCase.US_WSREMS__Last_Name__c;
        Case_RCA.US_WSREMS__DOB__c = extCase.US_WSREMS__DOB__c;
        Case_RCA.US_WSREMS__Patient_Risk_Category__c = extCase.US_WSREMS__Patient_Risk_Category__c;
        Case_RCA.SYN_Sponsor_Responsible__c = 'Actelion Pharmaceuticals US, Inc., a Johnson & Johnson Company';
        Case_RCA.US_WSREMS__Program_Picklist__c = extCase.US_WSREMS__Program_Picklist__c;
        Case_RCA.SYN_Prescriber__c = extCase.SYN_Prescriber__c; 
        Case_RCA.Prescriber_REMS_ID_Number__c = extCase.Prescriber_REMS_ID_Number__c;
        Case_RCA.SYN_Prescriber_First_Name__c = extCase.SYN_Prescriber_First_Name__c;
        Case_RCA.SYN_Prescriber_Last_Name__c = extCase.SYN_Prescriber_Last_Name__c;
        if(ProgramRecordTypeControl == Maci_programStr+'-Treatment_InterruptionRCA') {
            Case_RCA.Days_of_Interruption__c = (extCase.Days_of_Interruption__c != null) ? extCase.Days_of_Interruption__c : null;
            Case_RCA.Reason_for_Treatment_Interruption__c = extCase.Reason_for_Treatment_Interruption__c;
            Case_RCA.SYN_Patient_REMS_ID_Number__c = extCase.SYN_Patient_REMS_ID_Number__c;
            Case_RCA.RDA__c = extCase.CaseNumber;
        } else if(ProgramRecordTypeControl == Maci_programStr+'-MisclassificationRCA') {
            Case_RCA.SYN_Patient_REMS_ID_Number__c = (accountIdMap != null && accountIdMap.containsKey(participantId) && accountIdMap.get(participantId).SYN_Ref_Id__c != null) ? accountIdMap.get(participantId).SYN_Ref_Id__c : extCase.SYN_Patient_REMS_ID_Number__c;
        }
        
        return Case_RCA;
        
    }
	public static void MisclassificationReviewPendingTask(List<Case> Caselist) {
        Task task_RCA;
        List<Task> Task_RCA_Lst = new List<Task>();
        Id changeInReproPotentialStatusCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');
        for (Case cs :[SELECT Id,recordTypeId,RecordType.DeveloperName,Status,US_WSREMS__Outcome__c,ownerId,US_WSREMS__REMS_Program__c,US_WSREMS__Patient__c,US_WSREMS__Program_Picklist__c,US_WSREMS__REMS_Service_Summary__c,US_WSREMS__Patient__r.PersonContactId,
                    	ContactId,US_WSREMS__Patient_Risk_Category__c FROM Case WHERE Id IN: Trigger.New AND recordTypeId =: changeInReproPotentialStatusCaseRecTypeId AND US_WSREMS__Program_Picklist__c =: 'Macitentan REMS' AND Status =: 'Complete' ]){
                            if( cs.US_WSREMS__Outcome__c == 'Misclassification Review Pending' ){
                          task_RCA = createRCA_Task('Escalation','Reproductive Status Misclassification Review ',cs.US_WSREMS__REMS_Program__c,System.today(),Maci_Escalation_QueueId,'Reproductive Status Misclassification Review Task ',cs.US_WSREMS__Patient__r.PersonContactId);
                          task_RCA.WhatId = cs.US_WSREMS__REMS_Service_Summary__c;      
                          Task_RCA_Lst.add(task_RCA); 
                }
                            
            
        }
        try{
            insert Task_RCA_Lst;
        }catch(exception e){
            system.debug('---Error---'+e.getMessage());
        }
    }
    
}