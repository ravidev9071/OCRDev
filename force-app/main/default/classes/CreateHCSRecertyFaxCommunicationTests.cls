@isTest
private class CreateHCSRecertyFaxCommunicationTests {
    @isTest
    private static void createHCSRecertificationFaxCommunicationRecTest() {

        Account authRep = new Account();
        authRep.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        authRep.Fax = '11111111';
        authRep.US_WSREMS__Email__c = 'test@test.com';

        Account accountRecord = new Account();
        accountRecord.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        accountRecord.US_WSREMS__ReCertification_Reminder_Date__c = System.today();
        accountRecord.US_WSREMS__VerificationAgentTaskDate__c = System.today();
        accountRecord.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        accountRecord.US_WSREMS__Authorized_Representative__r = authRep;
        accountRecord.US_WSREMS__Authorized_Representative__c = authRep.Id;
        accountRecord.US_WSREMS__Program_Picklist__c = SYN_Utilitycls.AVEED_PROGRAM_NAME;

        Account accountRecord1 = new Account();
        accountRecord1.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        accountRecord1.US_WSREMS__VerificationReminderDate__c = System.today();
        accountRecord1.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        accountRecord1.US_WSREMS__VerificationAgentTaskDate__c = System.today();
        accountRecord1.US_WSREMS__Authorized_Representative__r = authRep;
        accountRecord1.US_WSREMS__Authorized_Representative__c = authRep.Id;
        accountRecord1.US_WSREMS__Program_Picklist__c = SYN_Utilitycls.AVEED_PROGRAM_NAME;

        List<Account> accountList = new List<Account>();
        accountList.add(accountRecord);
        accountList.add(accountRecord1);

        exception ex;
        test.startTest();
            try{
                CreateHCSRecertyFaxCommunication.createHCSRecertificationFaxCommunicationRec(accountList);
            } catch(exception e){
                ex = e;
            }
        test.stopTest();
        system.assert(ex != null);
    }
}