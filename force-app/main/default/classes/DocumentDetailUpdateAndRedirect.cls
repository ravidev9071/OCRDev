/**
 * @File Name    : DocumentDetailUpdateAndRedirect.cls
 * @Description  : This class handles the update of DocumentChecklistItem and ReceivedDocument records 
 *                 and then redirects the user based on the document status.
 *
 * @Author             : Wilco
 * @Last Modified By   : Wilco
 * @Last Modified On   : February 28, 2025
 * @Modification Log   :
 * ==============================================================================
 * Ver | Date             | Author | Modification
 * ==============================================================================
 * 1.0 | February 28, 2025 |        | Initial Version
 **/

public with sharing class DocumentDetailUpdateAndRedirect {
    
    // Record IDs from the current page parameters
    public Id recDocId { get; set; }
    public Id docId { get; set; }
    
    // Constructor to initialize record IDs
    public DocumentDetailUpdateAndRedirect() {
        recDocId = ApexPages.currentPage().getParameters().get('parentId');
        docId = ApexPages.currentPage().getParameters().get('Id');
    }
    
    // Method to update DocumentChecklistItem and ReceivedDocument records, then redirect the user
    public PageReference updateAndRedirect() {
        // List to hold all records to update
        List<SObject> recordsToUpdate = new List<SObject>();
        
        // Variables to capture the status and UIPath task id from the matching DocumentChecklistItem record
        String strStatus,uiPathTaskId;
        
        // Query DocumentChecklistItem records related to the ReceivedDocument
        for (DocumentChecklistItem dci : [
            SELECT Id, Status, OwnerId, ReceivedDocumentId, UIPathTaskId__c, 
                   ReceivedDocument.OwnerId, ReceivedDocument.Processing_Status__c
            FROM DocumentChecklistItem
            WHERE ReceivedDocumentId = :recDocId
        ]) {
            // If the current record matches the document id, capture its status and UIPath task id
            if (docId == dci.Id) {
                strStatus = dci.Status;
                uiPathTaskId = dci.UIPathTaskId__c;
            }
            
            // Update DocumentChecklistItem owner to the current user
            dci.OwnerId = UserInfo.getUserId();
            recordsToUpdate.add(dci);
        }
        
        // Update the ReceivedDocument record with new owner and processing status
        recordsToUpdate.add(new ReceivedDocument(
            Id = recDocId,
            OwnerId = UserInfo.getUserId(),
            Processing_Status__c = System.Label.ReceivedDocumentValueAssigned
        ));
        
        // Attempt to update records in the database
        try {
            List<Database.SaveResult> results = Database.update(recordsToUpdate, false);
        } catch (DmlException e) {
            System.debug(LoggingLevel.Debug, 'Error Updating: ' + e.getMessage());
        }
        
        // Determine the redirect URL based on the document status
        String redirectUrl = (strStatus == System.Label.DCIStatusValueOCRReviewPending)
            ? System.Label.UiPath_Task + uiPathTaskId
            : '/' + docId;
        
        // Redirect to the built URL
        return new PageReference(redirectUrl).setRedirect(true);
    }
}