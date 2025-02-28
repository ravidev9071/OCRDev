@isTest()
public class RemsBatchToSendBlastEmailsTest {

    @testSetup
    static void setupTestData() {
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Aveed REMS','Active');
            
         // Collecting Prescriber Account
         Id prescriberAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        
         Account accountObj = new Account();
         accountObj.FirstName= 'TestUser';
         accountObj.LastName = 'Program';
         accountObj.RecordTypeId = prescriberAccRecordTypeId;
         accountObj.US_WSREMS__Channel__c  = 'fax';
         accountObj.US_WSREMS__Program_Picklist__c = 'Aveed REMS';
         accountObj.US_WSREMS__SLN_State__c  ='AK';
         accountObj.Phone = '9999999999';
         accountObj.US_WSREMS__NPI__c  = '9999999999';
         accountObj.US_WSREMS__Phone_Type__c  = 'mobile';
         accountObj.US_WSREMS__EXT__c  = '123';
         accountObj.Fax = '9999999999';
         accountObj.US_WSREMS__Email__c  ='testmaci@test.com';
         accountObj.US_WSREMS__Preferred_Contact_Method__c  = 'email';
         accountObj.US_WSREMS__REMS_Program__c = programObj.Id;
         accountObj.PersonEmail = 'abc123@test.com';
         insert accountObj;
    }


    @isTest
    public static void BatchToSendInvitationBlastEmails_Test() {
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'testDeveloperName';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();

            insert validEmailTemplate;
                
            OrgWideEmailAddress addresses = [SELECT Id FROM OrgWideEmailAddress Where IsVerified = TRUE LIMIT 1];
                
                Test.StartTest();
                    RemsBatchToSendBlastEmails.RequestInputWrapper inputRequest = new RemsBatchToSendBlastEmails.RequestInputWrapper();
                    inputRequest.queryString = 'Select Id, US_WSREMS__Email__c, PersonContactId, US_WSREMS__Send_Invitation_Date__c From Account Limit 1';
                    inputRequest.templateId = validEmailTemplate.Id;
                    inputRequest.orgEmailId = addresses.Id;
                    inputRequest.ObjectName = 'Account';
                    inputRequest.bccAddress = 'test123@test.com';
                    inputRequest.toAddressField = 'US_WSREMS__Email__c';
                    inputRequest.setSaveActivity = TRUE;
                    inputRequest.updateRecord = FALSE;
                    RemsBatchToSendBlastEmails batch = new RemsBatchToSendBlastEmails(inputRequest);
                    Database.executeBatch(batch, 200); 
                Test.StopTest();

                List<Account> accList = [ Select Id, US_WSREMS__Email__c, PersonContactId, US_WSREMS__Send_Invitation_Date__c From Account Where US_WSREMS__Send_Invitation_Date__c =: System.Today() ];
                System.assertEquals(accList != null, true);
        }             
    }

    @isTest
    public static void BatchToSendInvitationBlastEmails_Test2() {
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'testDeveloperName';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();

            insert validEmailTemplate;
                
            OrgWideEmailAddress addresses = [SELECT Id, Address FROM OrgWideEmailAddress Where IsVerified = TRUE LIMIT 1];
                
                Test.StartTest();
                    RemsBatchToSendBlastEmails.RequestInputWrapper inputRequest = new RemsBatchToSendBlastEmails.RequestInputWrapper();
                    inputRequest.queryString = 'Select Id, US_WSREMS__Email__c, PersonContactId, US_WSREMS__Send_Invitation_Date__c From Account Limit 1';
                    inputRequest.templateName = validEmailTemplate.DeveloperName;
                    inputRequest.orgEmailAddress = addresses.Address;
                    inputRequest.ObjectName = 'Account';
                    inputRequest.bccAddress = 'test123@test.com';
                    inputRequest.toAddressField = 'US_WSREMS__Email__c';
                    inputRequest.setSaveActivity = FALSE;
                    inputRequest.updateRecord = TRUE;
                    RemsBatchToSendBlastEmails batch = new RemsBatchToSendBlastEmails(inputRequest);
                    Database.executeBatch(batch, 200); 
                Test.StopTest();
                List<Account> accList = [ Select Id, US_WSREMS__Email__c, PersonContactId, US_WSREMS__Send_Invitation_Date__c From Account Where US_WSREMS__Send_Invitation_Date__c =: System.Today() ];
                System.assertEquals(accList != null, true);
        }             
    }

}