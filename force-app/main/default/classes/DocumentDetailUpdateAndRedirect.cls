public class DocumentDetailUpdateAndRedirect {
    public Id recordId { get; set; }
    
    // Constructor: Retrieve the record Id from the URL parameters.
    public DocumentDetailUpdateAndRedirect() {
        recordId = ApexPages.currentPage().getParameters().get('id');
    }
    
    // This method performs the update (if applicable) and then redirects.
    public PageReference updateAndRedirect() {
        if (recordId != null) {
            try {
                // Query the DocumentChecklistItem record.
                DocumentChecklistItem dci = [
                    SELECT Id, Status, OwnerId, ReceivedDocumentId
                    FROM DocumentChecklistItem
                    WHERE Id = :recordId
                    LIMIT 1
                ];
                
                // If the Status is not "OCR Review" or "Complete", update the records.
                if (dci.Status != 'OCR Review' && dci.Status != 'Complete') {
                    // Update DocumentChecklistItem owner to the current user.
                    //dci.OwnerId = UserInfo.getUserId();
                    update dci;
                    
                    // If the parent ReceivedDocument exists, update it.
                    if (dci.ReceivedDocumentId != null) {
                        ReceivedDocument rd = [
                            SELECT Id, OwnerId, Processing_Status__c
                            FROM ReceivedDocument
                            WHERE Id = :dci.ReceivedDocumentId
                            LIMIT 1
                        ];
                        //rd.OwnerId = UserInfo.getUserId();
                        rd.Processing_Status__c = 'Assigned';
                        update rd;
                    }
                }
                
                // Redirect to the DocumentChecklistItem detail page.
                PageReference detailPage = new PageReference('/' + recordId);
                detailPage.setRedirect(true);
                return detailPage;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'An error occurred: ' + ex.getMessage()
                ));
            }
        }
        return null;
    }
}