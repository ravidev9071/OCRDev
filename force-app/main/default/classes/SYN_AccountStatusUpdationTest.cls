/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-20-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class SYN_AccountStatusUpdationTest {
    @TestSetup
    static void makeData(){
        US_WSREMS__REMS_Program__c remsProg1 = new US_WSREMS__REMS_Program__c();
        remsProg1.Name = 'Macitentan REMS';
        remsProg1.REMS_Project_Code__c = 'BT7433';
        remsProg1.US_WSREMS__Status__c ='Active';
        remsProg1.QueueName__c ='Syneos Test Call Queue';
        insert remsProg1;

        Id patientRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        Id providerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Account providerAccount = SYN_TestDataUtility.createAccount(remsProg1.Id,providerRecTypeId,'TestProviderFristName','TestProviderLastName');

        //Id RemsRecordTypeId,Id ProgramId, String requestorType, String pathStageName
        Id enrollRecTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId();
        
        US_WSREMS__REMS_Service_Summary__c service = new US_WSREMS__REMS_Service_Summary__c();
        service.recordtypeId = enrollRecTypeId;
        service.US_WSREMS__REMSProgram__c = remsProg1.Id;
        service.US_WSREMS__Requestor_Type__c = 'Prescriber';
        service.US_WSREMS__Path_Stage_Name__c = 'Intake';
        service.US_WSREMS__Participant__c = providerAccount.Id;
        service.US_WSREMS__Status__c = 'Closed';
        service.US_WSREMS__Service_Outcome__c = 'Successful';
        Insert service;

        Id enrollmentCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();
       // Case caseObj1 = SYN_TestDataUtility.createCase(enrollmentCaseRecTypeId,service.Id,'TestCaseFirstName','TestCaseLastName','Complete');
        Case caseObj1 = new case();
        caseObj1.recordtypeId= enrollmentCaseRecTypeId;
        caseObj1.US_WSREMS__REMS_Service_Summary__c= service.Id;
        caseObj1.US_WSREMS__First_Name__c= 'TestCaseFirstName';
        caseObj1.US_WSREMS__Last_Name__c= 'TestCaseLastName';
        caseObj1.SYN_Gender__c ='Non-Binary';
        caseObj1.status ='Complete';
        caseObj1.US_WSREMS__Program_Picklist__c ='Macitentan REMS';
        caseObj1.SYN_Street_Address__c ='3260 N Hayden Rd';
        caseObj1.US_WSREMS__State__c ='AZ';
        caseObj1.US_WSREMS__City__c ='Scottsdale';
        caseObj1.SYN_Zip_Code__c ='85250';
        caseObj1.US_WSREMS__Phone__c ='8525085250';
        caseObj1.SYN_Currently_Enrolled_for_Oxybate__c  ='Yes';
        caseObj1.SYN_Previously_Enrolled_for_Oxybate__c  ='Yes';
        caseObj1.SYN_Prescriber_First_Name__c  ='FirstName';
        caseObj1.SYN_Prescriber_Last_Name__c  ='LastName';
        caseObj1.US_WSREMS__DEA__c  ='FH7654321';
        caseObj1.US_WSREMS__Shipping_Street__c   ='3260 N Hayden Rd';
        caseObj1.SYN_Prescriber_Phone__c   ='8525085250';
        caseObj1.US_WSREMS__Outcome__c ='Complete';
        caseObj1.US_WSREMS__Shipping_City__c ='Scottsdale';
        caseObj1.SYN_Shipping_State__c ='AZ';
        caseObj1.US_WSREMS__Shipping_Zip_Postal_Code__c ='85250';
        caseObj1.SYN_Prescriber_Fax__c ='8525085250';
        caseObj1.US_WSREMS__Signature__c ='Yes';
        caseObj1.US_WSREMS__Date__c =System.today();
        caseObj1.SYN_Prescriber_Signature__c ='Yes';
        caseObj1.SYN_Prescriber_Signature_Date__c =system.today();
        caseObj1.US_WSREMS__DOB__c =Date.newInstance(2016, 12, 9);
        caseObj1.Program_Record_Type_Control__c = remsProg1.Name+'-Patient_Enrollement';
        caseObj1.US_WSREMS__Call_Outcome__c = 'TEST';
        caseObj1.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        //insert caseObj1;
    }

    @isTest
    static void syn_AccountUpdationTest(){
        Account testAcc =[SELECT Id, US_WSREMS__Status__c FROM Account WHERE LastName='TestProviderLastName' LIMIT 1];
        US_WSREMS__REMS_Service_Summary__c service = [SELECT Id,US_WSREMS__Status__c,US_WSREMS__Service_Outcome__c,US_WSREMS__Participant__c,
                                                                US_WSREMS__Requestor_Type__c,Program_Name__c,(SELECT Id, status, US_WSREMS__Outcome__c FROM US_WSREMS__Cases__r)
                                                                FROM US_WSREMS__REMS_Service_Summary__c 
                                                                LIMIT 1];
        List<US_WSREMS__REMS_Service_Summary__c> remsList = new List<US_WSREMS__REMS_Service_Summary__c>();
        remsList.add(service);
       // Case cs = [SELECT Id, status,US_WSREMS__Outcome__c FROM Case WHERE  US_WSREMS__Last_Name__c ='TestCaseLastName' LIMIT 1];
        Test.startTest();
       // SYN_AccountStatusUpdation.accountStatusUpdatewWithCustomMetadata(remsList,null);
        Test.stopTest();

    }
}