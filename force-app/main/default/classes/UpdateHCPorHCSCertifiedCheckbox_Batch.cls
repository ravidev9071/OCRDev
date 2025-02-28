public class UpdateHCPorHCSCertifiedCheckbox_Batch implements Database.Batchable<sObject>, Schedulable {

    public Static Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
    public Static Id hcsEnrollmentRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
    public Database.QueryLocator start(Database.BatchableContext bc){
    String certifiedStatus ='Certified';
    String pendingStatus ='Pending';
    Set<String> participantStatus = new Set<String>();
    participantStatus.add(certifiedStatus);
    participantStatus.add(pendingStatus);
    String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
    List<string> programList = new List<string>();
    programList.add(programName);
    programList.add(Label.Xiaflex_REMS_Program_Name);
        return Database.getQueryLocator([SELECT Id, RecordType.name,US_WSREMS__Incomplete_Reasons__c, HCSnotCertified__c, HCPnotCertified__c, US_WSREMS__Participant__r.US_WSREMS__Status__c,US_WSREMS__Prescriber__r.US_WSREMS__Status__c,US_WSREMS__Prescriber__c,US_WSREMS__Healthcare_Setting__r.US_WSREMS__Status__c,US_WSREMS__Healthcare_Setting__c
            FROM Case 
            WHERE US_WSREMS__Program_Name__c IN: programList
                AND (
                    (RecordTypeId =:prescriberEnrollCaseRecTypeId
                        AND HCSnotCertified__c = true
                        AND US_WSREMS__Healthcare_Setting__r.US_WSREMS__Status__c =:participantStatus
                    ) OR (
                        RecordTypeId =: hcsEnrollmentRecordType
                        AND HCPnotCertified__c = true
                        AND US_WSREMS__Prescriber__r.US_WSREMS__Status__c =:participantStatus
                    )
                )
                
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Case> caseList){
        List<Case> updateCase = new List<Case>();
        
            Map<Id, Case> hcsMapToIncompleteReasonMap = new Map<Id, Case>();

            for(Case caseRec: caseList){
                if(caseRec.US_WSREMS__Incomplete_Reasons__c == SYN_Utilitycls.HCS_NOT_CEERTIFIED || caseRec.US_WSREMS__Incomplete_Reasons__c == SYN_Utilitycls.HCP_NOT_CERTIFIED){
                    hcsMapToIncompleteReasonMap.put(caseRec.US_WSREMS__Participant__c, caseRec);
                }
            }
            
            for(Case caseRec: caseList){
            if(caseRec.RecordTypeId == prescriberEnrollCaseRecTypeId){
                if(caseRec.US_WSREMS__Healthcare_Setting__r.US_WSREMS__Status__c == 'Certified'){
                    caseRec.HCSnotCertified__c = false;
                    updateCase.add(caseRec);
                } else if(caseRec.US_WSREMS__Healthcare_Setting__r.US_WSREMS__Status__c == 'Pending' && hcsMapToIncompleteReasonMap.containskey(caseRec.US_WSREMS__Healthcare_Setting__c) &&  hcsMapToIncompleteReasonMap.get(caseRec.US_WSREMS__Healthcare_Setting__c).US_WSREMS__Prescriber__c ==  caseRec.US_WSREMS__Participant__c && hcsMapToIncompleteReasonMap.get(caseRec.US_WSREMS__Healthcare_Setting__c).US_WSREMS__Incomplete_Reasons__c == SYN_Utilitycls.HCP_NOT_CERTIFIED){
                    caseRec.HCSnotCertified__c = false;
                    updateCase.add(caseRec);
                }
            } else if(caseRec.RecordTypeId == hcsEnrollmentRecordType){
                if(caseRec.US_WSREMS__Prescriber__r.US_WSREMS__Status__c == 'Certified'){
                    caseRec.HCPnotCertified__c = false;
                    updateCase.add(caseRec);
                } else if(caseRec.US_WSREMS__Prescriber__r.US_WSREMS__Status__c == 'Pending' && hcsMapToIncompleteReasonMap.containskey(caseRec.US_WSREMS__Prescriber__c) && hcsMapToIncompleteReasonMap.get(caseRec.US_WSREMS__Prescriber__c).US_WSREMS__Healthcare_Setting__c ==  caseRec.US_WSREMS__Participant__c && hcsMapToIncompleteReasonMap.get(caseRec.US_WSREMS__Prescriber__c).US_WSREMS__Incomplete_Reasons__c == SYN_Utilitycls.HCS_NOT_CEERTIFIED){
                    caseRec.HCPnotCertified__c = false;
                    updateCase.add(caseRec);
                }
            } 
        }
        try{
            update updateCase;
        }catch(exception e){
            system.debug('--Error---'+e.getmessage());
        }
    }

    public void execute(SchedulableContext sc){
        Database.executeBatch(new UpdateHCPorHCSCertifiedCheckbox_Batch());
    }

    public void finish(Database.BatchableContext bc){
    }
}