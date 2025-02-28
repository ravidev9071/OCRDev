@isTest()
public class MaciRDABanner_Test {
 @isTest
    public static void getCurrentRDARecord_Test() {
       id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id recordTypeIdPharmacy = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
        id casePDARecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();
        id recordTypeIdREMSService = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Pre_Dispense_Authorization').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        US_WSREMS__Program_Users__c programUser = SYN_TestDataUtility.createProgramUser(UserInfo.getUserId(),programObj.id);
        Test.StartTest();   
        Account prescAccount = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        Account patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
        Account pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy);
        Account pharmCParticipanAccount = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,recordTypeIdPharmacyParticipant);
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c(US_WSREMS__REMSProgram__c = programObj.id,US_WSREMS__Requestor_Type__c = 'Pharmacy',US_WSREMS__Participant__c = pharmCAccount.id, recordTypeId = recordTypeIdREMSService);
        Insert serviceObj;
        US_WSREMS__Affiliation__c createAffiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmCParticipanAccount.Id,pharmCAccount.Id);
        
        Case caseObjRDA = SYN_TestDataUtility.createaRDACase(casePDARecordTypeId,programObj.id,prescAccount,patientAccount,pharmCAccount,pharmCParticipanAccount,serviceObj);
        Case objecase=MaciRDABanner.getCurrentRDARecord(caseObjRDA.Id);
        
       // Verify that the Case record is populated correctly in the controller
        System.assertEquals(caseObjRDA.Id, objecase.Id);
       
        
        Test.StopTest();
               
    }
}