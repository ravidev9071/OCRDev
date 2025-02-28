/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-25-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SYN_CorrespondenceHandler{
    public  class EmailWrapperClass{
        public Boolean setActivity{get;set;}
        public String templateName{get;set;}
        public String recipientType{get;set;}
        public String oweAdd{get;set;}
        public String whatIdVal{get;set;}
        public String targetObjIdVal{get;set;}
        public String sourceId{get;set;}
        public string emailAddress{get;set;}
        public Id communicationRecId{get;set;}
        public List<String> attachIds{get;set;}
        public List<String> bccEmailAddress{get;set;}
        public List<String> toAddressList{get;set;}
    }
    
    public static String email = 'Email';
    public static String fax = 'Fax';
    public static void sendEmailCorrespondence(SObject source, String templateName, Id communicationRecId){	
        Id pharmacyEnrollcaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Pharmacy_Enrollment');
        Id patientEnrollcaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');	
        Id distributorEnrollcaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Distributor_Enrollment');
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        Id kAACaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Knowledge_Assessment_A');  
        Id kABCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Knowledge_Assessment_B');
        Id pccCaseRecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Counseling_Checklist');
        Id rmrCaseRecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Risk_Management_Report');
        Boolean emailWithAttachment = FALSE;
        case cs = (case) source;	
        String participantType = cs.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c;
        String reporterType = cs.SYN_Type_of_Reporter__c;	
        SYN_EmailUtility.getAllCorrespondenceSettings();	
        Map<string,string> fieldValueMap = SYN_CommonUtility.getObjectFieldValues(source);	
        // case cas = [SELECT Id FROM Case LIMIT 1];	
        String userProgName = fieldValueMap.get('USREMSPROGNAME');	
        Id ownerId = fieldValueMap.get('ownerId');	
      //  Id setTargetObjectId = fieldValueMap.get('TargetObjectId');	
        Id setTargetObjectId;	
        String emailId = '';	
        Id participantAcctId;
        List<String> bccEmailAdd;
        if(fieldValueMap.get('caseRecordTypeId') == pharmacyEnrollcaseRecTypeId){	
            emailId = fieldValueMap.get('AuthRepEmailId');	
            participantAcctId = fieldValueMap.get('whatId');	
            setTargetObjectId = fieldValueMap.get('AuthRepTargetObjId');
            bccEmailAdd = new List<String>();
            bccEmailAdd.add(System.Label.SOXREMSSupportEmail);				
        }
         else if(fieldValueMap.get('caseRecordTypeId') == patientEnrollcaseRecTypeId){	
            emailId = fieldValueMap.get('prescriberEmail');	
            participantAcctId = fieldValueMap.get('whatId');	
            setTargetObjectId = fieldValueMap.get('prescribertargetObjectIdVal');
            bccEmailAdd = new List<String>();
            bccEmailAdd.add(System.Label.SOXREMSSupportEmail);		
        }
        else if(fieldValueMap.get('caseRecordTypeId') == distributorEnrollcaseRecTypeId){	
            emailId = fieldValueMap.get('caseEmail');	
            participantAcctId = fieldValueMap.get('whatId');
            Account targetObjAcc  = [select Id, PersonContactId, Name from Account where Name = :SYN_Utilitycls.SOXPersonContactIdAccName Limit 1];	
           // setTargetObjectId = fieldValueMap.get('distibtrtargetObjectIdVal');
            setTargetObjectId = targetObjAcc.PersonContactId;
            bccEmailAdd = new List<String>();
            bccEmailAdd.add(System.Label.SOXREMSSupportEmail);		
        }
        else if(fieldValueMap.get('caseRecordTypeId') == prescriberEnrollCaseRecTypeId){	
            emailId = fieldValueMap.get('prescriberEmail');	
            participantAcctId = fieldValueMap.get('whatId');	
            setTargetObjectId = fieldValueMap.get('prescribertargetObjectIdVal');
            bccEmailAdd = new List<String>();
            bccEmailAdd.add(System.Label.SOXREMSSupportEmail);
        }
          else if(fieldValueMap.get('caseRecordTypeId') == kAACaseRecTypeId ||fieldValueMap.get('caseRecordTypeId') == kABCaseRecTypeId){	
            emailId = fieldValueMap.get('caseEmail');
            participantAcctId = fieldValueMap.get('whatId');
             Id participantId = fieldValueMap.get('participantId');
            if(participantId != Null){
                Account acctargetObj  = [select Id, PersonContactId, Name from Account where Id = :participantId Limit 1];
                                setTargetObjectId = acctargetObj.PersonContactId;

            } 
            bccEmailAdd = new List<String>();
            bccEmailAdd.add(System.Label.SOXREMSSupportEmail); //aded by ismail
        }
        else if(fieldValueMap.get('caseRecordTypeId') == pccCaseRecTypeId){	
            emailId = fieldValueMap.get('pharmacyPartipEmail');
            participantAcctId = fieldValueMap.get('whatId');
               Id participantId = fieldValueMap.get('PharmacyParticipantId');
              Account acctargetObj  = [select Id, PersonContactId, Name from Account where Id = :participantId Limit 1];
            setTargetObjectId = acctargetObj.PersonContactId;
            bccEmailAdd = new List<String>();
            bccEmailAdd.add(System.Label.SOXREMSSupportEmail); //added  by ismail
        }
        else if(fieldValueMap.get('caseRecordTypeId') == rmrCaseRecTypeId && ((participantType == 'Prescriber' && reporterType == 'Prescribing Physician')||(participantType == 'Pharmacy' && reporterType == 'Pharmacist'))){	
            emailId = fieldValueMap.get('rmrReporterEmail');
            participantAcctId = fieldValueMap.get('whatId');
            setTargetObjectId = fieldValueMap.get('nameOfReportertargetObjectIdVal');
            bccEmailAdd = new List<String>();
            bccEmailAdd.add(System.Label.SOXREMSSupportEmail); //added by ismail
        }
        else {	
            emailId = fieldValueMap.get('EmailAddress');	
            participantAcctId = fieldValueMap.get('participantId');	
            setTargetObjectId = fieldValueMap.get('TargetObjectId');	
        }	
        	
        REMS_Correspondence_Settings__mdt corresSettingRec = SYN_EmailUtility.getProgramSpecificCorresSett(userProgName, templateName);	
        SYN_CorrespondenceHandler.EmailWrapperClass emailwrappvalues = new SYN_CorrespondenceHandler.EmailWrapperClass();	
        emailwrappvalues.templateName = corresSettingRec.Template_Name__c;	
        emailwrappvalues.recipientType = corresSettingRec.Recipient_Type__c;	
        emailwrappvalues.oweAdd = corresSettingRec.From__c;	
        emailwrappvalues.setActivity = True;	
        emailwrappvalues.whatIdVal = participantAcctId;	
        emailwrappvalues.targetObjIdVal = setTargetObjectId;	
        emailwrappvalues.emailAddress = emailId;	
        emailwrappvalues.attachIds = new List<String>{};
        emailwrappvalues.bccEmailAddress = bccEmailAdd;
        emailwrappvalues.communicationRecId = communicationRecId;
        	
        if(corresSettingRec != NULL){               	
            	
            if(corresSettingRec.Type__c == email){	
                emailWithAttachment = String.isNotBlank(corresSettingRec.Conga_Attachment_Template__c)? TRUE : FALSE;	
                if(emailWithAttachment){	
                 fieldValueMap.put('CommunicationId',communicationRecId+'');
                   SYN_CongaUtility.GeneratePDFUsingConga genarateCongaFaxPdf = new SYN_CongaUtility.GeneratePDFUsingConga(source.Id, corresSettingRec, email,fieldValueMap,'case');   
                   system.enqueueJob(genarateCongaFaxPdf);	
                }else{	
                    //SYN_EmailUtility.sendEmail(source, corresSettingRec.Template_Name__c, corresSettingRec.Recipient_Type__c, corresSettingRec.From__c, FALSE, source.Id, setTargetObjectId, new List<String>{});	
                    SYN_EmailUtility.sendEmail(emailwrappvalues);	
                }	
            }	
        } 	
    }    
    //public static void sendFaxCorrespondence(Case caseRec, String templateName){
    public static void sendFaxCorrespondence(SObject source, String templateName, Id communicationRecId,String obj){
    
       
        SYN_EmailUtility.getAllCorrespondenceSettings();
        Map<string,string> fieldValueMap = SYN_CommonUtility.getObjectFieldValues(source);
        String userProgName = fieldValueMap.get('USREMSPROGNAME');
        fieldValueMap.put('CommunicationId',communicationRecId+'');
        REMS_Correspondence_Settings__mdt corresSettingRec = SYN_EmailUtility.getProgramSpecificCorresSett(userProgName, templateName);
            if(corresSettingRec != NULL){
            //SYN_CongaUtility.generatePDFUsingConga(caseRec.Id, corresSettingRec, fPax);
           SYN_CongaUtility.GeneratePDFUsingConga genarateCongaFaxPdf = new SYN_CongaUtility.GeneratePDFUsingConga(source.Id, corresSettingRec, fax,fieldValueMap,obj);
            
            system.enqueueJob(genarateCongaFaxPdf);
        }
    }
}