public class updateHCPorHCSCertifiedCheckboxOnCase {

    public static void updateIncompleteReasonOnInsertorUpdate(Boolean isUpdate, List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        Id hcsEnrollmentRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
        List<Case> caseToUpdate = new List<Case>();
        Set<id> accSetToQuery = new Set<id>();
        Map<String,Account> accMap = new Map<String,Account>();
        String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        String xiaflexprogramName = 'Xiaflex';
        for(case newCase: newCaseList){
            if(newCase.US_WSREMS__Program_Name__c == programName || newCase.US_WSREMS__Program_Name__c == xiaflexprogramName) {
                if(isUpdate) {
                    Case oldCase = oldCaseMap.get(newCase.Id);
                    if(oldCase.US_WSREMS__Healthcare_Setting__c != newCase.US_WSREMS__Healthcare_Setting__c && newCase.US_WSREMS__Healthcare_Setting__c != null && newCase.RecordTypeId == prescriberEnrollCaseRecTypeId){
                        accSetToQuery.add(newCase.US_WSREMS__Healthcare_Setting__c);
                    } else if(oldCase.US_WSREMS__Prescriber__c != newCase.US_WSREMS__Prescriber__c && newCase.US_WSREMS__Prescriber__c != null && newCase.RecordTypeId == hcsEnrollmentRecordType){
                        accSetToQuery.add(newCase.US_WSREMS__Prescriber__c);
                    }
                } else {
                    if(newCase.RecordTypeId == prescriberEnrollCaseRecTypeId && newCase.US_WSREMS__Healthcare_Setting__c != null){
                        accSetToQuery.add(newCase.US_WSREMS__Healthcare_Setting__c);
                    } else if(newCase.RecordTypeId == hcsEnrollmentRecordType && newCase.US_WSREMS__Prescriber__c != null){
                        accSetToQuery.add(newCase.US_WSREMS__Prescriber__c);
                    }
                }
            }
        }

        if(!accSetToQuery.isEmpty()){
            for(Account accountRec : [SELECT Id, Name, US_WSREMS__Status__c FROM Account WHERE Id In: accSetToQuery]){
                accMap.put(accountRec.Id, accountRec);
            }
        }

        if(!accMap.isEmpty()){
            List<Case> updateList = new List<Case>();
            for(Case newCase: newCaseList){
                Case caseRec = new Case();
                caseRec.Id = newCase.Id;
                if(newCase.RecordTypeId == prescriberEnrollCaseRecTypeId){ // Prescriber
                    if(newCase.US_WSREMS__Healthcare_Setting__c != null && accMap.containsKey(newCase.US_WSREMS__Healthcare_Setting__c) && accMap.get(newCase.US_WSREMS__Healthcare_Setting__c).US_WSREMS__Status__c != 'Certified'){//prescriber
                        if(isUpdate){
                            caseRec.HCSnotCertified__c = true;
                            updateList.add(caseRec);
                        } else {
                            newCase.HCSnotCertified__c = true;
                        }
                    } else {
                        if(isUpdate){
                            caseRec.HCSnotCertified__c = false;
                            updateList.add(caseRec);
                        } else {
                            newCase.HCSnotCertified__c = false;
                        }
                    }
                } else if(newCase.RecordTypeId == hcsEnrollmentRecordType){   
                    if(newCase.US_WSREMS__Prescriber__c != null && accMap.containsKey(newCase.US_WSREMS__Prescriber__c) && accMap.get(newCase.US_WSREMS__Prescriber__c).US_WSREMS__Status__c != 'Certified'){
                        if(isUpdate){
                            caseRec.HCPnotCertified__c = true;
                            updateList.add(caseRec);
                        } else {
                            newCase.HCPnotCertified__c = true;
                        }
                    } else{
                        if(isUpdate){
                            caseRec.HCPnotCertified__c = false;
                            updateList.add(caseRec);
                        } else {
                            newCase.HCPnotCertified__c = false;
                        }
                    }
                }
            }
            if(isUpdate && !updateList.isEmpty() && !Test.isRunningTest()){
                update updateList;
            }
        }
    }
}