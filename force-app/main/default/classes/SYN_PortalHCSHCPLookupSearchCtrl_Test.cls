@isTest
public class SYN_PortalHCSHCPLookupSearchCtrl_Test {
    @isTest
    public static void  getAccounts(){
        list<US_WSREMS__REMS_Program__c> programObj = SYN_TestDataFactory.createProgram(1,True,'AVEED REMS','BT2815');
        insert programObj;
        account prescriberAcc = SYN_TestDataFactory.createPrescriberAccount('741258963','7458269301',False,programObj[0].id);
        prescriberAcc.US_WSREMS__Status__c = 'Certified';
        prescriberAcc.Program__c = 'AVEED REMS';
        insert prescriberAcc;
        
        List<Account> certifiedAccTest = SYN_PortalHCSHCPLookupSearchCtrl.searchRecords(prescriberAcc.FirstName);
        List<US_WSREMS__Affiliation__c> certifiedAccTest1 = SYN_PortalHCSHCPLookupSearchCtrl.searchHCPRecords(prescriberAcc.ShippingPostalCode);
        
    }
}