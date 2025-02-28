@isTest
public class LightningRecordEditFormControllerTest {
    public static testmethod void  method1() {
        id RemsRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Sodium Oxybate REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        Insert programObj;
        
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = RemsRecordTypeId;
        Insert serviceObj;
        
        Case caseObj = new Case(RecordTypeId = caseRecordTypeId,Program_Record_Type_Control__c =programObj.Name+'-Prescriber_enrollment', Status = 'Draft', US_WSREMS__REMS_Service_Summary__c = serviceObj.id);
        insert caseObj; 
        LightningRecordEditFormController.getPageLayoutFields('case-Case Layout');
        LightningRecordEditFormController.getAllRecordTypeDetails('case');
        LightningRecordEditFormController.getPageLayoutforRequestorType(caseObj.Id, false,'',serviceObj.Id);
        LightningRecordEditFormController.getPageLayoutforRequestorType(caseObj.Id, true,'',serviceObj.Id);

    }
}