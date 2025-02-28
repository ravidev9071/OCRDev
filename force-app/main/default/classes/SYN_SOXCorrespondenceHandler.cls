/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-23-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SYN_SOXCorrespondenceHandler {
    public static final Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
    public static final Map<Id, Map<String, String>> affiliationFirstAndLastReferenceMap = new Map<Id, Map<String, String>>();
    public static void stakeholderEnrollMissingInfo(Boolean isInsert, Boolean isUpdate, Map<Id, Case> newMap,  Map<Id, Case> oldMap) {  
        //BT6825-905 userstorychanges
        List<REMS_Outbound_Communication__c> communicationRecList=new List<REMS_Outbound_Communication__c>();
        
        Set<String> programsToTriggerMissingInvalidCommu = new Set<String>{
            SYN_Utilitycls.SOX_PROGRAM_NAME
                };
                    
        Id patientEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');  
        Id prescriberEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');  
        Id pharmacyEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Pharmacy_Enrollment');  
        Id distributorEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Distributor_Enrollment');
        Id patientCounselingChecklistCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Counseling_Checklist');
        Id rmrCaseRecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Risk_Management_Report');
        Id pAECaseRecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'PAE_PC_MI');
      
        Set<Id> applicableRecordTypes = new Set<Id>{
            patientEnrollmentCaseRecTypeId,
                prescriberEnrollmentCaseRecTypeId,
                pharmacyEnrollmentCaseRecTypeId,
                distributorEnrollmentCaseRecTypeId,
                patientCounselingChecklistCaseRecTypeId,
                rmrCaseRecTypeId
                };
                    Set<Id> casesToCheckPrefferedConMethod = new Set<Id>();
        for(Case caseRec: newMap.values()){
            
            
            if(programsToTriggerMissingInvalidCommu.contains(caseRec.US_WSREMS__Program_Name__c) && (applicableRecordTypes.contains(caseRec.RecordTypeId) && caseRec.Status == 'Draft' && (isInsert || (isUpdate && caseRec.Status != oldMap.get(caseRec.Id).Status))) || (caseRec.RecordTypeId == pAECaseRecTypeId && caseRec.US_WSREMS__Outcome__c == 'Complete' && (isInsert || (isUpdate && caseRec.Status != oldMap.get(caseRec.Id).US_WSREMS__Outcome__c)) )){
                
                casesToCheckPrefferedConMethod.add(caseRec.Id);
            }
            
        }
        Map<Case,string> caseTemplateMap=new Map<Case,String>();
        List<Case> filteredCaseList = new List<Case>();
        if(!casesToCheckPrefferedConMethod.isEmpty()){  
            
            filteredCaseList =[SELECT Id,caseNumber,SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c,SYN_Prescriber__c,Status,RecordTypeId,SYN_Prescriber_First_Name__c, US_WSREMS__Patient__r.firstName,US_WSREMS__Patient__r.LastName,SYN_Prescriber_Last_Name__c,SYN_Prescriber_Middle_Name__c,SYN_Prescriber_Fax__c,
                               US_WSREMS__Email__c,US_WSREMS__Preferred_Contact_Method__c,SYN_Authorized_Rep__r.US_WSREMS__Email__c,US_WSREMS__Participant__r.Fax,US_WSREMS__Patient__r.Fax,Account.Fax,US_WSREMS__REMS_Service_Summary__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c,
                               US_WSREMS__Pharmacy_User__r.Fax,US_WSREMS__Fax__c,Incomplete_Reason__c,US_WSREMS__Patient__r.SYN_Ref_Id__c,US_WSREMS__First_Name__c,US_WSREMS__Last_Name__c,US_WSREMS__DOB__c,
                               US_WSREMS__Participant__r.firstName,SYN_Prescriber__r.firstName,US_WSREMS__Participant__r.LastName,SYN_Prescriber__r.LastName,SYN_Prescriber__r.Fax,US_WSREMS__Program_Name__c,OwnerId, US_WSREMS__Pharmacy_User__r.firstName,
                               US_WSREMS__Pharmacy_User__r.LastName,SYN_Type_of_Reporter__c,US_WSREMS__Participant__r.US_WSREMS__Email__c,SYN_Name_of_Reporter__c,SYN_Prescriber__r.US_WSREMS__Email__c,US_WSREMS__Participant__c,
                               Account.FirstName,Account_Record_Type__c,US_WSREMS__Outcome__c,SYN_Name_of_Reporter__r.Fax,SYN_Authorized_Rep__c,SYN_Name_of_Reporter__r.personContactId,SYN_Name_of_Reporter__r.US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Participant__r.personContactId,X1_Pharmacy_Participant__r.US_WSREMS__Email__c,SYN_Authorized_Rep__r.personContactId,SYN_Prescriber__r.personContactId,US_WSREMS__Distributor__r.US_WSREMS__Email__c,US_WSREMS__Distributor__r.personContactId FROM Case WHERE Id IN : casesToCheckPrefferedConMethod];
        }
        
        for(Case caseInstance : filteredCaseList) {
            
            if(caseInstance.RecordTypeId == patientEnrollmentCaseRecTypeId){
                
                if(caseInstance.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c == 'Fax' && caseInstance.SYN_Prescriber_First_Name__c != NULL && caseInstance.SYN_Prescriber_Last_Name__c != NULL && caseInstance.SYN_Prescriber_Fax__c != NULL) {
                    
                     //BT6825-905 userstorychanges
                    communicationRecList.add(createREMSCommunicationRecords(caseInstance,'Fax','Con-PatientEnrollmentFormwithMissing'));
                    
                }else if(caseInstance.SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c == 'Email' && caseInstance.SYN_Prescriber_First_Name__c != null && caseInstance.SYN_Prescriber_Last_Name__c != null && caseInstance.SYN_Prescriber__r.US_WSREMS__Email__c != NULL) {
                    
                      //BT6825-905 userstorychanges
                    communicationRecList.add(createREMSCommunicationRecords(caseInstance,'Email','SOX-Patient Enrollment Form with Missing'));
                }                
            }
            
            if(caseInstance.RecordTypeId == prescriberEnrollmentCaseRecTypeId || caseInstance.RecordTypeId == pharmacyEnrollmentCaseRecTypeId ||caseInstance.RecordTypeId == distributorEnrollmentCaseRecTypeId){
                
                if(caseInstance.US_WSREMS__Preferred_Contact_Method__c == 'Fax' && caseInstance.US_WSREMS__Last_Name__c != NULL && caseInstance.US_WSREMS__First_Name__c != NULL && caseInstance.US_WSREMS__Fax__c != NULL) {
                    
                      //BT6825-905 userstorychanges
                    communicationRecList.add(createREMSCommunicationRecords(caseInstance,'Fax','Con-StakeholderEnrollmentFormwithMissin'));
                }
                if(caseInstance.US_WSREMS__Preferred_Contact_Method__c == 'Email' && caseInstance.US_WSREMS__Last_Name__c != NULL && caseInstance.US_WSREMS__First_Name__c != NULL && caseInstance.US_WSREMS__Email__c != NULL) {
                    
                       //BT6825-905 userstorychanges
                    communicationRecList.add(createREMSCommunicationRecords(caseInstance,'Email','SOX-Stakeholder Enrollment Form with Mis')); 
                }
            }
               if(caseInstance.RecordTypeId == patientCounselingChecklistCaseRecTypeId && caseInstance.X1_Pharmacy_Participant__r.US_WSREMS__Email__c != null )
               {
                   communicationRecList.add(createREMSCommunicationRecords(caseInstance,'Email','SOX-PatientCounselingChecklistMissingInf'));
                   
               }
            if(caseInstance.RecordTypeId == rmrCaseRecTypeId && caseInstance.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c == 'Prescriber' && caseInstance.SYN_Type_of_Reporter__c == 'Prescribing Physician' && caseInstance.Account_Record_Type__c == 'Prescriber' && caseInstance.SYN_Name_of_Reporter__r.US_WSREMS__Preferred_Contact_Method__c == 'Fax')
               {
                   communicationRecList.add(createREMSCommunicationRecords(caseInstance,'Fax','Con-RiskManagementReportwithMissing'));
                   
               }
               if(caseInstance.RecordTypeId == rmrCaseRecTypeId && ((caseInstance.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c == 'Prescriber' && caseInstance.SYN_Type_of_Reporter__c == 'Prescribing Physician' && caseInstance.Account_Record_Type__c == 'Prescriber' && caseInstance.SYN_Name_of_Reporter__r.US_WSREMS__Preferred_Contact_Method__c == 'Email') || (caseInstance.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c == 'Pharmacy' && caseInstance.Account_Record_Type__c == 'Pharmacy Participant' && caseInstance.SYN_Type_of_Reporter__c == 'Pharmacist')))
               {
                   communicationRecList.add(createREMSCommunicationRecords(caseInstance,'Email','SOX-Risk_Management_Report_Missing_Info'));
                   
               }
            if(caseInstance.RecordTypeId == pAECaseRecTypeId && caseInstance.status == 'Complete' && caseInstance.US_WSREMS__Outcome__c == 'Complete') {
                    
                    //BT6825-905 userstorychanges
                    communicationRecList.add(createREMSCommunicationRecords(caseInstance,'Email','SOX-Potential Adverse Event (PAE) / (PC)'));
                }
            
            
        }
        //BT6825-905 userstorychanges
        if(communicationRecList!=null && !communicationRecList.isEmpty()){
            insert communicationRecList;
        }
    }
    
    /* Below method is for triggering the email for Knowledge Assessment*/
    public static void kAResults(Boolean isInsert, Boolean isUpdate, Map<Id, Case> newMap,  Map<Id, Case> oldMap) {
         Id kAACaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Knowledge_Assessment_A');  
        Id kABCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Knowledge_Assessment_B');
        //BT6825-905 userstorychanges
        List<REMS_Outbound_Communication__c> communicationRecList=new List<REMS_Outbound_Communication__c>();
        
        Boolean checkAnswers = FALSE; // Boolean check to trigger the email if Picklist fields are changed during update
        
        /* Insert only*/
        If(isInsert){ 
            for(case casObj : newMap.values()){                
                if(casObj.US_WSREMS__Outcome__c == 'Fail' && casObj.US_WSREMS__Email__c != NULL && casObj.US_WSREMS__Program_Name__c == SYN_Utilitycls.SOX_PROGRAM_NAME
                   &&(casObj.RecordTypeId == kABCaseRecTypeId || casObj.RecordTypeId == kAACaseRecTypeId)){
                          //BT6825-905 userstorychanges
                       communicationRecList.add(createREMSCommunicationRecords(casObj,'Email','SOX-Knowledge Assessment Failed'));
                   }
            }
        }
        
        /* Update only*/
        else{
        
        List<SYN_KnowledgeAssessmentAnswerValidation__mdt> KAFields = [SELECT RecordType_Dev_Name__c,Question__c, Full_Question__c, Answer__c , Order__c  FROM SYN_KnowledgeAssessmentAnswerValidation__mdt WHERE RecordType_Dev_Name__c != ''] ;
            Map<String, List<SYN_KnowledgeAssessmentAnswerValidation__mdt>> recordTypeAndMDT = new Map<String, List<SYN_KnowledgeAssessmentAnswerValidation__mdt>>();
            
            for(SYN_KnowledgeAssessmentAnswerValidation__mdt kav : KAFields){
                
                if(!recordTypeAndMDT.containsKey(kav.RecordType_Dev_Name__c)){
                    
                    recordTypeAndMDT.put(kav.RecordType_Dev_Name__c, new List<SYN_KnowledgeAssessmentAnswerValidation__mdt>());
                }
                
                List<SYN_KnowledgeAssessmentAnswerValidation__mdt> tempKAFields = recordTypeAndMDT.get(kav.RecordType_Dev_Name__c);
                tempKAFields.add(kav);
                recordTypeAndMDT.put(kav.RecordType_Dev_Name__c, tempKAFields);
                
            }
            
            for(case casObj : newMap.values()){
                case oldCaseObj = oldMap.get(casObj.Id);
                 
                List<SYN_KnowledgeAssessmentAnswerValidation__mdt> KAFields_meta = new List<SYN_KnowledgeAssessmentAnswerValidation__mdt>();
                if(recordTypeAndMDT.containsKey(casObj.US_WSREMS__Record_Type_Name__c)){
                
                    KAFields_meta = recordTypeAndMDT.get(casObj.US_WSREMS__Record_Type_Name__c);
                } 
                for(SYN_KnowledgeAssessmentAnswerValidation__mdt kAQuestion: KAFields){
                    if(casObj.get(kAQuestion.Question__c) != oldCaseObj.get(kAQuestion.Question__c)){
                        checkAnswers = TRUE;
                    }         
                }  
                
                if(casObj.US_WSREMS__Outcome__c == 'Fail' && casObj.US_WSREMS__Email__c != NULL && 
                   checkAnswers == TRUE && casObj.US_WSREMS__Program_Name__c == SYN_Utilitycls.SOX_PROGRAM_NAME &&
                   (casObj.RecordTypeId == kABCaseRecTypeId || casObj.RecordTypeId == kAACaseRecTypeId)){
                        //BT6825-905 userstorychanges
                       communicationRecList.add(createREMSCommunicationRecords(casObj,'Email','SOX-Knowledge Assessment Failed'));
                   }
                
            }
        }
        //BT6825-905 userstorychanges
        if(communicationRecList!=null && !communicationRecList.isEmpty()){
            insert communicationRecList;
        }
    }
    public static void pccCommunication(Case caseObj){
        List<REMS_Outbound_Communication__c> communicationRecList=new List<REMS_Outbound_Communication__c>();
            if (caseObj.Status == 'Complete' && caseObj.US_WSREMS__Outcome__c == 'Complete') {
                communicationRecList.add(createREMSCommunicationRecords(caseObj,'Email','SOX-Patient Counseling Checklist Process'));
            }
        if(communicationRecList!=null && !communicationRecList.isEmpty()){
            insert communicationRecList;
        }
    }
    
    //BT6825-905 userstorychanges
    public static REMS_Outbound_Communication__c createREMSCommunicationRecords(Case caseObject,String typeofCommunication,String templatename){
        REMS_Outbound_Communication__c communicationRec=new REMS_Outbound_Communication__c();
        communicationRec.Case__c=caseObject.Id;
        communicationRec.Recipient__c=caseObject.US_WSREMS__Participant__c;
        communicationRec.Template__c= templatename;
        communicationRec.Status__c='Pending';
        communicationRec.OBCom_Type__c=typeofCommunication;
        return communicationRec;
    }
    //BT6825-905 userstorychanges
  
    
    public static void getCaseDetailstoSendEmail(List<REMS_Outbound_Communication__c> scope){
        Id accountHCSRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');
        Id caseHCSRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
        Id nonComplianceRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');

        List<Id> caseIdList=new List<Id>();
        Set<Id> healthCareSettingAccIds = new Set<Id>();
        //Xiaflex Affiliation Fax Notification Changes
        Set<Id> prescriberAccIds = new Set<Id>();
        Set<Id> hcsAccIds = new Set<Id>();
        List<Account> prescriberList=new List<Account>();
        Map<Id,String> templateMap=new Map<Id,string>();
        for(REMS_Outbound_Communication__c communicationRec:scope){
            caseIdList.add(communicationRec.Case__c);
            templateMap.put(communicationRec.Case__c,communicationRec.Template__c);
            if( communicationRec.Recipient__c != NULL ){
                if( communicationRec.Recipient__r.RecordType.DeveloperName == 'Health_Care_Setting' ){
                    healthCareSettingAccIds.add(communicationRec.Recipient__c);
                    //Affiliation Notification for Xiaflex program
                    if(communicationRec.Recipient__r.US_WSREMS__REMS_Program__r.Name == SYN_Utilitycls.XIAFLEX_PROGRAM_NAME) {
                        hcsAccIds.add(communicationRec.Recipient__c);
                    }
                //Affiliation notification for Xiaflex program
                } else if( communicationRec.Recipient__r.RecordType.DeveloperName == 'Prescriber' && communicationRec.Recipient__r.US_WSREMS__REMS_Program__r.Name == SYN_Utilitycls.XIAFLEX_PROGRAM_NAME ){
                    prescriberAccIds.add(communicationRec.Recipient__c);
                }
            }
        }
        String relationshipfields='US_WSREMS__Prescriber__r.Fax,X1_Pharmacy_Participant__r.US_WSREMS__Email__c,X1_Pharmacy_Participant__r.FirstName,X1_Pharmacy_Participant__r.LastName,SYN_Prescriber__r.US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__Patient__r.firstName,US_WSREMS__Patient__r.LastName,SYN_Name_of_Reporter__r.Fax,SYN_Authorized_Rep__r.US_WSREMS__Email__c,US_WSREMS__Participant__r.Fax,US_WSREMS__Patient__r.Fax,US_WSREMS__Pharmacy_User__r.Fax,US_WSREMS__Patient__r.SYN_Ref_Id__c,US_WSREMS__Participant__r.firstName,SYN_Prescriber__r.firstName,US_WSREMS__Participant__r.LastName,SYN_Prescriber__r.LastName,SYN_Prescriber__r.Fax, US_WSREMS__Pharmacy_User__r.firstName,US_WSREMS__Pharmacy_User__r.LastName,US_WSREMS__Participant__r.US_WSREMS__Email__c,SYN_Prescriber__r.US_WSREMS__Email__c,Account.FirstName,US_WSREMS__Participant__r.personContactId,SYN_Authorized_Rep__r.personContactId,SYN_Prescriber__r.personContactId,US_WSREMS__Distributor__r.US_WSREMS__Email__c,US_WSREMS__Distributor__r.personContactId,US_WSREMS__Program_Name__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c,SYN_Pharmacist__r.US_WSREMS__Email__c,SYN_Pharmacist__r.personContactId,SYN_Name_of_Reporter__r.US_WSREMS__Email__c,SYN_Name_of_Reporter__r.personContactId,'
        + 'US_WSREMS__Participant__r.US_WSREMS__Email__c,US_WSREMS__Participant__r.RecordTypeId,US_WSREMS__REMS_Authorized_Rep__r.Fax, US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__Email__c, US_WSREMS__REMS_Authorized_Rep__r.personContactId,' 
        + 'US_WSREMS__X1_Participant__r.Fax, US_WSREMS__X1_Participant__r.RecordTypeId,US_WSREMS__X1_Participant__r.personContactId, US_WSREMS__X1_Participant__r.Name, US_WSREMS__X1_Participant__r.US_WSREMS__Email__c, US_WSREMS__Authorized_Representative_New_Primary_AR__r.personContactId,'
        + 'US_WSREMS__Participant__r.Name';
        List<String> listrelatioship = relationshipfields.split(',');
        Set<String> relationshipset= new Set<String>();
        relationshipset.addAll(listrelatioship);
        string condition=' where id IN : caseIdList';
        String finalquery=SYN_QueryUtil.getQuery('Case','',condition,'',relationshipset);
        
        List<case> caseList=Database.query(finalquery);

        Map<Id, Case> accounIdToHCSEnrollementCaseMap = new Map<Id, Case>();

        for(case caseRecord : caseList) {
            if(caseRecord.RecordTypeId == nonComplianceRecordType && caseRecord.US_WSREMS__X1_Participant__r.RecordTypeId == accountHCSRecordType &&
                (caseRecord.US_WSREMS__Program_Picklist__c == SYN_Utilitycls.AVEED_PROGRAM_NAME || caseRecord.US_WSREMS__Program_Picklist__c == SYN_Utilitycls.XIAFLEX_PROGRAM_NAME)
            ) {
                healthCareSettingAccIds.add(caseRecord.US_WSREMS__X1_Participant__c);
            }
        }

        if(!healthCareSettingAccIds.isEmpty()){
            for(US_WSREMS__Affiliation__c affiliationRec : AutomationCommunicationFromCase.getAffiliationsRecordsByHcsAccountIds(healthCareSettingAccIds)){
                if(!accountIdToaffiliationMap.containsKey(affiliationRec.US_WSREMS__Health_Care_Setting__c)){
                    accountIdToaffiliationMap.put(affiliationRec.US_WSREMS__Health_Care_Setting__c, affiliationRec);
                }
            }

            for(US_WSREMS__Affiliation__c affiliationRec : AutomationCommunicationFromCase.getXiaflexAffiliationsRecordsByHcsAccountIds(healthCareSettingAccIds)){
                if(!accountIdToaffiliationMap.containsKey(affiliationRec.US_WSREMS__Health_Care_Setting__c)){
                    accountIdToaffiliationMap.put(affiliationRec.US_WSREMS__Health_Care_Setting__c, affiliationRec);
                }
            }
        }
        
        //Process hcs affiliation notification fax template details
        if( !hcsAccIds.isEmpty() ){
            getAffiliationFirstAndLastDetails(hcsAccIds, 'Health_Care_Setting');
        }

        //Process prescriber affiliation notification fax template details
        if( !prescriberAccIds.isEmpty() ){
            getAffiliationFirstAndLastDetails(prescriberAccIds, 'Prescriber');
        }

        for(REMS_Outbound_Communication__c communicationRecObj:scope){
            for(Case caseObj :caseList){
               
                if(communicationRecObj.Case__c == caseObj.Id && communicationRecObj.OBCom_Type__c =='Email' ){
                    SYN_CorrespondenceHandler.sendEmailCorrespondence(caseObj,communicationRecObj.Template__c,communicationRecObj.Id);
                }else if(communicationRecObj.Case__c == caseObj.Id && communicationRecObj.OBCom_Type__c =='Fax' ){
                    
                   SYN_CorrespondenceHandler.sendFaxCorrespondence(caseObj,communicationRecObj.Template__c,communicationRecObj.Id,'case');  
               
                }
            }
            if(communicationRecObj.Recipient__c!=null && communicationRecObj.Case__c ==null){
                Account prescriber=[select id,name,Fax,PersonContactId,ownerid,Program_Name__c,US_WSREMS__Program_Name__c,US_WSREMS__First_And_Last_Name__c from account where id=:communicationRecObj.Recipient__c];
      
                   SYN_CorrespondenceHandler.sendFaxCorrespondence(prescriber,communicationRecObj.Template__c,communicationRecObj.Id ,'Account');  
      
       }
            
            
        }
        
    }
    
    /****************************************************************************************************************
    * Method Name : getAffiliationFirstAndLastDetails
    * @description: This method used to fetch the first and last reference of the Affiliation record based on the AccountId and recordType passed.
    *                - This logic used to identify the HCS or HCP affiliation records which are getting created at the same time to send the affiliation notifications for Xiaflex program.
    *                - Based on the Prescriber or HCS accountId passed we are fetching all the latest affiliation records to find the most recently created ones.
    *                - This first and last reference was passed to the Conga query to fetch the only relevant affiliated records to send in the Fax details.
    * @author     : Utthirakumar
    * @param      : accIds - stakeholder account ids, recType - stakeholder account recordType
    * @return     : void
    ****************************************************************************************************************/
    
    public static void getAffiliationFirstAndLastDetails(Set<Id> accIds, String recType){

        List<US_WSREMS__Affiliation__c> affliationsList = new List<US_WSREMS__Affiliation__c>();
        Map<Id, US_WSREMS__Affiliation__c> lastAffiliationReference = new Map<Id, US_WSREMS__Affiliation__c>();

        if( recType == SYN_Utilitycls.Prescriber ){
            affliationsList = [ Select Id, Name, US_WSREMS__Prescriber__c, US_WSREMS__Health_Care_Setting__c, CreatedDate, CreatedById From US_WSREMS__Affiliation__c Where US_WSREMS__Prescriber__c IN : accIds AND US_WSREMS__Health_Care_Setting__c != NULL ORDER BY Name DESC ];
        } else if( recType == 'Health_Care_Setting'){
            affliationsList = [ Select Id, Name, US_WSREMS__Prescriber__c, US_WSREMS__Health_Care_Setting__c, CreatedDate, CreatedById From US_WSREMS__Affiliation__c Where US_WSREMS__Health_Care_Setting__c IN : accIds AND US_WSREMS__Prescriber__c != NULL ORDER BY Name DESC ];
        }

        for( US_WSREMS__Affiliation__c aff : affliationsList ){
            Map<String, String> tempMap;
            if( recType == SYN_Utilitycls.Prescriber ){
                if( affiliationFirstAndLastReferenceMap.containsKey(aff.US_WSREMS__Prescriber__c) ){
                    tempMap =  affiliationFirstAndLastReferenceMap.get(aff.US_WSREMS__Prescriber__c);
                } else {
                    tempMap = new Map<String, String>();
                    tempMap.put('AccountRecordType', SYN_Utilitycls.Prescriber);
                    tempMap.put('Last', aff.Name);
                    tempMap.put('First', aff.Name);
                }
                if( lastAffiliationReference.containsKey(aff.US_WSREMS__Prescriber__c) ){
                    US_WSREMS__Affiliation__c lastAff = lastAffiliationReference.get(aff.US_WSREMS__Prescriber__c);
                    if( aff.CreatedDate == lastAff.CreatedDate && aff.CreatedById == lastAff.CreatedById ){
                        tempMap.put('First', aff.Name);
                    }
                } else {
                    lastAffiliationReference.put(aff.US_WSREMS__Prescriber__c, aff);
                }
                affiliationFirstAndLastReferenceMap.put(aff.US_WSREMS__Prescriber__c, tempMap);
            } else if( recType == 'Health_Care_Setting'){
                if( affiliationFirstAndLastReferenceMap.containsKey(aff.US_WSREMS__Health_Care_Setting__c) ){
                    tempMap =  affiliationFirstAndLastReferenceMap.get(aff.US_WSREMS__Health_Care_Setting__c);
                } else {
                    tempMap = new Map<String, String>();
                    tempMap.put('AccountRecordType', 'Health_Care_Setting');
                    tempMap.put('Last', aff.Name);
                    tempMap.put('First', aff.Name);
                }
                if( lastAffiliationReference.containsKey(aff.US_WSREMS__Health_Care_Setting__c) ){
                    US_WSREMS__Affiliation__c lastAff = lastAffiliationReference.get(aff.US_WSREMS__Health_Care_Setting__c);
                    if( aff.CreatedDate == lastAff.CreatedDate && aff.CreatedById == lastAff.CreatedById ){
                        tempMap.put('First', aff.Name);
                    }
                } else {
                    lastAffiliationReference.put(aff.US_WSREMS__Health_Care_Setting__c, aff);
                }
                affiliationFirstAndLastReferenceMap.put(aff.US_WSREMS__Health_Care_Setting__c, tempMap);
            }
        }

    }
    
}