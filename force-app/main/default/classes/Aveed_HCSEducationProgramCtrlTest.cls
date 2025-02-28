@IsTest
public class Aveed_HCSEducationProgramCtrlTest {
    
    @IsTest() 
    static void getRelatedFilesByRecordTest() {
        
        Map<ID,ContentDistribution> mapContentDistribution=new Map<ID, ContentDistribution>();
        
        US_WSREMS__REMS_Program__c programObj =new US_WSREMS__REMS_Program__c();
        programObj.Name=SYN_Utilitycls.AVEED_PROGRAM_NAME;
        insert programObj;   
        
        Id idRTforParticipantFile =Schema.SObjectType.REMS_Participant_Files__c.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        
        REMS_Participant_Files__c remsParticipantFileobj = new REMS_Participant_Files__c();
        remsParticipantFileobj.Name ='Test Participant';  
        remsParticipantFileobj.RecordTypeId=idRTforParticipantFile;
        remsParticipantFileobj.Portal_Role__c='Public';
        remsParticipantFileobj.REMS_Program__c=programObj.id;
        insert remsParticipantFileobj;
        
        ContentVersion contentVersionObj=new Contentversion();
        contentVersionObj.title='ABC';
        contentVersionObj.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        contentVersionObj.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert contentVersionObj;
        
        ContentDocumentLink contentlinkObj=new ContentDocumentLink();
        contentlinkObj.LinkedEntityId=remsParticipantFileobj.id;
        contentlinkObj.contentdocumentid=[select contentdocumentid from contentversion where id =: contentVersionObj.id].contentdocumentid;
        contentlinkObj.ShareType = 'I';
        contentlinkObj.Visibility = 'AllUsers';         
        insert contentlinkObj;
        
        ContentDocumentLink contentDocumentList = [select contentdocument.id, contentdocument.title, contentdocument.filetype from contentdocumentlink 
                                                  where linkedentityid =:remsParticipantFileobj.id];
        ContentVersion cver = [select id from contentversion where contentdocumentid = :contentDocumentList.contentdocument.id];
        ContentDistribution contentDocumentObj = new ContentDistribution();
        contentDocumentObj.Name = 'Test';
        contentDocumentObj.ContentVersionId = cver.id;
        contentDocumentObj.PreferencesAllowViewInBrowser= true;
        contentDocumentObj.PreferencesLinkLatestVersion=true;
        contentDocumentObj.PreferencesNotifyOnVisit=false;
        contentDocumentObj.PreferencesPasswordRequired=false;
        contentDocumentObj.PreferencesAllowOriginalDownload= true;
        insert contentDocumentObj;
        
        List<REMS_Participant_Files__c> participantList = [SELECT Id,RecordType.DeveloperName,Portal_Role__c,REMS_Program__c FROM REMS_Participant_Files__c
                                                           WHERE RecordType.DeveloperName = 'Prescriber' LIMIT 1];
        
        
        Test.startTest();
        mapContentDistribution = Aveed_HCSEducationProgramCtrl.getFilesPublicLink(remsParticipantFileobj.Name,'Public','Prescriber');
        
        System.assert(!mapContentDistribution.isEmpty(), 'There must be at least one record!');
        Test.stopTest();
    }
}