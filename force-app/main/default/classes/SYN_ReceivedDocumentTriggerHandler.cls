public class SYN_ReceivedDocumentTriggerHandler {
    
    public static Map<String, String> progmap = new Map<String, String>();
    public static Map<String, Id> progIdmap = new Map<String, Id>();
    public static Set<String> programNameSet = new Set<String>();
	public static Map<String, String> programQueueMap = new Map<String, String>();
    public static Map<String, Id> queueIdmap = new Map<String, Id>();
	   
    public static void updateREMSProgram(List<ReceivedDocument> receiveddocs){
        
        Program_Fax_Configuration__mdt[] prgfax = [SELECT MasterLabel, QualifiedApiName, Program_Fax_Queue__c, REMS_Program__c ,Fax_Number__c FROM Program_Fax_Configuration__mdt WHERE Active__c = TRUE];
        for(Program_Fax_Configuration__mdt prg : prgfax){
		
            progmap.put(prg.Fax_Number__c, prg.REMS_Program__c);
			programQueueMap.put(prg.Fax_Number__c, prg.Program_Fax_Queue__c);
        }
        
		for(Group queueNameList : [SELECT Id, Developername FROM Group WHERE Developername IN:programQueueMap.values() AND Type = 'Queue']){
           
		   queueIdmap.put(queueNameList.Developername, queueNameList.Id);
        }
	   
        for(ReceivedDocument doc : receiveddocs){
		
            if(progmap != NULL && progmap.keySet().contains(doc.Program_Fax_Number__c)){
                programNameSet.add(progmap.get(doc.Program_Fax_Number__c));
            }
        }
        
        if(programNameSet.size() > 0){
		
            List<US_WSREMS__REMS_Program__c> rems_program= [SELECT id,name FROM US_WSREMS__REMS_Program__c WHERE Name IN :programNameSet];
            for(US_WSREMS__REMS_Program__c rems : rems_program){
                progIdmap.put(rems.name,rems.Id);
            }
        }	
        
        for(ReceivedDocument recdoc: receiveddocs){
			
			recdoc.Processing_Status__c = 'Unassigned';
            if(progmap.keySet().contains(recdoc.Program_Fax_Number__c)){
                if(progIdmap.keySet().contains(progmap.get(recdoc.Program_Fax_Number__c))){
                    recdoc.REMS_Program__c=progIdmap.get(progmap.get(recdoc.Program_Fax_Number__c));
                }
            }
			
            if(programQueueMap.containsKey(recdoc.Program_Fax_Number__c) && (queueIdmap.get(programQueueMap.get(recdoc.Program_Fax_Number__c)) !=null)) {
			
				recdoc.OwnerId = queueIdmap.get(programQueueMap.get(recdoc.Program_Fax_Number__c));			   
			}	            
        }        
    }
    
    public static void updateAssignedProcessingTime(List<ReceivedDocument> receiveddocList){
       // REMS_Program__c
       String businessHoursId;
        Id programId= SYN_CommonUtility.SOXprogramId();
        String SoxBHId = SYN_CommonUtility.getBusinessHoursId(System.Label.SOXBusinessHoursName);
        String clozapineBHId = SYN_CommonUtility.getBusinessHoursId(System.Label.ClozapineBusinessHoursName);
        Map<String, Time> endHours = SYN_CommonUtility.getBusinessEndHours(System.Label.ClozapineBusinessHoursName);
            
		for(ReceivedDocument receiveddoc : receiveddocList ){
			if(receiveddoc.REMS_Program__c == programId){
				businessHoursId=SoxBHId;
			}else{
				 businessHoursId=clozapineBHId;
			}
			
			if(receiveddoc.First_Assigned_Date__c != NULL){
				
				Map<String, Long> timeEleMap = SYN_CommonUtility.calculateBusinessHours(businessHoursId, receiveddoc.CreatedDate, receiveddoc.First_Assigned_Date__c);
				String totalTime = String.valueOf(timeEleMap.get('hours')) + ' hrs ' +  String.valueOf(timeEleMap.get('mins')) +' mins'; 
				receiveddoc.Assigned_Processing_Time_in_Mins__c = (Integer.valueOf(timeEleMap.get('hours')*60) +Integer.valueof(timeEleMap.get('mins')));
				receiveddoc.Assigned_Processing_Time__c = totalTime;                     
									
			}  
		}   
        
    }
    
    public static void updateProcessingStatus(List<ReceivedDocument> receivedList, Map<Id,ReceivedDocument> oldValues){
        List<ReceivedDocument> receivedDocOwnerChanged = new List<ReceivedDocument>();
        List<Id> clozapineUser = SYN_CommonUtility.getUserFromPG(system.label.PublicGroupClozapineRW );
        String errorMsg = System.label.Clozapine_Owner_Error_Msg; 
         Id programId= SYN_CommonUtility.SOXprogramId();
        Id piaSkyprogramId= SYN_CommonUtility.PiaSkyprogramId();//116 PiaSky
        Id aveedProgramId =SYN_CommonUtility.getProgramId(SYN_Utilitycls.AVEED_PROGRAM_NAME);
        Id ClozapineprogramId;
        List<Id> SoxUser = SYN_CommonUtility.getUserFromPG(system.label.PublicGroupSOXRW );
        List<Id> SoxQueueUser = SYN_CommonUtility.getUserFromQueue(SYN_Utilitycls.Sox_queue_name );
        String soxErrorMsg = System.label.SOX_Owner_Error_Message; 
        List<Id> piaSkyUser = SYN_CommonUtility.getUserFromPG(system.label.PublicGroupPiaSkyRW );//116 PiaSky
        List<Id> piaSkyQueueUser = SYN_CommonUtility.getUserFromQueue(SYN_Utilitycls.PiaSky_queue_name );//116 PiaSky
        List<Id> aveedUser = SYN_CommonUtility.getUserFromPG(SYN_Utilitycls.AVEED_PublicGroup );
        List<Id> aveedQueueUser = SYN_CommonUtility.getUserFromQueue(SYN_Utilitycls.AVEED_QueueName );
        String piaSkyErrorMsg = System.label.PiaSky_Owner_Error_Message;//116 PiaSky
        for (US_WSREMS__REMS_Program__c prgm : [select id from US_WSREMS__REMS_Program__c  where name ='Clozapine REMS' LIMIT 1]){
            ClozapineprogramId = prgm.id;
       }
        for(ReceivedDocument rc:receivedList){
            ReceivedDocument beforeUpdate = oldValues.get(rc.id);           
            if(beforeUpdate.OwnerId !=rc.OwnerId && rc.OwnerID.getsobjecttype() == User.sobjecttype ){
                if(rc.REMS_Program__c == programId){
                    if ((!SoxUser.contains(rc.OwnerId)) && (!SoxQueueUser.contains(rc.OwnerId))){
                    rc.adderror(soxErrorMsg);
                	} 
                }else if(rc.REMS_Program__c == piaSkyprogramId){
                    if ((!piaSkyUser.contains(rc.OwnerId)) && (!piaSkyQueueUser.contains(rc.OwnerId))){
                    rc.adderror(piaSkyErrorMsg);
                	}
                }else if (rc.REMS_Program__c == ClozapineprogramId) {
                    if (!clozapineUser.contains(rc.OwnerId)){
                    rc.adderror(errorMsg);
                	} 
                }else if(rc.REMS_Program__c == aveedProgramId){
                    if ((!aveedUser.contains(rc.OwnerId)) && (!aveedQueueUser.contains(rc.OwnerId))){
                        rc.adderror(SYN_Utilitycls.AVEED_Owner_Error_Msg);
                        } 
                }
               
                rc.Processing_Status__c='Assigned';  
                rc.First_Assigned_Date__c=System.now();
            }
             if (beforeUpdate.First_Assigned_Date__c != rc.First_Assigned_Date__c){
                receivedDocOwnerChanged.add(rc);
            }
        }
        if (receivedDocOwnerChanged.size() >0 ){
            updateSLAStatus(receivedDocOwnerChanged);
        }
        
    }
 
    public static void updateShareRecord(Map<Id, ReceivedDocument> newMap, Map<Id, ReceivedDocument> oldMap){
        
        List<sObject> sObjectList = new List<sObject>();
        for(ReceivedDocument rdRec : newMap.values()){
            
            ReceivedDocument rdRecOldMap = oldMap.get(rdRec.Id);
            if(rdRecOldMap.OwnerId != rdRec.OwnerId || rdRecOldMap.Program_Name__c != rdRec.Program_Name__c){
                
                sObjectList.add(rdRec);
            }
            
        }
        
        if(!sObjectList.isEmpty()){
            
            SYN_SharingUtility.createShareRecordsList(sObjectList, 'ReceivedDocumentShare','ReceivedDocument');
        }
    }
    
    public static void updateSLAStatus(List<ReceivedDocument> newReceivedDocList){
        Id programId= SYN_CommonUtility.SOXprogramId();
        String clozapineBHId = SYN_CommonUtility.getBusinessHoursId(System.Label.ClozapineBusinessHoursName);
        String SoxBHId = SYN_CommonUtility.getBusinessHoursId(System.Label.SOXBusinessHoursName);
        String businessHoursId;
        Map<String, Time> clozapine_endHours = SYN_CommonUtility.getBusinessEndHours(System.Label.ClozapineBusinessHoursName);
        Map<String, Time> sox_endHours = SYN_CommonUtility.getBusinessEndHours(System.Label.SOXBusinessHoursName);
      	Map<String, Time> endHours;
        DateTime createDate;
        Integer NoOfBusinessDays = Integer.valueOf(System.Label.NumOfBusinessDays);
        for (ReceivedDocument rcd : newReceivedDocList){
            createDate = rcd.CreatedDate;
            if(rcd.REMS_Program__c == programId){
                    businessHoursId=SoxBHId;
                	endHours=sox_endHours;
                }else{
                     businessHoursId=clozapineBHId;
                     endHours=clozapine_endHours;
                }
            
            Datetime endTimeOfCreateddatePlusMins;
            createDate = rcd.CreatedDate;             
            
            if(BusinessHours.isWithin(businessHoursId , createDate)){
                
                Time endTimeOfADay = endHours.get(createDate.format('EEE'));       //getting the End business hours of that particular day
                Datetime endTimeOfCreatedDateBusinessHrs = DateTime.newInstance(rcd.CreatedDate.date(), endTimeOfADay);  // constructing the created business day with end time 
                endTimeOfCreateddatePlusMins = endTimeOfCreatedDateBusinessHrs.addMinutes(5);  //adding 5mins to make after business hours to get the next business day
                
            }else{
            
                endTimeOfCreateddatePlusMins = createDate;
            }           
            
            Datetime nextBusinessdayStartDate = BusinessHours.nextStartDate(businessHoursId, endTimeOfCreateddatePlusMins);  //getting the nextbusiness day
            Time endTimeOfNextBusinessday = endHours.get(nextBusinessdayStartDate.format('EEE')); // constructing the next business day with end time  
            Datetime endDatetimeNextday= DateTime.newInstance(nextBusinessdayStartDate.date(), endTimeOfNextBusinessday);
            
            if (rcd.First_Assigned_Date__c <= endDatetimeNextday ){
            
                rcd.SLA_Status__c = 'Within SLA';
            }else {
            
                rcd.SLA_Status__c = 'Outside SLA';
            }
          
        }
    }
}