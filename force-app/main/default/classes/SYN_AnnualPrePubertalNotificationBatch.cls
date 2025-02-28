/**
* @description       :
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             :
* @last modified on  : 11-21-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 Date               Developer                               Modification
 09/16/2024          Dileep Gurram(Wilco)                  Changes added as part of BT7433-2231 :Add in task for 15-day Annual pre-pubertal warning
**/
global class SYN_AnnualPrePubertalNotificationBatch implements Database.Batchable<sObject>
{
    private  String queryString;
    private  String prgmName;
    private  String complete ='Complete';
    private  String enrolled ='Enrolled';
    private  String fnrp ='FNRP (Patient is pre-pubertal)';
    private  String patient ='Patient';
    private  OrgWideEmailAddress owa = New OrgWideEmailAddress();
    private  EmailTemplate template = new EmailTemplate();
    private  String faxTemplate;
    private  String emailTemplateName;
    private  Id patientEnrollmentCaseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');
    
    global SYN_AnnualPrePubertalNotificationBatch( String programName, String faxTemplateName,String emailTemplateName){
        faxTemplate = faxTemplateName;
        emailTemplateName = emailTemplateName;
        prgmName = programName;
        template = [Select Id,Name,DeveloperName,Subject,Description,HtmlValue,Body from EmailTemplate WHERE DeveloperName =:emailtemplateName ];
        owa = [select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: label.no_reply_macitentanrems];
        this.queryString ='select id,US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Program__r.name,US_WSREMS__Patient__c,US_WSREMS__Participant__r.PersonContactId,US_WSREMS__Participant__c, US_WSREMS__Patient__r.Patient_Reproductive_Check__c,' 
            +'US_WSREMS__Patient__r.Patient_Dob_Check__c, US_WSREMS__Patient__r.US_WSREMS__Status__c,SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c,'
            +'SYN_Prescriber__r.Fax, SYN_Prescriber__r.Email_address__c, SYN_Prescriber__r.US_WSREMS__Channel__c,US_WSREMS__Patient__r.US_WSREMS__DOB__c,US_WSREMS__Patient__r.Patient_Reproductive_Status_Date__c,'
            +'US_WSREMS__Patient__r.SYN_Ref_Id__c, US_WSREMS__Patient_Initials_First_Middle_Last__c from case where RecordTypeId = :patientEnrollmentCaseRecordTypeId AND '
            +'US_WSREMS__REMS_Program__r.Name= :prgmName AND US_WSREMS__Patient__r.Patient_Reproductive_Status_Date__c!= null AND US_WSREMS__Patient__r.US_WSREMS__DOB__c != null AND '
            +'Patient_Status__c= :enrolled AND US_WSREMS__Patient__r.US_WSREMS__Patient_Risk_Category__c= :fnrp AND Status= :complete  AND US_WSREMS__Outcome__c= :complete';
        
    }

    global Database.QueryLocator start(Database.batchableContext BC){
        
        return database.getQueryLocator(queryString);
        
    }
    
    global void execute(Database.BatchableContext BC, List<case> scope){
        List<Account> presAccount = new List<Account>();
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        List<US_WSREMS__Affiliation__c> finalAccListToSendEmails = new List<US_WSREMS__Affiliation__c>();
        List<US_WSREMS__Affiliation__c> finalAccListToSendFax = new List<US_WSREMS__Affiliation__c>();
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        List<String> bccAddresses = New List<String>();
        List<Task> task_insertlist=new List<Task>();
        bccAddresses.add(label.RemsSupportEmail);
        Contact con = MACIAutomationCommunicationUtility.getContact();
        Group groupObj =[ SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name =:SYN_Utilitycls.Maci_Escalation_queue_name];
              
        for(case cs:scope){
            
             date daycalc =date.newInstance(cs.US_WSREMS__Patient__r.Patient_Reproductive_Status_Date__c.year()+1,
                                           cs.US_WSREMS__Patient__r.Patient_Reproductive_Status_Date__c.Month(),
                                           cs.US_WSREMS__Patient__r.Patient_Reproductive_Status_Date__c.day());
            
            date daycalcforAge =date.newInstance(cs.US_WSREMS__Patient__r.US_WSREMS__DOB__c.year()+8,
                                           cs.US_WSREMS__Patient__r.US_WSREMS__DOB__c.Month(),
                                           cs.US_WSREMS__Patient__r.US_WSREMS__DOB__c.day());
            //for 30-day
            Integer daysNum=Date.today().daysBetween(daycalc);
             Integer daysAge=Date.today().daysBetween(daycalcforAge);
             Boolean isDate30Days=(daysNum==30) ;
             Boolean isAge30Days=(daysAge==30) ;
            //for 15-day
            Boolean isDate15Days=(daysNum==15);
            Boolean isAge15Days=(daysAge==15);
            
            Decimal patientAge =date.newInstance(cs.US_WSREMS__Patient__r.US_WSREMS__DOB__c.year(),
                                           cs.US_WSREMS__Patient__r.US_WSREMS__DOB__c.Month(),
                                           cs.US_WSREMS__Patient__r.US_WSREMS__DOB__c.day()).daysBetween(Date.today())/365.22;
            Boolean isOlderthan8 = patientAge >= 8;
            
          if((isDate30Days && isOlderthan8) ||(isAge30Days && !isOlderthan8)){
            
            String result = MACIAutomationCommunicationUtility.checkEmailOrFax(cs.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c, cs.SYN_Prescriber__r.Fax, cs.SYN_Prescriber__r.Email_address__c, cs.SYN_Prescriber__r.US_WSREMS__Channel__c);
            if(result == 'SendEmail'){
                List<String> toAddresses = New List<String>();
                toAddresses.add(cs.SYN_Prescriber__r.Email_address__c);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setBccAddresses(bccAddresses);
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setSaveAsActivity(true);
                mail.setWhatId(cs.Id);
                mail.setTemplateId(template.Id);
                if(con!=null)
                    mail.setTargetObjectId(con.Id);
                
                mail.setTreatTargetObjectAsRecipient(false);
                if(owa != null){
                    mail.setOrgWideEmailAddressId(owa.Id);
                }
                emailMessageList.add(mail);
                
            }else if(result == 'SendFax'){
                REMS_Outbound_Communication__c communicationRec=new REMS_Outbound_Communication__c();
                communicationRec.Template__c= faxTemplate;
                communicationRec.Status__c='Pending';
                communicationRec.Case__c=cs.Id;
                communicationRec.Recipient__c=cs.US_WSREMS__Participant__c;
                communicationRec.OBCom_Type__c='Fax';
                communicationRecList.add(communicationRec);
            }
        }
             else if((isDate15Days && isOlderthan8) ||(isAge15Days && !isOlderthan8)){
                Task t=new Task();
	
                    id  recordTypeId =Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SocialDeterminant').getRecordTypeId();
                   t.RecordTypeId=recordTypeId;
                   t.Subject='Annual Pre-Pubertal Verification Due';
                   t.Type='Follow-up';
                   t.Program_Name__c =cs.US_WSREMS__REMS_Program__c;
                   t.REMS_Program__c=cs.US_WSREMS__REMS_Program__r.Name;
                   t.Status='In-Progress';
                   t.ActivityDate=system.today();
                   if(groupObj.id !=null){
                      t.OwnerId = groupObj.id;
                   }
                   t.WhatId=cs.US_WSREMS__Patient__c;
                   t.Priority='Normal';
                   t.WhoId =cs.US_WSREMS__Participant__r.PersonContactId;
                   task_insertlist.add(t);  
            }
        }
        
        try{
            if(!emailMessageList.isEmpty()){
                MACIAutomationCommunicationUtility.triggerEmailsToRecipients(emailMessageList);
            }
            if(communicationRecList!=null && !communicationRecList.isEmpty()){
                insert communicationRecList;
            }
            if(!task_insertlist.isEmpty() ){
                insert task_insertlist;
            }
        }catch(Exception e){
            string errorMessage=  e.getMessage();
            sendEmailToAdmin(label.adminEmail,errorMessage);
        }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    private void sendEmailToAdmin(String recipientEmail, String errorMessage){
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{recipientEmail});
        email.setSubject('Production: Annual PrePubertal Notification Batch Failed');
        email.setplainTextBody('SYN_AnnualPrePubertalNotificationBatch batch job encountered an error:' +errorMessage);
    }
    
}