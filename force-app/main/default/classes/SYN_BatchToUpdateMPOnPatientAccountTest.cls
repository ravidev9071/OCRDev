/*
* @File Name          : SYN_BatchToUpdateMPOnPatientAccountTest.cls
* @Description        : This is a test class for the batch class(SYN_BatchToUpdateMPOnPatientAccount) that will collect all the monthly pregnancy test records data that exceeds 30 days or 
                        counseling records that are equals 31 days and updates them.
* @Author             : Praveen Vellanki
*/
@isTest
public class SYN_BatchToUpdateMPOnPatientAccountTest {
    @isTest
    public static void batchToUpdatePregnancyRecordedOnAccountTest() {
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        
        Account createPatientAccount = SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        createPatientAccount.Monthly_Pregnancy_Test_Recorded__c = 'Yes';
        createPatientAccount.Counseling_Recorded__c = True;
        createPatientAccount.Monthly_Pregnancy_Test_Date__c = Date.newInstance(1988, 12, 9);
        createPatientAccount.Counseling_Completion_Date__c = Date.newInstance(2023, 8, 15);
        update createPatientAccount;
        
        Account createPatientAccount1 = SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        createPatientAccount1.Monthly_Pregnancy_Test_Recorded__c = 'Yes';
        //createPatientAccount1.Counseling_Recorded__c = True;
        createPatientAccount1.Monthly_Pregnancy_Test_Date__c = Date.newInstance(1988, 12, 9);
        //createPatientAccount1.Counseling_Completion_Date__c = Date.newInstance(2023, 8, 15);
        update createPatientAccount1;
        
        Account createPatientAccount2 = SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        //createPatientAccount2.Monthly_Pregnancy_Test_Recorded__c = 'Yes';
        createPatientAccount2.Counseling_Recorded__c = True;
        //createPatientAccount2.Monthly_Pregnancy_Test_Date__c = Date.newInstance(1988, 12, 9);
        createPatientAccount2.Counseling_Completion_Date__c = Date.newInstance(2023, 8, 15);
        update createPatientAccount2;

        Test.startTest();
            SYN_BatchToUpdateMPOnPatientAccount obj = new SYN_BatchToUpdateMPOnPatientAccount();
            DataBase.executeBatch(obj); 
        Test.stopTest();
        
    }
}