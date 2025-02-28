public class AutomationCommunicationFromCase {
    
    public static Boolean isOutcomeApproved = false;
    public static void getAutomationCommunicationFromCase(List<Case> caseList, String programName){
        Id PrescriberEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
         Id OutpatientPharmacyEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Outpatient_Pharmacy');
        Id RDACaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'PDA');
        //Added By Rajeev for TRYVIO REMS Correspondence Template on 7th June 2024
        Id PAE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PAE').getRecordTypeId();
		//End  Rajeev for TRYVIO REMS Correspondence Template on 7th June 2024
        List<Case> finalCaseList = New List<Case>();
		
		Set<Id> setfinalCasePAE = new Set<Id>();
        Boolean isAfterUpdate = (Trigger.isAfter && Trigger.isUpdate);
        Map<Id, List<Onboarding_Checklist__mdt>> mapRecordtype = new Map<Id, List<Onboarding_Checklist__mdt>>();
        for(Case cs:[SELECT Id,recordTypeId,RecordType.DeveloperName,Status,US_WSREMS__Outcome__c,ownerId,US_WSREMS__Program_Name__c,US_WSREMS__Program_Picklist__c,
                     SYN_Authorized_Rep__c, US_WSREMS__Incomplete_Reasons__c, SYN_Authorized_Rep__r.US_WSREMS__Email__c,SYN_Authorized_Rep__r.US_WSREMS__Status__c,SYN_Pharmacy__c,SYN_Pharmacy__r.US_WSREMS__Status__c,
                     SYN_Prescriber__c,SYN_Prescriber__r.Email_address__c,SYN_Prescriber__r.US_WSREMS__Status__c,US_WSREMS__Distributor__c,
                     US_WSREMS__Distributor__r.US_WSREMS__Email__c,US_WSREMS__Distributor__r.US_WSREMS__Status__c,Pharmacy_Participant__c,Pharmacy_Participant__r.US_WSREMS__Email__c,US_WSREMS__Patient__c,
                     US_WSREMS__Patient__r.US_WSREMS__Status__c,US_WSREMS__REMS_Service_Summary__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c,
                     US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Participant__r.US_WSREMS__Status__c,Email_address__c,SYN_Prescriber_First_Name__c,US_WSREMS__Fax__c,
                     SYN_Prescriber_Last_Name__c,Incomplete_Reason__c,Incomplete_Reasons__c,Participant_REMS_ID_Num__c,Patient_Name_Initials__c,US_WSREMS__Patient_DOB__c,
                     US_WSREMS__REMS_Authorized_Rep__c,US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__Email__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c,US_WSREMS__Channel__c , US_WSREMS__REMS_Program__c,US_WSREMS__Participant__r.PersonContactId,US_WSREMS__Email__c,SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c,SYN_Prescriber__r.Fax,US_WSREMS__Preferred_Contact_Method__c,Prescriber_fax_Number__c FROM Case WHERE Id IN: Trigger.New AND US_WSREMS__Program_Name__c =:programName]){
                        
                     if(isAfterUpdate && cs.RecordTypeId == PAE && cs.US_WSREMS__Program_Name__c == System.label.Tryvio_Program){
                            setfinalCasePAE.add(cs.Id);
                        }else if(!isOutcomeApproved && cs.RecordType.DeveloperName =='PDA'  && cs.Status == 'Complete' && cs.US_WSREMS__Outcome__c == 'Approved' && cs.US_WSREMS__Program_Name__c == System.label.PiaSky_REMS_Program_Name){
                            finalCaseList.add(cs);
                            isOutcomeApproved = true;
                     }
            }
        
        if(!finalCaseList.isEmpty()){
           SendEmailNotifications.getNotificationPiasky(finalCaseList,programName);
        }

        if(!setfinalCasePAE.isEmpty()){
            List<EmailMessage> listEM = [Select Id from EmailMessage Where subject like '%Reportable Event Form' and parentId IN: setfinalCasePAE limit 1];
            TryvioQueueable paeQueue = new TryvioQueueable(setfinalCasePAE);
            if(listEM.isEmpty()){
                System.enqueueJob(paeQueue);
            }
		   
        }
    }

    public static void sendEmailForKAResponses(Map<Id, US_WSREMS__Assessment_Submission__c> newKASubmissionMap, Map<Id, US_WSREMS__Assessment_Submission__c> oldKASubmissionMap){
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = new List<String>();
        String toaddress;
        String templateName;
        Set<Id> newKASubmissionSet = new Set<Id>();
        for(US_WSREMS__Assessment_Submission__c submissionRec : newKASubmissionMap.values()){
            US_WSREMS__Assessment_Submission__c oldSubmissionRec = oldKASubmissionMap.get(submissionRec.Id);
            if(oldSubmissionRec.US_WSREMS__Assessment_Result__c != submissionRec.US_WSREMS__Assessment_Result__c && 
                submissionRec.US_WSREMS__Assessment_Result__c == 'Fail' || submissionRec.US_WSREMS__Assessment_Result__c == 'Failed'
            ) {
                newKASubmissionSet.add(submissionRec.Id);
            }
        }

        if(!newKASubmissionSet.isEmpty()){
            Contact contactRecord = SendEmailNotifications.getContact();
            Map<String, Id> orgWideAddressMap = SendEmailNotifications.getOrgWideAddresses();

            for(US_WSREMS__Assessment_Submission__c submission : getAssessmentSubmissionRecordsByIds(newKASubmissionSet)){
                if(submission.US_WSREMS__Case__c != null && submission.US_WSREMS__Case__r.US_WSREMS__Participant__c != null && submission.US_WSREMS__Case__r.US_WSREMS__Channel__c == 'Fax') {
                    if(submission.US_WSREMS__Case__r.US_WSREMS__Participant__r.PersonEmail != ''
                        && submission.US_WSREMS__Case__r.US_WSREMS__Participant__r.PersonEmail != null){
                        toaddress = submission.US_WSREMS__Case__r.US_WSREMS__Participant__r.PersonEmail;
                    } else if(submission.US_WSREMS__Case__r.US_WSREMS__Email__c != '' && submission.US_WSREMS__Case__r.US_WSREMS__Email__c != null) {
                        toaddress = submission.US_WSREMS__Case__r.US_WSREMS__Email__c;
                    } if(toaddress != null) {
                        toAddresses.add(toaddress);
                        templateName = 'Aveed_EnrollHCP_KAFeedback';
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email = SendEmailNotifications.sendemail(contactRecord, orgWideAddressMap.get(Label.AVEEDRemsSupportEmail), submission.US_WSREMS__Case__r.US_WSREMS__Participant__r, toAddresses, templateName, SendEmailNotifications.getEmailTemplateMap());
                        emailMessageList.add(email);
                    }
                }
            }
        }

        if(!emailMessageList.isEmpty()){
            SendEmailNotifications.triggerEmailsToRecipients(emailMessageList);
        }
    }

    public static List<Case> getCasesByProgramAndCaseIds(Set<Id> caseIds, String program){
        return ([SELECT Id,recordTypeId,US_WSREMS__Type_of_Report__c, RecordType.DeveloperName,Status,US_WSREMS__Outcome__c,ownerId,US_WSREMS__Program_Name__c,
            US_WSREMS__Program_Picklist__c, US_WSREMS__Incomplete_Reasons__c,US_WSREMS__REMS_Service_Summary__c,US_WSREMS__REMS_Authorized_Rep__c,
            Email_address__c,US_WSREMS__Fax__c, Participant_REMS_ID_Num__c, US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__Email__c,
            US_WSREMS__Channel__c, US_WSREMS__REMS_Program__c,US_WSREMS__Participant__r.PersonContactId,US_WSREMS__Email__c,
            US_WSREMS__Pharmacy_Type__c, US_WSREMS__Participant__r.US_WSREMS__Status__c,US_WSREMS__Participant__r.RecordTypeId,
            US_WSREMS__Preferred_Contact_Method__c,Prescriber_fax_Number__c, US_WSREMS__Participant__r.US_WSREMS__Email__c,US_WSREMS__Email_ar__c,
            US_WSREMS__Participant__r.US_WSREMS__First_And_Last_Name__c, US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c,
            US_WSREMS__Participant__r.PersonEmail, US_WSREMS__REMS_Authorized_Rep__r.PersonEmail, US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__First_And_Last_Name__c,
            US_WSREMS__REMS_ID__c, US_WSREMS__X1_Participant__c, US_WSREMS__X1_Participant__r.RecordTypeId, US_WSREMS__X1_Participant__r.PersonEmail,
            US_WSREMS__Participant_Email__c, US_WSREMS__Participant_FirstName__c, US_WSREMS__Participant_LastName__c, US_WSREMS__Participant__r.US_WSREMS__REMS_ID__c,
            US_WSREMS__X1_Participant__r.Name, US_WSREMS__X1_Participant__r.US_WSREMS__Address_Line_1__c,US_WSREMS__X1_Participant__r.US_WSREMS__Address_Line_2__c,
            US_WSREMS__X1_Participant__r.US_WSREMS__State__c,US_WSREMS__X1_Participant__r.US_WSREMS__City__c, US_WSREMS__X1_Participant__r.US_WSREMS__Zip__c, US_WSREMS__Description__c,
            US_WSREMS__X1_Participant__r.US_WSREMS__First_And_Last_Name__c, US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__Healthcare_Setting__r.Name,
            US_WSREMS__Healthcare_Setting__r.US_WSREMS__Address_Line_1__c, US_WSREMS__Healthcare_Setting__r.US_WSREMS__City__c, US_WSREMS__Healthcare_Setting__r.US_WSREMS__State__c,
            US_WSREMS__Healthcare_Setting__r.US_WSREMS__Zip__c, US_WSREMS__Authorized_Representative_New_Primary_AR__r.PersonEmail,US_WSREMS__Authorized_Representative_New_Primary_AR__c,
            US_WSREMS__Authorized_Representative_New_Primary_AR__r.US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Participant_Fax__c,
            US_WSREMS__AR_Email_New_Primary_AR__c,US_WSREMS__X1_Participant__r.Fax,US_WSREMS__Prescriber__r.PersonEmail,US_WSREMS__Program_Type__c,
            US_WSREMS__Address_Line_1__c,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Zip__c
        FROM Case
        WHERE Id IN: caseIds
            AND US_WSREMS__Program_Name__c =:program
        ]);
    }

    public static List<Case> getCasesByProgramAndaccountIds(Set<Id> accIds, String program){
        return ([SELECT Id,recordTypeId ,RecordType.DeveloperName,Status,US_WSREMS__Outcome__c,ownerId,US_WSREMS__Program_Name__c,
            US_WSREMS__Participant__r.US_WSREMS__Status__c,US_WSREMS__Participant__r.RecordTypeId, US_WSREMS__Participant__r.US_WSREMS__Sub_Status__c,
            US_WSREMS__Participant__r.US_WSREMS__Email__c, US_WSREMS__Email__c, US_WSREMS__Deactivation_Date__c, US_WSREMS__Email_ar__c,
            US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__Email__c, US_WSREMS__Name__c, US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c,
            US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__REMS_Zip_Code__c, US_WSREMS__REMS_ID__c,US_WSREMS__REMS_Authorized_Rep__r.PersonEmail,
            US_WSREMS__Participant__r.US_WSREMS__First_And_Last_Name__c, US_WSREMS__Participant__r.PersonEmail,
            US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__Description__c,
            US_WSREMS__X1_Participant__r.US_WSREMS__First_And_Last_Name__c, US_WSREMS__X1_Participant__r.Name,
            US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__First_And_Last_Name__c,
            US_WSREMS__X1_Participant__r.US_WSREMS__Status__c,US_WSREMS__X1_Participant__r.RecordTypeId, US_WSREMS__X1_Participant__r.US_WSREMS__Sub_Status__c,
            US_WSREMS__X1_Participant__r.PersonEmail, US_WSREMS__Channel__c, US_WSREMS__X1_Participant__c, US_WSREMS__REMS_Authorized_Rep__c
        FROM Case
        WHERE US_WSREMS__Participant__c IN: accIds 
            AND US_WSREMS__Program_Name__c =:program
        Order by CreatedDate DESC
        ]);
    }

    public static List<Case> getNonComplanceCasesByProgramAndaccountIds(Set<Id> accIds, String program){
        return ([SELECT Id,recordTypeId ,RecordType.DeveloperName,Status,US_WSREMS__Outcome__c,ownerId,US_WSREMS__Program_Name__c,
            US_WSREMS__X1_Participant__r.US_WSREMS__Status__c,US_WSREMS__X1_Participant__r.RecordTypeId, US_WSREMS__X1_Participant__r.US_WSREMS__Sub_Status__c,
            US_WSREMS__X1_Participant__r.US_WSREMS__Email__c, US_WSREMS__Email__c, US_WSREMS__Deactivation_Date__c, US_WSREMS__Email_ar__c,
            US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__Email__c, US_WSREMS__Name__c, US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c,
            US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__REMS_Zip_Code__c, US_WSREMS__REMS_ID__c,US_WSREMS__REMS_Authorized_Rep__r.PersonEmail,
            US_WSREMS__X1_Participant__r.US_WSREMS__First_And_Last_Name__c, US_WSREMS__X1_Participant__r.PersonEmail,
            US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__Description__c,US_WSREMS__X1_Participant__r.Name,
            US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__First_And_Last_Name__c, US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c,
            US_WSREMS__Participant__r.US_WSREMS__Email__c, US_WSREMS__Participant__r.US_WSREMS__First_And_Last_Name__c, US_WSREMS__Participant__r.PersonEmail,
            US_WSREMS__Participant__r.Fax, US_WSREMS__Participant__r.US_WSREMS__Status__c, US_WSREMS__Participant__r.US_WSREMS__Sub_Status__c,US_WSREMS__Participant__r.RecordTypeId,
            US_WSREMS__X1_Participant__c, US_WSREMS__X1_Participant__r.US_WSREMS__Address_Line_1__c, US_WSREMS__X1_Participant__r.Fax
        FROM Case
        WHERE US_WSREMS__X1_Participant__c IN: accIds 
            AND US_WSREMS__Program_Name__c =:program
            AND RecordTypeId =:AVEEDAutomationCommunicationUtility.nonComplianceRecordType
        Order by CreatedDate DESC
        ]);
    }

    public static List<US_WSREMS__Assessment_Submission__c> getAssessmentSubmissionRecordsByIds (Set<Id> assessmentIds){
        return([SELECT Id,Name, US_WSREMS__Case__r.US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__Case__c,
            US_WSREMS__Total_Number_of_Attempts__c,US_WSREMS__Assessment_Result__c,US_WSREMS__Case__r.RecordType.name,
            US_WSREMS__Case__r.RecordType.DeveloperName,US_WSREMS__Case__r.US_WSREMS__Participant__r.US_WSREMS__Email__c,
            US_WSREMS__Case__r.US_WSREMS__First_Name__c,US_WSREMS__Case__r.US_WSREMS__Last_Name__c,US_WSREMS__Case__r.US_WSREMS__Fax__c,
            US_WSREMS__Case__r.US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Case__r.US_WSREMS__Email__c, 
            US_WSREMS__Case__r.US_WSREMS__Program_Picklist__c, US_WSREMS__Case__r.US_WSREMS__Program_Name__c, US_WSREMS__Case__r.RecordTypeId,
            US_WSREMS__Case__r.US_WSREMS__Participant__r.US_WSREMS__First_And_Last_Name__c, US_WSREMS__Case__r.US_WSREMS__Participant__r.PersonEmail,
            US_WSREMS__Case__r.US_WSREMS__Participant__r.Fax, US_WSREMS__Case__r.US_WSREMS__Channel__c
        FROM US_WSREMS__Assessment_Submission__c
        WHERE Id IN: assessmentIds]);
    }

    public static Map<String, List<US_WSREMS__Program_Fields_Configuration__c>> getProgramFieldConfigurationsForIncompleteReasons (String objectName, String program){
        Map<String, List<US_WSREMS__Program_Fields_Configuration__c>> caseRecordTypeIdToIncompleteMap = new Map<String, List<US_WSREMS__Program_Fields_Configuration__c>>();
        List<US_WSREMS__Program_Fields_Configuration__c> programFieldConfigurationList = [SELECT Id, US_WSREMS__Target_Object_Field__c,US_WSREMS__Target_Object_Record_Type__c,US_WSREMS__Target_Object_Field_Label__c
                                                                FROM US_WSREMS__Program_Fields_Configuration__c
                                                                WHERE US_WSREMS__Soft_Required__c = true
                                                                AND US_WSREMS__Target_Object__c =:objectName
                                                                AND US_WSREMS__REMS_Program__r.Name =:program];
        
            for(US_WSREMS__Program_Fields_Configuration__c pfc : programFieldConfigurationList){
                if(caseRecordTypeIdToIncompleteMap.containsKey(pfc.US_WSREMS__Target_Object_Record_Type__c)){
                    caseRecordTypeIdToIncompleteMap.get(pfc.US_WSREMS__Target_Object_Record_Type__c).add(pfc);
                } else{
                    caseRecordTypeIdToIncompleteMap.put(pfc.US_WSREMS__Target_Object_Record_Type__c, new List<US_WSREMS__Program_Fields_Configuration__c>{pfc});
                }
            }
            return caseRecordTypeIdToIncompleteMap;
    }

    public static List<US_WSREMS__Affiliation__c> getAffiliationsRecordsByHcsAccountIds(Set<Id> hcsAccountIds){
        return([SELECT Id,US_WSREMS__Health_Care_Setting__c,US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c,US_WSREMS__Authorized_Representative__r.PersonEmail,
        US_WSREMS__Authorized_Representative__r.Fax, US_WSREMS__Authorized_Representative__r.personContactId, US_WSREMS__Authorized_Representative__c
            FROM US_WSREMS__Affiliation__c
            WHERE RecordType.DeveloperName  = 'Authorized_Representative_Affiliation'
            AND US_WSREMS__REMSProgram__r.Name =: Label.AVEED_REMS_Program_Name
            AND US_WSREMS__Health_Care_Setting__c =: hcsAccountIds
            ORDER BY CreatedDate DESC 
        ]);
    }
    public static List<US_WSREMS__Affiliation__c> getXiaflexAffiliationsRecordsByHcsAccountIds(Set<Id> hcsAccountIds){
        return([SELECT Id,US_WSREMS__Health_Care_Setting__c,US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c,US_WSREMS__Authorized_Representative__r.PersonEmail,
        US_WSREMS__Authorized_Representative__r.Fax, US_WSREMS__Authorized_Representative__r.personContactId, US_WSREMS__Authorized_Representative__c
            FROM US_WSREMS__Affiliation__c
            WHERE RecordType.DeveloperName  = 'Authorized_Representative_Affiliation'
            AND US_WSREMS__REMSProgram__r.Name =: Label.Xiaflex_REMS_Program_Name
            AND US_WSREMS__Health_Care_Setting__c =: hcsAccountIds
            ORDER BY CreatedDate DESC 
        ]);
    }
            
}