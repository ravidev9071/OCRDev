/**
* @File Name          : SYN_CaseTrigger
* @Handler            : SYN_CaseTriggerHanlder
* @TestClass          : SYN_CaseTriggerHanlder_Test
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 1.0    02/22/2022        Chaitanya Nandamuri (Wilco)     Initial Implementation
* 2.0    03/22/2022        Raja Durai/ Praveen (Wilco)     handleAfterUpdate Method(Sprint-6: To update Account Via case)
* 3.0    03/29/2022        Chaitanya Nandamuri (Wilco)     completeCasestatus (BT6825-147 : Close Rems Service on Case completion)
*4.0     04/11/2022        Praveen Vellaki(Wilco)         Line16- Before Insert- setRDAMACICaseStatusToComplete() - 
Set RDA case status to complete on creation of case for MACI - 7433-172
*5.0     30/11/2022        Ashish Y (Wilco)                As per story 335 , Submit approval process method has been added to after insert
and after update
*6.0      16/2/2023       Praveen v (Wilco)                 BT7433- 430 -Line 69: After Insert -SYN_CaseTriggerHelper.MACIAutomationCommunicationFromCase(Trigger.new);                  
**/
trigger SYN_CaseTrigger on Case (before Insert, before update, before delete , after Insert, after update, after delete) {
map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
String soxProgram = 'Sodium Oxybate REMS';
String maciProgram = 'Macitentan REMS';
String piaskyProgram = 'PiaSky REMS';
    String tryvioProgram = 'TRYVIO REMS';
String xiaflexProgram = 'XIAFLEX';
String aveedProgram = 'AVEED REMS';
Boolean CaseMethodDisable = Trigger_Method_Controller__mdt.getInstance('Production_MACI_Controller').Disable_Case_Method__c ;   
if(SYN_CommonUtility.triggerByPass())
    return;
if(SYN_SkipCaseTrigger.skipCaseTrigger)
    return;    
if (trigger.isBefore){
    if(CaseMethodDisable){
        SYN_CaseTriggerHanlder.assignProgram(trigger.new); 
        SYN_CaseTriggerHanlder.updatePortalSharingAcctfield(trigger.new); 
    }else{
    if (trigger.isInsert){
        Map<String, Map<Id, List<Case>>> prgmRTAndCaseListMap = SYN_CaseTriggerHanlder.filterCasesByPrgm(Trigger.new);
        
        SYN_CaseTriggerHanlder.assignProgram(trigger.new); 
        
        if(prgmRTAndCaseListMap.containsKey(maciProgram)){
            SYN_CaseTriggerHanlder.updateChangeARStatus(trigger.new,null);
            SYN_CaseTriggerHanlder.setAccountCaseStatusToComplete(trigger.new);
            SYN_CaseTriggerHelper.reverseRDAValidationOnService(trigger.new);
            SYN_CaseTriggerHanlder.getShipmentRelatedDataForMACIRDA(trigger.new);
            SYN_CaseTriggerHanlder.setRDAMACICaseStatusToComplete(trigger.new);
        }
        else if (prgmRTAndCaseListMap.containsKey(SYN_Utilitycls.PiaSky_PROGRAM_NAME)) {
             SYN_CaseTriggerHanlder.setRDAMACICaseStatusToComplete(trigger.new);
            SYN_CaseTriggerHanlder.piaskyAffiliatedwithCertifiedPharmacy(trigger.new,null);
       }
        if(prgmRTAndCaseListMap.containsKey(soxProgram) || prgmRTAndCaseListMap.containsKey(maciProgram)){
            SYN_CaseTriggerHanlder.customValidation(trigger.new);
            SYN_CaseTriggerHanlder.updateParticipantField(trigger.new);
        }
          
           SYN_CaseTriggerHanlder.updateCaseRDACode(Trigger.new);
            SYN_CaseTriggerHanlder.DOBValidation(trigger.new);
            SYN_CaseTriggerHanlder.updatePortalSharingAcctfield(trigger.new); 

        if(prgmRTAndCaseListMap.containsKey(soxProgram)){
            SYN_CaseTriggerHanlder.createfacility(trigger.new);
            SYN_CaseTriggerHanlder.updateKAcaseOutcome(trigger.new);
            SYN_CaseTriggerHanlder.restrictPCCLRDACases(trigger.new);
            SYN_CaseTriggerHanlder.RDAMatchReverseRDAPharmacy(trigger.New);
            SYN_CaseTriggerHanlder.SLNNullvalidationBeforeInsert(trigger.New);
            SYN_CaseTriggerHanlder.validateKnowledgeAssessment(trigger.New);
        }


        if(prgmRTAndCaseListMap.containsKey(aveedProgram) || prgmRTAndCaseListMap.containsKey(xiaflexProgram)){
            SYN_CaseTriggerHanlder.updatePrograRecTypeControl(trigger.new);
            updateHCPorHCSCertifiedCheckboxOnCase.updateIncompleteReasonOnInsertorUpdate(false, trigger.new, null);
            SYN_CaseTriggerHanlder.preventPrescriberDuplicateNPI(trigger.new);
           
        }
        
        if(prgmRTAndCaseListMap.containsKey(maciProgram)){
            SYN_CaseTriggerHanlder.affiliatedwithCertifiedPharmacy(trigger.new,null);
            SYN_CaseTriggerHanlder.updateCaseDateonComplete(trigger.new,null);
            SYN_CaseTriggerHanlder.setEnrollmentCaseOutcomeToComplete(trigger.new, null); 
            SYN_CaseTriggerHanlder.updateParticipantAccountNPIStatusForVeeva(trigger.new);
            SYN_CaseTriggerHanlder.updateReverseRDACaseStatus(Trigger.new);
        }
        else if (prgmRTAndCaseListMap.containsKey(System.Label.Tryvio_Program)) {
            SYN_CaseTriggerHanlder.setRDATRYVIOCaseStatusToComplete(trigger.new);
        }
        if(prgmRTAndCaseListMap.containsKey(xiaflexProgram)){
            SYN_CaseTriggerHanlder.updateIncompleteReasonForIdentifier(trigger.new);
        }
        //  SYN_CaseTriggerHanlder.restrictSameCaseType(trigger.new);
    } else if (trigger.isUpdate){
        Map<String, Map<Id, List<Case>>> prgmRTAndCaseListMap = SYN_CaseTriggerHanlder.filterCasesByPrgm(Trigger.new);
            if(prgmRTAndCaseListMap.containsKey(soxProgram)){
                SYN_CaseTriggerHanlder.updateAccountStatus(trigger.new);
            }
        if(prgmRTAndCaseListMap.containsKey(SYN_Utilitycls.PiaSky_PROGRAM_NAME) || prgmRTAndCaseListMap.containsKey(SYN_Utilitycls.TRYVIO_PROGRAM_NAME)) {
                SYN_CaseTriggerHanlder.populateSponserDate(Trigger.New); //104 PiaSky
        }
        if(prgmRTAndCaseListMap.containsKey(xiaflexProgram)){
            SYN_CaseTriggerHanlder.updateIncompleteReasonForIdentifier(trigger.new);
            SYN_CaseTriggerHanlder.SponsorAcknowledgementDate(trigger.new);
        }
            
 if(prgmRTAndCaseListMap.containsKey(soxProgram) || prgmRTAndCaseListMap.containsKey(maciProgram)){
            SYN_CaseTriggerHanlder.customValidation(trigger.new);
            SYN_CaseTriggerHanlder.updateParticipantField(trigger.new);
            }
            SYN_CaseTriggerHanlder.updateCaseRDACode(Trigger.newMap, Trigger.oldMap);
            SYN_CaseTriggerHanlder.DOBValidation(trigger.new);
            SYN_CaseTriggerHanlder.updatePortalSharingAcctfield(trigger.new);  
        if(prgmRTAndCaseListMap.containsKey(soxProgram)){
            SYN_CaseTriggerHanlder.createfacility(trigger.new);
            SYN_CaseTriggerHanlder.updateKAcaseOutcome(trigger.new); 
            SYN_CaseTriggerHanlder.restrictPCCLRDACases(trigger.new);
            SYN_CaseTriggerHanlder.RDAMatchReverseRDAPharmacy(trigger.new);
            SYN_CaseTriggerHanlder.validateKnowledgeAssessment(trigger.New);
        }
        if(prgmRTAndCaseListMap.containsKey(maciProgram)){
            SYN_CaseTriggerHanlder.updateChangeARStatus(trigger.new,null);
            SYN_CaseTriggerHanlder.affiliatedwithCertifiedPharmacy(trigger.new,Trigger.oldMap);
            SYN_CaseTriggerHanlder.updateCaseDateonComplete(trigger.new,trigger.oldMap);
            SYN_CaseTriggerHanlder.setEnrollmentCaseOutcomeToComplete(trigger.new, Trigger.oldMap);
        }
        if(prgmRTAndCaseListMap.containsKey(aveedProgram)){
            SYN_CaseTriggerHanlder.SponsorAcknowledgementDate(trigger.new);
            SYN_CaseTriggerHanlder.checkKAAttempts(trigger.new, Trigger.oldMap);
        }
        if (prgmRTAndCaseListMap.containsKey(System.Label.Tryvio_Program)) {
            SYN_CaseTriggerHanlder.checkKAAttempts(trigger.new, Trigger.oldMap);
       }
    }
  }
} if(Trigger.isAfter){
  if(CaseMethodDisable){
            SYN_SharingUtility.createCaseSharingRecs(Trigger.new);
            SYN_CaseTriggerHanlder.updateAccount(Trigger.new, trigger.oldMap);
   }else{
    if(Trigger.isUpdate){
        Map<String, Map<Id, List<Case>>> prgmRTAndCaseListMap = SYN_CaseTriggerHanlder.filterCasesByPrgm(Trigger.new);
        Id PAE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PAE').getRecordTypeId();
        
         if(prgmRTAndCaseListMap.containsKey(tryvioProgram) &&  trigger.new[0].RecordTypeId == PAE ){
            AutomationCommunicationFromCase.getAutomationCommunicationFromCase(trigger.new, tryvioProgram);
        }
   
        if(prgmRTAndCaseListMap.containsKey(soxProgram)){
            SYN_CaseTriggerHanlder.updateAccountStatus(trigger.new);
            SYN_CaseTriggerHanlder.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
        if(prgmRTAndCaseListMap.containsKey(maciProgram)){
            SYN_CaseTriggerHanlder.completeCasestatusOnUpdate(Trigger.new, trigger.oldMap);
        }
            SYN_CaseTriggerHanlder.ChangeOfInformation(Trigger.newMap, Trigger.oldMap);
        if(prgmRTAndCaseListMap.containsKey(soxProgram)){
            SYN_SOXCorrespondenceHandler.stakeholderEnrollMissingInfo(Trigger.isInsert, Trigger.isUpdate,Trigger.newMap, Trigger.oldMap);
            SYN_SOXCorrespondenceHandler.kAResults(Trigger.isInsert, Trigger.isUpdate,Trigger.newMap, Trigger.oldMap);
        }
        SYN_CaseTriggerHanlder.updateAccount(Trigger.new, trigger.oldMap);
            SYN_CaseTriggerHanlder.caseValuesForAccountStatusUpdation(Trigger.new,Trigger.oldMap);
        if(prgmRTAndCaseListMap.containsKey(maciProgram)){
            SYN_CaseTriggerHanlder.updateCaseAccount(Trigger.new);
            SYN_CaseTriggerHanlder.UpdateAccountAndServiceStatus(Trigger.new,Trigger.oldMap);
            SYN_CaseTriggerHanlder.createChecklists(Trigger.newMap,Trigger.oldMap);
            SYN_CaseTriggerHanlder.updateChannelonAccountFromCase(Trigger.new);
        }
            
        //732 user story
        if(prgmRTAndCaseListMap.containsKey(soxProgram)){
            SYN_CaseTriggerHanlder.updateAccountUserType(trigger.new, trigger.oldMap); 
            //977 user story
            SYN_CaseTriggerHanlder.remsServiceUpdate(Trigger.New,Trigger.oldMap);    
    
        if(SYN_CaseTriggerHanlder.firstTrig)
        {
            SYN_CaseTriggerHanlder.firstTrig = false;
            SYN_CaseTriggerHanlder.submitApprovalProcess(trigger.new);//for approval process added by Ashish Y[Wilco]
        }
            SYN_CaseTriggerHanlder.updateAccountMonitor(Trigger.new); // for Monitor participant added by AshishY   
       }
       if(prgmRTAndCaseListMap.containsKey(maciProgram)){
            SYN_CaseTriggerHanlder.RootCauseAnalysis(Trigger.new,Trigger.oldMap); // RCA
            RCA_Automation.MisclassificationReviewPendingTask(Trigger.new);
            
        }
        if(prgmRTAndCaseListMap.containsKey(piaskyProgram)){
            Piasky_AutomatedTaskCreation.createNoncomplainceTask(trigger.new, trigger.oldMap, true, piaskyProgram); 
             PiaSky_NPISearchController.NPIvalidationPiasky(trigger.new, trigger.oldMap, true); 
             AutomationCommunicationFromCase.getAutomationCommunicationFromCase(Trigger.new,piaskyProgram);
             SYN_CaseTriggerHanlder.CompleteTaskoncaseclosure(Trigger.new,Trigger.oldMap);
        }
        if(prgmRTAndCaseListMap.containsKey(tryvioProgram)){
            Tryvio_AutomatedTaskCreation.createNoncomplainceTask(trigger.new, trigger.oldMap, true, tryvioProgram);
        }
        if(prgmRTAndCaseListMap.containsKey(aveedProgram)){
            AVEEDAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(true, trigger.newMap, trigger.oldMap);
            updateHCPorHCSCertifiedCheckboxOnCase.updateIncompleteReasonOnInsertorUpdate(true, trigger.new, trigger.oldMap);
            PiaSky_NPISearchController.NPIvalidationPiasky(trigger.new, trigger.oldMap, true); 
            SYN_CaseTriggerHanlder.updateKACheckBoxonAccount(trigger.new);
            SYN_CaseTriggerHanlder.updateAVEEDARonHCSAccount(Trigger.new);
        }
        if(prgmRTAndCaseListMap.containsKey(xiaflexProgram)){
          PiaSky_NPISearchController.NPIvalidationPiasky(trigger.new, trigger.oldMap, true); 
          SYN_CaseTriggerHanlder.updateKACheckBoxonAccount(trigger.new);
          SYN_CaseTriggerHanlder.updateAVEEDARonHCSAccount(Trigger.new);
          updateHCPorHCSCertifiedCheckboxOnCase.updateIncompleteReasonOnInsertorUpdate(true, trigger.new, trigger.oldMap);
          XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(true, trigger.newMap, trigger.oldMap);
          SYN_CaseTriggerHanlder.updateAccounts(trigger.new, trigger.oldMap);
        }     
     
    } else if(trigger.isInsert){
        Map<String, Map<Id, List<Case>>> prgmRTAndCaseListMap = SYN_CaseTriggerHanlder.filterCasesByPrgm(Trigger.new);
        //SYN_CaseTriggerHelper.AffiliationsbyCase(Trigger.new);
        map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
            
        if(mapBigObjectSettings.KeySet().Contains('Case') && mapBigObjectSettings.get('Case').IsActive__c==True && (!Test.isRunningTest()))
            {
            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'Case','Insert');
            if(Limits.getQueueableJobs() == 0) {
            system.enqueueJob(qe); }
            }
        
        if(prgmRTAndCaseListMap.containsKey(aveedProgram)){
            AVEEDAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(false, trigger.newMap, null);
        }
        if(prgmRTAndCaseListMap.containsKey(maciProgram)){
            //SYN_CaseTriggerHelper.MACIAutomationCommunicationForRDAPortal(Trigger.new);
            SYN_CaseTriggerHelper.MACIAutomationCommunicationFromCase(Trigger.new);  //BT7433- 430
        }
            SYN_CaseTriggerHanlder.DEAvalidationAfterInsert(Trigger.new);
            SYN_CaseTriggerHanlder.updateAccount(Trigger.new,null);
            SYN_CaseTriggerHanlder.ChangeOfInformation(Trigger.newMap, null);
            // SYN_AffiliationHandler.createPatientAndPrescriberAffi(Trigger.new);
            SYN_CaseTriggerHanlder.caseValuesForAccountStatusUpdation(Trigger.new,null);
        if(prgmRTAndCaseListMap.containsKey(maciProgram)){
            SYN_CaseTriggerHanlder.updateCaseAccount(Trigger.new);
            SYN_CaseTriggerHanlder.completeCasestatusOnUpdate(Trigger.new, null);
            SYN_CaseTriggerHanlder.UpdateAccountAndServiceStatus(trigger.new,null);
            SYN_CaseTriggerHanlder.createChecklists(Trigger.newMap,null);
            SYN_CaseTriggerHanlder.updateChannelonAccountFromCase(Trigger.new);
        }
        if(prgmRTAndCaseListMap.containsKey(piaskyProgram)){
            AutomationCommunicationFromCase.getAutomationCommunicationFromCase(Trigger.new,piaskyProgram);
        }
        if(prgmRTAndCaseListMap.containsKey(soxProgram)){
            SYN_SOXCorrespondenceHandler.stakeholderEnrollMissingInfo(Trigger.isInsert, Trigger.isUpdate,Trigger.newMap, Trigger.oldMap);
            SYN_SOXCorrespondenceHandler.kAResults(Trigger.isInsert, Trigger.isUpdate,Trigger.newMap, Trigger.oldMap);
        }      
            

        SYN_SharingUtility.createCaseSharingRecs(Trigger.new);
        
        //732 user story
        if(prgmRTAndCaseListMap.containsKey(soxProgram)){
            SYN_CaseTriggerHanlder.updateAccountUserType(trigger.new, trigger.oldMap);    
        //977 user story
           SYN_CaseTriggerHanlder.remsServiceUpdate(Trigger.New,null);    
        if(SYN_CaseTriggerHanlder.firstTrig)
        {
                SYN_CaseTriggerHanlder.firstTrig = false;
                SYN_CaseTriggerHanlder.submitApprovalProcess(trigger.new);//for approval process added by Ashish Y[Wilco]
            }
            SYN_CaseTriggerHanlder.updateAccountMonitor(Trigger.new); // for Monitor participant added by AshishY    
        }
        if(prgmRTAndCaseListMap.containsKey(maciProgram)){
            SYN_CaseTriggerHanlder.RootCauseAnalysis(Trigger.new,null); // RCA
            MACIAutomationCommunicationUtility.getReportableEventFormMACI(Trigger.new);//BT7433-421 & 423...
            RCA_Automation.MisclassificationReviewPendingTask(Trigger.new);
            SYN_CaseTriggerHelper.PAETask(Trigger.new);
            //SYN_CaseTriggerHanlder.updateAccountStatus(trigger.new);
        }
        if(prgmRTAndCaseListMap.containsKey(aveedProgram)){
                Piasky_AutomatedTaskCreation.createRemsCaseRelatedTasks(trigger.new, trigger.oldMap, aveedProgram, 'Deactivation');
                PiaSky_NPISearchController.NPIvalidationPiasky(trigger.new, trigger.oldMap, false); 
        }
        if(prgmRTAndCaseListMap.containsKey(xiaflexProgram)){
            Piasky_AutomatedTaskCreation.createRemsCaseRelatedTasks(trigger.new, trigger.oldMap, xiaflexProgram, 'Deactivation');
            PiaSky_NPISearchController.NPIvalidationPiasky(trigger.new, trigger.oldMap, false); 
            XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(false, trigger.newMap, trigger.oldMap);
            SYN_CaseTriggerHanlder.updateAccounts(trigger.new, trigger.oldMap);
        }
       
    if(prgmRTAndCaseListMap.containsKey(piaskyProgram)){
        PiaSky_NPISearchController.NPIvalidationPiasky(trigger.new, trigger.oldMap, false);  
        Piasky_AutomatedTaskCreation.createNoncomplainceTask(trigger.new, trigger.oldMap, false, piaskyProgram); //BT1005-112
    }
    if(prgmRTAndCaseListMap.containsKey(tryvioProgram)){
        PiaSky_NPISearchController.NPIvalidationPiasky(trigger.new, trigger.oldMap, false); 
       
        Tryvio_AutomatedTaskCreation.createNoncomplainceTask(trigger.new, trigger.oldMap, false, tryvioProgram);
    }
    }
  }
}

if(trigger.isDelete && trigger.isBefore)
    {
        map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
        if(mapBigObjectSettings.KeySet().Contains('Case') && mapBigObjectSettings.get('Case').IsActive__c==True && (!Test.isRunningTest()))
        {
        SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.old,'Case','Delete');
        system.enqueueJob(qe); 
        }
    }



}