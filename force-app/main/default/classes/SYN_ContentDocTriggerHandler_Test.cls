@isTest
public class SYN_ContentDocTriggerHandler_Test {
    public static String versionId = '';
    @testSetup static void setupData() {
        String firstname = 'Chaitanya';
        String lastName  = 'Nandamuri';
        
        Id profileId = [Select Id, Name From Profile Where Name = 'REMS Agent' Limit 1].Id;
        Id roleId = null;
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User userRecord = new User(  firstname = firstName,
                                   lastName = lastName,
                                   email = uniqueName + '@nanda' + orgId + '.org',
                                   Username = uniqueName + '@nanda' + orgId + '.org',
                                   EmailEncodingKey = 'ISO-8859-1',
                                   Alias = uniqueName.substring(18, 23),
                                   TimeZoneSidKey = 'America/Los_Angeles',
                                   LocaleSidKey = 'en_US',
                                   LanguageLocaleKey = 'en_US',
                                   ProfileId = profileId
                                  );
        if(!String.isBlank(roleId)){
            userRecord.UserRoleId = roleId;
        }
        
        Insert userRecord;     
        
        
        system.runAs(userRecord){
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
            
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            versionId = contentVersion_1.Id;
        }
        
    }
    
    @IsTest
    static void userCannotDeleteFiles(){
        
        User agentUser = [select id from user where firstname ='Chaitanya' and IsActive = true limit 1];
        
        System.runAs(agentUser){
            
            ContentVersion content=new ContentVersion();

		content.Title='Header_Picture1';

		content.PathOnClient='/' + content.Title + '.jpg';

		Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body');

		content.VersionData=bodyBlob;

		content.origin = 'H';		

		insert content;

		List<ContentDocument> documentsObj = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument

											  where LatestPublishedVersionId=:content.Id];
            
            //List<ContentDocument> conDocList = [select id from ContentDocument where LatestPublishedVersionId=:versionId];
            
            try
            {
               	System.debug('test::'+documentsObj);
                delete documentsObj;
            }
            catch(Exception e)
            {
                system.assert(e.getMessage().contains(System.Label.File_Delete_Error_Msg));
            }
            
            
            
        }
        
        
    }
    
    
}