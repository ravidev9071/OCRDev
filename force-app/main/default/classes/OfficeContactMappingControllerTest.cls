@isTest
public class OfficeContactMappingControllerTest {

  public static Account createofficecontactAccount(String NPI,Integer SLN,String phn,Boolean isCreate , Id programId){
    String officeContactRecType = REMSUtility.retrieveRecTypeNameId(REMSAppLiterals.ACCOUNT_OBJECT).get('Office Contact'); 
    Account accountObj = new Account();
    accountObj.FirstName= 'TestUser';
    accountObj.LastName = 'Program';
    accountObj.RecordTypeId = officeContactRecType;
    accountObj.US_WSREMS__Channel__c = 'fax';
    accountObj.Phone = phn;
    accountObj.US_WSREMS__National_Provider_Identifier__c = NPI;
    accountObj.US_WSREMS__Phone_Type__c = 'mobile';
    accountObj.US_WSREMS__EXT__c = '123';
    accountObj.Fax = phn;
    accountObj.US_WSREMS__Email__c ='test@test.com';
    accountObj.PersonEmail='test@test.com';
    accountObj.US_WSREMS__Preferred_Contact_Method__c = 'email';
    accountObj.US_WSREMS__REMS_Program__c = programId;
    if(isCreate){
        insert accountObj;
    }
    return accountObj;
} 

  public static List<US_WSREMS__REMS_Program__c> createPrograms(integer noOfRecords,boolean isCreate){
    List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
    for(integer i=0;i<noOfRecords;i++){
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'AVEED REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        programList.add(programObj);
    }
    
    if(isCreate && programList.size()>0){
        insert programList;
    }
    return programList; 
}
  @TestSetup
  static void createTestData() {
    List<US_WSREMS__REMS_Program__c> programList = createPrograms(
      1,
      false 
    );
    programList[0].name = 'Sample REMS Program';
    insert programList;

    Id prescriberRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Prescriber')
      .getRecordTypeId();

    Account accountDetail = SYN_TestDataFactory.createPersonAccountforPrescriber(
      '3234567890',
      1,
      '963963963963',
      false
    );
    accountDetail.US_WSREMS__REMS_Program__c = programList[0].Id;
    accountDetail.FirstName = 'Test';
    accountDetail.LastName = 'test';
    accountDetail.Phone = '9877987458';
    accountDetail.US_WSREMS__GMC_ID__c = '12345';
    accountDetail.US_WSREMS__NMC_ID__c = '12345';
    accountDetail.US_WSREMS__GPhC_ID__c = '12345';
    accountDetail.US_WSREMS__PSNI_ID__c = '12345';
    accountDetail.PersonEmail = 'test@test.com';
    accountDetail.US_WSREMS__DOB__c = date.parse('12/03/1988');
    accountDetail.shippingCity = 'Delhi';
    accountDetail.ShippingPostalCode = '12356';
    accountDetail.RecordTypeId = prescriberRecTypeId;
    insert accountDetail;

    Id officeContactRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Office_Contact')
      .getRecordTypeId();

    Account contactAccount=createofficecontactAccount('2000226666',3234587,'963963963963',false,programList[0].Id);
    contactAccount.FirstName = 'TestNew';
    contactAccount.LastName = 'testNew';
    contactAccount.Phone = '9877987458';
    contactAccount.US_WSREMS__GMC_ID__c = '1235';
    contactAccount.US_WSREMS__NMC_ID__c = '1235';
    contactAccount.US_WSREMS__GPhC_ID__c = '1235';
    contactAccount.US_WSREMS__PSNI_ID__c = '12345';
    contactAccount.PersonEmail = 'tesst@test.com';
    contactAccount.US_WSREMS__DOB__c = date.parse('12/03/1988');
    contactAccount.shippingCity = 'Delhi';
    contactAccount.ShippingPostalCode = '12356';
    contactAccount.RecordTypeId = officeContactRecTypeId;
    insert contactAccount;
  }

  @isTest
  public static void whenStringIsPassedGetAccounts() {
    List<US_WSREMS__REMS_Program__c> programId = [
      SELECT Id
      FROM US_WSREMS__REMS_Program__c
      WHERE Name = 'Sample REMS Program'
    ];
    Test.startTest();
    List<Account> listOfAccount = OfficeContactMappingController.getPrescriberAccountList(
      'Test',
      'Office_Contact',
      'Search By Email',
      programId[0].Id,
      'Prescriber Delegate'  
    );
    List<Account> accountList = OfficeContactMappingController.getPrescriberAccountList(
      'Test',
      'Prescriber',
      'test',
      programId[0].Id,
      'Prescriber Delegate'  
    );
    Test.stopTest();
    System.assert(!listOfAccount?.isEmpty(), 'Accounts Records Retrived');
  }

  @isTest
  public static void createAffiliationTestRecord() {
    List<Map<String, String>> accountList = new List<Map<String, String>>();
    Map<String, String> accountMap = new Map<String, String>();
    List<Account> listOfAccount = [
      SELECT Id, Name, US_WSREMS__REMS_Program__c
      FROM Account
      WHERE RecordType.DeveloperName = 'Prescriber'
    ];
    for (Account acc : listOfAccount) {
      accountMap.put('Id', acc.Id);
      accountMap.put('RemsId', acc.US_WSREMS__REMS_Program__c);
    }
    accountList.add(accountMap);
    List<Map<String, String>> accountPrescriberList = new List<Map<String, String>>();
    Map<String, String> prescriberMap = new Map<String, String>();
    List<Account> officeContactAccount = [
      SELECT Id, Name, US_WSREMS__REMS_Program__c
      FROM Account
      WHERE RecordType.DeveloperName = 'Office_Contact'
    ];
    string programName;
    for (Account acc : listOfAccount) {
      prescriberMap.put('Id', acc.Id);
      prescriberMap.put('RemsId', acc.US_WSREMS__REMS_Program__c);
      programName = acc.US_WSREMS__REMS_Program__c;
    }
    accountPrescriberList.add(prescriberMap);
    Test.startTest();
    OfficeContactMappingController.createAffiliationRecords(
      listOfAccount[0].Id,
      'Office_Contact','Office_Contact',
      accountPrescriberList,'Add_Office_Contacts',programName
    );
    OfficeContactMappingController.createAffiliationRecords(
      officeContactAccount[0].Id,
      'Prescriber', 'Prescriber',
      accountList,'Add_Prescriber',programName
    );
    OfficeContactMappingController.createAffiliationRecords(
      officeContactAccount[0].Id,
      OfficeContactMappingController.Health_Care_Setting, OfficeContactMappingController.Health_Care_Setting,
      accountList,OfficeContactMappingController.ADD_AR_HCS,programName
    );
     
    OfficeContactMappingController.createAffiliationRecords(
      officeContactAccount[0].Id,
      OfficeContactMappingController.INPATIENTPHARMACY, OfficeContactMappingController.INPATIENTPHARMACY,
      accountList,OfficeContactMappingController.ADD_AR_PHARMACY,programName
    );
      
    OfficeContactMappingController.fetchRecordTypeData(
      officeContactAccount[0].Id
    );
    Test.stopTest();
    List<US_WSREMS__Affiliation__c> affiliationList = [
      SELECT Id, Name
      FROM US_WSREMS__Affiliation__c
    ];
    System.assert(!affiliationList?.isEmpty(), 'Affiliation Records Created');
  }

  @isTest
  public static void validateAffiliationTestRecord() {
    List<Account> prescriberAccount = [
      SELECT Id, Name, US_WSREMS__REMS_Program__c
      FROM Account
      WHERE RecordType.DeveloperName = 'Prescriber'
    ];
    List<Account> officeContactAccount = [
      SELECT Id, Name, US_WSREMS__REMS_Program__c
      FROM Account
      WHERE RecordType.DeveloperName = 'Office_Contact'
    ];
    Test.startTest();
    Boolean affliationRecord = OfficeContactMappingController.validateAffiliationRecords(
      officeContactAccount[0].Id,
      prescriberAccount[0].Id,
      prescriberAccount[0].US_WSREMS__REMS_Program__c, 'Prescriber','Prescriber',OfficeContactMappingController.ADD_AR_PHARMACY_STAFF);
      Boolean hcsAffliationRecord = OfficeContactMappingController.validateAffiliationRecords(
          officeContactAccount[0].Id,
          prescriberAccount[0].Id,
          prescriberAccount[0].US_WSREMS__REMS_Program__c, OfficeContactMappingController.Health_Care_Setting,OfficeContactMappingController.Health_Care_Setting,OfficeContactMappingController.ADD_AR_PHARMACY_STAFF);
      Boolean pharmacyAffliationRecord = OfficeContactMappingController.validateAffiliationRecords(
          officeContactAccount[0].Id,
          prescriberAccount[0].Id,
          prescriberAccount[0].US_WSREMS__REMS_Program__c, OfficeContactMappingController.INPATIENTPHARMACY,OfficeContactMappingController.INPATIENTPHARMACY,OfficeContactMappingController.ADD_AR_PHARMACY_STAFF);
     OfficeContactMappingController.validateEnrollmentCase(officeContactAccount[0].Id,OfficeContactMappingController.ADD_AR_PHARMACY_STAFF);
    Test.stopTest();
    System.assert(!affliationRecord, 'No Duplicate record exists.');
  }
}