global class SYN_BatchToSendInvitationEmails implements Database.Batchable<sObject>
{   
    private String queryString;
    private string templateId;
    private string contactId;
    private string OrgEmailId;
    private string ObjectName; 
    private string inviteFlag;
    private string bccAddress; 

    Public SYN_BatchToSendInvitationEmails(String Query,String templateId,String contactId, string OrgEmailId, string ObjectName, string inviteFlag, string bccAddress){
        this.queryString  = Query;
        this.templateId = templateId;
        this.contactId = contactId;
        this.OrgEmailId = OrgEmailId;
        this.ObjectName = ObjectName;
        this.inviteFlag = inviteFlag;
        this.bccAddress = bccAddress;
    }
   
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   //Pick up all the attachments in Status New from Document Mapping. 
        return Database.getQueryLocator(queryString);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
       List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
       List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();

       List<Account> accountListToUpdate = new List<Account>();
       if(this.ObjectName == 'Account'){
            for(Account acc : scope){
                String toAddress;
                if(acc.RecordType.DeveloperName == 'Prescriber'){
                    toAddress = acc.Email_address__c;
                }else if(acc.RecordType.DeveloperName == 'Pharmacy_Participant'){
                    toAddress = acc.US_WSREMS__Email__c;
                }
               if(toAddress != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] sendingTo = new String[]{toAddress};
                    mail.setToAddresses(sendingTo );
                    if(this.bccAddress != ''){
                        String[] sendingToBccAdd = new String[]{this.bccAddress};
                        mail.setBccAddresses(sendingToBccAdd );
                    }
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    mail.setSaveAsActivity(true);
                    mail.setWhatId(acc.Id);
                    mail.setTemplateId(this.templateId);
                    mail.setTargetObjectId(acc.personcontactId);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setOrgWideEmailAddressId(this.OrgEmailId);
                    if(acc.Invitation_Days__c == null){
                        acc.Invitation_Days__c = this.inviteFlag;
                    }else{
                        acc.Invitation_Days__c = acc.Invitation_Days__c+';'+this.inviteFlag;
                    }
                    
                    accountListToUpdate.add(acc);
                    emailMessageList.add(mail);
                }
            }
        } 
        
        if(this.ObjectName == 'US_WSREMS__Affiliation__c'){
           Set<Id> accountIds = new Set<Id>();
            for(Account acf : scope){
                accountIds.add(acf.Id);
                  if(acf.Invitation_Days__c == null){
                        acf.Invitation_Days__c = this.inviteFlag;
                    }else{
                        acf.Invitation_Days__c = acf.Invitation_Days__c+';'+this.inviteFlag;
                    }
                accountListToUpdate.add(acf);
            }
            Set<Id> accoutnIds = new Set<Id>();
            if(!accountIds.isEmpty()){
                for(US_WSREMS__Affiliation__c aff : [SELECT Id, US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy_User__r.personcontactId,US_WSREMS__Pharmacy_User__r.US_WSREMS__Email__c,US_WSREMS__Pharmacy__c FROM US_WSREMS__Affiliation__c 
                                                                    WHERE US_WSREMS__Pharmacy_User__c != null AND US_WSREMS__Pharmacy__c != null
                                                                    AND US_WSREMS__Pharmacy_User__c IN: accountIds AND US_WSREMS__isActive__c = true 
                                                                    AND US_WSREMS__REMSProgram__r.Name = 'Macitentan REMS']){
                    if(!accoutnIds.contains(aff.US_WSREMS__Pharmacy_User__c)){ 
                        String toAddress;
                        toAddress = aff.US_WSREMS__Pharmacy_User__r.US_WSREMS__Email__c;
                        if(toAddress != null){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            String[] sendingTo = new String[]{toAddress};
                            mail.setToAddresses(sendingTo );
                            if(this.bccAddress != ''){
                                String[] sendingToBccAdd = new String[]{this.bccAddress};
                                mail.setBccAddresses(sendingToBccAdd );
                            }
                            mail.setBccSender(false);
                            mail.setUseSignature(false);
                            mail.setSaveAsActivity(true);
                            mail.setWhatId(aff.Id);
                            mail.setTemplateId(this.templateId);
                            mail.setTargetObjectId(aff.US_WSREMS__Pharmacy_User__r.personcontactId);
                            mail.setTreatTargetObjectAsRecipient(false);
                            mail.setOrgWideEmailAddressId(this.OrgEmailId);
                           
                            emailMessageList.add(mail);
                            accoutnIds.add(aff.US_WSREMS__Pharmacy_User__c);
                        } 
                    }                                               
                }
                                                                    
            }
        }
       
        if(!emailMessageList.isEmpty()){
            try {
                results = Messaging.sendEmail(emailMessageList); 
            }catch(Exception exp) {               
                System.debug('Error---'+exp.getMessage());   
            }
        }
        
        if(!accountListToUpdate.isEmpty()){
            try{
               update accountListToUpdate;
           }catch (exception e){
             System.debug('Error---'+e.getMessage());  
           }
        }
    }    
    global void finish(Database.BatchableContext BC)
    {
    }
}