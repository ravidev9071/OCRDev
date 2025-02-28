public class SYN_FileShareComponentController {
    
    @AuraEnabled
    public static List<AccountFileListWrapper> getContentDetailsWrapper(String recordId) {
        
        List<AccountFileListWrapper> list_wrapper=new List<AccountFileListWrapper>();
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId, LinkedEntityId 
                                                         FROM   ContentDocumentLink 
                                                         WHERE  LinkedEntityId =: recordId];
        Set<Id> contentDocumentId = new Set<Id>();
       
        for(ContentDocumentLink cdl : contentDocumentList){
            contentDocumentId.add(cdl.ContentDocumentId);
        }
        
        List<ContentVersion> contentVersionList = [SELECT Id, VersionData, FileType, Title, FileExtension,
                                                   ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
                                                   CreatedDate, ContentDocumentId, ContentDocument.FileType
                                                   FROM   ContentVersion 
                                                   WHERE  ContentDocumentId IN : contentDocumentId];
        for(ContentVersion cv:contentVersionList){
            AccountFileListWrapper af=new AccountFileListWrapper();
            af.content=cv;
            af.versionData='';
            af.fileType=ContentType(cv.ContentDocument.FileType);
            list_wrapper.add(af);
        }
        
        return list_wrapper;
    }
    
    @AuraEnabled
    public static Boolean getObjType(String recordId){
         String sObjName = Id.valueof(recordId).getSObjectType().getDescribe().getName(); 
        if(sObjName == 'DocumentChecklistItem'){
                return true;
        }else{
            return false;
        }
    }
    
  
    @AuraEnabled
    public static string ContentType(String fileType) {
        
        switch on fileType.toLowerCase(){
            when 'docx' {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'csv' {
                return 'application/vnd.ms-excel';
            }
            when 'wav' {
                return 'audio/wav';
            }
            when 'wmv' {
                return 'video/x-ms-wmv';
            }
            when 'mp3' {
                return 'audio/mpeg';
            }
            when 'mp4' {
                return 'video/mp4';
            }
            when 'png' {
                return 'image/png';
                
            }
            when 'pdf' {
                return 'application/pdf';
                
            }
            when else {
                return 'image/jpeg';
            }
        }
        
    }
    
    
    public class AccountFileListWrapper{
        @AuraEnabled
        public ContentVersion content{get;set;}
        @AuraEnabled
        public String versionData{get;set;}
        @AuraEnabled
        public String fileType{get;set;}
       
    }
    
    
}