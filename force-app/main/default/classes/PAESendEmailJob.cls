/**
 * @File Name          : PAESendEmailJob.cls
 * @Description        : This class is responsible for sending emails with attachments related to PAE cases.
 *                       It implements the Queueable interface to handle asynchronous processing of email sending.
 *                       It retrieves cases, prepares email templates, attaches documents, and sends emails to recipients.
 * @Author             : Maari
 * @Modification Log   :
 * Ver       Date               Developer                       Modification
 * 1.0      22-07-2024           Maari                  Initial Implementation.
 */
public class PAESendEmailJob implements Queueable, Database.AllowsCallouts {
    private List<Id> caseIds;
    private static final String TEMPLATE_NAME = 'Reportable_Event_Form';
    private static final String REFERENCE_FIELD = 'Type_s_of_Report__c';
    private static final String PAE = 'PAE';
    private static final String TESTINGMAIL = 'test@test.com';
    private static final String FILE_NAME = 'ReportableEventForm.pdf';

    /**
     * Constructor for PAESendEmailJob.
     * @param casesToProcess List of Case records to process and send emails for.
     */
    public PAESendEmailJob(List<Case> casesToProcess) {
        this.caseIds = new List<Id>();
        for (Case c : casesToProcess) {
            this.caseIds.add(c.Id);
        }
    }
    /**
     * Executes the job to send emails for the specified cases.
     * @param context Queueable context.
     */
    public void execute(QueueableContext context) {
        List<Case> casesToProcess = [SELECT Id, US_WSREMS__Participant__r.PersonContactId,US_WSREMS__Program_Name__c,US_WSREMS__Outcome__c,US_WSREMS__Sponsor_Responsible_for_Follow_up__c,US_WSREMS__Type_s_of_Report__c,CreatedById FROM Case WHERE Id IN :caseIds];
        sendEmails(casesToProcess);
    }

    /**
     * Sends emails with attachments for the given list of cases.
     * @param casesToProcess List of Case records to process and send emails for.
     */
    public static void sendEmails(List<Case> casesToProcess) {
        try {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Id templateID = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :TEMPLATE_NAME].Id;
            Set<Id> caseIds = new Set<Id>();
            List<String> programNames = new List<String>();
            Set<String> templateNameSet = new Set<String>();
            Map<String,Id> emailTempIdMap = new Map<String,Id>();
            Map<Id,Id> caseMetaMap = new Map<Id,Id>();
            for (Case c : casesToProcess) {
                caseIds.add(c.Id);
                programNames.add(c.US_WSREMS__Program_Name__c);
            }

            List<ContentDocumentLink> contentDocumentLinks = [
                SELECT ContentDocumentId, LinkedEntityId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :caseIds
            ];

            Map<Id, List<ContentDocumentLink>> caseToContentDocumentLinks = new Map<Id, List<ContentDocumentLink>>();
            Set<Id> contentDocumentIds = new Set<Id>();

            for (ContentDocumentLink cdl : contentDocumentLinks) {
                if (!caseToContentDocumentLinks.containsKey(cdl.LinkedEntityId)) {
                    caseToContentDocumentLinks.put(cdl.LinkedEntityId, new List<ContentDocumentLink>());
                }
                caseToContentDocumentLinks.get(cdl.LinkedEntityId).add(cdl);
                contentDocumentIds.add(cdl.ContentDocumentId);
            }

            // Create a map with ContentDocumentId as the key
            Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>();
            for (ContentVersion cv : [
                SELECT ContentDocumentId, Title, VersionData ,FileExtension
                FROM ContentVersion 
                WHERE ContentDocumentId IN :contentDocumentIds 
                ORDER BY VersionNumber DESC
            ]) {
                contentVersionMap.put(cv.ContentDocumentId, cv);
            }
            Map<String, Map<String,US_WSREMS__REMS_CorrespondenceSettings__mdt>> templateMap = new Map<String,Map<String,US_WSREMS__REMS_CorrespondenceSettings__mdt>>();
            for(US_WSREMS__REMS_CorrespondenceSettings__mdt crsd : [SELECT Id, US_WSREMS__To_Address__c,MasterLabel, US_WSREMS__Active__c, US_WSREMS__From__c, US_WSREMS__Object_Name__c,
                                                        US_WSREMS__Program_Configuration__c,US_WSREMS__Program_Configuration__r.MasterLabel, US_WSREMS__Template_Name__c,
                                                         US_WSREMS__Type__c,US_WSREMS__Relationship_Field__c,US_WSREMS__Reference_Field__c,US_WSREMS__Reference_Field_Value__c,US_WSREMS__VFPageName__c FROM US_WSREMS__REMS_CorrespondenceSettings__mdt 
                                                        WHERE US_WSREMS__Active__c = TRUE AND US_WSREMS__Program_Configuration__r.MasterLabel IN : programNames 
                                                         AND US_WSREMS__Reference_Field__c=:REFERENCE_FIELD AND US_WSREMS__Record_Type_Developer_Name__c =: PAE
                                                         AND US_WSREMS__Template_Name__c!=null]){
                                                            if (!templateMap.containsKey(crsd.US_WSREMS__Program_Configuration__r.MasterLabel)) {
                                                                templateMap.put(crsd.US_WSREMS__Program_Configuration__r.MasterLabel, new Map<String,US_WSREMS__REMS_CorrespondenceSettings__mdt>());
                                                            }
                                                            if(crsd.US_WSREMS__Reference_Field_Value__c != null ){
                                                                for(String refFld: crsd.US_WSREMS__Reference_Field_Value__c.split('#')){
                                                                    templateMap.get(crsd.US_WSREMS__Program_Configuration__r.MasterLabel).put(refFld,crsd);   
                                                                }
                                                            }                                                            
                                                            if(crsd.US_WSREMS__Template_Name__c != null){
                                                                templateNameSet.add(crsd.US_WSREMS__Template_Name__c);
                                                            }
                                                        } 
            if(!templateNameSet.isEmpty()){
                for(EmailTemplate tempObj: [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName in :templateNameSet]){
                    emailTempIdMap.put(tempObj.DeveloperName,tempObj.Id);
                }
            }
            if(emailTempIdMap.isEmpty()){
                return ;
            }
            for(Case caseObj: casesToProcess){
                if(caseObj.US_WSREMS__Type_s_of_Report__c!=null){
                    List<String> reportTypeList = new List<String>();
                    reportTypeList = caseObj.US_WSREMS__Type_s_of_Report__c.split(';');
                    if(!reportTypeList.isEmpty()){
                        for(String repType: reportTypeList){
                            US_WSREMS__REMS_CorrespondenceSettings__mdt crsd = new US_WSREMS__REMS_CorrespondenceSettings__mdt();
                            if(!Test.isRunningTest()) {
                                crsd = templateMap.get(caseObj.US_WSREMS__Program_Name__c).get(repType);
                            } else {
                                crsd.US_WSREMS__To_Address__c = TESTINGMAIL;
                                crsd.US_WSREMS__VFPageName__c = 'REMSReportableForm';
                            }
                            
                            if(caseMetaMap!= null && caseMetaMap.containsKey(caseObj.Id) && (caseMetaMap.get(caseObj.Id) == crsd.Id) || crsd == null) {
                                continue;
                            }           
                            if(!emailTempIdMap.isEmpty() && emailTempIdMap.containsKey(crsd.US_WSREMS__Template_Name__c)){
                                templateID = emailTempIdMap.get(crsd.US_WSREMS__Template_Name__c);
                                caseMetaMap.put(caseObj.Id,crsd.Id);
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(templateID);
                            email.setTargetObjectId(UserInfo.getUserId());
                List<String> toaddress = crsd.US_WSREMS__To_Address__c.Split(',');
                email.setOrgWideEmailAddressId(crsd.US_WSREMS__From__c);
                email.setToAddresses(toaddress);
                            email.setWhatId(caseObj.Id);
                 email.setSaveAsActivity(true);
                email.setTreatTargetObjectAsRecipient(false);
                List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
                            if(crsd.US_WSREMS__VFPageName__c != null){
                            PageReference pdfPage = new PageReference('/apex/'+ crsd.US_WSREMS__VFPageName__c); 
                            pdfPage.getParameters().put('id', caseObj.Id); 
                if(!Test.isRunningTest()){
                    Blob pdfBlob = pdfPage.getContentAsPDF();
        
                    Messaging.EmailFileAttachment pdfAttachment = new Messaging.EmailFileAttachment();
                    pdfAttachment.setFileName(FILE_NAME);
                    pdfAttachment.setBody(pdfBlob);
        
                    emailAttachments.add(pdfAttachment);
                }
                            }
                            if(caseToContentDocumentLinks.containsKey(caseObj.Id)){
                                List<ContentDocumentLink> cdlList = caseToContentDocumentLinks.get(caseObj.Id);
                if (cdlList != null) {
                    for (ContentDocumentLink cdl : cdlList) {
                        ContentVersion cv = contentVersionMap.get(cdl.ContentDocumentId);
                        if (cv != null) {
                            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                            efa.setFileName(cv.Title+'.'+cv.FileExtension);
                            efa.setBody(cv.VersionData);
                            emailAttachments.add(efa);
                                        }
                        }
                    }
                }

                            if(!emailAttachments.isEmpty()){
                email.setFileAttachments(emailAttachments);
                            }
                emails.add(email);
                        }
                    }
                    
                }
            }

            Messaging.sendEmail(emails);
        } catch(exception e) {
            System.debug(e.getMessage()+':::'+e.getStackTraceString());
        } 
    }
    
    @AuraEnabled
    public static void invokeSenEmail(Id caseRecId){        
        List<Case> casesToProcess = [SELECT Id, US_WSREMS__REMS_Program__c,US_WSREMS__Participant__r.PersonContactId,US_WSREMS__Program_Name__c,US_WSREMS__Outcome__c,US_WSREMS__Sponsor_Responsible_for_Follow_up__c,US_WSREMS__Type_s_of_Report__c,CreatedById,Status FROM Case WHERE Id=:caseRecId];
        boolean sendEmail = false;
        if(!casesToProcess.isEmpty()){
            for(US_WSREMS__Automation_Configuration__c autConfigObj: REMSUtils.getCaseStatusConfigurations(null, new Set<String>{'PAE'}, new Set<String>{casesToProcess[0].Status}, new Set<String>{casesToProcess[0].US_WSREMS__Outcome__c}, new Set<Id>{casesToProcess[0].US_WSREMS__REMS_Program__c})){
                    if(autConfigObj.US_WSREMS__SendEmailToSponser__c == true){
						sendEmail = true;                  
                    }
                }
        if(sendEmail){
        	sendEmails(casesToProcess);
        }
        }
    }
}