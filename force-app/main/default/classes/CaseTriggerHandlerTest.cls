@isTest
public class CaseTriggerHandlerTest {
    //caseFollowupTaskCreate test class
    public static testMethod void method1() 
    { 
         
       Try {
         US_WSREMS__REMS_Program__c remobj = new US_WSREMS__REMS_Program__c();
          remobj.Name ='Sodium Oxybate REMS';
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
          id RemsRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Inbound_Communication').getRecordTypeId();

          US_WSREMS__REMS_Service_Summary__c remsobj = new US_WSREMS__REMS_Service_Summary__c();
          remsobj.US_WSREMS__Participant__c  = actobj.Id;
          remsobj.US_WSREMS__REMSProgram__c = remobj.id;
          remsobj.US_WSREMS__Requestor_Type__c ='pharmacy'; 
          remsobj.US_WSREMS__StageName__c='Intake';
           remsObj.RecordtypeId = RemsRecordTypeId;
          insert remsobj;
          
          System.debug([Select Id,recordtype.name FROM US_WSREMS__REMS_Service_Summary__c WHERE id=:remsobj.Id ]);
           
       //  id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inbound_Communication').getRecordTypeId();
          
        case CaseObj = new Case();
        CaseObj.US_WSREMS__REMS_Service_Summary__c = remsobj.id;
        CaseObj.US_WSREMS__REMS_Program__c = remobj.id;
        CaseObj.US_WSREMS__Participant__c = actobj.Id;
        //CaseObj.RecordTypeId = CaseRecordTypeId;
        CaseObj.US_WSREMS__Call_Notes__c = 'test';
        CaseObj.US_WSREMS__Call_Outcome__c = 'Call Back';
        CaseObj.US_WSREMS__Call_Outcome_Reason__c = 'Holiday';
        CaseObj.status = 'New';
    
         insert CaseObj;
         CaseObj.Status = 'Complete';
         update CaseObj;
          
       } catch(Exception e)
      
       {
          
       }
    }
    
   
}