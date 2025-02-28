@isTest
public class SYN_VeevaAPI_Search_Test
{
    public static testMethod void method1() 
    { 
       //Try {
         US_WSREMS__REMS_Program__c remobj = new US_WSREMS__REMS_Program__c();
          remobj.Name ='Sodium Oxybate REMS  ';
          remobj.REMS_Project_Code__c = 'BT6825';
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
           
         
          
        case CaseObj = new Case();
        CaseObj.US_WSREMS__REMS_Service_Summary__c = remsobj.id;
        CaseObj.US_WSREMS__REMS_Program__c = remobj.id;
        CaseObj.US_WSREMS__Participant__c = actobj.Id;
        CaseObj.US_WSREMS__Call_Notes__c = 'test';
        CaseObj.US_WSREMS__Call_Outcome__c = 'Call Back';
        CaseObj.US_WSREMS__Call_Outcome_Reason__c = 'Holiday';
        CaseObj.US_WSREMS__Last_Name__c = 'Welsh';
        CaseObj.US_WSREMS__DEA__c = 'AW9292765';
        CaseObj.status = 'New';
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS-SYN_Patient_Person_Account';
         insert CaseObj;
         list<string> lstcase = new list<string>();
         lstcase.add(CaseObj.id);
         Test.startTest();
             Test.setMock(HttpCalloutMock.class, new SYN_VeevaAPIAuthJSON_MockCall());
             //Test.setMock(HttpCalloutMock.class, new SYN_VeevaAPISearchJSON_MockCall());
            // boolean isValid = SYN_VeevaAPI_Search.searchCurrentCase(lstcase);
             SYN_VeevaAPI_Search.searchCurrentCase(lstcase);
         Test.stopTest(); 
       //}
       // catch(Exception e)
       
       {
          
       }
    }
}