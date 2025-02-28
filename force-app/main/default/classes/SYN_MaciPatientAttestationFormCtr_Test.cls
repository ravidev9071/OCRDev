/**************************************************************************
* Name :   SYN_InvitePharamcyStaffController_Test

Modification Log:
----------------------------------------------------------------------------------
Developer               Date                   Description
-----------------------------------------------------------------------------------
Prasanth Kumar        06/03/2023              Initial Version
*********************************************************************************/


@isTest
public class SYN_MaciPatientAttestationFormCtr_Test{
    
    @isTest
    public static void PatientEnrollmentSignature_Test() {
         // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        User usr;
        Account prescriberAccount;
        Account patientAccount;
        Case patietnEnrollmentCase;
        Test.StartTest();
        System.runAs (communitydefaulowner) {
        
            // Create Prescriber Account
            prescriberAccount= SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
            
            id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
            
            patietnEnrollmentCase = SYN_TestDataUtility.createNewPatientEnrollmentCase(programObj.Id,'Macitentan REMS',prescriberAccount,patientAccount);
            SYN_MaciPatientAttestationFormCtr.getCurrentPatientInfo(patietnEnrollmentCase.id);
            SYN_MaciPatientAttestationFormCtr.saveSignature(patietnEnrollmentCase,'Signed','testpdf');
            SYN_MaciPatientAttestationFormCtr.addPatientEnrollmentFormtoAccount(patietnEnrollmentCase);     
           
        }
           
        Test.StopTest();
    }
    
    @isTest
    public static void PatientEnrollmentSignatureNegative_Test() {
         // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        User usr;
        Account prescriberAccount;
        Account patientAccount;
        Case patietnEnrollmentCase;
        Test.StartTest();
        System.runAs (communitydefaulowner) {
        
            // Create Prescriber Account
            prescriberAccount= SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
            
            id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
            
            patietnEnrollmentCase = SYN_TestDataUtility.createNewPatientEnrollmentCase(programObj.Id,'Macitentan REMS',prescriberAccount,patientAccount);
            SYN_MaciPatientAttestationFormCtr.SavePrescriberSignature(patientAccount.id,'null','','');
           
        }
           
        Test.StopTest();
    }
    
    @isTest
    public static void PatientEnrollmentViewForm_Test() {
    
         // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        User usr;
        Account prescriberAccount;
        Account patientAccount;
        Case patietnEnrollmentCase;
        Test.StartTest();
        System.runAs (communitydefaulowner) {
        
            // Create Prescriber Account
            prescriberAccount= SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
            
            id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
            
            patietnEnrollmentCase = SYN_TestDataUtility.createNewPatientEnrollmentCase(programObj.Id,'Macitentan REMS',prescriberAccount,patientAccount);
            ApexPages.currentPage().getParameters().put('id', patietnEnrollmentCase.US_WSREMS__Patient__c);
            SYN_MaciPatientEnrollmentViewFormCtr frmController= new SYN_MaciPatientEnrollmentViewFormCtr();  
            frmController.getCs();
            frmController.getAttachments();
           
        }
           
        Test.StopTest();
    }
    
}