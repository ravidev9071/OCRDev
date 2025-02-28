/**
 * @description       : Send email notifications for affiliation
 * @author            : Utthirakumar
 * @group             : 
 * @last modified on  : 20-11-2024
 * @last modified by  : Utthirakumar
**/

public class AutomationCommunicationFromAffiliation {

    //Affiliation recordtypes
    private static Id prescriberAffiliationRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.AFFILIATION_OBJECT, SYN_Utilitycls.PRESCRIBER_AFFILIATION_RECORDTYPENAME); 
    private static Id hcsAffiliationRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.AFFILIATION_OBJECT, 'Healthcare_Setting_Affiliation');
    private static Id arAffiliationRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.AFFILIATION_OBJECT, 'Authorized_Representative_Affiliation');
    
    //Xiaflex programId
    private static Id xiaflexProgramId = SYN_CommonUtility.getProgramId(SYN_Utilitycls.XIAFLEX_PROGRAM_NAME);
    
    public static Map<Id, Id> hcsARMap = new Map<Id, Id>();
    public static Map<String, OrgWideEmailAddress> owdMap = new Map<String, OrgWideEmailAddress>();
    public static List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    public static List<EmailMessageWrapper> emailWrapperMessage = new List<EmailMessageWrapper>();
    public static Map<String, Id> emailTemplateMap = new Map<String, Id>();

    /*
    *********************************************************
    @Method Name    : sendAffiliationNotifications
    @author         : Utthirakumar
    @description    : method is used to send affiliation notifications to stakeholders.
    @param          : newAffiliations - list of affiliation records from the affiliation trigger.
    @return         : void
    ********************************************************
    */
    public static void sendAffiliationNotifications(List<US_WSREMS__Affiliation__c> newAffiliations) {

        Set<Id> accountIds = new Set<Id>();
 	    Set<Id> hcsAccountIds = new Set<Id>(); 
        
        for (US_WSREMS__Affiliation__c affiliation : newAffiliations) {
            //Xiaflex program check
            if ( affiliation.US_WSREMS__REMSProgram__c == xiaflexProgramId ) {
                
                //Adding HCS in the Prescriber stakeholder detail page.
                if(affiliation.RecordTypeId == hcsAffiliationRecordTypeId && affiliation.US_WSREMS__Prescriber__c != null) 
			    {
			        accountIds.add(affiliation.US_WSREMS__Prescriber__c);

			    } //Adding HCP in the HelathCareSetting stakeholder detail page.
			    else if(affiliation.RecordTypeId == prescriberAffiliationRecordTypeId && affiliation.US_WSREMS__Health_Care_Setting__c != null)
			    {
                    hcsAccountIds.add(affiliation.US_WSREMS__Health_Care_Setting__c);
			    }
            }
        }
        
        //To retrieve the AR's related to HCS's through affiliation.
        if( hcsAccountIds != NULL && hcsAccountIds.size() > 0 ){
            for( US_WSREMS__Affiliation__c aff : [ SELECT Id, US_WSREMS__Authorized_Representative__c, US_WSREMS__Health_Care_Setting__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Health_Care_Setting__c IN : hcsAccountIds AND US_WSREMS__REMSProgram__c =: xiaflexProgramId AND US_WSREMS__isActive__c = TRUE AND US_WSREMS__Authorized_Representative__c != NULL ]){
                hcsARMap.put(aff.US_WSREMS__Health_Care_Setting__c, aff.US_WSREMS__Authorized_Representative__c);
                accountIds.add(aff.US_WSREMS__Authorized_Representative__c);
            }
        }

        //All the stakeholder details of HCP (or) AR's related to HCS
        if( accountIds != NULL && accountIds.size() > 0 ){

            //To retrieve all the orgwideAddress which are verified
            owdMap = getOrgWideAddressesMap();

            //To retrieve all the email templates which are for affiliations
            generateEmailTemplateMap();

            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, PersonEmail, US_WSREMS__Status__c, US_WSREMS__Email__c, personContactId, US_WSREMS__Program_Type__c, US_WSREMS__Preferred_Contact_Method__c, Fax FROM Account WHERE Id IN : accountIds]);
        
            processStakeholderNotifications(accountMap, newAffiliations);

        }
    }

    /*
    *********************************************************
    @Method Name    : processStakeholderNotifications
    @author         : Utthirakumar
    @description    : method is used to process affiliation notifications by checking stakeholder conditions.
    @param          : accountMap - reference of Account map
                      newAffiliations - list of affiliation records from the affiliation trigger.
    @return         : void
    ********************************************************
    */
    public static void processStakeholderNotifications( Map<Id, Account> accountMap, List<US_WSREMS__Affiliation__c> newAffiliations ){

        Boolean affiliationsFromPortal = FALSE;
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Set<Id> processedPrescribers = new Set<Id>();
        Set<Id> processedHCS = new Set<Id>();
        User xiaflexDefaultPortalOwner = SYN_CommonUtility.getDefaultportalUser(System.Label.xiaflex_default_Portal_User); 

        //Itreating all the affiliations to process for the email and fax notifications
        for (US_WSREMS__Affiliation__c affiliation : newAffiliations) {

            //Either Prescriber or AR account (if it's HCS)
            Account relatedToAccount;
            String emailWhatId;
            String accountIdForFax;
            String emailOrFax;
            //Xiaflex program check
            if ( affiliation.US_WSREMS__REMSProgram__c == xiaflexProgramId ) {
                
                if( affiliation.RecordTypeId == hcsAffiliationRecordTypeId && affiliation.US_WSREMS__Prescriber__c != null && !processedPrescribers.contains(affiliation.US_WSREMS__Prescriber__c)) 
			    {
			        
                    relatedToAccount = accountMap.get(affiliation.US_WSREMS__Prescriber__c);

                    if( relatedToAccount != NULL && relatedToAccount.US_WSREMS__Status__c == SYN_Utilitycls.PharmacyAccStatus){
                        emailWhatId = relatedToAccount.Id;
                        processedPrescribers.add(affiliation.US_WSREMS__Prescriber__c);
                        accountIdForFax = affiliation.US_WSREMS__Prescriber__c;
                        emailOrFax = XIAFLEXAutomationCommunicationUtility.checkEmailOrFax(relatedToAccount.US_WSREMS__Preferred_Contact_Method__c, relatedToAccount.PersonEmail, relatedToAccount.Fax);
                    }
			    }
			    else if(affiliation.RecordTypeId == prescriberAffiliationRecordTypeId && affiliation.US_WSREMS__Health_Care_Setting__c != null && !processedHCS.contains(affiliation.US_WSREMS__Health_Care_Setting__c))
			    {
                    if( hcsARMap.containsKey(affiliation.US_WSREMS__Health_Care_Setting__c) ){
                        relatedToAccount = accountMap.get(hcsARMap.get(affiliation.US_WSREMS__Health_Care_Setting__c));
                    }
                    
                    if( relatedToAccount != NULL ){
                        accountIdForFax = affiliation.US_WSREMS__Health_Care_Setting__c;
                        processedHCS.add(affiliation.US_WSREMS__Health_Care_Setting__c);
                        emailWhatId = affiliation.US_WSREMS__Health_Care_Setting__c;
                        emailOrFax = XIAFLEXAutomationCommunicationUtility.checkEmailOrFax(relatedToAccount.US_WSREMS__Preferred_Contact_Method__c, relatedToAccount.PersonEmail, relatedToAccount.Fax);
                    }
			    }

                //To process the related HCP (or) AR's related to HCS
                if( emailOrFax == 'sendemail' ){
                    if( xiaflexDefaultPortalOwner != NULL && !affiliationsFromPortal && affiliation.ownerId == xiaflexDefaultPortalOwner.Id){
                        affiliationsFromPortal = TRUE;
                    }
                    String templateId = getEamilTemplateId(relatedToAccount.US_WSREMS__Program_Type__c, affiliation.RecordTypeId);
                    prepareEmailNotifications(relatedToAccount, templateId, emailWhatId, affiliationsFromPortal);
                //To process fax related communications  
                } else if( emailOrFax == 'sendfax' ) {
                    Account accountRec = new Account(Id = accountIdForFax);
                    String faxTemplateCorrespondenceName = getFaxTemplateName(relatedToAccount.US_WSREMS__Program_Type__c, affiliation.RecordTypeId);
                    communicationRecList.add(XIAFLEXAutomationCommunicationUtility.createREMSCommunicationRecords(accountRec,'Fax',faxTemplateCorrespondenceName));
                }
            }
        }

        //Check and send the email notifications
        if( !emails.isEmpty() || !emailWrapperMessage.isEmpty() ){
            sendEmailNotifications(affiliationsFromPortal);
        }

        //Check and insert communicationRecords for the Fax notifications
        if( communicationRecList != NULL && communicationRecList.size() > 0 ){
            insert communicationRecList;
        }
    }

    /*
    *********************************************************
    @Method Name    : prepareEmailNotifications
    @author         : Utthirakumar
    @description    : method is used to prepare affiliation email notifications to send.
    @param          : relatedToAccount - reference of stakeholder account.
                      templateId - email templateId.
                      emailWhatId - whatId of the email template.
                      portalAffiliations - true for the affiliations created by portal Users otherwise false.
    @return         : void
    ********************************************************
    */
    public static void prepareEmailNotifications( Account relatedToAccount, String templateId, String emailWhatId, Boolean portalAffiliations ){
        
        //fetch the orgwideemail address based on the programType
        OrgWideEmailAddress owaRecord;
        if(relatedToAccount.US_WSREMS__Program_Type__c == SYN_Utilitycls.REMS ){
            owaRecord = owdMap.get(Label.XIAFLEXRemsSupportEmail.toLowerCase());
        } else if( relatedToAccount.US_WSREMS__Program_Type__c == SYN_Utilitycls.MDP ){
            owaRecord = owdMap.get(Label.XIAFLEXMDPSupportEmail.toLowerCase());
        }

        //prepare to and bcc receipients
        String[] sendingTo = new String[]{};
        if( !String.isBlank(relatedToAccount.personEmail) ){
            sendingTo.add(relatedToAccount.personEmail);
        } else if( !String.isBlank(relatedToAccount.US_WSREMS__Email__c) ){
            sendingTo.add(relatedToAccount.US_WSREMS__Email__c);
        }
        String bccAddress = System.Label.Xiaflex_REMS_BCC_Email_for_Correspondence_Templates;
        String[] bccAddresses = bccAddress.split(';');
        
        //Construct wrapper instance for the email message.
        EmailMessageWrapper msgWrap = new EmailMessageWrapper(templateId, emailWhatId, relatedToAccount.personcontactId, sendingTo, bccAddresses, owaRecord.Id);
            
        if( portalAffiliations ){
            //wrapper instance for future method
            emailWrapperMessage.add(msgWrap);
        } else {
            Messaging.SingleEmailMessage email = prepareEmailMessage(msgWrap);
            emails.add(email);
        }
    }

    /*
    *********************************************************
    @Method Name    : sendEmailNotifications
    @author         : Utthirakumar
    @description    : method is used to send affiliation email notifications.
    @param          : affiliationsFromPortal - true for the affiliations created by portal Users otherwise false.
    @return         : void
    ********************************************************
    */
    public static void sendEmailNotifications( Boolean affiliationsFromPortal ){
        
        //Send email notifications immediatly
        if (!emails.isEmpty() && !affiliationsFromPortal ) {
            System.debug('emails: ' + emails);
            Messaging.sendEmail(emails);
        }

        //Send email notifications using future method
        if( !emailWrapperMessage.isEmpty() &&  affiliationsFromPortal ) {
            String messageWrappers = JSON.serialize(emailWrapperMessage);
            sendAffiliationEmailNotificationsAsync(messageWrappers);
        }
    }

    /*
    *********************************************************
    @Method Name    : generateEmailTemplateMap
    @author         : Utthirakumar
    @description    : method is used to generate map for the emailTemplates.
    @return         : void
    ********************************************************
    */
    public static void generateEmailTemplateMap(){
        //fetch email templates related to Xiaflex notifications
        for (EmailTemplate template : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN ('Xiaflex_MDP_HCP_Affiliations', 'Xiaflex_MDP_HCS_Affiliations','Xiaflex_HCP_Updated_Affiliations', 'Xiaflex_HCS_Updated_Affiliations')]) {
            emailTemplateMap.put(template.DeveloperName, template.Id);
        }
    }

    /*
    *********************************************************
    @Method Name    : getEamilTemplateId
    @author         : Utthirakumar
    @description    : method is used to get the emailTemplate id dynamically based on programType and recordType.
    @param          : programType - value passed as REMS or MDP.
                      recordTypeId - dynamic recordTypeId of Affiliation.
    @return         : returns emailTemplateId
    ********************************************************
    */
    public static String getEamilTemplateId(String programType, String recordTypeId){
        //fetch the emailTemplateId based on programType and recordType
        String templateId;

        //HCS affiliations to send HCP notifications.
        if( recordTypeId == hcsAffiliationRecordTypeId ){
            if( programType == SYN_Utilitycls.REMS ){
                templateId = emailTemplateMap.get('Xiaflex_HCP_Updated_Affiliations');
            } else if( programType == SYN_Utilitycls.MDP ){
                templateId = emailTemplateMap.get('Xiaflex_MDP_HCP_Affiliations');
            }
        //HCP affiliations to send HCS notifications.    
        } else if( recordTypeId == prescriberAffiliationRecordTypeId ){
            if( programType == SYN_Utilitycls.REMS ){
                templateId = emailTemplateMap.get('Xiaflex_HCS_Updated_Affiliations');
            } else if( programType == SYN_Utilitycls.MDP ){
                templateId = emailTemplateMap.get('Xiaflex_MDP_HCS_Affiliations');
            }
        }
        return templateId;
    }

    /*
    *********************************************************
    @Method Name    : getFaxTemplateName
    @author         : Utthirakumar
    @description    : method is used to get the fax template name based on programType and recordType.
    @param          : programType - value passed as REMS or MDP.
                      recordTypeId - dynamic recordTypeId of Affiliation.
    @return         : returns Fax template name
    ********************************************************
    */
    public static String getFaxTemplateName(String programType, String recordTypeId){
        String templateName;
        //HCS affiliations to send HCP notifications.
        if( recordTypeId == hcsAffiliationRecordTypeId ){
            if( programType == SYN_Utilitycls.REMS ){
                templateName = 'XIAFLEX CONGA HCP Affiliate Notification';
            } else if( programType == SYN_Utilitycls.MDP ){
                templateName = 'XIAFLEX MDP CONGA HCP Affiliate Notify';
            }
        //HCS affiliations to send HCP notifications.
        } else if( recordTypeId == prescriberAffiliationRecordTypeId ){
            if( programType == SYN_Utilitycls.REMS ){
                templateName = 'XIAFLEX CONGA HCS Affiliate Notification';
            } else if( programType == SYN_Utilitycls.MDP ){
                templateName = 'XIAFLEX MDP CONGA HCS Affiliate Notify';
            }
        }
        return templateName;
    }

    /*
    *********************************************************
    @Method Name    : getOrgWideAddressesMap
    @author         : Utthirakumar
    @description    : method is used to retrieve all the org wide email addresses which are verified in the org.
    @param          : None
    @return         : returns Map of orgWideEmailAddresses
    ********************************************************
    */
    public static Map<String, OrgWideEmailAddress> getOrgWideAddressesMap(){
        //retrieves all the orgwideaddresses which are verified.
        Map<String, OrgWideEmailAddress> owaMap = new Map<String, OrgWideEmailAddress>();
        for(OrgWideEmailAddress owa : [ Select Id, Address, DisplayName from Orgwideemailaddress where Address != NULL AND IsVerified = TRUE ] ) {
            owaMap.put(owa.Address.toLowerCase(), owa);
        }
        return owaMap;
    }

    /*
    *********************************************************
    @Method Name    : sendAffiliationEmailNotificationsAsync
    @author         : Utthirakumar
    @description    : method is used to send email notifications by using future method.
                        - We are sending the emails in async approach for the affiliations which got created from portal. 
                        - We are assigning the default owner for all xiaflex portal records which is causing the issue due to the owner change while sending the eamil as either Guest User or portal site user.
                        - To avoid the error INVALID_CROSS_REFERENCE_KEY for the portal scenarios we used this async way to send the email. 
    @param          : messageWrappers - Serialized string of wrapper class which consists of Email message details.
    @return         : void
    ********************************************************
    */
    @future
    public static void sendAffiliationEmailNotificationsAsync(String messageWrappers){

        List<EmailMessageWrapper> deserializedWrapperMessages;
        //deserialize wrapper class collection instance
        if( !String.isBlank(messageWrappers) ) {
            deserializedWrapperMessages = (List<EmailMessageWrapper>)JSON.deserialize(messageWrappers, List<EmailMessageWrapper>.class);
        }
       
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        //prepare email messages from the wrapper class instance.
        for( EmailMessageWrapper emailWrap :  deserializedWrapperMessages ){
            Messaging.SingleEmailMessage email = prepareEmailMessage(emailWrap);
            emails.add(email);
        }
        
        //send email notifications
        if( emails.size() > 0 ) {
            Messaging.sendEmail(emails);
        }
    }

    /*
    *********************************************************
    @Method Name    : prepareEmailMessage
    @author         : Utthirakumar
    @description    : method is used to construct singleEmailMessage from the wrapper class.
    @param          : emailWrap - emailmessagewrapper class instance.
    @return         : returns singleEmailMessage instance
    ********************************************************
    */
    public static Messaging.SingleEmailMessage prepareEmailMessage( EmailMessageWrapper emailWrap ){
        //Construct the singleEmailMessage instance from the wrapper class instance
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(emailWrap.templateId);
        email.setWhatId(emailWrap.whatId);
        email.setTargetObjectId(emailWrap.targetObjectId);
        email.setTreatTargetObjectAsRecipient(false);
        email.setToAddresses(emailWrap.toAddresses);
        email.setBccAddresses(emailWrap.bccAddresses);
        email.setBccSender(false);
        email.setOrgWideEmailAddressId(emailWrap.orgWideId);
        return email;
    }

     /*
    *********************************************************
    @Method Name    : EmailMessageWrapper
    @author         : Utthirakumar
    @description    : EmailMessageWrapper class
    @param          : templateId - to hold the emailTemplateId value.
                      whatId - to hold the whatId value.
                      targetObjectId - to hold the targetObjectId value.
                      toAddresses - to hold the receipient addresses.
                      bccAddresses - to hold the bcc receipient addresses.
                      orgWideId - to hold the orgwideEmailAddress Id value.
    @return         : constructs single instance of the wrapper class.
    ********************************************************
    */
    public class EmailMessageWrapper {
        public string templateId { get; set; }
        public string whatId { get; set; }
        public string targetObjectId { get; set; }
        public List<string> toAddresses {get; set;}
        public List<string> bccAddresses {get; set;}
        public string orgWideId { get; set; }
        public EmailMessageWrapper( String templateId, String whatId, String targetObjectId, List<String> toAddresses, List<String> bccAddresses, String orgWideId ){
            this.templateId = templateId;
            this.whatId = whatId;
            this.targetObjectId = targetObjectId;
            this.toAddresses = toAddresses;
            this.bccAddresses = bccAddresses;
            this.orgWideId = orgWideId;
        }
    }

}