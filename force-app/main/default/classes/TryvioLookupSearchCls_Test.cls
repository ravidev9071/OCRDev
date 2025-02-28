@isTest
public class TryvioLookupSearchCls_Test {
	
    @isTest
    public static void  getAccounts(){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c ();
            programObj.Name = 'TRYVIO REMS';
            programObj.US_WSREMS__Status__c  ='Active';
            programObj.REMS_Project_Code__c = 'BT1005';
            programObj.US_WSREMS__Program_State_Date__c  = System.today();
            programObj.US_WSREMS__Program_End_Date__c  = System.today().addDays(20);
            programList.add(programObj);
         insert programList; 
        account pharmacyAcc = SYN_TestDataFactory.createPharmacyAccount('741258963','7458269301',False,programList[0].id);
        pharmacyAcc.US_WSREMS__Status__c = 'Certified';
        pharmacyAcc.Program__c = 'TRYVIO REMS';//programObj[0].Name;
        insert pharmacyAcc;
        List<Account> certifiedAccTest = TryvioLookupSearchCls.searchRecords(pharmacyAcc.name,'Healthcare', 'Lookup');
        System.assert(certifiedAccTest != null);
        certifiedAccTest = TryvioLookupSearchCls.searchRecords(pharmacyAcc.name,'Prescribers', 'Locator');
        System.assert(certifiedAccTest != null);
    }
}