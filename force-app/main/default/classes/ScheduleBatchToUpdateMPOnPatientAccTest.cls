/*
* @File Name          : ScheduleBatchToUpdateMPOnPatientAccTest.cls
* @Description        : This test class is used for code coverage of ScheduleBatchToUpdateMPOnPatientAccount.cls
* @Author             : 
*/ 
@isTest()
public class ScheduleBatchToUpdateMPOnPatientAccTest {
     public static testMethod void testScheduleBatchToUpdateMPOnPatientAcc(){
       
          ScheduleBatchToUpdateMPOnPatientAccount batchInstance= new ScheduleBatchToUpdateMPOnPatientAccount();
          batchInstance.execute(null);
     }
}