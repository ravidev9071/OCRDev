@isTest
public class SYN_InOutBoundComponentControllerTest {
 @testSetUp
    static void createTestData(){
        List<US_WSREMS__REMS_Program__c> remsProgramList =SYN_TestDataFactory.createSOXPrograms(1,true);
        SYN_TestDataFactory.createProgramServiceConfig(true, remsProgramList[0].id);
        Id remsRTId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Outbound_Communication').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c remsServiceObject = SYN_TestDataFactory.createService(true, remsProgramList[0].Id, remsRTId);
       
        SYN_TestDataFactory.createBusinessAccount('1234476', '9087654321', true,remsProgramList[0].id);
        SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', true,remsProgramList[0].id);
        
    } 
    @isTest
    static void testgetPageLayoutFields(){   
        List<US_WSREMS__REMS_Service_Summary__c> remsServiceList = [SELECT Id, Name FROM US_WSREMS__REMS_Service_Summary__c WHERE RecordType.DeveloperName = 'Outbound_Communication' LIMIT 1];
		Case caseObj=new Case();
        caseObj.US_WSREMS__REMS_Service_Summary__c=remsServiceList[0].Id;
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS-SYN_Patient_Person_Account';
        insert caseObj;
        Test.startTest();
        List<SYN_InboundOutBoundComponentController.LayoutSection> sectionList = SYN_InboundOutBoundComponentController.getPageLayoutFields('Case-Case Layout');
        SYN_InboundOutBoundComponentController.caseDetails caseDetailObject = SYN_InboundOutBoundComponentController.getPageLayoutforRequestorType(caseObj.Id);
              Test.stopTest();
    }

}