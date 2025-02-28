public without sharing class Aveed_HCSEducationProgramCtrl {
    
    @AuraEnabled
    public static Map<Id, ContentDistribution> getFilesPublicLink(String fileTitle,String portalRole, String record_type) {
      
        if (String.isBlank(fileTitle)) {
            return null;
        }
        Set<Id> recordIdSet = new Set<Id>();
        List<REMS_Participant_Files__c> participantList = [SELECT Id, Portal_Role__c, REMS_Program__c, Name FROM REMS_Participant_Files__c
                                                           WHERE Name = :fileTitle
                                                           AND REMS_Program__r.Name = :SYN_Utilitycls.AVEED_PROGRAM_NAME
                                                           AND Portal_Role__c = :portalRole
                                                           AND RecordType.Name = :record_type];
        
      if(!participantList.isEmpty()){
        for (REMS_Participant_Files__c participantObj : participantList) {
            recordIdSet.add(participantObj.Id);
        }
    }
      
        Set<Id> documentIds = new Set<Id>();
        if(!recordIdSet.isEmpty()){
        List<ContentDocumentLink> docLinkList = [SELECT ContentDocumentId, LinkedEntityId 
                                                 FROM ContentDocumentLink
                                                 WHERE LinkedEntityId IN :recordIdSet];    
        if(!docLinkList.isEmpty()){                                       
            for (ContentDocumentLink docLink : docLinkList) {
                documentIds.add(docLink.ContentDocumentId);
            }     
        }
      
    }
       
        Map<Id, ContentDistribution> fileWithLinksMap = new Map<Id, ContentDistribution>();
        for (ContentDistribution distribution : [SELECT Id, ContentVersionId, ContentDocumentId, RelatedRecordId, PdfDownloadUrl, ContentDownloadUrl, DistributionPublicUrl 
                                                 FROM ContentDistribution
                                                 WHERE ContentDocumentId IN :documentIds])
        {
            fileWithLinksMap.put(distribution.ContentDocumentId, distribution);
        }
        return fileWithLinksMap;
    }

}