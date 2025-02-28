/**
* @File Name          : SYN_CaseTriggerHelper.cls
* @Description        : Extended logic for Case trigger and hanlder
* @Trigger            : SYN_CaseTrigger
* @TestClass          : 
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 1.0    02/22/2022      Chaitanya Nandamuri (Wilco)     Helper class for Change of Information to update participant (BT6825- 249).
* 2.0    06/16/2022      Chaitanya Nandamuri (Wilco)     Logic to find RDA Rejection Reason and update case status reason (BT6825-52).
* 3.0   09/14/2022       Chaitanya Nandamuri (Wilco)     Moving some RDA Rejections to validation rules for SOX program(Bt6825-583)
* 4.0    16/02/2023     Praveen V (Wilco)                MACIAutomationCommunicationFromCase: BT7433-430
*5.0     09/15/2024     Dileep Gurram(Wilco)             Changes added in createREMSTask Method as Part of BT7433-2262 AND BT7433-2354
*6.0     09/15/2024     Dileep Gurram(Wilco)             Changes added in reverseRDAValidationOnService Method for Revrese RDA creation as Part of BT7433-2401.
*7.0      09/16/2024        Dileep Gurram(Wilco)         Changes added regarding Duplicate record type issue in patientPregnancyRDACase Method from line number: 941 to 944

**/
public class SYN_CaseTriggerHelper {
    
    public static Id AccPatientRCTyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();//BT6825-52
    public static Id AccPrescreiberRCTyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();//BT6825-52
    public static Id AccPharmacyRCTyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();//BT6825-52
    public static Id CseRDARCTyId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();//BT6825-52
    public static string RDArejectionReasonsStr;
    public static List<US_WSREMS__Affiliation__c> affiliationRecsToInsert = New List<US_WSREMS__Affiliation__c>();
    private static Map <Id, schema.RecordtypeInfo> mapCaseRecordTypesById = Schema.SObjectType.case.getRecordtypeInfosById();
    public static Set<Id> pharmacyUserIds= New Set<Id>();
    
    //public static Id SoxProgramId = SYN_CommonUtility.SOXprogramId();
    
    public static void updateAccount(Map<Id,Case> newCaseMap,Map<Id,Case> oldCaseMap, Set<Id>CaseRec) {
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Map<String,Map<String,String>> requestorTypeTargetsourceMap = new Map<String,Map<String,String>>(); 
        if(CaseRec.isEmpty()){
            return;
        }
        for (US_WSREMS__Field_Mapping_Config__mdt fMapSerRec : [SELECT Id, US_WSREMS__IsActive__c, US_WSREMS__Order__c, US_WSREMS__Request_Type__c, US_WSREMS__Source_Field__c, US_WSREMS__Source_Object__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c, NamespacePrefix  FROM
                                                                US_WSREMS__Field_Mapping_Config__mdt WHERE  US_WSREMS__Source_Object__c =:  SYN_Utilitycls.CASE_OBJECT 
                                                                AND US_WSREMS__Target_Object__c =: SYN_Utilitycls.ACCOUNT_OBJECT AND NamespacePrefix != 'US_WSREMS' AND US_WSREMS__IsActive__c = true  AND (US_WSREMS__Program__r.MasterLabel =: SYN_Utilitycls.SOX_PROGRAM_NAME OR US_WSREMS__Program__r.MasterLabel =: SYN_Utilitycls.MACI_PROGRAM_NAME)  ] ){
                                                                    string requestTypeStr = fMapSerRec.US_WSREMS__Request_Type__c;
                                                                    
                                                                    String SourceStr = fMapSerRec.US_WSREMS__Source_Field__c.contains('__c') && fMapSerRec.NamespacePrefix == 'US_WSREMS'  ? 'US_WSREMS__'+fMapSerRec.US_WSREMS__Source_Field__c : fMapSerRec.US_WSREMS__Source_Field__c;
                                                                    String TargetStr = fMapSerRec.US_WSREMS__Target_Field__c.contains('__c') && fMapSerRec.NamespacePrefix == 'US_WSREMS' ? 'US_WSREMS__'+fMapSerRec.US_WSREMS__Target_Field__c : fMapSerRec.US_WSREMS__Target_Field__c;
                                                                    
                                                                    if(fMapSerRec.US_WSREMS__Request_Type__c != null && fMapSerRec.US_WSREMS__Request_Type__c.split(',') != null && fMapSerRec.US_WSREMS__Request_Type__c.split(',').size()>0){
                                                                        for(String requesType:fMapSerRec.US_WSREMS__Request_Type__c.split(',') ){
                                                                            if(requestorTypeTargetsourceMap.get(requesType)!= null){       
                                                                                Map<String,String> targetsourcefieldMap = new Map<String,String>();
                                                                                targetsourcefieldMap.put(TargetStr,SourceStr);
                                                                                requestorTypeTargetsourceMap.get(requesType).putAll(targetsourcefieldMap);
                                                                            }
                                                                            else{
                                                                                Map<String,String> targetsourcefieldMap = new Map<String,String>();
                                                                                targetsourcefieldMap.put(TargetStr,SourceStr);
                                                                                requestorTypeTargetsourceMap.put(requesType,targetsourcefieldMap);
                                                                            }
                                                                        }
                                                                        
                                                                    } else{
                                                                        if(requestorTypeTargetsourceMap.get(fMapSerRec.US_WSREMS__Request_Type__c)!= null){       
                                                                            Map<String,String> targetsourcefieldMap = new Map<String,String>();
                                                                            targetsourcefieldMap.put(TargetStr,SourceStr);
                                                                            requestorTypeTargetsourceMap.get(fMapSerRec.US_WSREMS__Request_Type__c).putAll(targetsourcefieldMap);
                                                                        }
                                                                        else{
                                                                            Map<String,String> targetsourcefieldMap = new Map<String,String>();
                                                                            targetsourcefieldMap.put(TargetStr,fMapSerRec.US_WSREMS__Source_Object__c);
                                                                            requestorTypeTargetsourceMap.put(fMapSerRec.US_WSREMS__Request_Type__c,targetsourcefieldMap);
                                                                        }
                                                                        
                                                                    }       
                                                                    if(requestorTypeTargetsourceMap!=null && requestorTypeTargetsourceMap.size()>0){                        
                                                                        for (Id CseId : CaseRec){
                                                                            case caseObj = newCaseMap.get(CseId);
                                                                            if(caseObj.US_WSREMS__Service_Requestor_Type__c !=null
                                                                               && requestorTypeTargetsourceMap.get(caseObj.US_WSREMS__Service_Requestor_Type__c )!=null){
                                                                                   Account actObj = new Account();
                                                                                   actObj.put('id',caseObj.US_WSREMS__Participant__c );
                                                                                   for(String targetField:requestorTypeTargetsourceMap.get(caseObj.US_WSREMS__Service_Requestor_Type__c ).keyset()){
                                                                                       Map<String,String> targetSourceFieldMap = requestorTypeTargetsourceMap.get(caseObj.US_WSREMS__Service_Requestor_Type__c );
                                                                                       String srcfield = targetSourceFieldMap.get(targetField);
                                                                                       actObj.put(targetField,caseObj.get(srcfield));
                                                                                       
                                                                                       if(caseObj.US_WSREMS__REMS_Program__c == SYN_CommonUtility.MACIprogramId()){
                                                                                           
                                                                                           if (!String.isblank(String.valueOf(caseObj.get(srcfield)))){
                                                                                               actObj.put(targetField,caseObj.get(srcfield));
                                                                                           }
                                                                                       }
                                                                                   }
                                                                                   accountMap.put(actObj.Id,actObj);
                                                                               }
                                                                        }
                                                                        
                                                                        
                                                                    }
                                                                    
                                                                }
        //added by ismail
                       if(accountMap!=null && accountMap.size()>0){
                                                                           for(Database.SaveResult sr : Database.update(accountMap.values(), false)){
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                    
                }else{
                    System.debug('The following error has occurred.'); 
                }
            }
            
        }
    }
    
    public static void RDACaseValidation(List<case>RDACaseLst){
        Id SoxProgramId;
        if (!test.isRunningTest()){
            SoxProgramId = SYN_CommonUtility.SOXprogramId(); 
        }      
        List<Id> ParticipantIdLst = new List<Id>();
        
        Map<Id,Boolean> participantStatusMap = new Map<Id,Boolean>();// 1,2 Condition check
        Map<Id,Boolean> ExistingApprovedRDAStatusMap = new Map<Id,Boolean>(); // 3 condition check
        Map<Id,Case> MostRecentApprovedRDAMap = new Map<Id,case>(); // step 4 validation
        Map<String,string> RDArejRuleToMsgMap = RDArejectionRuleToMsgMap(SYN_Utilitycls.SOX_PROGRAM_NAME);
        List<id> newcaseslst = new List<Id>();
        String RDArejectsStr ='';
        // First Iteration to collect all the Participants on New case
        for(case cseobj: RDACaseLst){
            if (!String.isBlank(cseobj.US_WSREMS__Patient__c)){
                ParticipantIdLst.add(cseobj.US_WSREMS__Patient__c );  
            }
            if (!String.isBlank(cseobj.SYN_Prescriber__c )){
                ParticipantIdLst.add(cseobj.SYN_Prescriber__c );
            }
            if (!String.isBlank(cseobj.US_WSREMS__Patient__c)){
                ExistingApprovedRDAStatusMap.put(cseobj.US_WSREMS__Patient__c,false);
                MostRecentApprovedRDAMap.put(cseobj.US_WSREMS__Patient__c,null);
            }
            
            newcaseslst.add(cseobj.Id);
        }
        
        // Loop on Participant to cover Rule 1 and Rule 2
        for(Account acc: [select id , recordtypeId, US_WSREMS__Status__c  from account where Id In: ParticipantIdLst]){
            
            if(acc.recordtypeId ==AccPatientRCTyId){
                participantStatusMap.put(acc.id, acc.US_WSREMS__Status__c == 'Enrolled' ? true : false);
            }
            if(acc.recordtypeId == AccPrescreiberRCTyId){
                participantStatusMap.put(acc.id, acc.US_WSREMS__Status__c == 'Certified' ? true : false);  
            }
        }
        
        
        // Loop over RDA Approved Cases 
        for(case cse : [select id , US_WSREMS__Outcome__c ,US_WSREMS__Patient__c,date_of_Fill__c, SYN_Days_Supply__c  from case where recordtypeId =: CseRDARCTyId and US_WSREMS__Patient__c In: ExistingApprovedRDAStatusMap.keyset() and Id NOT In: newcaseslst and US_WSREMS__Outcome__c = 'Approved']){
            ExistingApprovedRDAStatusMap.put(cse.US_WSREMS__Patient__c, true);
            
            // Logic to find most recent RDA Approved date
            if(MostRecentApprovedRDAMap.containsKey(cse.US_WSREMS__Patient__c) && MostRecentApprovedRDAMap.get(cse.US_WSREMS__Patient__c) != null){
                Case recentDateOfFill = MostRecentApprovedRDAMap.get(cse.US_WSREMS__Patient__c).date_of_Fill__c > cse.date_of_Fill__c ? MostRecentApprovedRDAMap.get(cse.US_WSREMS__Patient__c) : cse  ;
                MostRecentApprovedRDAMap.put(cse.US_WSREMS__Patient__c,recentDateOfFill);
            }else{
                MostRecentApprovedRDAMap.put(cse.US_WSREMS__Patient__c,cse );
            }
            
        }
        for (case cse: RDACaseLst){
            
            Case mostRecentRDAapprovedCase = MostRecentApprovedRDAMap.get(cse.US_WSREMS__Patient__c);
            if ( String.isBlank(cse.US_WSREMS__Patient__c) || !participantStatusMap.get(cse.US_WSREMS__Patient__c)){
                RDArejectsStr += 'Rule1_PatientEnrolled;';
            }
            if(String.isBlank(cse.SYN_Prescriber__c ) || !participantStatusMap.get(cse.SYN_Prescriber__c )){
                RDArejectsStr += 'Rule2_PrescriberCertified;';
            }
            
            
            if(cse.SYN_Days_Supply__c >90)
            {
                RDArejectsStr += 'Rule5_DaySup90;';
            }
            
            if(cse.X2_Patient_currently_disenrolled__c == 'Yes')
            {
                RDArejectsStr += 'Rule6_PatientDisEnrolled;';
            }
            if(cse.X3_Prescriber_currently_disenrolled__c  == 'Yes')
            {
                RDArejectsStr += 'Rule7_PrescriberDisenrolled;';
            }
            // BT6825-583 : moving rejection Reason to validation rule
            // Adding Program check for the validation.
            if (!test.isRunningTest() && cse.US_WSREMS__REMS_Program__c == SoxProgramId){
                if( String.isBlank(String.valueOf(cse.SYN_Days_Supply__c)) || cse.SYN_Days_Supply__c < 1  ){
                    cse.SYN_Days_Supply__c.addError(SYN_Utilitycls.RDA_errorMsg_DaysSupply);
                } 
                if(cse.US_WSREMS__Prescription_Date__c > date.today() ){
                    cse.US_WSREMS__Prescription_Date__c.addError(SYN_Utilitycls.RDA_errorMsg_FuturePrescriptionDate);
                } 
                if(cse.date_of_Fill__c  > date.today() ){
                    cse.date_of_Fill__c.addError(SYN_Utilitycls.RDA_errorMsg_FutureDateOfFill);
                }
                if(String.isBlank(String.valueOf(cse.SYN_Quantity__c )) || cse.SYN_Quantity__c  < 1 || cse.SYN_Quantity__c  > 9999 ){
                    cse.SYN_Quantity__c.addError(SYN_Utilitycls.RDA_errorMsg_Quantity);
                }
                if(String.isBlank(String.valueOf(cse.X1_Number_of_attempts__c  )) || cse.X1_Number_of_attempts__c   < 1 || cse.X1_Number_of_attempts__c  > 99 ){
                    cse.X1_Number_of_attempts__c.addError(SYN_Utilitycls.RDA_errorMsg_NumberOfAttempts);
                }
            }
            
            // compare other program date and most recent Approved(same program) RDA to to find the Recent approved date
            if(cse.X4a_What_was_the_most_recent_fill_date__c != null && cse.X4b_Days_supply_of_last_dispance__c != null && cse.date_of_Fill__c != null){
                if (cse.X4a_What_was_the_most_recent_fill_date__c.addDays(Integer.valueOf(cse.X4b_Days_supply_of_last_dispance__c - 10)) > cse.date_of_Fill__c){
                    RDArejectsStr += 'Rule9_PatientOverlappingPrescription_pro;';
                }  
            }
            
            if(String.isBlank(cse.US_WSREMS__Patient__c) || String.isBlank(cse.SYN_Prescriber__c ) || String.isBlank(cse.US_WSREMS__Patient__c)){
                if(cse.US_WSREMS__Outcome__c != 'Reversed'){
                    cse.US_WSREMS__Outcome__c =   String.isBlank(RDArejectsStr) ? 'Approved' : 'Rejected';  
                }
                // continue;
            }
            
            
            if(String.isBlank(cse.US_WSREMS__Patient__c) || (ExistingApprovedRDAStatusMap.get(cse.US_WSREMS__Patient__c) == false || cse.X4_Received_dispense_of_oxybate_product__c =='Yes') && cse.SYN_Days_Supply__c > 30 ){
                RDArejectsStr += 'Rule3_NewPatient30DaySupply;';
            }
            if(mostRecentRDAapprovedCase == null){
                if(cse.US_WSREMS__Outcome__c != 'Reversed'){
                    cse.US_WSREMS__Outcome__c =   String.isBlank(RDArejectsStr) ? 'Approved' : 'Rejected';
                }
                //continue;
            }
            if((cse.X4a_What_was_the_most_recent_fill_date__c != null && cse.X4_Received_dispense_of_oxybate_product__c =='Yes' && cse.X4a_What_was_the_most_recent_fill_date__c.addMonths(6) < cse.date_of_Fill__c && cse.SYN_Days_Supply__c > 30)
               || ((!String.isBlank(String.valueOf(mostRecentRDAapprovedCase) )) && !String.isBlank(cse.US_WSREMS__Patient__c) && cse.SYN_Days_Supply__c > 30 && mostRecentRDAapprovedCase.date_of_Fill__c.addMonths(6) < cse.date_of_Fill__c  ))
            {
                RDArejectsStr += 'Rule4_PatientInitiateTreatment6Months;';
            }
            // 5/1/22 + (30-10) > 5/10/22
            if (! String.isBlank(string.valueOf(mostRecentRDAapprovedCase)) && ( mostRecentRDAapprovedCase.date_of_Fill__c.addDays(Integer.valueOf(mostRecentRDAapprovedCase.SYN_Days_Supply__c - 10)) > cse.date_of_Fill__c)){
                RDArejectsStr += 'Rule8_PatientOverlappingPrescription_SOX;';
            }
            
            if(cse.US_WSREMS__Outcome__c != 'Reversed'){
                cse.US_WSREMS__Outcome__c =   String.isBlank(RDArejectsStr) ? 'Approved' : 'Rejected';         
            }
            
            // BT6825-592 Capturing the Rejection reasons
            String RDA_Rejection_Reason='';
            if (! String.isBlank(RDArejectsStr)){
                
                if(RDArejectsStr.contains(';')){
                    
                    for (string RDArej : RDArejectsStr.split(';')){
                        RDA_Rejection_Reason+= RDArejRuleToMsgMap.get(RDArej)+';';
                    }
                    
                }else{
                    RDA_Rejection_Reason = RDArejRuleToMsgMap.get(RDArejectsStr)+';';
                }
                cse.RDA_Rejection_Reason__c = RDA_Rejection_Reason.removeEnd(';');
                
            }else{
                cse.RDA_Rejection_Reason__c ='';
            }         
        }
        RDArejectionReasonsStr = RDArejectsStr.removeEnd(';');
        
    }
    
    public static Integer monthsUntillToday(Date pastDate){
        return pastDate.monthsBetween(Date.valueOf(date.today().format()) );
    }
    
    public static Integer monthsBetween(Date firstDate , date SecondDate ){
        return firstDate.monthsBetween(SecondDate);
    }
    public static map<string,string> RDArejectionRuleToMsgMap(String ProgramName){
        Map<String,string> RDArejRuleToMsgMap = new Map<String,String>();
        for( RDArejectionReasons__mdt RRR_mdt : [select DeveloperName , Rejection_Message__c  from RDArejectionReasons__mdt  where Program__r.MasterLabel =: ProgramName  ]){
            RDArejRuleToMsgMap.put(RRR_mdt.DeveloperName , RRR_mdt.Rejection_Message__c );
        }
        return RDArejRuleToMsgMap;
    }
    /********************************************************************************************************************************************************
Method Name     : AffiliationsbyCase()
Parameters      : newCaseAffLst: Newly inserted enrollment case.
Description     : Creates affiliation records for the stakeholders.
return          : NA.
********************************************************************************************************************************************************** */
    public static void AffiliationsbyCase(List<case> newCaseAffLst){
        
        Map<String,US_WSREMS__Affiliation__c> uniqueIdVsAffiliationRec = New Map<String,US_WSREMS__Affiliation__c>();
        Set<Id> ParticipantsIdSet = new Set<Id>();
        Set<Id> prescriberIdSet = new Set<Id>();  
        Set<Id> PIIdSet = new Set<Id>(); 
        Set<Id> patientIdSet = new Set<Id>(); 
        Set<Id> pharmcIdSet = new Set<Id>();
        Set<Id> authRepIdSet = new Set<Id>();
        Set<String> CaseenrollmentStr = new Set<String>{'Prescriber_enrollment','Patient_Enrollement','SYN_Outpatient_Pharmacy','SYN_Inpatient_Pharmacy', 'Patient_Reenrollment', 'Prescriber_Reenrollment', 'SYN_Outpatient_Pharmacy_Reenrollment', 'SYN_Inpatient_Pharmacy_Reenrollment'};
            Set<String> affiParticipantsStr = new Set<String>{'SYN_Prescriber__c','US_WSREMS__Facility__c','Account_Name_Secondary_Office__c','US_WSREMS__Patient__c','SYN_Pharmacy__c',
                'SYN_Authorized_Rep__c'};
                    Map<Id, List<US_WSREMS__Affiliation__c>> existingAffiliationMap = new Map<Id, List<US_WSREMS__Affiliation__c>>();
        
        //Capture participant Id's here...
        for (case affCase : newCaseAffLst ){
            if(affCase.US_WSREMS__Program_Picklist__c == 'Macitentan REMS'){
                if (CaseenrollmentStr.contains( mapCaseRecordTypesById.get(affCase.recordtypeId).getDeveloperName())){
                    
                    for (String parLookup : affiParticipantsStr){
                        if (!String.isBlank((String)affCase.get(parLookup))){
                            ParticipantsIdSet.add( ID.valueof((String)affCase.get(parLookup)));
                            if(parLookup == 'SYN_Authorized_Rep__c'){
                                pharmacyUserIds.add( ID.valueof((String)affCase.get(parLookup)));
                            }
                        }
                    
                    }
                }
            }
        }
        
        
        
        for(US_WSREMS__Affiliation__c affiliatiObj : [SELECT Id, RecordTypeId, US_WSREMS__REMS_Service__c, US_WSREMS__REMSProgram__c, US_WSREMS__End_Date__c,US_WSREMS__Start_Date__c, US_WSREMS__isActive__c, US_WSREMS__Pharmacy__c, US_WSREMS__Pharmacy_User__c, US_WSREMS__UserType__c, US_WSREMS__Prescribing_Institution__c, US_WSREMS__Prescriber__c, US_WSREMS__Patient__c FROM US_WSREMS__Affiliation__c 
                                                      WHERE US_WSREMS__isActive__c = TRUE AND (
                                                          (US_WSREMS__Pharmacy__c IN: ParticipantsIdSet) OR
                                                          (US_WSREMS__Pharmacy_User__c IN: ParticipantsIdSet) OR
                                                          (US_WSREMS__Prescribing_Institution__c IN: ParticipantsIdSet) OR 
                                                          (US_WSREMS__Prescriber__c IN: ParticipantsIdSet) OR 
                                                          (US_WSREMS__Patient__c IN: ParticipantsIdSet))]){ 
                                                              // Prescriber enrollment with primary facility/PI & secondary facility/PI ......
                                                          if(affiliatiObj.US_WSREMS__Prescribing_Institution__c != null && affiliatiObj.US_WSREMS__Prescriber__c != null){
                                                                  uniqueIdVsAffiliationRec.put(affiliatiObj.US_WSREMS__Prescriber__c+'_'+affiliatiObj.US_WSREMS__Prescribing_Institution__c, affiliatiObj);
                                                                  existingAffiliationMap = existingAffiliationMap(affiliatiObj.US_WSREMS__Prescriber__c , affiliatiObj , existingAffiliationMap);
                                                              }
                                                              // Patient enrollment
                                                          if(affiliatiObj.US_WSREMS__Patient__c != null && affiliatiObj.US_WSREMS__Prescriber__c != null){
                                                                  uniqueIdVsAffiliationRec.put(affiliatiObj.US_WSREMS__Patient__c+'_'+affiliatiObj.US_WSREMS__Prescriber__c, affiliatiObj);
                                                                  existingAffiliationMap = existingAffiliationMap(affiliatiObj.US_WSREMS__Patient__c , affiliatiObj , existingAffiliationMap);
                                                                  
                                                              }
                                                              // Pharmacy enrollment
                                                          if(affiliatiObj.US_WSREMS__Pharmacy__c != null && affiliatiObj.US_WSREMS__Pharmacy_User__c != null){
                                                                  uniqueIdVsAffiliationRec.put(affiliatiObj.US_WSREMS__Pharmacy__c+'_'+affiliatiObj.US_WSREMS__Pharmacy_User__c, affiliatiObj);
                                                                  existingAffiliationMap = existingAffiliationMap(affiliatiObj.US_WSREMS__Pharmacy__c , affiliatiObj , existingAffiliationMap);
                                                                  
                                                              }
                                                          }
        
        for (case affCase : newCaseAffLst ){
            US_WSREMS__Affiliation__c affiliRecord = New US_WSREMS__Affiliation__c();
            // prescriber enroll with primary facility... && // prescriber enroll with secondary facility...
            if ( mapCaseRecordTypesById.get(affCase.recordtypeId).getDeveloperName() == 'Prescriber_enrollment' && affCase.SYN_Prescriber__c != NULL){
                //Primary facility/PI check....
                
                if(affCase.US_WSREMS__Facility__c != null && !uniqueIdVsAffiliationRec.containsKey(affCase.SYN_Prescriber__c+'_'+affCase.US_WSREMS__Facility__c) ){
                    affiliRecord = SYN_AffiliationHandler.createPrescriberAndPresInstiAffi(affCase.SYN_Prescriber__c,affCase.US_WSREMS__Facility__c,affCase.US_WSREMS__REMS_Program__c,affCase.US_WSREMS__REMS_Service_Summary__c);
                    affiliationRecsToInsert.add(affiliRecord);
                }
                
                //Secondary facility/PI check....
                if(affCase.Account_Name_Secondary_Office__c != null && affCase.Account_Name_Secondary_Office__c != affCase.US_WSREMS__Facility__c && !uniqueIdVsAffiliationRec.containsKey(affCase.SYN_Prescriber__c+'_'+affCase.Account_Name_Secondary_Office__c) ){
                    US_WSREMS__Affiliation__c affiliRecord2 = New US_WSREMS__Affiliation__c();
                    affiliRecord2 = SYN_AffiliationHandler.createPrescriberAndPresInstiAffi(affCase.SYN_Prescriber__c,affCase.Account_Name_Secondary_Office__c,affCase.US_WSREMS__REMS_Program__c,affCase.US_WSREMS__REMS_Service_Summary__c);
                    affiliationRecsToInsert.add(affiliRecord2);
                }
                
            }// Presc Enroll complete...
            //Patient Enroll affil....
            if ( mapCaseRecordTypesById.get(affCase.recordtypeId).getDeveloperName() == 'Patient_Enrollement' && 
                affCase.US_WSREMS__Patient__c != NULL && affCase.SYN_Prescriber__c != NULL){
                    if(!uniqueIdVsAffiliationRec.containsKey(affCase.US_WSREMS__Patient__c+'_'+affCase.SYN_Prescriber__c) ){
                        affiliRecord = SYN_AffiliationHandler.createPatientAndPresAffil(affCase.US_WSREMS__Patient__c,affCase.SYN_Prescriber__c,affCase.US_WSREMS__REMS_Program__c,affCase.US_WSREMS__REMS_Service_Summary__c);
                        affiliationRecsToInsert.add(affiliRecord);
                    }
                } //Patient enroll affili end...
            //Pharmac enroll affiliation....
            if ((mapCaseRecordTypesById.get(affCase.recordtypeId).getDeveloperName() == 'SYN_Outpatient_Pharmacy' || mapCaseRecordTypesById.get(affCase.recordtypeId).getDeveloperName() == 'SYN_Inpatient_Pharmacy')  && affCase.SYN_Pharmacy__c != NULL && affCase.SYN_Authorized_Rep__c != NULL){
                if(!uniqueIdVsAffiliationRec.containsKey(affCase.SYN_Pharmacy__c+'_'+affCase.SYN_Authorized_Rep__c) ){
                    affiliRecord = SYN_AffiliationHandler.createPharmacyAndPharmacyParti(affCase.SYN_Pharmacy__c,affCase.SYN_Authorized_Rep__c,affCase.US_WSREMS__REMS_Program__c,affCase.US_WSREMS__REMS_Service_Summary__c);
                    if(affCase.US_WSREMS__Program_Picklist__c == 'Macitentan REMS'){
                        affiliRecord.AR_Category__c = 'Primary';
                        affiliRecord.US_WSREMS__UserType__c = 'Authorized Representative';
                        affiliRecord.Status__c = 'Active';
          affiliRecord.Default__c= true;
                    }
                    affiliationRecsToInsert.add(affiliRecord);
                    
                }
            } //Pharmac enroll affiliation....
            
            if (mapCaseRecordTypesById.get(affCase.recordtypeId).getDeveloperName() == 'Patient_Reenrollment' &&
                affCase.US_WSREMS__Patient__c != NULL && affCase.SYN_Prescriber__c != NULL)
            {
                affiliRecord = SYN_AffiliationHandler.createPatientAndPresAffil(affCase.US_WSREMS__Patient__c,affCase.SYN_Prescriber__c,affCase.US_WSREMS__REMS_Program__c,affCase.US_WSREMS__REMS_Service_Summary__c);
                endAffiliation(affCase.US_WSREMS__Patient__c,affiliRecord.recordTypeId, existingAffiliationMap , 'Patient_Reenrollment');
                if(!uniqueIdVsAffiliationRec.containsKey(affCase.US_WSREMS__Patient__c+'_'+affCase.SYN_Prescriber__c)) {
                    affiliationRecsToInsert.add(affiliRecord);
                } else if (uniqueIdVsAffiliationRec.containsKey(affCase.US_WSREMS__Patient__c+'_'+affCase.SYN_Prescriber__c)){
                    reEnrollAffiliation(affiliRecord , uniqueIdVsAffiliationRec.get(affCase.US_WSREMS__Patient__c+'_'+affCase.SYN_Prescriber__c));
                }
            }
            
            if ( mapCaseRecordTypesById.get(affCase.recordtypeId).getDeveloperName() == 'Prescriber_Reenrollment' && affCase.SYN_Prescriber__c != NULL )
            {
                //Primary facility/PI check....
                if(affCase.US_WSREMS__Facility__c != null ){
                    affiliRecord = SYN_AffiliationHandler.createPrescriberAndPresInstiAffi(affCase.SYN_Prescriber__c,affCase.US_WSREMS__Facility__c,affCase.US_WSREMS__REMS_Program__c,affCase.US_WSREMS__REMS_Service_Summary__c);
                    endAffiliation(affCase.SYN_Prescriber__c,affiliRecord.recordTypeId, existingAffiliationMap ,'Prescriber_Reenrollment PI 1');
                    
                    if (!uniqueIdVsAffiliationRec.containsKey(affCase.SYN_Prescriber__c+'_'+affCase.US_WSREMS__Facility__c)){
                        affiliationRecsToInsert.add(affiliRecord);
                    }else if (uniqueIdVsAffiliationRec.containsKey(affCase.SYN_Prescriber__c+'_'+affCase.US_WSREMS__Facility__c)){
                        reEnrollAffiliation(affiliRecord , uniqueIdVsAffiliationRec.get(affCase.SYN_Prescriber__c+'_'+affCase.US_WSREMS__Facility__c));
                    }
                }
                
                //Secondary facility/PI check....
                if(affCase.Account_Name_Secondary_Office__c != null && affCase.Account_Name_Secondary_Office__c != affCase.US_WSREMS__Facility__c ){
                    US_WSREMS__Affiliation__c affiliRecord2 = New US_WSREMS__Affiliation__c();
                    affiliRecord2 = SYN_AffiliationHandler.createPrescriberAndPresInstiAffi(affCase.SYN_Prescriber__c,affCase.Account_Name_Secondary_Office__c,affCase.US_WSREMS__REMS_Program__c,affCase.US_WSREMS__REMS_Service_Summary__c);
                    
                    if (!uniqueIdVsAffiliationRec.containsKey(affCase.SYN_Prescriber__c+'_'+affCase.Account_Name_Secondary_Office__c)){
                        affiliationRecsToInsert.add(affiliRecord2);
                    } else if (uniqueIdVsAffiliationRec.containsKey(affCase.SYN_Prescriber__c+'_'+affCase.Account_Name_Secondary_Office__c)){
                        reEnrollAffiliation(affiliRecord2 , uniqueIdVsAffiliationRec.get(affCase.SYN_Prescriber__c+'_'+affCase.Account_Name_Secondary_Office__c));
                    }
                    
                }
                
            }
            
            if ((mapCaseRecordTypesById.get(affCase.recordtypeId).getDeveloperName() == 'SYN_Outpatient_Pharmacy_Reenrollment' || mapCaseRecordTypesById.get(affCase.recordtypeId).getDeveloperName() == 'SYN_Inpatient_Pharmacy_Reenrollment') &&
                affCase.SYN_Pharmacy__c != NULL && affCase.SYN_Authorized_Rep__c != NULL)
            {
                affiliRecord = SYN_AffiliationHandler.createPharmacyAndPharmacyParti(affCase.SYN_Pharmacy__c,affCase.SYN_Authorized_Rep__c,affCase.US_WSREMS__REMS_Program__c,affCase.US_WSREMS__REMS_Service_Summary__c);
                if(affCase.US_WSREMS__Program_Picklist__c == 'Macitentan REMS'){
                    affiliRecord.AR_Category__c = 'Primary';
                    affiliRecord.US_WSREMS__UserType__c = 'Authorized Representative';
                    affiliRecord.Status__c = 'Active';
          affiliRecord.Default__c= true;
                }
                endAffiliation(affCase.SYN_Pharmacy__c,affiliRecord.recordTypeId, existingAffiliationMap, 'Pharmacy_Reenrollment');
                
                if(!uniqueIdVsAffiliationRec.containsKey(affCase.SYN_Pharmacy__c+'_'+affCase.SYN_Authorized_Rep__c) ){
                    affiliationRecsToInsert.add(affiliRecord);
                }else if (uniqueIdVsAffiliationRec.containsKey(affCase.SYN_Pharmacy__c+'_'+affCase.SYN_Authorized_Rep__c)){
                    reEnrollAffiliation(affiliRecord , uniqueIdVsAffiliationRec.get(affCase.SYN_Pharmacy__c+'_'+affCase.SYN_Authorized_Rep__c));
                }
            }
            
        }
        
        if(!affiliationRecsToInsert.isEmpty()){
            try{
                upsert affiliationRecsToInsert;
            }catch (exception e){
                system.debug('----Error-insert Affiliation REcs-----'+e.getMessage());
            }
        }        
    }
    
    //Method to end existing affiliation record 
    public static void endAffiliation(Id keyId, String recordTypeId , Map<Id, List<US_WSREMS__Affiliation__c>> existingAffiliationMap , string MethodName){
        
        if(existingAffiliationMap.containsKey(keyId)){
            
            for(US_WSREMS__Affiliation__c existAffili: existingAffiliationMap.get(keyId)){
                if((existAffili.recordTypeId == recordTypeId && MethodName != 'Pharmacy_Reenrollment') || (existAffili.recordTypeId == recordTypeId  && MethodName == 'Pharmacy_Reenrollment' && pharmacyUserIds.contains(existAffili.US_WSREMS__Pharmacy_User__c)) ){
                    existAffili.US_WSREMS__End_Date__c = System.Today();
                    existAffili.US_WSREMS__isActive__c = FALSE;
                    affiliationRecsToInsert.add(existAffili);
                }
            }
        }
    }
    
    public static void reEnrollAffiliation(US_WSREMS__Affiliation__c newAff ,  US_WSREMS__Affiliation__c oldAffObj ){
        newAff.US_WSREMS__Start_Date__c = oldAffObj.US_WSREMS__Start_Date__c;        
        affiliationRecsToInsert.add(newAff);
        
    }
    
    Public Static Map<Id, List<US_WSREMS__Affiliation__c>> existingAffiliationMap (Id ParticipantId, US_WSREMS__Affiliation__c affiliatiObj,   Map<Id, List<US_WSREMS__Affiliation__c>> extAffMap){
        
        if (extAffMap.containskey(ParticipantId)){
            extAffMap.get(ParticipantId).add(affiliatiObj);
        } else {
            extAffMap.put(ParticipantId, new List<US_WSREMS__Affiliation__c>{affiliatiObj});
        }
        return extAffMap;
        
    }
    
    /******************************************
Method Name : updatePortalAccountStatus
Description : update Account status to certified for Portal Accounts
*******************************************************/ 
    public static void updatePortalAccountStatus(set<Id> accountIds){
        Id PatientAccountRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
        List<Account> acclist = new List<Account>();
        for(Account acc : [SELECT Id,US_WSREMS__Status__c,recordTypeId,SYN_Signature__c,SYN_Signature_Date__c,Date_Enrolled__c FROM Account WHERE Id =: accountIds]){
            if(acc.recordTypeId  == PatientAccountRecTypeId ){
                acc.US_WSREMS__Status__c = 'Enrolled';
                acc.SYN_Signature__c = 'Yes';
                acc.SYN_Signature_Date__c = System.today();
                acc.Date_Enrolled__c = System.today();
                acclist.add(acc);
            }else if(acc.US_WSREMS__Status__c != 'Certified'){
                acc.US_WSREMS__Status__c = 'Certified';
                acclist.add(acc);
            }
        }
        
        if(!acclist.isEmpty()){
            try{
                update acclist;
            }catch(exception e){
                system.debug('---Error---'+e.getMessage());
            }
        }
        
    }
    
    /******************************************
Method Name : updatePortalREMSServiceStatus
Description : update Remservice status to closed for Portal services
*******************************************************/ 
    public static void updatePortalREMSServiceStatus(set<Id> preseriberRemsServiceIds){
        List<US_WSREMS__REMS_Service_Summary__c> remsServicelist = new List<US_WSREMS__REMS_Service_Summary__c>();
        for(US_WSREMS__REMS_Service_Summary__c rms : [SELECT Id,US_WSREMS__Status__c,US_WSREMS__Service_Outcome__c,US_WSREMS__Path_Stage_Name__c,US_WSREMS__StageName__c FROM US_WSREMS__REMS_Service_Summary__c WHERE Id = : preseriberRemsServiceIds]){
            if(rms.US_WSREMS__Status__c != 'Closed'){    
                rms.US_WSREMS__Status__c = 'Closed';
                rms.US_WSREMS__Service_Outcome__c= 'Successful';
                //rms.US_WSREMS__StageName__c= 'Closed';
                rms.US_WSREMS__Path_Stage_Name__c = 'Closed'; 
                remsServicelist.add(rms);
            }
        }
        if(!remsServicelist.isEmpty()){
            try{
                update remsServicelist;
            }catch(exception e){
                system.debug('---Error---'+e.getMessage());
            }
        }
        
    }
    /*
* method name : createChecklist
* author : Priya
* description : This method is used to create checklist for the REMS service summary based on case.
*/
    public static void createChecklist(List<Case> lstCaseToCreateChecklist){
        List<Task> lstTaskToCreate = new List<Task>();
        Map<String,Id> CaseRT = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        Map<Id, List<Onboarding_Checklist__mdt>> mapRecordtypeToChecklist = new Map<Id, List<Onboarding_Checklist__mdt>>();
        for(Onboarding_Checklist__mdt objMetadata : [SELECT Case_RecordType_Developer_Name__c, Subject__c,TaskType__c FROM Onboarding_Checklist__mdt WHERE Case_RecordType_Developer_Name__c != NULL AND Subject__c != NULL AND TaskType__c != 'Follow-up']){
            if(CaseRT.containsKey(objMetadata.Case_RecordType_Developer_Name__c)){
                Id recordTypeId = CaseRT.get(objMetadata.Case_RecordType_Developer_Name__c);
                if(mapRecordtypeToChecklist.containsKey(recordTypeId)){
                    mapRecordtypeToChecklist.get(recordTypeId).add(objMetadata);
                }else{
                    mapRecordtypeToChecklist.put(recordTypeId, new List<Onboarding_Checklist__mdt>{objMetadata});
                }
            }
        }
        for(Case objCase : lstCaseToCreateChecklist){
            if(mapRecordtypeToChecklist.containsKey(objCase.RecordTypeId)){
                for(Onboarding_Checklist__mdt objMetadata : mapRecordtypeToChecklist.get(objCase.RecordTypeId)){
                    Task objTask = new Task();
                    objTask.Subject = objMetadata.Subject__c;
                    objTask.whatId = objCase.US_WSREMS__REMS_Service_Summary__c;
                    objTask.OwnerId = objCase.OwnerId;
                    objTask.Status = 'Not Started';
                    objTask.Priority = 'Normal';
                    objTask.ActivityDate = System.today();
                    lstTaskToCreate.add(objTask);
                }
            }
        }
        
        if(!lstTaskToCreate.isEmpty()){
            insert lstTaskToCreate;
        }
        
    }
       
    /*
* method name : MACIAutomationCommunicationFromCase 
* author : Wilco
* description : This method is used to collect case data and send to the sendnoticiation method that trigger emails.
*/
    public static void MACIAutomationCommunicationFromCase(List<Case> caseList){
        
        Id changeInReproPotentialStatusCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');
        Id PatientEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');
        Id PrescriberEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        Id outpatientPharmacyEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Outpatient_Pharmacy');
        Id inpatientPharmacyEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Inpatient_Pharmacy');
        Id distributorEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Distributor_Enrollment');
        
        List<Case> finalCaseList = New List<Case>();
        List<Case> sendTaskList = New List<Case>();
        List<Task> Createtask = new List<Task>();
        List<Case> finalCaseListToSendFax = New List<Case>();
        Map<String, Schema.RecordTypeInfo>  Casetask = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        Map<Id, List<Onboarding_Checklist__mdt>> mapRecordtype = new Map<Id, List<Onboarding_Checklist__mdt>>();
        for(Case cs:[SELECT Id,recordTypeId,RecordType.DeveloperName,Status,US_WSREMS__Outcome__c,ownerId,US_WSREMS__Program_Name__c,US_WSREMS__Program_Picklist__c,
                     SYN_Authorized_Rep__c,SYN_Authorized_Rep__r.US_WSREMS__Email__c,SYN_Authorized_Rep__r.US_WSREMS__Status__c,SYN_Pharmacy__c,SYN_Pharmacy__r.US_WSREMS__Status__c,
                     SYN_Prescriber__c,SYN_Prescriber__r.Email_address__c,SYN_Prescriber__r.US_WSREMS__Status__c,US_WSREMS__Distributor__c,
                     US_WSREMS__Distributor__r.US_WSREMS__Email__c,US_WSREMS__Distributor__r.US_WSREMS__Status__c,Pharmacy_Participant__c,Pharmacy_Participant__r.US_WSREMS__Email__c,US_WSREMS__Patient__c,
                     US_WSREMS__Patient__r.US_WSREMS__Status__c,US_WSREMS__REMS_Service_Summary__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c,
                     US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Participant__r.US_WSREMS__Status__c,Email_address__c,SYN_Prescriber_First_Name__c,US_WSREMS__Fax__c,
                     SYN_Prescriber_Last_Name__c,Incomplete_Reason__c,Incomplete_Reasons__c,Participant_REMS_ID_Num__c,Patient_Name_Initials__c,US_WSREMS__Patient_DOB__c,SYN_Prescriber__r.PersonContactId,
                     US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c,US_WSREMS__Channel__c , US_WSREMS__REMS_Program__c,US_WSREMS__Participant__r.PersonContactId,US_WSREMS__Email__c,SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c,SYN_Prescriber__r.Fax,US_WSREMS__Preferred_Contact_Method__c,Prescriber_fax_Number__c,Notifications__c FROM Case WHERE Id IN: Trigger.New AND US_WSREMS__Program_Name__c =: 'Macitentan REMS']){
                         
                         
                         if(cs.RecordTypeId == changeInReproPotentialStatusCaseRecTypeId && cs.SYN_Prescriber__c != NULL && cs.US_WSREMS__Email__c != NULL && cs.Status == 'Draft' && cs.Incomplete_Reasons__c != NULL && cs.US_WSREMS__Channel__c != 'Migration' && cs.US_WSREMS__Channel__c != 'Portal'){
                             String result =MACIAutomationCommunicationUtility.checkEmailOrFax(cs.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c, cs.SYN_Prescriber__r.Fax, cs.SYN_Prescriber__r.Email_address__c, cs.US_WSREMS__Channel__c);
                             if(result == 'SendEmail'){    
                                 finalCaseList.add(cs);   
                             }else if(result == 'SendFax'){   
                                 finalCaseListToSendFax.add(cs);
                             }
                         }
                         if((cs.RecordTypeId == PrescriberEnrollmentCaseRecTypeId && cs.SYN_Prescriber__r.US_WSREMS__Status__c == 'Pending') && cs.SYN_Prescriber__c != NULL && cs.Status == 'Draft' && cs.Incomplete_Reasons__c != NULL && cs.US_WSREMS__Channel__c != 'Migration' && cs.US_WSREMS__Channel__c != 'Portal'){
                             String result =MACIAutomationCommunicationUtility.checkEmailOrFax(cs.US_WSREMS__Preferred_Contact_Method__c,cs.US_WSREMS__Fax__c,cs.US_WSREMS__Email__c,cs.US_WSREMS__Channel__c);
                             if(result == 'SendEmail'){    
                                 finalCaseList.add(cs);
                             }
                             else if(result == 'SendFax'){   
                                 finalCaseListToSendFax.add(cs);
                             }
                             else if(result == ''){   
                                sendTaskList.add(cs);
                            }
                             
                         }
                         if(((cs.RecordTypeId == outpatientPharmacyEnrollCaseRecTypeId || cs.RecordTypeId == inpatientPharmacyEnrollCaseRecTypeId) && cs.SYN_Authorized_Rep__c != NULL && cs.US_WSREMS__Email__c != NULL && cs.SYN_Pharmacy__c != NULL && cs.SYN_Pharmacy__r.US_WSREMS__Status__c == 'Pending') && cs.US_WSREMS__Email__c != NULL && cs.Status == 'Draft' && cs.Incomplete_Reasons__c != NULL && cs.US_WSREMS__Channel__c != 'Migration' && cs.US_WSREMS__Channel__c != 'Portal'){
                              
                                 finalCaseList.add(cs);
                           
                         }
                         if((cs.RecordTypeId == distributorEnrollCaseRecTypeId && cs.US_WSREMS__Distributor__c != NULL && cs.US_WSREMS__Email__c != NULL && cs.US_WSREMS__Distributor__r.US_WSREMS__Status__c == 'Pending') && cs.US_WSREMS__Email__c != NULL && cs.Status == 'Draft' && cs.Incomplete_Reasons__c != NULL && cs.US_WSREMS__Channel__c != 'Migration' && cs.US_WSREMS__Channel__c != 'Portal'){
                                
                                 finalCaseList.add(cs);
                            
                         }
                         
                         
                         //patient condition added here as it needs to trigger for both back office and portal....
                         if(cs.RecordTypeId == PatientEnrollmentCaseRecTypeId && cs.US_WSREMS__Patient__c != NULL && cs.US_WSREMS__Patient__r.US_WSREMS__Status__c == 'Pending' && cs.Status == 'Draft' && cs.Incomplete_Reasons__c != NULL && cs.US_WSREMS__Channel__c != 'Migration')
                         {
                          if( cs.SYN_Prescriber__c != NULL){
                             String result =MACIAutomationCommunicationUtility.checkEmailOrFax(cs.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c, cs.SYN_Prescriber__r.Fax, cs.SYN_Prescriber__r.Email_address__c, cs.US_WSREMS__Channel__c);
                             if(result == 'SendEmail' ){    
                                 finalCaseList.add(cs);
                             }else if(result == 'SendFax'){               
                                finalCaseListToSendFax.add(cs);
                             }else if(result == ''){   
                                sendTaskList.add(cs);
                             }
                            }
                             else{   
                                sendTaskList.add(cs);
                             }
                         }
                         
                         
                     }
        if(!finalCaseListToSendFax.isEmpty()){
             MACIAutomationCommunicationUtility.sendFaxNotification(finalCaseListToSendFax);
             createREMSTask(finalCaseListToSendFax);
        }
        if(!finalCaseList.isEmpty()){
            MACIAutomationCommunicationUtility.sendNotification(finalCaseList);
            createREMSTask(finalCaseList); 
                    }
        if(!sendTaskList.isEmpty()){ 
            createREMSTask(sendTaskList);
            
                }
                
    }
    /*
* method name : reverseRDAValidationOnService 
* author : Wilco
* description : This method is used to collect reverse RDA case data before insert, to check if the existing RDA has shipping and tracking records
*               If yes, an error will be show and user cannot process to reverse the RDA.
*/
    public static void reverseRDAValidationOnService(List<Case> caseList){
        Id revrdaCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Reverse_RDA');
        Id rdaCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'PDA');
        Map<Id,String> programMap = new Map<Id,String>();
        Map<Id,Case> caseRecMap = New Map<Id,Case>();
        Map<Id,Case> revrdacaseRecMap = New Map<Id,Case>();
        Map<Id,US_WSREMS__Shipping_and_Tracking__c> shippingRecMap = New Map<Id,US_WSREMS__Shipping_and_Tracking__c>();
        List<Case> rdaCasesList = New List<Case>();
        List<US_WSREMS__Shipping_and_Tracking__c> shippingRecords = New List<US_WSREMS__Shipping_and_Tracking__c>();
        
        programMap = SYN_CommonUtility.getActivePrograms();
        //This method is  related to Maci Program only
        for(case cs:caseList){
            if(cs.RecordTypeId == revrdaCaseRecTypeId && programMap.containsKey(cs.US_WSREMS__REMS_Program__c) && programMap.get(cs.US_WSREMS__REMS_Program__c) == 'Macitentan REMS'){
                if(cs.US_WSREMS__REMS_Service_Summary__c != NULL){
                    revrdacaseRecMap.put(cs.US_WSREMS__REMS_Service_Summary__c,cs);
                }
            }
        }
        
         if(!revrdacaseRecMap.isEmpty()){
              rdaCasesList = [SELECT Id,US_WSREMS__REMS_Service_Summary__c,RecordTypeId,US_WSREMS__Outcome__c,Status,US_WSREMS__Program_Picklist__c FROM CASE WHERE US_WSREMS__REMS_Service_Summary__c != null AND US_WSREMS__REMS_Service_Summary__c IN:revrdacaseRecMap.keyset() AND RecordTypeId =: rdaCaseRecTypeId];
        }
        
        if(!rdaCasesList.isEmpty()){
            for(Case cs: rdaCasesList){
                if(cs.RecordTypeId == rdaCaseRecTypeId && cs.US_WSREMS__Outcome__c == 'Approved' && cs.Status == 'Complete'
                   && cs.US_WSREMS__Program_Picklist__c == 'Macitentan REMS'){
                       caseRecMap.put(cs.US_WSREMS__REMS_Service_Summary__c,cs);
                   }
            } 
        }
        //
        
        if(!caseRecMap.isEmpty() && caseRecMap != NULL){
            shippingRecords = [SELECT Id,US_WSREMS__Case__c, US_WSREMS__Case__r.US_WSREMS__REMS_Service_Summary__c  FROM US_WSREMS__Shipping_and_Tracking__c WHERE RDA_Code__c !=null AND US_WSREMS__Status__c ='Accepted' AND US_WSREMS__Case__c != NULL AND US_WSREMS__Case__r.US_WSREMS__REMS_Service_Summary__c IN: caseRecMap.keyset()];
        }
        
        if(!shippingRecords.isEmpty() && shippingRecords != null){
            for(US_WSREMS__Shipping_and_Tracking__c s:shippingRecords){
                shippingRecMap.put(s.US_WSREMS__Case__r.US_WSREMS__REMS_Service_Summary__c,s);
            }
        }
        
        if(shippingRecMap != null){
            for(case cs:revrdacaseRecMap.Values()){ // reverse rda case...
                if(shippingRecMap.containsKey(cs.US_WSREMS__REMS_Service_Summary__c)){
                    cs.addError('RDA cannot be reversed after the product has been shipped.');
                }
            }
        }
        
    }
    
    /******************************************
Method Name : MACIChangeAuthRep
Description : Deactivate exsiting Affilition and creates new affiliations
*******************************************************/ 
    public static void MACIChangeAuthRep(Map<Id,String> mapPharmaParToARcat , Map<Id,Id> mapPharmacyToParticipant, Map<String, Case> mapPharmaParToCase){
        if (mapPharmaParToARcat.keyset().Isempty() || mapPharmacyToParticipant.keyset().Isempty()){
            return;
        }
        List<US_WSREMS__Affiliation__c> activeAndInactiveAff = new List<US_WSREMS__Affiliation__c>();
        
        for (US_WSREMS__Affiliation__c oldAff : [SELECT  Id,AR_Category__c, US_WSREMS__Pharmacy__c  FROM US_WSREMS__Affiliation__c WHERE RecordType.DeveloperName ='Pharmacy_User_Affiliation' and US_WSREMS__Pharmacy__c=:mapPharmacyToParticipant.keyset() and US_WSREMS__isActive__c = true and US_WSREMS__UserType__c ='Authorized Representative' and (AR_Category__c ='Primary' or AR_Category__c ='Secondary')  ]){
            if (mapPharmacyToParticipant.containskey(oldAff.US_WSREMS__Pharmacy__c) && mapPharmaParToARcat.get(mapPharmacyToParticipant.get(oldAff.US_WSREMS__Pharmacy__c)) == oldAff.AR_Category__c){
                oldAff.Status__c = 'Inactive';
                oldAff.US_WSREMS__End_Date__c = system.today();
                activeAndInactiveAff.add(oldAff);
            }
        }
        
        for (Id pharmacyId : mapPharmacyToParticipant.keyset() ){
            Id programId = mapPharmaParToCase.get(pharmacyId+'-'+mapPharmacyToParticipant.get(pharmacyId)).US_WSREMS__REMS_Program__c;
            Id ServiceId = mapPharmaParToCase.get(pharmacyId+'-'+mapPharmacyToParticipant.get(pharmacyId)).US_WSREMS__REMS_Service_Summary__c;
            US_WSREMS__Affiliation__c newAff = SYN_AffiliationHandler.createPharmacyAndPharmacyParti(pharmacyId, mapPharmacyToParticipant.get(pharmacyId), programId, ServiceId);
            String AR_category = mapPharmaParToARcat.get(mapPharmacyToParticipant.get(pharmacyId));
            newAff.AR_Category__c = AR_category;
            newAff.Status__c = 'Active';
            newAff.Default__c= true;
            newAff.US_WSREMS__isActive__c = true;
            newAff.US_WSREMS__Start_Date__c = system.today();
            newAff.US_WSREMS__UserType__c = 'Authorized Representative'; //AR_category == 'Primary' ? 'Authorized Representative' : 'Pharmacy Staff';
            activeAndInactiveAff.add(newAff);
            
        }
        
        if(!activeAndInactiveAff.isEmpty()){
            try{
                upsert activeAndInactiveAff;
                updatePharmacyParticipantAccountStatusToActive(mapPharmaParToARcat.keySet());
            }catch (exception e){
                system.debug('----Error- Change Auth rep Affiliatios -----'+e.getMessage());
            }
        }   
    }
    
    /******************************************
Method Name : updatePortalAccountStatusToDisenrolled
Description : update Account status to Disenrolled for patient Accounts
*******************************************************/ 
    public static void updatePharmacyParticipantAccountStatusToActive(set<Id> accountIds){
        List<Account> acclist = new List<Account>();
        List<Account>  inactiveAccountList = [SELECT Id,US_WSREMS__Status__c,recordTypeId,SYN_User_Type__c FROM Account WHERE Id =: accountIds AND Program_Name__c = 'Macitentan REMS' AND US_WSREMS__Status__c != 'Active'];
        if(!inactiveAccountList.isEmpty()){
            for(Account acc : inactiveAccountList){
                acc.US_WSREMS__Status__c = 'Active';
                if(String.isBlank(acc.SYN_User_Type__c)){
                    acc.SYN_User_Type__c = 'Authorized Representative';
                }
                acclist.add(acc);
            }
        }
        
        if(!acclist.isEmpty()){
            try{
                update acclist;
            }catch(exception e){
                system.debug('---Error---'+e.getMessage());
            }
        }
        
    }
    
    /******************************************
Method Name : updatePortalAccountStatusToDisenrolled
Description : update Account status to Disenrolled for patient Accounts
*******************************************************/ 
    public static void updatePortalAccountStatusToDisenrolled(set<Id> accountIds){
        List<Account> acclist = new List<Account>();
        for(Account acc : [SELECT Id,US_WSREMS__Status__c,recordTypeId,SYN_Signature__c,SYN_Signature_Date__c,Date_Enrolled__c FROM Account WHERE Id =: accountIds]){
            acc.US_WSREMS__Status__c = 'Disenrolled';
            acclist.add(acc);
        }
        if(!acclist.isEmpty()){
            try{
                update acclist;
            }catch(exception e){
                system.debug('---Error---'+e.getMessage());
            }
        }
        
    }
    
    public static Date getNextBusinessDate(DateTime currentDate, String businessHoursName) {
        
        Datetime endTimeOfCreateddatePlusMins;
        
        BusinessHours businessHourRecord = SYN_CommonUtility.getBusinessDaysAndTime(businessHoursName);
        Map<String, Time> endHours = new Map<String, Time>();
        endHours.put('Sun', businessHourRecord.SundayEndTime);
        endHours.put('Mon', businessHourRecord.MondayEndTime);
        endHours.put('Tue', businessHourRecord.TuesdayEndTime);
        endHours.put('Wed', businessHourRecord.WednesdayEndTime);
        endHours.put('Thu', businessHourRecord.ThursdayEndTime);
        endHours.put('Fri', businessHourRecord.FridayEndTime);
        endHours.put('Sat', businessHourRecord.SaturdayEndTime); 
        
        if(BusinessHours.isWithin(businessHourRecord.Id, currentDate)){
            Time endTimeOfADay = endHours.get(currentDate.format('EEE'));       //getting the End business hours of that particular day
            Datetime endTimeOfCreatedDateBusinessHrs = DateTime.newInstance(currentDate.date(), endTimeOfADay);  // constructing the created business day with end time 
            endTimeOfCreateddatePlusMins = endTimeOfCreatedDateBusinessHrs.addMinutes(5);  //adding 5mins to make after business hours to get the next business day
            
        }else{
            
            endTimeOfCreateddatePlusMins = currentDate;
        }           
        
        Datetime nextBusinessdayStartDate = BusinessHours.nextStartDate(businessHourRecord.Id, endTimeOfCreateddatePlusMins);  //getting the nextbusiness day
        Date dueDate = nextBusinessdayStartDate.date(); // Change the datetime format to date format
        
        return dueDate;
        
    }
    
    public static void patientPregnancyRDACase(List<case> patientPregnancyRDAList){
        Id programId= SYN_CommonUtility.MACIprogramId();
        List<case> patientRDACaseList = new List<Case>();
        Map<String,String> serviceMap = new Map<String,String>();
        List<US_WSREMS__REMS_Service_Summary__c> patientRDAServiceList = new List<US_WSREMS__REMS_Service_Summary__c>();
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        Map<String,Id> serviceRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c');
        Id remsServiceRecordTypeId = serviceRecordTypeMap.get('Patient_Pregnancy_Test');
        Id casePregnancyRecordTypeId = caseRecordTypeMap.get('Patient_Pregnancy_Test');
        Case newCase;
        
        
        for (case cse : patientPregnancyRDAList){
            US_WSREMS__REMS_Service_Summary__c remsService = new US_WSREMS__REMS_Service_Summary__c(recordTypeId = remsServiceRecordTypeId,Patient__c=cse.US_WSREMS__Patient__c,
                                                                                                US_WSREMS__Is_Portal__c = true,US_WSREMS__Participant__c = cse.US_WSREMS__Pharmacy__c,
                                                                                                    US_WSREMS__Path_Stage_Name__c = 'Closed',US_WSREMS__Registration_Status__c ='Pending',
                                                                                                    US_WSREMS__REMSProgram__c = programId,US_WSREMS__Requestor_Type__c='Pharmacy',
                                                                                                    US_WSREMS__StageName__c='Closed',US_WSREMS__Status__c='Closed',
                                                                                                US_WSREMS__Path_Complete__c=true,US_WSREMS__Service_Outcome__c='Successful');
            patientRDAServiceList.add(remsService);
        }
        
        if(!patientRDAServiceList.isEmpty()){
            try{
                insert patientRDAServiceList;
            }catch(exception e){
                system.debug('---patientPregnancyRDAServiceError---'+e.getMessage());
            }
        }   
        
        if (!patientRDAServiceList.isEmpty()){
            for (US_WSREMS__REMS_Service_Summary__c remsService : patientRDAServiceList){
                serviceMap.put(remsService.Patient__c,remsService.Id);
            }
        }
        
        for (case cse : patientPregnancyRDAList){
               if(serviceMap.get(cse.US_WSREMS__Patient__c) != null){
                
                newCase= New Case(RecordTypeId = casePregnancyRecordTypeId, SYN_Pharmacy__c =cse.US_WSREMS__Pharmacy__c, US_WSREMS__Program_Picklist__c =cse.US_WSREMS__Program_Picklist__c,US_WSREMS__Channel__c=cse.US_WSREMS__Channel__c,
                                            US_WSREMS__REMS_Program__c = programId,US_WSREMS__Patient__c=cse.US_WSREMS__Patient__c,Monthly_Pregnancy_Test_Recorded__c =true,SYN_Prescriber__c=cse.SYN_Prescriber__c,
                                  US_WSREMS__REMS_Service_Summary__c = serviceMap.get(cse.US_WSREMS__Patient__c),Date_of_Confirmation__c=System.today(),US_WSREMS__Outcome__c='Complete',Status='Complete',SYN_Patient_REMS_ID_Number__c=cse.SYN_Patient_REMS_ID_Number__c,US_WSREMS__First_Name__c=cse.US_WSREMS__First_Name__c,
                                  US_WSREMS__Last_Name__c=cse.US_WSREMS__Last_Name__c,US_WSREMS__Patient_Risk_Category__c = cse.US_WSREMS__Patient_Risk_Category__c,US_WSREMS__Participant__c=cse.US_WSREMS__Patient__c,Pharmacy_Participant__c=cse.Pharmacy_Participant__c);
                patientRDACaseList.add(newCase);
            } 
        }       
        
        if(!patientRDACaseList.isEmpty()){
            try{
                insert patientRDACaseList;
            }catch(exception e){
                system.debug('---patientPregnancyRDACaseError---'+e.getMessage());
            }
        }
    }
    
    
    public static void patientCounsellingRDACase(List<case> patientCounsellingRDAList){
        Id programId= SYN_CommonUtility.MACIprogramId();
        List<case> counsellingRDACaseList = new List<Case>();
        Map<String,String> serviceMap = new Map<String,String>();
        List<US_WSREMS__REMS_Service_Summary__c> counsellingRDAServiceList = new List<US_WSREMS__REMS_Service_Summary__c>();
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        Map<String,Id> serviceRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c');

        Id remsServiceRecordTypeId = serviceRecordTypeMap.get('Patient_Counseling_Checklist');
        Id caseCounselingRecordTypeId = caseRecordTypeMap.get('Patient_Counseling_Checklist');
        Case newCase;
        
        for (case cse : patientCounsellingRDAList){
            US_WSREMS__REMS_Service_Summary__c remsService = new US_WSREMS__REMS_Service_Summary__c(recordTypeId = remsServiceRecordTypeId,Patient__c=cse.US_WSREMS__Patient__c,
                                                                                                US_WSREMS__Is_Portal__c = true,US_WSREMS__Participant__c = cse.US_WSREMS__Pharmacy__c,
                                                                                                    US_WSREMS__Path_Stage_Name__c = 'Closed',US_WSREMS__Registration_Status__c ='Pending',
                                                                                                    US_WSREMS__REMSProgram__c = programId,US_WSREMS__Requestor_Type__c='Pharmacy',
                                                                                                    US_WSREMS__StageName__c='Closed',US_WSREMS__Status__c='Closed',
                                                                                                US_WSREMS__Path_Complete__c=true,US_WSREMS__Service_Outcome__c='Successful');
            counsellingRDAServiceList.add(remsService);
        }
        
        if(!counsellingRDAServiceList.isEmpty()){
            try{
                insert counsellingRDAServiceList;
            }catch(exception e){
                system.debug('<<<<patientCounsellingRDAServiceError'+e.getMessage());
            }
        }  
        
        if (!counsellingRDAServiceList.isEmpty()){
            for (US_WSREMS__REMS_Service_Summary__c remsService : counsellingRDAServiceList){
                serviceMap.put(remsService.Patient__c,remsService.Id);
            }
        }
        
        for (case cse : patientCounsellingRDAList){
            if(serviceMap.get(cse.US_WSREMS__Patient__c) != null ){
                
                newCase = New Case(RecordTypeId = caseCounselingRecordTypeId,US_WSREMS__Program_Picklist__c = cse.US_WSREMS__Program_Picklist__c,US_WSREMS__Channel__c=cse.US_WSREMS__Channel__c,
                                   US_WSREMS__REMS_Program__c = programId,US_WSREMS__Patient__c=cse.US_WSREMS__Patient__c,US_WSREMS__DOB__c=cse.US_WSREMS__DOB__c,
                                   SYN_Zip_Code__c=cse.SYN_Zip_Code__c,SYN_Patient_REMS_ID_Number__c=cse.SYN_Patient_REMS_ID_Number__c,US_WSREMS__First_Name__c=cse.US_WSREMS__First_Name__c,
                                   US_WSREMS__Last_Name__c=cse.US_WSREMS__Last_Name__c,US_WSREMS__Patient_Risk_Category__c = cse.US_WSREMS__Patient_Risk_Category__c,Recent_Patient_Reproductive_Status_Date__c=cse.Recent_Patient_Reproductive_Status_Date__c,
                                   SYN_Prescriber__c = cse.SYN_Prescriber__c,Prescriber_NPI__c=cse.Prescriber_NPI__c,Prescriber_REMS_ID_Number__c=cse.Prescriber_REMS_ID_Number__c,
                                   SYN_Pharmacy__c = cse.US_WSREMS__Pharmacy__c,SYN_Pharmacy_REMS_ID_Number__c=cse.SYN_Pharmacy_REMS_ID_Number__c,US_WSREMS__NPI__c=cse.US_WSREMS__NPI__c,US_WSREMS__Participant__c=cse.US_WSREMS__Pharmacy__c,
                                   Pharmacy_Participant__c=cse.Pharmacy_Participant__c,Participant_FirstName__c=cse.Participant_FirstName__c,Participant_LastName__c=cse.Participant_LastName__c,Counseling_Recorded__c=cse.Counseling_Recorded__c,
                                   Counseling_Completion_Date__c=System.today(),US_WSREMS__Outcome__c='Complete',Status='Complete',US_WSREMS__REMS_Service_Summary__c = serviceMap.get(cse.US_WSREMS__Patient__c),US_WSREMS__Pharmacy__c = cse.US_WSREMS__Pharmacy__c);
                
                counsellingRDACaseList.add(newCase);
            }
        }       
        
        if(!counsellingRDACaseList.isEmpty()){
            try{
                insert counsellingRDACaseList;
            }catch(exception e){
                system.debug('---patientCounsellingRDACaseError---'+e.getMessage());
            }
        }
    }
    /****************************************************************************************
Method Name : PAETask
Description : Create PAE task when AE resulted from treatment interruption = YES
*****************************************************************************************/ 
    public static void PAETask(List<Case> Caselist) {
        Id Maci_Escalation_QueueId = SYN_CommonUtility.getMaciEscQueue();
        Task task_PAE;
        List<Task> Task_PAE_Lst = new List<Task>();
        Id paePCCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'PAE_PC_MI');
        for (Case cs :[SELECT Id,recordTypeId,RecordType.DeveloperName,Status,Created_result_of_treatment_interruption__c,ownerId,US_WSREMS__REMS_Program__c,US_WSREMS__Patient__c,US_WSREMS__Program_Picklist__c,US_WSREMS__REMS_Service_Summary__c,US_WSREMS__Patient__r.PersonContactId,
                       ContactId FROM Case WHERE Id IN: Trigger.New AND recordTypeId =: paePCCaseRecTypeId AND US_WSREMS__Program_Picklist__c =: 'Macitentan REMS' AND Status IN ('Draft' , 'Complete') ]){
                           if( cs.Created_result_of_treatment_interruption__c == 'Yes' ){
                               task_PAE = RCA_Automation.createRCA_Task('Escalation','Adverse Event Reported',cs.US_WSREMS__REMS_Program__c,System.today(),Maci_Escalation_QueueId,'Adverse Event Reported',cs.US_WSREMS__Patient__r.PersonContactId);
                               task_PAE.WhatId = cs.US_WSREMS__REMS_Service_Summary__c;      
                               Task_PAE_Lst.add(task_PAE); 
                           }
                           
                           
                       }
        try{
            insert Task_PAE_Lst;
        }catch(exception e){
            system.debug('---Error---'+e.getMessage());
        }
    }
    public static void createREMSTask(List<Case> finalCaseList){
            List<Task> Createtask = new List<Task>();
            Map<String,Id> Casetask = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
            Id crpsRecTypeID = Casetask.get('Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');
            Map<Id, List<Onboarding_Checklist__mdt>> mapRecordtype = new Map<Id, List<Onboarding_Checklist__mdt>>();
           Group groupObj =[ SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name =: SYN_Utilitycls.Maci_REMS_Task_Queue];
          
            for(Onboarding_Checklist__mdt taskMetadata : [SELECT Case_RecordType_Developer_Name__c, Subject__c,TaskType__c,Task_Status__c,Program_Name__c FROM Onboarding_Checklist__mdt WHERE Case_RecordType_Developer_Name__c != NULL AND Subject__c != NULL AND TaskType__c = 'Follow-up' AND Program_Name__c !=NULL AND Program_Name__r.Label = 'Macitentan REMS' AND Task_Status__c != NULL ]){
                if(Casetask.containsKey(taskMetadata.Case_RecordType_Developer_Name__c)){
                    Id recordTypeId = Casetask.get(taskMetadata.Case_RecordType_Developer_Name__c);
                    if(mapRecordtype.containsKey(recordTypeId)){
                        
                        mapRecordtype.get(recordTypeId).add(taskMetadata);
                    }else{
                        mapRecordtype.put(recordTypeId, new List<Onboarding_Checklist__mdt>{taskMetadata});
                    }
                }
            }
            if(mapRecordtype != NULL){
                for(Case cse : finalCaseList){
                    if(mapRecordtype.containsKey(cse.RecordTypeId)){
                        for(Onboarding_Checklist__mdt taskMetadata : mapRecordtype.get(cse.RecordTypeId)){
                            Task tsk = new Task();
                            tsk.Subject = taskMetadata.Subject__c;
                            tsk.whatId = cse.US_WSREMS__REMS_Service_Summary__c;
                            if(cse.US_WSREMS__Channel__c != 'Portal'){
                            tsk.OwnerId = cse.OwnerId;
                            }
                            else{
                                if(groupObj.id != null){
                                    tsk.OwnerId = groupObj.id;
                                }
                            }
                            tsk.Status = taskMetadata.Task_Status__c;
                            tsk.Priority = 'Normal';
                            tsk.ActivityDate = System.today();
                            tsk.Program_Name__c =cse.US_WSREMS__REMS_Program__c;
                            tsk.Type = taskMetadata.TaskType__c;
                            if(cse.RecordTypeId==crpsRecTypeID){
                                tsk.description='Change in Reproductive Status and Annual Pre-pubertal Form received, however following information is still missing to complete change in status: '+cse.Incomplete_Reasons__c +' Follow-up with Prescriber for missing information.';
                                tsk.WhoId = cse.SYN_Prescriber__r.PersonContactId;
                            }else{
                            tsk.WhoId = cse.US_WSREMS__Participant__r.PersonContactId;
                            }
                            Createtask.add(tsk);
                        }
                    }
                }
            }
            
            if( !Createtask.isEmpty()){
                try{
                    insert Createtask;
                }catch(exception e){
                }
                
            }
    }
    
}