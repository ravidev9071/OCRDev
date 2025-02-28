public without sharing class SYN_AccountStatusUpdation {
    public static List<String> programName = new List<string>{'Macitentan REMS'};
    public static Map<Id, Schema.RecordTypeInfo> mapCaseRecordTypesById = Schema.SObjectType.case.getRecordtypeInfosById();
    
    public static void accountStatusUpdatewWithCustomMetadata(List<US_WSREMS__REMS_Service_Summary__c> rssList, Map<Id, US_WSREMS__REMS_Service_Summary__c> rssMap){
        Set<Id> rssIdValSet = new Set<Id>();
        for(US_WSREMS__REMS_Service_Summary__c rss: rssList){
            if(rssMap == null || rssMap.isEmpty()){
                if (programName.contains(rss.Program_Name__c)){
                    rssIdValSet.add(rss.Id);
                }
            }
            else{
                if(rss.US_WSREMS__Service_Outcome__c != rssMap.get(rss.Id).US_WSREMS__Service_Outcome__c || rss.US_WSREMS__Status__c != rssMap.get(rss.Id).US_WSREMS__Status__c){
                    rssIdValSet.add(rss.Id);
                }
            }
        }
        if(!rssIdValSet.isEmpty()){
            remsServiceIdsUtilityMethod(rssIdValSet);
        }
    }
    public static void remsServiceIdsUtilityMethod(set<Id> rssIdsSet){
        
        Set<Id> participantIdsSet = new Set<Id>();
        Set<String> programNameSet = new Set<String>();
        List<US_WSREMS__REMS_Service_Summary__c> remsServiceSummaryList  =[SELECT Id,recordTypeId,US_WSREMS__Status__c,US_WSREMS__Service_Outcome__c,Program_Name__c,US_WSREMS__REMSProgram__c,US_WSREMS__Participant__r.SYN_User_Type__c,US_WSREMS__Path_Stage_Name__c,
                                                                           US_WSREMS__Participant__c,US_WSREMS__Participant__r.US_WSREMS__Status__c, US_WSREMS__Requestor_Type__c,US_WSREMS__Participant__r.id,                                                                                 
                                                                           (SELECT Id, status, US_WSREMS__Outcome__c,Pharmacy_Participant__r.Id,Pharmacy_Participant__r.US_WSREMS__Status__c,Approval_Status__c,Pharmacy_Participant__r.SYN_User_Type__c, SYN_Authorized_Rep__c, RecordTypeId FROM US_WSREMS__Cases__r)
                                                                           FROM US_WSREMS__REMS_Service_Summary__c WHERE ID IN: rssIdsSet];
        if(!remsServiceSummaryList.isEmpty()){
            for(US_WSREMS__REMS_Service_Summary__c rssVal : remsServiceSummaryList){
                if(rssVal.US_WSREMS__Participant__c != null){
                  participantIdsSet.add(rssVal.US_WSREMS__Participant__c);
                }
                programNameSet.add(rssVal.Program_Name__c);
            }
        }
        Map<String,Account_Status_Configuration__mdt> accountStatusConfigMap = new Map<String,Account_Status_Configuration__mdt>();
        if(!programNameSet.isEmpty()){   
            for(Account_Status_Configuration__mdt  accStatConfig : [SELECT Id, Account_Status__c,Approval_Status__c, Case_Outcome__c,Case_Status__c,Program__c,Program__r.Label,REMS_Service__c,
                                                                    Requestor_Type__c,Service_Outcome__c,Service_Status__c 
                                                                    FROM Account_Status_Configuration__mdt 
                                                                    WHERE Program__r.Label IN: programNameSet]){
                                                                        
                                                                        string str = accStatConfig.Program__r.Label+accStatConfig.Requestor_Type__c+accStatConfig.REMS_Service__c+accStatConfig.Service_Status__c+accStatConfig.Service_Outcome__c+accStatConfig.Case_Status__c+ accStatConfig.Case_Outcome__c + accStatConfig.Approval_Status__c;
                                                                        if(!accountStatusConfigMap.containsKey(str)){
                                                                            accountStatusConfigMap.put(str, accStatConfig);
                                                                        }
                                                                    }
        }
        Map<Id,Account> participantAccountMap = new Map<Id,Account>(); 
        if(!participantIdsSet.isEmpty()){
            participantAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c FROM Account WHERE Id IN: participantIdsSet]);
        }
        if(!remsServiceSummaryList.isEmpty()){
            accountStatusUpdate(accountStatusConfigMap,remsServiceSummaryList,participantAccountMap);
        }
        
    }
    
    public static void accountStatusUpdate(Map<String,Account_Status_Configuration__mdt> accountStatusConfigMap, List<US_WSREMS__REMS_Service_Summary__c> remsServiceSummaryList,Map<Id,Account> participantAccountMap){
    string caseOutCome;
    string caseStatus;
    string approvalStatus;
    string changeAuthRepUserStatus;
    string changeAuthRepUserType;
    Id changeAuthRepUserId;
    Boolean statusOutcomeCheck =TRUE; // all the cases associated to the service should have same status and outcome
    List<Account> accToBeUpdated = new List<Account>();
    
    for(US_WSREMS__REMS_Service_Summary__c rss : remsServiceSummaryList){
        if(rss.US_WSREMS__Participant__c != null){
            Boolean check =FALSE;
            Boolean noRelatedCaseCheck = FALSE;
            string recordtypeName =  Schema.getGlobalDescribe().get('US_WSREMS__REMS_Service_Summary__c').getDescribe().getRecordTypeInfosById().get(rss.recordTypeId).getName();
            Id AuthRepUserId;
            if(rss.US_WSREMS__Cases__r != null && ! rss.US_WSREMS__Cases__r.isEmpty()){
                for(case cas : rss.US_WSREMS__Cases__r){  
                    
                    if(!check){
                        caseStatus = cas.status;
                        caseOutCome = cas.US_WSREMS__Outcome__c;
                        approvalStatus = cas.Approval_Status__c;
                        changeAuthRepUserId=cas.Pharmacy_Participant__r.Id;
                        changeAuthRepUserStatus=cas.Pharmacy_Participant__r.US_WSREMS__Status__c;
                        changeAuthRepUserType=cas.Pharmacy_Participant__r.SYN_User_Type__c;
                        check = TRUE;
                        if ( mapCaseRecordTypesById.get(cas.RecordTypeId).getDeveloperName () == 'SYN_Inpatient_Pharmacy' || mapCaseRecordTypesById.get(cas.RecordTypeId).getDeveloperName () == 'SYN_Outpatient_Pharmacy' )
                        {
                            AuthRepUserId = cas.SYN_Authorized_Rep__c;
                        }
                    }
                    if(cas.status != caseStatus || cas.US_WSREMS__Outcome__c != caseOutCome || cas.Approval_Status__c != approvalStatus){
                        statusOutcomeCheck = FALSE;
                        break;
                    }
                }
            }else {
                noRelatedCaseCheck = TRUE;
            }
            if(statusOutcomeCheck){
                string str = rss.Program_Name__c+rss.US_WSREMS__Requestor_Type__c+recordtypeName+rss.US_WSREMS__Status__c+rss.US_WSREMS__Service_Outcome__c+ caseStatus+ caseOutCome+ approvalStatus;
                Account acc = new Account();
                acc.Id = rss.US_WSREMS__Participant__r.id;
                string participantUserTpe = rss.US_WSREMS__Participant__r.SYN_User_Type__c;
                if(recordtypeName =='Disenrollment' && changeAuthRepUserId !=null && rss.US_WSREMS__Requestor_Type__c == 'Pharmacy' && rss.US_WSREMS__Status__c =='Closed' && rss.US_WSREMS__Service_Outcome__c == 'Successful'  && caseStatus =='Complete'  && caseOutCome =='Complete'){
                        acc.Id= changeAuthRepUserId;
                        acc.US_WSREMS__Status__c = 'Disenrolled';
                        accToBeUpdated.add(acc);
                }
                else if(recordtypeName =='Change Authorized Representative' && changeAuthRepUserId !=null && rss.US_WSREMS__Requestor_Type__c == 'Pharmacy' && rss.US_WSREMS__Status__c =='In Progress' && changeAuthRepUserType.contains('Authorized Representative') && (changeAuthRepUserStatus != 'Inactive' || changeAuthRepUserStatus != 'Active' )){
                        acc.Id= changeAuthRepUserId;
                        acc.US_WSREMS__Status__c = 'pending';
                        accToBeUpdated.add(acc);
                }
                else if(recordtypeName =='Knowledge Assessment' && rss.US_WSREMS__Status__c =='Open' && (caseStatus =='Draft' || caseStatus =='' || caseStatus ==null) && participantAccountMap.get(rss.US_WSREMS__Participant__c).US_WSREMS__Status__c =='Initiated'){
                    acc.US_WSREMS__Status__c = 'Pending';
                    accToBeUpdated.add(acc);
                }
                else if(recordtypeName =='Knowledge Assessment' && (rss.US_WSREMS__Status__c =='Open' || rss.US_WSREMS__Status__c =='Closed') && (rss.US_WSREMS__Service_Outcome__c == 'Unsuccessful' || rss.US_WSREMS__Service_Outcome__c == null) && (caseStatus =='Complete' || caseStatus =='Cancelled') && (caseOutCome =='Due Dilligence Exhausted' ||caseOutCome =='Created in Error' || caseOutCome =='Fail') && participantAccountMap.get(rss.US_WSREMS__Participant__c).US_WSREMS__Status__c =='Initiated'){
                    acc.US_WSREMS__Status__c = 'Canceled';
                    accToBeUpdated.add(acc);
                }
                else if(recordtypeName =='Knowledge Assessment' && rss.US_WSREMS__Status__c =='Closed' && rss.US_WSREMS__Service_Outcome__c == 'Successful'  && caseStatus =='Complete'  && caseOutCome =='Pass'){
                    acc.US_WSREMS__Status__c = 'Active';
                    accToBeUpdated.add(acc);
                }
                else if((recordtypeName =='Reenrollment' || recordtypeName =='Enrollment' || recordtypeName =='Disenrollment.') && (caseStatus =='Cancelled' || caseStatus =='Draft')  && (caseOutCome =='Created in Error' || caseOutCome =='Due Dilligence Exhausted') && rss.US_WSREMS__Path_Stage_Name__c == 'Closed'){
                     
                         acc.US_WSREMS__Status__c = 'Canceled';
                         acc.Sub_Status__c = caseOutCome;
                        accToBeUpdated.add(acc);  
                }
                else if (noRelatedCaseCheck && recordtypeName == 'Enrollment'){
                    acc.US_WSREMS__Status__c = 'Pending';
                    accToBeUpdated.add(acc);
                } 
                else if(accountStatusConfigMap.get(str) != null){
                    acc.US_WSREMS__Status__c = accountStatusConfigMap.get(str).Account_Status__c;
                    if(accountStatusConfigMap.get(str) != null && accountStatusConfigMap.get(str).Approval_Status__c != null){
                        acc.Sub_Status__c = null;
                    } 
                    accToBeUpdated.add(acc);

                    if ( rss.Program_Name__c=='Macitentan REMS' && recordtypeName == 'Enrollment' && rss.US_WSREMS__Requestor_Type__c =='Pharmacy'  && rss.US_WSREMS__Status__c =='Closed' && rss.US_WSREMS__Service_Outcome__c == 'Successful' && !string.isBlank(AuthRepUserId) ){
                        Account AuthRep = new Account();
                        AuthRep.id = AuthRepUserId;
                        Authrep.US_WSREMS__Status__c = 'Active';
                        accToBeUpdated.add(AuthRep);
                    }
                }                
            }     
        }
    }
        if(accToBeUpdated != null){
            update accToBeUpdated;
        }
    
    }
}