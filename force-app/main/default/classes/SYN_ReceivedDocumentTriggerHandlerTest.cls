@isTest
public class SYN_ReceivedDocumentTriggerHandlerTest {
    
    @testSetup
    Public static void createTestData(){
        ReceivedDocument rc = SYN_TestDataFactory.createReceivedDocument();
        SYN_TestDataFactory.createSOXPrograms1(1 , true, 'Clozapine REMS');
    }
    
    static testMethod void testReceivedDocumentTrigger() {
        ReceivedDocument rc = [select id , OwnerId from ReceivedDocument limit 1];
        String groupname='Sodium_Oxybate_Fax_Queue' ;
       List<group> publicGroupId = [select Id from group where DeveloperName =:groupname and type ='Queue' limit 1];
       List<GroupMember> gmlist= [Select UserOrGroupId From GroupMember where GroupId =:publicGroupId[0].Id];
        rc.OwnerId=gmlist[0].UserOrGroupId;
        update rc;
        
        Program_Fax_Configuration__mdt[] prgfax = [SELECT MasterLabel, QualifiedApiName, REMS_Program__c ,Fax_Number__c FROM Program_Fax_Configuration__mdt where Active__c=true];
        
        ReceivedDocument recdoc=[SELECT Id,Name,First_Assigned_Date__c,Program_Fax_Number__c,REMS_Program__c from ReceivedDocument ];
        system.assertEquals('TestReceivedDocument', recdoc.Name);
        
    }
    
    static testMethod void testStatusWithinSLA(){
        Test.startTest();
        ReceivedDocument rc = [select id , OwnerId from ReceivedDocument limit 1];
        String groupname='Sodium_Oxybate_Fax_Queue' ;
       List<group> publicGroupId = [select Id from group where DeveloperName =:groupname and type ='Queue' limit 1];
       List<GroupMember> gmlist= [Select UserOrGroupId From GroupMember where GroupId =:publicGroupId[0].Id];
        rc.OwnerId=gmlist[0].UserOrGroupId;
        update rc;
        
        rc = [select id , SLA_Status__c  from ReceivedDocument limit 1];
        Test.stopTest();
        //system.assertEquals('Within SLA', rc.SLA_Status__c);
        
    }
    static testMethod void testStatusOutSideSLA(){
        Test.startTest();
        ReceivedDocument rc = [select id , First_Assigned_Date__c from ReceivedDocument limit 1];
        rc.First_Assigned_Date__c  = Datetime.now().addDays(4);
        update rc;
        
        rc = [select id , SLA_Status__c  from ReceivedDocument limit 1];
        Test.stopTest();
       // system.assertEquals('Outside SLA', rc.SLA_Status__c);
    }
}