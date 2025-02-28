@isTest
public class SYN_EmailUtility_Test {
    @testSetup
    public static void dataSetup(){
        US_WSREMS__REMS_Program__c remsProg1 = new US_WSREMS__REMS_Program__c();
        remsProg1.Name = 'Sodium Oxybate REMS';
        remsProg1.US_WSREMS__Status__c ='Active';
        remsProg1.QueueName__c ='Syneos Test Call Queue';
        insert remsProg1;
        
        Account acc=new Account();
        acc.Name='test';
        acc.Phone='1234567789';
        acc.US_WSREMS__REMS_Program__c=remsProg1.id;
        insert acc;
        
        contact con= new contact();
        con.LastName='test';
        con.AccountId=acc.id;
        insert con;
        
        Attachment att=new Attachment();
        att.Body=Blob.valueOf('test');
        att.Name='Note_';
        att.parentId=acc.id;
        insert att;
         }
    @isTest
    public static void sendEmailTest(){
        string recipientType1 = 'Prescriber';
        string recipientType2= 'Patient';
        string recipientType3='Pharmacy User';
        
        String programName='Sodium Oxybate REMS';
        string tempName = 'SOX-Email Address Change Notification';
        string tempName1 = 'SOX-Email Address Change Test';
        
        Account acc=[select id from Account Limit 1];
        string accountid=acc.id;
        
        List<string> attachIdList=new List<string>();
        Attachment attach=[Select Name, Body From Attachment limit 1];
        attachIdList.add(attach.id);
        
        SYN_CorrespondenceHandler.EmailWrapperClass emailWrapper=new SYN_CorrespondenceHandler.EmailWrapperClass();
        emailWrapper.setActivity=true;
        emailWrapper.templateName='Email_Address_Change_Notification';
        emailWrapper.recipientType='Patient';
        emailWrapper.whatIdVal=acc.id;
        emailWrapper.targetObjIdVal=accountid;
        emailWrapper.attachIds=attachIdList;
        
        SYN_EmailUtility.sendEmail(emailWrapper);
        SYN_EmailUtility.emailRecipientList(recipientType1);
        SYN_EmailUtility.emailRecipientList(recipientType3);
        SYN_EmailUtility.getOWEAddressId('abc');
        SYN_EmailUtility.getAllCorrespondenceSettings();
        SYN_EmailUtility.getAttachments(attachIdList);
        SYN_EmailUtility.getProgramSpecificCorresSett(programName,tempName);
        SYN_EmailUtility.getEmailTemplate(tempName1);
        
    }
    /*
    static testMethod void sendEmailTest()
    {
        user userRec = [SELECT Id 
                        FROM USER
                        LIMIT 1];
        US_WSREMS__REMS_Program__c remsProg = new US_WSREMS__REMS_Program__c();
        remsProg.Name = 'Sodium Oxybate REMS';
        remsProg.US_WSREMS__Status__c ='Active';
        remsProg.QueueName__c ='Syneos Test Call Queue';
        insert remsProg;
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = remsProg.id;
        caseObj.US_WSREMS__Call_Notes__c = 'test';
        caseObj.status = 'New';
        caseObj.ownerId = userRec.Id;       
        insert caseObj;
        string tempName = 'SOX Noncompliance Notification';
        string recipientType1 = 'Prescriber';
        string recipientType2= 'Patient';
        string recipientType3='Pharmacy User';
        string recipientType4='Test';
        
        REMS_Correspondence_Settings__mdt CorresSett = [SELECT Id, From__c, Template_Name__c 
                                                        FROM REMS_Correspondence_Settings__mdt 
                                                        WHERE Active__c = TRUE LIMIT 1];
        
        //SYN_EmailUtility.sendEmail(caseObj, corresSett.Template_Name__c, recipientType1, corresSett.From__c, FALSE, caseObj.Id, caseobj.OwnerId, new List<String>{});
        //SYN_EmailUtility.sendEmail(caseObj, corresSett.Template_Name__c, recipientType2, corresSett.From__c, FALSE, caseObj.Id, caseobj.OwnerId, new List<String>{});
        //SYN_EmailUtility.sendEmail(caseObj, corresSett.Template_Name__c, recipientType3, corresSett.From__c, FALSE, caseObj.Id, caseobj.Id, new List<String>{});
        //SYN_EmailUtility.getAllCorrespondenceSettings();
        //SYN_EmailUtility.getProgramSpecificCorresSett(caseObj.US_WSREMS__Program_Name__c, tempName);
        
    }*/
}