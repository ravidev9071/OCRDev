/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-20-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Tryvio_CorrespondenceHandler {

    @InvocableMethod(label = 'Send Notification' description='Send Notification')
    public static void stakeholderNotifications(List<Id> listIds){
        String sObjName = listIds[0].getSObjectType().getDescribe().getName();
        
        If(sobjName == 'US_WSREMS__Assessment_Submission__c'){
            stakeholderKnowledgeAssessment(listIds);
        }
        else if(sobjName == 'Case'){
            stakeholderNotification(listIds);
        }
    }
    
    public static void stakeholderKnowledgeAssessment(List<Id> listKAS){
        List<Id> listPrescriberContactIds = new List<Id>();     
        List<Id> listPrescriberIds = new List<Id>();         
        
        String strTemplateName = '';
        List<US_WSREMS__Assessment_Submission__c> listAS = [SELECT Id,US_WSREMS__Case__r.US_WSREMS__Participant__c,US_WSREMS__Case__r.US_WSREMS__Participant__r.PersonContactId, US_WSREMS__Case__r.US_WSREMS__Participant__r.US_WSREMS__Email__c,US_WSREMS__Case__r.US_WSREMS__Channel__c , US_WSREMS__Assessment_Result__c,US_WSREMS__Total_Number_of_Attempts__c FROM US_WSREMS__Assessment_Submission__c WHERE Id IN: listKAS and US_WSREMS__Assessment_Result__c != ''] ;
        for(US_WSREMS__Assessment_Submission__c asRec : listAS){
            if(asRec.US_WSREMS__Case__r.US_WSREMS__Participant__c != null){
                listPrescriberContactIds.add(asRec.US_WSREMS__Case__r.US_WSREMS__Participant__r.PersonContactId);
                listPrescriberIds.add(asRec.US_WSREMS__Case__c);
            }            
            
            if(asRec.US_WSREMS__Assessment_Result__c == 'Failed' && asRec.US_WSREMS__Total_Number_of_Attempts__c <= 2){
                strTemplateName = 'Tryvio_Presc_Asses_Fail_First_Second';
            }else if(asRec.US_WSREMS__Assessment_Result__c == 'Failed' && asRec.US_WSREMS__Total_Number_of_Attempts__c == 3){
                strTemplateName = 'Tryvio_Presc_Knowledge_Assessment_Fail';
            }
            else if(asRec.US_WSREMS__Assessment_Result__c == 'Passed' &&  asRec.US_WSREMS__Case__r.US_WSREMS__Channel__c == 'Portal' ){
                strTemplateName = 'Tryvio_Presc_Knowledge_Confirmation';
            }
            
        }
       
        if(!String.isEmpty(strTemplateName) && !listPrescriberIds.isEmpty()){EmailTemplate emailTemplate =  SYN_EmailUtility.getEmailTemplate(strTemplateName);
            SYN_CorrespondenceHandler.EmailWrapperClass emailwrappvalues = new SYN_CorrespondenceHandler.EmailWrapperClass();   
            emailwrappvalues.templateName = strTemplateName;
            emailwrappvalues.oweAdd = System.label.Tryvio_SentFromEmailAddress;
            emailwrappvalues.setActivity = true;    
            emailwrappvalues.whatIdVal = listPrescriberIds[0];//newMap.values()[0].Id; 
            emailwrappvalues.targetObjIdVal = listPrescriberContactIds[0]; 
            emailwrappvalues.emailAddress = listPrescriberContactIds[0];       
            emailwrappvalues.bccEmailAddress = new List<String>{System.label.Tryvio_BCCEmailAddress};
            SYN_EmailUtility.sendEmail(emailwrappvalues);   
        }
        
        

    }
    
    
    public static void stakeholderNotification(List<Id> listCaseId){
        
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        Map<String,String> emailTemplateMap = SendEmailNotifications.getEmailTemplateNameAll('TRYVIO REMS');   
        Map<String,String> emailTemplateIdMap = SendEmailNotifications.getEmailTemplateIdsAll(emailTemplateMap);        
        Id outPatientRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Outpatient_Pharmacy_Enrollment').getRecordTypeId();
        Id inPatientRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inpatient_Pharmacy_Enrollment').getRecordTypeId();
        Id prescriberRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        List<String> toAddresses = new List<String>();
        List<String> bccAddress =  new List<String>{System.label.Tryvio_BCCEmailAddress};
        String templateName = '';
        String toaddress = '';
        String toaddressValue = '';
        String fromAddress = System.Label.Tryvio_OrgwideEmailAddressId;
        
        Contact con = SendEmailNotifications.getContact();
        List<Case> listCase = [SELECT Id,US_WSREMS__Email__c, US_WSREMS__Participant__c,US_WSREMS__Participant__r.US_WSREMS__Status__c , Status, US_WSREMS__Program_Name__c, US_WSREMS__Incomplete_Reasons__c,
                               recordtypeId,  US_WSREMS__Type_of_Report__c  FROM Case WHERE Id IN: listCaseId ] ;
        List<Case> listCases = [SELECT Id,US_WSREMS__Email__c, US_WSREMS__Participant__c,US_WSREMS__Participant__r.US_WSREMS__Status__c , Status, US_WSREMS__Program_Name__c, US_WSREMS__Incomplete_Reasons__c,
                               recordtypeId,  US_WSREMS__Type_of_Report__c  FROM Case WHERE US_WSREMS__Participant__c =: listCase[0].US_WSREMS__Participant__c and Case_Record_Type_Name__c = :'Enrollment' ] ;
        
        for(Case cs : listCases){
              if(cs.US_WSREMS__Participant__r.US_WSREMS__Status__c == System.label.Tryvio_Certified_On_Hold && cs.status == 'On Hold'  && cs.US_WSREMS__Program_Name__c==System.label.Tryvio_Program && ((cs.recordtypeId == outPatientRT && cs.US_WSREMS__Type_of_Report__c == System.label.Tryvio_Retail)||cs.recordtypeId == inPatientRT)){  
                toaddressValue = cs.US_WSREMS__Email__c; 
                toAddresses.add(toaddressValue);    
                templateName =  System.label.Tryvio_OutPatient_Inp_Pharmacy_Certification_Template;                         
                emailMessageList.add(SendEmailNotifications.sendNotification(toAddresses,emailTemplateIdMap.get(templateName),bccAddress, cs.Id, fromAddress,con.Id));                        
                templateName =  System.label.Tryvio_Phar_Certification_Manufacturer_Template; 
                toAddresses.clear();
                toaddressValue = System.label.Tryvio_IdorsiaEmailAddress;
                fromAddress = System.label.Tryvio_OrgwideFromAddressId;
                toAddresses.add(toaddressValue);
                       
                       
        } 
                  if(cs.US_WSREMS__Participant__r.US_WSREMS__Status__c == System.label.Tryvio_Certified_On_Hold && cs.status == 'On Hold'  && cs.US_WSREMS__Program_Name__c==System.label.Tryvio_Program  && ((cs.recordtypeId == outPatientRT && cs.US_WSREMS__Type_of_Report__c == System.label.Tryvio_Specialty))){  
                       toaddressValue = cs.US_WSREMS__Email__c; 
                       toAddresses.add(toaddressValue);    
                       templateName =  System.label.Tryvio_OutPatient_Inp_Pharmacy_Certification_Template;                         
                       emailMessageList.add(SendEmailNotifications.sendNotification(toAddresses,emailTemplateIdMap.get(templateName),bccAddress, cs.Id, fromAddress,con.Id)); 
                       templateName =  System.label.Tryvio_Retail_Phar_Certi_Manufacturer_Template;
                       toAddresses.clear();
                       toaddressValue = System.label.Tryvio_IdorsiaEmailAddress;
                       toAddresses.add(toaddressValue);  
                       
                   }
                   
                   if((cs.US_WSREMS__Participant__r.US_WSREMS__Status__c == System.label.Tryvio_Certified_On_Hold || cs.US_WSREMS__Participant__r.US_WSREMS__Status__c == System.label.Tryvio_Certified) && cs.status == 'Complete'  && cs.US_WSREMS__Program_Name__c==System.label.Tryvio_Program && (cs.recordtypeId == outPatientRT ||cs.recordtypeId == inPatientRT || cs.recordtypeId == prescriberRT)){
                    toaddressValue = cs.US_WSREMS__Email__c;                   
                    toAddresses.add(toaddressValue);
                    templateName =  System.label.Tryvio_Presbr_Out_Phar_Certification_Template; 
                       
                   }
                   
                    if(!toAddresses.isEmpty()){
                       emailMessageList.add(SendEmailNotifications.sendNotification(toAddresses,emailTemplateIdMap.get(templateName),bccAddress, cs.Id, fromAddress,con.Id));
                       toAddresses.clear();
                   }
        }
        
          if(!emailMessageList.isEmpty()){
            SendEmailNotifications.triggerEmailsToRecipients(emailMessageList);
            emailMessageList.clear();
        }

    }   

}