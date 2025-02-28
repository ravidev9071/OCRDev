/**
 * @description       : Batch class to send one time email blast for the migrated records.
 * @author            : Utthirakumar
 * @group             : 
 * @last modified on  : 10-10-2024
 * @last modified by  : Utthirakumar
**/

public class RemsBatchToSendBlastEmails implements Database.Batchable<sObject> {   

    /**
     Wrapper class instance which receives the input request params while invoke.
    */
    private RequestInputWrapper requestInputParams;

    /**
     Contructor method which assigns the received input request params into the local variable.
    */
    public RemsBatchToSendBlastEmails(RequestInputWrapper requestParams){
        this.requestInputParams = requestParams;
    }
   
    /**
     This method retrives the records based on the query string which passed via the input request param.
    */
    public Database.QueryLocator start(Database.BatchableContext BC)
    {   //Pick up all the attachments in Status New from Document Mapping. 
        return Database.getQueryLocator(this.requestInputParams.queryString);
    }
   
    /**
     This method processes the records which got queried based on the query string passed and processes it to send the emails.
     Processed records will be updated only if the updateRecord input param set as True.
     toAddressField in the input param allows to dynamically fetch the email address from the sobject which is processed.
    */
    public void execute(Database.BatchableContext BC, List<Account> scope)
    {
       List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
       List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
       List<Account> accountListToUpdate = new List<Account>();
       if( String.isBlank(this.requestInputParams.orgEmailId) && !String.isBlank(this.requestInputParams.orgEmailAddress) ){
            List<OrgWideEmailAddress> owa = [select Id from OrgWideEmailAddress WHERE Address =: this.requestInputParams.orgEmailAddress ];
            if( owa != NULL && owa.size() > 0 ){
                this.requestInputParams.orgEmailId = owa[0].Id;
            }
       }

       if( String.isBlank(this.requestInputParams.templateId) && !String.isBlank(this.requestInputParams.templateName) ){
            List<EmailTemplate> emailTemplate = [Select Id from EmailTemplate WHERE DeveloperName =: this.requestInputParams.templateName];
            if( emailTemplate != NULL && emailTemplate.size() > 0 ){
                this.requestInputParams.templateId = emailTemplate[0].Id;
            }
       }

       if(this.requestInputParams.objectName == 'Account'){
            for(Account acc : scope){
                String toAddress;
                if(!String.isBlank((String) acc.get(this.requestInputParams.toAddressField))){
                    toAddress = (String) acc.get(this.requestInputParams.toAddressField);
                }
                if(toAddress != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] sendingTo = new String[]{toAddress};
                    mail.setToAddresses(sendingTo);
                    if( !String.isBlank(this.requestInputParams.bccAddress) ){
                        String[] sendingToBccAdd = new String[]{this.requestInputParams.bccAddress};
                        mail.setBccAddresses(sendingToBccAdd );
                    }
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    if( this.requestInputParams.setSaveActivity ){
                        mail.setSaveAsActivity(true);
                    } else{
                        mail.setSaveAsActivity(false);
                    }
                    mail.setWhatId(acc.Id);
                    mail.setTemplateId(this.requestInputParams.templateId);
                    mail.setTargetObjectId(acc.personcontactId);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setOrgWideEmailAddressId(this.requestInputParams.orgEmailId);
                    emailMessageList.add(mail);
                    acc.US_WSREMS__Send_Invitation_Date__c = System.Today();
                    accountListToUpdate.add(acc);
                }
                
            }
        } 
        
        if(!emailMessageList.isEmpty()){
            try {
                results = Messaging.sendEmail(emailMessageList);
                
                if(!accountListToUpdate.isEmpty() && this.requestInputParams.updateRecord ){
                    update accountListToUpdate;
                }
                System.debug(LoggingLevel.INFO, 'Success');
            }catch(Exception exp) {               
                System.debug(LoggingLevel.ERROR, exp.getMessage());  
            }
        }
    }    

    public void finish(Database.BatchableContext BC)
    {   

    }

    /**
     Wrapper class to receive the input request dynamically during invoke.
     * @param queryString pass the query string to fetch records to be processed
     * @param templateId pass the email templateId which needs to be considered for the email send.
     * @param templateName  pass the email templateName instead of templateId to be considered for the email send.
     * @param orgEmailId pass the email address which considered for the email send.
     * @param orgEmailaddress pass the orgwideEmailAddress Id instead of the orgEmailId.
     * @param objectName   pass the objectName which needs to be processed.
     * @param bccAddress pass the bccAddress which needs to be added for the email send.
     * @param toAddressField pass the sobject field related to the object processed to fetch the email address dynamic for the email send.
     * @param setSaveActivity set this value as True if the email needs to be tracked under the sobject record else set this value as false.
     * @param updateRecord set this value as True if you want to update the record which is processed otherwise set this value as false.
    */
    public class RequestInputWrapper {
        public String queryString {get; set;}
        public string templateId {get; set;}
        public string templateName {get; set;}
        public string orgEmailId {get; set;}
        public string orgEmailaddress {get; set;}
        public string objectName {get; set;}
        public string bccAddress {get; set;}
        public string toAddressField {get; set;}
        public boolean setSaveActivity { get; set; }
        public boolean updateRecord { get; set; }
    }
}