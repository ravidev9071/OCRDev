/**
* @File Name          : MACIAutomationCommunicationUtility.cls
* @Description        : This is used as a email automation handler for MACI.
* @Trigger            : SYN_RemsServiceSummaryTrigger
* @TestClass          : MACIAutomationCommunicationUtilityTest
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date              Developer                         Modification
* 1.0       04/01/2023        Praveen V (Wilco)     ' Implementation: //BT7433- 426,420, 442,429, 440 - SP13
* 2.0       16/02/2023        Praveen V (Wilco)      Added status field to the custom metadata unique key. BT7433- 430, 441,433
                                                     SendNotifications() - Line:106; 108; 110; 112; 116; 118
                                                     getEmailTemplateName() - Line 194
                                                     if condition checks in the maciEmailAutomationCommunication() -entry criterias
**/
public class MACIAutomationCommunicationUtility {
    
    Public Static Map<String,REMS_Correspondence_Settings__mdt> programTemplates;
    Public Static Map<Id,Date> patientAccIdvsDisenrollCaseRecMap;
    
    /***********************************************************************************
     Method Name: maciEmailAutomationCommunication - Params: rssList - Trigger.New of REMS Service Record; rssMap: Old map of REMS Service record.
     description: This method is used to collect REMS Service record Ids and query the cases under it, based on the conditions collect the cases to a list and 
                  process them to the sendNotification method which is used to send emails.
     return:      NA.
    ************************************************************************************/
    public static void maciEmailAutomationCommunication(List<US_WSREMS__REMS_Service_Summary__c> rssList,  Map<Id, US_WSREMS__REMS_Service_Summary__c> rssMap){     
        
        Set<Id> rssIdSet = new Set<Id>();
        Set<Id> disEnrollCasePatientIdSet = new Set<Id>();
        List<Case> casesListUnderREMSService = New List<Case>();
        List<Case> finalCaseListToSendEmails = New List<Case>();
         List<Case> finalCaseListToSendFax = New List<Case>();
        patientAccIdvsDisenrollCaseRecMap = new Map<Id,Date>();
        String Patient='Patient';
        String Enrolled='Enrolled';
        String Prescriber='Prescriber';
        String Certified='Certified';
        
        Id enrollServiceRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Enrollment');   
        Id changeinReproServiceRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');
        Id RDAServiceRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Pre_Dispense_Authorization');
        Id patientDisEnrollRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Disenrollment');
        
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        Id pharmacyEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Pharmacy_Enrollment');
        Id patientEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');
        Id outpatientPharmacyEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Outpatient_Pharmacy');
        Id inpatientPharmacyEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Inpatient_Pharmacy');
        Id distributorEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Distributor_Enrollment');
        Id changeInReproPotentialStatusCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');
        Id rdaCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'PDA');
        Id disenrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Deactivation');
        Id reverseRdaCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Reverse_RDA');
        
        for(US_WSREMS__REMS_Service_Summary__c rss: rssList){
            //BT7433- 426,420, 442,429, 440 - SP13
            if(rss.US_WSREMS__Service_Outcome__c == 'Successful' && rss.US_WSREMS__Status__c == 'Closed' && rssMap.get(rss.Id).US_WSREMS__Service_Outcome__c != 'Successful' && rss.Program_Name__c == 'Macitentan REMS'    
               && (((rss.US_WSREMS__Requestor_Type__c == 'Patient' || rss.US_WSREMS__Requestor_Type__c == 'Prescriber' || rss.US_WSREMS__Requestor_Type__c == 'Pharmacy' || rss.US_WSREMS__Requestor_Type__c == 'Distributor') && rss.RecordTypeId == enrollServiceRecTypeId)
                   || (rss.RecordTypeId == changeinReproServiceRecTypeId && rss.US_WSREMS__Requestor_Type__c == 'Prescriber') 
                   || (rss.RecordTypeId == patientDisEnrollRecTypeId && rss.US_WSREMS__Requestor_Type__c == 'Patient') )){
                       rssIdSet.add(rss.Id);    
                   }

            if(rss.US_WSREMS__Service_Outcome__c == 'Successful' && rss.US_WSREMS__Status__c == 'Closed' && rssMap.get(rss.Id).US_WSREMS__Service_Outcome__c != 'Successful'
               && rss.RecordTypeId == RDAServiceRecTypeId && rss.US_WSREMS__Requestor_Type__c == 'Pharmacy' && rss.Program_Name__c == 'Macitentan REMS'){
                   rssIdSet.add(rss.Id);  
            }
            
            //BT7433- 441...
            if(rss.US_WSREMS__Service_Outcome__c == 'Reversed' && rss.US_WSREMS__Status__c == 'Closed' && rssMap.get(rss.Id).US_WSREMS__Service_Outcome__c != 'Reversed' 
               && rss.Program_Name__c == 'Macitentan REMS' && rss.RecordTypeId == RDAServiceRecTypeId && rss.US_WSREMS__Requestor_Type__c == 'Pharmacy'){
                       rssIdSet.add(rss.Id); 
               }
            
        }
        
        if(!rssIdSet.isEmpty()){
            casesListUnderREMSService = [SELECT Id,recordTypeId,RecordType.DeveloperName,Status,US_WSREMS__Outcome__c,ownerId,US_WSREMS__Program_Name__c,US_WSREMS__Program_Picklist__c,
                                         SYN_Authorized_Rep__c,SYN_Authorized_Rep__r.US_WSREMS__Email__c,SYN_Authorized_Rep__r.US_WSREMS__Status__c,SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Preferred_Contact_Method__c,
                                         SYN_Prescriber__c,SYN_Prescriber__r.Email_address__c,SYN_Prescriber__r.US_WSREMS__Status__c,US_WSREMS__Distributor__c,SYN_Prescriber__r.Fax,SYN_Prescriber__r.US_WSREMS__Email__c,
                                         US_WSREMS__Distributor__r.US_WSREMS__Email__c,Pharmacy_Participant__c,Pharmacy_Participant__r.US_WSREMS__Email__c,
                                         US_WSREMS__Patient__r.US_WSREMS__Status__c,US_WSREMS__REMS_Service_Summary__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c,
                                         US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Participant__r.US_WSREMS__Status__c,Email_address__c,US_WSREMS__Participant__c,
                                         US_WSREMS__Participant__r.US_WSREMS__Status__c,US_WSREMS__Deactivation_Date__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c,US_WSREMS__Channel__c,Incomplete_Reasons__c,US_WSREMS__Email__c,X1_Pharmacy_Participant__c,X1_Pharmacy_Participant__r.US_WSREMS__Email__c  FROM Case WHERE US_WSREMS__REMS_Service_Summary__c IN: rssIdSet];
        }
        
        if(!casesListUnderREMSService.isEmpty()){
            for(Case cs:casesListUnderREMSService){
                if(cs.US_WSREMS__Program_Picklist__c == 'Macitentan REMS'){
                    //BT7433- 426,420, 442,429, 440 - SP13
                    // Below conditions: 1. Patient condition combo; 2. Prescriber condition combo;3. Inpatient/Outpatient condition combo; 4. Distributor condition; 
                    // 5. Change in reproductive status 6. RDA.
                    if(cs.Status == 'Complete' && cs.US_WSREMS__Channel__c != 'Migration' && String.isNotBlank(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c)){

                            
                            
                            if(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c == Patient  && cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Participant__r.US_WSREMS__Status__c == Enrolled && cs.RecordTypeId == patientEnrollCaseRecTypeId && String.isNotBlank(cs.SYN_Prescriber__c) && String.isNotBlank(cs.SYN_Prescriber__r.Email_address__c))
                            {
                                String result = checkEmailOrFax(cs.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c, cs.SYN_Prescriber__r.Fax, cs.SYN_Prescriber__r.Email_address__c, cs.US_WSREMS__Channel__c);
                                if(result == 'SendEmail' ){
                                    finalCaseListToSendEmails.add(cs);
                                }
                                else if(result == 'SendFax'){               
                                    finalCaseListToSendFax.add(cs);
                                }
                            }
                        
                            if(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c == Prescriber && String.isNotBlank(cs.SYN_Prescriber__c) && String.isNotBlank(cs.SYN_Prescriber__r.Email_address__c) && ((cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Participant__r.US_WSREMS__Status__c == Certified && cs.RecordTypeId == prescriberEnrollCaseRecTypeId) || cs.RecordTypeId == changeInReproPotentialStatusCaseRecTypeId )){
                                
                                String result = checkEmailOrFax(cs.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c, cs.SYN_Prescriber__r.Fax, cs.SYN_Prescriber__r.Email_address__c, cs.US_WSREMS__Channel__c);
                                if(result == 'SendEmail' ){
                                    finalCaseListToSendEmails.add(cs);
                                }else if(result == 'SendFax'){  
                                    finalCaseListToSendFax.add(cs);
                                }
                            }
                            
                            if(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c == 'Pharmacy' && cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Participant__r.US_WSREMS__Status__c == 'Certified' && cs.SYN_Authorized_Rep__c != null && cs.SYN_Authorized_Rep__r.US_WSREMS__Email__c != null && cs.SYN_Authorized_Rep__r.US_WSREMS__Status__c == 'Active' && (cs.RecordTypeId == outpatientPharmacyEnrollCaseRecTypeId || cs.RecordTypeId == inpatientPharmacyEnrollCaseRecTypeId)){
                                
                                    finalCaseListToSendEmails.add(cs);
                            }
                            
                            if(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c == 'Pharmacy' && cs.RecordTypeId == rdaCaseRecTypeId && cs.Pharmacy_Participant__c != null && cs.Pharmacy_Participant__r.US_WSREMS__Email__c != null && cs.US_WSREMS__Outcome__c == 'Approved' && cs.US_WSREMS__Channel__c != 'Portal'){
                                
                                finalCaseListToSendEmails.add(cs);
                            }
                            
                            if(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c == 'Pharmacy' && cs.RecordTypeId == reverseRdaCaseRecTypeId && cs.X1_Pharmacy_Participant__c != null && cs.X1_Pharmacy_Participant__r.US_WSREMS__Email__c != null && cs.US_WSREMS__Outcome__c == 'Complete'){
                                
                                finalCaseListToSendEmails.add(cs);
                            }
                            if(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c == 'Distributor' && cs.RecordTypeId == distributorEnrollCaseRecTypeId && cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Participant__r.US_WSREMS__Status__c == 'Certified' &&  cs.US_WSREMS__Distributor__r.US_WSREMS__Email__c != null){
                                
                                finalCaseListToSendEmails.add(cs);
                            }
                            
                    
                    }
                    //BT7433-433
                    if(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Participant__r.US_WSREMS__Status__c == 'Disenrolled' && cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c == 'Patient' &&
                       cs.RecordTypeId == disenrollCaseRecTypeId && cs.US_WSREMS__Participant__c != null && cs.Status == 'Complete'){
                           disEnrollCasePatientIdSet.add(cs.US_WSREMS__Participant__c);
                           patientAccIdvsDisenrollCaseRecMap.put(cs.US_WSREMS__Participant__c,cs.US_WSREMS__Deactivation_Date__c);
                       }//BT7433-433 story
                   
                } //End of program if...
            } //End of case for loop...
            
            //BT7433-433
            if(!disEnrollCasePatientIdSet.isEmpty()){
                sendPatientDisenrollmentEmail(disEnrollCasePatientIdSet);
            }//BT7433-433
            
            if(!finalCaseListToSendEmails.isEmpty()){
                sendNotification(finalCaseListToSendEmails);
            }
            
            if(!finalCaseListToSendFax.isEmpty()){
                sendFaxNotification(finalCaseListToSendFax);
            }
        } //End of null check if       
    }
    
    /***********************************************************************************
     Method Name: sendNotification() - Params: caseList - Final case list that the email should trigger to; template data.
     description: This method consists of code that will send an email to the stakeholders, custom metadata call to collect the template name, get the details needed from 
                  the custom metadata by using the unique key forming here dynamically that matches the field values in the metadata.
     return:      NA.
    ************************************************************************************/
    
    public static void sendNotification(List<Case> caseList){
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        //Get the correspondence metadata recs to the emailTemplateMap...
        Map<String,String> emailTemplateMap = getEmailTemplateName();
        //Get the Map of template devname vs Id from getEmailTemplateIds()...
        Map<String,String> emailTemplateIdMap = getEmailTemplateIds(emailTemplateMap);
        //get a dummy contact from the database for targetObjID...
        Contact con = getContact();
        
        for(case cs : caseList){
            if(cs.US_WSREMS__REMS_Service_Summary__c != null && cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c != null 
               && programTemplates.containsKey(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email') ){
                   // Template Name
                   String templateName = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email').Template_Name__c;
                   // Get the To Address
                  List<String> toAddresses = new List<String>();
                    List<String> emailSet  = new List<String>();
                emailSet = sendEmailNotificationToOffCon(caseList);

                   String toaddress = '';
                   String toaddressValue = '';
                   String relationshipField = '';
                   
                   //To address will be picked from case if the emails are missing info emails...
                   //Else... they will be picked from the account.
                   if(cs.Incomplete_Reasons__c != null && cs.Status == 'Draft'){
                       toaddress = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email').Recipient_Email_Field__c;
                       toaddressValue = (String) cs.get(toaddress);
                       toAddresses.add(toaddressValue);
                   }else{
                       relationshipField = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email').Relationship_Field__c;
                       toaddress = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email').Recipient_Email_Field__c;
                       toaddressValue = (String) cs.getSobject(relationshipField).get(toaddress);
                       toAddresses.add(toaddressValue);
                   }  
                   
                    toAddresses.addAll(emailSet);
                 
                   // Get the Bcc Address
                   List<String> BccAddress = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email').BCC_Email__c.Split(',');                   
                   // Get the FROM Address 
                   String fromAddress = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Email').From__c;
                   
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
                   if(con!=null)
                   mail.setTargetObjectId(con.id);
                   mail.setTreatTargetObjectAsRecipient(false);
                       mail.setOrgWideEmailAddressId(fromAddress);
                   emailMessageList.add(mail);
               } //End of If...
        }
        if(!emailMessageList.isEmpty()){
            triggerEmailsToRecipients(emailMessageList);
        }
        
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
    
    // Get email template with requestor type from custom Metadata 
    public static Map<String,String> getEmailTemplateName(){
        programTemplates = new Map<String,REMS_Correspondence_Settings__mdt>();
        Map<String,String> templateMap = new Map<String,String>();
        
        for(REMS_Correspondence_Settings__mdt crsd : [SELECT Id, DeveloperName, MasterLabel, Active__c, Conga_Attachment_Template__c, From__c, Object_Name__c,
                                                      Product__c, Program_Configuration__c,Program_Configuration__r.MasterLabel, Recipient_Email_Field__c, 
                                                      Recipient_Type__c, Template_Name__c, Type__c,Record_Type_Developer_Name__c,BCC_Email__c,Relationship_Field__c,
                                                      Case_Status__c,Service_Status__c FROM REMS_Correspondence_Settings__mdt 
                                                      WHERE Active__c = TRUE  AND Program_Configuration__r.MasterLabel = 'Macitentan REMS']){
                                                          
                                                          templateMap.put(crsd.Template_Name__c,crsd.Recipient_Type__c);
                                                          programTemplates.put(crsd.Recipient_Type__c+''+crsd.Program_Configuration__r.MasterLabel+''+crsd.Record_Type_Developer_Name__c+''+crsd.Case_Status__c+''+crsd.Service_Status__c+''+crsd.Type__c,crsd);
                                                          
                                                      }        
        return templateMap;
    }
    
    // get email template based on before map
    Public Static Map<String,String> getEmailTemplateIds(Map<String,String> templateMap){
        Map<String,String> templateIdMap = new Map<String,String>();
        for(EmailTemplate temp :[Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate where DeveloperName =: templateMap.keySet()]){
            templateIdMap.put(temp.DeveloperName,temp.Id);
        }
        return templateIdMap;
    }
     /***********************************************************************************
     Method Name: sendPatientDisenrollmentEmail() - Params: caseList - Final case list that the email should trigger to; template data.BT7433-433
     description: This method consists of code that will send an email to the stakeholders, custom metadata call to collect the template name, get the details needed from 
                  the custom metadata by using the unique key forming here dynamically that matches the field values in the metadata.
     return:      NA.
    ************************************************************************************/
    public static void sendPatientDisenrollmentEmail(Set<Id> disEnrollCasePatientIdSet){
        Id patientEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');
        Id deactivationCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Deactivation');
        List<Case> updateDeactivationDateOnCaseList = New List<Case>();
        List<Case> finalCaseListToSendEmails = New List<Case>();
        List<Case> finalCaseListToSendFax = New List<Case>();
        
        List<Case> patientEnrollmentCaseList = [SELECT Id,recordTypeId,RecordType.DeveloperName,Status,US_WSREMS__Outcome__c,ownerId,US_WSREMS__Program_Name__c,US_WSREMS__Program_Picklist__c,
                                                SYN_Prescriber__c,SYN_Prescriber__r.Email_address__c,SYN_Prescriber__r.US_WSREMS__Status__c,US_WSREMS__Patient__r.US_WSREMS__Status__c,
                                                US_WSREMS__REMS_Service_Summary__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Participant__r.US_WSREMS__Status__c,
                                                Email_address__c,US_WSREMS__Participant__c,US_WSREMS__Participant__r.US_WSREMS__Status__c,US_WSREMS__Deactivation_Date__c, SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Channel__c,SYN_Prescriber__r.Fax,
                                                Patient_Name_Initials__c, US_WSREMS__DOB__c,Participant_REMS_ID_Num__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c,Incomplete_Reasons__c FROM Case WHERE US_WSREMS__Participant__c IN: disEnrollCasePatientIdSet];
        
        if(!patientEnrollmentCaseList.isEmpty()){
            for(Case cs:patientEnrollmentCaseList){
                if(cs.RecordTypeId == patientEnrollCaseRecTypeId && cs.Status == 'Complete' && 
                   cs.SYN_Prescriber__c != null && cs.SYN_Prescriber__r.Email_address__c != null){
                       
                       if(patientAccIdvsDisenrollCaseRecMap.containsKey(cs.US_WSREMS__Patient__c)){
                           cs.US_WSREMS__Deactivation_Date__c =  patientAccIdvsDisenrollCaseRecMap.get(cs.US_WSREMS__Patient__c);  
                           //Add to the list so that this date can be updated on the enrollment case record...
                           updateDeactivationDateOnCaseList.add(cs);
                       }
                       
                   }
            }//For loop end...
            
            if(!updateDeactivationDateOnCaseList.isEmpty()){
                try{
                    //Update the patient enrollment case here...
                    Update updateDeactivationDateOnCaseList;
                    //Actual loop to send the email by adding it to the case list...
                    for(Case cs:updateDeactivationDateOnCaseList){
                        if(cs.RecordTypeId == patientEnrollCaseRecTypeId && cs.Status == 'Complete' && 
                           cs.SYN_Prescriber__c != null && cs.SYN_Prescriber__r.Email_address__c != null){
                               //Temp assignment here such that it will pick the Disenroll template in the custom metadata...
                               cs.RecordTypeId = deactivationCaseRecTypeId;
                               cs.RecordType.DeveloperName = 'Deactivation';
                               String result = checkEmailOrFax(cs.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c, cs.SYN_Prescriber__r.Fax, cs.SYN_Prescriber__r.Email_address__c, cs.US_WSREMS__Channel__c);
                                if(result == 'SendEmail' ){
                                    finalCaseListToSendEmails.add(cs);
                                }else if(result == 'SendFax'){  
                                    finalCaseListToSendFax.add(cs);
                                }
                               
                           }
                    }
                    
                }catch (exception e){
                    system.debug('----Error-updateEnroll Case With Deacti Date-----'+e.getMessage());
                }
            }
            //finalCaseListToSendEmails - Final list of cases to send the email notifications...
            if(!finalCaseListToSendEmails.isEmpty()){
                sendNotification(finalCaseListToSendEmails);
            }
            if(!finalCaseListToSendFax.isEmpty()){
                sendFaxNotification(finalCaseListToSendFax);
            }
        }//End of If check...
        
    }

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
        //Get contact...
        Contact con = getContact();
        //EmailTemplate...
        template = [Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate WHERE DeveloperName =: requestList[0].templateName];
        //Org-wide Email...
        owa = [select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: requestList[0].fromAddress];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setBccAddresses(BccAddresses);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(true);
        mail.setWhatId(requestList[0].accountId);
        mail.setTemplateId(template.Id);
        if(con!=null)
        mail.setTargetObjectId(con.Id);
        mail.setTreatTargetObjectAsRecipient(false);
        if(owa != null){
            mail.setOrgWideEmailAddressId(owa.Id);
        }
        
        emailMessageList.add(mail);
        
        if(!emailMessageList.isEmpty()){
            triggerEmailsToRecipients(emailMessageList);
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

    //BT-9433-421;423...
     
    public static void getReportableEventFormMACI(List<Case> caseList){
        
        Id paePCCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'PAE_PC_MI');
        Set<Id> caseIds = New Set<Id>();
        Set<Id> caseIds1 = New Set<Id>();
        
        for(Case cs:caseList){
            if(cs.RecordTypeId == paePCCaseRecTypeId && cs.US_WSREMS__Program_Name__c == 'Macitentan REMS' && 
               cs.US_WSREMS__Outcome__c == 'Acknowledgment Pending' && cs.Status == 'Complete' && 
               cs.SYN_Type_of_Report__c != 'Pregnancy' && cs.SYN_Type_of_Report__c != 'Pregnancy w/ Adverse Event'){            
                   //BT7433-421...
                   caseIds.add(cs.Id);
               }
            //Pregnancy form VF...
            if(cs.RecordTypeId == paePCCaseRecTypeId && cs.US_WSREMS__Program_Name__c == 'Macitentan REMS' && 
               cs.US_WSREMS__Outcome__c == 'Acknowledgment Pending' && cs.Status == 'Complete' && 
               (cs.SYN_Type_of_Report__c == 'Pregnancy' || cs.SYN_Type_of_Report__c == 'Pregnancy w/ Adverse Event')){
                   //BT7433-423...
                   caseIds1.add(cs.Id);
               }
            
        }
        //Reportable event form VF....
        if(caseIds.size() > 0){
            sendEmailForPAEPCReportableFormEventMACI(caseIds);
        }
        //Pregnancy Form VF...
        if(caseIds1.size() > 0){
           sendEmailForPAEPCPregnancyEventFormMACI(caseIds1); 
        }        
    }
    
    //BT7433-- 421...
    @future(Callout=true)
    public static void sendEmailForPAEPCReportableFormEventMACI(Set<Id> caseIds){
        
        List<Attachment> attachList = New List<Attachment>();
        List<Case> updateCaseList = New List<Case>();
        Map<Id,Id> caseIdmap = new Map<Id,Id>();
        Map<Id,Attachment> caseIdVSvfattachmentIdmap = new Map<Id,Attachment>();
        
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        //Template,,
        EmailTemplate template = new EmailTemplate();
        template = [Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate WHERE DeveloperName = 'Potential_Adverse_Event_PAE_Product_Complaint_PC_Medical_Inquiry_MI_No'];
        //To address...
        List<String> toAddresses = Label.PAEPCEmailRecipientsMACI.Split(',');
        //BCC address...
        List<String> BccAddresses = New List<String>();
        BccAddresses.add(label.RemsSupportEmail); 
        //contact for targetObjId...
        Contact con = MACIAutomationCommunicationUtility.getContact();
        //Org-wide Email...
        OrgWideEmailAddress owa = New OrgWideEmailAddress();
        if(Test.isRunningTest()){
         owa = [select id, Address, DisplayName from OrgWideEmailAddress limit 1];
        }else{
        owa = [select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: Label.MACIToAddress];
        }
        List<string> emailAttachmentIDs = New List<string>();
        
        if(caseIds.size() > 0){
            for(String csId:caseIds){
                
                PageReference pageRef= Page.Maci_Reportable_Form;
                pageRef.getParameters().put('Id',csId);
                Attachment attach = new Attachment();
                attach.ParentId = csId;
                attach.name = 'Reportable Event form.pdf';
                if(Test.isRunningTest()) { 
                    attach.body = blob.valueOf('Unit.Test');
                } else {
                    attach.body = pageRef.getContent();
                }
                attachList.add(attach);
            }
        }
        try{
            
            insert attachList;
            if(attachList.size()>0){
                for(Attachment at: attachList){
                    caseIdVSvfattachmentIdmap.put(at.ParentId,at);
                }
            }
            //Code start to get the uploaded files and add to the emailattachmentids set...
            set<Id> contentDocumentIds = New Set<Id>();
            Map<Id,Case> serviceIdvsCaseRecord = new Map<Id,Case>();
            List<ContentDocumentLink> contentDocumentLinkList = New List<ContentDocumentLink>();
            List<ContentVersion> cvsList = New List<ContentVersion>();
            List<Case> existingCaseRecord = [SELECT Id,US_WSREMS__REMS_Service_Summary__c FROM Case WHERE US_WSREMS__REMS_Service_Summary__c != null AND Id IN:caseIds ];
            //Collect rems service from existing case Ids...
            if(existingCaseRecord.size()>0){
                for(Case cs:existingCaseRecord){
                    serviceIdvsCaseRecord.put(cs.US_WSREMS__REMS_Service_Summary__c,cs);
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
            if(caseIdVSvfattachmentIdmap!=null){
                for(Case cs:existingCaseRecord){
                    if(caseIdVSvfattachmentIdmap.containsKey(cs.Id)){
                        if(caseIdVSvfattachmentIdmap.get(cs.Id).parentId == cs.Id){
                            emailAttachmentIDs.add(caseIdVSvfattachmentIdmap.get(cs.Id).Id); //collect attachment Ids....
                            //Add contentVersionIds to email attachmentIds List...
                            if(cvsList.size()>0){
                                for(contentDocumentLink cl :contentDocumentLinkList){
                                    for(ContentVersion cv:cvsList){
                                        if(cs.US_WSREMS__REMS_Service_Summary__c == cl.LinkedEntityId && cl.ContentDocumentId == cv.ContentDocumentId){
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
                            //mail.setFileAttachments(emailAttachmentsList);
                            if(emailAttachmentIDs != null)
                            mail.setEntityAttachments(emailAttachmentIDs);
                            emailMessageList.add(mail);
                        }
                    }
                }
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
    
    //BT7433-- 423...
    @future(Callout=true)
    public static void sendEmailForPAEPCPregnancyEventFormMACI(Set<Id> caseIds){
        
        List<Attachment> attachList = New List<Attachment>();
         List<Attachment> attachList2 = New List<Attachment>();
        List<Case> updateCaseList = New List<Case>();
        Map<Id,Id> caseIdmap = new Map<Id,Id>();
        Map<Id,Attachment> caseIdVSvfattachmentIdmap = new Map<Id,Attachment>();
        Map<Id,Attachment> caseIdVSvfattachmentIdmap2 = new Map<Id,Attachment>();
        
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        //Template,,
        EmailTemplate template = new EmailTemplate();
        template = [Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate WHERE DeveloperName = 'Patient_Pregnancy_Notification'];
        //To address...
        List<String> toAddresses = Label.PAEPCEmailRecipientsMACI.Split(',');
        //BCC address...
        List<String> BccAddresses = New List<String>();
        BccAddresses.add(label.RemsSupportEmail); 
        //contact for targetObjId...
        Contact con = MACIAutomationCommunicationUtility.getContact();
        //Org-wide Email...
        OrgWideEmailAddress owa = New OrgWideEmailAddress();
         if(Test.isRunningTest()){
         owa = [select id, Address, DisplayName from OrgWideEmailAddress limit 1];
        }else{
        owa = [select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: Label.MACIToAddress];
        }
        List<string> emailAttachmentIDs = New List<string>();
        
        if(caseIds.size() > 0){
            for(String csId:caseIds){
                
                PageReference pageRef= Page.Maci_Reportable_Form;
                pageRef.getParameters().put('Id',csId);
                Attachment attach = new Attachment();
                attach.ParentId = csId;
                attach.name = 'Reportable Event form.pdf';
                if(Test.isRunningTest()) { 
                    attach.body = blob.valueOf('Unit.Test');
                } else {
                    attach.body = pageRef.getContent();
                }
                
                attachList.add(attach);
            }
        }
        try{
            
            insert attachList;
            if(attachList.size()>0){
                for(Attachment at: attachList){
                    caseIdVSvfattachmentIdmap.put(at.ParentId,at);
                }
            }
            
            // Create another attachment from VF page....
             for(String csId:caseIds){
                
                PageReference pageRef= Page.Maci_Pregnancy_Intake_Form;
                pageRef.getParameters().put('Id',csId);
                Attachment attach = new Attachment();
                attach.ParentId = csId;
                attach.name = 'Pregnancy Intake form.pdf';
                if(Test.isRunningTest()) { 
                    attach.body = blob.valueOf('Unit.Test');
                } else {
                    attach.body = pageRef.getContent();
                }
                
                attachList2.add(attach);
            }
            
            try{
                insert attachList2;
                if(attachList2.size()>0){
                    for(Attachment at: attachList2){
                        caseIdVSvfattachmentIdmap2.put(at.ParentId,at);
                    }
                }
            }catch(DmlException e) {
                System.debug('The following exception has occurred 423 VF2: ' + e.getMessage());
            } 
            
            //Code start to get the uploaded files and add to the emailattachmentids set...
            set<Id> contentDocumentIds = New Set<Id>();
            Map<Id,Case> serviceIdvsCaseRecord = new Map<Id,Case>();
            List<ContentDocumentLink> contentDocumentLinkList = New List<ContentDocumentLink>();
            List<ContentVersion> cvsList = New List<ContentVersion>();
            List<Case> existingCaseRecord = [SELECT Id,US_WSREMS__REMS_Service_Summary__c FROM Case WHERE US_WSREMS__REMS_Service_Summary__c != null AND Id IN:caseIds ];
            //Collect rems service from existing case Ids...
            if(existingCaseRecord.size()>0){
                for(Case cs:existingCaseRecord){
                    serviceIdvsCaseRecord.put(cs.US_WSREMS__REMS_Service_Summary__c,cs);
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
            
            if(caseIdVSvfattachmentIdmap!=null && caseIdVSvfattachmentIdmap2 != null){
                for(Case cs:existingCaseRecord){
                    if(caseIdVSvfattachmentIdmap.containsKey(cs.Id) && caseIdVSvfattachmentIdmap2.containsKey(cs.Id)){
                        if(caseIdVSvfattachmentIdmap.get(cs.Id).parentId == cs.Id && caseIdVSvfattachmentIdmap2.get(cs.Id).parentId == cs.Id){
                            emailAttachmentIDs.add(caseIdVSvfattachmentIdmap.get(cs.Id).Id); //collect attachment Ids.... VF1
                            emailAttachmentIDs.add(caseIdVSvfattachmentIdmap2.get(cs.Id).Id); //collect attachment Ids.... VF2
                             //Add contentVersionIds to email attachmentIds List...
                            if(cvsList.size()>0){
                                for(contentDocumentLink cl :contentDocumentLinkList){
                                    for(ContentVersion cv:cvsList){
                                        if(cs.US_WSREMS__REMS_Service_Summary__c == cl.LinkedEntityId && cl.ContentDocumentId == cv.ContentDocumentId){
                                            emailAttachmentIDs.add(cv.Id);   //collect ContentVersion Ids....
                                        }
                                    }
                                }
                            }
                            
                            //Prepare to send an email....
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
                            emailMessageList.add(mail);
                        }
                    }
                }
            }
            
            
            
            try{
                if(emailMessageList != null){
                    MACIAutomationCommunicationUtility.triggerEmailsToRecipients(emailMessageList);
                }
            }catch(DmlException e) {
                System.debug('The following exception has occurred 423: ' + e.getMessage());
            } 
        }catch(DmlException e) {
            System.debug('The following exception has occurred 423: ' + e.getMessage());
        }  
    }
    
    public static void sendFaxNotification(List<Case> caseList){
            
        Id PrescriberEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        Id PatientEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');
        Id changeInReproPotentialStatusCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');
         Map<String,String> emailTemplateMap = getEmailTemplateName();
            List<REMS_Outbound_Communication__c> communicationRecList=new List<REMS_Outbound_Communication__c>();
           
            for(case cs : caseList){
                 if(cs.US_WSREMS__REMS_Service_Summary__c != null && cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c != null 
                   && programTemplates.containsKey(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Fax') ){
                       // Template Name
                       String templateName = programTemplates.get(cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c+''+cs.US_WSREMS__Program_Name__c+''+cs.RecordType.DeveloperName+''+cs.Status+''+cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c+'Fax').Template_Name__c;
                       // Get the To Address
                       if(cs.RecordTypeId == PrescriberEnrollmentCaseRecTypeId && cs.Status=='Draft'){
                         communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(cs,'Fax',label.FAX_Prescriber_Enrollment_Missing_Info));  
                       }else if(cs.RecordTypeId == PatientEnrollmentCaseRecTypeId && cs.Status=='Draft'){
                         communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(cs,'Fax',label.Fax_Patient_Enrollment_Missing_Info_Day1));  
                       }
                       else if(cs.RecordTypeId == changeInReproPotentialStatusCaseRecTypeId && cs.Status=='Draft'){
                         communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(cs,'Fax',label.FAX_CRPS_Pre_pubertal_Missing_Info));  
                       }
                       else {
                    communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(cs,'Fax',templateName));
                    }
                   }
                   
    
        }

        if(communicationRecList!=null && !communicationRecList.isEmpty()){
            try{
            insert communicationRecList;
            }catch(Exception e){
                system.debug('exception::'+e.getMessage());   
            }
        }
    }
    
    public static String checkEmailOrFax(String prefContactMethod, String Fax, String Email, String Channel){
    
        String result = '';
        if((prefContactMethod == 'Fax' || prefContactMethod == 'Phone' ||  String.isBlank(prefContactMethod) || string.isEmpty(prefContactMethod))) 
        {                    
            if(Fax != NULL && Fax != label.InValid_FAX ){
            result = 'SendFax';
            }
            else if((Fax == NULL || Fax == label.InValid_FAX) && String.isNotBlank(Email)){
             result = 'SendEmail';
            } 
           
        }   
        else if(prefContactMethod == 'Email')
        {
            if(String.isNotBlank(Email) && Email !=label.DataMigrationSupportEmail && Email !=label.RemsSupportEmail)
            {    
             result = 'SendEmail';
            }
            else if(Fax != NULL && Fax != label.InValid_FAX)
            {
                result = 'SendFax';
            }  
            else{ 
                 result = 'SendEmail';
            }
        }
        else{
            result='';
        }
        
        return result;
    }
     public static List<String> sendEmailNotificationToOffCon(List<Case> caseList){
         set<Id> prescriberId = New set<id>();
         List<String> emailSet  = new List<String>();
         list<US_WSREMS__Affiliation__c> affList = new list<US_WSREMS__Affiliation__c>();
        Id PrescriberEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        Id PatientEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');
        Id changeInReproPotentialStatusCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');
        for(case c:caseList){
            if(c.RecordTypeId ==PatientEnrollmentCaseRecTypeId ){
            
            prescriberId.add(c.SYN_Prescriber__c);
            }
        }
        affList =[SELECT ID,Office_Contact__c,Notifications__c,Office_Contact__r.US_WSREMS__Email__c,US_WSREMS__Prescriber__c from US_WSREMS__Affiliation__c where US_WSREMS__Prescriber__c IN:prescriberId AND Office_Contact__c!=NULL];
        for(US_WSREMS__Affiliation__c aff :affList){
            if(aff.Notifications__c == 'Opt-in')
            emailSet.add(aff.Office_Contact__r.US_WSREMS__Email__c);
        }
        return emailSet;
    }
}