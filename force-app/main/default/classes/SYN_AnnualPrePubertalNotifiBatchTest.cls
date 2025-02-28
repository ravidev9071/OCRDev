/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-19-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest()
public class SYN_AnnualPrePubertalNotifiBatchTest {
    public static testMethod void sendFaxOREmailTestMethod(){ 

        Id recordTypeIdPatient = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient'); 
        Id recordTypeIdPrescriber = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        Id caseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('case', 'Patient_Enrollement');
        Test.startTest();
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        // Account Creation
        Account createPatientAccount = SYN_TestDataUtility.createPatientAccountDOBCheckTest(programObj.Id,recordTypeIdPatient);      
        Account prescAcc1 = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        //Rems Service Creation
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummaryopen(createPatientAccount.Id,programObj.Id);
        //Enrollment Service creation
        Case createPatientEnrollmentCase1 = SYN_TestDataUtility.createaPatientEnrollmentCase(caseRecordTypeId, programObj.Id,objService.id,createPatientAccount.Id,prescAcc1.id);
        objService.US_WSREMS__Status__c = 'Closed';
        objService.US_WSREMS__Service_Outcome__c = 'Successful';
        Update objService;
        string prgmName = 'Macitentan REMS';
        // Call the method to be tested
        SYN_AnnualPrePubertalNotificationBatch obj = new SYN_AnnualPrePubertalNotificationBatch(prgmName,label.Annual_Prepubertal_30_Day_ReminderFax,label.Annual_Prepubertal_30_Day_Reminder);
         SYN_FaxBlastBatch obj1= new SYN_FaxBlastBatch(label.Annual_Prepubertal_30_Day_ReminderFax);
        DataBase.executeBatch(obj);  
        DataBase.executeBatch(obj1); 
        Test.stopTest();     
    }
    
    public static testMethod void sendFaxTestMethod(){

        Id recordTypeIdPatient = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient'); 
        Id caseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('case', 'Patient_Enrollement');
        Id recordTypeIdPrescriber = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        Test.startTest();
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
       // Account Creation
        Account createPatientAccount = SYN_TestDataUtility.createPatientAccountDOBCheckTest(programObj.Id,recordTypeIdPatient);
        createPatientAccount = [Select FirstName,LastName, US_WSREMS__REMS_Program__c,Rating,Type,Industry,Ownership,Phone,AccountNumber,Sic,RecordTypeId,
                                ShippingCountry,ShippingState,ShippingStreet,ShippingCity,ShippingPostalCode,US_WSREMS__DOB__c,
                                US_WSREMS__Patient_Risk_Category__c, Patient_Reproductive_Status_Date__c, Patient_Dob_Check__c 
                                From Account Where Id =: createPatientAccount.Id];
        Account prescAcc1 = SYN_TestDataUtility.createPrescriberAccountWithNPIcubaFAX(programObj.Id,recordTypeIdPrescriber);
       //Rems Service Creation
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummaryopen(createPatientAccount.Id,programObj.Id);
       //Enrollment Service creation
        Case createPatientEnrollmentCase1 = SYN_TestDataUtility.createaPatientEnrollmentCase(caseRecordTypeId, programObj.Id,objService.id,createPatientAccount.Id,prescAcc1.id);
        objService.US_WSREMS__Status__c = 'Closed';
        objService.US_WSREMS__Service_Outcome__c = 'Successful';
        Update objService;
        string prgmName = 'Macitentan REMS';
        // Call the method to be tested
        SYN_AnnualPrePubertalNotificationBatch obj = new SYN_AnnualPrePubertalNotificationBatch(prgmName,label.Annual_Prepubertal_30_Day_ReminderFax,label.Annual_Prepubertal_30_Day_Reminder);
        SYN_FaxBlastBatch obj1= new SYN_FaxBlastBatch(label.Annual_Prepubertal_30_Day_ReminderFax);
        DataBase.executeBatch(obj); 
        DataBase.executeBatch(obj1); 
        
        Test.stopTest();
        
    }
    
    
}