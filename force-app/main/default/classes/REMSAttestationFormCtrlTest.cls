/**************************************************************************
* Name :   REMSAttestationFormCtrlTest

Modification Log:
----------------------------------------------------------------------------------
Developer               Date                   Description
-----------------------------------------------------------------------------------
Tarun Earle           12/07/2023              Initial Version
*********************************************************************************/

@isTest
public class REMSAttestationFormCtrlTest {
    @TestSetup
    static void testDataSetup() {
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('TRYVIO REMS','Active');
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.FirstName= 'TestUser';
        accountObj.LastName = 'Program';
        accountObj.RecordTypeId = recordTypeId;
        //accountObj.US_WSREMS__Channel__c  = 'Fax';
        accountObj.Phone = '9999999999';
        accountObj.US_WSREMS__NPI__c  = '9999999999';
        accountObj.US_WSREMS__EXT__c  = '123';
        accountObj.Fax = '9999999999';
        accountObj.US_WSREMS__Email__c  ='testmaci@test.com';
        accountObj.US_WSREMS__Preferred_Contact_Method__c  = 'Email';
        accountObj.US_WSREMS__REMS_Program__c = programObj.Id;
        insert accountObj;
        
        Account oAcc = new Account();
        Id IpRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inpatient_Pharmacy_Account').getRecordTypeId();
        
        oAcc.Name = 'IPP';
        oAcc.US_WSREMS__REMS_Program__c = programObj.Id;
        oAcc.RecordTypeId = IpRecordTypeId;
        insert oAcc;
        
        Case oCase = new Case();
        id recordTypeIdInpatient = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inpatient_Pharmacy_Enrollment').getRecordTypeId();
        oCase.US_WSREMS__Name__c = 'Test IP';
        //oCase.US_WSREMS__Channel__c = 'Fax';
        oCase.US_WSREMS__Program_Picklist__c ='TRYVIO REMS';
        oCase.US_WSREMS__REMS_Program__c = programObj.Id;
        oCase.US_WSREMS__Email__c = 'jok@yopmail.com';
        oCase.RecordTypeId = recordTypeIdInpatient;
        oCase.US_WSREMS__Participant__c = oAcc.Id;
        oCase.Program_Record_Type_Control__c='TRYVIO REMS-Inpatient_Pharmacy_Enrollment';
        insert oCase;
        
    }
    @isTest
    public static void PatientEnrollmentSignature_Test() {
        // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = [SELECT Id FROM US_WSREMS__REMS_Program__c LIMIT 1];
        Account getAcc = [SELECT Id,RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName = 'Prescriber' LIMIT 1];
        Account getIpAcc = [SELECT Id,RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName = 'Inpatient_Pharmacy_Account' LIMIT 1];
        Case getIpCase = [SELECT Id,US_WSREMS__First_Name__c,US_WSREMS__Middle_Name__c,RecordType.DeveloperName,US_WSREMS__Last_Name__c,US_WSREMS__Name__c,US_WSREMS__DOB__c,Primary_Language__c,US_WSREMS__Email__c,US_WSREMS__Zip__c,
                          US_WSREMS__Phone__c,US_WSREMS__Office_Phone__c,US_WSREMS__Address_Line_1__c,SYN_Alternate_Phone__c,Best_time_to_call__c,SYN_Street_Address__c,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Fax__c,
                          US_WSREMS__MI__c,US_WSREMS__Speciality__c,US_WSREMS__Professional_Designation__c,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Address_Line_2__c,US_WSREMS__Ext__c,US_WSREMS__Comments__c,US_WSREMS__Prescriber_First_Name__c,
                          US_WSREMS__Prescriber_Last_Name__c,US_WSREMS__Prescriber_Email__c,US_WSREMS__Office_Contact_phone__c,US_WSREMS__REMS_Prescriber_Ext__c,US_WSREMS__First_Name_Secondary_AR__c,US_WSREMS__Last_Name_Secondary_AR__c,
                          US_WSREMS__Participant_Email__c,US_WSREMS__REMS_Office_Contact_Phone__c,US_WSREMS__REMS_Alternate_Phone_Ext__c,US_WSREMS__Knowledge_Assessment__c,
                          US_WSREMS__Facility_Type__c,US_WSREMS__Shipping_Address_Line_1__c,US_WSREMS__Shipping_Address_Line_2__c,US_WSREMS__Participant_City__c,US_WSREMS__SLN_Issued_State__c,US_WSREMS__REMS_Zip_Code__c,Shipping_Fax__c,
                          US_WSREMS__Participant_FirstName__c,US_WSREMS__Participant_LastName__c,US_WSREMS__Title__c,US_WSREMS__REMS_Prescriber_Fax__c,US_WSREMS__Participant_Phone__c,US_WSREMS__Prescriber_State__c,
                          US_WSREMS__Type_of_Report__c,US_WSREMS__REMS_Job_Title__c,US_WSREMS__Credential__c,US_WSREMS__REMS_Ext__c,US_WSREMS__Participant_Fax__c,Office_Practice_Clinic_Name__c,
                          SYN_Zip_Code__c,US_WSREMS__Shipping_Street__c,US_WSREMS__Shipping_City__c,US_WSREMS__Shipping_Zip_Postal_Code__c,
                          US_WSREMS__NPI__c,Office_contact_name_Primary_Office__c,US_WSREMS__Patient_Risk_Category__c,Negative_Pregnancy_Test_Completed__c,
                          US_WSREMS__Signature__c,US_WSREMS__Prescriber_Signature__c,US_WSREMS__Date__c,US_WSREMS__Patient__c,US_WSREMS__Patient__r.name,US_WSREMS__Participant__c,US_WSREMS__REMS_Service_Summary__c  FROM Case WHERE RecordType.DeveloperName = 'Inpatient_Pharmacy_Enrollment' LIMIT 1];
        User usr;
        Account prescriberAccount;
        Account patientAccount;
        Case patietnEnrollmentCase;
        Test.StartTest();
        System.runAs (communitydefaulowner) {
            
            
            REMSAttestationFormCtrl.getCurrentPatientInfo(getIpCase.id);
            REMSAttestationFormCtrl.saveSignature(getIpCase,'Signed','testpdf');
            REMSAttestationFormCtrl.addPatientEnrollmentFormtoAccount(getIpCase);     
            
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
        US_WSREMS__REMS_Program__c programObj = [SELECT Id FROM US_WSREMS__REMS_Program__c LIMIT 1];
        Account getAcc1 = [SELECT Id,RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName = 'Prescriber' LIMIT 1];
        Account getIpAcc1 = [SELECT Id,RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName = 'Inpatient_Pharmacy_Account' LIMIT 1];
        Case getIpCase1 = [SELECT Id,US_WSREMS__First_Name__c,US_WSREMS__Middle_Name__c,US_WSREMS__Last_Name__c,RecordType.DeveloperName,US_WSREMS__Name__c,US_WSREMS__DOB__c,Primary_Language__c,US_WSREMS__Email__c,US_WSREMS__Zip__c,
                           US_WSREMS__Phone__c,US_WSREMS__Office_Phone__c,US_WSREMS__Address_Line_1__c,SYN_Alternate_Phone__c,Best_time_to_call__c,SYN_Street_Address__c,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Fax__c,
                           US_WSREMS__MI__c,US_WSREMS__Speciality__c,US_WSREMS__Professional_Designation__c,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Address_Line_2__c,US_WSREMS__Ext__c,US_WSREMS__Comments__c,US_WSREMS__Prescriber_First_Name__c,
                           US_WSREMS__Prescriber_Last_Name__c,US_WSREMS__Prescriber_Email__c,US_WSREMS__Office_Contact_phone__c,US_WSREMS__REMS_Prescriber_Ext__c,US_WSREMS__First_Name_Secondary_AR__c,US_WSREMS__Last_Name_Secondary_AR__c,
                           US_WSREMS__Participant_Email__c,US_WSREMS__REMS_Office_Contact_Phone__c,US_WSREMS__REMS_Alternate_Phone_Ext__c,US_WSREMS__Knowledge_Assessment__c,US_WSREMS__Prescriber_State__c,
                           US_WSREMS__Facility_Type__c,US_WSREMS__Shipping_Address_Line_1__c,US_WSREMS__Shipping_Address_Line_2__c,US_WSREMS__Participant_City__c,US_WSREMS__SLN_Issued_State__c,US_WSREMS__REMS_Zip_Code__c,Shipping_Fax__c,
                           US_WSREMS__Participant_FirstName__c,US_WSREMS__Participant_LastName__c,US_WSREMS__Title__c,US_WSREMS__REMS_Prescriber_Fax__c,US_WSREMS__Participant_Phone__c,
                           US_WSREMS__Type_of_Report__c,US_WSREMS__REMS_Job_Title__c,US_WSREMS__Credential__c,US_WSREMS__REMS_Ext__c,US_WSREMS__Participant_Fax__c,Office_Practice_Clinic_Name__c,
                           SYN_Zip_Code__c,US_WSREMS__Shipping_Street__c,US_WSREMS__Shipping_City__c,US_WSREMS__Shipping_Zip_Postal_Code__c,
                           US_WSREMS__NPI__c,Office_contact_name_Primary_Office__c,US_WSREMS__Patient_Risk_Category__c,Negative_Pregnancy_Test_Completed__c,
                           US_WSREMS__Signature__c,US_WSREMS__Prescriber_Signature__c,US_WSREMS__Date__c,US_WSREMS__Patient__c,US_WSREMS__Patient__r.name,US_WSREMS__Participant__c,US_WSREMS__REMS_Service_Summary__c FROM Case WHERE RecordType.DeveloperName = 'Inpatient_Pharmacy_Enrollment' LIMIT 1];
        User usr;
        Account prescriberAccount;
        Account patientAccount;
        Case patietnEnrollmentCase;
        Test.StartTest();
        System.runAs (communitydefaulowner) {
            
            
            REMSAttestationFormCtrl.SavePrescriberSignature(getIpAcc1.id,'null','','');
            
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
        US_WSREMS__REMS_Program__c programObj =[SELECT Id FROM US_WSREMS__REMS_Program__c LIMIT 1];
        Account getAcc2 = [SELECT Id,RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName = 'Prescriber' LIMIT 1];
        Account getIpAcc2 = [SELECT Id,RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName = 'Inpatient_Pharmacy_Account' LIMIT 1];
        Case getIpCase2 = [SELECT Id,US_WSREMS__First_Name__c,US_WSREMS__Middle_Name__c,US_WSREMS__Last_Name__c,US_WSREMS__Name__c,RecordType.DeveloperName,US_WSREMS__DOB__c,Primary_Language__c,US_WSREMS__Email__c,US_WSREMS__Zip__c,
                           US_WSREMS__Phone__c,US_WSREMS__Office_Phone__c,US_WSREMS__Address_Line_1__c,SYN_Alternate_Phone__c,Best_time_to_call__c,SYN_Street_Address__c,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Fax__c,
                           US_WSREMS__MI__c,US_WSREMS__Speciality__c,US_WSREMS__Professional_Designation__c,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Address_Line_2__c,US_WSREMS__Ext__c,US_WSREMS__Comments__c,US_WSREMS__Prescriber_First_Name__c,
                           US_WSREMS__Prescriber_Last_Name__c,US_WSREMS__Prescriber_Email__c,US_WSREMS__Office_Contact_phone__c,US_WSREMS__REMS_Prescriber_Ext__c,US_WSREMS__First_Name_Secondary_AR__c,US_WSREMS__Last_Name_Secondary_AR__c,
                           US_WSREMS__Participant_Email__c,US_WSREMS__REMS_Office_Contact_Phone__c,US_WSREMS__REMS_Alternate_Phone_Ext__c,US_WSREMS__Knowledge_Assessment__c,US_WSREMS__Prescriber_State__c,
                           US_WSREMS__Facility_Type__c,US_WSREMS__Shipping_Address_Line_1__c,US_WSREMS__Shipping_Address_Line_2__c,US_WSREMS__Participant_City__c,US_WSREMS__SLN_Issued_State__c,US_WSREMS__REMS_Zip_Code__c,Shipping_Fax__c,
                           US_WSREMS__Participant_FirstName__c,US_WSREMS__Participant_LastName__c,US_WSREMS__Title__c,US_WSREMS__REMS_Prescriber_Fax__c,US_WSREMS__Participant_Phone__c,
                           US_WSREMS__Type_of_Report__c,US_WSREMS__REMS_Job_Title__c,US_WSREMS__Credential__c,US_WSREMS__REMS_Ext__c,US_WSREMS__Participant_Fax__c,Office_Practice_Clinic_Name__c,
                           SYN_Zip_Code__c,US_WSREMS__Shipping_Street__c,US_WSREMS__Shipping_City__c,US_WSREMS__Shipping_Zip_Postal_Code__c,
                           US_WSREMS__NPI__c,Office_contact_name_Primary_Office__c,US_WSREMS__Patient_Risk_Category__c,Negative_Pregnancy_Test_Completed__c,
                           US_WSREMS__Signature__c,US_WSREMS__Prescriber_Signature__c,US_WSREMS__Date__c,US_WSREMS__Patient__c,US_WSREMS__Patient__r.name,US_WSREMS__Participant__c,US_WSREMS__REMS_Service_Summary__c FROM Case WHERE RecordType.DeveloperName = 'Inpatient_Pharmacy_Enrollment' LIMIT 1];
        User usr;
        Account prescriberAccount;
        Account patientAccount;
        Case patietnEnrollmentCase;
        Test.StartTest();
        System.runAs (communitydefaulowner) {
            
            // Create Prescriber Account
            Account getAcc = [SELECT Id FROM Account LIMIT 1];     
            
            ApexPages.currentPage().getParameters().put('id', getIpCase2.US_WSREMS__Participant__c);
            
        }
        
        Test.StopTest();
    }
    @isTest
    static void addPatientEnrollmentFormtoAccount_Negative(){
        Case oCase = new Case();
        REMSAttestationFormctrl.addPatientEnrollmentFormtoAccount(oCase);
    }
    @isTest
    static void saveSignature_Negative(){
        Case oCase = new Case();
        REMSAttestationFormctrl.saveSignature(oCase,'','');
    }
}