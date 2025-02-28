@isTest
public class SYN_BatchToUpdateKAExpirationStatusTest{
    
    @isTest
    public static void testUpdateKAExpiration() {
        id rssKARecTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Knowledge_Assessment').getRecordTypeId();
        US_WSREMS__REMS_Program__c remsProg = SYN_TestDataFactory.createREMSProgramSurvey();
        SYN_TestDataFactory.createProgramServiceConfig(true, remsProg.id);
        US_WSREMS__REMS_Service_Summary__c RssObj = SYN_TestDataFactory.createKAService(True, remsProg.id, rssKARecTypeId);
        test.startTest();
        SYN_BatchToUpdateKAExpirationStatus updateKAExp = new SYN_BatchToUpdateKAExpirationStatus('Sodium Oxybate REMS');
        Database.executeBatch(updateKAExp);
        test.stopTest();
        US_WSREMS__REMS_Service_Summary__c rsObj = [SELECT ID, US_WSREMS__Participant__r.US_WSREMS__Status__c,US_WSREMS__Participant__r.Sub_Status__c  From US_WSREMS__REMS_Service_Summary__c where ID =:RssObj.ID]; 
        System.assertEquals(rsObj.US_WSREMS__Participant__r.US_WSREMS__Status__c,'Inactive');
        System.assertEquals(rsObj.US_WSREMS__Participant__r.Sub_Status__c, 'Expired Training');
    }
}