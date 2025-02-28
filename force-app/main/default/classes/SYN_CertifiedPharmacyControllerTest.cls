@isTest
public class SYN_CertifiedPharmacyControllerTest {
    @isTest
    public static void  getAccounts(){
        list<US_WSREMS__REMS_Program__c> programObj = SYN_TestDataFactory.createSOXPrograms1(1,True,'Sodium Oxybate REMS');
        account pharmacyAcc = SYN_TestDataFactory.createPharmacyAccount('741258963','7458269301',False,programObj[0].id);
        pharmacyAcc.US_WSREMS__NPI__c = '7441258649';
        pharmacyAcc.US_WSREMS__DEA__c = '455546458';
        pharmacyAcc.US_WSREMS__Status__c = 'Certified';
        insert pharmacyAcc;
        List<Account> certifiedAccTest = SYN_CertifiedPharmacyController.getCertifiedAccounts(pharmacyAcc.Name,pharmacyAcc.US_WSREMS__DEA__c,pharmacyAcc.US_WSREMS__NPI__c);
        system.assertEquals(pharmacyAcc.ID, certifiedAccTest[0].Id);
    }
}