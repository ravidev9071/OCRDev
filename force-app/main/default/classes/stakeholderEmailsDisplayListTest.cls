/**
* @File Name          : stakeholderEmailsDisplayListTest .cls
* @Description        : This class provides test coverage for stakeholderEmailsDisplayList.
* @TestClass          : stakeholderEmailsDisplayListTest
* @Author             : Wilco
* @Date               : 03/FEB/2022
**/
@isTest
public class stakeholderEmailsDisplayListTest {

    @isTest
    public static void stakeholderEmailsDisplayList_Test() {
        User thisUser = [SELECT Id from User where Id = :UserInfo.getUserId()];
        
        EmailTemplate e;
        System.runAs ( thisUser ) {
            e = new EmailTemplate (developerName = 'MaciAutomationEmailTemplate', TemplateType= 'Text', Name = 'MaciAutomationEmailTemplate',FolderId = UserInfo.getUserId());
            insert e;               
        }
        
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();
        id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        Account prescAcc = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummary(createPatientAccount.Id,programObj.Id);
        
        Case createaPatientEnrollmentPatientCase = SYN_TestDataUtility.createaPatientEnrollmentPatientCaseFRP(caseRecordTypeId, programObj.Id,'Test FirstName','Test LastName',objService.id,createPatientAccount.Id);
        createaPatientEnrollmentPatientCase.SYN_Prescriber_Last_Name__c='sls';
        createaPatientEnrollmentPatientCase.US_WSREMS__State__c='Al';
        createaPatientEnrollmentPatientCase.US_WSREMS__Shipping_Street__c='test';
        createaPatientEnrollmentPatientCase.SYN_Prescriber_Phone__c='1234567890';
        createaPatientEnrollmentPatientCase.US_WSREMS__City__c='test city';
        createaPatientEnrollmentPatientCase.SYN_Prescriber_Signature__c='Yes';
        createaPatientEnrollmentPatientCase.SYN_Shipping_State__c='Al';
        createaPatientEnrollmentPatientCase.US_WSREMS__Signature__c='Yes';
        createaPatientEnrollmentPatientCase.SYN_Street_Address__c='address1';
        createaPatientEnrollmentPatientCase.US_WSREMS__Shipping_City__c='scity';
        createaPatientEnrollmentPatientCase.SYN_Prescriber_Signature_Date__c=system.today();
        createaPatientEnrollmentPatientCase.SYN_Zip_Code__c='12345';
        createaPatientEnrollmentPatientCase.US_WSREMS__Date__c=system.today();
        createaPatientEnrollmentPatientCase.US_WSREMS__Shipping_Zip_Postal_Code__c='12345';
        createaPatientEnrollmentPatientCase.SYN_Prescriber__c=prescAcc.Id;
        createaPatientEnrollmentPatientCase.US_WSREMS__NPI__c='1234567899';
        createaPatientEnrollmentPatientCase.SYN_Prescriber_First_Name__c='Pfirst';
        createaPatientEnrollmentPatientCase.US_WSREMS__Patient_Risk_Category__c='Female of Reproductive Potential (FRP)';
        createaPatientEnrollmentPatientCase.Negative_Pregnancy_Test_Completed__c='Yes';
        createaPatientEnrollmentPatientCase.status='Complete';
        createaPatientEnrollmentPatientCase.US_WSREMS__Outcome__c='Complete';
        update createaPatientEnrollmentPatientCase;
        
        objService.US_WSREMS__Service_Outcome__c = 'Successful';
        objService.US_WSREMS__Status__c = 'Closed';
        update objService;
        
        Test.startTest();
        stakeholderEmailsDisplayList.getEmailMessageRecords(createPatientAccount.Id);
        Test.stopTest();
    }
}