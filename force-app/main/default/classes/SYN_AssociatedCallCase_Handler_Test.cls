@isTest
public class SYN_AssociatedCallCase_Handler_Test {
    
    @testSetup
    static void createTestData(){
        List<US_WSREMS__REMS_Program__c> remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);
        SYN_TestDataFactory.createProgramServiceConfig(true, remsProgramList[0].id);
        Id remsRTId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Participant_Enrollment').getRecordTypeId();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Patient_Person_Account').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c remsServiceObject = SYN_TestDataFactory.createService(true, remsProgramList[0].Id, remsRTId);

        SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', true, remsProgramList[0].id );
        Case caseObj = new Case(RecordTypeId = caseRecordTypeId,Program_Record_Type_Control__c = remsProgramList[0].Name+'-SYN_Patient_Person_Account', Status = 'Draft', US_WSREMS__REMS_Service_Summary__c = remsServiceObject.id,US_WSREMS__DOB__c=date.Today()-900);
        insert caseObj;
        
    }
    @isTest
    static void beforeInsertTest(){
        Associated_Call_Case_Participant__c accp = new Associated_Call_Case_Participant__c();
        case c = [select id from case WHERE Status = 'Draft' Limit 1];
        Account A = [select id, US_WSREMS__REMS_Program__c, Name From Account];
        US_WSREMS__REMS_Program__c P = [select id from US_WSREMS__REMS_Program__c];
        accp.Case__c = c.id;
        accp.Participant__c = A.id;
        accp.REMS_Program__c = p.id;
        test.startTest();
        insert accp;
        test.stopTest();
        Associated_Call_Case_Participant__c accparticipant = [select id from Associated_Call_Case_Participant__c WHERE Id =:accp.id];
        system.assert(accparticipant.id != null);
        
    }

}