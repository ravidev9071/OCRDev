@isTest
public with sharing class SendHCSRecertificationFaxReminderJobTest {

    @isTest
    private static void SendHCSRecertificationFaxReminderTest(){

        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'AVEED REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;

        Account hcsAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId());
        hcsAccount.US_WSREMS__ReCertification_Reminder_Date__c = System.today();
        hcsAccount.US_WSREMS__Program_Picklist__c = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        update hcsAccount;

        Test.startTest();
            SendHCSRecertificationFaxReminderJob batchJob = new SendHCSRecertificationFaxReminderJob();
            DataBase.executeBatch(batchJob); 
        Test.stopTest();
    }
}