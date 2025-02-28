public without sharing class AVEEDAutomationCommunicationUtility {
    public Static Map<Id, String> caseRecordTypeIdToIncompleteMap = new Map<Id, String>();
    public Static Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
    public Static Id hcsReEnrollmentRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Reenrollment');
    public Static Id hcsEnrollmentRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
    public Static Id nonComplianceRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
    public Static Id prescriberRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
    public Static Id hcsRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');
    public Static Id changeAuthRepRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Change_Authorized_Representative');

    public static void sendCommunicationFromCaseWhileUpdateOrInsert(Boolean isUpdate,Map<Id, Case> newCaseMap,  Map<Id, Case> oldCaseMap){
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();

        Map<Id, Boolean> incompleteReasons = new Map<Id, Boolean>();
        List<Case> caseListToSendEmail = New List<Case>();
        Set<Id> caseIdToSendFax = New Set<Id>();
        Set<Id> nonComplainceAccountIds = New Set<Id>();
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        Map<String, List<US_WSREMS__Program_Fields_Configuration__c>> programFieldConfigurationMap = AutomationCommunicationFromCase.getProgramFieldConfigurationsForIncompleteReasons('Case', SYN_Utilitycls.AVEED_PROGRAM_NAME);
        
        Map<Id, String> recordTypeIdToProgramNameMap = new Map<Id, String>();
        recordTypeIdToProgramNameMap.put(hcsReEnrollmentRecordType, 'HCS_Reenrollment');
        recordTypeIdToProgramNameMap.put(hcsEnrollmentRecordType, 'HCS_Enrollment');
        recordTypeIdToProgramNameMap.put(prescriberEnrollCaseRecTypeId, 'Prescriber_enrollment');
        
        for(Case caseRecord:newCaseMap.values()){
            if(!isUpdate){
                if(recordTypeIdToProgramNameMap.containsKey(caseRecord.recordTypeId) && programFieldConfigurationMap.containsKey(recordTypeIdToProgramNameMap.get(caseRecord.recordTypeId))){
                        for(US_WSREMS__Program_Fields_Configuration__c pfc: programFieldConfigurationMap.get(recordTypeIdToProgramNameMap.get(caseRecord.recordTypeId))){
                            if(caseRecord.get(pfc.US_WSREMS__Target_Object_Field__c) == null || caseRecord.get(pfc.US_WSREMS__Target_Object_Field__c) == true){
                                incompleteReasons.put(caseRecord.Id, true);
                                break;
                        }
                    }
                }
            }
            if(caseRecord.recordTypeId == nonComplianceRecordType){
                nonComplainceAccountIds.add(caseRecord.US_WSREMS__X1_Participant__c);
            }
        }

        for(US_WSREMS__Affiliation__c affiliationRecord : AutomationCommunicationFromCase.getAffiliationsRecordsByHcsAccountIds(nonComplainceAccountIds)){
            if(!accountIdToaffiliationMap.containsKey(affiliationRecord.US_WSREMS__Health_Care_Setting__c)){
                accountIdToaffiliationMap.put(affiliationRecord.US_WSREMS__Health_Care_Setting__c, affiliationRecord);
            }
        }

        for(Case caseRecord: AutomationCommunicationFromCase.getCasesByProgramAndCaseIds(newCaseMap.keySet(), SYN_Utilitycls.AVEED_PROGRAM_NAME)){
            if(isUpdate){
                Case oldCase = oldCaseMap.get(caseRecord.Id);
                if(caseRecord.Status != oldCase.Status && caseRecord.Status == 'Complete' && caseRecord.RecordTypeId != nonComplianceRecordType){
                    if(caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Fax' && caseRecord.US_WSREMS__Outcome__c == 'Complete') {
                        communicationRecList = createREMSCommunicationForHCSorHcpEnroll(caseRecord);
                    } else if(caseRecord.US_WSREMS__Authorized_Representative_New_Primary_AR__r.US_WSREMS__Preferred_Contact_Method__c == 'Fax' && caseRecord.RecordTypeId == changeAuthRepRecordType) {
                        //Change Auth Rep Confirmation - Fax
                        communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga Auth Rep Replace Confirm')); 
                    } else if(caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Email' && caseRecord.US_WSREMS__Outcome__c == 'Complete' && caseRecord.RecordTypeId == hcsReEnrollmentRecordType){
                        // HCS reenroll confimation - Email
                        caseListToSendEmail.add(caseRecord);
                    } else if(caseRecord.US_WSREMS__Authorized_Representative_New_Primary_AR__r.US_WSREMS__Preferred_Contact_Method__c == 'Email' && caseRecord.RecordTypeId == changeAuthRepRecordType) {
                        // Auth rep change confirmation - Email
                        caseListToSendEmail.add(caseRecord);
                    } 
                } else if(caseRecord.US_WSREMS__Outcome__c != oldCase.US_WSREMS__Outcome__c && caseRecord.RecordTypeId == nonComplianceRecordType){
                    sObject caseCommunication = sendemailnotificatiofromnonComplaince(caseRecord, accountIdToaffiliationMap);
                    if(caseCommunication != null){
                        SObjectType ObjectName = caseCommunication.getSObjectType();  
                        if(String.valueOf(ObjectName) == 'Case'){
                            Case caseRec = (Case) caseCommunication;
                            caseListToSendEmail.add(caseRec);
                        } else {
                            REMS_Outbound_Communication__c communicationRec = (REMS_Outbound_Communication__c)caseCommunication;
                            communicationRecList.add(communicationRec);
                        }
                    }
                }
            } else {
                if(caseRecord.Status == 'Draft' && incompleteReasons.containsKey(caseRecord.Id) && incompleteReasons.get(caseRecord.Id) && caseRecord.US_WSREMS__Channel__c == 'Fax'){
                    if(caseRecord.RecordTypeId == prescriberEnrollCaseRecTypeId) {
                        String result = checkEmailOrFax(caseRecord.US_WSREMS__Preferred_Contact_Method__c, caseRecord.US_WSREMS__Email__c, caseRecord.US_WSREMS__Fax__c);
                        if(result == 'sendfax' && Label.aveed_sendFax == 'true'){
                            //Prescribing HCP Enrollment Request for Missing or Invalid Information - Fax
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCP Enrollment Missing Info'));
                        }
                    } else if(caseRecord.RecordTypeId == hcsEnrollmentRecordType) {
                        String result = checkEmailOrFax(caseRecord.US_WSREMS__Preferred_Contact_Method__c, caseRecord.US_WSREMS__Email_ar__c, caseRecord.US_WSREMS__Participant_Fax__c);
                        if(result == 'sendfax'  && Label.aveed_sendFax == 'true'){
                            //Healthcare Setting Enrollment Request for Mising or Invalid Information - Fax
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCS Enrollment Missing Info'));
                        }
                    } else if(caseRecord.RecordTypeId == hcsReEnrollmentRecordType) {
                        String result = checkEmailOrFax(caseRecord.US_WSREMS__Preferred_Contact_Method__c, caseRecord.US_WSREMS__Email_ar__c, caseRecord.US_WSREMS__Participant_Fax__c);
                        if(result == 'sendfax'){
                            caseListToSendEmail.add(caseRecord);
                            //Healthcare Setting Re-Enrollment Request for Missing Invalid Information - Fax
                            if(Label.aveed_sendFax == 'true'){
                                communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCS Re-Enrol mis or Inv Info'));
                            }
                        } else if(result == 'sendemail'){
                            caseListToSendEmail.add(caseRecord);
                        }
                    }
                } else if(caseRecord.Status == 'Complete' && caseRecord.US_WSREMS__Authorized_Representative_New_Primary_AR__r.US_WSREMS__Preferred_Contact_Method__c == 'Fax' && caseRecord.RecordTypeId == changeAuthRepRecordType) {
                    //Change Auth Rep Confirmation - Fax
                    communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga Auth Rep Replace Confirm')); 
                } else if(caseRecord.Status == 'Complete' && caseRecord.US_WSREMS__Outcome__c == 'Complete' && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Fax' && caseRecord.RecordTypeId != nonComplianceRecordType
                ) {
                    communicationRecList = createREMSCommunicationForHCSorHcpEnroll(caseRecord);
                } else if(caseRecord.Status == 'Complete' && caseRecord.US_WSREMS__Outcome__c == 'Complete' && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Email' && caseRecord.RecordTypeId == hcsReEnrollmentRecordType){
                    // HCS reenroll confimation - Email
                    caseListToSendEmail.add(caseRecord);
                } else if(caseRecord.Status == 'Complete' && caseRecord.US_WSREMS__Authorized_Representative_New_Primary_AR__r.US_WSREMS__Preferred_Contact_Method__c == 'Email' && caseRecord.RecordTypeId == changeAuthRepRecordType)
                {
                    // Auth rep change confirmation - Email
                    caseListToSendEmail.add(caseRecord);
                } else if(caseRecord.RecordTypeId == nonComplianceRecordType){
                    sObject caseCommunication = sendemailnotificatiofromnonComplaince(caseRecord, accountIdToaffiliationMap);
                    if(caseCommunication != null){
                        SObjectType ObjectName = caseCommunication.getSObjectType();  
                        if(String.valueOf(ObjectName) == 'Case'){
                            Case caseRec = (Case) caseCommunication;
                            caseListToSendEmail.add(caseRec);
                        } else {
                            REMS_Outbound_Communication__c communicationRec = (REMS_Outbound_Communication__c)caseCommunication;
                            communicationRecList.add(communicationRec);
                        }
                    }
                }
            }
        }

        if(communicationRecList!=null && !communicationRecList.isEmpty()){
            try{
                insert communicationRecList;
            } catch(exception ex){
                System.debug(LoggingLevel.ERROR, ex.getMessage());
                //TODO: add error handling
            }
        }

        if(!caseListToSendEmail.isEmpty()){
            if(Limits.getQueueableJobs() == 1) {
                System.schedule(
                    'AveedCaseNotificationSchedulable' + String.valueOf(Math.random()),
                    SYN_CommonUtility.getAsynchronousExpression(),
                    new AveedCaseNotificationSchedulable(caseListToSendEmail)
                );
            } else {
                System.enqueueJob(new AveedCaseNotificationQueueableJob(caseListToSendEmail));
            }
        }
    }

    @TestVisible
    private static List<REMS_Outbound_Communication__c> createREMSCommunicationForHCSorHcpEnroll(case caseRecord){
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();

        if(caseRecord.RecordTypeId == prescriberEnrollCaseRecTypeId) {
            //Prescribing HCP Enrollment Confirmation - Fax
            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCP Enrollment Confirm'));  
        } else if(caseRecord.RecordTypeId == hcsEnrollmentRecordType) {
            // HCS Enrollment Confirmation - Fax
            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCS Enrollment Confirmation'));
        } else if(caseRecord.RecordTypeId == hcsReEnrollmentRecordType) {
            // HCS Re-Enrollment Confirmation - Fax
            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCS Re-Enroll Confirmation'));
        }
        return communicationRecList;
    }

    @TestVisible
    private static String checkEmailOrFax(String preferredMethodOfContact, String email, String fax) {
        String result;
        if(preferredMethodOfContact == 'Email'){
            if(email != null){
                result = 'sendemail';
            } else if(fax != null){
                result = 'sendfax';
            }
        } else if(preferredMethodOfContact == 'Fax'){
            if(fax != null){
                result = 'sendfax';
            } else if(email != null){
                result = 'sendemail';
            }
        } else {
            if(email != null){
                result = 'sendemail';
            }
        }
        return result;
    }

    
    public static void sendFaxCommunicationFromAccountWhileUpdate(Map<Id, Account> newAccoutMap,  Map<Id, Account> oldAccoutMap){
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        List<Case> caseList = new List<Case>();
        Set<Id> accountIdsToSendFax = new Set<Id>();
        Set<Id> nonComplainceAccountIds = new Set<Id>();
        List<Account> accountSendEmailList = new List<Account>();
        List<Case> caseSendEmailList = new List<Case>();
        
        for(Account accountRecord: newAccoutMap.values()){
            Account oldAccountRecord = oldAccoutMap.get(accountRecord.Id);
            if(accountRecord.US_WSREMS__Status__c != oldAccountRecord.US_WSREMS__Status__c
                && accountRecord.US_WSREMS__Sub_Status__c != oldAccountRecord.US_WSREMS__Sub_Status__c
            ) {
                if(accountRecord.US_WSREMS__Sub_Status__c == 'Opt-Out' 
                    && (accountRecord.recordTypeId == prescriberRecordType || accountRecord.recordTypeId == hcsRecordType)
                ) {
                    accountIdsToSendFax.add(accountRecord.Id);
                } else if((accountRecord.US_WSREMS__Sub_Status__c == 'AR Not Confirmed' || accountRecord.US_WSREMS__Sub_Status__c == 'Failure to recertify')
                    && accountRecord.recordTypeId == hcsRecordType
                ) {
                    accountIdsToSendFax.add(accountRecord.Id);
                } else if(accountRecord.US_WSREMS__Sub_Status__c == 'Program Noncompliant'
                    && (accountRecord.recordTypeId == prescriberRecordType || accountRecord.recordTypeId == hcsRecordType)
                ) {
                    nonComplainceAccountIds.add(accountRecord.Id);
                }
            }
        }

        if(!accountIdsToSendFax.isEmpty()) {
            for(US_WSREMS__Affiliation__c affiliationRecord : AutomationCommunicationFromCase.getAffiliationsRecordsByHcsAccountIds(accountIdsToSendFax)){
                if(!accountIdToaffiliationMap.containsKey(affiliationRecord.US_WSREMS__Health_Care_Setting__c)){
                    accountIdToaffiliationMap.put(affiliationRecord.US_WSREMS__Health_Care_Setting__c, affiliationRecord);
                }
            }
        }

        for(Account accountRecord: newAccoutMap.values()){
            Account oldAccountRecord1 = oldAccoutMap.get(accountRecord.Id);
            if(accountRecord.US_WSREMS__Status__c != oldAccountRecord1.US_WSREMS__Status__c){
                if(accountRecord.US_WSREMS__Status__c == 'Deactivated' && accountRecord.US_WSREMS__Sub_Status__c == 'Opt-Out'
                    && accountRecord.recordTypeId == prescriberRecordType
                ) {
                    String result = checkEmailOrFax(accountRecord.US_WSREMS__Preferred_Contact_Method__c, accountRecord.PersonEmail, accountRecord.Fax);
                    if(result == 'sendfax'){
                        communicationRecList.add(createREMSCommunicationRecords(accountRecord,'Fax','AVEED_Conga HCP Opt-Out Confirm'));
                    } else if(result == 'sendemail'){
                        accountSendEmailList.add(accountRecord);
                    }
                } else if(accountRecord.US_WSREMS__Status__c == 'Deactivated' && accountRecord.US_WSREMS__Sub_Status__c == 'Opt-Out'
                    && accountRecord.recordTypeId == hcsRecordType
                ) {
                    if(accountIdToaffiliationMap.containsKey(accountRecord.Id)){
                        US_WSREMS__Affiliation__c affilationrec = accountIdToaffiliationMap.get(accountRecord.Id);
                        String result = checkEmailOrFax(accountRecord.US_WSREMS__Preferred_Contact_Method__c, affilationrec.US_WSREMS__Authorized_Representative__r.PersonEmail, affilationrec.US_WSREMS__Authorized_Representative__r.Fax);
                        if(result == 'sendfax'){
                            communicationRecList.add(createREMSCommunicationRecords(accountRecord,'Fax','AVEED_Conga HCS Opt-out Confirmation'));
                        } else if(result == 'sendemail'){
                            accountSendEmailList.add(accountRecord);
                        }
                    }
                } else if(accountRecord.US_WSREMS__Status__c == 'Decertified' && accountRecord.US_WSREMS__Sub_Status__c == 'AR Not Confirmed'
                    && accountRecord.recordTypeId == hcsRecordType
                ) {
                    if(accountIdToaffiliationMap.containsKey(accountRecord.Id)){
                        US_WSREMS__Affiliation__c affilationrec = accountIdToaffiliationMap.get(accountRecord.Id);
                        String result = checkEmailOrFax(accountRecord.US_WSREMS__Preferred_Contact_Method__c, affilationrec.US_WSREMS__Authorized_Representative__r.PersonEmail, affilationrec.US_WSREMS__Authorized_Representative__r.Fax);
                        if(result == 'sendfax'){
                            communicationRecList.add(createREMSCommunicationRecords(accountRecord,'Fax','AVEED_Conga HCS Deact - AR Not Confirmed'));
                        } else if(result == 'sendemail'){
                            accountSendEmailList.add(accountRecord);
                        }
                    }
                } else if(accountRecord.US_WSREMS__Status__c == 'Decertified' && accountRecord.US_WSREMS__Sub_Status__c == 'Failure to recertify'
                    && accountRecord.recordTypeId == hcsRecordType
                ) {
                    if(accountIdToaffiliationMap.containsKey(accountRecord.Id)){
                        US_WSREMS__Affiliation__c affilationrec = accountIdToaffiliationMap.get(accountRecord.Id);
                        String result = checkEmailOrFax(accountRecord.US_WSREMS__Preferred_Contact_Method__c, affilationrec.US_WSREMS__Authorized_Representative__r.PersonEmail, affilationrec.US_WSREMS__Authorized_Representative__r.Fax);
                        if(result == 'sendfax'){
                            communicationRecList.add(createREMSCommunicationRecords(accountRecord,'Fax','AVEED_Conga HCS Enrollment Deactivation'));
                        } else if(result == 'sendemail'){
                            accountSendEmailList.add(accountRecord);
                        }
                    }
                }
        }
        }

        List<Case> nonComplainceCaseList = new List<Case>();
        if(!nonComplainceAccountIds.isEmpty()){
            nonComplainceCaseList = AutomationCommunicationFromCase.getNonComplanceCasesByProgramAndaccountIds(nonComplainceAccountIds, SYN_Utilitycls.AVEED_PROGRAM_NAME);
            Map<Id, Case> accountIdToCaseMap = new Map<Id, Case>();
            for(US_WSREMS__Affiliation__c affiliationRecord : AutomationCommunicationFromCase.getAffiliationsRecordsByHcsAccountIds(nonComplainceAccountIds)){
                if(!accountIdToaffiliationMap.containsKey(affiliationRecord.US_WSREMS__Health_Care_Setting__c)){
                    accountIdToaffiliationMap.put(affiliationRecord.US_WSREMS__Health_Care_Setting__c, affiliationRecord);
                }
            }
            for(Case caseRecord: nonComplainceCaseList){
                if(!accountIdToCaseMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c)){
                    accountIdToCaseMap.put(caseRecord.US_WSREMS__X1_Participant__c, caseRecord);
                }

                if(caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Status__c == 'Decertified' && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Sub_Status__c == 'Program Noncompliant'
                    && accountIdToCaseMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c) && accountIdToCaseMap.get(caseRecord.US_WSREMS__X1_Participant__c) == caseRecord
                    && caseRecord.US_WSREMS__X1_Participant__r.recordTypeId == hcsRecordType
                ) {
                    // hcs nonc-compliance notification for account

                    if(accountIdToaffiliationMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c)){
                        US_WSREMS__Affiliation__c affilationrec = accountIdToaffiliationMap.get(caseRecord.US_WSREMS__X1_Participant__c);
                        String result = checkEmailOrFax(caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c, affilationrec.US_WSREMS__Authorized_Representative__r.PersonEmail, affilationrec.US_WSREMS__Authorized_Representative__r.Fax);
                        if(result == 'sendfax'){
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCS Non-Compliance Deactivat'));
                        } else if(result == 'sendemail'){
                            caseSendEmailList.add(caseRecord);
                        }
                    }
                } else if(caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Status__c == 'Decertified' && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Sub_Status__c == 'Program Noncompliant'
                    && accountIdToCaseMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c) && accountIdToCaseMap.get(caseRecord.US_WSREMS__X1_Participant__c) == caseRecord
                    && caseRecord.US_WSREMS__X1_Participant__r.recordTypeId == prescriberRecordType
                ) {
                    // hcp non-compliance notification for account
                    String result = checkEmailOrFax(caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c, caseRecord.US_WSREMS__X1_Participant__r.PersonEmail, caseRecord.US_WSREMS__X1_Participant__r.Fax);
                    if(result == 'sendfax'){
                        communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCP Non-Compliance Deactivat'));
                    } else if(result == 'sendemail'){
                        caseSendEmailList.add(caseRecord);
                    }
                }
            }
        }

        if(!accountSendEmailList.isEmpty()) {
            SendEmailNotifications.sendAveedAccountDeactivationNotificationFromAccount(accountSendEmailList, accountIdToaffiliationMap);
        }

        if(!caseSendEmailList.isEmpty()) {
            SendEmailNotifications.sendAveedAccountDeactivationNotificationForNonCompliance(caseSendEmailList, accountIdToaffiliationMap);
        }

        if(communicationRecList!=null && !communicationRecList.isEmpty()){
            try{
                insert communicationRecList;
            } catch(exception ex){
                System.debug(LoggingLevel.ERROR, ex.getMessage());
                //TODO: add error handling
            }
        }
    }

    public static void sendFaxForKAResponses(Map<Id, US_WSREMS__Assessment_Submission__c> newKASubmissionMap, Map<Id, US_WSREMS__Assessment_Submission__c> oldKASubmissionMap){
        Set<Id> newKASubmissionSet = new Set<Id>();
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        for(US_WSREMS__Assessment_Submission__c submissionRec : newKASubmissionMap.values()){
            US_WSREMS__Assessment_Submission__c oldSubmissionRec = oldKASubmissionMap.get(submissionRec.Id);
            if(oldSubmissionRec.US_WSREMS__Assessment_Result__c != submissionRec.US_WSREMS__Assessment_Result__c && 
                submissionRec.US_WSREMS__Assessment_Result__c == 'Passed'
            ) {
                newKASubmissionSet.add(submissionRec.Id);
            }
        }

        if(!newKASubmissionSet.isEmpty()){
            for(US_WSREMS__Assessment_Submission__c submission : AutomationCommunicationFromCase.getAssessmentSubmissionRecordsByIds(newKASubmissionSet)){
                if(
                    (submission.US_WSREMS__Case__c != null && submission.US_WSREMS__Case__r.US_WSREMS__Participant__c != null
                        && submission.US_WSREMS__Case__r.US_WSREMS__Participant__r.Fax != null)
                    && (
                        (submission.US_WSREMS__Case__r.US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c == 'Fax')
                        || (submission.US_WSREMS__Case__r.US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c == 'Email'
                            && submission.US_WSREMS__Case__r.US_WSREMS__Participant__r.PersonEmail == null
                        )
                    )
                ) {
                    //KA Passed Assessmnet
                    communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(submission.US_WSREMS__Case__r,'Fax','AVEED_Conga HCP KA Confirmation'));
                }
            }
        }

        if(communicationRecList!=null && !communicationRecList.isEmpty()){
            try{
                insert communicationRecList;
            } catch(exception ex){
                System.debug(LoggingLevel.ERROR, ex.getMessage());
                //TODO: add error handling
            }
        }
    }

    public static REMS_Outbound_Communication__c createREMSCommunicationRecords(Account accountRec,String typeofCommunication,String templatename){
        REMS_Outbound_Communication__c communicationRec = new REMS_Outbound_Communication__c();
        communicationRec.Recipient__c = accountRec.Id;
        communicationRec.Template__c= templatename;
        communicationRec.Status__c='Pending';
        communicationRec.OBCom_Type__c=typeofCommunication;
        return communicationRec;
    }
    public static sObject sendemailnotificatiofromnonComplaince(Case caseRecord, Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap){
        sObject caseOrOutboundCommunicationRecord;

            if(caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == hcsRecordType) {
                if(accountIdToaffiliationMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c)){
                    US_WSREMS__Affiliation__c affilationrec = accountIdToaffiliationMap.get(caseRecord.US_WSREMS__X1_Participant__c);
                    String result = checkEmailOrFax(caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c, affilationrec.US_WSREMS__Authorized_Representative__r.PersonEmail, affilationrec.US_WSREMS__Authorized_Representative__r.Fax);
                    if(result == 'sendfax'){
                        if(caseRecord.Status == 'Compliance Investigation' && caseRecord.US_WSREMS__Outcome__c == 'Suspected Non-compliance activity'){
                            caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCS Non-Complaince Suspected');  
                        } else if(caseRecord.Status == 'Complete' && caseRecord.US_WSREMS__Outcome__c == 'Confirmed Non-compliance activity'){
                            caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCS Non-Complaince Notice');  
                        } else if(caseRecord.Status == 'Compliance Investigation' && caseRecord.US_WSREMS__Outcome__c == 'Confirmed Non-compliance activity'){
                            caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCS Non-Compliance Warning');  
                        }
                    } else if(result == 'sendemail'){
                        caseOrOutboundCommunicationRecord = caseRecord;
                    }
                } 
            } else if(caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == prescriberRecordType) {
                String result = checkEmailOrFax(caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c, caseRecord.US_WSREMS__X1_Participant__r.PersonEmail, caseRecord.US_WSREMS__X1_Participant__r.Fax);
                if(result == 'sendfax'){
                    if(caseRecord.Status == 'Compliance Investigation' && caseRecord.US_WSREMS__Outcome__c == 'Suspected Non-compliance activity'){
                        caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCP Non-Complaince Suspected');  
                    } else if(caseRecord.Status == 'Complete' && caseRecord.US_WSREMS__Outcome__c == 'Confirmed Non-compliance activity'){
                        caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCP Non-Complaince Notice');  
                    } else if(caseRecord.Status == 'Compliance Investigation' && caseRecord.US_WSREMS__Outcome__c == 'Confirmed Non-compliance activity'){
                        caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord,'Fax','AVEED_Conga HCP Non-Complaince Warning');  
                    }
                } else if(result == 'sendemail'){
                    caseOrOutboundCommunicationRecord = caseRecord;
                }
            }
        return caseOrOutboundCommunicationRecord;
    }
}