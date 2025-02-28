/**************************************************************************
* Name :   SYN_MaciReportableEventFormCtr_Test

Modification Log:
----------------------------------------------------------------------------------
Developer               Date                   Description
-----------------------------------------------------------------------------------
DG                     07/06/2023              Initial Version
*********************************************************************************/

@IsTest
private class SYN_MaciReportableEventFormCtr_Test {
    @IsTest
    static void SYN_MaciReportableEventFormCtr_Test() {
        // Create a test Case record
        Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        Id pharmOutPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
         // Creating Rems Program
         US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        
            Test.StartTest();
            account pharmacyAcc = SYN_TestDataUtility.createPharmacyAccountTest(programObj.id,PharmacyAccRecordTypeId);
            case pharmacyCase = SYN_TestDataUtility.createCasePharmacyTest(pharmOutPatCaseRecTypeId,programObj.Id,pharmacyAcc.Id);

        // Set the current page reference with the Case record Id
        Test.setCurrentPageReference(new PageReference('/apex/yourPageName?Id=' + pharmacyCase.Id));

        // Instantiate the controller class
        SYN_MaciReportableEventFormCtr controller = new SYN_MaciReportableEventFormCtr();

        // Verify that the Case record is populated correctly in the controller
        System.assertEquals(pharmacyCase.Id, controller.getCs().Id);
        
        Test.StopTest();
    }
}