@isTest
public class SYN_SOXAutomatedTaskCreationBatchTest {
    public static testMethod void testBatch() {
        // Create test data
        US_WSREMS__REMS_Program__c remobj = new US_WSREMS__REMS_Program__c();
        remobj.Name ='Sodium Oxybate REMS';
        remobj.REMS_Project_Code__c = 'BT6825';
        remobj.US_WSREMS__Status__c ='Active';
        remobj.US_WSREMS__Program_State_Date__c = System.today();
        remobj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert remobj; 
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType ='Account' and Name ='pharmacy'].Id;
        Account actobj = new Account();
        actobj.Name='test';  
        actobj.phone = '8888888888';
        actobj.RecordTypeId =strRecordTypeId;
        actobj.US_WSREMS__REMS_Program__c =remobj.id;
        insert actobj;
        
        Group g = new Group(Name='Test Group', Type='Queue');
        insert g;
        
        id certificationRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Certification').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = remobj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = actobj.Id;
        serviceObj.RecordTypeId = certificationRecordTypeId;
        insert serviceObj;
        List<Case> CaseList = new List<Case>();
        
      //  for(Integer j=0 ;j <10;j++){
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__Email__c= actobj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= actobj.Phone;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.status = 'draft';
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS-SYN_Patient_Person_Account';
      //  CaseList.add(caseObj);    
       // }
       
        insert Caseobj;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(Caseobj.Id, yesterday); 
        //Call the implementation class 
        SYN_SOXAutomatedTaskCreationBatch batch = new SYN_SOXAutomatedTaskCreationBatch('Sodium Oxybate REMS');
        Test.startTest();
        //Call the implementation class 
        Id jobid= Database.executeBatch(batch);
        Test.stopTest();
        List<Case> Listtask=[Select Id,US_WSREMS__REMS_Service_Summary__c from Case];
        Set<Id> WhatIds = new Set<Id>();
        for(Case t : Listtask){
		WhatIds.add(t.US_WSREMS__REMS_Service_Summary__c);
        }
        List<Task> taskList = [SELECT Id, WhatId, Type, Status FROM Task WHERE id IN : WhatIds AND Status = 'Draft'];
        for (Task task : taskList) {
            System.assertEquals('Call', task.Type); 
            System.assertEquals('Draft', task.Status);
        }
    }
  
}