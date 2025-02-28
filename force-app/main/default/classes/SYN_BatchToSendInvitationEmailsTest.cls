@isTest()
public class SYN_BatchToSendInvitationEmailsTest {
    @isTest
    public static void BatchToSendInvitationEmails_Test() {
            
        Id prescriberAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            
         // Collecting Prescriber Account
        account prescriberAcc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
        prescriberAcc.Email_address__c='test22@gmail.com';
        prescriberAcc.Invitation_Days__c='Day1';
        update prescriberAcc;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId = : prescriberAcc.id LIMIT 1];
      
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'testDeveloperName';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();

        insert validEmailTemplate;
            
        OrgWideEmailAddress addresses = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
            
            Test.StartTest();
            SYN_BatchToSendInvitationEmails batch = new SYN_BatchToSendInvitationEmails('select Id,FirstName,US_WSREMS__Email__c,RecordType.DeveloperName,Email_address__c,Invitation_Days__c,Account.PersonContactId from account',validEmailTemplate.Id,con.Id,addresses.Id,'Account','Day2','bccAddress');
            DataBase.executeBatch(batch); 
            
            Test.StopTest();  
   
}             
    }
    
    
      @isTest
    public static void BatchToSendInvitationEmailsAffiliation_Test() {
      id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
      id recordTypeIdPharmacy = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
         
         US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
         Account pharmCParticipanAccount = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,recordTypeIdPharmacyParticipant);
         pharmCParticipanAccount.US_WSREMS__Email__c='test22@gmail.com';
         Update pharmCParticipanAccount;
        
         Account pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy);
           
       Contact con = [SELECT Id FROM Contact WHERE AccountId = : pharmCParticipanAccount.id LIMIT 1];
      
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'testDeveloperName';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();

        insert validEmailTemplate;
            
        OrgWideEmailAddress addresses = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
            
            Test.StartTest();
            
            US_WSREMS__Affiliation__c createAffiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmCParticipanAccount.Id,pharmCAccount.Id);
            createAffiliation.Status__c ='Active';
            Update createAffiliation;
            SYN_BatchToSendInvitationEmails batch1 = new SYN_BatchToSendInvitationEmails('select Id,FirstName,US_WSREMS__Email__c,RecordType.DeveloperName,Email_address__c,Invitation_Days__c,Account.PersonContactId from account',validEmailTemplate.Id,con.Id,addresses.Id,'US_WSREMS__Affiliation__c','Day2','bccAddress');
            
            DataBase.executeBatch(batch1); 
            Test.StopTest();  
   
        }     
    }

}