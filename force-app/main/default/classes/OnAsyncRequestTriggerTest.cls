/* Test Class to cover OnAsyncRequest Trigger*/

@isTest
public class OnAsyncRequestTriggerTest {
 @isTest
   static void testTriggerLogic() {
      
        List<AsyncRequest__e> asyncRequestList = new List<AsyncRequest__e>();
       
        List<sObject> testSObjectData = new List<sObject>();
       
        AsyncRequest__e asyncRequest = new AsyncRequest__e(
            Object_API_Name__c = 'Case',
            Action_Type__c = 'Insert',
            Serialized_List__c = JSON.serialize(testSObjectData)
        );
        asyncRequestList.add(asyncRequest);
       
        Test.startTest();
        EventBus.publish(asyncRequestList);
        Test.getEventBus().deliver();
        Test.stopTest();
      
    }
 }