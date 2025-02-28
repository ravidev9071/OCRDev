/**
* @File Name : PiaskyPAEEmailNotification.cls
* @Description : This class is responsible sending Piasky PAE Email Notification.
* @Author : Wilco
* @Last Modified By : Shaik Aneesha
* @Last Modified On : Novomber 11, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | Novomber 11, 2024 |   | Initial Version
**/



public class PiaskyPAEEmailNotification {

    private List<Id> caseIds; // Removed static keyword here
    private static final String TEMPLATE_NAME = 'Reportable_Event_Form';
    private static final String REFERENCE_FIELD = 'Type_s_of_Report__c';
    private static final String PAE = 'PAE';
    private static final String TESTINGMAIL = 'test@test.com';
    private static final String FILE_NAME = 'ReportableEventForm.pdf';


    @future(callout=true)
    public static void sendEmailsAsync(List<Id> caseIds) {
        Contact con = SendEmailNotifications.getContact();
        try {
            // Fetch cases based on Ids
            List<Case> casesToProcess = [
                SELECT Id, US_WSREMS__Program_Name__c, US_WSREMS__Type_s_of_Report__c 
                FROM Case 
                WHERE Id IN :caseIds
            ];
            

            // Initialize data structures
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            List<String> programNames = new List<String>();
            Set<String> templateNameSet = new Set<String>();
            Map<String, Id> emailTempIdMap = new Map<String, Id>();
            Map<Id, Id> caseMetaMap = new Map<Id, Id>();

            // Populate program names
            for (Case c : casesToProcess) {
                programNames.add(c.US_WSREMS__Program_Name__c);
            }
            

            // Query content document links associated with cases
            List<ContentDocumentLink> contentDocumentLinks = [
                SELECT ContentDocumentId, LinkedEntityId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :caseIds
            ];
            

            // Map cases to their content document links
            Map<Id, List<ContentDocumentLink>> caseToContentDocumentLinks = new Map<Id, List<ContentDocumentLink>>();
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink cdl : contentDocumentLinks) {
                if (!caseToContentDocumentLinks.containsKey(cdl.LinkedEntityId)) {
                    caseToContentDocumentLinks.put(cdl.LinkedEntityId, new List<ContentDocumentLink>());
                }
                caseToContentDocumentLinks.get(cdl.LinkedEntityId).add(cdl);
                contentDocumentIds.add(cdl.ContentDocumentId);
            }


            // Query content versions for the linked documents
            Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>();
            for (ContentVersion cv : [
                SELECT ContentDocumentId, Title, VersionData, FileExtension
                FROM ContentVersion 
                WHERE ContentDocumentId IN :contentDocumentIds 
                ORDER BY VersionNumber DESC
            ]) {
                contentVersionMap.put(cv.ContentDocumentId, cv);
            }


            // Query REMS correspondence settings for templates
            Map<String, Map<String, US_WSREMS__REMS_CorrespondenceSettings__mdt>> templateMap = new Map<String, Map<String, US_WSREMS__REMS_CorrespondenceSettings__mdt>>();
            for (US_WSREMS__REMS_CorrespondenceSettings__mdt crsd : [
                SELECT Id, US_WSREMS__To_Address__c, MasterLabel, US_WSREMS__Active__c, US_WSREMS__From__c, 
                       US_WSREMS__Program_Configuration__c, US_WSREMS__Program_Configuration__r.MasterLabel, 
                       US_WSREMS__Template_Name__c, US_WSREMS__Type__c, US_WSREMS__Reference_Field__c, 
                       US_WSREMS__Reference_Field_Value__c, US_WSREMS__VFPageName__c 
                FROM US_WSREMS__REMS_CorrespondenceSettings__mdt 
                WHERE US_WSREMS__Active__c = TRUE 
                  AND US_WSREMS__Program_Configuration__r.MasterLabel IN :programNames 
                  AND US_WSREMS__Template_Name__c != null
            ]) {
                if (!templateMap.containsKey(crsd.US_WSREMS__Program_Configuration__r.MasterLabel)) {
                    templateMap.put(crsd.US_WSREMS__Program_Configuration__r.MasterLabel, new Map<String, US_WSREMS__REMS_CorrespondenceSettings__mdt>());
                }

                if (crsd.US_WSREMS__Reference_Field_Value__c != null) {
                    for (String refFld : crsd.US_WSREMS__Reference_Field_Value__c.split('#')) {
                        templateMap.get(crsd.US_WSREMS__Program_Configuration__r.MasterLabel).put(refFld, crsd);
                    }
                }

                if (crsd.US_WSREMS__Template_Name__c != null) {
                    templateNameSet.add(crsd.US_WSREMS__Template_Name__c);
                }
            }


            // Query for email templates
            if (!templateNameSet.isEmpty()) {
                for (EmailTemplate tempObj : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName in :templateNameSet]) {
                    emailTempIdMap.put(tempObj.DeveloperName, tempObj.Id);
                }
            }


            // If no templates are found, exit
            if (emailTempIdMap.isEmpty()) {
                return;
            }

            // Process each case and generate emails
            for (Case caseObj : casesToProcess) {
                if (caseObj.US_WSREMS__Type_s_of_Report__c != null) {
                    List<String> reportTypeList = caseObj.US_WSREMS__Type_s_of_Report__c.split(';');
                    for (String repType : reportTypeList) {
                        US_WSREMS__REMS_CorrespondenceSettings__mdt crsd = templateMap.get(caseObj.US_WSREMS__Program_Name__c).get(repType);
                        
                        if (crsd == null || (caseMetaMap.containsKey(caseObj.Id) && caseMetaMap.get(caseObj.Id) == crsd.Id)) {
                            continue;
                        }

                        caseMetaMap.put(caseObj.Id, crsd.Id);
                        Id templateID = emailTempIdMap.get(crsd.US_WSREMS__Template_Name__c);

                        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        if (crsd.US_WSREMS__VFPageName__c != null) {
                            PageReference pageRef = new PageReference('/apex/' + crsd.US_WSREMS__VFPageName__c);
                            pageRef.getParameters().put('Id', caseObj.Id);
                            Attachment attach = new Attachment();
                            attach.ParentId = caseObj.Id;
                            attach.name = 'Reportable Event form.pdf';
                            if (Test.isRunningTest()) {
                                attach.body = Blob.valueOf('Unit.Test');
                            } else {
                                attach.body = pageRef.getContent();
                                efa.setFileName(attach.name);
                                efa.setBody(attach.body);
                                emailAttachments.add(efa);
                            }
                        }

                        // Attach content documents
                        if (caseToContentDocumentLinks.containsKey(caseObj.Id)) {
                            for (ContentDocumentLink cdl : caseToContentDocumentLinks.get(caseObj.Id)) {
                                ContentVersion cv = contentVersionMap.get(cdl.ContentDocumentId);
                                if (cv != null) {
                                    Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                                    efa1.setFileName(cv.Title + '.' + cv.FileExtension);
                                    efa1.setBody(cv.VersionData);
                                    if (efa1 != null) {
                                    emailAttachments.add(efa1);
                                   }
                                }
                            }
                        }                      

                        // Construct the email
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTemplateId(templateID);
                        email.setTargetObjectId(con.Id); // Adjust as necessary
                        email.setToAddresses(crsd.US_WSREMS__To_Address__c.split(','));
                        email.setOrgWideEmailAddressId(crsd.US_WSREMS__From__c);
                        email.setWhatId(caseObj.Id);
                        email.setSaveAsActivity(true);
                        email.setTreatTargetObjectAsRecipient(false);
                        email.setFileAttachments(emailAttachments);

                        emails.add(email);
                    }
                }
            }

            // Send emails in bulk
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }

        } catch (Exception e) {
            System.debug('### Error in Future Method: ' + e.getMessage() + ' - StackTrace: ' + e.getStackTraceString());
        }
    }
}