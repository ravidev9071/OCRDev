/**
* @File Name          : SYN_RemsServiceSummaryTriggerHandler.cls
* @Description        : This is used as a Hanlder for RemsService trigger.
* @Trigger            : SYN_RemsServiceSummaryTrigger
* @TestClass          : SYN_RemsSummaryTrigger_HTest
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date              Developer                         Modification
* 2.0       04/01/2022        Dnyaneshwar Gothakade (Wilco)     New:Line 555-596: Added accountFieldUpdate method :- To update Account fields WHEN the Service Status is 'Closed' and the Outcome is 'Successful' 
* 3.0       09/20/2024        Dileep Gurram(Wilco)               Changes added in accountFieldUpdate method regarding BT7433-2356
**/

public class SYN_RemsServiceSummaryTriggerHandler {


    public static void SurveyMethod(List<US_WSREMS__REMS_Service_Summary__c> serviceList){
        Map<Id, String> RSSSurveyStatusMap = new Map<Id,String>();
        Set<Id> surveyList=new Set<Id>();
        Set<Id> programIds=new Set<Id>();
        
        Id inboundRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get('Inbound Communication').getRecordTypeId();
        Id outboundRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get('Outbound Communication').getRecordTypeId();
        
        
        for(US_WSREMS__REMS_Service_Summary__c service:serviceList){
            programIds.add(service.US_WSREMS__REMSProgram__c);
            if(service.US_WSREMS__Path_Stage_Name__c =='Closed'){
                surveyList.add(service.Id);
            }
        }
        List<US_WSREMS__REMS_Program__c> programDetailsList = new List<US_WSREMS__REMS_Program__c>();
        if(!programIds.isEmpty()){
         programDetailsList = [select id,name from US_WSREMS__REMS_Program__c where id in: programIds];
        }      
        if(surveyList == null || surveyList.isEmpty()){
            return;
        }
        String baseQuery = 'SELECT Id,Status,Name,Invitation.Survey.Name,SubmitterId,Submitter.Name,CompletionDateTime,CreatedDate, Invitation.Name,Invitationid from SurveyResponse where invitation.name = :surveyList AND status =\'completed\'';
        if(programDetailsList[0].Name == Label.Macitentan_REMS_Program_Name){
            baseQuery += ' AND Invitation.Survey.Name =\'Macitentan REMS Activities and Discussions\'' ;
        }
        else if(programDetailsList[0].Name == Label.Sodium_Oxybate_REMS_Program_Name){
             baseQuery += ' AND Invitation.Survey.Name =\'SOX REMS Activities and Disscussions\'' ;
        }
        List<SurveyResponse> surveyRes = new List<SurveyResponse>();
        surveyRes =  Database.query(baseQuery);
        for (SurveyResponse SRObj : surveyRes){
                  RSSSurveyStatusMap.put(SRObj.Invitation.Name , SRObj.Status);
                                     }
        for(US_WSREMS__REMS_Service_Summary__c serviceRecord : serviceList){
            if((serviceRecord.US_WSREMS__Path_Stage_Name__c =='Closed') && ((!RSSSurveyStatusMap.keyset().contains(serviceRecord.id) )||
                                                                            (RSSSurveyStatusMap.keyset().contains(serviceRecord.id) && (RSSSurveyStatusMap.get(serviceRecord.id) !='Completed' )) ) && (serviceRecord.RecordtypeId == inboundRecordTypeId || serviceRecord.RecordtypeId == outboundRecordTypeId ) ){
                                                                    
                                                                               
                                                                                serviceRecord.addError('To mark this stage as complete, please complete the survey.');
                                                                                
                                                                            }
            
        }
        
        
    }
    
    
      public  static void createAffiliationRecs(Map<Id,US_WSREMS__REMS_Service_Summary__c> newServiceMap, Map<Id,US_WSREMS__REMS_Service_Summary__c> oldServiceMap){
         Set<Id> programIdSet = new Set<Id>();
         Set<Id> serviceIdSet = new Set<Id>();
         Set<Id> pharmacyuserIdSet = new Set<Id>();
         Set<Id> pharmacyIdSet = new Set<Id>();
         Map<Id,Case> serviceIdCaseMap = new Map<Id,Case>();
         List<US_WSREMS__Affiliation__c> updateAffiliationList = new List<US_WSREMS__Affiliation__c>();
         List<US_WSREMS__Affiliation__c> insertAffiliationList = new List<US_WSREMS__Affiliation__c>();
         Map<String,US_WSREMS__Affiliation__c> existingAffiliationMap = new Map<String,US_WSREMS__Affiliation__c>(); // Key Prgm,Pharmacy,Pharmacy user
         Map<Id,String> serviceRecordtypeIdbyDeveloperNameMap = retrieveRecTypeIdDeveloperName(SYN_AppLiterals.SERVICE_SUMMARY_OBJECT);
         Map<String, Id> recordtypeIdbyDeveloperNameMap = retrieveRecTypeDeveloperNameId(SYN_AppLiterals.AFFILIATION_OBJECT);
         for(US_WSREMS__REMS_Service_Summary__c serviceObj:newServiceMap.values()){
             if((newServiceMap.get(serviceObj.Id).US_WSREMS__Service_Outcome__c!=oldServiceMap.get(serviceObj.Id).US_WSREMS__Service_Outcome__c 
                 || newServiceMap.get(serviceObj.Id).US_WSREMS__Status__c!=oldServiceMap.get(serviceObj.Id).US_WSREMS__Status__c) 
                 && newServiceMap.get(serviceObj.Id).US_WSREMS__Service_Outcome__c ==System.Label.REMSServiceOutcomeStatusSuccessful
                 && newServiceMap.get(serviceObj.Id).US_WSREMS__Status__c==System.Label.US_WSREMS.ServiceStatusClose 
                 && serviceRecordtypeIdbyDeveloperNameMap.get(serviceObj.RecordTypeId) 
                    == SYN_AppLiterals.SERVICE_RECTYPE_CHANGE_AUTHORIZED_REPRESENTATIVE){
                 serviceIdSet.add(serviceObj.Id);  
             }
         }   
         if(serviceIdSet!=null && serviceIdSet.size()>0){             
             List<US_WSREMS__REMS_Service_Summary__c> serviceSummaryList = new List<US_WSREMS__REMS_Service_Summary__c>();
             serviceSummaryList = [SELECT Id,US_WSREMS__Participant__c,US_WSREMS__REMSProgram__c, 
                     (Select id,US_WSREMS__REMS_Service_Summary__c, 
                     US_WSREMS__Pharmacy_User_ar__c,US_WSREMS__UserType__c,Pharmacy_Participant__c, US_WSREMS__UserType_ar__c, US_WSREMS__Pharmacy_User__c 
                     FROM US_WSREMS__Cases__r limit 1) FROM US_WSREMS__REMS_Service_Summary__c where Id IN: serviceIdSet ];
             for(US_WSREMS__REMS_Service_Summary__c serviceObj:serviceSummaryList){
                 for(Case caseObj:serviceObj.US_WSREMS__Cases__r){
                     pharmacyIdSet.add(serviceObj.US_WSREMS__Participant__c);  
                     programIdSet.add(serviceObj.US_WSREMS__REMSProgram__c);
                     pharmacyuserIdSet.add(caseObj.US_WSREMS__Pharmacy_User_ar__c);
                 }
             }
             List<Account> updateList=new List<Account>();
             List<Account> accountList=[Select id,US_WSREMS__Status__c from Account where id IN:pharmacyIdSet];
             for(Account accrec:accountList){
                 accrec.US_WSREMS__Status__c='Certified';
                 updateList.add(accrec);
             }
             if(updateList.size()>0){
                 Database.update(updateList);
             }
             
             for(US_WSREMS__REMS_Service_Summary__c serviceObj:serviceSummaryList){
                 for(Case caseObj:serviceObj.US_WSREMS__Cases__r){
                             if(caseObj.Pharmacy_Participant__c!=null){
                             US_WSREMS__Affiliation__c affnewrepObj= new US_WSREMS__Affiliation__c(); //for other existing roles                                
                             affnewrepObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
                             affnewrepObj.US_WSREMS__End_Date__c = null;
                             affnewrepObj.US_WSREMS__REMSProgram__c =serviceObj.US_WSREMS__REMSProgram__c;
                             affnewrepObj.US_WSREMS__isActive__c = true;
                             affnewrepObj.US_WSREMS__Start_Date__c = System.today();
                             affnewrepObj.US_WSREMS__REMS_Service__c=serviceObj.Id;  
                             affnewrepObj.US_WSREMS__Pharmacy_User__c = caseObj.Pharmacy_Participant__c;
                             affnewrepObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
                             affnewrepObj.RecordTypeId=recordtypeIdbyDeveloperNameMap?.get(SYN_AppLiterals.AFFILIATION_RECTYPE_PHARMACY_USER_AFFILIATION);
                             insertaffiliationList.add(affnewrepObj);
                         
                     }
                 }
             }
 
             if(insertaffiliationList.size()>0){
                SObjectAccessDecision affiliationDecissionInsert =    Security.stripInaccessible(AccessType.CREATABLE,insertaffiliationList);
                 
                if (!affiliationDecissionInsert.getRecords().isEmpty()) {
                   
                   List<Database.SaveResult> resultList = Database.insert(affiliationDecissionInsert.getRecords(), false); 
                   for (Database.SaveResult sr : resultList) {
                       if (!sr.isSuccess()) {
                           for(Database.Error objErr : sr.getErrors()) {
                               System.debug('The following error has occurred.');
                               // Printing error message in Debug log
                               System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                           }
                       }
                    }
                }
             }
             
 
         }
     }
     public static Map<Id,String> retrieveRecTypeIdDeveloperName(String objectName){
        Map<Id,String> recordTypeIdDevNameMap = new Map<Id,String>();
        String updatedStringName = isCustomObject(objectName) ? SYN_AppLiterals.NAMESPACE_STRING+objectName : objectName;
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(updatedStringName).getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = objectSchema.getRecordTypeInfosByName();
        for(String rectypeName:recordTypeInfoMap.keyset()){
            if(recordTypeInfoMap.get(rectypeName).getDeveloperName()!='Master' && !recordTypeInfoMap.get(rectypeName).isMaster())
                recordTypeIdDevNameMap.put(recordTypeInfoMap.get(rectypeName).getRecordTypeId(),recordTypeInfoMap.get(rectypeName).getDeveloperName());            
        }
        return recordTypeIdDevNameMap;
    }
     public static Map<String,Id> retrieveRecTypeDeveloperNameId(String objectName){
        Map<String,Id> recordTypeDevNameIdMap = new Map<String,Id>();
        String updatedStringName = isCustomObject(objectName) ? SYN_AppLiterals.NAMESPACE_STRING+objectName : objectName;
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(updatedStringName).getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = objectSchema.getRecordTypeInfosByName();
        for(String rectypeName:recordTypeInfoMap.keyset()){
            if(recordTypeInfoMap.get(rectypeName).getDeveloperName()!='Master' && !recordTypeInfoMap.get(rectypeName).isMaster())
                recordTypeDevNameIdMap.put(recordTypeInfoMap.get(rectypeName).getDeveloperName(),recordTypeInfoMap.get(rectypeName).getRecordTypeId());            
        }
        return recordTypeDevNameIdMap;
    }
     public static Boolean isCustomObject (string sObjectNameString) {
        return sObjectNameString.endsWithIgnoreCase('__c');
    }
    
    
    public static List<US_WSREMS__Affiliation__c> newAffiliationList = new List<US_WSREMS__Affiliation__c>();
    public static Map<Id, List<US_WSREMS__Affiliation__c>> existingAffiliationMap = new Map<Id, List<US_WSREMS__Affiliation__c>>();
    
    public  static void createAffiliationRecords(Map<Id,US_WSREMS__REMS_Service_Summary__c> newServiceMap, Map<Id,US_WSREMS__REMS_Service_Summary__c> oldServiceMap){
        
        newAffiliationList = new List<US_WSREMS__Affiliation__c>();
        existingAffiliationMap = new Map<Id, List<US_WSREMS__Affiliation__c>>();
        
        Set<Id> pharamcyIdSet = new Set<Id>();
        Set<Id> pharmacyUserIdSet = new Set<Id>();
        Set<Id> prescInstiIdSet = new Set<Id>();
        Set<Id> prescriberIdSet = new Set<Id>();
        Set<Id> patientIdSet = new Set<Id>();
        
        Map<Id,String> serviceRecordtypeIdbyDeveloperNameMap = retrieveRecTypeIdDeveloperName(SYN_AppLiterals.SERVICE_SUMMARY_OBJECT);
        Map<String, Id> recordtypeIdbyDeveloperNameMap = retrieveRecTypeDeveloperNameId(SYN_AppLiterals.AFFILIATION_OBJECT);
        Set<Id> serviceIdSet = new Set<Id>();
        List<US_WSREMS__REMS_Service_Summary__c> filteredServiceList = new List<US_WSREMS__REMS_Service_Summary__c>();
        
        Map<String, Set<String>> progmAndRecTypToCreateAffi = new Map<String, Set<String>>();
        progmAndRecTypToCreateAffi.put('Sodium Oxybate REMS',
            new Set<String>{'Enrollment', 'Reenrollment','Change_Authorized_Representative','Participant_Account_Creation', 'Knowledge_Assessment','Disenrollment'}
        );
        
        for(US_WSREMS__REMS_Service_Summary__c serviceObj : newServiceMap.values()){
    
            if((newServiceMap.get(serviceObj.Id).US_WSREMS__Status__c != oldServiceMap.get(serviceObj.Id).US_WSREMS__Status__c)             
            && newServiceMap.get(serviceObj.Id).US_WSREMS__Status__c == System.Label.US_WSREMS.ServiceStatusClose ){
                
                String recordTypeDevName = serviceRecordtypeIdbyDeveloperNameMap.get(serviceObj.recordTypeId);
                Set<String> recTypToCretAffi = progmAndRecTypToCreateAffi.get(serviceObj.Program_Name__c);
                if(recTypToCretAffi != null && !recTypToCretAffi.isEmpty() && recTypToCretAffi.contains(recordTypeDevName)){
                
                    serviceIdSet.add(serviceObj.Id);
                }
            }
        } 
            
        if(!serviceIdSet.isEmpty()){
        
            List<US_WSREMS__REMS_Service_Summary__c> serviceSummaryList = new List<US_WSREMS__REMS_Service_Summary__c>();
            serviceSummaryList = [SELECT Id, US_WSREMS__Participant__c,US_WSREMS__Requestor_Type__c, US_WSREMS__REMSProgram__c, RecordTypeId, RecordType.Developername,
                     (SELECT id,US_WSREMS__REMS_Service_Summary__c,recordTypeId,Pharmacy_Employee_Type__c, US_WSREMS__Pharmacy_User_ar__c,US_WSREMS__UserType__c,US_WSREMS__Patient__c,SYN_Prescriber__c,US_WSREMS__Facility__c,SYN_Pharmacy__c,
                     SYN_Authorized_Rep__c,SYN_Authorized_Rep__r.SYN_User_Type__c, Pharmacy_Participant__c, Pharmacy_Participant__r.SYN_User_Type__c, US_WSREMS__UserType_ar__c, US_WSREMS__Pharmacy_User__c 
                     FROM US_WSREMS__Cases__r WHERE Status = 'Complete') FROM US_WSREMS__REMS_Service_Summary__c where Id IN: serviceIdSet];
            
               
            Id knowledgeAssmentA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Knowledge_Assessment_A').getRecordTypeId();
            Id knowledgeAssmentB = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Knowledge_Assessment_B').getRecordTypeId();
        
            for(US_WSREMS__REMS_Service_Summary__c serviceObj : serviceSummaryList){                
            
                for(Case caseObj : serviceObj.US_WSREMS__Cases__r){
                
                    if(serviceObj.RecordType.Developername == 'Enrollment' || serviceObj.RecordType.Developername == 'Reenrollment'){
                        
                        if(serviceObj.US_WSREMS__Requestor_Type__c == 'Prescriber' && caseObj.US_WSREMS__Facility__c != NULL && caseObj.SYN_Prescriber__c != NULL){
                            
                            prescriberIdSet.add(caseObj.SYN_Prescriber__c);
                            prescInstiIdSet.add(caseObj.US_WSREMS__Facility__c);
                            filteredServiceList.add(serviceObj);
                            
                        }else if(serviceObj.US_WSREMS__Requestor_Type__c == 'Patient' && caseObj.US_WSREMS__Patient__c != NULL &&  caseObj.SYN_Prescriber__c != NULL){
                            
                            prescriberIdSet.add(caseObj.SYN_Prescriber__c);
                            patientIdSet.add(caseObj.US_WSREMS__Patient__c);
                            filteredServiceList.add(serviceObj);
                            
                        }else if(serviceObj.US_WSREMS__Requestor_Type__c == 'Pharmacy' && caseObj.SYN_Pharmacy__c != NULL && caseObj.SYN_Authorized_Rep__c != NULL ){
                            
                            pharamcyIdSet.add(caseObj.SYN_Pharmacy__c);
                            pharmacyUserIdSet.add(caseObj.SYN_Authorized_Rep__c);
                            filteredServiceList.add(serviceObj);
                        }
                    }else if(serviceObj.RecordType.Developername == 'Knowledge_Assessment' && caseObj.SYN_Pharmacy__c != NULL &&  caseObj.Pharmacy_Participant__c != NULL){
                        
                        pharamcyIdSet.add(caseObj.SYN_Pharmacy__c);
                        pharmacyUserIdSet.add(caseObj.Pharmacy_Participant__c);
                        filteredServiceList.add(serviceObj);                                    
                       
                        if(serviceObj.US_WSREMS__Cases__r.size() > 1){
                            
                            break;  
                        }
                    }else if(serviceObj.RecordType.Developername == 'Disenrollment'){
                    
                        if(serviceObj.US_WSREMS__Requestor_Type__c == 'Prescriber' && caseObj.SYN_Prescriber__c != NULL){
                            
                            prescriberIdSet.add(caseObj.SYN_Prescriber__c);
                            filteredServiceList.add(serviceObj);   
                        }else if(serviceObj.US_WSREMS__Requestor_Type__c == 'Patient' && caseObj.US_WSREMS__Patient__c != NULL){
                            
                            patientIdSet.add(caseObj.US_WSREMS__Patient__c);
                            filteredServiceList.add(serviceObj);   
                        } if(serviceObj.US_WSREMS__Requestor_Type__c == 'Pharmacy' && caseObj.SYN_Pharmacy__c != NULL){
                            
                            pharamcyIdSet.add(caseObj.SYN_Pharmacy__c);
                            filteredServiceList.add(serviceObj);   
                        }
                        
                    
                    }
                }
                
            }
            
            
            Set<String> affiliUniqueSet = new Set<String>();            
            for(US_WSREMS__Affiliation__c affiliatiObj : [SELECT Id, RecordTypeId, US_WSREMS__REMS_Service__c, US_WSREMS__REMSProgram__c, US_WSREMS__End_Date__c, US_WSREMS__isActive__c, US_WSREMS__Pharmacy__c, US_WSREMS__Pharmacy_User__c, US_WSREMS__UserType__c, US_WSREMS__Prescribing_Institution__c, US_WSREMS__Prescriber__c, US_WSREMS__Patient__c FROM US_WSREMS__Affiliation__c 
                            WHERE US_WSREMS__isActive__c = TRUE AND (
                            (US_WSREMS__Pharmacy__c IN: pharamcyIdSet ) OR 
                            (US_WSREMS__Pharmacy_User__c IN: pharmacyUserIdSet ) OR 
                            (US_WSREMS__Prescribing_Institution__c IN: prescInstiIdSet ) OR 
                            (US_WSREMS__Prescriber__c IN: prescriberIdSet) OR 
                            (US_WSREMS__Patient__c IN: patientIdSet))
                            WITH SECURITY_ENFORCED]){           
                
                if(affiliatiObj.US_WSREMS__Pharmacy__c != NULL && affiliatiObj.US_WSREMS__Pharmacy_User__c != NULL){
                    
                    affiliUniqueSet.add(affiliatiObj.US_WSREMS__Pharmacy__c+'_'+affiliatiObj.US_WSREMS__Pharmacy_User__c);
                    
                    if(!existingAffiliationMap.containsKey(affiliatiObj.US_WSREMS__Pharmacy_User__c)){
                        existingAffiliationMap.put(affiliatiObj.US_WSREMS__Pharmacy_User__c, new List<US_WSREMS__Affiliation__c>());
                    }
                    List<US_WSREMS__Affiliation__c> affList = existingAffiliationMap.get(affiliatiObj.US_WSREMS__Pharmacy_User__c);
                    affList.add(affiliatiObj);
                    existingAffiliationMap.put(affiliatiObj.US_WSREMS__Pharmacy_User__c, affList);
                    
                }   
                
                if(affiliatiObj.US_WSREMS__Prescriber__c != NULL && affiliatiObj.US_WSREMS__Prescribing_Institution__c != NULL){
                    
                    affiliUniqueSet.add(affiliatiObj.US_WSREMS__Prescriber__c+'_'+affiliatiObj.US_WSREMS__Prescribing_Institution__c);
                    
                    if(!existingAffiliationMap.containsKey(affiliatiObj.US_WSREMS__Prescriber__c)){
                        existingAffiliationMap.put(affiliatiObj.US_WSREMS__Prescriber__c, new List<US_WSREMS__Affiliation__c>());
                    }
                    List<US_WSREMS__Affiliation__c> affList = existingAffiliationMap.get(affiliatiObj.US_WSREMS__Prescriber__c);
                    affList.add(affiliatiObj);
                    existingAffiliationMap.put(affiliatiObj.US_WSREMS__Prescriber__c, affList);
                }   
                
                if(affiliatiObj.US_WSREMS__Patient__c != NULL && affiliatiObj.US_WSREMS__Prescriber__c != NULL){
                    
                    affiliUniqueSet.add(affiliatiObj.US_WSREMS__Patient__c+'_'+affiliatiObj.US_WSREMS__Prescriber__c);
                    
                    if(!existingAffiliationMap.containsKey(affiliatiObj.US_WSREMS__Patient__c)){
                        existingAffiliationMap.put(affiliatiObj.US_WSREMS__Patient__c, new List<US_WSREMS__Affiliation__c>());
                    }
                    List<US_WSREMS__Affiliation__c> affList = existingAffiliationMap.get(affiliatiObj.US_WSREMS__Patient__c);
                    affList.add(affiliatiObj);
                    existingAffiliationMap.put(affiliatiObj.US_WSREMS__Patient__c, affList);
                }   
                
            }
            
            for(US_WSREMS__REMS_Service_Summary__c serviceObj : filteredServiceList){  
                Integer totalCasesCount = serviceObj.US_WSREMS__Cases__r.size();
                Integer caseLoopcount =0; 
                Boolean createAffiliation  = false;
                String affiliationType = '';
                String synPharmacy;
                Id pharmacyParticipant;
                US_WSREMS__Affiliation__c knowledgeaffiliRecord = new US_WSREMS__Affiliation__c();
                for(Case caseObj : serviceObj.US_WSREMS__Cases__r){
                    US_WSREMS__Affiliation__c affiliRecord = new US_WSREMS__Affiliation__c();
                    if(serviceObj.RecordType.Developername == 'Disenrollment'){
                        
                        if(serviceObj.US_WSREMS__Requestor_Type__c == 'Prescriber'){
                        
                            endAffiliationOnDisEnroll(caseObj.SYN_Prescriber__c);   
                        }else if(serviceObj.US_WSREMS__Requestor_Type__c == 'Patient'){
                            
                            endAffiliationOnDisEnroll(caseObj.US_WSREMS__Patient__c);
                        }else if(serviceObj.US_WSREMS__Requestor_Type__c == 'Pharmacy'){
                            
                            endAffiliationOnDisEnroll(caseObj.SYN_Pharmacy__c);
                        }
                    }else  if(serviceObj.RecordType.Developername == 'Enrollment' || serviceObj.RecordType.Developername == 'Reenrollment'){
                        
                        if(serviceObj.US_WSREMS__Requestor_Type__c == 'Prescriber' && !affiliUniqueSet.contains(caseObj.SYN_Prescriber__c+'_'+caseObj.US_WSREMS__Facility__c)){
                            
                            
                            affiliRecord = SYN_AffiliationHandler.createPrescriberAndPresInstiAffi(caseObj.SYN_Prescriber__c,caseObj.US_WSREMS__Facility__c, serviceObj.US_WSREMS__REMSProgram__c, serviceObj.Id);
                            endAffiliation(caseObj.SYN_Prescriber__c, affiliRecord.recordTypeId);                            
                        }else if(serviceObj.US_WSREMS__Requestor_Type__c == 'Patient'  && !affiliUniqueSet.contains(caseObj.US_WSREMS__Patient__c+'_'+caseObj.SYN_Prescriber__c)){
                           
                            affiliRecord = SYN_AffiliationHandler.createPatientAndPresAffil(caseObj.US_WSREMS__Patient__c, caseObj.SYN_Prescriber__c, serviceObj.US_WSREMS__REMSProgram__c, serviceObj.Id);
                            endAffiliation(caseObj.US_WSREMS__Patient__c, affiliRecord.recordTypeId);
                        }else  if(serviceObj.US_WSREMS__Requestor_Type__c == 'Pharmacy'  && !affiliUniqueSet.contains(caseObj.SYN_Pharmacy__c+'_'+caseObj.SYN_Authorized_Rep__c)){
                           
                            affiliRecord = SYN_AffiliationHandler.createPharmacyAndPharmacyParti(caseObj.SYN_Pharmacy__c, caseObj.SYN_Authorized_Rep__c,  serviceObj.US_WSREMS__REMSProgram__c, serviceObj.Id);
                            affiliRecord.US_WSREMS__UserType__c = caseObj.SYN_Authorized_Rep__r.SYN_User_Type__c;
                            endAffiliation(caseObj.SYN_Authorized_Rep__c, affiliRecord.recordTypeId);
                        }
                        
                    }
                    else  if(serviceObj.RecordType.Developername == 'Knowledge_Assessment'  &&  !affiliUniqueSet.contains(caseObj.SYN_Pharmacy__c+'_'+caseObj.Pharmacy_Participant__c) ){
                        ++caseLoopcount;
                        List<Case> casesAList = new List<Case>();
                        List<Case> casesBList = new List<Case>();
                        if(caseObj.recordTypeId == knowledgeAssmentA) {
                            casesAList.add(caseObj);
                        }
                        else if(caseObj.recordTypeId == knowledgeAssmentB) {
                            casesBList.add(caseObj);
                        }
                        if(caseLoopcount == totalCasesCount && casesAList.size()> 0 && casesBList.size() >0) {
                            for(case ca : casesAList) {
                                affiliationType = ca.Pharmacy_Participant__r.SYN_User_Type__c;
                                synPharmacy = ca.SYN_Pharmacy__c;
                                pharmacyParticipant = ca.Pharmacy_Participant__c;
                                for(case cb :casesBList ) {
                                    if(ca.Pharmacy_Employee_Type__c != null && !ca.Pharmacy_Employee_Type__c.split(';').contains('Authorized Representative') && cb.Pharmacy_Employee_Type__c != null && !cb.Pharmacy_Employee_Type__c.split(';').contains('Authorized Representative')  ) {
                                        createAffiliation = true;
                                    }
                                }
                                
                            }
                        } else if(caseLoopcount == totalCasesCount && casesAList.size() > 0) {
                            for(case ca : casesAList) {
                                affiliationType = ca.Pharmacy_Participant__r.SYN_User_Type__c;
                                synPharmacy = ca.SYN_Pharmacy__c;
                                pharmacyParticipant = ca.Pharmacy_Participant__c;
                                if(ca.Pharmacy_Employee_Type__c != null && !ca.Pharmacy_Employee_Type__c.split(';').contains('Authorized Representative')) {
                                    createAffiliation = true;
                                }
                            }
                        } else if(caseLoopcount == totalCasesCount && casesBList.size() > 0) {
                             for(case cb : casesBList) {
                                affiliationType = cb.Pharmacy_Participant__r.SYN_User_Type__c;
                                synPharmacy = cb.SYN_Pharmacy__c;
                                pharmacyParticipant = cb.Pharmacy_Participant__c;
                                if(cb.Pharmacy_Employee_Type__c != null && !cb.Pharmacy_Employee_Type__c.split(';').contains('Authorized Representative')) {
                                    createAffiliation = true;
                                }
                            }
                        }
                        
                    }
                    
                    if(affiliRecord != NULL && affiliRecord.US_WSREMS__Start_Date__c != NULL){
                        newAffiliationList.add(affiliRecord);
                    }
                    
                    if(serviceObj.RecordType.Developername == 'Knowledge_Assessment'  && serviceObj.US_WSREMS__Cases__r.size() > 1){
                        
                      
                    }
                }
                if(createAffiliation) {
                    knowledgeaffiliRecord = SYN_AffiliationHandler.createPharmacyAndPharmacyParti(synPharmacy,pharmacyParticipant, serviceObj.US_WSREMS__REMSProgram__c, serviceObj.Id);
                    if(knowledgeaffiliRecord != NULL && knowledgeaffiliRecord.US_WSREMS__Start_Date__c != NULL){
                        newAffiliationList.add(knowledgeaffiliRecord);
                    }   
                    knowledgeaffiliRecord.US_WSREMS__UserType__c = affiliationType;
                    endAffiliation(pharmacyParticipant, knowledgeaffiliRecord.recordTypeId);
                }
            }
            if(!newAffiliationList.isEmpty()){
            
                upsert newAffiliationList;
            }
        }
    }
       
    //Method to end existing affiliation record 
    public static void endAffiliation(Id keyId, String recordTypeId){
        
        if(existingAffiliationMap.containsKey(keyId)){
                                
            for(US_WSREMS__Affiliation__c existAffili: existingAffiliationMap.get(keyId)){
                
                if(existAffili.recordTypeId == recordTypeId){
                    existAffili.US_WSREMS__End_Date__c = System.Today();
                    existAffili.US_WSREMS__isActive__c = FALSE;
                    newAffiliationList.add(existAffili);
                }
            }
        }
    }
    
     //Method to end existing affiliation record 
    public static void endAffiliationOnDisEnroll(Id keyId){
        
        if(existingAffiliationMap.containsKey(keyId)){
                                
            for(US_WSREMS__Affiliation__c existAffili: existingAffiliationMap.get(keyId)){
                
                existAffili.US_WSREMS__End_Date__c = System.Today();
                existAffili.US_WSREMS__isActive__c = FALSE;
                newAffiliationList.add(existAffili);                
            }
        }
    }
    public static void accountStatusUpdate(List<US_WSREMS__REMS_Service_Summary__c> rssList, Map<Id, US_WSREMS__REMS_Service_Summary__c> rssMap){
        SYN_AccountStatusUpdation.accountStatusUpdatewWithCustomMetadata(rssList, rssMap);  
    }

    /**
     * method: beforeRssInsert
     * createdby : Chai dated 2/24/2023
     * description: Method to handler Before Insert logics 
     */
    public static void beforeRssInsert(List<US_WSREMS__REMS_Service_Summary__c> rssList){
        for (US_WSREMS__REMS_Service_Summary__c RSS : rssList){
            // Set the RSS status value to open on creation
            if (String.isBlank(RSS.US_WSREMS__Status__c)){
                RSS.US_WSREMS__Status__c = 'Open';
            }
        }
    }

   public static void certificationCommunication(List<US_WSREMS__REMS_Service_Summary__c> rssList,  Map<Id, US_WSREMS__REMS_Service_Summary__c> rssMap){   
        Set<Id> rssIdSet = new Set<Id>();   
            Id enrollServiceRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Enrollment');   
            Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
            Id patientEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');
            Id pharmacyEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Pharmacy_Enrollment');
            Id distributorEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Distributor_Enrollment');
            Id pccCaseRecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Counseling_Checklist');
            Id rmrCaseRecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Risk_Management_Report');
            Id pccServiceRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Patient_Counseling_Checklist');
            Id rmrServiceRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Risk_Management_Report');  
            String rssParticipantType;
             //BT6825-905 userstorychanges
            List<REMS_Outbound_Communication__c> communicationRecList=new List<REMS_Outbound_Communication__c>();

        for(US_WSREMS__REMS_Service_Summary__c rss: rssList){   
              if(rssMap == null || rssMap.isEmpty()){
                    rssIdSet.add(rss.Id); 
                }  
            if(rssMap != null){   
               if(rss.US_WSREMS__Service_Outcome__c == 'Successful' && rss.US_WSREMS__Status__c == 'Closed' &&     
                   rssMap.get(rss.Id).US_WSREMS__Service_Outcome__c != 'Successful' && (rss.RecordTypeId == enrollServiceRecTypeId || rss.RecordTypeId == pccServiceRecTypeId || rss.RecordTypeId == rmrServiceRecTypeId)
                   && (rss.US_WSREMS__Requestor_Type__c == 'Prescriber' || rss.US_WSREMS__Requestor_Type__c == 'Pharmacy' || rss.US_WSREMS__Requestor_Type__c =='Patient' || rss.US_WSREMS__Requestor_Type__c == 'Distributor')){   
                       rssIdSet.add(rss.Id);    
                   } 
           } //end of If condition   
           
        }   
            for (US_WSREMS__REMS_Service_Summary__c rssObj : [SELECT Id, US_WSREMS__Requestor_Type__c, (SELECT Id,recordTypeId,US_WSREMS__Participant__c,Status,US_WSREMS__Outcome__c,ownerId,US_WSREMS__Participant__r.personContactId,SYN_Authorized_Rep__r.personContactId,    
            US_WSREMS__Prescriber__r.Fax,US_WSREMS__Participant__r.Fax, US_WSREMS__Program_Name__c,Medical_Conditions__c, US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c, 
                US_WSREMS__Patient__r.Fax,US_WSREMS__Pharmacy_User__r.Fax,owner.email,owner.name,CaseNumber,Subject,US_WSREMS__Email__c ,    
                US_WSREMS__Prescriber__r.firstName, US_WSREMS__Prescriber__r.LastName, US_WSREMS__Patient__r.firstName,SYN_Prescriber__r.US_WSREMS__Email__c,      
                US_WSREMS__Patient__r.LastName, US_WSREMS__Pharmacy_User__r.firstName,SYN_Prescriber__r.Fax,SYN_Prescriber__r.personContactId,SYN_Prescriber_Fax__c , US_WSREMS__Pharmacy_User__r.LastName,    
                US_WSREMS__Participant__r.US_WSREMS__Email__c,Account_Record_Type__c,SYN_Name_of_Reporter__r.personContactId,SYN_Name_of_Reporter__r.US_WSREMS__Preferred_Contact_Method__c,SYN_Type_of_Reporter__c,SYN_Pharmacist__r.US_WSREMS__Email__c,SYN_Pharmacist__r.personContactId,US_WSREMS__Distributor__r.personContactId,SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c,SYN_Authorized_Rep__r.US_WSREMS__Email__c,SYN_Authorized_Rep__c,
                US_WSREMS__Participant__r.firstName,SYN_Name_of_Reporter__r.Fax,Account.Fax,US_WSREMS__Participant__r.LastName,US_WSREMS__Participant__r.Name,X1_Pharmacy_Participant__c, X1_Pharmacy_Participant__r.Name, X1_Pharmacy_Participant__r.US_WSREMS__Email__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c FROM US_WSREMS__Cases__r )  
               FROM US_WSREMS__REMS_Service_Summary__c WHERE Id IN :rssIdSet]){ 
                if(rssObj.US_WSREMS__Cases__r != null ){
                    rssParticipantType =  rssObj.US_WSREMS__Requestor_Type__c;
                    for(case caseObj: rssObj.US_WSREMS__Cases__r){  
                            if(caseObj.status == 'Complete' && caseObj.US_WSREMS__Outcome__c == 'Complete' && caseObj.US_WSREMS__Preferred_Contact_Method__c =='Email' && (caseObj.RecordTypeId == prescriberEnrollCaseRecTypeId ||caseObj.RecordTypeId == pharmacyEnrollCaseRecTypeId) ){
                                
                               //BT6825-905 userstorychanges
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseObj,caseObj.US_WSREMS__Preferred_Contact_Method__c,'SOX-Stakeholder Certification Confirmati'));  
                            }    
                            else if(caseObj.status == 'Complete' && caseObj.US_WSREMS__Outcome__c == 'Complete' && caseObj.US_WSREMS__Preferred_Contact_Method__c =='Fax' && (caseObj.RecordTypeId == prescriberEnrollCaseRecTypeId ||caseObj.RecordTypeId == pharmacyEnrollCaseRecTypeId) ){    
                                  //BT6825-905 userstorychanges
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseObj,caseObj.US_WSREMS__Preferred_Contact_Method__c,'Con-StakeholderCertificationConfirmation')); 
                            }
                            else if(caseObj.status == 'Complete' && caseObj.US_WSREMS__Outcome__c == 'Complete' && caseObj.US_WSREMS__Preferred_Contact_Method__c =='Fax' && (caseObj.RecordTypeId == distributorEnrollCaseRecTypeId) ){    
                                   //BT6825-905 userstorychanges
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseObj,caseObj.US_WSREMS__Preferred_Contact_Method__c,'Con-DistributorEnrollmentConfirmation')); 
                            }
                            else if(caseObj.status == 'Complete' && caseObj.US_WSREMS__Outcome__c == 'Complete' && caseObj.US_WSREMS__Preferred_Contact_Method__c =='Email' && (caseObj.RecordTypeId == distributorEnrollCaseRecTypeId) ){    
                                  //BT6825-905 userstorychanges
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseObj,caseObj.US_WSREMS__Preferred_Contact_Method__c,'SOX-Distributor Enrollment Confirmation')); 
                            }
                            else if(caseObj.status == 'Complete' && caseObj.US_WSREMS__Outcome__c == 'Complete'  && caseObj.RecordTypeId == pccCaseRecTypeId){    
                              communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseObj,'Email','SOX-Patient Counseling Checklist Process'));
                            }
                            else if(caseObj.status == 'Complete' && caseObj.US_WSREMS__Outcome__c == 'Complete' && ((rssParticipantType == 'Prescriber' && caseObj.SYN_Name_of_Reporter__r.US_WSREMS__Preferred_Contact_Method__c =='Email' && caseObj.SYN_Type_of_Reporter__c == 'Prescribing Physician' && caseObj.Account_Record_Type__c == 'Prescriber') || (caseObj.SYN_Type_of_Reporter__c == 'Pharmacist' && rssParticipantType == 'Pharmacy' && caseObj.Account_Record_Type__c == 'Pharmacy Participant')) && caseObj.RecordTypeId == rmrCaseRecTypeId){   
                             communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseObj,'Email','SOX-Risk Management Report Processed Suc'));
                            }
                            else if(caseObj.status == 'Complete' && caseObj.US_WSREMS__Outcome__c == 'Complete' && caseObj.US_WSREMS__Preferred_Contact_Method__c =='Fax' && caseObj.RecordTypeId == pharmacyEnrollCaseRecTypeId){  
                                   //BT6825-905 userstorychanges
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseObj,caseObj.US_WSREMS__Preferred_Contact_Method__c,'Con-StakeholderCertifiConfPharmacist'));
                            }
                            else if(caseObj.status == 'Complete' && caseObj.US_WSREMS__Outcome__c == 'Complete' && caseObj.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c =='Email' && caseObj.RecordTypeId == patientEnrollCaseRecTypeId){  
                                   //BT6825-866 userstorychanges
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseObj,caseObj.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c,'SOX-Patient Enrollment Confirmation'));
                            }
                        
                            else if(caseObj.status == 'Complete' && caseObj.US_WSREMS__Outcome__c == 'Complete' && caseObj.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c =='Fax'  && caseObj.RecordTypeId == patientEnrollCaseRecTypeId){  
                                 //BT6825-905 userstorychanges
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseObj,caseObj.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c,'Con-PatientEnrollmentConfirmation'));
                        }
                         else if(caseObj.status == 'Complete' && caseObj.US_WSREMS__Outcome__c == 'Complete' && rssParticipantType == 'Prescriber'&& caseObj.SYN_Type_of_Reporter__c == 'Prescribing Physician' && caseObj.Account_Record_Type__c == 'Prescriber' && caseObj.SYN_Name_of_Reporter__r.US_WSREMS__Preferred_Contact_Method__c =='Fax'  && caseObj.RecordTypeId == rmrCaseRecTypeId){  
                                  //BT6825-905 userstorychanges
                            communicationRecList.add(SYN_SOXCorrespondenceHandler.createREMSCommunicationRecords(caseObj,'Fax','Con-RiskManagementReportProcessedSuccess'));
                        }
                    }   
                }   
            }  
            
            if(communicationRecList!=null && !communicationRecList.isEmpty()){
                insert communicationRecList;
            }
    }

    //Method to update Account fields from REMS Services
    public static void accountFieldUpdate(List<US_WSREMS__REMS_Service_Summary__c> rssList,  Map<Id, US_WSREMS__REMS_Service_Summary__c> rssMap){
        Id disEnrollServiceRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Disenrollment');
        Id enrollServiceRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Enrollment');
        Id changeRepStatusRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');

        list<Account> accList=new List<Account>();
        Set<Id> rssIdSet = new Set<Id>();   
        
        List<Case> caseList = new List<Case>();
        
        for(US_WSREMS__REMS_Service_Summary__c rs:rssList)
        { 
            if(rs.US_WSREMS__Service_Outcome__c == 'Successful' && rs.US_WSREMS__Status__c == 'Closed' && rssMap.get(rs.Id).US_WSREMS__Status__c !='Closed'  && rs.Program_Name__c == 'Macitentan REMS' && 
               ((rs.RecordTypeId == enrollServiceRecTypeId  && rs.US_WSREMS__Requestor_Type__c == 'Patient')|| rs.RecordTypeId == disEnrollServiceRecTypeId) ||
               (rs.RecordTypeId == changeRepStatusRecTypeId  && rs.US_WSREMS__Requestor_Type__c == 'Prescriber'))
            {
                rssIdSet.add(rs.Id); 
            }
        }
        if(!rssIdSet.isEmpty()){
            caseList=[SELECT Id,US_WSREMS__Patient__c,SYN_Prescriber__c,SYN_Pharmacy__c,US_WSREMS__Patient__r.Sub_Status__c,
                      SYN_Prescriber__r.Sub_Status__c,SYN_Pharmacy__r.Sub_Status__c,Pharmacy_Participant__c,Pharmacy_Participant__r.Sub_Status__c,
                      US_WSREMS__Distributor__r.Sub_Status__c,US_WSREMS__Distributor__c,US_WSREMS__Deactivation_Reason__c,
                      US_WSREMS__Patient_Risk_Category__c,Recent_Patient_Reproductive_Status_Date__c,US_WSREMS__Participant__c,
                      US_WSREMS__Patient__r.US_WSREMS__Patient_Risk_Category__c, US_WSREMS__Patient__r.Patient_Reproductive_Status_Date__c, 
                      Recordtype.DeveloperName,US_WSREMS__Participant__r.Sub_Status__c  
                      FROM Case WHERE US_WSREMS__REMS_Service_Summary__c In :rssIdSet ];
        } 
        if(!caseList.isEmpty()){
            for(Case c:caseList)
            {
                if(String.isBlank(c.US_WSREMS__Deactivation_Reason__c)){
                c.US_WSREMS__Patient__r.US_WSREMS__Patient_Risk_Category__c = c.US_WSREMS__Patient_Risk_Category__c;
                c.US_WSREMS__Patient__r.Patient_Reproductive_Status_Date__c = System.today();
                accList.add(c.US_WSREMS__Patient__r);
                }
                
            //Changes added as part of BT7433-2422 by DILEEP Gurram(Wilco)
               if(c.US_WSREMS__Deactivation_Reason__c != null && c.Recordtype.DeveloperName == 'Deactivation' && c.US_WSREMS__Participant__c != null){
                    c.US_WSREMS__Participant__r.Sub_Status__c = c.US_WSREMS__Deactivation_Reason__c; 
                    accList.add(c.US_WSREMS__Participant__r);
                }
                
                
              } 
        }
        if (!accList.isEmpty()) {
            try{
                update accList;
            }catch(exception e){
                system.debug('Error Message'+e.getMessage());
            }
        }
    }
    /**
     * method: checkOpenTasks
     * createdby : Priya dated 2/7/2023
     * description: This method is used to check for open tasks for the REMS Service Summary and throw error on completion of the service summary
     */
    public static void checkOpenTasks(Map<Id,US_WSREMS__REMS_Service_Summary__c> mapREMSService){
        List<Task> lstTask = new List<Task>();
        List<Id> lstREMSUpdated = new List<Id>();
        Set<Id> setREMSServiceId = new Set<Id>();
        Map<Id, String> mapProgramIdToName = new Map<Id, String>();
        for(US_WSREMS__REMS_Program__c objProgram : [SELECT Id, Name FROM US_WSREMS__REMS_Program__c]){
            mapProgramIdToName.put(objProgram.Id, objProgram.Name);
        }
        for(US_WSREMS__REMS_Service_Summary__c objREMSService : mapREMSService.values()){
             if((objREMSService.US_WSREMS__Status__c == 'Closed' || objREMSService.US_WSREMS__Service_Outcome__c == 'Successful') &&
             ((objREMSService.US_WSREMS__Requestor_Type__c == 'Distributor'|| objREMSService.US_WSREMS__Requestor_Type__c =='Pharmacy') && mapProgramIdToName.get(objREMSService.US_WSREMS__REMSProgram__c) == 'Macitentan REMS')){
                lstREMSUpdated.add(objREMSService.Id);
            }
        }
        if(!lstREMSUpdated.isEmpty()){
            for( Task objTask : [SELECT Id, WhatId, Status FROM Task WHERE WhatId IN :lstREMSUpdated AND Status != 'Completed']){
                setREMSServiceId.add(objTask.WhatId);
            }
        }
        if(!setREMSServiceId.isEmpty()){
            for(Id idRemsService : setREMSServiceId){
                mapREMSService.get(idRemsService).addError('Please complete all the checklists before closing the REMS Service');
            }
        }
    }
    
     /********************************************************************************************************************************************************
    Method Name     : createPortalConfirmEmailTask()
   
    ********************************************************************************************************************************************************** */
    public static void createPortalConfirmEmailTask(List<US_WSREMS__REMS_Service_Summary__c> rssList, Map<Id, US_WSREMS__REMS_Service_Summary__c> rssMap){
        Id Maci_Escalation_QueueId = SYN_CommonUtility.getMaciEscQueue();
          List<Task> insertTaskList = new List<Task>();
        Id TaskrctypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SocialDeterminant').getRecordTypeId();
        Id enrollServiceRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Enrollment'); 
        Id reenrollServiceRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Reenrollment'); 
        for(US_WSREMS__REMS_Service_Summary__c rems : rssList){
            if(rems.US_WSREMS__Is_Portal__c == true && (rems.recordTypeId == enrollServiceRecTypeId || rems.recordTypeId == reenrollServiceRecTypeId)){
                Task completeisEnrollmentTask;
                completeisEnrollmentTask = SYN_PortalEnrollmentController.create_Task(rems.US_WSREMS__REMSProgram__c,System.today(),Maci_Escalation_QueueId,'Confirm Email/Fax was Sent',TaskrctypeId, rems.Id,''); 
                completeisEnrollmentTask.Status ='Completed';
                insertTaskList.add(completeisEnrollmentTask);
            }
            
        }
          if(!insertTaskList.isEmpty()){
              database.insert(insertTaskList,false);
          }
    }
    
   

}