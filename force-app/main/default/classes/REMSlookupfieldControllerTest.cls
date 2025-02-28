/**
* @Description        : Test Class for REMSlookupfieldController Class.
* @Author 			    : 
* @Modification Log   : 
* Ver       Date            Developer      		        Modification
*                          Wilco Source           		Initial Implementation.
**/
@isTest
public with sharing class REMSlookupfieldControllerTest {
    static testMethod void testLookupField() {
        List<string> returnFields = new List<string> {'Name'};
        List<string> returnFields1 = new List<string>();

        //Program Creation
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Test Program';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        //Record type creation
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();

        //Pharmacy Account Creation
        Account accObj = new Account();
        accObj.Name = 'Test Pharmacy'; 
        accObj.US_WSREMS__Status__c = 'Certified'; 
        accObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accObj.RecordTypeId = recordTypePharmacyId;      
        insert accObj;
        //List of Account Records
        Account accList = [SELECT Id,Name FROM Account LIMIT 1];
        Test.startTest();
        REMSlookupfieldController.getObjectDetails('Account');   
        REMSlookupfieldController.GetRecentRecords('Account', returnFields, 5);
        REMSlookupfieldController.GetRecentRecords('Account', returnFields1, 5);
        REMSlookupfieldController.GetRecord('Account', returnFields, accObj.Id);
        REMSlookupfieldController.GetRecord('Account', returnFields1, accObj.Id);
        REMSlookupfieldController.getRecordTypeId('Account','Pharmacy');
        REMSlookupfieldController.SearchRecords('Account', returnFields, returnFields, 'test', 'Name', 'ASC', 5, 
                                                'CreatedDate > 2020-01-01T00:00:01Z','Participant',pgrmObj.Id,'Pharmacy');
        REMSlookupfieldController.SearchRecords('Account', returnFields1, returnFields1, 'test', 'Name', 'ASC', 5, 
                                                'CreatedDate > 2020-01-01T00:00:01Z','Participant',pgrmObj.Id,'Pharmacy');
        Test.stopTest();
     
    }
   
}