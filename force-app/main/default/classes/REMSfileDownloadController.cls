/**
* @File Name          : REMSfileDownloadController.cls
* @Description        : This class download files .
* @TestClass          : REMSfileDownloadControllerTest
* @Author             : Shikha Chaurasia
* @Date               : 07-06-2022
**/

public without sharing class REMSfileDownloadController {
    
    public static final string GUEST_USER = 'Guest';
    public static final  string Visibility = 'AllUsers';
    
    @AuraEnabled(cacheable=true)
    public static Map<ID, ContentDistribution> getRelatedFilesByRecordId(String recordTypeDevName,String programId,String portalRole) {
        
        set<Id> recordIdSet = new set<Id>();
        List<ID> docLinkIdList = new List<ID>();
        Map<ID,ContentDistribution> mapContentDistribution=new Map<ID, ContentDistribution>(); 
        Map<ID, String> mapIdTitle = new Map<ID, String>();
      
        List<REMS_Participant_Files__c>  participantList = [Select Id,Name, RecordTypeId FROM REMS_Participant_Files__c  
                                                 WHERE RecordType.DeveloperName= : String.escapeSingleQuotes(recordTypeDevName) 
                                                 AND Portal_Role__c= : String.escapeSingleQuotes(portalRole) AND REMS_Program__c= : String.escapeSingleQuotes(programId) 
                                                 ];
        for(REMS_Participant_Files__c participantObj: participantList){
            recordIdSet.add(participantObj.Id);
        }
    
        List<ContentDocumentLink> docLinkList = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink
                                                 WHERE LinkedEntityId =:recordIdSet];         
    
        for (ContentDocumentLink docLink : docLinkList) {
            docLinkIdList.add(docLink.ContentDocumentId);
        }     
        
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId, FileExtension, Title
                                     FROM ContentVersion WHERE ContentDocumentId IN : docLinkIdList ];
              
        for (ContentVersion contentVersionObj : contentVersionList) {
            mapIdTitle.put(contentVersionObj.ContentDocumentId, contentVersionObj.Title);
        }
        

        List<ContentDistribution> contentDistList = [Select Id,Name, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl 
                                    from ContentDistribution 
                                    where ContentDocumentId IN: docLinkIdList ORDER BY CreatedDate ASC];

        for(ContentDistribution contentDistObj:contentDistList){
            contentDistObj.Name=mapIdTitle.get(contentDistObj.ContentDocumentId);
            mapContentDistribution.put(contentDistObj.ContentDocumentId,contentDistObj);
        }

        return mapContentDistribution;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<ID, ContentDistribution> getRelatedFilesByProgramName(String recordTypeDevName,String programName,String portalRole) {
        set<Id> recordIdSet = new set<Id>();
        List<ID> docLinkIdList = new List<ID>();
        Map<ID,ContentDistribution> mapContentDistribution=new Map<ID, ContentDistribution>(); 
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        List<ContentDocumentLink> docLinkList = new List<ContentDocumentLink>();
        List<US_WSREMS__REMS_Program__c> programList =[Select id,Name from US_WSREMS__REMS_Program__c where Name =:programName];
        return getRelatedFilesByRecordId(recordTypeDevName,programList[0].Id, portalRole);
    }
    @AuraEnabled(cacheable=true)
    public static Id getProgramId(String programName){
        List<US_WSREMS__REMS_Program__c> remsList= [Select id from US_WSREMS__REMS_Program__c  where name = :programName limit 1];
        return  (remsList != null && remsList.size() > 0) ? remsList[0].id : null;
    }
}