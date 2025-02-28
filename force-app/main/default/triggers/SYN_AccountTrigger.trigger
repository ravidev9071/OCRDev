/**
* @File Name          : SYN_AccountTrigger
* @Handler            : SYN_AccountTriggerHanlder
* @TestClass          : SYN_AccountTriggerHanlder_Test
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 1.0    03/29/2022        Chaitanya Nandamuri (Wilco)    createRemsService (BT6825-147: creation of REMSservice for the Account)
* 2.0    05/17/2022        Ismail Shaik (Wilco)           Validation Rule (BT6825-91: Validation Rule for Patient Enrollment form)
* 3.0    06/17/2023        Ashish Y[Wilco]                 addition of updateMonitor (BT6825-750)
**/
trigger SYN_AccountTrigger on Account (after insert, after update, before update, before insert, before delete){
Boolean AccountMethodDisable = Trigger_Method_Controller__mdt.getInstance('Production_MACI_Controller').DisableAccount__c;
    if(SYN_CommonUtility.triggerByPass())
    return;
    String soxProgram = 'Sodium Oxybate REMS';
    String maciProgram = 'Macitentan REMS';
    if (Trigger.isBefore){
        if(Trigger.isInsert) {
            SYN_AccountTriggerHandler.prepopulateProgram(Trigger.New);
            SYN_AccountTriggerHandler.updatePrescriberStatus(Trigger.New);//Added by Ashish P to make account status as Blank for Tryvio Rems.
        }
    }
    Map<String, Map<Id, List<Account>>> prgmRTAndAccountListMap = new Map<String, Map<Id, List<Account>>>();
        if(!Trigger.isDelete){
     prgmRTAndAccountListMap = SYN_AccountTriggerHandler.filterAccountsByPrgm(Trigger.new);
    }
 
        List<AsyncRequest__e> publishEvents = new List<AsyncRequest__e>();
    if (Trigger.isBefore){
        if(prgmRTAndAccountListMap.containsKey(maciProgram) ||prgmRTAndAccountListMap.containsKey(soxProgram)){
            if(Trigger.isInsert) {
                SYN_AccountTriggerHandler.updatedEnrolledDate(Trigger.New);
                SYN_AccountTriggerHandler.setPortalAccount(Trigger.New);
                SYN_AccountTriggerHandler.updatePortalSharingAcctfield(Trigger.New);
                SYN_AccountTriggerHandler.updateMonitored(Trigger.new); //added by Ashish Y[Wilco]
                SYN_AccountTriggerHandler.emailDuplicateCheck(Trigger.oldMap, Trigger.New);
                SYN_AccountTriggerHandler.prepopulateProgram(Trigger.New);
                 
            } else if(Trigger.isUpdate) {
                SYN_AccountTriggerHandler.updatedEnrolledDate(Trigger.New);
                SYN_AccountTriggerHandler.updatePortalSharingAcctfield(Trigger.New);
                SYN_AccountTriggerHandler.updateMonitored(Trigger.new); //added by Ashish Y[Wilco]
                SYN_AccountTriggerHandler.emailDuplicateCheck(Trigger.oldMap, Trigger.New);
                
            }
        }else if(!Trigger.isDelete && !(prgmRTAndAccountListMap.containsKey(SYN_Utilitycls.MACI_PROGRAM_NAME) ||prgmRTAndAccountListMap.containsKey(SYN_Utilitycls.SOX_PROGRAM_NAME))){
             SYN_AccountTriggerHandler.updatedEnrolledDate(Trigger.New);           
        }

        if(Trigger.isInsert) {
            if(prgmRTAndAccountListMap.containsKey(SYN_Utilitycls.AVEED_PROGRAM_NAME)){
                SYN_AccountTriggerHandler.updateEmailOnARAccount(Trigger.new);
            }
        }
        if(Trigger.isUpdate) {
            if(prgmRTAndAccountListMap.containsKey(SYN_Utilitycls.AVEED_PROGRAM_NAME) || prgmRTAndAccountListMap.containsKey(SYN_Utilitycls.XIAFLEX_PROGRAM_NAME)){
                SYN_AccountTriggerHandler.updateStatusChangeDate(Trigger.new, Trigger.oldMap);
            }
        }
    }else{
        if (Trigger.isInsert){
            if(prgmRTAndAccountListMap.containsKey(maciProgram) ||prgmRTAndAccountListMap.containsKey(soxProgram)){
            SYN_AccountTriggerHandler.createAffiliation(Trigger.new);
            if (!AccountMethodDisable){
                 SYN_AccountTriggerHandler.createRemsService(Trigger.new);
            }
            }
            //BT6825-108
            if(Trigger.isAfter){ //BT6825 - 108
                 if(prgmRTAndAccountListMap.containsKey(maciProgram) ||prgmRTAndAccountListMap.containsKey(soxProgram)){
                SYN_AccountTriggerHandler.createPortalUsers(Trigger.New);
                SYN_AccountTriggerHandler.portalUserCreation(Trigger.New); //added by Akilandeswari [Wilco]
                SYN_SharingUtility.createAccountSharingRecs(Trigger.new);
                }

            //Big Object 
            map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
            if(mapBigObjectSettings.KeySet().Contains('Account') && mapBigObjectSettings.get('Account').IsActive__c==True && (!Test.isRunningTest()))
                {
                    AsyncRequest__e ayncReq = new AsyncRequest__e();
                    ayncReq.Object_API_Name__c = 'Account';
                    ayncReq.Action_Type__c = 'Insert';
                    ayncReq.Serialized_List__c = JSON.serialize(trigger.new);
                    publishEvents.add(ayncReq); 
                    /*
                    SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'Account','Insert');
                    if(Limits.getQueueableJobs() == 0) {
                    system.enqueueJob(qe); }
                    */
                }
            }
        }
           if(Trigger.isUpdate) {
                if(Trigger.isAfter){ //BT6825 - 108
                    if(prgmRTAndAccountListMap.containsKey(maciProgram) ||prgmRTAndAccountListMap.containsKey(soxProgram)){
                    SYN_AccountTriggerHandler.createPortalUsers(Trigger.New);
                    SYN_AccountTriggerHandler.updatePortalUser(Trigger.new,Trigger.oldMap);//827 Story UpdatePortalUser added by Ismail S[Wilco]
                    SYN_AccountTriggerHandler.portalUserCreation(Trigger.New);
                    SYN_AccountTriggerHandler.activatePortalUser(Trigger.new,Trigger.oldMap);
                    SYN_AccountTriggerHandler.updatePrescriberHolderAccounts(Trigger.newMap,Trigger.oldMap);
                    //Big Object
                     }

                    //addedd by anusha for correpsondance templates
                    if(prgmRTAndAccountListMap.containsKey(SYN_Utilitycls.AVEED_PROGRAM_NAME)){
                        AVEEDAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(Trigger.newMap,Trigger.oldMap);
                    }

                    if(prgmRTAndAccountListMap.containsKey(SYN_Utilitycls.XIAFLEX_PROGRAM_NAME)){
                          XIAFLEXAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(Trigger.newMap,Trigger.oldMap);
                          SYN_AccountTriggerHandler.updateRelatedAccountANDCases(Trigger.new,Trigger.oldMap);
                    }
                    map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll(); 
                    if(mapBigObjectSettings.KeySet().Contains('Account') && mapBigObjectSettings.get('Account').IsActive__c==True && (!Test.isRunningTest())){

                        AsyncRequest__e ayncReq = new AsyncRequest__e();
                        ayncReq.Object_API_Name__c = 'Account';
                        ayncReq.Action_Type__c = 'Update';
                        ayncReq.Serialized_List__c = JSON.serialize(trigger.new);
                        publishEvents.add(ayncReq);
                            /*
                            SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'Account','Update');
                            if(Limits.getQueueableJobs() == 0) {
                            system.enqueueJob(qe); }
                            */
                    }
                }

            }
        }
                    /*if(RecursiveTriggerHandler.isFirstTime){
                            RecursiveTriggerHandler.isFirstTime=false;
                        // SYN_AccountTriggerHandler.updatedAllCasesToclosed(trigger.new);
                        } */

                    if(Trigger.isBefore) {
                        if(Trigger.isDelete){
                            //Big Object 
                                map<string,SYN_BigObjectTriggerController__mdt> mapBigObjectSettings = SYN_BigObjectTriggerController__mdt.getAll();
                              if(mapBigObjectSettings.KeySet().Contains('Account') && mapBigObjectSettings.get('Account').IsActive__c==True && (!Test.isRunningTest())){

                                AsyncRequest__e ayncReq = new AsyncRequest__e();
                                ayncReq.Object_API_Name__c = 'Account';
                                ayncReq.Action_Type__c = 'Delete';
                                ayncReq.Serialized_List__c = JSON.serialize(trigger.old);
                                publishEvents.add(ayncReq);
                                
                                    /*
                                    SYN_REMSbigObjectDataporcessQueuable qe = new SYN_REMSbigObjectDataporcessQueuable(trigger.new,'Account','Delete');
                                    system.enqueueJob(qe); 
                                    */
                              }

                        }
                    }        
    
    if(publishEvents.size()>0){
        EventBus.publish(publishEvents);
    }
}