/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-21-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest()
public class ScheduleAnnualPrePubertalBatch_Test {
     public static testMethod void testScheduleAnnualPrePubertalBatch(){
       
             ScheduleAnnualPrePubertalBatch batchInstance= new ScheduleAnnualPrePubertalBatch();
           batchInstance.execute(null);
           SYN_ScheduleFailedApexJobBatch batchInstance1= new SYN_ScheduleFailedApexJobBatch();
           batchInstance1.execute(null);
                     
        
     }

}