/*
* @File Name          : SYN_BatchToUpdateMPOnPatientAccount.cls
* @Description        : This class is used to schedule the SYN_BatchToUpdateMPOnPatientAccount.cls
* @Author             : Thandavakrishna Dindu and Praveen Vellanki
*/ 
global class ScheduleBatchToUpdateMPOnPatientAccount implements Schedulable
{
     global void execute(SchedulableContext sc)
     {
        integer batchSize=integer.valueof(Label.PatientMonthlyPregancybatchSize);
        SYN_BatchToUpdateMPOnPatientAccount  batchInstance = new SYN_BatchToUpdateMPOnPatientAccount (); // Your batch class
        database.executeBatch(batchInstance,batchSize);
     }
     
}