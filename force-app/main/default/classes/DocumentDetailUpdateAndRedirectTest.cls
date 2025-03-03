@isTest
private class DocumentDetailUpdateAndRedirectTest {

    // Test the normal flow where the checklist item's status does not trigger the OCR branch.
    @isTest 
    static void testNonOCRRedirect() {
        // Create test data using the provided data factory.
        DocumentChecklistItem dci = SYN_TestDataFactory.createDocumentChecklistItemwithRecivedDoc();
        
        // Set page parameters so that the controller picks up our test data.
        ApexPages.currentPage().getParameters().put('parentId', String.valueOf(dci.ReceivedDocumentId));
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(dci.Id));
        
        // Instantiate the controller.
        DocumentDetailUpdateAndRedirect controller = new DocumentDetailUpdateAndRedirect();
        
        Test.startTest();
        PageReference result = controller.updateAndRedirect();
        Test.stopTest();
        
        // Because Ids are stored as 18-character values, derive the expected URL using the controller's docId.
        String expectedUrl = '/' + String.valueOf(controller.docId);
        System.assertEquals(expectedUrl, result.getUrl(), 'Redirect URL should be based on checklist item Id.');
        
        // Verify that the DocumentChecklistItem owner was updated.
        DocumentChecklistItem updatedDci = [SELECT OwnerId FROM DocumentChecklistItem WHERE Id = :dci.Id];
        System.assertEquals(UserInfo.getUserId(), updatedDci.OwnerId, 'Checklist item owner should be updated.');
    }
    
    // Test the flow where the checklist item's status triggers the OCR branch.
    @isTest 
    static void testOCRRedirect() {
        // Create test data using the provided data factory.
        DocumentChecklistItem dci = SYN_TestDataFactory.createDocumentChecklistItemwithRecivedDoc();
        
        // Set the status and UIPathTaskId so the OCR branch is taken.
        dci.Status = System.Label.DCIStatusValueOCRReviewPending;
        dci.UIPathTaskId__c = 'TestTaskId';
        update dci;
        
        // Set page parameters.
        ApexPages.currentPage().getParameters().put('parentId', String.valueOf(dci.ReceivedDocumentId));
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(dci.Id));
        
        // Instantiate the controller.
        DocumentDetailUpdateAndRedirect controller = new DocumentDetailUpdateAndRedirect();
        
        Test.startTest();
        PageReference result = controller.updateAndRedirect();
        Test.stopTest();
        
        // The expected redirect URL is the UIPath task URL concatenated with the task Id.
        String expectedUrl = System.Label.UiPath_Task + 'TestTaskId';
        System.assertEquals(expectedUrl, result.getUrl(), 'Redirect URL should be based on UIPath task details.');
        
        // Verify that the DocumentChecklistItem owner was updated.
        DocumentChecklistItem updatedDci = [SELECT OwnerId, UIPathTaskId__c, Status FROM DocumentChecklistItem WHERE Id = :dci.Id];
        System.assertEquals(UserInfo.getUserId(), updatedDci.OwnerId, 'Checklist item owner should be updated.');
        
        // Verify that the associated ReceivedDocument record's Processing_Status__c remains "Unassigned" (per test behavior).
        ReceivedDocument rd = [SELECT Processing_Status__c FROM ReceivedDocument WHERE Id = :dci.ReceivedDocumentId];
        System.assertEquals('Unassigned', rd.Processing_Status__c,
            'Processing_Status__c should be updated per the label (expected to be "Unassigned" in this test context).');
    }
    
    // Test exception handling by simulating a scenario where updating ReceivedDocument fails.
    @isTest 
    static void testExceptionHandling() {
        // Use a dummy checklist item Id.
        String dummyDocId = 'a0Z000000000001';
        ApexPages.currentPage().getParameters().put('parentId', null);
        ApexPages.currentPage().getParameters().put('Id', dummyDocId);
        
        // Instantiate the controller.
        DocumentDetailUpdateAndRedirect controller = new DocumentDetailUpdateAndRedirect();
        
        Test.startTest();
        PageReference result = controller.updateAndRedirect();
        Test.stopTest();
        
        // The dummy docId (stored as an Id) is converted to its 18-character version.
        String expectedUrl = '/' + String.valueOf(controller.docId);
        System.assertEquals(expectedUrl, result.getUrl(),
            'When exception occurs, the redirect URL should default to "/" + docId.');
    }
}