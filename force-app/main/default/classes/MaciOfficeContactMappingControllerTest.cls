/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-18-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class MaciOfficeContactMappingControllerTest {
  @TestSetup
  static void createTestData() {
    List<US_WSREMS__REMS_Program__c> programList = REMSTestDataFactoryL.createPrograms(1,false);
    programList[0].name='Sample REMS Program';
    insert programList;   
        
    Id prescriberRecTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get('Prescriber');  

    Account accountDetail=SYN_TestDataFactory.createPersonAccountforPrescriber('3234567890',12345,'963963963963',false);
    accountDetail.US_WSREMS__REMS_Program__c=programList[0].Id;
    accountDetail.FirstName='Test';
    accountDetail.LastName='test';
    accountDetail.Phone='9877987458';
    accountDetail.PersonEmail='test@test.com';
    accountDetail.shippingCity='Delhi';
    accountDetail.ShippingPostalCode='12345';
    accountDetail.RecordTypeId = prescriberRecTypeId ;
    insert accountDetail;      

    Id officeContactRecTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account').get('Office_Contact'); 

    Account contactAccount=SYN_TestDataFactory.createPersonAccountforPrescriber('3234587890',12345,'963963963963',false);
    contactAccount.US_WSREMS__REMS_Program__c=programList[0].Id;
    contactAccount.FirstName='TestNew';
    contactAccount.LastName='testNew';
    contactAccount.Phone='9877987458';
    contactAccount.PersonEmail='tesst@test.com';
    contactAccount.shippingCity='Delhi';
    contactAccount.ShippingPostalCode='12345';
    contactAccount.RecordTypeId = officeContactRecTypeId ;
    insert contactAccount;       
  }
    
  @isTest
  public static void whenStringIsPassedGetAccounts() {
    Test.startTest();
    List<Account> listOfAccount = MaciOfficeContactMappingController.getPrescriberAccountList('Test','Office Contact','Search By Email');
    List<Account> accountList = MaciOfficeContactMappingController.getPrescriberAccountList('Test','Prescriber','test');
    Test.stopTest();
    System.assert(!listOfAccount?.isEmpty(), 'Accounts Records Retrived');
  }
    
  @isTest
  public static void createAffiliationTestRecord() {
    List<Map<String,String>> accountList = new List<Map<String,String>>();
    Map<String,String> accountMap = new Map<String,String>();
    List<Account> listOfAccount = [SELECT Id , Name , US_WSREMS__REMS_Program__c FROM Account WHERE RecordType.Name = 'Prescriber'];
    for (Account acc : listOfAccount){
      accountMap.put('Id',acc.Id);
      accountMap.put('RemsProgram',acc.US_WSREMS__REMS_Program__c); 
    }
    accountList.add(accountMap);
    List<Map<String,String>> accountPrescriberList = new List<Map<String,String>>();
    Map<String,String> prescriberMap = new Map<String,String>();
    List<Account> officeContactAccount = [SELECT Id , Name , US_WSREMS__REMS_Program__c FROM Account WHERE RecordType.Name = 'Office Contact'];
    for (Account acc : listOfAccount){
      prescriberMap.put('Id',acc.Id);
      prescriberMap.put('RemsProgram',acc.US_WSREMS__REMS_Program__c); 
    }
    accountPrescriberList.add(prescriberMap);
    Test.startTest();
    MaciOfficeContactMappingController.createPrescriberAffiliationRecords(listOfAccount[0].Id ,'Office Contact', accountPrescriberList, 'Opt-in', null);
    MaciOfficeContactMappingController.createPrescriberAffiliationRecords(officeContactAccount[0].Id ,'Prescriber', accountList, 'Opt-in', null);
    MaciOfficeContactMappingController.fetchRecordTypeData(officeContactAccount[0].Id);
    Test.stopTest();
    List<US_WSREMS__Affiliation__c> affiliationList = [SELECT Id , Name From US_WSREMS__Affiliation__c];
    System.assert(!affiliationList?.isEmpty(), 'Affiliation Records Created');
  }
    
  @isTest
  public static void validateAffiliationTestRecord() {
    List<Account> prescriberAccount = [SELECT Id , Name , US_WSREMS__REMS_Program__c FROM Account WHERE RecordType.Name = 'Prescriber'];
    List<Account> officeContactAccount = [SELECT Id , Name , US_WSREMS__REMS_Program__c FROM Account WHERE RecordType.Name = 'Office Contact'];
    Test.startTest();
    Boolean affliationRecord = MaciOfficeContactMappingController.validateAffiliationRecords(officeContactAccount[0].Id , prescriberAccount[0].Id , prescriberAccount[0].US_WSREMS__REMS_Program__c );
    Test.stopTest();
  }
}