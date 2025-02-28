@isTest
public class SYN_CertifiedPharmacyParticipant_Test {
    @TestSetup
    public static void createTestData() {
        list<US_WSREMS__REMS_Program__c> programObj = SYN_TestDataFactory.createSOXPrograms1(1,True,'Sodium Oxybate REMS');
        account pharmacyParticipantAcc = SYN_TestDataFactory.createPersonAccountforPrescriber('7441258649',456213,'7458963210',False, programObj[0].id);
        pharmacyParticipantAcc.US_WSREMS__DEA__c = '455546458';
        pharmacyParticipantAcc.US_WSREMS__Status__c = 'Certified';
        insert pharmacyParticipantAcc;
         
    }
    public static testMethod void SYN_CertifiedPharmacyMethod1() {
        Account pharmacyParticipantAcc = [Select Id ,FirstName,LastName,US_WSREMS__DEA__c,Phone From Account Limit 1];
        Test.startTest();
        list<Account> certifiedAccTest = SYN_CertifiedPharmacyParticipantctrl.getCertifiedAccounts(pharmacyParticipantAcc.FirstName,pharmacyParticipantAcc.LastName,pharmacyParticipantAcc.US_WSREMS__DEA__c,pharmacyParticipantAcc.Phone);
        list<Account> certifiedAccNameTest = SYN_CertifiedPharmacyParticipantctrl.getCertifiedAccounts('', pharmacyParticipantAcc.LastName, '', '');
        list<Account> certifiedAccDEATest = SYN_CertifiedPharmacyParticipantctrl.getCertifiedAccounts('', '', pharmacyParticipantAcc.US_WSREMS__DEA__c, '');
        list<Account> certifiedAccPhoneTest = SYN_CertifiedPharmacyParticipantctrl.getCertifiedAccounts('', '', '', pharmacyParticipantAcc.Phone);
        Test.stopTest();
        system.assertEquals(pharmacyParticipantAcc.ID, certifiedAccTest[0].Id); 
        system.assertEquals(pharmacyParticipantAcc.ID, certifiedAccNameTest[0].Id);
        system.assertEquals(pharmacyParticipantAcc.ID, certifiedAccDEATest[0].Id);
        system.assertEquals(pharmacyParticipantAcc.ID, certifiedAccPhoneTest[0].Id);
    }  
}