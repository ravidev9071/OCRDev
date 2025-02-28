public without sharing class caseAutomationController{

    /**
   * * Method Name         : checkCaseStatus
   * @ Description         : Validate Incomplete reason when case status completed
   * @ CreatedDate         : 16 May 2024
   * @ Author              : Wilco Offshore
   */
    public static void checkCaseStatus(List<Case> newCaseList, Set<Id> programIds, Set<String> caseRecordTypes, Set<String> caseStatus, Set<String> caseOutCome){
    
        List<US_WSREMS__Automation_Configuration__c> caseConfigurationList = REMSUtils.getCaseStatusConfigurations(null,caseRecordTypes,caseStatus,caseOutCome,programIds);
        if(caseConfigurationList.isEmpty()){
            return ;
        }
        Map<String,US_WSREMS__Automation_Configuration__c> caseAutomationMap= new Map<String,US_WSREMS__Automation_Configuration__c>();                                                        
        for(US_WSREMS__Automation_Configuration__c ac : caseConfigurationList){
            caseAutomationMap.put(ac.US_WSREMS__REMS_Program__c+ac.US_WSREMS__Case_Record_Type__c+ac.US_WSREMS__Case_Status__c+ac.US_WSREMS__Case_Outcome__c+ac.US_WSREMS__Hold_Account__c,ac);
        }
        
        if(caseAutomationMap != null){
            for(Case cs : newCaseList){
                String recordTypeDevrName= REMSUtils.retrieveRecTypeIdDeveloperName(REMSAppLiterals.CASE_OBJECT).get(cs.RecordTypeId);
                if(caseAutomationMap.containsKey(cs.US_WSREMS__REMS_Program__c+recordTypeDevrName+cs.Status+cs.US_WSREMS__Outcome__c+cs.US_WSREMS__Hold_Account__c)) {
                    US_WSREMS__Automation_Configuration__c ac = caseAutomationMap.get(cs.US_WSREMS__REMS_Program__c+recordTypeDevrName+cs.Status+cs.US_WSREMS__Outcome__c+cs.US_WSREMS__Hold_Account__c);
                    if(ac.US_WSREMS__Channel__c!=null && cs.US_WSREMS__Channel__c!=null && ac.US_WSREMS__Channel__c.contains(cs.US_WSREMS__Channel__c) && 
                        ac.US_WSREMS__Do_we_need_to_check_incomplete_reason__c && cs.US_WSREMS__Incomplete_Reasons__c != null && cs.US_WSREMS__Incomplete_Reasons__c != ''){
                            if(ac.US_WSREMS__Incomplete_Reason_Validation_Msg__c != null){
                                cs.AddError(ac.US_WSREMS__Incomplete_Reason_Validation_Msg__c);
                            }else{
                        cs.AddError(System.Label.casesoftrequiredfields);
                    }
                    }
                }
            }
        } 
    }
    
    /**
   * * Method Name         : AssignCaseStatus
   * @ Description         : Assign Status of type New when all the required fields not filled
   * @ CreatedDate         : 16 May 2024
   * @ Author              : Wilco Offshore
   */
    public static void AssignCaseStatus(List<Case> newCaseList, Set<Id> programIds, Set<String> recordTypeName){
    
        List<US_WSREMS__Automation_Configuration__c> caseConfigurationList = [SELECT id, US_WSREMS__Object__c, US_WSREMS__Case_Record_Type__c, US_WSREMS__Do_we_need_to_check_incomplete_reason__c, US_WSREMS__REMS_Program__c,
                                                                    US_WSREMS__Case_Status__c, US_WSREMS__Case_Outcome__c,US_WSREMS__Channel__c FROM  US_WSREMS__Automation_Configuration__c WHERE US_WSREMS__REMS_Program__c IN : programIds
                                                                    AND US_WSREMS__Type_of_Status__c ='New' AND US_WSREMS__Case_Record_Type__c =: recordTypeName];
        
        Map<String,US_WSREMS__Automation_Configuration__c> caseAutomationMap= new Map<String,US_WSREMS__Automation_Configuration__c>();                                                        
        for(US_WSREMS__Automation_Configuration__c ac : caseConfigurationList){
            caseAutomationMap.put(ac.US_WSREMS__REMS_Program__c+ac.US_WSREMS__Case_Record_Type__c,ac);
        }
        
        if(caseAutomationMap != null){
            for(Case cs : newCaseList){
                String recordTypeDevrName= REMSUtils.retrieveRecTypeIdDeveloperName(REMSAppLiterals.CASE_OBJECT).get(cs.RecordTypeId);
                if(caseAutomationMap.containsKey(cs.US_WSREMS__REMS_Program__c+recordTypeDevrName)) {
                    US_WSREMS__Automation_Configuration__c ac = caseAutomationMap.get(cs.US_WSREMS__REMS_Program__c+recordTypeDevrName);
                    if(ac.US_WSREMS__Channel__c!=null&& cs.US_WSREMS__Record_Type_Name__c != REMSAppLiterals.SERVICE_RECTYPE_CHANGE_AUTHORIZED_REPRESENTATIVE && cs.US_WSREMS__Channel__c!=null && ac.US_WSREMS__Channel__c.contains(cs.US_WSREMS__Channel__c) && cs.US_WSREMS__REMS_Service_Summary__c!=null){ 
                        if(ac.US_WSREMS__Do_we_need_to_check_incomplete_reason__c && (cs.US_WSREMS__Incomplete_Reasons__c == null || cs.US_WSREMS__Incomplete_Reasons__c == '')){
                            cs.Status = ac.US_WSREMS__Case_Status__c;
                            cs.US_WSREMS__Outcome__c = ac.US_WSREMS__Case_Outcome__c;
                        }else if(!ac.US_WSREMS__Do_we_need_to_check_incomplete_reason__c){
                            cs.Status = ac.US_WSREMS__Case_Status__c;
                            cs.US_WSREMS__Outcome__c = ac.US_WSREMS__Case_Outcome__c;
                        }
                    }
                }
            }
        } 
    }
    
    /**
   * * Method Name         : updateCaseStatus
   * @ Description         : Assign Status of type Closed when all the required fields are filled
   * @ CreatedDate         : 16 May 2024
   * @ Author              : Wilco Offshore
   */
    public static void updateCaseStatus(List<Case> newCaseList, Set<Id> programIds, Set<String> recordTypeName){
    
        List<US_WSREMS__Automation_Configuration__c> caseConfigurationList = [SELECT id, US_WSREMS__Object__c, US_WSREMS__Case_Record_Type__c, US_WSREMS__Do_we_need_to_check_incomplete_reason__c, US_WSREMS__REMS_Program__c,
                                                                    US_WSREMS__Case_Status__c, US_WSREMS__Case_Outcome__c, US_WSREMS__Channel__c, US_WSREMS__Hold_Account__c, US_WSREMS__KA_Parent_Reference__c, US_WSREMS__KA_Passed__c 
                                                                    FROM  US_WSREMS__Automation_Configuration__c WHERE US_WSREMS__REMS_Program__c IN : programIds
                                                                    AND US_WSREMS__Type_of_Status__c ='Closed' AND US_WSREMS__Case_Record_Type__c =: recordTypeName];
        
        Map<String,US_WSREMS__Automation_Configuration__c> caseAutomationMap= new Map<String,US_WSREMS__Automation_Configuration__c>();                                                        
        Map<Id,US_WSREMS__Automation_Configuration__c> accountCaseMap = new Map<Id,US_WSREMS__Automation_Configuration__c>();
        for(US_WSREMS__Automation_Configuration__c ac : caseConfigurationList){
            caseAutomationMap.put(ac.US_WSREMS__REMS_Program__c+ac.US_WSREMS__Case_Record_Type__c+ac.US_WSREMS__Hold_Account__c,ac);
        }
        
        if(caseAutomationMap != null){
            for(Case cs : newCaseList){
                String recordTypeDevrName= REMSUtils.retrieveRecTypeIdDeveloperName(REMSAppLiterals.CASE_OBJECT).get(cs.RecordTypeId);
                if(caseAutomationMap.containsKey(cs.US_WSREMS__REMS_Program__c+recordTypeDevrName+cs.US_WSREMS__Hold_Account__c)) {
                    US_WSREMS__Automation_Configuration__c ac = caseAutomationMap.get(cs.US_WSREMS__REMS_Program__c+recordTypeDevrName+cs.US_WSREMS__Hold_Account__c);
                    if(ac.US_WSREMS__Channel__c!=null && cs.US_WSREMS__Channel__c!=null && ac.US_WSREMS__Channel__c.contains(cs.US_WSREMS__Channel__c) && cs.US_WSREMS__REMS_Service_Summary__c!=null){
                        accountCaseMap.put(cs.Id,ac);
                    }
                }
            }
           
            for(Case cs : newCaseList){
                if(accountCaseMap.containsKey(cs.Id)){
                    US_WSREMS__Automation_Configuration__c ac = accountCaseMap.get(cs.Id);
                    if((ac.US_WSREMS__KA_Passed__c==false || (ac.US_WSREMS__KA_Passed__c==true && cs.US_WSREMS__Knowledge_Assessment__c == 'Passed'))&& cs.US_WSREMS__Record_Type_Name__c != REMSAppLiterals.SERVICE_RECTYPE_CHANGE_AUTHORIZED_REPRESENTATIVE){
                        if(ac.US_WSREMS__Do_we_need_to_check_incomplete_reason__c && (cs.US_WSREMS__Incomplete_Reasons__c == null || cs.US_WSREMS__Incomplete_Reasons__c == '')){
                            cs.Status = ac.US_WSREMS__Case_Status__c;
                            cs.US_WSREMS__Outcome__c = ac.US_WSREMS__Case_Outcome__c;
                        }else if(!ac.US_WSREMS__Do_we_need_to_check_incomplete_reason__c){
                            cs.Status = ac.US_WSREMS__Case_Status__c;
                            cs.US_WSREMS__Outcome__c = ac.US_WSREMS__Case_Outcome__c;
                        }
                    }
                }
            }
        } 
    }
    /**
   * * Method Name         : updateAccountStatus
   * @ Description         : Update Account Status when Case Status changed
   * @ CreatedDate         : 16 May 2024
   * @ Author              : Wilco Offshore
   */
    
    public static void updateAccountStatus(List<Case> newCaseList, Set<Id> programIds, Set<String> caseRecordTypes, Set<String> caseStatus, Set<String> caseOutCome){
        Map<String,List<US_WSREMS__Automation_Configuration__c>> caseAutomationMap= new Map<String,List<US_WSREMS__Automation_Configuration__c>>();                                                        
        List<Account> updateaccountList = new List<Account>();
        List<US_WSREMS__REMS_Service_Summary__c> remsServiceList = new List<US_WSREMS__REMS_Service_Summary__c>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Set<Id> accountIdSet = new  Set<Id>();
        try{     
            caseAutomationMap = getStatusConfigurationRecords( programIds, caseRecordTypes, caseStatus, caseOutCome);                                                          
        for(Case caseobj: newCaseList){
            if(caseobj.US_WSREMS__Participant__c != null){
                accountIdSet.add(caseobj.US_WSREMS__Participant__c );
            }
        }

        if(!accountIdSet.isEmpty()){
            for(Account accObj: [SELECT Id,US_WSREMS__Date_Enrolled__c,US_WSREMS__Prescriber_Signature__c FROM Account WHERE Id in :accountIdSet]){
                accountMap.put(accObj.Id,accObj);
            }
        }

        Map<String,String> accountAROutPatientMap = new Map<String,String>();
        for(US_WSREMS__Affiliation__c record :[SELECT Id,US_WSREMS__Pharmacy__c ,US_WSREMS__Pharmacy_User__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Pharmacy__c IN : accountMap.KeySet() AND US_WSREMS__Pharmacy_User__r.US_WSREMS__Channel__c =: REMSAppLiterals.CASE_CHANNEL_PORTAL and US_WSREMS__Pharmacy_User__c != null ] ) {
            accountAROutPatientMap.put(record.US_WSREMS__Pharmacy__c, record.US_WSREMS__Pharmacy_User__c);
        }

        if(caseAutomationMap != null){
            for(Case cs : newCaseList){
                String recordTypeDevrName= REMSUtils.retrieveRecTypeIdDeveloperName(REMSAppLiterals.CASE_OBJECT).get(cs.RecordTypeId);
                    
                if(caseAutomationMap.containsKey(cs.US_WSREMS__REMS_Program__c+recordTypeDevrName+cs.Status+cs.US_WSREMS__Outcome__c) && cs.US_WSREMS__Participant__c != null) {
                    US_WSREMS__Automation_Configuration__c ac;
                    for(US_WSREMS__Automation_Configuration__c acObj: caseAutomationMap.get(cs.US_WSREMS__REMS_Program__c+recordTypeDevrName+cs.Status+cs.US_WSREMS__Outcome__c)){
                        if(acObj.US_WSREMS__Channel__c!=null && cs.US_WSREMS__Channel__c!=null && acObj.US_WSREMS__Channel__c.contains(cs.US_WSREMS__Channel__c)){
                            ac = acObj;
                        }
                    }  
                    if(ac!=null) {               
                        if(ac.US_WSREMS__Account_Status__c!=null){
                            if(ac.US_WSREMS__Case_Record_Type__c == 'Knowledge_Assessment' && ac.US_WSREMS__KA_Parent_Reference__c!=null){
                                if((ac.US_WSREMS__KA_Passed__c==false || (ac.US_WSREMS__KA_Passed__c==true && cs.US_WSREMS__Knowledge_Assessment__c == 'Passed'))){
                                    List<String> requestorTypeRefList = new List<String> ();
                                    requestorTypeRefList = ac.US_WSREMS__KA_Parent_Reference__c.split('\\$');
                                    string referenceField;
                                    for(String requestorTypeRef: requestorTypeRefList){
                                        if(cs.US_WSREMS__Service_Requestor_Type__c!=null && requestorTypeRef.contains(cs.US_WSREMS__Service_Requestor_Type__c)){
                                            referenceField = requestorTypeRef.substringAfter(':');
                                        }
                                    }
                                    if(referenceField!=null && cs.get(referenceField)!=null){
                                        Account accObj = new Account();
                                        accObj.Id = (Id)cs.get(referenceField);
                                        accObj.US_WSREMS__Status__c =  ac.US_WSREMS__Account_Status__c;
                                        accObj.US_WSREMS__Sub_Status__c = ac.US_WSREMS__Account_Sub_Status__c;
                                        updateaccountList.add(accObj);
                                    }
                                }
                            }else{
                                updateaccountList.addall(prepareAccount(cs, accountMap, accountAROutPatientMap,ac));
                            }
                                
                            }
                            If(cs.US_WSREMS__REMS_Service_Summary__c != null){
                                if(ac.US_WSREMS__Service_Path__c == 'Closed'){
                                    REMSAvoidRecursiveCls.stop_serviceupdateFromAutomation = true;
                                }
                                US_WSREMS__REMS_Service_Summary__c rs = prepareService(cs, ac);
                                remsServiceList.add(rs);
                            }
                        }
                    }
                }
            } 
            
            if(!updateaccountList.isEmpty()){
                if(REMSAvoidRecursiveCls.stop_accountUpdate==false){
                    update updateaccountList;
                }
            }
            if(!remsServiceList.isEmpty()){
                update remsServiceList;
                REMSAvoidRecursiveCls.stop_serviceupdateFromAutomation = false;
            }
        
        }catch(exception ex){

        }
    }
    
    /**
   * * Method Name         : getStatusConfigurationRecords
   * @ Description         : get automation configuration foe all case status and outcome
   * @ CreatedDate         : 16 May 2024
   * @ Author              : Wilco Offshore
   */
    public static Map<String,List<US_WSREMS__Automation_Configuration__c>> getStatusConfigurationRecords( Set<Id> programIds, Set<String> caseRecordTypes, Set<String> caseStatus, Set<String> caseOutCome){
        Map<String,List<US_WSREMS__Automation_Configuration__c>> caseAutomationMap= new Map<String,List<US_WSREMS__Automation_Configuration__c>>();                                                        
        List<US_WSREMS__Automation_Configuration__c> caseConfigurationList = [SELECT id,US_WSREMS__RecertificationAgentTaskDaysBefore__c,US_WSREMS__RecertificationReminderDays__c,US_WSREMS__REMSCertificationExpirationApplies__c,US_WSREMS__Verification_Expiration_Applies__c,US_WSREMS__Number_Of_Years_Verification_Valid__c,US_WSREMS__Verification_Agent_Task_Days_Before__c,US_WSREMS__Verification_Reminder_Days__c,US_WSREMS__NumberOfYearsCertificationValid__c,US_WSREMS__Object__c, US_WSREMS__Case_Record_Type__c, US_WSREMS__Do_we_need_to_check_incomplete_reason__c, US_WSREMS__REMS_Program__c,
                                                                    US_WSREMS__Case_Status__c, US_WSREMS__Case_Outcome__c, US_WSREMS__Account_Status__c, US_WSREMS__Account_Sub_Status__c, US_WSREMS__Type_of_Status__c, 
                                                                    US_WSREMS__Service_Status__c, US_WSREMS__Service_Outcome__c,US_WSREMS__Channel__c, US_WSREMS__Service_Path__c, US_WSREMS__Service_Stage__c,
                                                                    US_WSREMS__Date_Enrolled__c, US_WSREMS__Update_Signature__c, US_WSREMS__Update_AR_Account__c, US_WSREMS__KA_Parent_Reference__c, US_WSREMS__KA_Passed__c
                                                                    FROM  US_WSREMS__Automation_Configuration__c WHERE US_WSREMS__REMS_Program__c IN : programIds
                                                                    AND US_WSREMS__Case_Status__c =: caseStatus AND US_WSREMS__Case_Outcome__c = : caseOutCome AND US_WSREMS__Case_Record_Type__c =:caseRecordTypes];

        for(US_WSREMS__Automation_Configuration__c ac : caseConfigurationList){
            if(!caseAutomationMap.containsKey(ac.US_WSREMS__REMS_Program__c+ac.US_WSREMS__Case_Record_Type__c+ac.US_WSREMS__Case_Status__c+ac.US_WSREMS__Case_Outcome__c)){
            caseAutomationMap.put(ac.US_WSREMS__REMS_Program__c+ac.US_WSREMS__Case_Record_Type__c+ac.US_WSREMS__Case_Status__c+ac.US_WSREMS__Case_Outcome__c,new List<US_WSREMS__Automation_Configuration__c>{ac});
            }else{
            caseAutomationMap.get(ac.US_WSREMS__REMS_Program__c+ac.US_WSREMS__Case_Record_Type__c+ac.US_WSREMS__Case_Status__c+ac.US_WSREMS__Case_Outcome__c).add(ac);
            }
        }
        return caseAutomationMap;
    }

     /**
   * * Method Name         : prepareAccount
   * @ Description         : Assign values to account record
   * @ CreatedDate         : 16 May 2024
   * @ Author              : Wilco Offshore
   */
    public static List<Account> prepareAccount(Case cs, Map<Id,Account> accountMap, Map<String,String> accountAROutPatientMap, US_WSREMS__Automation_Configuration__c ac){
        List<Account> accountList = new List<Account>();
                        Account acc = new Account(Id = cs.US_WSREMS__Participant__c);
                        acc.US_WSREMS__Status__c =  ac.US_WSREMS__Account_Status__c;
                        acc.US_WSREMS__Sub_Status__c = ac.US_WSREMS__Account_Sub_Status__c;
                        //1916
                        if(ac.US_WSREMS__Verification_Expiration_Applies__c==true && ac.US_WSREMS__Number_Of_Years_Verification_Valid__c!=null &&
                          ac.US_WSREMS__Verification_Reminder_Days__c!=null && ac.US_WSREMS__Verification_Agent_Task_Days_Before__c!=null){
                              if(REMSAppLiterals.CASE_ENROLL_REENROLL_RECTYPE_SET_Certification.contains(ac.US_WSREMS__Case_Record_Type__c)){
                                  acc.US_WSREMS__VerificationComplete__c=true;
                                  acc.US_WSREMS__VerificationDueDate__c=system.now().addYears(integer.valueof(ac.US_WSREMS__Number_Of_Years_Verification_Valid__c));
                                  acc.US_WSREMS__VerificationReminderDate__c=acc.US_WSREMS__VerificationDueDate__c.addDays(- integer.valueof(ac.US_WSREMS__Verification_Reminder_Days__c));
                                  acc.US_WSREMS__VerificationAgentTaskDate__c=acc.US_WSREMS__VerificationDueDate__c.addDays(- integer.valueof(ac.US_WSREMS__Verification_Agent_Task_Days_Before__c));
                              }
                              else{
                                  acc.US_WSREMS__VerificationComplete__c=false;
                                  acc.US_WSREMS__VerificationDueDate__c=system.now().addYears(integer.valueof(ac.US_WSREMS__Number_Of_Years_Verification_Valid__c));
                                  acc.US_WSREMS__VerificationReminderDate__c=acc.US_WSREMS__VerificationDueDate__c.addDays(- integer.valueof(ac.US_WSREMS__Verification_Reminder_Days__c));
                                  acc.US_WSREMS__VerificationAgentTaskDate__c=acc.US_WSREMS__VerificationDueDate__c.addDays(- integer.valueof(ac.US_WSREMS__Verification_Agent_Task_Days_Before__c));
                              }
                              
                        }
                        //Re certification
                        if(ac.US_WSREMS__REMSCertificationExpirationApplies__c==true && ac.US_WSREMS__NumberOfYearsCertificationValid__c!=null &&
                        ac.US_WSREMS__RecertificationReminderDays__c!=null && ac.US_WSREMS__RecertificationAgentTaskDaysBefore__c!=null){
                            if(REMSAppLiterals.CASE_ENROLL_REENROLL_RECTYPE_SET_Certification.contains(ac.US_WSREMS__Case_Record_Type__c)){
                                acc.US_WSREMS__Recertification_Complete__c=true;
                                acc.US_WSREMS__Recertification_Due_Date__c=system.now().addYears(integer.valueof(ac.US_WSREMS__NumberOfYearsCertificationValid__c));
                                acc.US_WSREMS__ReCertification_Reminder_Date__c=acc.US_WSREMS__Recertification_Due_Date__c.addDays(- integer.valueof(ac.US_WSREMS__RecertificationReminderDays__c));
                                acc.US_WSREMS__ReCertification_Agent_Task_Date__c=acc.US_WSREMS__Recertification_Due_Date__c.addDays(- integer.valueof(ac.US_WSREMS__RecertificationAgentTaskDaysBefore__c));
                            }else{
                                acc.US_WSREMS__Recertification_Complete__c=false;
                                acc.US_WSREMS__Recertification_Due_Date__c=system.now().addYears(integer.valueof(ac.US_WSREMS__NumberOfYearsCertificationValid__c));
                                acc.US_WSREMS__ReCertification_Reminder_Date__c=acc.US_WSREMS__Recertification_Due_Date__c.addDays(- integer.valueof(ac.US_WSREMS__RecertificationReminderDays__c));
                                acc.US_WSREMS__ReCertification_Agent_Task_Date__c=acc.US_WSREMS__Recertification_Due_Date__c.addDays(- integer.valueof(ac.US_WSREMS__RecertificationAgentTaskDaysBefore__c));
                            }                           
                        }
                        
                        if(ac.US_WSREMS__Date_Enrolled__c == true && accountMap.get(cs.US_WSREMS__Participant__c).US_WSREMS__Date_Enrolled__c == null){
                            acc.US_WSREMS__Date_Enrolled__c = System.today();
                        }
                        if(ac.US_WSREMS__Update_Signature__c == true){
                            acc.US_WSREMS__Prescriber_Signature__c = cs.US_WSREMS__Prescriber_Signature__c!=null?cs.US_WSREMS__Prescriber_Signature__c:accountMap.get(cs.US_WSREMS__Participant__c).US_WSREMS__Prescriber_Signature__c;
                            acc.US_WSREMS__Prescriber_Signature__c = cs.US_WSREMS__Signature__c!=null?cs.US_WSREMS__Signature__c:accountMap.get(cs.US_WSREMS__Participant__c).US_WSREMS__Prescriber_Signature__c;
                            acc.US_WSREMS__Prescriber_Signature_Date__c = cs.US_WSREMS__Signature_Date_Pharmacist__c;
                        }

                        if(ac.US_WSREMS__Update_AR_Account__c ==true){
                            if( accountAROutPatientMap.containsKey(cs.US_WSREMS__Participant__c)) {
                                Account arAcc = new Account();
                                arAcc.Id = accountAROutPatientMap.get(cs.US_WSREMS__Participant__c);
                                arAcc.US_WSREMS__Status__c =  ac.US_WSREMS__Account_Status__c;
                                accountList.add(arAcc);
                            }
                        }
                        accountList.add(acc);
        return accountList;
    }

     /**
   * * Method Name         : updateAccountStatus
   * @ Description         : Assign values to service record
   * @ CreatedDate         : 16 May 2024
   * @ Author              : Wilco Offshore
   */
    public static US_WSREMS__REMS_Service_Summary__c prepareService(Case cs, US_WSREMS__Automation_Configuration__c ac){
                            US_WSREMS__REMS_Service_Summary__c rs = new US_WSREMS__REMS_Service_Summary__c(Id = cs.US_WSREMS__REMS_Service_Summary__c);
                            rs.US_WSREMS__Status__c = ac.US_WSREMS__Service_Status__c;
                            rs.US_WSREMS__Service_Outcome__c = ac.US_WSREMS__Service_Outcome__c;
                            rs.US_WSREMS__Path_Stage_Name__c = ac.US_WSREMS__Service_Path__c;
                            rs.US_WSREMS__StageName__c = ac.US_WSREMS__Service_Stage__c;
        return rs;
    }
}