public class SYN_EmailProcessor{
    public static void processAndTriggerCaseCommu(Boolean isInsert, Boolean isUpdate, Map<Id, Case> newMap, Map<Id, Case> oldMap){
                	List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Id riskMgmtReportRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
        Id enrollmentCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();
        Set<Id> caseIds = new Set<Id>();
        for(case emailCase : newMap.values()){
            if(isUpdate){
                if(emailCase.Approval_Status__c != oldMap.get(emailCase.Id).Approval_Status__c){
                    caseIds.add(emailCase.Id);
                }
            }
            else if(isInsert){
                caseIds.add(emailCase.Id);
            }
        }
        List<Case> caseList =[SELECT Id,recordTypeId,US_WSREMS__Participant__c,Status,ownerId,US_WSREMS__Participant__r.personContactId,US_WSREMS__Prescriber__r.Fax,US_WSREMS__Program_Name__c,Medical_Conditions__c,US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Patient__r.Fax,US_WSREMS__Pharmacy_User__r.Fax,owner.email,owner.name,CaseNumber,Subject,US_WSREMS__Prescriber__r.firstName, US_WSREMS__Prescriber__r.LastName, US_WSREMS__Patient__r.firstName, US_WSREMS__Patient__r.LastName, US_WSREMS__Pharmacy_User__r.firstName, US_WSREMS__Pharmacy_User__r.LastName From Case WHERE Id IN: caseIds]; 
        SYN_CorrespondenceHandler.EmailWrapperClass emailWrapValues = new SYN_CorrespondenceHandler.EmailWrapperClass();
        for(Case cas :caseList){
            if(cas.recordTypeId ==enrollmentCaseRecTypeId){
                stakeHolderEnrollMissingCaseEmailTriggering(cas);
            }
            else if(cas.recordTypeId ==riskMgmtReportRecTypeId && cas.Status == 'Complete'){
                riskMgmtReportCaseEmailTriggering(cas);
            }   
        }
    }
    public static void processAndTriggerRSSCommu(Boolean isInsert, Boolean isUpdate, Map<Id, US_WSREMS__REMS_Service_Summary__c> newMap, Map<Id, US_WSREMS__REMS_Service_Summary__c> oldMap){
        
    } 
    
    public static void riskMgmtReportCaseEmailTriggering(case triggeringCase){
                        	List<REMS_Outbound_Communication__c> communicationRecList=new List<REMS_Outbound_Communication__c>();
        if(triggeringCase.Status =='Complete' && triggeringCase.US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c =='Email'){ 
            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(triggeringCase,triggeringCase.US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c,'SOX-RiskManagementReportProcessedSuccess'));

        }
    }
    //SOX-Stakeholder_Enrollment_Missing_Info	
    public static void stakeHolderEnrollMissingCaseEmailTriggering(case triggeringCase){
                	List<REMS_Outbound_Communication__c> communicationRecList=new List<REMS_Outbound_Communication__c>();
        if(triggeringCase.Status =='Complete' && triggeringCase.US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c =='Email'){
                        communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(triggeringCase,triggeringCase.US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c,'SOX-Stakeholder_Enrollment_Missing_Info'));

        }
        else if(triggeringCase.Status =='Complete' && triggeringCase.US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c =='Fax'){
                        communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(triggeringCase,triggeringCase.US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c,'Con-StakeholderEnrollmentFormwithMissin'));

        }
    }
}