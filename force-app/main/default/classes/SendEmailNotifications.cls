public without sharing class SendEmailNotifications {
    Public Static Map<String,REMS_Correspondence_Settings__mdt> programTemplates;
    Public static String suspectedNoncomplianceActivity = REMSAppLiterals.Suspected_Non_compliance_activity;
    Public static String complianceInvestigation = REMSAppLiterals.Compliance_Investigation;
    Public static String confirmedNoncomplianceActivity = REMSAppLiterals.Confirmed_Non_compliance_activity;
    Public static String complete = REMSAppLiterals.CASE_OUTCOME;
    
    public static void getNotificationPiasky(List<Case> caseList, String programName){
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        //Get the correspondence metadata recs to the emailTemplateMap...
        //Get the Map of template devname vs Id from getEmailTemplateIds()...
      
        
        Map<String,String> emailTemplateMap = getEmailTemplateNameAll(programName);
        //Get the Map of template devname vs Id from getEmailTemplateIds()...
        Map<String,String> emailTemplateIdMap = getEmailTemplateIdsAll(emailTemplateMap);
        //get a dummy contact from the database for targetObjID...
        Contact con = getContact();

        OrgWideEmailAddress[] owea =[select Id,Address from OrgWideEmailAddress where Address ='piaskyrems@remshelp.com'];
        for(case cs : caseList){

            if(cs.US_WSREMS__REMS_Service_Summary__c != null && cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c != null 
               && programTemplates.containsKey(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email') ){
                   // Template Name
                   String templateName = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email').Template_Name__c;
                   // Get the To Address
                  List<String> toAddresses = new List<String>();
                   String toaddress = '';
                   String toaddressValue = '';
                   String relationshipField = '';
                   
                   //To address will be picked from case if the emails are missing info emails...
                   //Else... they will be picked from the account.
                   if(cs.US_WSREMS__Incomplete_Reasons__c != null && cs.Status == 'Draft'){
                    toaddress = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email').Recipient_Email_Field__c;
                    toaddressValue = (String) cs.get(toaddress);
                    toAddresses.add(toaddressValue);
                }
                if(cs.US_WSREMS__Incomplete_Reasons__c == null && cs.Status == 'Complete'){
                    relationshipField = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email').Relationship_Field__c;
                    toaddress = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email').Recipient_Email_Field__c;
                    toaddressValue = (String) cs.getSobject(relationshipField).get(toaddress);
                    toAddresses.add(toaddressValue);
                       
                } 
                       
                   
                // Get the Bcc Address
                List<String> BccAddress = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email').BCC_Email__c.Split(',');                   
                   // Get the FROM Address 
                   String fromAddress = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email').From__c;
               
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setSaveAsActivity(true);
                mail.setWhatId(cs.Id);
                if(emailTemplateIdMap.containsKey(templateName)){
                    mail.setTemplateId(emailTemplateIdMap.get(templateName));
                }
                if(con!=null)
                mail.setTargetObjectId(con.id);
                mail.setTreatTargetObjectAsRecipient(false);
                if ( owea.size() > 0 ) {
             mail.setOrgWideEmailAddressId(owea.get(0).Id);
                 }
                emailMessageList.add(mail);      
               } //End of If...
        }
        
        if(!emailMessageList.isEmpty()){
            triggerEmailsToRecipients(emailMessageList);
        }
        
    }

    public static Messaging.SingleEmailMessage sendNotification(List<String> toAddresses, String templateId, List<String> bccAddress, Id whatIdVal, String oweaId, Id contactId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setBccAddresses(bccAddress);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(true);
        mail.setWhatId(whatIdVal);
        mail.setTemplateId(templateId);
        mail.setTargetObjectId(contactId);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setOrgWideEmailAddressId(oweaId);

        return mail;
    }
    
    public static void triggerEmailsToRecipients(List<Messaging.SingleEmailMessage> theEmailMessages){
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        Boolean complete = false;
        try {
            results = Messaging.sendEmail(theEmailMessages); 
            complete = true;    
        }catch(Exception exp) {   
              system.debug('----send email error-----'+exp.getMessage());          
        }
        
        if (complete && results[0].isSuccess() != true) {
            List<Messaging.SendEmailError> errors = results[0].getErrors();   
            String errorReport = '';
            for(Messaging.SendEmailError curError : errors) {   
                errorReport = errorReport + curError.getMessage() + '/n';  
            }        
        }
    }
    public static contact getContact(){
        List<Contact> conlst = [SELECT Id FROM Contact WHERE FirstName ='TestEmailTemplate-DoNotDelete' LIMIT 1];
        if(!conlst.isEmpty()){
            return conlst[0];
        }
        return null;
    }
    
    public Static Map<String,String> getAllEmailTemplateIds(String programName){
        
        Map<String,String> templateIdMap = new Map<String,String>();
        List<String> templateIdFromMeta = new List<String>();

        for(REMS_Correspondence_Settings__mdt crsd : [SELECT Id, DeveloperName, MasterLabel, Active__c, Conga_Attachment_Template__c, From__c, Object_Name__c,
                                                      Product__c, Program_Configuration__c,Program_Configuration__r.MasterLabel, Recipient_Email_Field__c, 
                                                      Recipient_Type__c, Template_Name__c, Type__c,Record_Type_Developer_Name__c,BCC_Email__c,Relationship_Field__c,
                                                      Case_Status__c,Service_Status__c FROM REMS_Correspondence_Settings__mdt 
                                                      WHERE Active__c = TRUE  AND Program_Configuration__r.MasterLabel =: programName]){

                                templateIdFromMeta.add(crsd.Template_Name__c); 
                              
                            programTemplates.put(crsd.Recipient_Type__c+''+crsd.Program_Configuration__r.MasterLabel+''+crsd.Record_Type_Developer_Name__c+''+crsd.Case_Status__c+''+crsd.Service_Status__c+''+crsd.Type__c,crsd);
                            
                                                      }

        for(EmailTemplate temp :[Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate where DeveloperName =: templateIdFromMeta]){
            templateIdMap.put(temp.DeveloperName,temp.Id);
        }
        return templateIdMap;
    }
    
    public static Map<String,String> getEmailTemplateNameAll(String progName){
        programTemplates = new Map<String,REMS_Correspondence_Settings__mdt>();
        Map<String,String> templateMap = new Map<String,String>();
        
        for(REMS_Correspondence_Settings__mdt crsd : [SELECT Id, DeveloperName, MasterLabel, Active__c, Conga_Attachment_Template__c, From__c, Object_Name__c,
                                                      Product__c, Program_Configuration__c,Program_Configuration__r.MasterLabel, Recipient_Email_Field__c, 
                                                      Recipient_Type__c, Template_Name__c, Type__c,Record_Type_Developer_Name__c,BCC_Email__c,Relationship_Field__c,
                                                      Case_Status__c,Service_Status__c FROM REMS_Correspondence_Settings__mdt 
                                                      WHERE Active__c = TRUE  AND Program_Configuration__r.MasterLabel = :progName]){
                                                          
                                                      templateMap.put(crsd.Template_Name__c,crsd.Recipient_Type__c);
                  programTemplates.put(crsd.Recipient_Type__c+''+crsd.Program_Configuration__r.MasterLabel+''+crsd.Record_Type_Developer_Name__c+''+crsd.Case_Status__c+''+crsd.Service_Status__c+''+crsd.Type__c,crsd);
                                                                                             
                                                      }        
        return templateMap;
    }
    
    // get email template based on before map
    Public Static Map<String,String> getEmailTemplateIdsAll(Map<String,String> templateMap){
        Map<String,String> templateIdMap = new Map<String,String>();
        for(EmailTemplate temp :[Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate where DeveloperName =: templateMap.keySet()]){
            templateIdMap.put(temp.DeveloperName,temp.Id);
        }
        return templateIdMap;
    }

    //Added By Rajeev for TRYVIO REMS Correspondence Template on 7th June 2024
   // @future(Callout=true)
   public static void sendEmailForPAEPCReportableFormEventTRYVIO(Set<Id> caseIds){
        
        List<Attachment> attachList = New List<Attachment>();
        List<Case> updateCaseList = New List<Case>();
        Map<Id,Id> caseIdmap = new Map<Id,Id>();
        Map<Id,Attachment> caseIdVSvfattachmentIdmap = new Map<Id,Attachment>();
        List<String> toAddresses = new List<String>();

        for(Case cse : [Select Id, US_WSREMS__Type_s_of_Report__c From Case Where Id IN: caseIds]){
            if(!String.isEmpty(cse.US_WSREMS__Type_s_of_Report__c)){
                if(cse.US_WSREMS__Type_s_of_Report__c.contains('Potential Adverse Event')){
                    toAddresses.add(System.Label.PAEPCEmailRecipientsTRYVIO);
                }
                if(cse.US_WSREMS__Type_s_of_Report__c.contains('Product Quality Complaing')){
                    toAddresses.add(System.Label.PQCEmailAddressTryvio);
                }
                if(cse.US_WSREMS__Type_s_of_Report__c.contains('Medical Information Request')){
                    toAddresses.add(System.Label.MIREmailAddressTryvio);
                }
            }
        }
        
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        //Template,,
        EmailTemplate template = new EmailTemplate();
        if(!Test.isRunningTest()){
         template = [Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate WHERE DeveloperName = 'Tryvio_PAE_PQC_MIR_Notification'];
        }else{
            template = [Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate limit 1];
        }
    
        //BCC address...
        List<String> BccAddresses = New List<String>();
        BccAddresses.add(label.TRYVIORemsSupportEmail); 
        //contact for targetObjId...
        Contact con = MACIAutomationCommunicationUtility.getContact();
        //Org-wide Email...
        OrgWideEmailAddress owa = New OrgWideEmailAddress();
        if(!Test.isRunningTest()){
        owa = [select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: Label.TRYVIOToAddress];
        }else{
            owa = [select id, Address, DisplayName from OrgWideEmailAddress WHERE IsVerified = true limit 1];
        }
        List<string> emailAttachmentIDs = New List<string>();
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        
        if(caseIds.size() > 0){
            for(String csId:caseIds){
                
                PageReference pageRef= Page.TRYVIO_Reportable_Form;
                pageRef.getParameters().put('Id',csId);
                Attachment attach = new Attachment();
                attach.ParentId = csId;
                attach.name = 'Reportable Event form.pdf';
                if(Test.isRunningTest()) { 
                    attach.body = blob.valueOf('Unit.Test');
                } else {
                    attach.body = pageRef.getContent();
                    efa.setFileName(attach.name);
                    efa.setBody(attach.body);
                }
                attachList.add(attach);
            }
        }
        try{
            
            //Code start to get the uploaded files and add to the emailattachmentids set...
            set<Id> contentDocumentIds = New Set<Id>();
            Map<Id,Case> serviceIdvsCaseRecord = new Map<Id,Case>();
            List<ContentDocumentLink> contentDocumentLinkList = New List<ContentDocumentLink>();
            List<ContentVersion> cvsList = New List<ContentVersion>();
            List<Case> existingCaseRecord = [SELECT Id,US_WSREMS__REMS_Service_Summary__c FROM Case WHERE US_WSREMS__REMS_Service_Summary__c != null AND Id IN:caseIds ];
            //Collect rems service from existing case Ids...
            if(existingCaseRecord.size()>0){
                for(Case cs:existingCaseRecord){
                serviceIdvsCaseRecord.put(cs.Id,cs);
                } 
            }
            //query contentdocumentLink records to get content document from the above collected rems service record...
            if(serviceIdvsCaseRecord != null){
                contentDocumentLinkList = [SELECT Id,ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:serviceIdvsCaseRecord.keyset() ];
            }
            //loop of above contentdocList to collect the contentdocument Ids into a set...
            if(contentDocumentLinkList.size()>0){
                for(contentDocumentLink cd:contentDocumentLinkList){
                    contentDocumentIds.add(cd.ContentDocumentId);
                }
            }
            //query to get contentversion records...
            if(contentDocumentIds.size()>0){
                cvsList = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
            }
            
            //Code end to get the uploaded files and add to the emailattachmentids set...
        
                for(Case cs:existingCaseRecord){
                            //Add contentVersionIds to email attachmentIds List...
                            if(cvsList.size()>0){
                                for(contentDocumentLink cl :contentDocumentLinkList){
                                    for(ContentVersion cv:cvsList){
                                    if(cs.Id == cl.LinkedEntityId && cl.ContentDocumentId == cv.ContentDocumentId){
                                            emailAttachmentIDs.add(cv.Id);   //collect ContentVersion Ids....
                                        }
                                    }
                                }
                            }
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setToAddresses(toAddresses);
                            mail.setBccAddresses(BccAddresses);
                            mail.setBccSender(false);
                            mail.setUseSignature(false);
                            mail.setSaveAsActivity(true);
                            mail.setWhatId(cs.Id);
                            mail.setTemplateId(template.Id);
                            if(con!=null)
                                mail.setTargetObjectId(con.id);
                            mail.setTreatTargetObjectAsRecipient(false);
                            mail.setOrgWideEmailAddressId(owa.Id);
                        if(emailAttachmentIDs != null)
                            mail.setEntityAttachments(emailAttachmentIDs);
                            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                            emailMessageList.add(mail);
                        }
            
            try{
                if(emailMessageList != null){
                    MACIAutomationCommunicationUtility.triggerEmailsToRecipients(emailMessageList);
                }
            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            } 
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }  
    }
    
    //TRYVIO REMS Correspondence Template -- Rajeev 7th June 2024
 
    public static void sendAveedAccountDeactivationNotificationFromAccount(List<Account> accountList, Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap){
        List<String> toAddresses = new List<String>();
        String toaddress = '';
        String toaddressValue = '';
        String templateName;
        List<String> BccAddresses = New List<String>();
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        Map<String, EmailTemplate> emailtemplateMap = getEmailTemplateMap();
        US_WSREMS__Affiliation__c affiliationRecord;
        Contact contactRecord = getContact();
        Map<String, Id> orgWideAddressMap = getOrgWideAddresses();

        for(Account accountRecord: accountList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            //Prescribing HCP Program Opt-Out Confirmation - prescriber
            if(accountRecord.US_WSREMS__Status__c == 'Deactivated' && accountRecord.US_WSREMS__Sub_Status__c == 'Opt-Out'
                && accountRecord.recordTypeId == AVEEDAutomationCommunicationUtility.prescriberRecordType
            ) {
                toaddress = accountRecord.PersonEmail;
                if(toaddress != ''){
                    toAddresses.add(toaddress);
                    templateName = 'AveedHCPProgOptOutConf_Email';    
                    email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDRemsSupportEmail), accountRecord, toAddresses, templateName, emailtemplateMap);
                    emailMessageList.add(email);
                }
            } else if(accountRecord.US_WSREMS__Status__c == 'Deactivated' && accountRecord.US_WSREMS__Sub_Status__c == 'Opt-Out'
                && accountRecord.recordTypeId == AVEEDAutomationCommunicationUtility.hcsRecordType
            ) {
                //Aveed Healthcare Setting Program Opt-Out Confirmation - sent to Auth Rep
                affiliationRecord = accountIdToaffiliationMap.get(accountRecord.Id);
                if(affiliationRecord.US_WSREMS__Authorized_Representative__c != null && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != ''
                    && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != null
                ){
                    toaddress = affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail;
                }

                if(toaddress != ''){
                    toAddresses.add(toaddress);
                    templateName = 'AveedHCS_ProgramOptOutConfirm';
                    email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDRemsSupportEmail), accountRecord, toAddresses, templateName, emailtemplateMap);
                    String aveedHtmlBody = emailtemplateMap.get(templateName).markup;
                    String body = prepareBodyForAffiliationHCSTemplates(affiliationRecord, accountRecord, aveedHtmlBody);
                    aveedHtmlBody = body;
                    email.setHtmlBody(aveedHtmlBody);
                    email.setSubject(emailtemplateMap.get(templateName).Subject);
                    emailMessageList.add(email);
                }
            } else if(accountRecord.US_WSREMS__Status__c == 'Decertified' && accountRecord.US_WSREMS__Sub_Status__c == 'AR Not Confirmed'
                && accountRecord.recordTypeId == AVEEDAutomationCommunicationUtility.hcsRecordType
            ) {
                // Aveed Healthcare Setting Deactivation Notification – AR Not Confirmed - sent to auth rep
                affiliationRecord = accountIdToaffiliationMap.get(accountRecord.Id);
                if(affiliationRecord.US_WSREMS__Authorized_Representative__c != null && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != ''
                    && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != null
                ){
                    toaddress = affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail;
                }
                if(toaddress != ''){
                    toAddresses.add(toaddress);
                    templateName = 'Aveed_HCS_Deact_Notify_AR_Not_Confirmed';
                    email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDRemsSupportEmail), accountRecord, toAddresses, templateName, emailtemplateMap);
                    String aveedHtmlBody = emailtemplateMap.get(templateName).markup;
                    String body = prepareBodyForAffiliationHCSTemplates(affiliationRecord, accountRecord, aveedHtmlBody);
                    aveedHtmlBody = body;
                    email.setHtmlBody(aveedHtmlBody);
                    email.setSubject(emailtemplateMap.get(templateName).Subject);
                    emailMessageList.add(email);
                }
                } else if(accountRecord.US_WSREMS__Status__c == 'Decertified' && accountRecord.US_WSREMS__Sub_Status__c == 'Failure to recertify'
                && accountRecord.recordTypeId == AVEEDAutomationCommunicationUtility.hcsRecordType
            ) {
                // Aveed Healthcare Setting Deactivation Notification – AR Not Confirmed - sent to auth rep
                affiliationRecord = accountIdToaffiliationMap.get(accountRecord.Id);
                if(affiliationRecord.US_WSREMS__Authorized_Representative__c != null && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != ''
                    && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != null
                ){
                    toaddress = affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail;
                }
                if(toaddress != ''){
                    toAddresses.add(toaddress);
                    templateName = 'AVEED_HCS_Enrollment_Deactivation_Notice';
                    email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDRemsSupportEmail), accountRecord, toAddresses, templateName, emailtemplateMap);
                    String aveedHtmlBody = emailtemplateMap.get(templateName).markup;
                    String body = prepareBodyForAffiliationHCSTemplates(affiliationRecord, accountRecord, aveedHtmlBody);
                    aveedHtmlBody = body;
                    email.setHtmlBody(aveedHtmlBody);
                    email.setSubject(emailtemplateMap.get(templateName).Subject);
                    emailMessageList.add(email);
                }
            }
        }

        if(!emailMessageList.isEmpty()){
            triggerEmailsToRecipients(emailMessageList);
        }
    }

    public static void sendAveedAccountDeactivationNotificationForNonCompliance(List<Case> caseList, Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap){

        List<String> toAddresses = new List<String>();
        String toaddress = '';
        String toaddressValue = '';
        String templateName;
        List<String> BccAddresses = New List<String>();
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        Map<Id, Case> accounIdToHCSEnrollementCaseMap = new Map<Id, Case>();
        Map<String, EmailTemplate> emailtemplateMap = getEmailTemplateMap();
        US_WSREMS__Affiliation__c affiliationRecord;
        Contact contactRecord = getContact();
        Map<String, Id> orgWideAddressMap = getOrgWideAddresses();

        for(Case caseRecord: caseList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            //Prescribing HCP Program Opt-Out Confirmation - prescriber
            if(caseRecord.RecordTypeId == AVEEDAutomationCommunicationUtility.nonComplianceRecordType && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Status__c == 'Decertified'
            ) {
                if(caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == AVEEDAutomationCommunicationUtility.prescriberRecordType && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Sub_Status__c == 'Program Noncompliant'){
                    toaddress = caseRecord.US_WSREMS__X1_Participant__r.PersonEmail;
                    if(toaddress == '' || toaddress == null){
                        toaddress = caseRecord.US_WSREMS__Participant_Email__c;
                    }
                    if(toaddress != ''){
                        toAddresses.add(toaddress);
                        // non-complaince deactivation template for HCP===
                        templateName = 'Aveed_HCP_or_HCS_Noncompliance_Deact';
                        email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDToaddress), caseRecord, toAddresses, templateName, emailtemplateMap);
                        String aveedHtmlBody = emailtemplateMap.get(templateName).markup;
                        aveedHtmlBody = aveedHtmlBody.replace('{{PRESCRIBER_NAME}}', (caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__First_And_Last_Name__c != null ? caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__First_And_Last_Name__c : ''));
                        aveedHtmlBody = aveedHtmlBody.replace('{{REMS_DESCRIPTION}}', caseRecord.US_WSREMS__Description__c != null ? caseRecord.US_WSREMS__Description__c : '');
                        email.setHtmlBody(aveedHtmlBody);
                        email.setSubject(emailtemplateMap.get(templateName).Subject);
                        emailMessageList.add(email);
                    }
                } else if(caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == AVEEDAutomationCommunicationUtility.hcsRecordType && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Sub_Status__c == 'Program Noncompliant'){
                    affiliationRecord = accountIdToaffiliationMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c) ? accountIdToaffiliationMap.get(caseRecord.US_WSREMS__X1_Participant__c) : null;
                    if(affiliationRecord != null){
                        toaddress = affiliationRecord.US_WSREMS__Authorized_Representative__c != null && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != null ? affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail : null;
                    }

                    if(toaddress != ''){
                        toAddresses.add(toaddress);
                        // non-complaince deactivation template for HCS===
                        templateName = 'Aveed_HCP_or_HCS_Noncompliance_Deact';
                        email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDToaddress), caseRecord, toAddresses, templateName, emailtemplateMap);
                        String aveedHtmlBody = emailtemplateMap.get(templateName).markup;
                        aveedHtmlBody = aveedHtmlBody.replace('{{PRESCRIBER_NAME}}', (affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c != null ? affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c : ''));
                        aveedHtmlBody = aveedHtmlBody.replace('{{REMS_DESCRIPTION}}', caseRecord.US_WSREMS__Description__c != null ? caseRecord.US_WSREMS__Description__c : '');
                        email.setHtmlBody(aveedHtmlBody);
                        email.setSubject(emailtemplateMap.get(templateName).Subject);
                        emailMessageList.add(email);
                    }
                }
            }
        }

        if(!emailMessageList.isEmpty()){
            triggerEmailsToRecipients(emailMessageList);
        }
    }


    public static void sendAveedCaseNotificationAsync(List<Case> triggeredCaseList){
        List<Case> caseList = AutomationCommunicationFromCase.getCasesByProgramAndCaseIds(new Map<Id, Case>(triggeredCaseList).keySet(), 'AVEED REMS');

        Id casePrescriberRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        Id caseHCSRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
        Id prescriberRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        Id hcsRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');
        Id nonComplianceRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        Id hcsReEnrollmentRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Reenrollment');
        Id changeAuthRepRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Change_Authorized_Representative');
       
        Map<String, EmailTemplate> emailtemplateMap = getEmailTemplateMap();
        List<String> toAddresses = new List<String>();
        String toaddress = '';
        String toaddressValue = '';
        String templateName;
        List<String> BccAddresses = New List<String>();
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        Map<Id, Case> accounIdToHCSEnrollementCaseMap = new Map<Id, Case>();
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRecord;

        Contact contactRecord = getContact();
        Map<String, Id> orgWideAddressMap = getOrgWideAddresses();
        //Org-wide Email..

        Set<Id> nonComplainceAuthRepIds = new Set<Id>();
        for(case caseRecord : caseList) {
            if(caseRecord.RecordTypeId == nonComplianceRecordType && caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == hcsRecordType) {
                nonComplainceAuthRepIds.add(caseRecord.US_WSREMS__X1_Participant__c);
            }
        }

        if(!nonComplainceAuthRepIds.isEmpty()){
            for(US_WSREMS__Affiliation__c affiliationRec : AutomationCommunicationFromCase.getAffiliationsRecordsByHcsAccountIds(nonComplainceAuthRepIds)){
                if(!accountIdToaffiliationMap.containsKey(affiliationRec.US_WSREMS__Health_Care_Setting__c)){
                    accountIdToaffiliationMap.put(affiliationRec.US_WSREMS__Health_Care_Setting__c, affiliationRec);
                }
            }
        }


        for(Case caseRecord: caseList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(caseRecord.RecordTypeId == nonComplianceRecordType
            ) {
                if(caseRecord.RecordTypeId == nonComplianceRecordType && caseRecord.Status == 'Compliance Investigation'
                    && caseRecord.US_WSREMS__Outcome__c == 'Confirmed Non-compliance activity'
                ) {
                    if(caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == prescriberRecordType){
                        toaddress = caseRecord.US_WSREMS__X1_Participant__r.PersonEmail;
                        if(toaddress == '' || toaddress == null){
                            toaddress = caseRecord.US_WSREMS__Participant_Email__c;
                        }
                        if(toaddress != ''){
                            toAddresses.add(toaddress);
                            // HCP non-complaince Warning template===
                            templateName = 'Aveed_HCP_Non_Compliance_Warning';
                            email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDToaddress), caseRecord, toAddresses, templateName, emailtemplateMap);
                            emailMessageList.add(email);                             
                        }
                    } else if(caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == hcsRecordType){
                        affiliationRecord = accountIdToaffiliationMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c) ? accountIdToaffiliationMap.get(caseRecord.US_WSREMS__X1_Participant__c) : null;
                        if(affiliationRecord != null){
                            toaddress = affiliationRecord.US_WSREMS__Authorized_Representative__c != null && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != null ? affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail : null;
                        }

                        if(toaddress != ''){
                            toAddresses.add(toaddress);
                            // HCS non-complaince Warning template===
                            templateName = 'Aveed_HCS_Non_Compliance_Warning';
                            email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDToaddress), caseRecord, toAddresses, templateName, emailtemplateMap);
                            String aveedHtmlBody = emailtemplateMap.get(templateName).markup;
                            aveedHtmlBody = aveedHtmlBody.replace('{{PRESCRIBER_NAME}}', (affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c != null ? affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c : ''));
                            aveedHtmlBody = aveedHtmlBody.replace('{{REMS_DESCRIPTION}}', caseRecord.US_WSREMS__Description__c != null ? caseRecord.US_WSREMS__Description__c : '');
                            email.setHtmlBody(aveedHtmlBody);
                            email.setSubject(emailtemplateMap.get(templateName).Subject);
                            emailMessageList.add(email);
                        }
                    }
                } else if(caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == prescriberRecordType){
                    toaddress = caseRecord.US_WSREMS__X1_Participant__r.PersonEmail;
                    if(toaddress == '' || toaddress == null){
                        toaddress = caseRecord.US_WSREMS__Participant_Email__c;
                    }
                    if(toaddress != ''){
                        toAddresses.add(toaddress);
                        if(caseRecord.US_WSREMS__Outcome__c == 'Suspected Non-compliance activity' && caseRecord.Status == 'Compliance Investigation') {
                            // HCP suspected template===
                            templateName = 'Aveed_HCP_or_HCS_Noncompliance_Sus';
                        } else if(caseRecord.US_WSREMS__Outcome__c == 'Confirmed Non-compliance activity' && caseRecord.Status == 'Complete') {
                            // HCP Confirmed template===
                            templateName = 'Aveed_HCP_or_HCS_Noncompliance_Notice';
                        }
                        if(templateName != null){
                            email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDToaddress), caseRecord, toAddresses, templateName, emailtemplateMap);
                            String aveedHtmlBody = emailtemplateMap.get(templateName).markup;
                            String body = prepareBodyForHCPTemplate(caseRecord, aveedHtmlBody);
                            aveedHtmlBody = body;
                            email.setHtmlBody(aveedHtmlBody);
                            email.setSubject(emailtemplateMap.get(templateName).Subject);
                            emailMessageList.add(email); 
                        }                 
                    }
                } else if(caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == hcsRecordType){
                    affiliationRecord = accountIdToaffiliationMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c) ? accountIdToaffiliationMap.get(caseRecord.US_WSREMS__X1_Participant__c) : null;

                    if(affiliationRecord != null){
                        toaddress = affiliationRecord.US_WSREMS__Authorized_Representative__c != null && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != null ? affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail : null;
                    }

                    if(toaddress != ''){
                        toAddresses.add(toaddress);
                        if(caseRecord.US_WSREMS__Outcome__c == 'Suspected Non-compliance activity' && caseRecord.Status == 'Compliance Investigation') {
                            // HCS suspected template===
                            templateName = 'Aveed_HCP_or_HCS_Noncompliance_Sus';
                        } else if(caseRecord.US_WSREMS__Outcome__c == 'Confirmed Non-compliance activity' && caseRecord.Status == 'Complete') {
                            // HCS Confirmed template===
                            templateName = 'Aveed_HCP_or_HCS_Noncompliance_Notice';
                        }
                        if(templateName != null){
                            email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDToaddress), caseRecord, toAddresses, templateName, emailtemplateMap);
                            String aveedHtmlBody = emailtemplateMap.get(templateName).markup;
                            String body = prepareBodyForHCSTemplates(affiliationRecord, caseRecord, aveedHtmlBody);
                            aveedHtmlBody = body;
                            email.setHtmlBody(aveedHtmlBody);
                            email.setSubject(emailtemplateMap.get(templateName).Subject);
                            emailMessageList.add(email); 
                        }                   
                    }
                } 
            } else if(caseRecord.RecordTypeId == hcsReEnrollmentRecordType && caseRecord.Status == 'Complete' && caseRecord.US_WSREMS__Incomplete_Reasons__c == null){
                toaddress = caseRecord.US_WSREMS__REMS_Authorized_Rep__r.PersonEmail;
                if(toaddress == '' || toaddress == null){
                    toaddress = caseRecord.US_WSREMS__Email_ar__c;
                }
                if(toaddress != ''){
                    toAddresses.add(toaddress);
                    // Aveed Healthcare Setting Re-Enrollment Confirmation
                    templateName = 'Aveed_HCS_Re_Enrollment_Confirmation';
                    email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDRemsSupportEmail), caseRecord, toAddresses, templateName, emailtemplateMap);
                    emailMessageList.add(email);
                }
            } else if(caseRecord.RecordTypeId == hcsReEnrollmentRecordType && caseRecord.Status == 'Draft' && caseRecord.US_WSREMS__Incomplete_Reasons__c != null){
                toaddress = caseRecord.US_WSREMS__REMS_Authorized_Rep__r.PersonEmail;
                if(toaddress == '' || toaddress == null){
                    toaddress = caseRecord.US_WSREMS__Email_ar__c;
                }
                if(toaddress != ''){
                    toAddresses.add(toaddress);
                    // Aveed Healthcare Setting Re-Enrollment Request for Missing or Invalid Information
                    templateName = 'Aveed_HCS_Re_Enrol_Req_for_Mis_Inv_Info';
                    email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDRemsSupportEmail), caseRecord, toAddresses, templateName, emailtemplateMap);
                    emailMessageList.add(email);
                }
            } else if(caseRecord.RecordTypeId == changeAuthRepRecordType && caseRecord.Status == 'Complete'){
                if(caseRecord.US_WSREMS__Authorized_Representative_New_Primary_AR__c != null){
                    toaddress = caseRecord.US_WSREMS__Authorized_Representative_New_Primary_AR__r.PersonEmail;
                }
                if(toaddress == '' || toaddress == null){
                    toaddress = caseRecord.US_WSREMS__AR_Email_New_Primary_AR__c;
                }
                if(toaddress != ''){
                    toAddresses.add(toaddress);
                    templateName = 'Aveed_AuthRep_Replace_Con_to_NewAuthRep';    
                    email = sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDRemsSupportEmail), caseRecord, toAddresses, templateName, emailtemplateMap);
                    emailMessageList.add(email);
                }
            }
        }

        if(!emailMessageList.isEmpty()){
            triggerEmailsToRecipients(emailMessageList);
        }
    }

    public static Messaging.SingleEmailMessage sendemail(Contact con, Id owea, SObject relatedRecord, List<String> toAddresses, String templateName, Map<String,EmailTemplate> emailTemplateIdMap){
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        Case caseRec;
        SObjectType ObjectName = relatedRecord.getSObjectType();  
        if(String.valueOf(ObjectName) == 'Case'){
            caseRec = (Case) relatedRecord;
        }
        List<String> BccAddresses = New List<String>();
        BccAddresses.add(label.AVEEDToaddress); 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setBccAddresses(BccAddresses);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(true);
        mail.setWhatId(relatedRecord.Id);
        if(emailTemplateIdMap.containsKey(templateName)){
            mail.setTemplateId(emailTemplateIdMap.get(templateName).Id);
        }
        if(con != null)
        mail.setTargetObjectId(con.id);
        mail.setTreatTargetObjectAsRecipient(false);
        if (owea != null) {
            mail.setOrgWideEmailAddressId(owea);
        }
        return mail;
    }

    public static Map<String, Id> getOrgWideAddresses(){
        Set<String> addresses = new Set<String>();
        Map<String, Id> orgwideAddress = new Map<String, Id>();
        String aveedSupportEmail = Label.AVEEDRemsSupportEmail;
        String aveedToAddress = Label.AVEEDToaddress;
        addresses.add(aveedSupportEmail);
        addresses.add(aveedToAddress);
        String xiaflexREMS = Label.XIAFLEXRemsSupportEmail;
        String xiaflexMDP = Label.XIAFLEXMDPSupportEmail;
        addresses.add(xiaflexREMS);
        addresses.add(xiaflexMDP);

        List<OrgWideEmailAddress> owea = [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address = :addresses];
        for(OrgWideEmailAddress oweaAddress : owea){
            orgwideAddress.put(oweaAddress.Address, oweaAddress.Id);
        }
        if(!orgwideAddress.isEmpty()){
            return orgwideAddress;
        } else{
            return null;
        }
    }

    public static Map<String, EmailTemplate> getEmailTemplateMap() {
        Map<String, String> emailTemplateMap = new Map<String, String>(); 
        emailTemplateMap.put('AveedHCPProgOptOutConf_Email', 'Aveed HCP Program Opt Out Confirmation');
        emailTemplateMap.put('AveedHCS_ProgramOptOutConfirm', 'Aveed HCS Program Opt Out Confirmation');
        emailTemplateMap.put('Aveed_HCS_Deact_Notify_AR_Not_Confirmed', 'Aveed HCS Program Deactivation Notification');
        emailTemplateMap.put('Aveed_EnrollHCP_KAFeedback', 'Aveed Prescribing HCP Enrollment Knowledge Assessment Attempts Feedback');
        emailTemplateMap.put('Aveed_HCS_Re_Enrol_Req_for_Mis_Inv_Info', 'Aveed Healthcare Setting Re-Enrollment Request for Missing or Invalid Information');
        emailTemplateMap.put('Aveed_HCS_Re_Enrollment_Confirmation', 'Aveed Healthcare Setting Re-Enrollment Confirmation');
        emailTemplateMap.put('Aveed_HCP_or_HCS_Noncompliance_Sus', 'Aveed Prescribing HCP or Healthcare Setting REMS Program Noncompliance Sus');
        emailTemplateMap.put('Aveed_HCP_or_HCS_Noncompliance_Notice', 'Aveed Prescribing HCP or Healthcare Setting REMS Program Noncompliance Notice');
        emailTemplateMap.put('Aveed_HCP_or_HCS_Noncompliance_Deact', 'Aveed HCP or HCS REMS Program Noncompliance Deactivation');
        emailTemplateMap.put('Aveed_HCP_Non_Compliance_Warning', 'Aveed Prescribing HCP REMS Program Non-Compliance Warning');
        emailTemplateMap.put('Aveed_HCS_Non_Compliance_Warning', 'Aveed Healthcare Setting REMS Program Non-Compliance Warning');
        emailTemplateMap.put('Aveed_AuthRep_Replace_Con_to_NewAuthRep', 'Aveed Authorized Representative Confirmed');
        emailTemplateMap.put('AVEED_HCS_Enrollment_Deactivation_Notice', 'Aveed HCS Enrollment Deactivation Notice');

        Map<String,EmailTemplate> templateIdMap = new Map<String,EmailTemplate>();
        for(EmailTemplate temp :[SELECT Id , HtmlValue, Markup, DeveloperName, Subject FROM EmailTemplate WHERE DeveloperName =: emailTemplateMap.keySet()]){
            templateIdMap.put(temp.DeveloperName,temp);
        }
         return templateIdMap;
    }

    public static String prepareBodyForHCSTemplates(US_WSREMS__Affiliation__c affiliationRecord, Case caseRecord, String aveedHtmlBody) {
        aveedHtmlBody = aveedHtmlBody.replace('{{PRESCRIBER_NAME}}', (
            affiliationRecord.US_WSREMS__Authorized_Representative__c != null 
                &&  affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c != null 
                ? affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c : ''
            )
        );
        aveedHtmlBody = aveedHtmlBody.replace('{{REMS_DESCRIPTION}}', caseRecord.US_WSREMS__Description__c != null ? caseRecord.US_WSREMS__Description__c : '');
        aveedHtmlBody = aveedHtmlBody.replace('{{REMS_ID}}', caseRecord.US_WSREMS__REMS_ID__c != null ? caseRecord.US_WSREMS__REMS_ID__c : '');

        String name = caseRecord.US_WSREMS__X1_Participant__r.Name != null ? caseRecord.US_WSREMS__X1_Participant__r.Name : '';
        String addressLine1 = caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Address_Line_1__c != null ? caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Address_Line_1__c : '';
        String city = caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__City__c != null ? caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__City__c : '';
        String state = caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__State__c != null ? caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__State__c : '';
        String zip = caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Zip__c != null ? caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Zip__c : '';
        
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_NAME}}', name != '' ? name + '<br>' : '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_ADDRESS}}', addressLine1 != '' ? addressLine1 + '<br>' : '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_CITY}}', city != '' ? city + ', ' : '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_STATE}}', state != '' ? state + ' ' : '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_ZIP}}', zip != '' ? zip : '');
        return aveedHtmlBody;
    }

    public static String prepareBodyForHCPTemplate(Case caseRecord, String aveedHtmlBody){
        aveedHtmlBody = aveedHtmlBody.replace('{{PRESCRIBER_NAME}}', (caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__First_And_Last_Name__c != null ? caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__First_And_Last_Name__c : ''));
        aveedHtmlBody = aveedHtmlBody.replace('{{REMS_DESCRIPTION}}', caseRecord.US_WSREMS__Description__c != null ? caseRecord.US_WSREMS__Description__c : '');
        aveedHtmlBody = aveedHtmlBody.replace('{{REMS_ID}}', caseRecord.US_WSREMS__REMS_ID__c != null ? caseRecord.US_WSREMS__REMS_ID__c : '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_NAME}}', '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_ADDRESS}}', '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_CITY}}', '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_STATE}}', '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_ZIP}}', '');
        return aveedHtmlBody;
    }

    public static String prepareBodyForAffiliationHCSTemplates(US_WSREMS__Affiliation__c affiliationRecord, Account accountRecord, String aveedHtmlBody) {
        DateTime currentSystemDate = System.now();
        aveedHtmlBody = aveedHtmlBody.replace('{{AUTHREP_NAME}}', (
            affiliationRecord.US_WSREMS__Authorized_Representative__c != null 
                &&  affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c != null 
                ? affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c : ''
            )
        );
        aveedHtmlBody = aveedHtmlBody.replace('{{REMS_ID}}', accountRecord.US_WSREMS__REMS_ID__c != null ? accountRecord.US_WSREMS__REMS_ID__c : '');
        aveedHtmlBody = aveedHtmlBody.replace('{{DEACTIVATION_DATE}}', currentSystemDate.format('MM') + '/' + currentSystemDate.format('dd') + '/' + currentSystemDate.format('YYYY'));

        String name = accountRecord.Name != null ? accountRecord.Name : '';
        String addressLine1 = accountRecord.US_WSREMS__Address_Line_1__c != null ? accountRecord.US_WSREMS__Address_Line_1__c : '';
        String city = accountRecord.US_WSREMS__City__c != null ? accountRecord.US_WSREMS__City__c : '';
        String state = accountRecord.US_WSREMS__State__c != null ? accountRecord.US_WSREMS__State__c : '';
        String zip = accountRecord.US_WSREMS__Zip__c != null ? accountRecord.US_WSREMS__Zip__c : '';
        
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_NAME}}', name != '' ? name : '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_ADDRESS}}', addressLine1 != '' ? addressLine1 : '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_CITY}}', city != '' ? city + ', ' : '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_STATE}}', state != '' ? state + ' ' : '');
        aveedHtmlBody = aveedHtmlBody.replace('{{HCS_ZIP}}', zip != '' ? zip : '');
        return aveedHtmlBody;
    }
    // Added by Krishnababu M for XIAFLEX -- BT-2816-130 (Correspondance Template)-- Start
    public static void sendXiaflexCaseNotificationAsync(List<Case> triggeredCaseList){
        List<Case> caseList = AutomationCommunicationFromCase.getCasesByProgramAndCaseIds(new Map<Id, Case>(triggeredCaseList).keySet(), 'XIAFLEX');
		Id casePrescriberRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        Id caseHCSRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
         Id caseHcsReEnrollmentRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Reenrollment');
        Id caseChangeAuthRepRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Change_Authorized_Representative');
       Id nonComplianceRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        Id prescriberRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        Id hcsRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');

        Map<String, EmailTemplate> xiflexEmailtemplateMap = getXiaflexEmailTemplateMap();
        List<String> toAddresses = new List<String>();
        String toaddress = '';
        String toaddressValue = '';
        String templateName;
        List<String> BccAddresses = New List<String>();
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        Map<Id, Case> accounIdToHCSEnrollementCaseMap = new Map<Id, Case>();
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRecord;

        Set<Id> nonComplainceAuthRepIds = new Set<Id>();
        for(case caseRecord : caseList) {
            if(caseRecord.RecordTypeId == nonComplianceRecordType && caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == hcsRecordType) {
                nonComplainceAuthRepIds.add(caseRecord.US_WSREMS__X1_Participant__c);
            }
        }

        if(!nonComplainceAuthRepIds.isEmpty()){
            for(US_WSREMS__Affiliation__c affiliationRec : AutomationCommunicationFromCase.getXiaflexAffiliationsRecordsByHcsAccountIds(nonComplainceAuthRepIds)){
                if(!accountIdToaffiliationMap.containsKey(affiliationRec.US_WSREMS__Health_Care_Setting__c)){
                    accountIdToaffiliationMap.put(affiliationRec.US_WSREMS__Health_Care_Setting__c, affiliationRec);
                }
            }
        }
        
        Map<String,OrgWideEmailAddress> owaAddressMap = SYN_CommonUtility.getOrgWideAddressesMap();
        for(Case caseRecord: caseList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(caseRecord.status == complete && caseRecord.RecordTypeId != nonComplianceRecordType && (caseRecord.US_WSREMS__Incomplete_Reasons__c == null || caseRecord.US_WSREMS__Incomplete_Reasons__c == '') ){
                if(caseRecord.RecordTypeId == casePrescriberRecTypeId){
                    toaddress = caseRecord.US_WSREMS__Prescriber__r.PersonEmail;
                    if(toaddress == '' || toaddress == null){
                    toaddress = caseRecord.US_WSREMS__Email__c;
                    }
                    if(toaddress != ''){
                    toAddresses.add(toaddress);
                      if(caseRecord.US_WSREMS__Program_Type__c=='REMS'){
                    templateName = 'Xiaflex_HCP_Enrollment_Con_Notif';
                    }else if(caseRecord.US_WSREMS__Program_Type__c =='MDP'){
                       templateName = 'Xiaflex_MDP_HCP_Enrollment_Con_Notif';
                    }
                    email = sendXiaflexemail(caseRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                    emailMessageList.add(email);
                    }


                }else if (caseRecord.RecordTypeId == caseHCSRecTypeId){
                    toaddress = caseRecord.US_WSREMS__REMS_Authorized_Rep__r.PersonEmail;
                    if(toaddress == '' || toaddress == null){
                    toaddress = caseRecord.US_WSREMS__Email__c;
                    }
                    if(toaddress != ''){
                    toAddresses.add(toaddress);
                          if(caseRecord.US_WSREMS__Program_Type__c=='REMS'){
                   
                    templateName = 'Xiaflex_HCS_Enrollment_Con_Notifi';
                    }
                    else if(caseRecord.US_WSREMS__Program_Type__c =='MDP'){
                       templateName = 'Xiaflex_MDP_HCS_Enrollment_Con_Notif';
                    }
                    
                    email = sendXiaflexemail(caseRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                    emailMessageList.add(email);
                    }

                }else if (caseRecord.RecordTypeId == caseHcsReEnrollmentRecordType){
                    toaddress = caseRecord.US_WSREMS__REMS_Authorized_Rep__r.PersonEmail;
                    if(toaddress == '' || toaddress == null){
                    toaddress = caseRecord.US_WSREMS__Email__c ;
                    }
                    if(toaddress != ''){
                    toAddresses.add(toaddress);
                    // Xiaflex Healthcare Setting Re-Enrollment Confirmation
                    templateName = 'Xiaflex_HCS_Re_Enrollment_Confirmation';
                    email = sendXiaflexemail(caseRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                    emailMessageList.add(email);
                    }

                }else if (caseRecord.RecordTypeId == caseChangeAuthRepRecordType && caseRecord.US_WSREMS__Healthcare_Setting__c!=null){
                    if(caseRecord.US_WSREMS__Authorized_Representative_New_Primary_AR__c != null){
                    toaddress = caseRecord.US_WSREMS__Authorized_Representative_New_Primary_AR__r.PersonEmail;
                
                    }
                    if(toaddress == '' || toaddress == null){
                    toaddress = caseRecord.US_WSREMS__AR_Email_New_Primary_AR__c;
                    }
                    if(toaddress != ''){
                    toAddresses.add(toaddress);
                    if(caseRecord.US_WSREMS__Program_Type__c=='REMS'){
                    // Xiaflex REMS Healthcare Setting Change AR Confirmation.
                    templateName = 'Xiaflex_AR_Replace_Con_Sent_to_New_AR'; 
                    }
                    else if(caseRecord.US_WSREMS__Program_Type__c =='MDP'){
                       templateName = 'Xiaflex_MDP_AR_Replace_Sent_to_New_AR';
                    }
                    email = sendXiaflexemail(caseRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                    emailMessageList.add(email);
                    }


                }

            }
            else if(caseRecord.RecordTypeId == nonComplianceRecordType){
                if(caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == prescriberRecordType){
                    toaddress = caseRecord.US_WSREMS__X1_Participant__r.PersonEmail;
                    if(toaddress == '' || toaddress == null){
                        toaddress = caseRecord.US_WSREMS__Participant_Email__c;
                    }
                    if(toaddress != ''){
                        toAddresses.add(toaddress);
                        if(caseRecord.US_WSREMS__Outcome__c == suspectedNoncomplianceActivity && caseRecord.Status == complianceInvestigation) {
                            // HCP suspected template===
                            if(caseRecord.US_WSREMS__Program_Type__c=='REMS'){
                                templateName = 'Xiaflex_HCP_or_HCS_Noncom_Suspect';

                            }else if(caseRecord.US_WSREMS__Program_Type__c=='MDP'){
                                templateName = 'HCP_XIAFLEX_MDP_Noncompliance';

                            }
                            
                        } else if(caseRecord.US_WSREMS__Outcome__c == confirmedNoncomplianceActivity && caseRecord.Status == complete) {
                            // HCP Confirmed template===
                            if(caseRecord.US_WSREMS__Program_Type__c=='REMS'){
                               templateName = 'Xiaflex_HCP_or_HCS_Noncompliance_Notice'; 
                            }else if(caseRecord.US_WSREMS__Program_Type__c=='MDP'){
                                templateName = 'Xiaflex_MDP_HCP_HCS_Noncompliance_Notice'; 
                            }
                        }
                        if(String.isNotEmpty(templateName)){
                            email = sendXiaflexemail(caseRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                            String xiaflexHtmlBody = xiflexEmailtemplateMap.get(templateName).markup;
                            String body = prepareBodyForXiaflexHCPTemplate(caseRecord, xiaflexHtmlBody);
                            xiaflexHtmlBody = body;
                            email.setHtmlBody(xiaflexHtmlBody);
                            email.setSubject(xiflexEmailtemplateMap.get(templateName).Subject);
                            emailMessageList.add(email);
                        }
                    }
                }
                else if(caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == hcsRecordType){
                    affiliationRecord = accountIdToaffiliationMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c) ? accountIdToaffiliationMap.get(caseRecord.US_WSREMS__X1_Participant__c) : null;
                    if(affiliationRecord != null){
                        toaddress = affiliationRecord.US_WSREMS__Authorized_Representative__c != null && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != null ? affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail : null;
                    }
                    if(toaddress != ''){
                        toAddresses.add(toaddress);
                        if(caseRecord.US_WSREMS__Outcome__c == suspectedNoncomplianceActivity && caseRecord.Status == complianceInvestigation) {
                            // HCS suspected template===
                            if(caseRecord.US_WSREMS__Program_Type__c == 'REMS'){
                                templateName = 'Xiaflex_HCP_or_HCS_Noncom_Suspect';
                            }else if(caseRecord.US_WSREMS__Program_Type__c == 'MDP'){
                                templateName = 'HCP_XIAFLEX_MDP_Noncompliance';
                            }
                        } else if(caseRecord.US_WSREMS__Outcome__c == confirmedNoncomplianceActivity  && caseRecord.Status == complete) {
                            // HCS Confirmed template===
                            if(caseRecord.US_WSREMS__Program_Type__c == 'REMS'){
                               templateName = 'Xiaflex_HCP_or_HCS_Noncompliance_Notice'; 
                            }else if(caseRecord.US_WSREMS__Program_Type__c == 'MDP'){
                                templateName = 'Xiaflex_MDP_HCP_HCS_Noncompliance_Notice';
                            }
                            
                        }
                        else if(caseRecord.Status == complianceInvestigation && caseRecord.US_WSREMS__Outcome__c == confirmedNoncomplianceActivity){
                            if(caseRecord.US_WSREMS__Program_Type__c == 'REMS'){
                                templateName = 'Xiaflex_HCS_REMS_Noncompliance_Warning';
                            }else if(caseRecord.US_WSREMS__Program_Type__c == 'MDP'){
                                templateName = 'Xiaflex_MDP_HCS_Noncompliance_Warning';
                            }
                        }
                        if(String.isNotEmpty(templateName)){
                            email = sendXiaflexemail(caseRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                            String xiaflexHtmlBody = xiflexEmailtemplateMap.get(templateName).markup;
                            String body = prepareBodyForXiaflexHCSTemplates(affiliationRecord, caseRecord, xiaflexHtmlBody);
                            xiaflexHtmlBody = body;
                            xiaflexHtmlBody = xiaflexHtmlBody.replace('{{PRESCRIBER_NAME}}', (affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c != null ? affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c : ''));
                        	xiaflexHtmlBody = xiaflexHtmlBody.replace('{!relatedTo.US_WSREMS__Description__c}', caseRecord.US_WSREMS__Description__c != null ? caseRecord.US_WSREMS__Description__c : '');
                            email.setHtmlBody(xiaflexHtmlBody);
                            email.setSubject(xiflexEmailtemplateMap.get(templateName).Subject);
                            emailMessageList.add(email);  
                        }
                    }

                }

            }       
        }

        if(!emailMessageList.isEmpty()){
            triggerEmailsToRecipients(emailMessageList);
        }
    }
    // ***************************
    	public static void sendXiaflexAccountDeactivationNotificationFromAccount(List<Account> accountList, Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap){
        List<String> toAddresses = new List<String>();
        String toaddress = '';
        String toaddressValue = '';
        String templateName;
        List<String> BccAddresses = New List<String>();
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        Map<String, EmailTemplate> xiflexEmailtemplateMap = getXiaflexEmailTemplateMap();
        US_WSREMS__Affiliation__c affiliationRecord;

        Map<String,OrgWideEmailAddress> owaAddressMap = SYN_CommonUtility.getOrgWideAddressesMap();
        for(Account accountRecord: accountList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // HCP Program Opt-Out Confirmation - prescriber
            if(accountRecord.US_WSREMS__Status__c == 'Deactivated' && accountRecord.US_WSREMS__Sub_Status__c == 'Program Opt-Out'
                && accountRecord.recordTypeId == XIAFLEXAutomationCommunicationUtility.prescriberRecordType
            ) {
                toaddress = accountRecord.PersonEmail;
                if(toaddress != ''){
                    toAddresses.add(toaddress);
                    if(accountRecord.US_WSREMS__Program_Type__c == 'REMS'){
                       templateName = 'Xiaflex_HCP_Opt_Out_Confirmation_Notifcn'; 
                    }else if(accountRecord.US_WSREMS__Program_Type__c == 'MDP'){
                    templateName = 'Xiaflex_MDP_HCP_Opt_Out_Confmn_Notifcn';
                	}
                   email = sendXiaflexemail(accountRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                    emailMessageList.add(email);
                }
            } else if(accountRecord.US_WSREMS__Status__c == 'Deactivated' && accountRecord.US_WSREMS__Sub_Status__c == 'Program Opt-Out'
                && accountRecord.recordTypeId == XIAFLEXAutomationCommunicationUtility.hcsRecordType
            ) {
                //Xiaflex Healthcare Setting Program Opt-Out Confirmation - sent to Auth Rep
                affiliationRecord = accountIdToaffiliationMap.get(accountRecord.Id);
                if(affiliationRecord.US_WSREMS__Authorized_Representative__c != null && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != ''
                    && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != null
                ){
                    toaddress = affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail;
                }

                if(toaddress != ''){
                    toAddresses.add(toaddress);
                    if(accountRecord.US_WSREMS__Program_Type__c == 'REMS'){
                       templateName = 'Xiaflex_HCS_Opt_Out_Confirmation_Notifcn'; 
                    }else if(accountRecord.US_WSREMS__Program_Type__c == 'MDP'){
                    templateName = 'Xiaflex_MDP_HCS_Opt_Out_Confmn_Notifcn';
                	}
                    email = sendXiaflexemail(accountRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                    String xiaflexHtmlBody = xiflexEmailtemplateMap.get(templateName).markup;
                    String body = prepareBodyForXiaflexAffiliationHCSTemplates(affiliationRecord, accountRecord, xiaflexHtmlBody);
                    xiaflexHtmlBody = body;
                    email.setHtmlBody(xiaflexHtmlBody);
                    email.setSubject(xiflexEmailtemplateMap.get(templateName).Subject);
                    emailMessageList.add(email);
                }
            } else if(accountRecord.US_WSREMS__Status__c == 'Decertified' && accountRecord.US_WSREMS__Program_Type__c=='REMS' && accountRecord.US_WSREMS__Sub_Status__c == 'Enrollment Expired'
                && accountRecord.recordTypeId == XIAFLEXAutomationCommunicationUtility.hcsRecordType
            ) {
                // Xiaflex Healthcare Setting Deactivation Notification – AR Not Confirmed - sent to auth rep
                affiliationRecord = accountIdToaffiliationMap.get(accountRecord.Id);
                if(affiliationRecord.US_WSREMS__Authorized_Representative__c != null && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != ''
                    && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != null
                ){
                    toaddress = affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail;
                }
                if(toaddress != ''){
                    toAddresses.add(toaddress);
                    templateName = 'XIAFLEX_HCS_Deactivation_Notice';
                    email = sendXiaflexemail(accountRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                    String xiaflexHtmlBody = xiflexEmailtemplateMap.get(templateName).markup;
                    String body = prepareBodyForXiaflexAffiliationHCSTemplates(affiliationRecord, accountRecord, xiaflexHtmlBody);
                    xiaflexHtmlBody = body;
                    email.setHtmlBody(xiaflexHtmlBody);
                    email.setSubject(xiflexEmailtemplateMap.get(templateName).Subject);
                    emailMessageList.add(email);
                }
            }
            else if(accountRecord.US_WSREMS__Status__c == 'Decertified' && accountRecord.US_WSREMS__Sub_Status__c == 'Non-compliance'
                 && accountRecord.recordTypeId == XIAFLEXAutomationCommunicationUtility.hcsRecordType
            ) {
                // Xiaflex Healthcare Setting Deactivation Notification – AR Not Confirmed - sent to auth rep
                affiliationRecord = accountIdToaffiliationMap.get(accountRecord.Id);
                if(affiliationRecord.US_WSREMS__Authorized_Representative__c != null && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != ''
                    && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != null
                ){
                    toaddress = affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail;
                }
                if(toaddress != ''){
                    toAddresses.add(toaddress);
                    if(accountRecord.US_WSREMS__Program_Type__c == 'REMS'){  
                    templateName = 'Xiaflex_HCS_Non_Complai_Confirm_Noti';
                    }
                    else if(accountRecord.US_WSREMS__Program_Type__c == 'MDP'){
                    templateName = 'Xiaflex_MDP_HCS_Non_Complai_Confirm_Noti';
                    }
                    email = sendXiaflexemail(accountRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                    String xiaflexHtmlBody = xiflexEmailtemplateMap.get(templateName).markup;
                    String body = prepareBodyForXiaflexAffiliationHCSTemplates(affiliationRecord, accountRecord, xiaflexHtmlBody);
                    xiaflexHtmlBody = body;
                    email.setHtmlBody(xiaflexHtmlBody);
                    email.setSubject(xiflexEmailtemplateMap.get(templateName).Subject);
                    emailMessageList.add(email);
                }
            } else if(accountRecord.US_WSREMS__Status__c == 'Decertified' && accountRecord.US_WSREMS__Sub_Status__c == 'Non-compliance'
             && accountRecord.recordTypeId == XIAFLEXAutomationCommunicationUtility.prescriberRecordType
        ) {
            toaddress = accountRecord.PersonEmail;
            if(toaddress != ''){
                toAddresses.add(toaddress);
                if(accountRecord.US_WSREMS__Program_Type__c == 'REMS'){
                   templateName = 'Xiaflex_HCP_Non_Complai_Confirm_Noti'; 
                }
               else if(accountRecord.US_WSREMS__Program_Type__c == 'MDP'){
                    templateName = 'Xiaflex_MDP_HCP_Non_Complai_Confirm_Noti';
                    }
                email = sendXiaflexemail(accountRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                emailMessageList.add(email);
            }
        }          
        }

        if(!emailMessageList.isEmpty()){
            triggerEmailsToRecipients(emailMessageList);
        }
    }

    public static void sendXiaflexAccountDeactivationNotificationForNonCompliance(List<Case> caseList, Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap){

        List<String> toAddresses = new List<String>();
        String toaddress = '';
        String toaddressValue = '';
        String templateName;
        List<String> BccAddresses = New List<String>();
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        Map<Id, Case> accounIdToHCSEnrollementCaseMap = new Map<Id, Case>();
        Map<String, EmailTemplate> xiflexEmailtemplateMap = getXiaflexEmailTemplateMap();
        US_WSREMS__Affiliation__c affiliationRecord;
		Map<String,OrgWideEmailAddress> owaAddressMap = SYN_CommonUtility.getOrgWideAddressesMap();
        for(Case caseRecord: caseList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // HCP Nonc Compliance deactivation - prescriber
            if(caseRecord.RecordTypeId == XIAFLEXAutomationCommunicationUtility.nonComplianceRecordType && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Status__c == 'Decertified'
            ) {
                if(caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == XIAFLEXAutomationCommunicationUtility.prescriberRecordType && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Sub_Status__c == 'Non-compliance'){
                    toaddress = caseRecord.US_WSREMS__X1_Participant__r.PersonEmail;
                    if(toaddress == '' || toaddress == null){
                        toaddress = caseRecord.US_WSREMS__Email__c;
                    }
                    if(toaddress != ''){
                        toAddresses.add(toaddress);
                        // non-complaince deactivation template for HCP===
                        if(caseRecord.US_WSREMS__Program_Type__c == 'REMS'){
                            templateName = 'Xiaflex_HCP_or_HCS_Noncompliance_Deacti';
                            
                        }else if(caseRecord.US_WSREMS__Program_Type__c == 'MDP'){
                            templatename = 'Xiaflex_MDP_HCP_HCS_Noncompliance_Deact';
                        }
                        email = sendXiaflexemail(caseRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                        String xiaflexHtmlBody = xiflexEmailtemplateMap.get(templateName).markup;
                        String body = prepareBodyForXiaflexHCPTemplate(caseRecord, xiaflexHtmlBody);
                        xiaflexHtmlBody = body;
                        DateTime currentSystemDate = System.now();
                        email.setHtmlBody(xiaflexHtmlBody);
                        email.setSubject(xiflexEmailtemplateMap.get(templateName).Subject);
                        emailMessageList.add(email);
                    }
                } else if(caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == XIAFLEXAutomationCommunicationUtility.hcsRecordType && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Sub_Status__c == 'Noncompliant'){
                    affiliationRecord = accountIdToaffiliationMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c) ? accountIdToaffiliationMap.get(caseRecord.US_WSREMS__X1_Participant__c) : null;
                    if(affiliationRecord != null){
                        toaddress = affiliationRecord.US_WSREMS__Authorized_Representative__c != null && affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail != null ? affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail : null;
                    }

                    if(toaddress != ''){
                        toAddresses.add(toaddress);
                        // non-complaince deactivation template for HCS===
                        if(caseRecord.US_WSREMS__Program_Type__c == 'REMS'){
                            templateName = 'Xiaflex_HCP_or_HCS_Noncompliance_Deacti';
                            
                        }else if(caseRecord.US_WSREMS__Program_Type__c == 'MDP'){
                            templatename = 'Xiaflex_MDP_HCP_HCS_Noncompliance_Deact';
                        }
                        email = sendXiaflexemail(caseRecord, toAddresses, templateName, xiflexEmailtemplateMap,owaAddressMap);
                        String xiaflexHtmlBody = xiflexEmailtemplateMap.get(templateName).markup;
                        DateTime currentSystemDate = System.now();
                        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{PRESCRIBER_NAME}}', (affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c != null ? affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c : ''));
                        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{REMS_DESCRIPTION}}', caseRecord.US_WSREMS__Description__c != null ? caseRecord.US_WSREMS__Description__c : '');
                        xiaflexHtmlBody = xiaflexHtmlBody.replace('xiaflex_Logo', System.Label.Xiaflex_LogoForEmailTemplates);
                        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{SYSTEM_DATE}}', currentSystemDate.format('MMMMMMMMMMMMMMMM') + ', ' + currentSystemDate.format('YYYY'));
                        email.setHtmlBody(xiaflexHtmlBody);
                        email.setSubject(xiflexEmailtemplateMap.get(templateName).Subject);
                        emailMessageList.add(email);
                    }
                }
            }
        }

        if(!emailMessageList.isEmpty()){
            triggerEmailsToRecipients(emailMessageList);
        }
    }
    public static String prepareBodyForXiaflexAffiliationHCSTemplates(US_WSREMS__Affiliation__c affiliationRecord, Account accountRecord, String xiaflexHtmlBody) {
        DateTime currentSystemDate = System.now();
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{AUTHREP_NAME}}', (affiliationRecord != null && 
            affiliationRecord.US_WSREMS__Authorized_Representative__c != null 
                &&  affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c != null 
                ? affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c : ''
            )
        );
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{REMS_ID}}', accountRecord.US_WSREMS__REMS_ID__c != null ? accountRecord.US_WSREMS__REMS_ID__c : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('xiaflex_Logo', System.Label.Xiaflex_LogoForEmailTemplates);
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{SYSTEM_DATE}}', currentSystemDate.format('MMMMMMMMMMMMMMMM') + ', ' + currentSystemDate.format('YYYY'));
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{DEACTIVATION_DATE}}', currentSystemDate.format('MM') + '/' + currentSystemDate.format('dd') + '/' + currentSystemDate.format('YYYY'));
 		xiaflexHtmlBody = xiaflexHtmlBody.replace('{{Prescriber}}', System.Label.XiaflexPrescribingInfo);
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{Medication}}', System.Label.XiaflexMedicationGuide);
        String name = accountRecord.Name != null ? accountRecord.Name : '';
        String addressLine1 = accountRecord.US_WSREMS__Address_Line_1__c != null ? accountRecord.US_WSREMS__Address_Line_1__c : '';
        String addressLine2 = accountRecord.US_WSREMS__Address_Line_2__c != null ? accountRecord.US_WSREMS__Address_Line_2__c : '';
        String city = accountRecord.US_WSREMS__City__c != null ? accountRecord.US_WSREMS__City__c : '';
        String state = accountRecord.US_WSREMS__State__c != null ? accountRecord.US_WSREMS__State__c : '';
        String zip = accountRecord.US_WSREMS__Zip__c != null ? accountRecord.US_WSREMS__Zip__c : '';
        String comment = accountRecord.US_WSREMS__Comments__c != null ? accountRecord.US_WSREMS__Comments__c : '';
        
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_NAME}}', name != '' ? name : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_ADDRESS}}', addressLine1 != '' ? addressLine1 : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_ADDRESS2}}', addressLine2 != '' ? addressLine2 : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_CITY}}', city != '' ? city + ', ' : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_STATE}}', state != '' ? state + ', ' : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_ZIP}}', zip != '' ? zip : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{Description}}', comment != '' ? comment : '');
        return xiaflexHtmlBody;
    }
    public static Map<String, EmailTemplate> getXiaflexEmailTemplateMap() {
        Map<String, String> emailTemplateMap = new Map<String, String>();
        Set<string> emailtemplateSet = new Set<string>();
        // REMS
        emailtemplateSet.add('Xiaflex_HCP_Enrollment_Con_Notif');
        emailtemplateSet.add('Xiaflex_HCS_Enrollment_Con_Notifi');
        emailtemplateSet.add('Xiaflex_HCS_Re_Enrollment_Confirmation');
        emailtemplateSet.add('Xiaflex_AR_Replace_Con_Sent_to_New_AR');
        emailtemplateSet.add('Xiaflex_HCP_or_HCS_Noncom_Suspect');
        emailtemplateSet.add('Xiaflex_HCP_or_HCS_Noncompliance_Notice');
        emailtemplateSet.add('Xiaflex_HCP_REMS_Noncompliance_Warning');
        emailtemplateSet.add('Xiaflex_HCS_REMS_Noncompliance_Warning');
        emailtemplateSet.add('Xiaflex_HCP_Opt_Out_Confirmation_Notifcn');
        emailtemplateSet.add('Xiaflex_HCS_Opt_Out_Confirmation_Notifcn');
        emailtemplateSet.add('XIAFLEX_HCS_Deactivation_Notice');
        // MDP
        emailtemplateSet.add('Xiaflex_MDP_HCP_Enrollment_Con_Notif');
        emailtemplateSet.add('Xiaflex_MDP_HCS_Enrollment_Con_Notif');
        emailtemplateSet.add('Xiaflex_MDP_AR_Replace_Sent_to_New_AR');
        emailtemplateSet.add('HCP_XIAFLEX_MDP_Noncompliance');
        emailtemplateSet.add('Xiaflex_MDP_HCP_HCS_Noncompliance_Notice');
        emailtemplateSet.add('Xiaflex_MDP_HCP_Noncomp_Warning');
        emailtemplateSet.add('Xiaflex_MDP_HCS_Noncompliance_Warning');
        emailtemplateSet.add('Xiaflex_MDP_HCP_Opt_Out_Confmn_Notifcn');
        emailtemplateSet.add('Xiaflex_MDP_HCS_Opt_Out_Confmn_Notifcn');
        emailtemplateSet.add('Xiaflex_MDP_HCP_HCS_Noncompliance_Deact');
        emailtemplateSet.add('Xiaflex_HCP_Non_Complai_Confirm_Noti');
        emailtemplateSet.add('Xiaflex_HCS_Non_Complai_Confirm_Noti');
        emailtemplateSet.add('Xiaflex_MDP_HCP_Non_Complai_Confirm_Noti');
        emailtemplateSet.add('Xiaflex_MDP_HCS_Non_Complai_Confirm_Noti');
        emailtemplateSet.add('Xiaflex_HCP_Aff_HCS_Cer_Ren_Rem');
        Map<String,EmailTemplate> templateIdMap = new Map<String,EmailTemplate>();
        for(EmailTemplate temp :[SELECT Id , HtmlValue, Markup, DeveloperName, Subject FROM EmailTemplate WHERE DeveloperName IN :emailtemplateSet]){
            templateIdMap.put(temp.DeveloperName,temp);
        }
         return templateIdMap;
    }
    public static String prepareBodyForXiaflexHCPTemplate(Case caseRecord, String xiaflexHtmlBody){
        DateTime currentSystemDate = System.now();
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{PRESCRIBER_NAME}}', (caseRecord.US_WSREMS__X1_Participant__r.Name != null ? caseRecord.US_WSREMS__X1_Participant__r.Name : ''));
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{REMS_DESCRIPTION}}', caseRecord.US_WSREMS__Description__c != null ? caseRecord.US_WSREMS__Description__c : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{REMS_ID}}', caseRecord.US_WSREMS__REMS_ID__c != null ? caseRecord.US_WSREMS__REMS_ID__c : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('xiaflex_Logo', System.Label.Xiaflex_LogoForEmailTemplates);
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_NAME}}',' ');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_ADDRESS}}', ' ');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_ADDRESS2}}', ' ');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_CITY}}', ' ');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_STATE}}',' ');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_ZIP}}',' ');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{SYSTEM_DATE}}', currentSystemDate.format('MMMMMMMMMMMMMMMM') + ', ' + currentSystemDate.format('YYYY'));
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{Prescriber}}', System.Label.XiaflexPrescribingInfo);
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{Medication}}', System.Label.XiaflexMedicationGuide);
        return xiaflexHtmlBody;
    }
    public static String prepareBodyForXiaflexHCSTemplates(US_WSREMS__Affiliation__c affiliationRecord, Case caseRecord, String xiaflexHtmlBody) {
        DateTime currentSystemDate = System.now();
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{PRESCRIBER_NAME}}', (
            affiliationRecord.US_WSREMS__Authorized_Representative__c != null 
                &&  affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c != null 
                ? affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c : null
            )
        );
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{REMS_DESCRIPTION}}', caseRecord.US_WSREMS__Description__c != null ? caseRecord.US_WSREMS__Description__c : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{REMS_ID}}', caseRecord.US_WSREMS__REMS_ID__c != null ? caseRecord.US_WSREMS__REMS_ID__c : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('xiaflex_Logo', System.Label.Xiaflex_LogoForEmailTemplates);
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{SYSTEM_DATE}}', currentSystemDate.format('MMMMMMMMMMMMMMMM') + ', ' + currentSystemDate.format('YYYY'));
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{Prescriber}}', System.Label.XiaflexPrescribingInfo);
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{Medication}}', System.Label.XiaflexMedicationGuide);

        String name = (caseRecord.US_WSREMS__X1_Participant__c != null && caseRecord.US_WSREMS__X1_Participant__r.Name != null) ? caseRecord.US_WSREMS__X1_Participant__r.Name : '';
        String addressLine1 = (caseRecord.US_WSREMS__X1_Participant__c != null && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Address_Line_1__c != null) ? caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Address_Line_1__c : '';
        String addressLine2 = (caseRecord.US_WSREMS__X1_Participant__c != null && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Address_Line_2__c != null) ? caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Address_Line_2__c : '';
        String city = (caseRecord.US_WSREMS__X1_Participant__c != null && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__City__c != null) ? caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__City__c : '';
        String state = (caseRecord.US_WSREMS__X1_Participant__c != null && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__State__c != null) ? caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__State__c : '';
        String zip = (caseRecord.US_WSREMS__X1_Participant__c != null && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Zip__c != null) ? caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Zip__c : '';
        
        
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_NAME}}', name != '' ? name : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_ADDRESS}}', addressLine1 != '' ? addressLine1 : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_ADDRESS2}}', addressLine2 != '' ? addressLine2 : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_CITY}}', city != '' ? city + ', ' : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_STATE}}', state != '' ? state + ', ' : '');
        xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_ZIP}}', zip != '' ? zip : '');
        return xiaflexHtmlBody;
    }
        public static Messaging.SingleEmailMessage sendXiaflexemail(SObject relatedRecord, List<String> toAddresses, String templateName, Map<String,EmailTemplate> emailTemplateIdMap,Map<String,OrgWideEmailAddress> owaMap){
            List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
            Contact con = getContact();
            Case caseRec;
            Account acRec;
            SObjectType ObjectName = relatedRecord.getSObjectType();  
            if(String.valueOf(ObjectName) == 'Case'){
                caseRec = (Case) relatedRecord;
            }else if(String.valueOf(ObjectName) == 'Account'){
                acRec = (Account) relatedRecord;
            }
            OrgWideEmailAddress owea;
                //Org-wide Email...
            if((caseRec != null && caseRec.US_WSREMS__Program_Type__c == 'REMS')||
               (acRec !=null && acRec.US_WSREMS__Program_Type__c == 'REMS')){
                owea = owaMap.get(Label.XIAFLEXRemsSupportEmail.toLowercase());
            }
             else if((caseRec != null && caseRec.US_WSREMS__Program_Type__c == 'MDP') || (acRec !=null && acRec.US_WSREMS__Program_Type__c == 'MDP')){
                owea =owaMap.get(Label.XIAFLEXMDPSupportEmail.toLowercase());
            }else {
                owea = owaMap.get(Label.XIAFLEXtoaddress.toLowercase());
            }
            //Email for From address...
            //Email for BCC Address-----
             
            String bccAddress = System.Label.Xiaflex_REMS_BCC_Email_for_Correspondence_Templates;
            String[] bccAddresses = bccAddress.split(';');
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setBccAddresses(bccAddresses);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(true);
            mail.setWhatId(relatedRecord.Id);
            if(emailTemplateIdMap.containsKey(templateName)){
                mail.setTemplateId(emailTemplateIdMap.get(templateName).Id);
            }
            if(con != null)
            mail.setTargetObjectId(con.id);
            mail.setTreatTargetObjectAsRecipient(false);
            if(owea != null){
                mail.setOrgWideEmailAddressId(owea.Id);
            }
            return mail;
        }
// Added by Krishnababu M for XIAFLEX -- BT-2816-130 (Correspondance Template)-- End

@InvocableMethod
    public static void piasky_PAEsendEmails(List<List<SObject>> casesToProcessWrapper) {

        // Ensure the input contains one list of cases
        if (casesToProcessWrapper.isEmpty() || casesToProcessWrapper[0].isEmpty()) {
            return;
        }
        
        // Convert the list of SObjects to a list of Case objects
        List<Case> casesToProcess = (List<Case>) casesToProcessWrapper[0];

        // Extract Case IDs
        List<Id> caseIds = new List<Id>();
        for (Case c : casesToProcess) {
            caseIds.add(c.Id);
        }

        // Call the future method in the top-level class
        PiaskyPAEEmailNotification.sendEmailsAsync(caseIds);
    }
}