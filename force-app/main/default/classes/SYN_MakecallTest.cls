@istest
public class SYN_MakecallTest {
  
  
  @testsetup static void taskCreationdata(){
      Test.startTest();
      
      US_WSREMS__REMS_Program__c remobj = new US_WSREMS__REMS_Program__c();
      remobj.Name ='Macitentan REMS';
      remobj.Toll_Free_Number_1__c ='123456';
      remobj.US_WSREMS__Status__c ='Active';
      insert remobj;
      
        US_WSREMS__REMS_Program__c remobj1 = new US_WSREMS__REMS_Program__c();
      
      remobj1.Name ='synprogram1';
        remobj1.Toll_Free_Number_1__c ='';
      remobj1.US_WSREMS__Status__c ='Active';
      insert remobj1;
      // SYN_TestDataFactory.createProgramServiceConfig(true, remobj1.id);
      
      String strRecordTypeId = [Select Id From RecordType Where SobjectType ='Account' and Name ='Pharmacy'].Id;
      System.debug('strRecordTypeId09'+strRecordTypeId);
      Account actobj = new Account();
      actobj.Name='test001';
      actobj.phone = '8888888888';
      
      actobj.RecordTypeId =strRecordTypeId;
      actobj.US_WSREMS__REMS_Program__c =remobj.id;
      insert actobj;
      
        Account actobj1 = new Account();
      actobj1.Name='test001';
        actobj1.phone = '8888888888';
      actobj1.RecordTypeId =strRecordTypeId;
      actobj1.US_WSREMS__REMS_Program__c =remobj1.id;
      insert actobj1;
          
      Contact con1=new Contact();
      con1.AccountId=actobj1.Id;
      con1.FirstName='TestFN';
      con1.LastName='TestLN';
      insert con1;
      
        Contact con2=new Contact();
      con2.AccountId=actobj.Id;
      con2.FirstName='TestFN';
      con2.LastName='TestLN2';
        con2.phone = '8888888888';
      insert con2;
      
      String recordTypeCaseId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId();
      US_WSREMS__REMS_Service_Summary__c remsobj = new US_WSREMS__REMS_Service_Summary__c();
      remsObj.RecordTypeId = recordTypeCaseId;
      remsobj.US_WSREMS__Participant__c    = actobj.Id;
      remsobj.US_WSREMS__REMSProgram__c = remobj.id;
      remsobj.US_WSREMS__Requestor_Type__c ='Pharmacy';
      remsobj.US_WSREMS__StageName__c='Intake';
      insert remsobj;
      
      US_WSREMS__REMS_Service_Summary__c remsobj1 = new US_WSREMS__REMS_Service_Summary__c();
      remsobj1.US_WSREMS__Participant__c   = actobj.Id;
      remsobj1.US_WSREMS__REMSProgram__c = remobj.id;
      remsobj1.US_WSREMS__Requestor_Type__c ='pharmacy'; 
      remsobj1.US_WSREMS__StageName__c='Intake';
      remsobj1.Outbound_REMS_Service__c= remsobj.Id;
      insert remsobj1;
      
      US_WSREMS__REMS_Service_Summary__c remsobj2 = new US_WSREMS__REMS_Service_Summary__c();
      // remsobj2.US_WSREMS__Participant__c    = actobj.Id;
      remsobj2.US_WSREMS__REMSProgram__c = remobj.id;
      remsobj2.US_WSREMS__Requestor_Type__c ='Pharmacy';
      remsobj2.US_WSREMS__StageName__c='Intake';
      insert remsobj2;
      
      US_WSREMS__REMS_Service_Summary__c remsobj3 = new US_WSREMS__REMS_Service_Summary__c();
      remsobj3.US_WSREMS__Participant__c   = actobj1.Id;
      remsobj3.US_WSREMS__REMSProgram__c = remobj1.id;
      remsobj3.US_WSREMS__Requestor_Type__c ='pharmacy'; 
      remsobj3.US_WSREMS__StageName__c='Intake';
      //remsobj3.Outbound_REMS_Service__c= remsobj.Id;
      insert remsobj3;
  
      Case caseObj=new Case();
      Id recordTypeIdcase= Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('Outbound_Call').getRecordTypeId();
      caseObj.RecordTypeId=recordTypeIdcase;
      caseObj.US_WSREMS__REMS_Service_Summary__c=remsobj.Id;
      caseObj.US_WSREMS__First_Name__c ='TestLastName123';
      caseObj.US_WSREMS__Last_Name__c  ='TestFirstName123';
      caseObj.US_WSREMS__Relationship__c ='Caregiver';
      caseObj.US_WSREMS__Participant__c = actObj.Id;	
      caseObj.US_WSREMS__Same_as_Account__c = True;	
      caseObj.US_WSREMS__Call_Notes__c = 'Test';	
      caseObj.status = 'Draft';
	  caseObj.Program_Record_Type_Control__c ='Macitentan REMS-Outbound_Call';
      insert caseObj;
      
      
      Task tasobj = new Task();
      tasobj.WhatId = remsobj.Id;
    //tasobj.AccountId = actobj.Id;
      insert tasobj;
      
      Task tasobj1 = new Task();
      tasobj1.WhatId =actobj.Id;
      insert tasobj1;
      
       Task tasobj2 = new Task();
      tasobj2.WhatId =actobj1.Id;
      insert tasobj2;
      
       Task tasobj3 = new Task();
      tasobj3.WhatId =actobj1.Id;
      insert tasobj3;
      
      Task tasobj4 = new Task();
      tasobj4.whoId =con2.Id;
      tasobj4.WhatId =actobj1.Id;
      insert tasobj4;
      
       Task tasobj5 = new Task();
      tasobj5.whoId =con1.Id;
      tasobj5.WhatId =remsobj.Id;
      insert tasobj5;
  
   Task tasobj6 = new Task();	
      tasobj6.whoId =con1.Id;	
      tasobj6.whatId =remsobj.Id;	
        
      insert tasobj6;	
      
      Test.stopTest();
      
  }
  
  
  static testmethod void createServiceCreation_Account(){
      
      Test.startTest();

      Account acc = [Select id from Account where name='test001' limit 1];
	  Contact conData = [Select id from Contact where lastname = 'TestLN' limit 1];
	  Task taskdata = [Select id from Task where whoid =:condata.id limit 1];
      SYN_InboundUtility.servicecasewrapper testCallAcc =  SYN_Makeacall.callServiceCreation(acc.Id,'Account','');
	  Test.stopTest();

      Task taskTest = [Select id,US_WSREMS__Outbound_REMS_Service__c from Task where id =: taskdata.id limit 1];
        system.assertEquals(testCallAcc.ServiceId != null , True);
  }
  static testmethod void createServiceCreation_Remsservice(){
      
      Test.startTest();
	  Contact conData = [Select id from Contact where lastname = 'TestLN' limit 1];
      US_WSREMS__REMS_Service_Summary__c remsData = [Select id from US_WSREMS__REMS_Service_Summary__c Limit 1];
      Task taskdata = [Select id from Task where whoid =:condata.id limit 1];
      SYN_InboundUtility.servicecasewrapper testCallService = SYN_Makeacall.callServiceCreation(remsData.Id,'US_WSREMS__REMS_Service_Summary__c','');
	  Test.stopTest();

      Task taskTest = [Select id,US_WSREMS__Outbound_REMS_Service__c from Task where id =: taskdata.id limit 1];
        system.assertEquals(testCallService != Null , True); 
  }
  static testmethod void createServiceCreation_Task(){
      
      Test.startTest();
      
      Contact conData = [Select id from Contact where lastname = 'TestLN' limit 1];
      Task taskdata = [Select id from Task where whoid =:condata.id limit 1];
      SYN_InboundUtility.servicecasewrapper testCallTask = SYN_Makeacall.callServiceCreation(taskdata.Id,'Task',conData.Id);
	  Test.stopTest();

      Task taskTest = [Select id,US_WSREMS__Outbound_REMS_Service__c from Task where id =: taskdata.id limit 1]; 
        //system.assertEquals(taskTest.US_WSREMS__Outbound_REMS_Service__c, testCallTask.ServiceId);
  }
  static testmethod void createServiceCreation_Taskstatus(){
      
      Test.startTest();
	  Contact conData = [Select id from Contact where lastname = 'TestLN' limit 1];
      Task taskdata = [Select id from Task where whoid =:condata.id limit 1];
      SYN_Makeacall.makeaCallwrapper testGetTaskStatus = SYN_Makeacall.getTaskStatus(taskdata.Id,'Task');  
	  Test.stopTest();


  }
  static testmethod void createServiceCreation_Taskstatusservice(){
      
      Test.startTest();

      US_WSREMS__REMS_Service_Summary__c remsData = [Select id from US_WSREMS__REMS_Service_Summary__c Limit 1];
      
      SYN_Makeacall.makeaCallwrapper testGetTaskStatusService = SYN_Makeacall.getTaskStatus(remsData.Id,'US_WSREMS__REMS_Service_Summary__c');  
	  Test.stopTest();

     
  }
  
  
      static testmethod void createTask(){
          
            Test.startTest();
          
            Task taskData = [Select id from Task limit 1];
            Test.setMock(HttpCalloutMock.class, new API_ResponseMock()); 
            SYN_Makeacall.makeaCallwrapper testMakeacall = SYN_Makeacall.makeacall(taskData.id,'Task');
        system.assertEquals('Participant is not associated to the Task', testMakeacall.status_message);                      
          Test.stopTest();
          
      }
  
  
    static testmethod void createTask2(){
          
            Test.startTest();
          
            Account acc = [Select id from Account where name='test001' limit 1];
          US_WSREMS__REMS_Service_Summary__c remsData = [Select id from US_WSREMS__REMS_Service_Summary__c Limit 1];
          
          Contact conData = [Select id from Contact where lastname = 'TestLN' limit 1];
          Task taskdata = [Select id from Task where whoid =:condata.id limit 1];
            //Task taskData = [Select id from Task limit 1];
            Test.setMock(HttpCalloutMock.class, new API_ResponseMock());
        
          SYN_Makeacall.makeacall(acc.Id,'Account');
          SYN_Makeacall.makeaCallwrapper testMakeacall = SYN_Makeacall.makeacall(remsData.Id,'US_WSREMS__REMS_Service_Summary__c');
          system.assertEquals(testMakeacall.status == False && testMakeacall.status_message != Null, True);
              SYN_Makeacall.makeacall(taskData.id,'Task');
          
          Test.stopTest();
          
      }

      static testmethod void createTask3(){
          
            Test.startTest();
          
            Account accData = [Select id from account where Name ='test001' limit 1];
            Task taskData = [Select id from task where whatId =:accData.id limit 1];
            Test.setMock(HttpCalloutMock.class, new API_ResponseMock());
            SYN_Makeacall.makeaCallwrapper testMakeacall =  SYN_Makeacall.makeacall(taskData.Id,'Task');
            Test.stopTest();
            system.assertEquals('Participant is not associated to the Task', testMakeacall.status_message);

        } 
}