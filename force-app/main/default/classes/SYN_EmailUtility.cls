public with sharing class SYN_EmailUtility{      
    
    public static String patient = 'Patient';
    public static String prescriber = 'Prescriber';
    public static String pharmacyUser = 'Pharmacy User';
    
    
    /**
    * @Author: Rajadurai Kalyanasundaram    
    * @Description:  Method to construct and send the email 
    * @Param: caseRec, 'TemplateName', 'StakeHolder', 'fromaddress'
    */

    //public static void sendEmail(SObject source, String templateName, String recipientType, String oweAdd, Boolean setActivity, String whatIdVal, String targetObjIdVal, List<String> attachIds){}

    public static void sendEmail(SYN_CorrespondenceHandler.EmailWrapperClass emailwrappvalues){
                                
        List<Messaging.SingleEmailMessage> theEmailMessages = new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = new List<String>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        EmailTemplate emailTemplate = getEmailTemplate(emailwrappvalues.templateName);
        if(emailwrappvalues.toAddressList != Null && emailwrappvalues.toAddressList.size()>0 ){
            toAddresses = emailwrappvalues.toAddressList;
        }
        else{
            toAddresses.add(emailwrappvalues.emailAddress);
        }

        mail.setToAddresses(toAddresses);
        mail.setBccAddresses(emailwrappvalues.bccEmailAddress);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(emailwrappvalues.setActivity);
        mail.setWhatId(emailwrappvalues.whatIdVal);
        if(emailTemplate != null){
            mail.setTemplateId(emailTemplate.Id);
        }
        mail.setTargetObjectId(emailwrappvalues.targetObjIdVal);
        mail.setTreatTargetObjectAsRecipient(false);
        
        Id owdId = String.isBlank(emailwrappvalues.oweAdd)? null: getOWEAddressId(emailwrappvalues.oweAdd);
        if(owdId != null){
            mail.setOrgWideEmailAddressId(owdId);
        }
        
        if(emailwrappvalues.attachIds != NULL){
        
            List<Messaging.EmailFileAttachment> emailAttachments = getAttachments(emailwrappvalues.attachIds);
            if(emailAttachments != NULL && !emailAttachments.isEmpty()){
            
                mail.setFileAttachments(emailAttachments);   
            }
        }
        theEmailMessages.add(mail);
    
        if(!theEmailMessages.isEmpty()) {
          boolean status = triggerEmailsToRecipients(theEmailMessages);
            if(emailwrappvalues.communicationRecId !=null){
            REMS_Outbound_Communication__c recordObj=new REMS_Outbound_Communication__c();
            recordObj.id=emailwrappvalues.communicationRecId;
            if(status){
                recordObj.Status__c='Sent';
               recordObj.ContactName__c=emailwrappvalues.targetObjIdVal;
            }else{
                 recordObj.Status__c='Failed';
                recordObj.ContactName__c=emailwrappvalues.targetObjIdVal;
            }
                update recordObj;
            }
        }
    }
    /**
    * @Author: Mani krishna   
    * @Description:  Method will return the list of Email Recipients
    * @Param: recipientType
    */
        public static List<string> emailRecipientList(string recipientType){
            List<string> emailRecipientTypeList = new List<string>();

            if(recipientType == patient){     
            
                //toAddresses.add('rajaduraik@wilcosource.com');
                emailRecipientTypeList.add('manikrishnad@wilcosource.com');
                emailRecipientTypeList.add('sravanthik@wilcosource.com');
                emailRecipientTypeList.add('harishac@wilcosource.com');
               // toAddresses.add('saitejaa@wilcosource.com');
                //toAddresses.add(caseRec.Patient_Email__c);
            }
            
            if(recipientType == prescriber){     
                
                //toAddresses.add('rajaduraik@wilcosource.com');
                emailRecipientTypeList.add('manikrishnad@wilcosource.com');
                emailRecipientTypeList.add('sravanthik@wilcosource.com');
                emailRecipientTypeList.add('harishac@wilcosource.com');
               // toAddresses.add('saitejaa@wilcosource.com');
                //toAddresses.add(caseRec.Provider__r.Email);
            }        
            
            if(recipientType == pharmacyUser){     
                
                //toAddresses.add('rajaduraik@wilcosource.com');
                emailRecipientTypeList.add('manikrishnad@wilcosource.com');
                emailRecipientTypeList.add('sravanthik@wilcosource.com');
                emailRecipientTypeList.add('harishac@wilcosource.com');
               // toAddresses.add('saitejaa@wilcosource.com');
                //toAddresses.add(caseRec.Provider__r.Email);
            }
            return emailRecipientTypeList;
    }
    /**
    * @Author: Mani krishna   
    * @Description:  Method will return the list of Email Recipients
    * @Param: List of Email Messages
    */

    public static boolean triggerEmailsToRecipients(List<Messaging.SingleEmailMessage> theEmailMessages){
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        Boolean complete = false;
        try {
            results = Messaging.sendEmail(theEmailMessages); 
            complete = true;        
        }catch(Exception exp) {               
          
            System.debug(':::'+exp.getMessage());   
        }
        
           if (complete && results[0].isSuccess() != true) {
        
            List<Messaging.SendEmailError> errors = results[0].getErrors();   
            String errorReport = '';
            for(Messaging.SendEmailError curError : errors) {
    
                errorReport = errorReport + curError.getMessage() + '/n';
    
            }        
        }
		return complete;
    }
    
    /**
    * @Author: Rajadurai Kalyanasundaram    
    * @Description:  Method to query the email template based on template name
    * @Param: Email Template name 
    */
    public static Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();
    public static EmailTemplate getEmailTemplate(String templateName){
        
        
        if(emailTemplateMap != null && emailTemplateMap.containsKey(templateName)){
            
            return emailTemplateMap.get(templateName);
        }else{  
            
            for(EmailTemplate et : [SELECT Id ,HtmlValue,DeveloperName FROM EmailTemplate where DeveloperName != '']){
                emailTemplateMap.put(et.DeveloperName, et);
            }  

            
            if(emailTemplateMap != null && emailTemplateMap.containsKey(templateName)){
            
                return emailTemplateMap.get(templateName);
            }
            return null;                
        }
    }   
    
    /**
    * @Author: Rajadurai Kalyanasundaram    
    * @Description:  Method to query the Org Wide Email Address based on input email
    * @Param: From Email Address 
    */
    public static Map<String, OrgWideEmailAddress> orgWideEmailIdMap = new Map<String, OrgWideEmailAddress>();
    public static Id getOWEAddressId(String emailAddress){
        
        if(orgWideEmailIdMap != null && orgWideEmailIdMap.containsKey(emailAddress)){
            
            return orgWideEmailIdMap.get(emailAddress).Id;
        }else{
        
            List<OrgWideEmailAddress> oweaList = new List<OrgWideEmailAddress>();
            if(oweaList.isEmpty()){
            
                oweaList = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress LIMIT 5000];
            }
            
            for(OrgWideEmailAddress owEmail : oweaList){
                
                orgWideEmailIdMap.put(owEmail.Address, owEmail);
            }  
            
            if(orgWideEmailIdMap != null && orgWideEmailIdMap.containsKey(emailAddress)){
            
                return orgWideEmailIdMap.get(emailAddress).Id;
            }
            return null;                
        }   
    }
    
    /**
    * @Author: Rajadurai Kalyanasundaram    
    * @Description:  Method to query the email attachments based on attachment Ids
    * @Param: Attachments Ids 
    */    
    public static List<Messaging.EmailFileAttachment> getAttachments(List<Id> attchIdList){
    
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                
        for (Attachment attcRecord: [Select Name, Body From Attachment Where id IN: attchIdList WITH SECURITY_ENFORCED]){
    
            Messaging.EmailFileAttachment fileAttach = new Messaging.EmailFileAttachment();
            fileAttach.setContentType('application/pdf');
            fileAttach.setFileName(attcRecord.Name);
            fileAttach.setBody(attcRecord.Body);
            attachments.add(fileAttach);
        }
        
        return attachments;
    }
    
    public static Map<String, Map<String, REMS_Correspondence_Settings__mdt>> correspondSettingsMap = new Map<String,  Map<String, REMS_Correspondence_Settings__mdt>>();
    
    public static REMS_Correspondence_Settings__mdt getProgramSpecificCorresSett(String programName, String templateName){
        REMS_Correspondence_Settings__mdt settings = new REMS_Correspondence_Settings__mdt();
        if(!correspondSettingsMap.containsKey(programName)){
            correspondSettingsMap = getAllCorrespondenceSettings();
        }
        Map<String, REMS_Correspondence_Settings__mdt> programEmailSettings = correspondSettingsMap.get(programName);
        settings = programEmailSettings.get(templateName);
        return settings;
        
    }
    
    public static Map<String, Map<String, REMS_Correspondence_Settings__mdt>> getAllCorrespondenceSettings(){

         correspondSettingsMap = new Map<String,  Map<String, REMS_Correspondence_Settings__mdt>>();
         
         for(REMS_Correspondence_Settings__mdt resCorresSett : [SELECT Id, DeveloperName, MasterLabel, Active__c, Conga_Attachment_Template__c, From__c, Object_Name__c, Product__c, Program_Configuration__c, 
            Program_Configuration__r.MasterLabel, Recipient_Email_Field__c, Recipient_Type__c, Template_Name__c, Type__c 
            FROM REMS_Correspondence_Settings__mdt 
            WHERE Active__c = TRUE ]){
             if(!correspondSettingsMap.containsKey(resCorresSett.Program_Configuration__r.MasterLabel)){
                 correspondSettingsMap.put(resCorresSett.Program_Configuration__r.MasterLabel, new Map<String, REMS_Correspondence_Settings__mdt>());
             }
             
             Map<String, REMS_Correspondence_Settings__mdt> corresSettingMap = correspondSettingsMap.get(resCorresSett.Program_Configuration__r.MasterLabel);
             corresSettingMap.put(resCorresSett.MasterLabel, resCorresSett);
             
             correspondSettingsMap.put(resCorresSett.Program_Configuration__r.MasterLabel, corresSettingMap); 
         }
         return correspondSettingsMap;
    }
}