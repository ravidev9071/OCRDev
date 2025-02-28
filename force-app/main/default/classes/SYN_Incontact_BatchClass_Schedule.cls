global class SYN_Incontact_BatchClass_Schedule implements Schedulable 
{
   global void execute(SchedulableContext sc) 
   {
      SYN_Incontact_BatchClass batchProcess = new SYN_Incontact_BatchClass(); 
      Database.executeBatch(batchProcess,1);
   }
}