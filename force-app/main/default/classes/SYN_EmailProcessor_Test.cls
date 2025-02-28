@isTest
public with sharing class SYN_EmailProcessor_Test {

    @TestSetup
    static void  testDataSetup(){
        US_WSREMS__REMS_Program__c remsProgram = SYN_TestDataUtility.createProgram('Sodium Oxybate Rems', 'Active');
        Id patientAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        Account patientAccObj = SYN_TestDataUtility.createAccount(remsProgram.id, patientAccRecTypeId, 'FirstName', 'LastName');
        patientAccObj.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        update patientAccObj;
        Id rmrCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
        Id patientEnrollCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();
        Case patEnrollCaseObj = SYN_TestDataUtility.createaNewCase(patientEnrollCaseRecTypeId,'FirstName','LastName', 'Draft',remsProgram.id);
        //Case rmrCaseObj = SYN_TestDataUtility.createaNewCase(rmrCaseRecTypeId,'FirstName','LastName', 'Draft',remsProgram.id);
    }

    @isTest
    public static void processAndTriggerCaseCommuTest(){
        Id rmrCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();

        Account patientAccObj= [SELECT Id, FirstName,LastName,US_WSREMS__REMS_Program__c,Rating,Type,Industry,Ownership,Phone,AccountNumber,Sic,RecordTypeId,ShippingCountry,ShippingState,ShippingStreet,ShippingCity,ShippingPostalCode,SYN_Shipping_Address_2__c FROM Account LIMIT 1];
        map<id,Case> patEnrollCaseOldMap = new map<id,case>();
        map<id,Case> patEnrollCaseNewMap = new  map<id,Case>();
        for(case caseObj : [SELECT Id,US_WSREMS__First_Name__c,US_WSREMS__Last_Name__c,US_WSREMS__Phone__c,US_WSREMS__DOB__c,US_WSREMS__Fax__c,Status,US_WSREMS__REMS_Program__c FROM Case LIMIT 1]) 
        {
            patEnrollCaseOldMap.put(caseObj.id,caseObj);
            caseObj.US_WSREMS__Participant__c = patientAccObj.id;
            caseObj.Status = 'Complete';
            caseObj.US_WSREMS__Outcome__c = 'Complete';
            caseObj.Approval_Status__c = 'DEA Override Approved';
            caseObj.US_WSREMS__Patient__c = patientAccObj.id;
            caseObj.US_WSREMS__Outcome__c = 'Complete';
            caseObj.US_WSREMS__Channel__c = 'Fax';
            patEnrollCaseNewMap.put(caseObj.id,caseObj);    
        }
        update patEnrollCaseNewMap.values();
        
        Test.StartTest();
        SYN_EmailProcessor.processAndTriggerCaseCommu(True,False, patEnrollCaseNewMap, patEnrollCaseOldMap);
        SYN_EmailProcessor.processAndTriggerCaseCommu(False, True, patEnrollCaseNewMap, patEnrollCaseOldMap);
        Test.StopTest();
        List<Account> accList = [SELECT ID, US_WSREMS__Preferred_Contact_Method__c From Account Limit 1];
        System.assertEquals(accList[0].US_WSREMS__Preferred_Contact_Method__c,'Email', 'Preferred contact Method should be Email');
    }    
}