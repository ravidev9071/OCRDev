/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-29-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class ScheduleAnnualPrePubertalBatch implements Schedulable{
     global void execute(SchedulableContext sc)
     {
        String prgmName='Macitentan REMS';
        integer batchSize=integer.valueof(Label.PatientMonthlyPregancybatchSize);
        SYN_AnnualPrePubertalNotificationBatch  batchInstance = new SYN_AnnualPrePubertalNotificationBatch (prgmName,label.Annual_Prepubertal_30_Day_ReminderFax,label.Annual_Prepubertal_30_Day_Reminder); 
        database.executeBatch(batchInstance,batchSize);
     }
     

}