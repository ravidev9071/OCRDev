/**
* @File Name          : REMSAutomationCommunicationUtility.cls
* @Description        : This is used as a email automation handler for MACI.
* @Trigger            : 
* @TestClass          : REMSAutomationCommunicationUtilityUtilityTest
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date              Developer                         Modification
* 1.0       09/24/2023        Srinivas B(Wilco)     ' Implementation: 
*
**/

Public class REMSAutomationCommunicationUtility {

    Public Static Map<Id,Date> patientAccIdvsDisenrollCaseRecMap;

    /***********************************************************************************
     Method Name: sendNotificationFromFlow() - Params: requestList - This is the list that contains the data like account Id(what Id), 
                                                                     email template dev name, from address, to address & BCC address.
     description: This method will be invoked from the flow: BT7433_Communication_Triggers_Send_Invite_Emails that will send emails on:
                  1. Create of an account.
                  2. Scheduled emails for the same accounts.
     return:      NA.
    ************************************************************************************/
    @InvocableMethod
    public static void sendNotificationFromFlow( List<Requests> requestList){ 
        OrgWideEmailAddress owa = New OrgWideEmailAddress();
        EmailTemplate template = new EmailTemplate();
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = New List<String>();
        toAddresses.add(requestList[0].toAddress);
        List<String> BccAddresses = New List<String>();
        BccAddresses.add(requestList[0].BccAddress);
        Contact con = getContact();
        template = [Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate WHERE DeveloperName =: requestList[0].templateName];
        
        String contactIdLabel = System.Label.ContactIdLabel;
        if(!Test.isRunningTest()){
            owa = [select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: requestList[0].fromAddress];
         }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setBccAddresses(BccAddresses);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(true);
        mail.setWhatId(requestList[0].accountId);
        mail.setTemplateId(template.Id);
        if(con!=null)
        mail.setTargetObjectId(ContactIdLabel);
        mail.setTreatTargetObjectAsRecipient(false);
        if(owa != null){
            mail.setOrgWideEmailAddressId(owa.Id);
        }
        
        emailMessageList.add(mail);
        
        if(!emailMessageList.isEmpty()){
            triggerEmailsToRecipients(emailMessageList);
        }
        
        
        
    }
    
    public static void sendESignatureEmail( List<Requests> requestList){ 
        OrgWideEmailAddress owa = New OrgWideEmailAddress();
        EmailTemplate template = new EmailTemplate();
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        String contactIdLabel = System.Label.ContactIdLabel; 
        For(Requests emailRequest : requestList){
          List<String> toAddresses = New List<String>();
          List<String> BccAddresses = New List<String>();
          template = [Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate WHERE DeveloperName =: emailRequest.templateName];
          owa = Test.isRunningTest() ? null  : [select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: emailRequest.fromAddress];
          toAddresses.add(emailRequest.toAddress);
          BccAddresses.add(emailRequest.BccAddress);       
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setBccAddresses(BccAddresses);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(true);
            mail.setWhatId(emailRequest.accountId);
            mail.setTemplateId(template.Id);
            mail.setTargetObjectId(ContactIdLabel);
            mail.setTreatTargetObjectAsRecipient(false);
          if(owa != null){
            mail.setOrgWideEmailAddressId(owa.Id);
          }
          emailMessageList.add(mail);
        }
        if(!emailMessageList.isEmpty()){
            triggerEmailsToRecipients(emailMessageList);
        }  
    }

    public static contact getContact(){
        List<Contact> conlst = [SELECT Id FROM Contact];
        if(!conlst.isEmpty()){
            return conlst[0];
        }
        return null;
    } 
    
    /***********************************************************************************
     Method Name: triggerEmailsToRecipients() - Params: theEmailMessages - Singleemail message list that should trigger.
     description: This method is responsible to send the emails from the list formed in the sendNotification()
     return:      NA.
    ************************************************************************************/
    public static void triggerEmailsToRecipients(List<Messaging.SingleEmailMessage> theEmailMessages){
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        Boolean complete = false;
        try {
            results = Messaging.sendEmail(theEmailMessages); 
            complete = true;    
        }catch(Exception exp) {   
                   
        }
        
        if (complete && results[0].isSuccess() != true) {
            List<Messaging.SendEmailError> errors = results[0].getErrors();   
            String errorReport = '';
            for(Messaging.SendEmailError curError : errors) {   
                errorReport = errorReport + curError.getMessage() + '/n';  
            }        
        }
    }
    

    public class Requests {
        @InvocableVariable(label='accountId' description='currentAccountId' required=true)
        public Id accountId;
        @InvocableVariable(label='templateName' description='Template ID' required=true)
        public String templateName;
        @InvocableVariable(label='toAddress' description='toAddress' required=true)
        public string toAddress;
        @InvocableVariable(label='BccAddress' description='yourDescription' required=true)
        public String BccAddress;
        @InvocableVariable(label='fromAddress' description='yourDescription' required=false)
        public String fromAddress;
        
    }

public Static Map<String,US_WSREMS__REMS_CorrespondenceSettings__mdt> programTemplates;

  public static void sendNotification(List<Case> caseList, Set<String> programNames,String referenceField){
    
      List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        //Get the correspondence metadata recs to the emailTemplateMap...
        Map<String,String> emailTemplateMap = getEmailTemplateName(programNames,referenceField);
        //Get the Map of template devname vs Id from getEmailTemplateIds()...
        Map<String,String> emailTemplateIdMap = getEmailTemplateIds(emailTemplateMap);
          for(case cs : caseList){
            String refFieldValue = String.valueOf(cs.get(referenceField));
            String key = cs.US_WSREMS__Service_Requestor_Type__c+'$$'+cs.US_WSREMS__Program_Name__c+'$$'+cs.US_WSREMS__Record_Type_Name__c+'$$'+cs.Status+'$$'+referenceField+'$$'+refFieldValue;
            if(cs.US_WSREMS__REMS_Service_Summary__c!= null && cs.US_WSREMS__Service_Requestor_Type__c != null && 
                programTemplates.containsKey(key)){
                 String templateName = programTemplates.get(key).US_WSREMS__Template_Name__c;
                   // Get the To Address
                  List<String> toAddresses = new List<String>();
                   String toaddress = '';
                   String toaddressValue = '';
                   String relationshipField = '';
                   if(programTemplates.get(key)!=null && programTemplates.get(key).US_WSREMS__Recipient_Email_Field__c!=null){
                     toaddress = programTemplates.get(key).US_WSREMS__Recipient_Email_Field__c;
                       toaddressValue = (String) cs.get(toaddress);
                       toAddresses.add(toaddressValue);
                    if(programTemplates.get(key)!=null && programTemplates.get(key).US_WSREMS__BCC_Email__c!=null){
                        // Get the Bcc Address
                   List<String> BccAddress = programTemplates.get(key).US_WSREMS__BCC_Email__c.Split(',');                   
                   // Get the FROM Address 
                   String fromAddress = programTemplates.get(key).US_WSREMS__From__c;
                   if(fromAddress != null && BccAddress != null){
                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                   mail.setToAddresses(toAddresses);
                   mail.setBccAddresses(BccAddress);
                   mail.setBccSender(false);
                   mail.setUseSignature(false);
                   mail.setSaveAsActivity(true);
                   mail.setWhatId(cs.Id);
                   if(emailTemplateIdMap.containsKey(templateName)){
                       mail.setTemplateId(emailTemplateIdMap.get(templateName));
                   }
                   //if(con!=null)
                   mail.setTreatTargetObjectAsRecipient(false);
                   mail.setOrgWideEmailAddressId(fromAddress);
                   mail.setTargetObjectId(cs.US_WSREMS__ContactId__c);
 					
                   mail.setWhatId(cs.Id);
                   emailMessageList.add(mail);
                }
                    }
            }
                }
        }
        if(!emailMessageList.isEmpty()){
            triggerEmailsToRecipients(emailMessageList);
        }
    }


     // Get email template with requestor type from custom Metadata 
    public static Map<String,String> getEmailTemplateName(Set<String> progamName, string refField){
        programTemplates = new Map<String,US_WSREMS__REMS_CorrespondenceSettings__mdt>();
        Map<String,String> templateMap = new Map<String,String>();
        
        for(US_WSREMS__REMS_CorrespondenceSettings__mdt crsd : [SELECT Id, DeveloperName, MasterLabel, US_WSREMS__Active__c, US_WSREMS__From__c, US_WSREMS__Object_Name__c,
                                                      US_WSREMS__Program_Configuration__c,US_WSREMS__Program_Configuration__r.MasterLabel, US_WSREMS__Recipient_Email_Field__c, 
                                                      US_WSREMS__Recipient_Type__c, US_WSREMS__Template_Name__c, US_WSREMS__Type__c,US_WSREMS__Record_Type_Developer_Name__c,US_WSREMS__BCC_Email__c,US_WSREMS__Relationship_Field__c,
                                                      US_WSREMS__Case_Status__c,US_WSREMS__Reference_Field__c,US_WSREMS__Reference_Field_Value__c FROM US_WSREMS__REMS_CorrespondenceSettings__mdt 
                                                      WHERE US_WSREMS__Active__c = TRUE AND US_WSREMS__Program_Configuration__r.MasterLabel = : progamName AND US_WSREMS__Reference_Field__c=:refField]){
                                                          
                                                          templateMap.put(crsd.US_WSREMS__Template_Name__c,crsd.US_WSREMS__Recipient_Type__c);
                                                          programTemplates.put(crsd.US_WSREMS__Recipient_Type__c+'$$'+crsd.US_WSREMS__Program_Configuration__r.MasterLabel+'$$'+crsd.US_WSREMS__Record_Type_Developer_Name__c+'$$'+crsd.US_WSREMS__Case_Status__c+'$$'+crsd.US_WSREMS__Reference_Field__c+'$$'+crsd.US_WSREMS__Reference_Field_Value__c,crsd);
                                                          
                                                      } 
        
        return templateMap;
    }

    // get email template based on before map
    public static Map<String,String> getEmailTemplateIds(Map<String,String> templateMap){
        Map<String,String> templateIdMap = new Map<String,String>();
        for(EmailTemplate temp :[Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate where DeveloperName =: templateMap.keySet()]){
            templateIdMap.put(temp.DeveloperName,temp.Id);
        }
        return templateIdMap;
    }
}