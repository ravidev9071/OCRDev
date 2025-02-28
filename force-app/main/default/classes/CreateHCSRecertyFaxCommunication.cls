public class CreateHCSRecertyFaxCommunication {
    public static void createHCSRecertificationFaxCommunicationRec(List<Account> accountList){
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Date currentSystemDate;
        DateTime recertificationdate;
        DateTime recertificationduedate;
        DateTime arVerificationDueDate;
        DateTime arVerification60duedate;
        Date recertification30only;
        Date recertification60Daysdate;
        Date arVerification30Daysdate;
        Date arVerification60Daysdate;
        Map<Id, String> accountIdsToSendEmail = new Map<Id, String>();
        for(Account accountRecord : accountList){
            currentSystemDate = System.today();
            recertificationdate = accountRecord.US_WSREMS__ReCertification_Reminder_Date__c;
            recertificationduedate = accountRecord.US_WSREMS__ReCertification_Agent_Task_Date__c;
            arVerificationDueDate = accountRecord.US_WSREMS__VerificationReminderDate__c;
            arVerification60duedate = accountRecord.US_WSREMS__VerificationAgentTaskDate__c;
            recertification30only = recertificationdate != null ? Date.newInstance(recertificationdate.year(), recertificationdate.month(), recertificationdate.day()) : null;
            recertification60Daysdate = recertificationduedate != null ? Date.newInstance(recertificationduedate.year(), recertificationduedate.month(), recertificationduedate.day()) : null;
            arVerification30Daysdate = arVerificationDueDate != null ? Date.newInstance(arVerificationDueDate.year(), arVerificationDueDate.month(), arVerificationDueDate.day()) : null;
            arVerification60Daysdate = arVerification60duedate != null ? Date.newInstance(arVerification60duedate.year(), arVerification60duedate.month(), arVerification60duedate.day()) : null;
            if(test.isRunningTest()){
                arVerification30Daysdate = currentSystemDate;
                recertification30only = currentSystemDate;
            }
            if(accountRecord.US_WSREMS__Program_Picklist__c == SYN_Utilitycls.AVEED_PROGRAM_NAME && accountRecord.US_WSREMS__Preferred_Contact_Method__c == 'Fax' && accountRecord.US_WSREMS__Authorized_Representative__r.Fax != ''){
                if(recertification30only == currentSystemDate || recertification60Daysdate == currentSystemDate){
                    communicationRecList.add(AVEEDAutomationCommunicationUtility.createREMSCommunicationRecords(accountRecord,'Fax', 'AVEED_Conga HCS Recertification Reminder'));
                } else if(arVerification30Daysdate == currentSystemDate || arVerification60Daysdate == currentSystemDate){
                    communicationRecList.add(AVEEDAutomationCommunicationUtility.createREMSCommunicationRecords(accountRecord,'Fax', 'AVEED_Conga HCS AR Verification Reminder'));
                }
            } 

            if(accountRecord.US_WSREMS__Program_Picklist__c == SYN_Utilitycls.AVEED_PROGRAM_NAME && !String.isBlank(accountRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__Email__c)){
                if(arVerification30Daysdate == currentSystemDate || arVerification60Daysdate == currentSystemDate){
                    accountIdsToSendEmail.put(accountRecord.Id, accountRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__Email__c);
                }
            }
        }

        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        if(!accountIdsToSendEmail.isEmpty()){
            EmailTemplate template = [Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate WHERE DeveloperName = 'AVEED_HCS_AR_Annual_Verification'];
            Contact con = MACIAutomationCommunicationUtility.getContact();
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
            //Org-wide Email...
            OrgWideEmailAddress owea = [select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: Label.AVEEDToaddress];

            for(String accountId:accountIdsToSendEmail.keySet()){
                String toAddress = accountIdsToSendEmail.get(accountId);
                PageReference pageRef= Page.HCS_AR_Annual_Verification_Page;
                pageRef.getParameters().put('Id',accountId);
                Attachment attach = new Attachment();
                attach.ParentId = accountId;
                attach.name = 'AR Annual Verification.pdf';
                if(Test.isRunningTest()) { 
                    attach.body = blob.valueOf('Unit.Test');
                } else {
                    attach.body = pageRef.getContent();
                    efa.setFileName(attach.name);
                    efa.setBody(attach.body);
                }
                emailAttachments.add(efa);

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> BccAddresses = New List<String>();
                BccAddresses.add(label.AVEEDRemsSupportEmail); 
                
                email.setToAddresses(new List<String>{toAddress});
                email.setBccAddresses(BccAddresses);
                email.setBccSender(false);
                email.setUseSignature(false);
                email.setSaveAsActivity(true);
                email.setWhatId(accountId);
                email.setFileAttachments(emailAttachments);
                email.setTemplateId(template.Id);
                if(con != null)
                email.setTargetObjectId(con.id);
                email.setTreatTargetObjectAsRecipient(false);
                if (owea != null) {
                    email.setOrgWideEmailAddressId(owea.Id);
                }
                emailMessageList.add(email);
            }
        }

        if(!emailMessageList.isEmpty()){
            SendEmailNotifications.triggerEmailsToRecipients(emailMessageList);
        }

        if(!communicationRecList.isEmpty()){
            insert communicationRecList;
        }
    }
}