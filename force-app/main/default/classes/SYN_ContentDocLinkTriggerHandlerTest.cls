@IsTest
public class SYN_ContentDocLinkTriggerHandlerTest {
    
    @testsetup static void setupMethod(){
        SYN_TestDataFactory.createSOXPrograms1(1 , true, 'Clozapine REMS');
    }
      
    static testMethod void testContentDocumentLinkTrigger() {
        
        DocumentChecklistItem documentchecklist=SYN_TestDataFactory.createDocumentChecklistItem();
        Contentversion cv=SYN_TestDataFactory.createContentVersion();
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId   
            FROM ContentDocument
        ];
        
        ContentDocumentLink cdl=SYN_TestDataFactory.createContentDocumentLink(documents[0].id, documentchecklist.Id);
        SYN_TestDataFactory.createefaxRecord();
        system.assertEquals(1, documents.size());
    }
    
}