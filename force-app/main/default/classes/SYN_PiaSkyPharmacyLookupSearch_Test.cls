@isTest
public class SYN_PiaSkyPharmacyLookupSearch_Test {
    @isTest
    public static void  getAccounts(){
        US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c ();
        programObj.Name = 'PiaSky REMS';
        programObj.US_WSREMS__Status__c  ='Active';
        programObj.REMS_Project_Code__c = 'BT1005';
        programObj.US_WSREMS__Program_State_Date__c  = System.today();
        programObj.US_WSREMS__Program_End_Date__c  = System.today().addDays(20);
        insert programObj; 
       
        id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.Name = 'TestPharmact';
        accountObj.US_WSREMS__Channel__c = 'fax';
        accountObj.Rating = 'Hot';
        accountObj.Type = 'Prospect';
        accountObj.Industry = 'Banking';
        accountObj.Ownership = 'Public';
        accountObj.Phone = '7458269301';
        accountObj.AccountNumber = '741258963';
        accountObj.Sic = 'Test Site';
        accountObj.RecordTypeId = recordTypeId;
        accountObj.ShippingCountry = 'United States';
        accountObj.ShippingState = 'Alabama';
        accountObj.ShippingStreet = 'Test Street';
        accountObj.ShippingCity = 'Test City';
        accountObj.ShippingPostalCode = '12345';
        accountObj.US_WSREMS__REMS_Program__c = programObj.id;
        accountObj.US_WSREMS__Status__c = 'Certified';
        accountObj.Program__c = 'PiaSky REMS';
        insert accountObj;
        
        List<Account> certifiedAccTest = SYN_PiaSkyPharmacyLookupSearchCls.searchRecords(accountObj.name,accountObj.ShippingCity,accountObj.ShippingState,accountObj.ShippingPostalCode);
       SYN_PiaSkyPharmacyLookupSearchCls.getCerifiedPharmacies('asc');
    }
     @isTest
    public static void  getPicklistValues(){
        SYN_PiaSkyPharmacyLookupSearchCls.getPicklistValues('Account','Salutation');
        
    }
}