@isTest
public class SYN_InContact_BatchClass_Test {
    
    public static testMethod void method1() {
        
        US_WSREMS__REMS_Program__c remobj = new US_WSREMS__REMS_Program__c();
        remobj.Name ='Sodium Oxybate REMS';
        remobj.REMS_Project_Code__c = 'BT6825';
        remobj.US_WSREMS__Status__c ='Active';
        insert remobj; 
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType ='Account' and Name ='pharmacy'].Id;
        Account actobj = new Account();
        actobj.Name='test';  
        actobj.phone = '8888888888';
        actobj.RecordTypeId =strRecordTypeId;
        actobj.US_WSREMS__REMS_Program__c =remobj.id;
        insert actobj;
        
        contact con = new contact();
        con.lastName='GTest contact';
        insert con;
        
        Case caseObj=new Case();
        //  caseObj.RecordTypeId=recordTypeIdcase;
        caseObj.US_WSREMS__Participant__c=actobj.Id;
        caseObj.US_WSREMS__REMS_Program__c=actobj.US_WSREMS__REMS_Program__c;
        // caseObj.US_WSREMS__REMS_Service_Summary__c=ServiceId;
        caseObj.inContact_Contact_ID__c=con.Id;
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS-SYN_Patient_Person_Account';
        insert caseObj;
        
        Test.startTest();
        SYN_Incontact_BatchClass ba= new SYN_Incontact_BatchClass();
        test.setMock(HttpCalloutMock.class, new SYN_Incontact_Batch_Mock());
        Id jobid= Database.executeBatch(ba,5);
        SYN_Incontact_BatchClass_Schedule testsche = new SYN_Incontact_BatchClass_Schedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
        
    }
}