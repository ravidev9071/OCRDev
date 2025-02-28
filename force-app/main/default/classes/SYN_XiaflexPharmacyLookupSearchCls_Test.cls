@isTest
public class SYN_XiaflexPharmacyLookupSearchCls_Test {
	@isTest
    public static void  getAccounts(){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c ();
            programObj.Name = 'prgmName';
            programObj.US_WSREMS__Status__c  ='Active';
            programObj.REMS_Project_Code__c = 'BT1005';
            programObj.US_WSREMS__Program_State_Date__c  = System.today();
            programObj.US_WSREMS__Program_End_Date__c  = System.today().addDays(20);
            programList.add(programObj);
         insert programList; 
        account pharmacyAcc = SYN_TestDataFactory.createPharmacyAccount('741258963','7458269301',False,programList[0].id);
        pharmacyAcc.US_WSREMS__Status__c = 'Certified';
        pharmacyAcc.Program__c = 'XIAFLEX';//programObj[0].Name;
        pharmacyAcc.US_WSREMS__Program_Type__c='REMS';
        insert pharmacyAcc;
        List<Account> certifiedAccTest = SYN_XiaflexPharmacyLookupSearchCls.searchRecords(pharmacyAcc.name,'Healthcare','Lookup','REMS');
        System.assertEquals(0,certifiedAccTest.size(),'For Healthcare Loopkup Account');
    }
	@isTest
    public static void  searchHCPRecords(){
        US_WSREMS__REMS_Program__c program = SYN_TestDataUtility.createProgram('Xiaflex', 'Active');
        account presAcc = SYN_TestDataFactory.createPrescriberAccountWithNPI(program.id, Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId());
        account pharmacyAcc = SYN_TestDataFactory.createPharmacyAccount('741258963','7458269301',False,program.id);
        pharmacyAcc.US_WSREMS__Status__c = 'Certified';
        pharmacyAcc.Program__c = 'XIAFLEX';//programObj[0].Name;
        pharmacyAcc.US_WSREMS__Program_Type__c='REMS';
        insert pharmacyAcc;
        US_WSREMS__Affiliation__c aff = createAffiliation(null, pharmacyAcc.Id, presAcc.Id, 'Prescriber Affiliation', program);
        List<US_WSREMS__Affiliation__c> certifiedAccTest = SYN_XiaflexPharmacyLookupSearchCls.searchHCPRecords(presAcc.LastName,'Xiaflex','REMS');
        List<SObject> presAddressMap = SYN_XiaflexPharmacyLookupSearchCls.searchRecordsForLocator('United States', 'Prescribing', 'REMS');
        List<SObject> pharmaAddressMap = SYN_XiaflexPharmacyLookupSearchCls.searchRecordsForLocator('United States', 'HealthcareSetting', 'REMS');
        System.assertEquals(0,certifiedAccTest.size(),'For Prescriber Loopkup Account');
        System.assertEquals(0,presAddressMap.size(),'For Prescriber Locator Account');
        System.assertEquals(0,pharmaAddressMap.size(),'For Healthcare Locator Account');
    }
    
    public static US_WSREMS__Affiliation__c createAffiliation(Id arId, Id hcsId, Id presId, String recordType, US_WSREMS__REMS_Program__c program){
        Id recordTypeId = Schema.sObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        US_WSREMS__Affiliation__c affiliatedAcc = new US_WSREMS__Affiliation__c();
        affiliatedAcc.RecordTypeId = recordTypeId;
        affiliatedAcc.US_WSREMS__REMSProgram__c = program.Id;
        affiliatedAcc.US_WSREMS__isActive__c = true;
        affiliatedAcc.US_WSREMS__Start_Date__c = System.Today();
        if(recordType == 'Healthcare Setting Affiliation' || recordType == 'Prescriber Affiliation'){
            affiliatedAcc.US_WSREMS__Prescriber__c = presId;
        } else if(recordType == 'Authorized Representative Affiliation'){
            affiliatedAcc.US_WSREMS__Authorized_Representative__c = arId;
        }
        affiliatedAcc.US_WSREMS__Health_Care_Setting__c = hcsId;
        return affiliatedAcc;
    }
}