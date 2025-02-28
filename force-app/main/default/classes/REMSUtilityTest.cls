@IsTest
private class REMSUtilityTest {
    @IsTest
    static void testRetrieveRecTypeNameId() {
        // Test data setup
        String objectName = 'Account'; 
         String field = 'Name';
        String customPermissionName = 'Custom_Permission';
        Test.startTest();
        Map<String, Id> result = REMSUtility.retrieveRecTypeNameId(objectName);
        Map<String, Id> result1 = REMSUtility.retrieveRecTypeDeveloperNameId(objectName);
        Map<Id, String> result2 = REMSUtility.retrieveRecTypeIdDeveloperName(objectName);
        Boolean result3 = REMSUtility.isFieldAccessible(objectName, field);
        Boolean result4 = REMSUtility.isFieldCreateableAndUpdateable(objectName, field);
        Boolean result5 = REMSUtility.validateCustomPermission(customPermissionName);
        Test.stopTest();
        // Perform assertions
        System.assertNotEquals(null, result.size(), 'The size should not be null.');
        System.assertNotEquals(null, result1.size(), 'The size should not be null.');
        System.assertNotEquals(null, result2.size(), 'The size should not be null.');
        System.assertEquals(true, result3);        
        System.assertEquals(true, result4);
    }   
    
    @isTest
    static void testREMSUtilitycls() {
         string objectName = 'REMS_Service_Summary__c';
        Test.startTest();
        
        // Call the method being tested
        Map<String, Id> result = REMSUtilitycls.retrieveRecTypeNameId(objectName);
         
        Test.stopTest();
        System.assertNotEquals(null, result.size(), 'The size should not be null.');
    }
    
    @isTest
    private static void getRecordTypeNameAndSchemaTest(){
        string objectName = 'Account';
        Test.startTest();
        
        // Call the method being tested
        Map<String,Schema.RecordTypeInfo> result = REMSUtility.getRecordTypeNameAndSchema(objectName);
         
        Test.stopTest();
        System.assertNotEquals(null, result.size(), 'The size should not be null.');
    }
    
    @isTest
    private static void retrieveRecTypeIdDeveloperName_ProductTest(){
        string objectName = 'Account';
        Test.startTest();
        
        // Call the method being tested
        Map<Id, String> result = REMSUtility.retrieveRecTypeIdDeveloperName_Product(objectName);
         
        Test.stopTest();
        System.assertNotEquals(null, result.size(), 'The size should not be null.');
    }
    
    @isTest
    private static void retrieveRecTypeDeveloperNameId_ProductTest(){
        string objectName = 'Account';
        
        Test.startTest();
        // Call the method being tested
        Map<String, Id> result = REMSUtility.retrieveRecTypeDeveloperNameId_Product(objectName);
         
        Test.stopTest();
        System.assertNotEquals(null, result.size(), 'The size should not be null.');
    }

}