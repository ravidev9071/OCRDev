@isTest
private class SYN_FileShareComponentControllerTest {
    static testMethod void testFilesharingcontroller() {
        
       // Account acc=SYN_TestDataFactory.createAccount();
        
        ContentVersion cv=SYN_TestDataFactory.createContentVersion();
        
        ContentDocument document = [
            SELECT Id, Title, FileType, LatestPublishedVersionId   
            FROM ContentDocument LIMIT 1
        ];
         
        
        SYN_FileShareComponentController.getObjType(SYN_TestDataFactory.createDocumentChecklistItem().Id);
        
        Account acc = [Select Id From Account Where Name =: 'TestAccount'];
        
        ContentDocumentLink cdl=SYN_TestDataFactory.createContentDocumentLink(document.id, acc.Id);
        
        System.assertEquals(1, SYN_FileShareComponentController.getContentDetailsWrapper(acc.Id).size());
        
        SYN_FileShareComponentController.getObjType(SYN_TestDataFactory.createReceivedDocument().Id);
        
    }
    
}