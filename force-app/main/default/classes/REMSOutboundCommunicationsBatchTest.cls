@istest
public class REMSOutboundCommunicationsBatchTest {
static testMethod void testMethod1() 
    {
        List<REMS_Outbound_Communication__c> lstREMSOutboundCommunications= new List<REMS_Outbound_Communication__c>();
        for(Integer i=0 ;i <200;i++)
        {
            REMS_Outbound_Communication__c remsOC = new REMS_Outbound_Communication__c();
            remsOC.Status__c ='pending';
            lstREMSOutboundCommunications.add(remsOC);
        }
        
        insert lstREMSOutboundCommunications;
        
        Test.startTest();

            REMSOutboundCommunicationsBatch obj = new REMSOutboundCommunicationsBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}