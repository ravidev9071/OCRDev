@isTest
private class HCSAccountDBTest {

    @isTest
    private static void getHCSAccountTest() {
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;

        Test.startTest();
        Account account = new Account();
        Account hcsAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId());
        Test.setCurrentPageReference(new PageReference('/apex/yourPageName?Id=' + hcsAccount.Id));
            // Instantiate the controller class
            HCSAccountDB controller = new HCSAccountDB();

        // Verify that the Case record is populated correctly in the controller
        System.assertEquals(hcsAccount.Id, controller.getAccount().Id);
        Test.stopTest();
    }
}