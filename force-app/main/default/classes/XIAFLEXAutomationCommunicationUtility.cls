/* This class will send out an email with the correspondence templates */


public without sharing class XIAFLEXAutomationCommunicationUtility {

    /*Variables*/

    public Static Map < String, REMS_Correspondence_Settings__mdt > programTemplates; // Map of templates

    public Static Map < Id, String > caseRecordTypeIdToIncompleteMap = new Map < Id, String > ();
    public Static Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
    public Static Id hcsReEnrollmentRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Reenrollment');
    public Static Id hcsEnrollmentRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
    public Static Id nonComplianceRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
    public Static Id prescriberRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
    public Static Id hcsRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');
    public Static Id changeAuthRepRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Change_Authorized_Representative');
    public static string outcomeValesForNcSuspected = 'Suspected Non-compliance activity';
    public static String outcomeValuesForNcConfirmed = 'Confirmed Non-compliance activity';
    public static string nonComplianceStatusForSuspecOrWarning = 'Compliance Investigation';
    public static String caseStatusComplete = 'Complete';
    public static String caseStatusDraft = 'Draft';
    public static Set < String > accountSubstatuses = new Set < String > {
        'Program Opt-Out',
        'Enrollment Expired',
        'Noncompliant',
        'Non-compliance'
    };
    public static Set < String > accountStatus = new Set < String > {
        'Deactivated',
        'Decertified'
    };


    //  ----

    /*Send EmailCommunication */
    public static void sendCommunicationFromCaseWhileUpdateOrInsert(Boolean isUpdate, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {

        List < REMS_Outbound_Communication__c > communicationRecList = new List < REMS_Outbound_Communication__c > ();
        Map < Id, Boolean > incompleteReasons = new Map < Id, Boolean > ();
        String incompleteReaonsString = '<ul>';
        List < Case > caseListToSendEmail = New List < Case > ();
        Set < Id > caseIdToSendFax = New Set < Id > ();
        Set < Id > nonComplainceAccountIds = New Set < Id > ();
        Map < Id, US_WSREMS__Affiliation__c > accountIdToaffiliationMap = new Map < Id, US_WSREMS__Affiliation__c > ();

        Map < Id, String > recordTypeIdToProgramNameMap = new Map < Id, String > ();
        recordTypeIdToProgramNameMap.put(hcsReEnrollmentRecordType, 'HCS_Reenrollment');
        recordTypeIdToProgramNameMap.put(hcsEnrollmentRecordType, 'HCS_Enrollment');
        recordTypeIdToProgramNameMap.put(prescriberEnrollCaseRecTypeId, 'Prescriber_Enrollment');


        for (
            case caseRecord: newCaseMap.values()) {
            if (caseRecord.recordTypeId == nonComplianceRecordType) {
                nonComplainceAccountIds.add(caseRecord.US_WSREMS__X1_Participant__c);
            }

        }
        for (US_WSREMS__Affiliation__c affiliationRecord: AutomationCommunicationFromCase.getXiaflexAffiliationsRecordsByHcsAccountIds(nonComplainceAccountIds)) {
            if (!accountIdToaffiliationMap.containsKey(affiliationRecord.US_WSREMS__Health_Care_Setting__c)) {
                accountIdToaffiliationMap.put(affiliationRecord.US_WSREMS__Health_Care_Setting__c, affiliationRecord);
            }
        }
        for (Case caseRecord: AutomationCommunicationFromCase.getCasesByProgramAndCaseIds(newCaseMap.keySet(), SYN_Utilitycls.XIAFLEX_PROGRAM_NAME)) {
            if (!isUpdate) {
                if (
                    (caseRecord.Status == caseStatusComplete && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Email' && caseRecord.RecordTypeId == hcsReEnrollmentRecordType) ||
                    (caseRecord.Status == caseStatusComplete && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Email' && caseRecord.RecordTypeId == hcsEnrollmentRecordType) ||
                    (caseRecord.Status == caseStatusComplete && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Email' && caseRecord.RecordTypeId == prescriberEnrollCaseRecTypeId) ||
                    (caseRecord.US_WSREMS__Authorized_Representative_New_Primary_AR__r.US_WSREMS__Preferred_Contact_Method__c == 'Email' && caseRecord.RecordTypeId == changeAuthRepRecordType)
                ) {
                    // HCP Enroll Confirmation -- Email
                    // HCS Enroll Confirmation -- Email
                    // HCS reenroll confimation - Email
                    // Auth rep change confirmation - Email
                    caseListToSendEmail.add(caseRecord);
                } else if (
                    (caseRecord.Status == caseStatusComplete && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Fax' && caseRecord.RecordTypeId == hcsReEnrollmentRecordType) ||
                    (caseRecord.Status == caseStatusComplete && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Fax' && caseRecord.RecordTypeId == hcsEnrollmentRecordType) ||
                    (caseRecord.Status == caseStatusComplete && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Fax' && caseRecord.RecordTypeId == prescriberEnrollCaseRecTypeId) ||
                    (caseRecord.US_WSREMS__Authorized_Representative_New_Primary_AR__r.US_WSREMS__Preferred_Contact_Method__c == 'Fax' && caseRecord.RecordTypeId == changeAuthRepRecordType)
                ) {
                    communicationRecList = createREMSCommunicationForHCSorHcpEnroll(caseRecord);

                } else if (caseRecord.Status == caseStatusDraft && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Fax') {
                    if (caseRecord.RecordTypeId == prescriberEnrollCaseRecTypeId && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
                        communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCP Enrollment Missing Inf'));
                    } else if (caseRecord.RecordTypeId == prescriberEnrollCaseRecTypeId && caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
                        communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga HCP Enrollment Missg'));
                    } else if (caseRecord.RecordTypeId == hcsEnrollmentRecordType && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
                        communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCS Enrollment Missing Info'));
                    } else if (caseRecord.RecordTypeId == hcsEnrollmentRecordType && caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
                        communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga HCS Enrollment Missg'));
                    } else if (caseRecord.RecordTypeId == hcsReEnrollmentRecordType && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
                        communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCS Re-Enrol mis or Inv In'));
                    }
                } else if (caseRecord.RecordTypeId == nonComplianceRecordType) {
                    sObject caseCommunication = sendemailnotificatiofromnonComplaince(caseRecord, accountIdToaffiliationMap);
                    if (caseCommunication != null) {
                        SObjectType ObjectName = caseCommunication.getSObjectType();
                        if (String.valueOf(ObjectName) == 'Case') {
                            Case caseRec = (Case) caseCommunication;
                            caseListToSendEmail.add(caseRec);
                        } else {
                            REMS_Outbound_Communication__c communicationRec = (REMS_Outbound_Communication__c) caseCommunication;
                            communicationRecList.add(communicationRec);
                        }
                    }

                }

            } else if (isUpdate) {
                Case oldCase = oldCaseMap.get(caseRecord.Id);
                if (caseRecord.status == caseStatusComplete && caseRecord.RecordTypeId != nonComplianceRecordType) {
                    if (
                        (caseRecord.RecordTypeId == hcsReEnrollmentRecordType && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Email') ||
                        (caseRecord.RecordTypeId == hcsEnrollmentRecordType && oldCaseMap.get(caseRecord.Id).status != caseRecord.status && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Email') ||
                        (caseRecord.RecordTypeId == prescriberEnrollCaseRecTypeId && oldCaseMap.get(caseRecord.Id).status != caseRecord.status && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Email') ||
                        (caseRecord.US_WSREMS__Authorized_Representative_New_Primary_AR__r.US_WSREMS__Preferred_Contact_Method__c == 'Email' && caseRecord.RecordTypeId == changeAuthRepRecordType)
                    ) {
                        caseListToSendEmail.add(caseRecord);
                    }
                }
                if (caseRecord.Status == caseStatusComplete && caseRecord.RecordTypeId != nonComplianceRecordType) {
                    if (
                        (caseRecord.RecordTypeId == hcsReEnrollmentRecordType && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Fax') ||
                        (caseRecord.RecordTypeId == hcsEnrollmentRecordType && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Fax') ||
                        (caseRecord.RecordTypeId == prescriberEnrollCaseRecTypeId && caseRecord.US_WSREMS__Preferred_Contact_Method__c == 'Fax') ||
                        (caseRecord.US_WSREMS__Authorized_Representative_New_Primary_AR__r.US_WSREMS__Preferred_Contact_Method__c == 'Fax' && caseRecord.RecordTypeId == changeAuthRepRecordType)
                    ) {
                        communicationRecList = createREMSCommunicationForHCSorHcpEnroll(caseRecord);
                    }
                } else if (caseRecord.Status != oldCase.Status && caseRecord.RecordTypeId == nonComplianceRecordType) {
                    sObject caseCommunication = sendemailnotificatiofromnonComplaince(caseRecord, accountIdToaffiliationMap);
                    if (caseCommunication != null) {
                        SObjectType ObjectName = caseCommunication.getSObjectType();
                        if (String.valueOf(ObjectName) == 'Case') {
                            Case caseRec = (Case) caseCommunication;
                            caseListToSendEmail.add(caseRec);
                        } else {
                            REMS_Outbound_Communication__c communicationRec = (REMS_Outbound_Communication__c) caseCommunication;
                            communicationRecList.add(communicationRec);
                        }
                    }
                }

            }
        }

        if (communicationRecList != null && !communicationRecList.isEmpty()) {
            try {
                insert communicationRecList;
            } catch (exception ex) {
                system.debug('ex==' + ex);
                //TODO: add error handling
            }
        }

        if (!caseListToSendEmail.isEmpty()) {
            if (Limits.getQueueableJobs() == 1) {
                System.schedule(
                    'XiaflexCaseNotificationSchedulable' + String.valueOf(Math.random()),
                    SYN_CommonUtility.getAsynchronousExpression(),
                    new XiaflexCaseNotificationSchedulable(caseListToSendEmail)
                );
            } else {
                System.enqueueJob(new XiaflexCaseNotificationQueueableJob(caseListToSendEmail));
            }
        }
    }

    @TestVisible
    private static List < REMS_Outbound_Communication__c > createREMSCommunicationForHCSorHcpEnroll(
        case caseRecord) {
        List < REMS_Outbound_Communication__c > communicationRecList = new List < REMS_Outbound_Communication__c > ();

        if (caseRecord.RecordTypeId == prescriberEnrollCaseRecTypeId && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCP Enrollment Confirm'));
        } else if (caseRecord.RecordTypeId == prescriberEnrollCaseRecTypeId && caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga MDP HCP Enrollment Confirm'));
        } else if (caseRecord.RecordTypeId == hcsEnrollmentRecordType && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCS Enrollment Confirmatn'));
        } else if (caseRecord.RecordTypeId == hcsEnrollmentRecordType && caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga HCS Enrollment Confm'));
        } else if (caseRecord.RecordTypeId == hcsReEnrollmentRecordType && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCS Re-Enroll Confirmation'));
        } else if (caseRecord.RecordTypeId == hcsReEnrollmentRecordType && caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga HCS Re-Enroll Confirma'));
        } else if (caseRecord.RecordTypeId == changeAuthRepRecordType && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga Auth Rep Replace Confirm'));
        } else if (caseRecord.RecordTypeId == changeAuthRepRecordType && caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga Auth Rep Rep Confirm'));
        }
        return communicationRecList;
    }
    public static sObject sendemailnotificatiofromnonComplaince(
        case caseRecord, Map < Id, US_WSREMS__Affiliation__c > accountIdToaffiliationMap) {
        sObject caseOrOutboundCommunicationRecord;
        if (caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == prescriberRecordType) {

            if (caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c == 'Email') {
                caseOrOutboundCommunicationRecord = caseRecord;

            } else if (caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c == 'Fax') {
                if (caseRecord.Status == nonComplianceStatusForSuspecOrWarning && caseRecord.US_WSREMS__Outcome__c == outcomeValesForNcSuspected && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
                    caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCP Non-Complaince Sus');
                } else if (caseRecord.Status == nonComplianceStatusForSuspecOrWarning && caseRecord.US_WSREMS__Outcome__c == outcomeValesForNcSuspected && caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
                    caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga HCP Non-Complaince Sus');
                } else if (caseRecord.Status == caseStatusComplete && caseRecord.US_WSREMS__Outcome__c == outcomeValuesForNcConfirmed && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
                    caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCP Non-Complaince Notice');
                } else if (caseRecord.Status == caseStatusComplete && caseRecord.US_WSREMS__Outcome__c == outcomeValuesForNcConfirmed && caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
                    caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga HCP Non-Complaince Not');

                } else if (caseRecord.Status == nonComplianceStatusForSuspecOrWarning && caseRecord.US_WSREMS__Outcome__c == outcomeValuesForNcConfirmed && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
                    caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCP Non-Complaince Warning');
                } else if (caseRecord.Status == nonComplianceStatusForSuspecOrWarning && caseRecord.US_WSREMS__Outcome__c == outcomeValuesForNcConfirmed && caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
                    caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga HCP Non-Complaince War');
                }


            }

        } else if (accountIdToaffiliationMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c)) {
            US_WSREMS__Affiliation__c affilationrec = accountIdToaffiliationMap.get(caseRecord.US_WSREMS__X1_Participant__c);
            if (caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c == 'Email') {
                caseOrOutboundCommunicationRecord = caseRecord;
            } else if (caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c == 'Fax') {
                if (caseRecord.Status == nonComplianceStatusForSuspecOrWarning && caseRecord.US_WSREMS__Outcome__c == outcomeValesForNcSuspected && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
                    caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCS Non-Complaince Sus');
                } else if (caseRecord.Status == nonComplianceStatusForSuspecOrWarning && caseRecord.US_WSREMS__Outcome__c == outcomeValesForNcSuspected && caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
                    caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga HCS Non-Complaince Sus');
                } else if (caseRecord.Status == caseStatusComplete && caseRecord.US_WSREMS__Outcome__c == outcomeValuesForNcConfirmed && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
                    caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCS Non-Complaince Notice');
                } else if (caseRecord.Status == caseStatusComplete && caseRecord.US_WSREMS__Outcome__c == outcomeValuesForNcConfirmed && caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
                    caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga HCS Non-Complaince Not');
                } else if (caseRecord.Status == nonComplianceStatusForSuspecOrWarning && caseRecord.US_WSREMS__Outcome__c == outcomeValuesForNcConfirmed && caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
                    caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCS Non-Complaince Warning');
                } else if (caseRecord.Status == nonComplianceStatusForSuspecOrWarning && caseRecord.US_WSREMS__Outcome__c == outcomeValuesForNcConfirmed && caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
                    caseOrOutboundCommunicationRecord = SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga HCS Non-Complaince War');
                }
            }

        }
        return caseOrOutboundCommunicationRecord;
    }

    // Communication Sending Based on Account Status 
    public static String checkEmailOrFax(String preferredMethodOfContact, String email, String fax) {
        String result;
        if (preferredMethodOfContact == 'Email') {
            if (email != null) {
                result = 'sendemail';
            } else if (fax != null) {
                result = 'sendfax';
            }
        } else if (preferredMethodOfContact == 'Fax') {
            if (fax != null) {
                result = 'sendfax';
            } else if (email != null) {
                result = 'sendemail';
            }
        } else {
            if (email != null) {
                result = 'sendemail';
            }
        }
        return result;
    }

    public static REMS_Outbound_Communication__c createREMSCommunicationRecords(Account accountRec, String typeofCommunication, String templatename) {
        REMS_Outbound_Communication__c communicationRec = new REMS_Outbound_Communication__c();
        communicationRec.Recipient__c = accountRec.Id;
        communicationRec.Template__c = templatename;
        communicationRec.Status__c = 'Pending';
        communicationRec.OBCom_Type__c = typeofCommunication;
        return communicationRec;
    }
    //changed by Pratap M for correspondence templates on 18-10-2024....Removed unreachable code such as nonComplainceAccountIds and its reference

    public static void sendFaxCommunicationFromAccountWhileUpdate(Map < Id, Account > newAccoutMap, Map < Id, Account > oldAccoutMap) {
        List < REMS_Outbound_Communication__c > communicationRecList = new List < REMS_Outbound_Communication__c > ();
        Map < Id, US_WSREMS__Affiliation__c > accountIdToaffiliationMap = new Map < Id, US_WSREMS__Affiliation__c > ();
        List < Case > caseList = new List < Case > ();
        Set < Id > accountIdsToSendFax = new Set < Id > ();
        Set < Id > nonComplainceAccountIds = new Set < Id > ();
        List < Account > accountSendEmailList = new List < Account > ();
        List < Case > caseSendEmailList = new List < Case > ();

        for (Account accountRecord: newAccoutMap.values()) {
            Account oldAccountRecord = oldAccoutMap.get(accountRecord.Id);
            if (accountRecord.US_WSREMS__Status__c != oldAccountRecord.US_WSREMS__Status__c &&
                accountRecord.US_WSREMS__Sub_Status__c != oldAccountRecord.US_WSREMS__Sub_Status__c
            ) {
                if (accountRecord.US_WSREMS__Status__c == 'Decertified' && accountRecord.US_WSREMS__Sub_Status__c == 'Non-compliance' &&
                    (accountRecord.recordTypeId == prescriberRecordType || accountRecord.recordTypeId == hcsRecordType)
                ) {
                    nonComplainceAccountIds.add(accountRecord.Id);
                } else if ((accountStatus.contains(accountRecord.US_WSREMS__Status__c) || accountSubstatuses.contains(accountRecord.US_WSREMS__Sub_Status__c)) &&
                    (accountRecord.recordTypeId == prescriberRecordType || accountRecord.recordTypeId == hcsRecordType)
                ) {
                    accountIdsToSendFax.add(accountRecord.Id);
                }
            }
        }

        if (!accountIdsToSendFax.isEmpty()) {
            for (US_WSREMS__Affiliation__c affiliationRecord: AutomationCommunicationFromCase.getXiaflexAffiliationsRecordsByHcsAccountIds(accountIdsToSendFax)) {
                if (!accountIdToaffiliationMap.containsKey(affiliationRecord.US_WSREMS__Health_Care_Setting__c)) {
                    accountIdToaffiliationMap.put(affiliationRecord.US_WSREMS__Health_Care_Setting__c, affiliationRecord);
                }
            }
        }

        for (Account accountRecord: newAccoutMap.values()) {
            Account oldAccountRecord1 = oldAccoutMap.get(accountRecord.Id);
            if (accountRecord.US_WSREMS__Status__c != oldAccountRecord1.US_WSREMS__Status__c) {
                if (accountRecord.US_WSREMS__Status__c == 'Deactivated' && accountRecord.US_WSREMS__Sub_Status__c == 'Program Opt-Out' &&
                    accountRecord.recordTypeId == prescriberRecordType
                ) {
                    String result = checkEmailOrFax(accountRecord.US_WSREMS__Preferred_Contact_Method__c, accountRecord.PersonEmail, accountRecord.Fax);
                    //Added by pratap M Deactivation condition as per sandeep comments
                    if (result == 'sendfax' && accountRecord.US_WSREMS__Status__c == 'Deactivated') {
                        if (accountRecord.US_WSREMS__Program_Type__c == 'REMS') {
                            communicationRecList.add(createREMSCommunicationRecords(accountRecord, 'Fax', 'XIAFLEX_Conga HCP Opt-Out Confirm'));

                        } else if (accountRecord.US_WSREMS__Program_Type__c == 'MDP') {
                            communicationRecList.add(createREMSCommunicationRecords(accountRecord, 'Fax', 'XIAFLEX_MDP_Conga HCP Opt-Out Confirm'));

                        }
                    } else if (result == 'sendemail') {
                        accountSendEmailList.add(accountRecord);
                    }
                } else if (accountRecord.US_WSREMS__Status__c == 'Deactivated' &&
                    accountSubstatuses.contains(accountRecord.US_WSREMS__Sub_Status__c) &&
                    accountRecord.recordTypeId == hcsRecordType
                ) {
                    if (accountIdToaffiliationMap.containsKey(accountRecord.Id)) {
                        US_WSREMS__Affiliation__c affilationrec = accountIdToaffiliationMap.get(accountRecord.Id);
                        String result = checkEmailOrFax(accountRecord.US_WSREMS__Preferred_Contact_Method__c, affilationrec.US_WSREMS__Authorized_Representative__r.PersonEmail, affilationrec.US_WSREMS__Authorized_Representative__r.Fax);
                        if (result == 'sendfax') {
                            if (accountRecord.US_WSREMS__Program_Type__c == 'REMS') {
                                communicationRecList.add(createREMSCommunicationRecords(accountRecord, 'Fax', 'XIAFLEX_Conga HCS Opt-out Confirmation'));

                            } else if (accountRecord.US_WSREMS__Program_Type__c == 'MDP') {
                                communicationRecList.add(createREMSCommunicationRecords(accountRecord, 'Fax', 'XIAFLEX_MDP_Conga HCS Opt-out Confirm'));

                            }
                        } else if (result == 'sendemail') {
                            accountSendEmailList.add(accountRecord);
                        }
                    }
                } else if (accountStatus.contains(accountRecord.US_WSREMS__Status__c) && accountSubstatuses.contains(accountRecord.US_WSREMS__Sub_Status__c) &&
                    accountRecord.recordTypeId == hcsRecordType
                ) {
                    if (accountIdToaffiliationMap.containsKey(accountRecord.Id)) {
                        US_WSREMS__Affiliation__c affilationrec = accountIdToaffiliationMap.get(accountRecord.Id);
                        String result = checkEmailOrFax(accountRecord.US_WSREMS__Preferred_Contact_Method__c, affilationrec.US_WSREMS__Authorized_Representative__r.PersonEmail, affilationrec.US_WSREMS__Authorized_Representative__r.Fax);
                        if (result == 'sendfax') {
                            communicationRecList.add(createREMSCommunicationRecords(accountRecord, 'Fax', 'XIAFLEX_Conga HCS Enrollment Deactivation'));
                        } else if (result == 'sendemail') {
                            accountSendEmailList.add(accountRecord);
                        }
                    }
                }
            }
        }

        List < Case > nonComplainceCaseList = new List < Case > ();
        if (!nonComplainceAccountIds.isEmpty()) {
            nonComplainceCaseList = AutomationCommunicationFromCase.getNonComplanceCasesByProgramAndaccountIds(nonComplainceAccountIds, SYN_Utilitycls.XIAFLEX_PROGRAM_NAME);
            Map < Id, Case > accountIdToCaseMap = new Map < Id, Case > ();
            for (US_WSREMS__Affiliation__c affiliationRecord: AutomationCommunicationFromCase.getXiaflexAffiliationsRecordsByHcsAccountIds(nonComplainceAccountIds)) {
                if (!accountIdToaffiliationMap.containsKey(affiliationRecord.US_WSREMS__Health_Care_Setting__c)) {
                    accountIdToaffiliationMap.put(affiliationRecord.US_WSREMS__Health_Care_Setting__c, affiliationRecord);
                }
            }
            for (Case caseRecord: nonComplainceCaseList) {
                if (!accountIdToCaseMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c)) {
                    accountIdToCaseMap.put(caseRecord.US_WSREMS__X1_Participant__c, caseRecord);
                }

                if (caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Status__c == 'Decertified' && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Sub_Status__c == 'Non-compliance' &&
                    accountIdToCaseMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c) && accountIdToCaseMap.get(caseRecord.US_WSREMS__X1_Participant__c) == caseRecord &&
                    caseRecord.US_WSREMS__X1_Participant__r.recordTypeId == hcsRecordType
                ) {
                    if (accountIdToaffiliationMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c)) {
                        US_WSREMS__Affiliation__c affilationrec = accountIdToaffiliationMap.get(caseRecord.US_WSREMS__X1_Participant__c);
                        String result = checkEmailOrFax(caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c, affilationrec.US_WSREMS__Authorized_Representative__r.PersonEmail, affilationrec.US_WSREMS__Authorized_Representative__r.Fax);
                        if (result == 'sendfax') {
                            if (caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
                                communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCS Non-Compliance Deactn'));

                            } else if (caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
                                communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga HCS Non-Compli Deactn'));
                            }
                        } else if (result == 'sendemail') {
                            caseSendEmailList.add(caseRecord);
                        }
                    }
                } else if (caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Status__c == 'Decertified' && caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Sub_Status__c == 'Non-compliance' &&
                    accountIdToCaseMap.containsKey(caseRecord.US_WSREMS__X1_Participant__c) && accountIdToCaseMap.get(caseRecord.US_WSREMS__X1_Participant__c) == caseRecord &&
                    caseRecord.US_WSREMS__X1_Participant__r.recordTypeId == prescriberRecordType
                ) {
                    // hcp non-compliance notification for account
                    String result = checkEmailOrFax(caseRecord.US_WSREMS__X1_Participant__r.US_WSREMS__Preferred_Contact_Method__c, caseRecord.US_WSREMS__X1_Participant__r.PersonEmail, caseRecord.US_WSREMS__X1_Participant__r.Fax);
                    if (result == 'sendfax') {
                        if (caseRecord.US_WSREMS__Program_Type__c == 'REMS') {
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_Conga HCP Non-Compliance Deactn'));

                        } else if (caseRecord.US_WSREMS__Program_Type__c == 'MDP') {
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseRecord, 'Fax', 'XIAFLEX_MDP_Conga HCP Non-Comp Deactn'));
                        }
                    } else if (result == 'sendemail') {
                        caseSendEmailList.add(caseRecord);
                    }
                }
            }
        }

        if (!accountSendEmailList.isEmpty()) {
            SendEmailNotifications.sendXiaflexAccountDeactivationNotificationFromAccount(accountSendEmailList, accountIdToaffiliationMap);
        }

        if (!caseSendEmailList.isEmpty()) {
            SendEmailNotifications.sendXiaflexAccountDeactivationNotificationForNonCompliance(caseSendEmailList, accountIdToaffiliationMap);
        }

        if (communicationRecList != null && !communicationRecList.isEmpty()) {
            try {
                insert communicationRecList;
            } catch (exception ex) {
                system.debug('ex==' + ex);
                //TODO: add error handling
            }
        }
    }

    /**
    @Description : To send the HCS renewal reminder emails to affliliated HCP of HCS for XIAFLEX
    @Parameter : List<Id>
    @return : void
    **/
    @InvocableMethod(label = 'Send Notification XIAFLEX'
        category = 'Account')
    public static void sendNotificationFromFlow(List < Id > accIdList) {
        List < REMS_Outbound_Communication__c > communicationRecList = new List < REMS_Outbound_Communication__c > ();
        Map < String, Id > owaMap = SendEmailNotifications.getOrgWideAddresses();
        List < Messaging.SingleEmailMessage > emailMessageList = new List < Messaging.SingleEmailMessage > ();
        Map < String, String > emailTemplateMap = SendEmailNotifications.getEmailTemplateNameAll('XIAFLEX');
        Map < String, String > emailTemplateIdMap = SendEmailNotifications.getEmailTemplateIdsAll(emailTemplateMap);
        Id hcsEnrollment = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        List < String > toAddresses = new List < String > ();
        String bccAddress = System.Label.Xiaflex_REMS_BCC_Email_for_Correspondence_Templates;
        String[] bccAddresses = bccAddress.split(';');

        String templateName = '';
        Map < String, EmailTemplate > xiflexEmailtemplateMap = SendEmailNotifications.getXiaflexEmailTemplateMap();

        Contact con = SendEmailNotifications.getContact();
        Map < Id, Case > accountCaseMap = new Map < Id, Case > ();
        List < Case > cases = [SELECT Id, US_WSREMS__Participant__c, US_WSREMS__Participant__r.US_WSREMS__Recertification_Due_Date__c,
            US_WSREMS__Participant__r.Name, US_WSREMS__Program_Type__c, US_WSREMS__Address_Line_1__c,
            US_WSREMS__Address_Line_2__c, US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Zip__c,
            US_WSREMS__First_Name_ar__c, US_WSREMS__Last_Name_ar__c, US_WSREMS__REMS_ID__c,
            US_WSREMS__Participant__r.FirstName, US_WSREMS__Participant__r.LastName
            FROM Case WHERE US_WSREMS__Participant__c IN: accIdList
            AND(Recordtype.name = 'HCS Enrollment'
                OR Recordtype.name = 'HCS Reenrollment')
            Order BY Createddate DESC
        ];
        for (Case c: cases) {
            if (!accountCaseMap.containsKey(c.US_WSREMS__Participant__c)) {
                accountCaseMap.put(c.US_WSREMS__Participant__c, c);
            }
        }
        List < US_WSREMS__Affiliation__c > listAff = [SELECT id, recordtype.name, US_WSREMS__Authorized_Representative__c,
            US_WSREMS__Prescriber__r.US_WSREMS__Email__c,
            US_WSREMS__Prescriber__r.FirstName, US_WSREMS__Prescriber__r.LastName,
            US_WSREMS__Prescriber__r.US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__isActive__c,
            US_WSREMS__Health_Care_Setting__r.US_WSREMS__Program_Type__c
            FROM US_WSREMS__Affiliation__c
            WHERE US_WSREMS__isActive__c = true AND US_WSREMS__Prescriber__c != null
            AND US_WSREMS__REMSProgram__r.name = 'XIAFLEX'
            AND US_WSREMS__Health_Care_Setting__c IN: accIdList
        ];
        Map < String, OrgWideEmailAddress > owaAddressMap = SYN_CommonUtility.getOrgWideAddressesMap();
        for (US_WSREMS__Affiliation__c aff: listAff) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if (aff.US_WSREMS__Prescriber__c != null && aff.US_WSREMS__Prescriber__r.US_WSREMS__Preferred_Contact_Method__c == 'Email') {
                Id csId = accountCaseMap.get(aff.US_WSREMS__Health_Care_Setting__c).Id;
                if (aff.US_WSREMS__Prescriber__r.US_WSREMS__Email__c != null && aff.US_WSREMS__Prescriber__r.US_WSREMS__Email__c != '') {
                    toAddresses.add(aff.US_WSREMS__Prescriber__r.US_WSREMS__Email__c);
                    templateName = 'Xiaflex_HCP_Aff_HCS_Cer_Ren_Rem';
                }
                Case caseRecord = accountCaseMap.get(aff.US_WSREMS__Health_Care_Setting__c);
                if (toAddresses.size() > 0) {
                    email = SendEmailNotifications.sendXiaflexemail(accountCaseMap.get(aff.US_WSREMS__Health_Care_Setting__c), toAddresses, emailTemplateIdMap.get(templateName), xiflexEmailtemplateMap, owaAddressMap);
                    String xiaflexHtmlBody = xiflexEmailtemplateMap.get(templateName).markup;
                    Datetime expDate = accountCaseMap.get(aff.US_WSREMS__Health_Care_Setting__c).US_WSREMS__Participant__r.US_WSREMS__Recertification_Due_Date__c;
                    xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_Enrollment_Expiration_Date}}', expDate != null ? String.valueof(expDate) : '');
                    String name = caseRecord.US_WSREMS__Participant__r.Name != null ? caseRecord.US_WSREMS__Participant__r.Name : '';
                    String addressLine1 = caseRecord.US_WSREMS__Address_Line_1__c != null ? caseRecord.US_WSREMS__Address_Line_1__c : '';
                    String addressLine2 = caseRecord.US_WSREMS__Address_Line_2__c != null ? caseRecord.US_WSREMS__Address_Line_2__c : '';
                    String city = caseRecord.US_WSREMS__City__c != null ? caseRecord.US_WSREMS__City__c : '';
                    String state = caseRecord.US_WSREMS__State__c != null ? caseRecord.US_WSREMS__State__c : '';
                    String zip = caseRecord.US_WSREMS__Zip__c != null ? caseRecord.US_WSREMS__Zip__c : '';
                    String fName = aff.US_WSREMS__Prescriber__r.FirstName != null ? aff.US_WSREMS__Prescriber__r.FirstName : '';
                    String lName = aff.US_WSREMS__Prescriber__r.LastName != null ? aff.US_WSREMS__Prescriber__r.LastName : '';

                    xiaflexHtmlBody = xiaflexHtmlBody.replace('{!relatedTo.US_WSREMS__First_Name_ar__c}', fName != '' ? fName : '');
                    xiaflexHtmlBody = xiaflexHtmlBody.replace('{!relatedTo.US_WSREMS__Last_Name_ar__c}', lName != '' ? lName : '');
                    xiaflexHtmlBody = xiaflexHtmlBody.replace('{{REMS_ID}}', caseRecord.US_WSREMS__REMS_ID__c != null ? caseRecord.US_WSREMS__REMS_ID__c : '');
                    xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_NAME}}', name != '' ? name : '');
                    xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_ADDRESS}}', addressLine1 != '' ? addressLine1 : '');
                    xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_ADDRESS2}}', addressLine2 != '' ? addressLine2 : '');
                    xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_CITY}}', city != '' ? city + ', ' : '');
                    xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_STATE}}', state != '' ? state + ', ' : '');
                    xiaflexHtmlBody = xiaflexHtmlBody.replace('{{HCS_ZIP}}', zip != '' ? zip : '');

                    email.setHtmlBody(xiaflexHtmlBody);
                    email.setSubject(xiflexEmailtemplateMap.get(templateName).Subject);
                    email.setBccAddresses(bccAddresses);
                    emailMessageList.add(email);
                    if (!emailMessageList.isEmpty()) {
                        SendEmailNotifications.triggerEmailsToRecipients(emailMessageList);
                    }
                }
            } else if (aff.US_WSREMS__Prescriber__r.US_WSREMS__Preferred_Contact_Method__c == 'Fax') {
                communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(accountCaseMap.get(aff.US_WSREMS__Health_Care_Setting__c), 'Fax', 'XIAFLEX_Conga HCP Enrollment Confirm'));
            }
        }
        if (communicationRecList != null && !communicationRecList.isEmpty()) {
            try {
                insert communicationRecList;
            } catch (exception ex) {
                system.debug('ex==' + ex);
            }
        }
    }
}