public with sharing class OCR_ECMS_Controller {
    @AuraEnabled(cacheable=true)
    public static StagedData__c getJsonStringFromRecord(String Id) {
        List<StagedData__c> records = [SELECT OCRECMSRepsonse__c FROM StagedData__c where Id =: Id LIMIT 1];
        if (!records.isEmpty()) {
            return records[0];
        } else {
            return null; // Handle appropriately
        }
    }

    @AuraEnabled(cacheable=true)
    public static void getData() {
        System.debug(LoggingLevel.debug, 'TestData');
    }
}