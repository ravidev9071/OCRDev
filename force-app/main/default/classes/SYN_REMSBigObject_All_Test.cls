@isTest
private class SYN_REMSBigObject_All_Test 
{
    @isTest static void  method1() 
    {
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MetadatService_Mock());
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
      //  Test.setMock(WebServiceMock.class, new MetadatService_Mock());
        SYN_REMSBigObjectMetaDataService.createBigObjectMetadata('Account');
        
        BigObject_Data_Process_Setings__c accBigObject = new BigObject_Data_Process_Setings__c();
        accBigObject.Source_Object_Name__c = 'Account';
        accBigObject.Source_Object_API_Name__c = 'Account';
        accBigObject.Target_Object_Name__c = 'AccountBigObject';
        accBigObject.Target_Object_API_Name__c = 'AccountBigObject__b';
        accBigObject.Active_Mapping_Process__c = true;
        accBigObject.Active__c = true;
        insert accBigObject;
        
        //SYN_REMSbigObjectMappingProcess.processInfo('Account');
        US_WSREMS__REMS_Program__c remobj = new US_WSREMS__REMS_Program__c();
        remobj.Name ='Sodium Oxybate REMS';
        remobj.US_WSREMS__Status__c ='Active';
        insert remobj;
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType ='Account' and Name ='pharmacy'].Id;
        Account actobj = new Account();
        actobj.Name='test';  
        actobj.phone = '8888888888';
        actobj.RecordTypeId =strRecordTypeId;
        actobj.US_WSREMS__REMS_Program__c =remobj.id;
        actobj.Program__c ='Macitentan REMS';
        insert actobj;
        
        update actobj;
        
       // delete actobj;
        
        //System.enqueueJob(q); 
        Test.stopTest();
    }
    @isTest static void  method2() 
    {
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MetadatService_Mock());
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        //Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl());
        SYN_REMSBigObjectMetaDataService.createBigObjectMetadata('US_WSREMS__REMS_Program__c');
        //System.enqueueJob(q); 
        BigObject_Data_Process_Setings__c accBigObject = new BigObject_Data_Process_Setings__c();
        accBigObject.Source_Object_Name__c = 'REMS Program';
        accBigObject.Source_Object_API_Name__c = 'US_WSREMS__REMS_Program__c';
        accBigObject.Target_Object_Name__c = 'REMS_ProgramBigObject';
        accBigObject.Target_Object_API_Name__c = 'REMS_ProgramBigObject__b';
        accBigObject.Active_Mapping_Process__c = false;
        insert accBigObject;
        
        accBigObject.Active_Mapping_Process__c = true;
        update accBigObject;
        
        accBigObject.Active_Mapping_Process__c = false;
        update accBigObject;
        Test.stopTest();
    }
    
    @isTest static void  method3() 
    {
        Test.startTest();
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            SYN_REMSbigObjectCreateProcessQueuable apc = new SYN_REMSbigObjectCreateProcessQueuable('Account'); 
            System.enqueueJob(apc);
        Test.stopTest();
    }
    @isTest static void  method4()
    {
        US_WSREMS__REMS_Program__c remobj = new US_WSREMS__REMS_Program__c();
          remobj.Name ='Sodium Oxybate REMS  ';
          remobj.US_WSREMS__Status__c ='Active';
          insert remobj; 
          
          Update remobj;
          
          delete remobj;
        /* String strRecordTypeId = [Select Id From RecordType Where SobjectType ='Account' and Name ='pharmacy'].Id;
          System.debug('strRecordTypeId09'+strRecordTypeId);
           Account actobj = new Account();
          actobj.Name='test';  
          actobj.phone = '888-8888888';
          actobj.RecordTypeId =strRecordTypeId;
          actobj.US_WSREMS__REMS_Program__c =remobj.id;
           insert actobj;
          US_WSREMS__REMS_Service_Summary__c remsobj = new US_WSREMS__REMS_Service_Summary__c();
          remsobj.US_WSREMS__Participant__c  = actobj.Id;
          remsobj.US_WSREMS__REMSProgram__c = remobj.id;
          remsobj.US_WSREMS__Requestor_Type__c ='pharmacy'; 
          remsobj.US_WSREMS__StageName__c='Intake';
          insert remsobj; */

    }
    @isTest static void  method5()
    {
        US_WSREMS__REMS_Program__c remobj = new US_WSREMS__REMS_Program__c();
          remobj.Name ='Sodium Oxybate REMS  ';
          remobj.US_WSREMS__Status__c ='Active';
          insert remobj; 
          
          
         String strRecordTypeId = [Select Id From RecordType Where SobjectType ='Account' and Name ='pharmacy'].Id;
          System.debug('strRecordTypeId09'+strRecordTypeId);
           Account actobj = new Account();
          actobj.Name='test';  
          actobj.phone = '8888888888';
          actobj.RecordTypeId =strRecordTypeId;
          actobj.US_WSREMS__REMS_Program__c =remobj.id;
           insert actobj;
          US_WSREMS__REMS_Service_Summary__c remsobj = new US_WSREMS__REMS_Service_Summary__c();
          remsobj.US_WSREMS__Participant__c  = actobj.Id;
          remsobj.US_WSREMS__REMSProgram__c = remobj.id;
          remsobj.US_WSREMS__Requestor_Type__c ='pharmacy'; 
          remsobj.US_WSREMS__StageName__c='Intake';
          insert remsobj;
          
          update remsobj;
          
          delete remsobj;

    }
    @isTest
    static void testVaccDataBigObject() {
       
        List<Vaccination_Data__c> vaccdataRecs = new List<Vaccination_Data__c>{
            new Vaccination_Data__c(Patient_ID__c = 'test')
        };
        
        Test.startTest();
        insert vaccdataRecs;
        update vaccdataRecs;
        delete vaccdataRecs;
        Test.stopTest();
   
    }
}