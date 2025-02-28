/*@isTest()
public class SYN_InpatientPharmacyFormController_Test {
    
    @isTest
    public static void getPharmacyInfo_Test() {
        id recordTypeIdPharmacy = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        US_WSREMS__Program_Users__c programUser = SYN_TestDataUtility.createProgramUser(UserInfo.getUserId(),programObj.id);
        Test.StartTest();   
        Account pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy);
        Account pharmCParticipanAccount = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,recordTypeIdPharmacyParticipant);
         US_WSREMS__Affiliation__c createAffiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmCParticipanAccount.Id,pharmCAccount.Id);
          
        account pharmAcc= SYN_InpatientPharmacyFormController.getPharmacyInfo(pharmCAccount,programObj.id);
        //SYN_InpatientPharmacyFormController inPatient = new SYN_InpatientPharmacyFormController();
        //SYN_InpatientPharmacyFormController();
        Test.StopTest();
        
    }
    
     @isTest
    public static void getAuthorizedReps_Test() {
        id recordTypeIdPharmacy = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
        
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        US_WSREMS__Program_Users__c programUser = SYN_TestDataUtility.createProgramUser(UserInfo.getUserId(),programObj.id);
        Test.StartTest();   
        Account pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy);
        Account pharmCParticipanAccount = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,recordTypeIdPharmacyParticipant);
       //  US_WSREMS__Affiliation__c createAffiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmCParticipanAccount.Id,pharmCAccount.Id);
        case pharmacycase = SYN_TestDataUtility.createCasePharmacyAuthorizedTest(caseRecordTypeId, programObj.Id,pharmCAccount.Id, pharmCParticipanAccount.Id); 
        Case getAuthorizedReps= SYN_InpatientPharmacyFormController.getAuthorizedReps(pharmCAccount,programObj.id,pharmCParticipanAccount);
        
        // PageReference pageRef = Page.Maci_Inpatient_enrollment;
        // Test.setCurrentPage(pageRef);
         //ApexPages.StandardController sc = new ApexPages.StandardController(pharmacycase);
        // SYN_InpatientPharmacyFormController controller = new SYN_InpatientPharmacyFormController() ;
        
        Test.StopTest();
        
    }
}
*/
@isTest()
public class SYN_InpatientPharmacyFormController_Test {
 @isTest
    public static void SYN_InpatientPharmacyForm_Test() {
       // Pharmacy account record type Id 
        Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        Id pharmOutPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
         // Creating Rems Program
         US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        
            Test.StartTest();
            account pharmacyAcc = SYN_TestDataUtility.createPharmacyAccountTest(programObj.id,PharmacyAccRecordTypeId);
            case pharmacyCase = SYN_TestDataUtility.createCasePharmacyTest(pharmOutPatCaseRecTypeId,programObj.Id,pharmacyAcc.Id);
            
            PageReference pageRef = Page.Maci_Inpatient_enrollment;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',pharmacyCase.SYN_Pharmacy__c);
            SYN_InpatientPharmacyFormController inPatient = new SYN_InpatientPharmacyFormController();
        
         // Set the current page reference with the Case record Id
       // Test.setCurrentPageReference(new PageReference('/apex/yourPageName?Id=' + testCase.Id));

        // Instantiate the controller class
      //  SYN_MaciReportableEventFormCtr controller = new SYN_MaciReportableEventFormCtr();

        // Verify that the Case record is populated correctly in the controller
        System.assertEquals(pharmacyCase.SYN_Pharmacy__c, inPatient.getac().SYN_Pharmacy__c);
       
          //  outPatient.getac();
           
            Test.StopTest();         
    }
}