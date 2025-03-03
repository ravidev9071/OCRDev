public with sharing class DocumentChecklistController {
    @AuraEnabled
    public static String updateRecordsAndGetRedirectUrl(Id recordId) {
        if(recordId == null) {
            throw new AuraHandledException('Record Id is required.');
        }
        
        // Query the DocumentChecklistItem record.
        DocumentChecklistItem dci = [
            SELECT Id, Status, OwnerId, ReceivedDocumentId, UIPathTaskId__c 
            FROM DocumentChecklistItem 
            WHERE Id = :recordId
            LIMIT 1
        ];
        
        // Update DocumentChecklistItem owner.
        dci.OwnerId = UserInfo.getUserId();
        update dci;
        
        // If a related ReceivedDocument exists, update its owner.
        if(dci.ReceivedDocumentId != null) {
            ReceivedDocument rd = [
                SELECT Id, OwnerId, Processing_Status__c 
                FROM ReceivedDocument 
                WHERE Id = :dci.ReceivedDocumentId
                LIMIT 1
            ];
            rd.OwnerId = UserInfo.getUserId();
            /*if(dci.Status != 'OCR Review') {
                rd.Processing_Status__c = 'Assigned';
            }
            update rd;*/
        }
        
        // Determine and return the redirect URL.
        if(dci.Status == 'OCR Review') {
            if(String.isBlank(dci.UIPathTaskId__c)) {
                throw new AuraHandledException('UIPathTaskId__c is missing from the record.');
            }
            return 'https://cloud.uipath.com/syneoshealth/Test/orchestrator_/tasks/view/4444479' + dci.UIPathTaskId__c;
        } else {
            return '/' + dci.Id;
        }
    }
}