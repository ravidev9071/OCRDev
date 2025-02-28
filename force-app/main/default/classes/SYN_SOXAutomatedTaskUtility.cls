public class SYN_SOXAutomatedTaskUtility {
    public static  Id bHoursId;
    public  Datetime SubtractDays(Datetime dStartDate, Integer iDays, String businessHoursname){  
       bHoursId=Id.valueof(SYN_CommonUtility.getBusinessHoursId(businessHoursname));
       dStartDate = getPreviousWorkingDay(dStartDate);
       for (Integer i = 0; i < iDays; i++){            
           dStartDate = dStartDate.addDays(-1); 
           if (!BusinessHours.isWithin(bHoursId, dStartDate)){           
            dStartDate = getPreviousWorkingDay(dStartDate);
           }
       }
       return dStartDate;
   }
   
     public  Datetime getPreviousWorkingDay(Datetime d){   
        //Check if new date is within working days
       if (!BusinessHours.isWithin(bHoursId, d)){           
           d = d.addDays(-1);
           return getPreviousWorkingDay(d);
       } else{           
           return d;
       }
   }
   public Datetime getcurrentDate(Map<String, Time> sox_startHours){
      
      
       Date datenow=System.today();
        Time startTimeOfADay = sox_startHours.get(DateTime.newInstance(datenow.year(), datenow.month(), datenow.day()).format('EEE')); 
       //getting the start business hours of that particular day
        Datetime startTimeOfCreatedDateBusinessHrs = DateTime.newInstance(datenow, startTimeOfADay); 
       return startTimeOfCreatedDateBusinessHrs;
   }
   
   public static Task createFollowupTask(Case caseObj ,Id queueId,Id recordTypeId,Id bHoursId){
        //bHoursId=Id.valueof(SYN_CommonUtility.getBusinessHoursId(System.Label.SOXBusinessHoursName));
       
       Task t=new Task();
       t.RecordTypeId=recordTypeId;
       t.Subject='Obtain Missing Information';
       t.Type='Call';
       t.WhatId=caseObj.US_WSREMS__REMS_Service_Summary__c;
       t.Program_Name__c =caseObj.US_WSREMS__REMS_Program__c;
       t.REMS_Program__c=caseObj.US_WSREMS__REMS_Program__r.Name;
       t.Type_of_Outbound_Call__c = 'Follow-up';
       t.OwnerId=queueId;
       t.ActivityDate=BusinessHours.nextStartDate(bHoursId , Date.today()).date();
       t.Status='Draft';
       t.WhoId =caseObj.US_WSREMS__Participant__r.PersonContactId;
     /*  Date dt=Date.today();
       t.Schedule_call_time__c = endhours.get(DateTime.newInstance(dt.year(), dt.month(), dt.day()).format('EEE'));
       t.Time_Zone__c ='EST';*/
       return t;
       
   }
   
    public static Task createDueDiligenceTask(Case caseObj ,Id queueId,Id recordTypeId,Id bHoursId){
       // bHoursId=Id.valueof(SYN_CommonUtility.getBusinessHoursId(System.Label.SOXBusinessHoursName));
       Task t=new Task(); 
       t.Subject = 'Close Service and Case - Due Diligence Exhausted';
       t.Type = 'Other';
       t.WhatId=caseObj.US_WSREMS__REMS_Service_Summary__c;
       t.Program_Name__c =caseObj.US_WSREMS__REMS_Program__c;
       t.REMS_Program__c=caseObj.US_WSREMS__REMS_Program__r.Name;
       t.OwnerId=queueId;
       t.Status='Draft';
       t.RecordTypeId=recordTypeId;
       t.WhoId =caseObj.US_WSREMS__Participant__r.PersonContactId;
       t.ActivityDate=BusinessHours.nextStartDate(bHoursId , Date.today()).date();
       return t;
       
   }

}