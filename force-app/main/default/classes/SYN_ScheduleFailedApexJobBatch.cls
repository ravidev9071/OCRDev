/**
 * @description       : 
 * @author            :Dileep kumar Gurram
 * @group             : 
 * @last modified on  : 03-21-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

    global class SYN_ScheduleFailedApexJobBatch implements Schedulable{
        global void execute(SchedulableContext sc)
        {
           integer batchSize=integer.valueof(Label.PatientMonthlyPregancybatchSize);
           SYN_FailedApexJobEmailBatch  batchInstance = new SYN_FailedApexJobEmailBatch (); 
           database.executeBatch(batchInstance,batchSize);
        }
        
   
   }