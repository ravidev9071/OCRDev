/**
* @File Name          : SYN_CaseTriggerHanlder.cls
* @Description        : This is used as a Hanlder for Case trigger.
* @Trigger            : SYN_CaseTrigger
* @TestClass          : SYN_CaseTriggerHanlder_Test
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 1.0    02/22/2022        Chaitanya Nandamuri (Wilco)     Initial Implementation (Case Status Automation FrameWork )
* 2.0    03/29/2022        Raja Durai (Wilco)              handleAfterUpdate (Updating Accounts through cases)
* 3.0    03/30/2022        CHaitanya nandamuri (Wilco)     completeCasestatus BT6825-147 : Close the REMSservice on case completion.
* 4.0    04/29/2022        Praveen (Wilco)                 Added if condition for picklist fields for validating based on the user selection for BT6825-46
* 5.0    05/17/2022        Ismail Shaik (Wilco)            Validation Rule (BT6825-91: Validation Rule for Patient Enrollment form )
* 6.0    06/01/2022        Chaitanya Nandamuri (Wilco)     Handler class for Change of Information (BT6825- 249).
* 7.0    07/27/2022        Chaitanya Nandamuri(Wilco)      DEA vallidation check and updating status on Case BT6825-168/BT6825-122 (Implemented under updateCaseRDACode)
* 8.0    07/27/2022        Chaitanya Nandamuri(Wilco)      DEA vallidation check on record creation.
*9.0     09/23/2022        Praveen(Wilco)                  DEAvalidationAfterInsert method has been modified with the program check and added check for the record types.
*10.0    09/24/2022        Praveen(Wilco)                  Changes are:
                                                           Line94: updateCaseRDACode: 
                                                           New:Line 103-105: Added program if check, record types for NPI validation for MACI.
                                                           Update:Line 105-107: Added else check for above line for other than MACI.
                                                           Line118: DEAvalidationAfterInsert: 
                                                           New:Line 123-125: Added program if check, record types for NPI validation for MACI.
                                                           Update:Line 125-128: Added else check for above line for other than MACI.
*12.0   10/31/2022         Praveen(Wilco)                  Method: npiValidationForMACI - This is added to validate the NPI value if it is already existing in any accounts such that 
                                                                                          when an NPi is changed on case it will be invoked and checked.
*13.0   11/5/2022          Praveen(Wilco)                 Line:64; setRDAMACICaseStatusToComplete: Method to set RDA case status to complete for MACI.
*14.0   11/5/2022          Praveen(Wilco)                 Line 121: updateCaseRDACode --> conditions for maci and sox program
                                                          Line 131: updateCaseRDACode --> conditions for maci and sox program
                                                          Line 172: setAuthorizationCode --> Code to set the auth code and date.
                                                          Line 606-638: CustomValidation --> Added if condition for SOX and in the else maci conditions are added.
*15.0   30/11/2022         Ashish Y(Wilco)                Line 1761-1799: as part of the story 335 automation of approval process
                                                          Line 39-41: Boolean variable for recursive trigger
*16.0   11/30/2022         Praveen(Wilco)                 Line 621: CustomValidation-> Counseling Recorded, Monthly Pregnancy Test Recorded, Prescriber Refill Authorization Recorded, Reason for Days Supply >30,
                                                           Reason for Treatment Interruption: conditions are commented and added in the validation rules as part of MACI-7433-264.
*17.0   11/30/2022         Praveen(Wilco)                 setRDAMACICaseStatusToComplete -> Outcome was set to "Approved"; 
                                                          Line283: RDACaseLst is added with the program check as it is not needed for MACI.
*18.0    12/02/2022        Praveen(Wilco)                getShipmentRelatedDataForMACIRDA: Method to get the most recent RDA under the patient account of the inserting RDA and get the field values from the shipping and tracking recent record.
*19.0    19/12/2022         Aneesha Shaik(Wilco)           Updatating Account status and sub status values. BT6825-257(Method : updateAccountStatus)
*20.0    21/12/2022        Swetha S (Wilco)                 Line 811:As a part of Maci-Bt7433-444 story added to validate the Signature fields
*21.0     1/21/2023        Chaitanya Nandamuri (Wilco)     Maci Affiliations created on Case closure (Method : completeCasestatusOnUpdate)
*22.0     09/12/2024      Dileep Gurram(Wilco)              Changes added/Removed in completeCasestatusOnUpdate  Method Regarding BT7433-2356
*23.0      09/12/2024      Dileep Gurram(Wilco)              Changes added/Removed in getShipmentRelatedDataForMACIRDA  Method Regarding BT7433-2364 line number 114
**/
public class SYN_CaseTriggerHanlder {
    
    /*Below code is added by AshishY[Wilco]
     Below variable can be used to stop recurssive triggers */
     public static Boolean firstTrig = true;
     public static Boolean stopAccUpdate = false;
    
    Private static final string caseObj = 'case';
    Private static final string CompleteStatus = 'Complete';
    
    public static string soxProgram = 'Sodium Oxybate REMS';
    public static string maciProgram = 'Macitentan REMS';
    
    private
        static final Map<Id, Schema.RecordTypeInfo> mapRemsRecordTypesById =
        Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosById();
    private
        static final Map<String, Schema.RecordTypeInfo> mapRemsRecordTypesByDeveloperName =
        Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName();
    private
        static final Map<Id, Schema.RecordTypeInfo> mapCaseRecordTypesById =
        Schema.SObjectType.Case.getRecordTypeInfosById();
    private
        static final Map<String, Schema.RecordTypeInfo> mapCaseRcTyByDevName =
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    Private 
        static final Map<String, Schema.SObjectField> caseFieldAPItoLabelMap =
        Schema.getGlobalDescribe().get(caseObj).getDescribe().fields.getMap();
    Public static Map<String,String> errorMap = new Map<String,String>();
    public static Set<String> CaseenrollmentStr = new Set<String>{'Prescriber_enrollment','Patient_Enrollement','SYN_Outpatient_Pharmacy','SYN_Inpatient_Pharmacy', 'Patient_Reenrollment', 'Prescriber_Reenrollment', 'SYN_Outpatient_Pharmacy_Reenrollment', 'SYN_Inpatient_Pharmacy_Reenrollment'};
        public static Set<String> CaseenrollmentStrForNPI = new Set<String>{'Prescriber_enrollment','SYN_Outpatient_Pharmacy','SYN_Inpatient_Pharmacy'};
    public static Map<Id,Id> participantIdtoPersonAccMap ;

    public static void updateParticipantAccountNPIStatusForVeeva(list<case> newCaseList){
        set<Id> remsServiceIds = new Set<Id>();
        List<US_WSREMS__REMS_Service_Summary__c> remsServicesList = New List<US_WSREMS__REMS_Service_Summary__c>();
        List<Account> updateAccountList = New List<Account>();

        for(case c:newCaseList){
            if(((mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'Prescriber_enrollment') || (mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'SYN_Inpatient_Pharmacy') ||
                (mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'SYN_Outpatient_Pharmacy')) && c.REMS_Project_Code__c == Label.MACIProgramProjectCode && c.US_WSREMS__REMS_Service_Summary__c != null &&
               (c.US_WSREMS__Status__c == 'Active' || c.US_WSREMS__Status__c == 'Inactive') && c.US_WSREMS__NPI__c != ''){
                   remsServiceIds.add(c.US_WSREMS__REMS_Service_Summary__c);
               }

            if(!remsServiceIds.isEmpty()){
                remsServicesList = [SELECT Id,US_WSREMS__Participant__c,US_WSREMS__Requestor_Type__c FROM US_WSREMS__REMS_Service_Summary__c WHERE Id IN: remsServiceIds];
            }

            if(!remsServicesList.isEmpty()){
                for(case cs:newCaseList){
                    for(US_WSREMS__REMS_Service_Summary__c rs: remsServicesList){
                        if(rs.US_WSREMS__Participant__c != null && rs.Id == cs.US_WSREMS__REMS_Service_Summary__c &&
                           (cs.US_WSREMS__Status__c == 'Active' || cs.US_WSREMS__Status__c == 'Inactive')){
                               Account acc = New Account(Id=rs.US_WSREMS__Participant__c,SYN_NPI_Validation_Status__c = cs.US_WSREMS__Status__c);
                               updateAccountList.add(acc);
                           }
                    }

                }
            }
        }

        if(!updateAccountList.isEmpty()){
            try{
                update updateAccountList;
            }catch(exception e){

            }
        }

    }
    //Method to get the most recent RDA under the patient account of the inserting RDA and get the field values from the shipping and tracking recent record.
    public static void getShipmentRelatedDataForMACIRDA(list<case> newCaseList){
        Set<Id> patientAccIds = New Set<Id>();
        Set<Id> completedRDACaseIds = New Set<Id>();
        List<Case> rdaCompletedCaseList = New List<Case>();
        List<US_WSREMS__Shipping_and_Tracking__c> shippingNDTrackingRecsList = New List<US_WSREMS__Shipping_and_Tracking__c>();
        Map<Id,Case> patientIdvsExistingRDARec = New Map<Id,Case>();
        Map<Id,US_WSREMS__Shipping_and_Tracking__c> completedRDAvsShippingTrackingRec = New Map<Id,US_WSREMS__Shipping_and_Tracking__c>();
        
        for(case c :newCaseList){
            if((mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'PDA') && c.REMS_Project_Code__c == Label.MACIProgramProjectCode 
               && c.US_WSREMS__Patient__c != null){        
                   patientAccIds.add(c.US_WSREMS__Patient__c);
               }
        }
        if(patientAccIds != null && !patientAccIds.isEmpty()){
            rdaCompletedCaseList = [SELECT Id,RecordTypeId,US_WSREMS__Patient__c,US_WSREMS__Patient__r.Days_Supply__c,US_WSREMS__Patient__r.Shipment_Date__c,REMS_Project_Code__c,Recordtype.Name,RecordType.DeveloperName FROM Case WHERE US_WSREMS__Patient__c IN:patientAccIds AND RecordType.DeveloperName = 'PDA' ORDER BY CreatedDate DESC];
        }
        if(rdaCompletedCaseList != null && !rdaCompletedCaseList.isEmpty()){ // check empty
            for(Case cs:rdaCompletedCaseList){
                if(!patientIdvsExistingRDARec.containskey(cs.US_WSREMS__Patient__c)) {
                    patientIdvsExistingRDARec.put(cs.US_WSREMS__Patient__c,cs);
                }
            }
        }
        if(patientIdvsExistingRDARec != null && !patientIdvsExistingRDARec.isEmpty()){
            shippingNDTrackingRecsList = [SELECT Id,US_WSREMS__Case__c,US_WSREMS__Case__r.US_WSREMS__Patient__c,Days_Supply__c,US_WSREMS__Shipment_Date__c FROM US_WSREMS__Shipping_and_Tracking__c WHERE US_WSREMS__Case__c =: patientIdvsExistingRDARec.Values() AND US_WSREMS__Shipment_Date__c != Null AND Days_Supply__c != Null ORDER BY CreatedDate DESC];
        }
        if(shippingNDTrackingRecsList != null && !shippingNDTrackingRecsList.isEmpty()){
            for(US_WSREMS__Shipping_and_Tracking__c s:shippingNDTrackingRecsList){
                completedRDAvsShippingTrackingRec.put(s.US_WSREMS__Case__r.US_WSREMS__Patient__c,s);
            }
        } 
        if(completedRDAvsShippingTrackingRec != null && !completedRDAvsShippingTrackingRec.isEmpty()){
            for(case c :newCaseList){
                if(patientIdvsExistingRDARec.containskey(c.US_WSREMS__Patient__c)){
                    if(c.US_WSREMS__Patient__c == patientIdvsExistingRDARec.get(c.US_WSREMS__Patient__c).US_WSREMS__Patient__c && mapCaseRecordTypesById.get(patientIdvsExistingRDARec.get(c.US_WSREMS__Patient__c).RecordTypeId).getDeveloperName() == 'PDA' &&
                       mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'PDA'){
                           Date calculatedShippingDate = patientIdvsExistingRDARec.get(c.US_WSREMS__Patient__c).US_WSREMS__Patient__r.Shipment_Date__c.addDays(Integer.valueOf(patientIdvsExistingRDARec.get(c.US_WSREMS__Patient__c).US_WSREMS__Patient__r.Days_Supply__c));
                           c.Days_of_Interruption__c = calculatedShippingDate.daysBetween(date.today())-5;
                       }
                }
            }
        } 
    }  
    // Method to set the RDA case to complete and outcome to approve.
    public static void setRDAMACICaseStatusToComplete(list<case> newCaseList){
        for(case c :newCaseList){
            if((mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'PDA') && c.Status != 'Complete' && (c.REMS_Project_Code__c == Label.MACIProgramProjectCode || (c.US_WSREMS__Program_Picklist__c == Label.PiaSky_REMS_Program_Name && c.status != 'Cancelled'))){        
               c.Status = 'Complete';
               if(c.Prescriber_Status__c != 'Certified' && c.US_WSREMS__Program_Picklist__c == Label.PiaSky_REMS_Program_Name) {
                   c.US_WSREMS__Outcome__c = 'Rejected';
               } else  {
                  c.US_WSREMS__Outcome__c = 'Approved';
               }
           }
        }
}  

  // Method to set the RDA case to complete and outcome to approve.
  public static void setRDATRYVIOCaseStatusToComplete(list<case> newCaseList){
    String strComplete = System.Label.Case_Close_Status;
    Set<Id> setIds = new Set<Id>();
    Map<Id, String> mapAuthPres = new Map<Id, String>();
    for(case caseRec : newCaseList){
        if(caseRec.US_WSREMS__Prescriber__c != null){
            setIds.add(caseRec.US_WSREMS__Prescriber__c);
        }
    }
    for(Account accRec : [Select Id, US_WSREMS__Status__c From Account Where Id IN: setIds]){
        mapAuthPres.put(accRec.id, accRec.US_WSREMS__Status__c);
    }
    
    for(case caseObj :newCaseList){    
        if((mapCaseRecordTypesById.get(caseObj.RecordTypeId).getDeveloperName() == 'PDA') && caseObj.US_WSREMS__Program_Picklist__c == System.Label.Tryvio_Program && caseObj.Status != strComplete){
               if((caseObj.US_WSREMS__Prescriber__c != null && mapAuthPres.get(caseObj.US_WSREMS__Prescriber__c) == System.Label.Tryvio_Certified) && caseObj.US_WSREMS__Program_Name__c == System.Label.Tryvio_Program){
                  system.debug('Case Record ==> 3');
                  String str = string.valueof(Math.abs(Crypto.getRandomLong()));
                  String randomNumber = str.substring(0, 7);
                  String RDACode = 'RDA-'+ randomNumber;
                  if(String.isEmpty(caseObj.RDA_Authorization_Code__c)){
                      caseObj.RDA_Authorization_Code__c=  RDACode; 
                  }
                  caseObj.status = strComplete;                     
                  //caseObj.US_WSREMS__Outcome__c = 'Complete';                     
                  caseObj.US_WSREMS__Authorization_Status__c = System.Label.Tryvio_Approved;
                  caseObj.US_WSREMS__Authorization_Status_Reason__c = System.Label.Tryvio_Auth_Status_ReasonPT;
                  caseObj.RDA_Authorization_Code_Date__c = date.today();
                  
              }
              else  if((caseObj.US_WSREMS__Prescriber__c == null  || (caseObj.US_WSREMS__Prescriber__c != null && mapAuthPres.get(caseObj.US_WSREMS__Prescriber__c) != System.Label.Tryvio_Certified)) 
                && caseObj.US_WSREMS__Program_Name__c == System.Label.Tryvio_Program){
                system.debug('Case Record ==> 2');                        
                caseObj.status = strComplete;
                //caseObj.US_WSREMS__Status__c = 'Complete';
                caseObj.US_WSREMS__Outcome__c = System.Label.Tryvio_Denied;
                caseObj.US_WSREMS__Authorization_Status__c = System.Label.Tryvio_Denied;
                caseObj.US_WSREMS__Authorization_Status_Reason__c = System.Label.Tryvio_Auth_Status_ReasonNT;
                caseObj.RDA_Authorization_Code_Date__c = date.today();
               
             }
        }
    }
}

public static List<String> addValuesintoList(List<String> errorMessageList, String errMessage) {

    if(String.isNotBlank(errMessage)) {
        errorMessageList.add(errMessage);
    }
    return errorMessageList;
    } 
    public static void DOBValidation(list<case> newCaseList){
            for(case c :newCaseList){
               if(((mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == SYN_Utilitycls.Patient_Enrollment_RectypeDevName) || (mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == SYN_Utilitycls.Patient_Reenrollement)) && (c.US_WSREMS__DOB__c == Null)){            
                   c.addError('DOB is required');
               }
            }
    } 
    public static void updateSLNStatusonNullSLN(list<case> newCaseList){
        List<Id> accList = new List<Id>();
        List<Account> acctList = new List<Account>();
        for(case caseObj :newCaseList){
           if(caseObj.US_WSREMS__REMS_Program__c != null && caseobj.US_WSREMS__Program_Name__c == SYN_Utilitycls.SOX_PROGRAM_NAME && caseObj.US_WSREMS__SLN__c == null && SYN_Utilitycls.CASE_ENROLLMENT_RECTYPE_SET_VEEVA.contains(mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName())){
            caseObj.SLN_Status__c = 'INVALID';
               if(!String.isBlank(caseObj.US_WSREMS__Participant__c)){
                   accList.add(caseObj.US_WSREMS__Participant__c);
            }
            } 
            
        }
        if(!accList.isEmpty()){
            for(Id accId :accList ){
               Account acc = new Account (id = accId ,SLN_Status__c = 'Invalid'); 
                AcctList.add(acc);
            } 
        }
        if(!acctList.isEmpty()){
          update  acctList;
        }
    }
    //BT6825-465 
    public static void updatePortalSharingAcctfield(List<Case> caseList){
        List<Case> newCaseList = new List<Case>();
        for(Case caseRec : caseList){
            if(caseRec.Portal_Sharing_Account__c == null){
                newCaseList.add(caseRec);
            }
        }
        if(newCaseList.isEmpty()){
            return;
        }
        SYN_CommonUtility.portalSharingData portalSharingInformation = SYN_CommonUtility.portalSharingInfo();
        Map<string, Account> accountNameAndRecMap = portalSharingInformation.accNameAndRecordMap;
        Map<String, String> programNameAndAccountMap = portalSharingInformation.ProgramNameAndAccMap;
        if(!accountNameAndRecMap.isEmpty()){
             for(Case caseRec : newCaseList){
                 if(String.isNotBlank(caseRec.US_WSREMS__Program_Name__c)){    
                     
                     String portAccName = '';
                     String accountId = '';
                     if(programNameAndAccountMap.containsKey(caseRec.US_WSREMS__Program_Name__c)){
                         
                         portAccName = programNameAndAccountMap.get(caseRec.US_WSREMS__Program_Name__c);
                         
                         if(accountNameAndRecMap.containsKey(portAccName)){
                             
                             accountId = accountNameAndRecMap.get(portAccName).Id;
                         }
                     }
                     
                     
                     if(String.isNotBlank(accountId)){
                         caseRec.Portal_Sharing_Account__c = accountId;
                     }
                     else{
                        caseRec.Portal_Sharing_Account__c = Null;
                     }
                 }
             }
         }
         
    } //BT6825-465

    //BT6825-653
    public static void updateKAcaseOutcome(List<case> caseList) {

        Map<Id,Case> kAACaseMap = new Map<Id,Case>();
        Map<Id,Case> kABCaseMap = new Map<Id,Case>();

        Id kAACaseRecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', SYN_Utilitycls.Knowlege_Assessment_A);
        Id kABCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', SYN_Utilitycls.Knowlege_Assessment_B);

        Id programId= SYN_CommonUtility.SOXprogramId();
        for(Case caseRecord : caseList){
                if(caseRecord.US_WSREMS__REMS_Program__c == programId){
                if(caseRecord.RecordTypeId == kAACaseRecTypeId){
                    kAACaseMap.put(caseRecord.Id,caseRecord);
                }
                if( caseRecord.RecordTypeId == kABCaseRecTypeId){
                    kABCaseMap.put(caseRecord.Id,caseRecord);
                }
            }
        }

        if (kAACaseMap != null && (! kAACaseMap.isEmpty())) {
            Map<String,String> questionAnswermap = getquestionAnswerMapping(SYN_Utilitycls.Knowlege_Assessment_A);
            updateKAOutcome(kAACaseMap,questionAnswermap);
        }
        if (kABCaseMap != null && (! kABCaseMap.isEmpty())) {
            Map<String,String> questionAnswermap = getquestionAnswerMapping(SYN_Utilitycls.Knowlege_Assessment_B);
            updateKAOutcome(kABCaseMap,questionAnswermap);
        }

    }

    public static void updateKAOutcome(Map<Id,Case> kACasemap, Map<String,String> questionAnswermap){
        Map<String,String> fieldAPItoLabelMap = SYN_KnowledgeAssessmentAnswerValidation.getFieldlabelMap('Case');
            for(Id caseId : kACasemap.keySet()){
                List<String> failAnsList =  new List<String>();
                List<String> passAnsList =  new List<String>();
                Case caseObj = kACasemap.get(caseId);
                for(String question : questionAnswermap.keySet()){
                    if(caseObj.get(question) != questionAnswermap.get(question)){
                        if(fieldAPItoLabelMap.containsKey(question)){
                    
                            failAnsList.add(fieldAPItoLabelMap.get(question));
                        }
                    }
                    else{
                        passAnsList.add(question);
                    }        
                }
                //added for split issue Due dilligence and created in error condition
                if(!passAnsList.isEmpty() && failAnsList.isEmpty() && 
                   (caseObj.US_WSREMS__Outcome__c != 'Due Dilligence Exhausted' && caseObj.US_WSREMS__Outcome__c != 'Created in Error')){
                    caseObj.Incorrect_KA_Questions__c = '';
                    caseObj.US_WSREMS__Outcome__c = 'Pass';
                }
                if(((passAnsList.isEmpty() && !failAnsList.isEmpty()) || (!passAnsList.isEmpty() && !failAnsList.isEmpty())) 
                   && (caseObj.US_WSREMS__Outcome__c != 'Due Dilligence Exhausted' && caseObj.US_WSREMS__Outcome__c != 'Created in Error')){
                    caseObj.Incorrect_KA_Questions__c = String.join(failAnsList,';');
                    caseObj.US_WSREMS__Outcome__c = 'Fail';
                }           
            }        
    }

    public static Map<String,string> getquestionAnswerMapping(String caseRecordTypeDevName ){

            Map<string,string> targetSourceFieldMapping = new Map<String,string>();
            
            for (SYN_KnowledgeAssessmentAnswerValidation__mdt mdt : [select RecordType_Dev_Name__c,Question__c, Full_Question__c, Answer__c  from SYN_KnowledgeAssessmentAnswerValidation__mdt 
                                                                where RecordType_Dev_Name__c =: caseRecordTypeDevName] ){
                targetSourceFieldMapping.put( mdt.Question__c , mdt.Answer__c );
            }
            return targetSourceFieldMapping;
    }

//BT6825-653

public static void updateCaseRDACode(List<Case> caseList){
    for(Case caseObj:caseList)
      {
          if((caseObj.US_WSREMS__Outcome__c=='Approved' && caseObj.REMS_Project_Code__c != Label.MACIProgramProjectCode) || 
          (mapCaseRecordTypesById.get(caseObj.RecordTypeId).getDeveloperName() == 'PDA' && caseObj.REMS_Project_Code__c == Label.MACIProgramProjectCode && caseObj.US_WSREMS__Outcome__c == 'Approved') ||
             (caseObj.US_WSREMS__Outcome__c=='Approved' && caseObj.US_WSREMS__Program_Picklist__c == Label.PiaSky_REMS_Program_Name && mapCaseRecordTypesById.get(caseObj.RecordTypeId).getDeveloperName() == 'PDA'))
             {
                setAuthorizationCode(caseObj);
            }  
      }        
}
    
public static void updateCaseRDACode(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        List<Id> DEAValidationCaseIdLst = new List<Id>();
        List<Id> SLNValidationCaseIdLst = new List<Id>();
        List<Case> SLNNullCaseIdLst = new List<Case>();

        for(Case caseObj:newCaseMap.values()){
            if((newCaseMap.get(caseObj.Id).US_WSREMS__Outcome__c!=oldCaseMap.get(caseObj.Id).US_WSREMS__Outcome__c && newCaseMap.get(caseObj.Id).US_WSREMS__Outcome__c=='Approved' && caseObj.REMS_Project_Code__c != Label.MACIProgramProjectCode)
           || (newCaseMap.get(caseObj.Id).US_WSREMS__Outcome__c!=oldCaseMap.get(caseObj.Id).US_WSREMS__Outcome__c 
           && newCaseMap.get(caseObj.Id).US_WSREMS__Outcome__c=='Approved' && mapCaseRecordTypesById.get(caseObj.RecordTypeId).getDeveloperName() == 'PDA' && caseObj.REMS_Project_Code__c == Label.MACIProgramProjectCode)){
               setAuthorizationCode(caseObj);
           }
        
        // BT6825-168/BT6825-12
            if(caseobj.US_WSREMS__REMS_Program__c != null && caseobj.US_WSREMS__Program_Name__c == Label.Macitentan_REMS_Program_Name && caseObj.US_WSREMS__NPI__c != null && caseObj.US_WSREMS__NPI__c != oldCaseMap.get(caseObj.Id).US_WSREMS__NPI__c && SYN_Utilitycls.CASE_ENROLLMENT_RECTYPE_SET_VEEVA.contains(mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName())){
                DEAValidationCaseIdLst.add(caseobj.id); //npi validation
            }else if(caseObj.US_WSREMS__DEA__c != oldCaseMap.get(caseObj.Id).US_WSREMS__DEA__c ||caseObj.US_WSREMS__Last_Name__c != oldCaseMap.get(caseObj.Id).US_WSREMS__Last_Name__c ){
                DEAValidationCaseIdLst.add(caseObj.id);
        }

        if(caseobj.US_WSREMS__REMS_Program__c != null && caseobj.US_WSREMS__Program_Name__c == SYN_Utilitycls.SOX_PROGRAM_NAME && caseObj.US_WSREMS__NPI__c != null && (caseObj.US_WSREMS__NPI__c != oldCaseMap.get(caseObj.Id).US_WSREMS__NPI__c ||caseObj.US_WSREMS__Last_Name__c != oldCaseMap.get(caseObj.Id).US_WSREMS__Last_Name__c) && SYN_Utilitycls.CASE_ENROLLMENT_RECTYPE_SET_VEEVA.contains(mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName())){

                DEAValidationCaseIdLst.add(caseObj.id);
        }
        //BT6825-435
        if(caseobj.US_WSREMS__REMS_Program__c != null && caseobj.US_WSREMS__Program_Name__c == SYN_Utilitycls.SOX_PROGRAM_NAME 
        && caseObj.US_WSREMS__SLN__c != null && (caseObj.US_WSREMS__SLN__c != oldCaseMap.get(caseObj.Id).US_WSREMS__SLN__c 
        ||caseObj.US_WSREMS__Last_Name__c != oldCaseMap.get(caseObj.Id).US_WSREMS__Last_Name__c) 
        && SYN_Utilitycls.CASE_ENROLLMENT_RECTYPE_SET_VEEVA.contains(mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName())){
                   SLNValidationCaseIdLst.add(caseObj.id);
        }
        else if(caseObj.US_WSREMS__SLN__c == null){
                SLNNullCaseIdLst.add(caseObj);
        }//BT6825-435
        
    }
        if (!DEAValidationCaseIdLst.isEmpty()){
            DEAValidation(DEAValidationCaseIdLst);
    }
        if (!SLNValidationCaseIdLst.isEmpty()){
            DEAValidation(SLNValidationCaseIdLst);
    }
        if (!SLNNullCaseIdLst.isEmpty()){
            SYN_CaseTriggerHanlder.updateSLNStatusonNullSLN(SLNNullCaseIdLst);
    }

}

// BT6825-168/BT6825-12
public static void DEAValidation(List<Id>CaseIdLst){
        SYN_VeevaAPI_Search.searchCurrentCase(CaseIdLst);
    }
    //BT6825-435
public static void SLNNullvalidationBeforeInsert(List<Case> caseList){
    List<Case> SLNNullCaseObjLst = new List<Case>();
       for (case caseObj:caseList){
        if(caseObj.US_WSREMS__SLN__c == null && ((mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == SYN_Utilitycls.Prescriber_enrollRCTypeDev) 
        || (mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == SYN_Utilitycls.Prescriber_ReenrollRCTypeDev)
        || (mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == SYN_Utilitycls.Prescriber_Person_Account))){
           SLNNullCaseObjLst.add(caseObj);
            } 
       }
       if (!SLNNullCaseObjLst.isEmpty()){
       SYN_CaseTriggerHanlder.updateSLNStatusonNullSLN(SLNNullCaseObjLst);         
   }
} //BT6825-435
/// BT6825-PrescriberEnrollmentScreen
public static void DEAvalidationAfterInsert(List<Case> caseList){
    List<Id> caseIdlst = new List<Id>();
    for (case caseobj:caseList){
        if(caseobj.US_WSREMS__REMS_Program__c != null && caseObj.US_WSREMS__Channel__c !='Portal' && caseobj.US_WSREMS__Program_Name__c == Label.Macitentan_REMS_Program_Name && caseObj.US_WSREMS__NPI__c != null && SYN_Utilitycls.CASE_ENROLLMENT_RECTYPE_SET_VEEVA.contains(mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName())){
            caseIdlst.add(caseobj.id);//npi validation via veeva
        }else if((mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == SYN_Utilitycls.Prescriber_enrollRCTypeDev && UserInfo.getUserType() == 'PowerCustomerSuccess'
           && caseObj.US_WSREMS__DEA__c != null )){
               caseIdlst.add(caseobj.id); 
        }
        // added Piasky check BT 10005-45
         if( (caseObj.US_WSREMS__NPI__c != null || caseObj.US_WSREMS__SLN__c != null) && caseobj.US_WSREMS__Program_Name__c != Label.Macitentan_REMS_Program_Name && caseobj.US_WSREMS__Program_Name__c !=  Label.PiaSky_REMS_Program_Name && SYN_Utilitycls.CASE_ENROLLMENT_RECTYPE_SET_VEEVA.contains(mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName())){
            caseIdlst.add(caseObj.id);
        }

         
    }
    if(!caseIdlst.isEmpty() && caseIdlst != null){
    
            SYN_VeevaAPI_Search.searchCurrentCase(caseIdlst);
        }
    }
    
    public static void setAuthorizationCode(Case caseObj){

        if(caseObj.REMS_Project_Code__c != Label.MACIProgramProjectCode){
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, 7);
        String RDACode = 'RDA-'+ randomNumber;
        caseObj.RDA_Authorization_Code__c= RDACode;
        }

        if(caseObj.REMS_Project_Code__c == Label.MACIProgramProjectCode || caseObj.US_WSREMS__Program_Picklist__c == Label.PiaSky_REMS_Program_Name){
            caseObj.RDA_Authorization_Code_Date__c = date.today();
          }   
    } 

    @InvocableMethod
    public static List<string> setAuthorizationCodeMACI(){
        List<String> RDACode = New List<String>();
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, 7);
        RDACode.add('RDA-'+ randomNumber);
        system.debug('RDACode--->>'+RDACode);
        return RDACode;
    }

    public static void updateParticipantField(list<case> newCaseLst){
        List<US_WSREMS__REMS_Service_Summary__c> RSSList = [Select id, US_WSREMS__Participant__c FROM US_WSREMS__REMS_Service_Summary__c WHERE Id = :newCaseLst[0].US_WSREMS__REMS_Service_Summary__c ];
        for(case a: newCaseLst){
            if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Patient_Enrollement' || mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Patient_Reenrollment'){//Added or condition for reenrollment record types            
                a.US_WSREMS__Participant__c = a.US_WSREMS__Patient__c;
            }else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Prescriber_enrollment' || mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Prescriber_Reenrollment'){//Added or condition for reenrollment record types
                a.US_WSREMS__Participant__c = a.SYN_Prescriber__c;
            }else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'SYN_Distributor_Enrollment' || mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Distributor_Reenrollment'){//Added or condition for reenrollment record types
                a.US_WSREMS__Participant__c = a.US_WSREMS__Distributor__c;
            }else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Pharmacy_Enrollment' || mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Pharmacy_Reenrollment'){//Added or condition for reenrollment record types
                a.US_WSREMS__Participant__c = a.SYN_Pharmacy__c;
            }else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Patient_Counseling_Checklist' && a.REMS_Project_Code__c != Label.MACIProgramProjectCode){
                a.US_WSREMS__Participant__c = a.SYN_Pharmacy__c;
            }else if((mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'SYN_Knowledge_Assessment_A' && a.US_WSREMS__Service_Requestor_Type__c == 'Pharmacy' ) 
                     || (mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'SYN_Knowledge_Assessment_B' && a.US_WSREMS__Service_Requestor_Type__c == 'Pharmacy')) {
                         a.US_WSREMS__Participant__c = a.SYN_Pharmacy__c;
                     }else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'SYN_Knowledge_Assessment_A'){
                         a.US_WSREMS__Participant__c = a.Pharmacy_Participant__c;
                     }else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'SYN_Knowledge_Assessment_B'){
                         a.US_WSREMS__Participant__c = a.Pharmacy_Participant__c; 
                     }
            else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Risk_Management_Report'){
                a.US_WSREMS__Participant__c = a.SYN_Name_of_Reporter__c; 
            }
            else if((mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'PAE_PC_MI')||(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'PDA')
            ||(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'SYN_Non_Compliance')||(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Patient_Pregnancy_Test')){
                if(!RSSList.isEmpty()){
                a.US_WSREMS__Participant__c = RSSList[0].US_WSREMS__Participant__c; 
            }
                }
            else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'SYN_Inpatient_Pharmacy' || mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'SYN_Inpatient_Pharmacy_Reenrollment'){
                a.US_WSREMS__Participant__c = a.SYN_Pharmacy__c!=null? a.SYN_Pharmacy__c:a.US_WSREMS__Participant__c;
                a.SYN_Pharmacy__c = a.SYN_Pharmacy__c!=null? a.SYN_Pharmacy__c:a.US_WSREMS__Participant__c;

            }
            else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'SYN_Outpatient_Pharmacy' || mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'SYN_Outpatient_Pharmacy_Reenrollment'){
                a.US_WSREMS__Participant__c = a.SYN_Pharmacy__c!=null? a.SYN_Pharmacy__c:a.US_WSREMS__Participant__c;
            }
            else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification'){
                a.US_WSREMS__Participant__c = a.SYN_Prescriber__c;
            }
            else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Change_Authorized_Representative' && a.US_WSREMS__Pharmacy__c!=null){
                a.US_WSREMS__Participant__c = a.US_WSREMS__Pharmacy__c;
            }
            else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Change_Authorized_Representative' && a.US_WSREMS__Pharmacy__c==null && a.US_WSREMS__Program_Picklist__c == System.Label.Tryvio_Program){
                a.US_WSREMS__Participant__c = a.US_WSREMS__Distributor__c;
            }
            else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Patient_Counseling_Checklist' && a.US_WSREMS__Service_Requestor_Type__c == 'Pharmacy' && a.REMS_Project_Code__c == Label.MACIProgramProjectCode){
                a.US_WSREMS__Participant__c = a.SYN_Pharmacy__c;
            }
            else if(mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName() == 'Patient_Counseling_Checklist' && a.US_WSREMS__Service_Requestor_Type__c == 'Prescriber' && a.REMS_Project_Code__c == Label.MACIProgramProjectCode){
                a.US_WSREMS__Participant__c = a.SYN_Prescriber__c;
            }
            else if (mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName().contains('RCA') ){
                a.US_WSREMS__Participant__c = a.US_WSREMS__Patient__c;
            }
            else if (mapCaseRecordTypesById.get(a.RecordTypeId).getDeveloperName().contains('Reverse_RDA') && a.US_WSREMS__Program_Picklist__c == 'Macitentan REMS' ){    // updated this line to update participant for Reverse RDA For maci program
                a.US_WSREMS__Participant__c = a.US_WSREMS__Pharmacy__c;
            }
        }
    } 
    
    public static void customValidation(List<Case> newCaseLst){
        
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        Map<string, Object_validation_and_status_automation__mdt > customValidationMap = new map<String, Object_validation_and_status_automation__mdt>();
        Map<String, List<String>> newCustomValidationMap = new map<String, List<String>>();
        set<Id> remsServiceId = new set<Id>();
        Map<Id,Id> remsIdtoRctyIdMap = new Map<Id,Id>();
        customValidationMap = createCustomValidationMap(caseObj);
        id caseRiskManagementRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();//BT6825-46
        id pccRecordTypeId = caseRecordTypeMap.get('Patient_Counseling_Checklist');
        id PAERecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PAE_PC_MI')?.getRecordTypeId();//BT6825-222
        id casePatientEnrolRCTyId =caseRecordTypeMap.get('Patient_Enrollement');
        id casePatientReEnrolRCTyId =caseRecordTypeMap.get('Patient_Reenrollment');
        id caseRDARCTyId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();//BT6825-52
        id caseCARId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();//377
        id serviceRCTyId = mapRemsRecordTypesByDeveloperName.get('Participant_Account_Creation').getRecordTypeId();
        id prescriberEnrollmentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        id distributorEnrollmentRecordTypeId = caseRecordTypeMap.get('SYN_Distributor_Enrollment');
        id distributorReEnrollmentRecordTypeId =caseRecordTypeMap.get('Distributor_Reenrollment');
        id pharmacyEnrollmentRecordTypeId = caseRecordTypeMap.get('Pharmacy_Enrollment');
        id inPatpharmacyEnrollmentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
        id inPatpharmacyReEnrollmentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy_Reenrollment').getRecordTypeId();
        id outPatpharmacyEnrollmentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Outpatient_Pharmacy').getRecordTypeId();
        id outPatpharmacyReEnrollmentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Outpatient_Pharmacy_Reenrollment').getRecordTypeId();
        id changeInREproPotenRecordTypeId = caseRecordTypeMap.get('Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');

        List<Case> patientEnrollmentCases = new List<Case>();
        List<Case> carCases = new List<Case>(); //377
        List<Case> RDACaseLst = new List<Case>();
       
        Map<Id,String> programMap = SYN_CommonUtility.getActivePrograms();
        Set<String> programNames = new Set<String>();
         Map<Id,Id> accIds = new Map<Id,Id>();
        
        for(case cobj : newCaseLst){
            // Collect Program Case Program
           if(cobj.US_WSREMS__REMS_Program__c != null && programMap.containsKey(cobj.US_WSREMS__REMS_Program__c)){
               programNames.add(programMap.get(cobj.US_WSREMS__REMS_Program__c));
               if(cobj.US_WSREMS__Participant__c != null && cobj.US_WSREMS__REMS_Service_Summary__c == null){
                accIds.put(cobj.US_WSREMS__Participant__c, null);
           }
       }
       }
        if(accIds.keyset() != null){
            for(US_WSREMS__REMS_Service_Summary__c Rss: [SELECT Id,US_WSREMS__Participant__c,recordtypeId FROM US_WSREMS__REMS_Service_Summary__c WHERE recordtypeId =: serviceRCTyId AND US_WSREMS__Participant__c =:accIds.keyset() ]){
                accIds.put(rss.US_WSREMS__Participant__c,rss.Id);
            }
        }
       if(programNames != null && !programNames.isEmpty()){
            newCustomValidationMap = createProgramBasedCustomValidationMap(caseObj,programNames);
       }
       
        for (case cseObj: newCaseLst ){
         if(cseObj.US_WSREMS__REMS_Program__c != null && programMap.containsKey(cseObj.US_WSREMS__REMS_Program__c)){
               programNames.add(programMap.get(cseObj.US_WSREMS__REMS_Program__c));
               if(cseObj.US_WSREMS__Participant__c != null && accIds.Keyset() != null){
                if(accIds.get(cseObj.US_WSREMS__Participant__c) != null){
                    cseObj.US_WSREMS__REMS_Service_Summary__c = AccIds.get(cseObj.US_WSREMS__Participant__c);
                  }
               }   
           }
            if (cseObj.US_WSREMS__REMS_Service_Summary__c  == null){
                continue;
            }
            remsServiceId.add(cseObj.US_WSREMS__REMS_Service_Summary__c);
            
            if(cseObj.RecordTypeId == casePatientEnrolRCTyId || cseObj.RecordTypeId == casePatientReEnrolRCTyId){ // BT-6825-253 - OR condition(cseObj.RecordTypeId == casePatientReEnrolRCTyId){
                
                patientEnrollmentCases.add(cseObj);
            }
            //377
            if(cseObj.RecordTypeId == caseCARId) {
                carCases.add(cseObj);
            } //377
            
            if(cseObj.RecordTypeId == caseRDARCTyId && cseObj.REMS_Project_Code__c != Label.MACIProgramProjectCode){
                RDACaseLst.add(cseObj);
            }
        }
        
        if(!RDACaseLst.isEmpty()){
            SYN_CaseTriggerHelper.RDACaseValidation(RDACaseLst);
        }
        
        for (US_WSREMS__REMS_Service_Summary__c REMSs: [select id , recordtypeId from US_WSREMS__REMS_Service_Summary__c where Id In:remsServiceId ]){
            remsIdtoRctyIdMap.put(REMSs.id, REMSs.RecordTypeId);
        }
        
        Map<Id, Account> prescriberAccountStatusMap = new Map<Id, Account>();
        Map<Id, Account> carCasesAccountsStatusMap = new Map<Id, Account>(); //377
        if(!patientEnrollmentCases.isEmpty()){
            
            prescriberAccountStatusMap = checkPrescriberStatus(newCaseLst);
        }
        //377
        if(!carCases.isEmpty()){
            carCasesAccountsStatusMap = checkPharmacyStatus(newCaseLst);
        } //377
         //832
         Boolean stopAccUpdate = false;
         Set<String> allCaseRecordTypes = new Set<String>{
             'Prescriber_enrollment','Prescriber_Reenrollment','Prescriber_Person_Account','Prescriber_COI','Pharmacy_Enrollment',
             'Pharmacy_Participant_Account','Pharmacy_Participant_COI','SYN_Knowledge_Assessment_A','SYN_Knowledge_Assessment_B'};
         Set<String> caseCreationCaseRecTypes = new Set<String>{
             'Prescriber_enrollment','Prescriber_Reenrollment','Prescriber_COI','Pharmacy_Enrollment','Pharmacy_Participant_COI',
             'SYN_Knowledge_Assessment_A','SYN_Knowledge_Assessment_B'}; 
         Set<String> incompleteReasonCaseRecTypes = new Set<String>{
                     'Prescriber_enrollment','Prescriber_Reenrollment', 'Pharmacy_Enrollment'};
         
                     id prescriberAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
                     id pharmPartiAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
                     id prescriberEnrollRectypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
                     id prescriberReenrollRectypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_Reenrollment').getRecordTypeId();
                     id KKARectypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Knowledge_Assessment_A').getRecordTypeId();
                     id KKBRectypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Knowledge_Assessment_B').getRecordTypeId();
                     id prescriberCOIRectypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_COI').getRecordTypeId();
                     id phrmcyPartiCOIRectypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant_COI').getRecordTypeId();
                     id pharmacyEnrollRectypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Enrollment').getRecordTypeId();
                     List<Case> filteredEmailCases = new List<Case>();
                     List<Account> emailAccList = new List<Account>();
                     Set<String> caseEmails = new set<String>();
                     Map<String, List<Account>> emailAccountMap = new Map<String, List<Account>>();
                     Map<Id,Id> caseToAccRecordtypeMap = new Map<Id,Id>();
                     caseToAccRecordtypeMap.put(prescriberEnrollRectypeId, prescriberAccRecTypeId);
                     caseToAccRecordtypeMap.put(prescriberReenrollRectypeId, prescriberAccRecTypeId);
                     caseToAccRecordtypeMap.put(KKARectypeId, pharmPartiAccRecTypeId);
                     caseToAccRecordtypeMap.put(KKBRectypeId, pharmPartiAccRecTypeId);
                     caseToAccRecordtypeMap.put(pharmacyEnrollRectypeID, pharmPartiAccRecTypeId);
                     caseToAccRecordtypeMap.put(prescriberCOIRectypeId, prescriberAccRecTypeId);
                     caseToAccRecordtypeMap.put(phrmcyPartiCOIRectypeId, pharmPartiAccRecTypeId);
                     Set<id> crpsCaseID = new set<Id>();
                     Set<id> crpsPatientCaseID = new set<Id>();
                     Map<Id,String> PatientRiskCatMap= new  Map<Id,String> ();
                     for(case caseRec: newCaseLst){
                         String caseRecTypeDevName = mapCaseRecordTypesById.get(caseRec.RecordTypeId).getDeveloperName();
                        if(allCaseRecordTypes.contains(caseRecTypeDevName) && caseRec.US_WSREMS__REMS_Program__c != null && caseRec.US_WSREMS__Program_Name__c == Label.Sodium_Oxybate_REMS_Program_Name){
                            
                         filteredEmailCases.add(caseRec); 
                        }
                          if(caseRec.US_WSREMS__Patient__c!=null && caseRec.RecordTypeId == changeInREproPotenRecordTypeId){
                            crpsCaseID.add(caseRec.id);
                              crpsPatientCaseID.add(caseRec.US_WSREMS__Patient__c);
                                        }
                    }
                    for(Account acc:[select id,US_WSREMS__Patient_Risk_Category__c from Account where Id IN:crpsPatientCaseID]){
                             PatientRiskCatMap.put(acc.id,acc.US_WSREMS__Patient_Risk_Category__c);
                    }
                    for(case c: filteredEmailCases){
                     if(c.US_WSREMS__Email__c != Null){
                         caseEmails.add(c.US_WSREMS__Email__c);
                     }
                 }
                 List<Account> accList = [select Id, US_WSREMS__Email__c, RecordTypeId, Program_Name__c from Account where US_WSREMS__Email__c IN: caseEmails AND Program_Name__c = :Label.Sodium_Oxybate_REMS_Program_Name];
                 if(!accList.isEmpty() && accList != Null){
                     for(Account A: accList){
                         if(!emailAccountMap.containskey(A.US_WSREMS__Email__c)){
                             emailAccountMap.put(A.US_WSREMS__Email__c, new List<Account>());
                             }
                         emailAccountMap.get(A.US_WSREMS__Email__c).Add(A);
                 }
                 } 
                 //832
        List<String> requiredFieldLst;
        for (case cseObj: newCaseLst ){
            if (cseObj.US_WSREMS__REMS_Service_Summary__c  == null){
                continue;
            }
            String uniqueKey = mapCaseRecordTypesById.get(cseObj.RecordTypeId).getDeveloperName() +'$$'+mapRemsRecordTypesById.get(remsIdtoRctyIdMap.get(cseObj.US_WSREMS__REMS_Service_Summary__c)).getDeveloperName();
            if(cseObj.US_WSREMS__REMS_Program__c != null && programMap != null && !programMap.isEmpty() && programMap.containsKey(cseObj.US_WSREMS__REMS_Program__c) && programMap.get(cseObj.US_WSREMS__REMS_Program__c) == Label.Sodium_Oxybate_REMS_Program_Name && (UserInfo.getUserType() != 'PowerCustomerSuccess')){
                requiredFieldLst = customValidationMap.get(uniqueKey)?.Required_fields__c.deleteWhitespace().split(';');
            }else if(cseObj.US_WSREMS__REMS_Program__c != null && newCustomValidationMap != null && !newCustomValidationMap.isEmpty() && newCustomValidationMap.containsKey(uniqueKey)){
                requiredFieldLst = newCustomValidationMap.get(uniqueKey);
            }
            
            string errorMsg = '';
            List<String> errorMessageList = new List<String>();
            // Maci NPI validation 
            if (cseObj.US_WSREMS__Program_Picklist__c == Label.Macitentan_REMS_Program_Name && CaseenrollmentStrForNPI.contains( mapCaseRecordTypesById.get(cseObj.RecordTypeId).getDeveloperName())  &&
                cseObj.US_WSREMS__Status__c != 'Active' ){
                    errorMessageList = addValuesintoList(errorMessageList, 'NPI is invalid');
                }
            //Case status if complete then the incomplete reasons has to be null
            if(cseobj.status == 'Complete' && cseobj.Incomplete_Reasons__c != '' &&
              cseObj.US_WSREMS__Program_Picklist__c == Label.Macitentan_REMS_Program_Name){
                cseobj.Incomplete_Reasons__c = '';
            }
            //377
            if(cseObj.RecordTypeId == caseCARId){
                
                if(carCasesAccountsStatusMap != NULL && carCasesAccountsStatusMap.containsKey(cseObj.US_WSREMS__Pharmacy__c)){
                    if(carCasesAccountsStatusMap.get(cseObj.US_WSREMS__Pharmacy__c).US_WSREMS__Status__c  != 'Certified'&& cseObj.Status !='Draft' ){
                        errorMessageList = addValuesintoList(errorMessageList, 'Pharmacy must be certified to complete the case');
                    }
                }
                if(carCasesAccountsStatusMap != NULL && carCasesAccountsStatusMap.containsKey(cseObj.Pharmacy_Participant__c) && cseObj.US_WSREMS__Program_Picklist__c != Label.Macitentan_REMS_Program_Name ){
                    if(carCasesAccountsStatusMap.get(cseObj.Pharmacy_Participant__c).US_WSREMS__Status__c  != 'Active' && cseObj.Status !='Draft'){
                        errorMessageList = addValuesintoList(errorMessageList, ' New Authorized Representative must be Active to complete the case');
                    }
                }
                if(carCasesAccountsStatusMap != NULL && (carCasesAccountsStatusMap.containsKey(cseObj.US_WSREMS__Pharmacy__c) && carCasesAccountsStatusMap.containsKey(cseObj.Pharmacy_Participant__c))){
                    if((carCasesAccountsStatusMap.containsKey(cseObj.US_WSREMS__Pharmacy__c) && carCasesAccountsStatusMap.get(cseObj.US_WSREMS__Pharmacy__c).US_WSREMS__Status__c  == 'Certified') && (carCasesAccountsStatusMap.containsKey(cseObj.Pharmacy_Participant__c) && carCasesAccountsStatusMap.get(cseObj.Pharmacy_Participant__c).US_WSREMS__Status__c  == 'Active' )){
                      
                        cseobj.status = 'Complete';
                    }
                }
                if ( errorMessageList.size() == 0 && cseObj.Status  != CompleteStatus ){
                
                } else if (errorMessageList.size() > 0 && cseObj.Status  == CompleteStatus){
                String errMsg = String.valueOf(errorMessageList);
                errMsg = errMsg.substring(1, errMsg.length()-1);
                cseObj.addError(errMsg);
            }
            }//377
            //832
            String emailMatchPicklistValue = 'The provided email address already exists within another account.';
            Boolean duplicateEmail = false;
            String caseRecTypeDevName = mapCaseRecordTypesById.get(cseObj.RecordTypeId).getDeveloperName();
            List<Account> matchingAccounts = emailAccountMap.get(cseObj.US_WSREMS__Email__c);//832
            String presAccId = cseObj.SYN_Prescriber__c;
            String AccId = cseObj.US_WSREMS__Participant__c;
            String authRepId = cseObj.SYN_Authorized_Rep__c;
            Boolean presCOIEmailMatch = false;
            Boolean pharmPartiCOIEmailMatch = false;
            Boolean kAAEmailMatch = false;
            Boolean kABEmailMatch = false;
            if(matchingAccounts != null){
                for (Account acc : matchingAccounts) {
                    if (acc.Id != AccId && (cseObj.RecordTypeId == prescriberCOIRectypeId || cseObj.RecordTypeId == phrmcyPartiCOIRectypeId || cseObj.RecordTypeId == KKARectypeId || cseObj.RecordTypeId == KKBRectypeId) && caseToAccRecordtypeMap.get(cseObj.RecordTypeId) == acc.RecordTypeId && acc.US_WSREMS__Email__c == cseObj.US_WSREMS__Email__c && cseObj.Status == 'Complete' && cseObj.US_WSREMS__Outcome__c != 'Due Dilligence Exhausted')  {
                        duplicateEmail = true;
                        SYN_CaseTriggerHanlder.stopAccUpdate = true;
                        if(cseObj.RecordTypeId == prescriberCOIRectypeId){
                            presCOIEmailMatch = true;
                        } else if(cseObj.RecordTypeId == phrmcyPartiCOIRectypeId){
                            pharmPartiCOIEmailMatch = true;
                        } else if(cseObj.RecordTypeId == KKARectypeId){
                            kAAEmailMatch = true;
                        } else if(cseObj.RecordTypeId == KKBRectypeId){
                            kABEmailMatch = true;
                        }
                              
                    }
                    if (acc.Id != AccId && (cseObj.RecordTypeId == prescriberCOIRectypeId || cseObj.RecordTypeId == phrmcyPartiCOIRectypeId || cseObj.RecordTypeId == KKARectypeId || cseObj.RecordTypeId == KKBRectypeId) && caseToAccRecordtypeMap.get(cseObj.RecordTypeId) == acc.RecordTypeId && acc.US_WSREMS__Email__c == cseObj.US_WSREMS__Email__c && cseObj.Status == 'Complete' && cseObj.US_WSREMS__Outcome__c == 'Due Dilligence Exhausted')  {
                        duplicateEmail = true;
                        SYN_CaseTriggerHanlder.stopAccUpdate = true;
                              
                    }
                    else if (acc.Id != AccId && (cseObj.RecordTypeId == prescriberCOIRectypeId || cseObj.RecordTypeId == phrmcyPartiCOIRectypeId || cseObj.RecordTypeId == KKARectypeId || cseObj.RecordTypeId == KKBRectypeId) && caseToAccRecordtypeMap.get(cseObj.RecordTypeId) == acc.RecordTypeId && acc.US_WSREMS__Email__c == cseObj.US_WSREMS__Email__c && cseObj.Status == 'Draft' )  {
                        duplicateEmail = true;
                        SYN_CaseTriggerHanlder.stopAccUpdate = true;
                        if(cseObj.RecordTypeId == prescriberCOIRectypeId){
                            presCOIEmailMatch = true;
                        } else if(cseObj.RecordTypeId == phrmcyPartiCOIRectypeId){
                            pharmPartiCOIEmailMatch = true;
                        } else if(cseObj.RecordTypeId == KKARectypeId){
                            kAAEmailMatch = true;
                        } else if(cseObj.RecordTypeId == KKBRectypeId){
                            kABEmailMatch = true;
                        }
                       
                                
                    }
                    }

            } 
            if ((requiredFieldLst == null || requiredFieldLst.isEmpty()) && duplicateEmail == false){
                return;
            } 
          
            if(requiredFieldLst != null){
                for (string field : requiredFieldLst ){
                    
                    if ( string.isBlank( String.valueOf(cseObj.get(field)) ) ){
                        //Skipping DEA value of prescriber as this is a conflict for PPCL -456 portal flow requirement
                        if(UserInfo.getUserType() == 'PowerCustomerSuccess' && field == 'US_WSREMS__DEA__c' 
                        && cseObj.RecordTypeId == pccRecordTypeId){ 
                            continue;
                        }
                        errorMessageList = addValuesintoList(errorMessageList, caseFieldAPItoLabelMap.get(field).getDescribe().getLabel());
                    }
                }
            }
            Boolean presEnrollEmailMatch = false;
            Boolean presReEnrollEmailMatch = false;
            Boolean pharmpartiEnrollEmailMatch = false;
            if(matchingAccounts != null){
                    for (Account acc : matchingAccounts) {
                        if (acc.Id != presAccId && (cseObj.RecordTypeId == prescriberEnrollRectypeId ) && caseToAccRecordtypeMap.get(cseObj.RecordTypeId) == acc.RecordTypeId && acc.US_WSREMS__Email__c == cseObj.US_WSREMS__Email__c && cseObj.Status == 'Complete' && cseObj.US_WSREMS__Outcome__c != 'Due Dilligence Exhausted'){
                            SYN_CaseTriggerHanlder.stopAccUpdate = true;
                            presEnrollEmailMatch = true;
                        }
                        if (acc.Id != presAccId && (cseObj.RecordTypeId == prescriberReenrollRectypeId ) && caseToAccRecordtypeMap.get(cseObj.RecordTypeId) == acc.RecordTypeId && acc.US_WSREMS__Email__c == cseObj.US_WSREMS__Email__c && cseObj.Status == 'Complete' && cseObj.US_WSREMS__Outcome__c != 'Due Dilligence Exhausted'){
                            SYN_CaseTriggerHanlder.stopAccUpdate = true;
                            presReEnrollEmailMatch = true;
                            
                        }
                        else if(acc.Id != presAccId && (cseObj.RecordTypeId == prescriberEnrollRectypeId || cseObj.RecordTypeId == prescriberReenrollRectypeId ) && caseToAccRecordtypeMap.get(cseObj.RecordTypeId) == acc.RecordTypeId && acc.US_WSREMS__Email__c == cseObj.US_WSREMS__Email__c && (cseObj.Status == 'Complete') && cseObj.US_WSREMS__Outcome__c == 'Due Dilligence Exhausted'){
                            SYN_CaseTriggerHanlder.stopAccUpdate = true;
                        }
                        else if (acc.Id != presAccId && (cseObj.RecordTypeId == prescriberEnrollRectypeId || cseObj.RecordTypeId == prescriberReenrollRectypeId ) && caseToAccRecordtypeMap.get(cseObj.RecordTypeId) == acc.RecordTypeId && acc.US_WSREMS__Email__c == cseObj.US_WSREMS__Email__c && cseObj.Status == 'Draft' && incompleteReasonCaseRecTypes.contains(caseRecTypeDevName))  {                              
                            SYN_CaseTriggerHanlder.stopAccUpdate = true; 
                            if(cseObj.RecordTypeId == prescriberEnrollRectypeId){
                                presEnrollEmailMatch = true;
                            }else{
                              presReEnrollEmailMatch = true;  
                            }
                          
                        }
                        else if (acc.Id != authRepId && (cseObj.RecordTypeId == pharmacyEnrollRectypeID) && caseToAccRecordtypeMap.get(cseObj.RecordTypeId) == acc.RecordTypeId && acc.US_WSREMS__Email__c == cseObj.US_WSREMS__Email__c && (cseObj.Status == 'Complete') && cseObj.US_WSREMS__Outcome__c != 'Due Dilligence Exhausted')  {        
                            SYN_CaseTriggerHanlder.stopAccUpdate = true;
                            pharmpartiEnrollEmailMatch = true;
                            
                        }
                        else if (acc.Id != authRepId && (cseObj.RecordTypeId == pharmacyEnrollRectypeID) && caseToAccRecordtypeMap.get(cseObj.RecordTypeId) == acc.RecordTypeId && acc.US_WSREMS__Email__c == cseObj.US_WSREMS__Email__c && (cseObj.Status == 'Complete') && cseObj.US_WSREMS__Outcome__c == 'Due Dilligence Exhausted')  {
                            SYN_CaseTriggerHanlder.stopAccUpdate = true;
                        }
                        else if (acc.Id != authRepId && (cseObj.RecordTypeId == pharmacyEnrollRectypeID) && caseToAccRecordtypeMap.get(cseObj.RecordTypeId) == acc.RecordTypeId && acc.US_WSREMS__Email__c == cseObj.US_WSREMS__Email__c && (cseObj.Status == 'Draft') )  {
                         pharmpartiEnrollEmailMatch = true;
                            SYN_CaseTriggerHanlder.stopAccUpdate = true;        
                        }
                                                
                    }

                } 
            
            
            //BT6825 - 46   
            if(cseObj.RecordTypeId == caseRiskManagementRecordTypeId){
                String RMR_errormsg='';
                List<String> rmrerrorMessageList = new List<String>();
                errorMessageList = (cseObj.SYN_Type_of_Reporter__c == 'Other' && (cseObj.SYN_If_Other_Type_of_Reporter__c == '' || cseObj.SYN_If_Other_Type_of_Reporter__c == Null)) ? addValuesintoList(errorMessageList, 'Other Reporter Type') : addValuesintoList(errorMessageList, ''); 
                rmrerrorMessageList = (cseObj.SYN_Type_of_Reporter__c == 'Other' && (cseObj.SYN_If_Other_Type_of_Reporter__c == '' || cseObj.SYN_If_Other_Type_of_Reporter__c == Null)) ? addValuesintoList(rmrerrorMessageList, 'Other Reporter Type') : addValuesintoList(rmrerrorMessageList, ''); 
                errorMessageList = (cseObj.SYN_Attachments__c == 'Other' && (cseObj.SYN_If_Other_Attachments__c == '' || cseObj.SYN_If_Other_Attachments__c == Null)) ? addValuesintoList(errorMessageList, 'Other (Attachments)') : addValuesintoList(errorMessageList, '');
                rmrerrorMessageList = (cseObj.SYN_Attachments__c == 'Other' && (cseObj.SYN_If_Other_Attachments__c == '' || cseObj.SYN_If_Other_Attachments__c == Null)) ? addValuesintoList(rmrerrorMessageList, 'Other (Attachments)') : addValuesintoList(rmrerrorMessageList, '');
                errorMessageList = (cseObj.SYN_Early_Refill_Requested__c == 'Yes' && (cseObj.SYN_If_yes_reason_for_early_refill__c == '' || cseObj.SYN_If_yes_reason_for_early_refill__c == Null)) ? addValuesintoList(errorMessageList, 'If yes, reason for early refill?') : addValuesintoList(errorMessageList, '');
                rmrerrorMessageList = (cseObj.SYN_Early_Refill_Requested__c == 'Yes' && (cseObj.SYN_If_yes_reason_for_early_refill__c == '' || cseObj.SYN_If_yes_reason_for_early_refill__c == Null)) ? addValuesintoList(rmrerrorMessageList, 'If yes, reason for early refill?') : addValuesintoList(rmrerrorMessageList, '');
                errorMessageList = (cseObj.SYN_Prescriber_Contacted__c == 'Yes' && (cseObj.SYN_If_yes_what_was_the_outcome__c == '' || cseObj.SYN_If_yes_what_was_the_outcome__c == Null)) ? addValuesintoList(errorMessageList, 'If yes, what was the outcome?') : addValuesintoList(errorMessageList, '');
                rmrerrorMessageList = (cseObj.SYN_Prescriber_Contacted__c == 'Yes' && (cseObj.SYN_If_yes_what_was_the_outcome__c == '' || cseObj.SYN_If_yes_what_was_the_outcome__c == Null)) ? addValuesintoList(rmrerrorMessageList, 'If yes, what was the outcome?') : addValuesintoList(rmrerrorMessageList, '');
                errorMessageList = (cseObj.SYN_Prescriber_Contacted__c == 'No' && (cseObj.SYN_If_no_what_is_the_reason__c == '' || cseObj.SYN_If_no_what_is_the_reason__c == Null)) ? addValuesintoList(errorMessageList, 'If no, what is the reason?') : addValuesintoList(errorMessageList, '');
                rmrerrorMessageList = (cseObj.SYN_Prescriber_Contacted__c == 'No' && (cseObj.SYN_If_no_what_is_the_reason__c == '' || cseObj.SYN_If_no_what_is_the_reason__c == Null)) ? addValuesintoList(rmrerrorMessageList, 'If no, what is the reason?') : addValuesintoList(rmrerrorMessageList, '');
                errorMessageList = (cseObj.SYN_Was_early_refill_approved__c == 'Yes' && (cseObj.SYN_Early_refill_status_reason__c == '' || cseObj.SYN_Early_refill_status_reason__c == Null)) ? addValuesintoList(errorMessageList, 'Early refill status reason?') : addValuesintoList(errorMessageList, '');
                rmrerrorMessageList = (cseObj.SYN_Was_early_refill_approved__c == 'Yes' && (cseObj.SYN_Early_refill_status_reason__c == '' || cseObj.SYN_Early_refill_status_reason__c == Null)) ? addValuesintoList(rmrerrorMessageList, 'Early refill status reason?') : addValuesintoList(rmrerrorMessageList, '');

                errorMessageList = (cseObj.SYN_For_the_patient__c == 'Yes' && cseObj.US_WSREMS__Patient__c == null) ? addValuesintoList(errorMessageList, 'Patient') : addValuesintoList(errorMessageList, '');
                errorMessageList = (cseObj.SYN_For_the_prescriber__c == 'Yes' && cseObj.SYN_Prescriber__c == null) ? addValuesintoList(errorMessageList, 'Prescriber') : addValuesintoList(errorMessageList, '');
                errorMessageList = (cseObj.US_WSREMS__Program_Picklist__c == Label.SYN_SOX_REMS_Program_Name && cseObj.US_WSREMS__Signature__c == 'No') ? addValuesintoList(errorMessageList, 'Signature') : addValuesintoList(errorMessageList, '');

                rmrerrorMessageList = (cseObj.SYN_Nature_of_Report__c !=null && cseObj.SYN_Nature_of_Report__c.contains('Treatment Delay/Interruption') && (cseObj.Treatment_Delay_due_to_other_REMS__c == '' || cseObj.Treatment_Delay_due_to_other_REMS__c == Null)) ? addValuesintoList(rmrerrorMessageList, 'Treatment Delay due to other REMS') : addValuesintoList(rmrerrorMessageList, '');
                
                if(rmrerrorMessageList.size() > 0) {
                    String rmrMsg = String.valueOf(rmrerrorMessageList);
                    rmrMsg = rmrMsg.substring(1, rmrMsg.length()-1);
    
                    cseObj.addError('Please complete all required fields : '+rmrMsg);   
                }
                
            } else if(cseObj.RecordTypeId == casePatientEnrolRCTyId) {
                if(((cseObj.Status != 'Draft' && cseObj.US_WSREMS__Program_Picklist__c != Label.Macitentan_REMS_Program_Name) || cseObj.US_WSREMS__Program_Picklist__c == Label.Macitentan_REMS_Program_Name)) {
                    if(prescriberAccountStatusMap != NULL && prescriberAccountStatusMap.containsKey(cseObj.SYN_Prescriber__c)){
                    
                        errorMessageList = (prescriberAccountStatusMap.get(cseObj.SYN_Prescriber__c).US_WSREMS__Status__c  != 'Certified') ? addValuesintoList(errorMessageList, 'Prescriber not Certified') : addValuesintoList(errorMessageList, '');
                    }
                    if(cseObj.US_WSREMS__REMS_Program__c != null && programMap.containsKey(cseObj.US_WSREMS__REMS_Program__c) && programMap.get(cseObj.US_WSREMS__REMS_Program__c) == Label.Macitentan_REMS_Program_Name && cseObj.US_WSREMS__DOB__c!= null){
                            Integer days = cseObj.US_WSREMS__DOB__c.daysBetween(Date.Today());
                            integer age = Integer.valueOf(days/365.22);
                            errorMessageList = (age < 18 && (String.isBlank(cseObj.Legal_Guardian_Name__c) || String.isBlank(cseObj.Legal_Guardian_Relationship__c) || String.isBlank(cseObj.Legal_Guardian_Phone__c)) ) ? addValuesintoList(errorMessageList, SYN_Utilitycls.Legal_Guardian_ErrorMsg) : addValuesintoList(errorMessageList, '');
                    }
                } 
                errorMessageList = (cseObj.US_WSREMS__Program_Picklist__c == Label.SYN_SOX_REMS_Program_Name && cseObj.RecordTypeId == casePatientEnrolRCTyId && cseObj.US_WSREMS__Program_Picklist__c != Label.Macitentan_REMS_Program_Name && cseObj.US_WSREMS__Signature__c == 'No') ? addValuesintoList(errorMessageList, 'Signature') : addValuesintoList(errorMessageList, '');
                errorMessageList = (cseObj.US_WSREMS__Program_Picklist__c == Label.SYN_SOX_REMS_Program_Name && cseObj.RecordTypeId == casePatientEnrolRCTyId && cseObj.US_WSREMS__Program_Picklist__c != Label.Macitentan_REMS_Program_Name && cseObj.SYN_Prescriber_Signature__c == 'No') ? addValuesintoList(errorMessageList, 'Prescriber Signature') : addValuesintoList(errorMessageList, '');
    
            } else if(cseObj.RecordTypeId == casePatientReEnrolRCTyId) {
                if(((cseObj.Status != 'Draft' && cseObj.US_WSREMS__Program_Picklist__c != Label.Macitentan_REMS_Program_Name) || cseObj.US_WSREMS__Program_Picklist__c == Label.Macitentan_REMS_Program_Name)) {
                    if(prescriberAccountStatusMap != NULL && prescriberAccountStatusMap.containsKey(cseObj.SYN_Prescriber__c)){
                    
                        errorMessageList = (prescriberAccountStatusMap.get(cseObj.SYN_Prescriber__c).US_WSREMS__Status__c  != 'Certified') ? addValuesintoList(errorMessageList, 'Prescriber not Certified') : addValuesintoList(errorMessageList, '');
                    }
                    if(cseObj.US_WSREMS__REMS_Program__c != null && programMap.containsKey(cseObj.US_WSREMS__REMS_Program__c) && programMap.get(cseObj.US_WSREMS__REMS_Program__c) == Label.Macitentan_REMS_Program_Name && cseObj.US_WSREMS__DOB__c!= null){
                            Integer days = cseObj.US_WSREMS__DOB__c.daysBetween(Date.Today());
                            integer age = Integer.valueOf(days/365.22);
                            errorMessageList = (age < 18 && (String.isBlank(cseObj.Legal_Guardian_Name__c) || String.isBlank(cseObj.Legal_Guardian_Relationship__c) || String.isBlank(cseObj.Legal_Guardian_Phone__c) ) ) ? addValuesintoList(errorMessageList, SYN_Utilitycls.Legal_Guardian_ErrorMsg) : addValuesintoList(errorMessageList, '');
                    }
                }
                
            }
            //BT6825-46
            //BT6825-43
            else if(cseObj.RecordTypeId == pccRecordTypeId){
                if((cseObj.SYN_Please_select_one_of_the_following__c == 'New') || (cseObj.SYN_Please_select_one_of_the_following__c == 'Restart')){
                    
                    errorMessageList = (String.isBlank(cseObj.SYN_Dose_1_Grams__c)) ? addValuesintoList(errorMessageList, 'Dose 1 Grams') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (String.isBlank(cseObj.SYN_Dose_2_Grams__c)) ? addValuesintoList(errorMessageList, 'Dose 2 Grams') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (String.isBlank(cseObj.SYN_Step_2_Pharmacist_Name__c)) ? addValuesintoList(errorMessageList, 'Step 2. Pharmacist Name') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.SYN_Step_2_Date_and_Time__c == null) ? addValuesintoList(errorMessageList, 'Step 2. Date and Time') : addValuesintoList(errorMessageList, '');
                }    
                    // Added the condition so that this validation will skip for the portal user for BT6825-456,
                // because there is a conflict between the field placements to validate
                if(UserInfo.getUserType() != 'PowerCustomerSuccess' && ( cseObj.SYN_Please_select_one_of_the_following__c == 'New' || cseObj.SYN_Please_select_one_of_the_following__c == 'Restart' || cseObj.Medication_Type__c != Null || cseObj.Medical_Conditions__c != Null)){
                    
                    errorMessageList = (String.isBlank(cseObj.X1_Is_patient_taking_sedative_hypnotics__c)) ? addValuesintoList(errorMessageList, '1. Is patient taking sedative hypnotics?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X1_Is_patient_taking_sedative_hypnotics__c == 'Yes' && String.isBlank(cseObj.X1a_Counseled_Patient__c)) ? addValuesintoList(errorMessageList, '1a. Counseled patient?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X1_Is_patient_taking_sedative_hypnotics__c == 'Yes' && String.isBlank(cseObj.X1b_Please_list_the_drug_s_and_doses__c)) ? addValuesintoList(errorMessageList, '1b. Please list the drug(s) and doses:') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (String.isBlank(cseObj.X2_Patient_taking_sedating_antidepressan__c)) ? addValuesintoList(errorMessageList, '2. Taking sedating antidepressants?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X2_Patient_taking_sedating_antidepressan__c == 'Yes' && String.isBlank(cseObj.X2a_Counseled_Patient__c)) ? addValuesintoList(errorMessageList, '2a. Counseled patient?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X2_Patient_taking_sedating_antidepressan__c == 'Yes' && String.isBlank(cseObj.X2b_Please_list_the_drug_s_and_doses__c)) ? addValuesintoList(errorMessageList, '2b. Please list the drug(s) and doses:') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (String.isBlank(cseObj.X4_Drink_alcohol__c)) ? addValuesintoList(errorMessageList, '4. Drink alcohol?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X4_Drink_alcohol__c == 'Yes' && String.isBlank(cseObj.X4a_Counseled_Patient__c)) ? addValuesintoList(errorMessageList, '4a. Counseled patient?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (String.isBlank(cseObj.X5_Sleep_Apena__c)) ? addValuesintoList(errorMessageList, '5. Patient diagnosed with sleep apnea?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X5_Sleep_Apena__c == 'Yes' && String.isBlank(cseObj.X5a_Counseled_Patient__c)) ? addValuesintoList(errorMessageList, '5a. Counseled patient?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (String.isBlank(cseObj.X6_Affect_breathing__c)) ? addValuesintoList(errorMessageList, '6. Affect breathing?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X6_Affect_breathing__c =='Yes' && String.isBlank(cseObj.X6a_Counseled_Patient__c)) ? addValuesintoList(errorMessageList, '6a. Counseled patient') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X6_Affect_breathing__c =='Yes' && String.isBlank(cseObj.X6b_Please_list_the_drug_s_and_doses__c)) ? addValuesintoList(errorMessageList, '6b. Please list the drug(s) and doses:') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (String.isBlank(cseObj.X7_Other_medical_conditions__c)) ? addValuesintoList(errorMessageList, '7. Other medical conditions?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X7_Other_medical_conditions__c == 'Yes' && String.isBlank(cseObj.X7a_Counseled_Patient__c)) ? addValuesintoList(errorMessageList, '7a. Counseled patient?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X7_Other_medical_conditions__c == 'Yes' && String.isBlank(cseObj.X7b_Please_list_the_condition_s__c)) ? addValuesintoList(errorMessageList, '7b. Please list the condition(s):') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (String.isBlank(cseObj.X8_Questions_about_Sodium_Oxybate__c)) ? addValuesintoList(errorMessageList, '8. Questions about sodium oxybate?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X8_Questions_about_Sodium_Oxybate__c == 'Yes' && String.isBlank(cseObj.X8a_Counseled_Patient__c)) ? addValuesintoList(errorMessageList, '8a. Counseled patient') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X8_Questions_about_Sodium_Oxybate__c == 'Yes' && String.isBlank(cseObj.X8b_Please_list_question_s__c)) ? addValuesintoList(errorMessageList, '8b. Please list question(s):') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (String.isBlank(cseObj.Step_3_Pharmacist_Name__c)) ? addValuesintoList(errorMessageList, 'Step 3. Pharmacist Name') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X3_Date_and_Time__c == Null) ? addValuesintoList(errorMessageList, 'Step 3. Date and Time') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (String.isBlank(cseObj.Prescriber_Consult__c)) ? addValuesintoList(errorMessageList, '11. Is a prescriber consult required?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.Prescriber_Consult__c == 'No' && String.isBlank(cseObj.If_no_provide_reason__c)) ? addValuesintoList(errorMessageList, '11a. If no, provide reason') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.Prescriber_Consult__c == 'Yes' && cseObj.X1_Called_prescriber_Date__c == Null) ? addValuesintoList(errorMessageList, '11b. If yes, called prescriber') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.Prescriber_Consult__c == 'Yes' && String.isBlank(cseObj.X4_Name_of_Prescriber__c)) ? addValuesintoList(errorMessageList, '12. Name of prescriber consulted:') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.Prescriber_Consult__c == 'Yes' && String.isBlank(cseObj.Prescriber_NPI_or_DEA__c)) ? addValuesintoList(errorMessageList, '13. Prescriber NPI or DEA') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.Prescriber_Consult__c == 'Yes' && String.isBlank(cseObj.Prescriber_Consult_Outcome__c)) ? addValuesintoList(errorMessageList, '14. Prescriber consult outcome:') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (String.isBlank(cseObj.X4_Pharmacist_Name__c)) ? addValuesintoList(errorMessageList, 'Step 4. Pharmacist Name') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X4_Date_and_Time__c == Null) ? addValuesintoList(errorMessageList, 'Step 4. Date and Time') : addValuesintoList(errorMessageList, '');
                }
                
                errorMessageList = ((String.isBlank(cseObj.Checklist_Complete__c) || cseObj.Checklist_Complete__c == 'No') && cseObj.US_WSREMS__Program_Picklist__c != Label.Macitentan_REMS_Program_Name) ? addValuesintoList(errorMessageList, '15. Checklist Completed:') : addValuesintoList(errorMessageList, '');
                errorMessageList = ((cseObj.Checklist_Complete__c == 'Yes' && cseObj.If_yes_date_complete__c == null)) ? addValuesintoList(errorMessageList, '15a. If yes, date checklist completed:') : addValuesintoList(errorMessageList, '');
                if(UserInfo.getUserType() != 'PowerCustomerSuccess'){ // Added this condition for BT6825-456 as this field is not available on the flow
                    errorMessageList = (cseObj.Checklist_Complete__c == 'No' && String.isBlank(cseObj.If_no_reason__c)) ? addValuesintoList(errorMessageList, '15b. If no, reason') : addValuesintoList(errorMessageList, '');
                }
                errorMessageList = (String.isBlank(cseObj.X5_Pharmacist_Name__c) && cseObj.US_WSREMS__Program_Picklist__c != Label.Macitentan_REMS_Program_Name) ? addValuesintoList(errorMessageList, 'Step 5. Pharmacist Name') : addValuesintoList(errorMessageList, '');
                errorMessageList = (cseObj.X5_Date_and_Time__c == null) ? addValuesintoList(errorMessageList, 'Step 5. Date and Time') : addValuesintoList(errorMessageList, '');
                errorMessageList = (cseObj.US_WSREMS__Program_Picklist__c == Label.SYN_SOX_REMS_Program_Name && cseObj.US_WSREMS__Signature__c == 'No') ? addValuesintoList(errorMessageList, 'Signature') : addValuesintoList(errorMessageList, '');
                errorMessageList = (cseObj.Counseling_Recorded__c == false && cseObj.US_WSREMS__Patient_Risk_Category__c == 'Female of Reproductive Potential (FRP)' && cseObj.US_WSREMS__Program_Picklist__c == Label.Macitentan_REMS_Program_Name) ? addValuesintoList(errorMessageList, 'Counseling Recorded?') : addValuesintoList(errorMessageList, '');
            }
            //BT6825-43
            //BT6825-222
            else if(cseObj.RecordTypeId == PAERecordTypeId){
                if(cseObj.SYN_Patient_Name_Unknown__c == True){
                    errorMessageList = (String.isBlank(cseObj.SYN_Gender__c) && cseObj.US_WSREMS__Program_Picklist__c != Label.Macitentan_REMS_Program_Name) ? addValuesintoList(errorMessageList, 'Gender') : addValuesintoList(errorMessageList, '');
                    if(cseObj.US_WSREMS__REMS_Program__c != null && programMap.containsKey(cseObj.US_WSREMS__REMS_Program__c) && programMap.get(cseObj.US_WSREMS__REMS_Program__c) != Label.Macitentan_REMS_Program_Name)
                    errorMessageList = (String.isBlank(cseObj.SYN_Age_Range__c)) ? addValuesintoList(errorMessageList, 'Age Range') : addValuesintoList(errorMessageList, '');
                   
                    else{
                        errorMessageList = addValuesintoList(errorMessageList, '');
                    }
    
                }

               
            } //BT6825-222
            //BT6825-52
            else if(cseObj.RecordTypeId == caseRDARCTyId){
                if(cseObj.REMS_Project_Code__c != Label.MACIProgramProjectCode){ //MACI-RDA
                    
                    errorMessageList = (cseObj.Pharmacy_Status__c != 'Certified') ? addValuesintoList(errorMessageList, 'Pharmacy must be Certified') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X4_Received_dispense_of_oxybate_product__c == 'Yes' && cseObj.X4a_What_was_the_most_recent_fill_date__c == null) ? addValuesintoList(errorMessageList, '4a. What was the most recent fill date?') : addValuesintoList(errorMessageList, '');
                    errorMessageList = (cseObj.X4_Received_dispense_of_oxybate_product__c == 'Yes' && cseObj.X4b_Days_supply_of_last_dispance__c == null) ? addValuesintoList(errorMessageList, '4b. Days supply of last dispense?') : addValuesintoList(errorMessageList, '');
                }else if(cseObj.REMS_Project_Code__c == Label.MACIProgramProjectCode){ //MACI-RDA
                    
                } //MACI RDA.
            }//BT6825-52
            else if(cseObj.RecordTypeId == prescriberEnrollmentRecordTypeId) {
                errorMessageList = (cseObj.REMS_Project_Code__c == Label.MACIProgramProjectCode && cseObj.Professional_Designation__c == null) ? addValuesintoList(errorMessageList, 'Professional Designation') : addValuesintoList(errorMessageList, '');
                errorMessageList = (cseObj.US_WSREMS__Program_Picklist__c == Label.SYN_SOX_REMS_Program_Name && cseObj.US_WSREMS__Signature__c == 'No') ? addValuesintoList(errorMessageList, 'Signature') : addValuesintoList(errorMessageList, '');
            } 
            /** Start - BT6825-907 ***/
            else if(cseObj.RecordTypeId == distributorEnrollmentRecordTypeId) {
                errorMessageList = (cseObj.US_WSREMS__Program_Picklist__c == Label.SYN_SOX_REMS_Program_Name && cseObj.US_WSREMS__Signature__c == 'No') ? addValuesintoList(errorMessageList, 'Signature') : addValuesintoList(errorMessageList, '');
            } 
            else if(cseObj.RecordTypeId == pharmacyEnrollmentRecordTypeId) {
                errorMessageList = (cseObj.US_WSREMS__Program_Picklist__c == Label.SYN_SOX_REMS_Program_Name && cseObj.US_WSREMS__Signature__c == 'No') ? addValuesintoList(errorMessageList, 'Signature') : addValuesintoList(errorMessageList, '');
            } 
            /** End - BT6825-907 ***/
            //If signature is No, then the signature field has to be shown in the incomplete reasons field for MACI
            if(cseObj.US_WSREMS__Signature__c == 'No' && cseObj.US_WSREMS__Program_Picklist__c == Label.Macitentan_REMS_Program_Name && (cseObj.RecordTypeId == prescriberEnrollRectypeId || cseObj.RecordTypeId == prescriberReenrollRectypeId || 
            cseObj.RecordTypeId == casePatientEnrolRCTyId || cseObj.RecordTypeId == casePatientReEnrolRCTyId || 
            cseObj.RecordTypeId == distributorEnrollmentRecordTypeId || cseObj.RecordTypeId == distributorReEnrollmentRecordTypeId || 
            cseObj.RecordTypeId == inPatpharmacyEnrollmentRecordTypeId || cseObj.RecordTypeId == inPatpharmacyReEnrollmentRecordTypeId || 
            cseObj.RecordTypeId == outPatpharmacyEnrollmentRecordTypeId || cseObj.RecordTypeId == outPatpharmacyReEnrollmentRecordTypeId)){
             errorMessageList = cseObj.US_WSREMS__Signature__c == 'No' ? addValuesintoList(errorMessageList, 'Signature') : addValuesintoList(errorMessageList, '');
            }
            if(cseObj.SYN_Prescriber_Signature__c == 'No' && cseObj.US_WSREMS__Program_Picklist__c == Label.Macitentan_REMS_Program_Name && 
            (cseObj.RecordTypeId == changeInREproPotenRecordTypeId || cseObj.RecordTypeId == casePatientEnrolRCTyId || cseObj.RecordTypeId == casePatientReEnrolRCTyId) ){
             errorMessageList = cseObj.SYN_Prescriber_Signature__c == 'No' ? addValuesintoList(errorMessageList, 'Prescriber Signature') : addValuesintoList(errorMessageList, '');
            }
            if(crpsCaseID.contains(cseObj.id)){
                String patientRsikCategory=PatientRiskCatMap.get(cseObj.US_WSREMS__Patient__c);
             if( String.isBlank(cseObj.Reason_for_change_in_classification__c) && cseObj.US_WSREMS__Program_Picklist__c == Label.Macitentan_REMS_Program_Name && cseObj.RecordTypeId == changeInREproPotenRecordTypeId ){                     
                 errorMessageList = (cseObj.US_WSREMS__Patient_Risk_Category__c != patientRsikCategory) ? addValuesintoList(errorMessageList, 'Reason for change in classification') : addValuesintoList(errorMessageList, '');
            }
            }
            if ( errorMessageList.size() == 0 && cseObj.Status  != COMPLETESTATUS && cseObj.US_WSREMS__Program_Picklist__c == Label.Macitentan_REMS_Program_Name){
                cseObj.Incomplete_Reasons__c = '';
                if(cseObj.US_WSREMS__Signature__c == 'No' || cseObj.SYN_Prescriber_Signature__c == 'No'){ //BT7433-444
                        cseObj.Status = 'Draft';
                }else{
                    system.debug('cseObj.RecTypeId'+cseObj.RecordTypeId);
                    system.debug('cseObj.Status975'+cseObj.Status);
                    cseObj.Status = CompleteStatus;
                  cseObj.Incomplete_Reasons__c = '';                  
                    system.debug('cseObj.Status978'+cseObj.Status);
                }
                }
            if ( errorMessageList.size() == 0  && cseObj.Status  != CompleteStatus  && cseObj.US_WSREMS__Program_Picklist__c == Label.Sodium_Oxybate_REMS_Program_Name ){
                if(((mapCaseRecordTypesById.get(cseObj.RecordTypeId).getDeveloperName() == 'Pharmacy_Enrollment' || mapCaseRecordTypesById.get(cseObj.RecordTypeId).getDeveloperName() == 'Pharmacy_Reenrollment') && cseObj.SYN_DEA_Validation__c == 'Invalid') ||((mapCaseRecordTypesById.get(cseObj.RecordTypeId).getDeveloperName() == 'Prescriber_enrollment'|| mapCaseRecordTypesById.get(cseObj.RecordTypeId).getDeveloperName() == 'Prescriber_Reenrollment') && (cseObj.SYN_DEA_Validation__c == 'Invalid' || cseObj.NPI_Status__c  == 'Invalid'))){
                    cseObj.Status = cseObj.Status == 'Cancelled'?'Cancelled':'Draft'; //if condition BT7433-776
                }
               //Adding for RMR when status is draft and no validations automatically it will close status and outcome 895
               else if (mapCaseRecordTypesById.get(cseObj.RecordTypeId).getDeveloperName() == 'Risk_Management_Report'){
                    cseObj.Status = CompleteStatus;
                    cseObj.US_WSREMS__Outcome__c = CompleteStatus;
             }
             else if(errorMessageList.size() == 0 && (cseObj.RecordTypeId == pharmacyEnrollRectypeID || cseObj.RecordTypeId == prescriberEnrollRectypeId || cseObj.RecordTypeId == prescriberReenrollRectypeId || cseObj.RecordTypeId == prescriberCOIRectypeId || cseObj.RecordTypeId == phrmcyPartiCOIRectypeId || cseObj.RecordTypeId == KKARectypeId || cseObj.RecordTypeId == KKBRectypeId) && (presEnrollEmailMatch == true || presReEnrollEmailMatch == true || pharmpartiEnrollEmailMatch == true || presCOIEmailMatch == true || pharmPartiCOIEmailMatch == true || kAAEmailMatch == true || kABEmailMatch == true) ){
                    system.debug('cseobj.Status-988-B-'+cseObj.Status);
                cseObj.Status = cseObj.Status;
                    system.debug('cseobj.Status-988-A-'+cseObj.Status);
            }
                else{
                    system.debug('991-B-'+cseObj.Status);
                    cseObj.Status = CompleteStatus;
                    system.debug('991-A-'+cseObj.Status);
                }
                if(programMap.containsKey(cseObj.US_WSREMS__REMS_Program__c) && programMap.get(cseObj.US_WSREMS__REMS_Program__c) == Label.Sodium_Oxybate_REMS_Program_Name && cseObj.RecordTypeId != PAERecordTypeId && cseObj.RecordtypeId != caseRDARCTyId)
                cseObj.Incomplete_Reason__c = '';
                
            }else if (errorMessageList.size() > 0  && (cseObj.Status  == CompleteStatus || cseObj.Status == 'Draft')){
                
                if(cseObj.US_WSREMS__REMS_Program__c != null && programMap != null && !programMap.isEmpty() && programMap.containsKey(cseObj.US_WSREMS__REMS_Program__c) && programMap.get(cseObj.US_WSREMS__REMS_Program__c) == Label.Sodium_Oxybate_REMS_Program_Name){
                    if(cseObj.Status == CompleteStatus) {

                        String errMsg = String.valueOf(errorMessageList);
                        errMsg = errMsg.substring(1, errMsg.length()-1);

                        //Below conditions are added for 895 RMR only :Ashish Y
                        //Added condition RMR and Due Dilligence 
                        If(mapCaseRecordTypesById.get(cseObj.RecordTypeId).getDeveloperName() == 'Risk_Management_Report' &&
                           cseObj.US_WSREMS__Outcome__c != 'Due Dilligence Exhausted'){
                            
                            cseObj.addError(customValidationMap.get(uniqueKey).ErrorMsg__c+': '+errMsg); 
                        } //End of inner if 
                        else if(mapCaseRecordTypesById.get(cseObj.RecordTypeId).getDeveloperName() != 'Risk_Management_Report'){

                            cseObj.addError(customValidationMap.get(uniqueKey).ErrorMsg__c+': '+errMsg); 
                        }
                        //End of else if 
                          
                    } //End of completstatus if                   
                    if(cseObj.Status == 'Draft' && cseObj.RecordTypeId != PAERecordTypeId && cseObj.RecordtypeId != caseRDARCTyId ){
                        if(presEnrollEmailMatch == true || presReEnrollEmailMatch == true || pharmpartiEnrollEmailMatch == true){
                        String errMsg = '';
                        for(String str : errorMessageList) {
                            errMsg += str;
                            errMsg += ';';
                        }
                            errMsg += emailMatchPicklistValue+ ';';
                        cseObj.Incomplete_Reason__c = errMsg;
                            
                        }else {
                        String errMsg = '';
                        for(String str : errorMessageList) {
                            errMsg += str;
                            errMsg += ';';
                        }
                        cseObj.Incomplete_Reason__c = errMsg;
                        }
                        
                    }
                    
                }else if(cseObj.US_WSREMS__REMS_Program__c != null  && errorMap.containsKey(uniqueKey)){
                    if(cseObj.Status == CompleteStatus) {
                        String errMsg = String.valueOf(errorMessageList);
                        errMsg = errMsg.substring(1, errMsg.length()-1);
                        cseObj.addError(errorMap.get(uniqueKey)+': '+errMsg); 
                    }
                    
                    if(cseObj.Status == 'Draft' && programMap.get(cseObj.US_WSREMS__REMS_Program__c) == Label.Sodium_Oxybate_REMS_Program_Name && cseObj.RecordTypeId != PAERecordTypeId && cseObj.RecordtypeId != caseRDARCTyId ) {
                        String errMsg = '';
                        for(String str : errorMessageList) {
                            errMsg += str;
                            errMsg += ';';
                        }
                        cseObj.Incomplete_Reason__c = errMsg;
                        //casesListTobeUpdated.add(c);
                    }
                    else if(cseObj.Status == 'Draft'){
                        String errMsg = '';
                        for(String str : errorMessageList) {
                            errMsg += str;
                            errMsg += ';';
                        }
                        if(errMsg != null){
                            cseObj.Incomplete_Reasons__c = errMsg.removeEnd(';');
                            if(cseObj.US_WSREMS_Original_Incomplete_Reasons__c==null){
                                cseObj.US_WSREMS_Original_Incomplete_Reasons__c = errMsg.removeEnd(';');
                            }
                        }else{
                            cseObj.Incomplete_Reasons__c = '';
                        }
                    }
                    else if(cseObj.Status == 'Complete'){
                        cseObj.Incomplete_Reasons__c = '';
                    }
                }
            }
            if(errorMessageList.size() == 0  && cseObj.Status  == CompleteStatus  && cseObj.US_WSREMS__Program_Picklist__c == Label.Sodium_Oxybate_REMS_Program_Name && (cseObj.RecordTypeId == pharmacyEnrollRectypeID || cseObj.RecordTypeId == prescriberEnrollRectypeId || cseObj.RecordTypeId == prescriberReenrollRectypeId
                || cseObj.RecordTypeId == prescriberCOIRectypeId || cseObj.RecordTypeId == phrmcyPartiCOIRectypeId || cseObj.RecordTypeId == KKARectypeId || cseObj.RecordTypeId == KKBRectypeId)){
                if(presEnrollEmailMatch == true || presReEnrollEmailMatch == true || pharmpartiEnrollEmailMatch == true || presCOIEmailMatch == true || pharmPartiCOIEmailMatch == true || kAAEmailMatch == true || kABEmailMatch == true){
                   cseObj.addError('The case cannot be saved as complete because the email address matches an existing account.') ;
                }
                else if(presEnrollEmailMatch == false || presReEnrollEmailMatch == false || pharmpartiEnrollEmailMatch == false){
                   if(cseObj.Incomplete_Reason__c != null){
                       cseObj.Incomplete_Reason__c = '';
                    } 
                }
            }
            if(errorMessageList.size() == 0  && cseObj.Status  == 'Draft'  && cseObj.US_WSREMS__Program_Picklist__c == Label.Sodium_Oxybate_REMS_Program_Name && (cseObj.RecordTypeId == pharmacyEnrollRectypeID || cseObj.RecordTypeId == prescriberEnrollRectypeId || cseObj.RecordTypeId == prescriberReenrollRectypeId)){
                if(presEnrollEmailMatch == true || presReEnrollEmailMatch == true || pharmpartiEnrollEmailMatch == true){
                   if(cseObj.Incomplete_Reason__c != null){
                            Set<String> existingValues = new Set<String>(cseObj.Incomplete_Reason__c.split(';'));
                            existingValues.add(emailMatchPicklistValue);
                            cseObj.Incomplete_Reason__c = String.join(new List<String>(existingValues), ';');
                    }
                    else{
                       Set<String> existingValues = new Set<String>();
                            existingValues.add(emailMatchPicklistValue);
                            cseObj.Incomplete_Reason__c = String.join(new List<String>(existingValues), ';'); 
                    }
                }
                else if(presEnrollEmailMatch == false || presReEnrollEmailMatch == false || pharmpartiEnrollEmailMatch == false){
                   if(cseObj.Incomplete_Reason__c != null){
                            Set<String> existingValues = new Set<String>(cseObj.Incomplete_Reason__c.split(';'));
                            existingValues.remove(emailMatchPicklistValue);
                            cseObj.Incomplete_Reason__c = String.join(new List<String>(existingValues), ';');
                    } 
                }
                
                // cseObj.Incomplete_Reason__c = '';
            }
          
        } 
    }
    
    private static Map<string, Object_validation_and_status_automation__mdt> createCustomValidationMap(String ObjectAPI){
        Map<string, Object_validation_and_status_automation__mdt > customValidationMap = new map<String, Object_validation_and_status_automation__mdt>();
        
        for (Object_validation_and_status_automation__mdt objVaL_mdt : [select ObjectAPIName__c , Object_recordType_DevName__c ,Rems_Service_RCtype__c , Required_fields__c, ErrorMsg__c  
                                                                        from Object_validation_and_status_automation__mdt 
                                                                        where ObjectAPIName__c =: ObjectAPI and IsActive__c = true]){
                                                                            String uniqueKeyStr = objVaL_mdt.Object_recordType_DevName__c+'$$'+objVaL_mdt.Rems_Service_RCtype__c;
                                                                            customValidationMap.put(uniqueKeyStr, objVaL_mdt);                                                            
                                                                        }
        return customValidationMap;
    }
    
    public static void handleAfterUpdate(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
        
        updateStakeHolderAccounts(newCaseMap, oldCaseMap);    
    }
    
    public static void updateStakeHolderAccounts(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
        
        Set<String> accountCaseRecordTypes = new Set<String>{
            'Pharmacy_Account','Prescriber_Person_Account','Prescribing_Institution_Account','Pharmacy_Participant_Account','SYN_Patient_Person_Account',
                'General_Contact','REMS_Distributor_Account'
                };
                    
                    List<Case> filteredCases = new List<Case>();
        for(Case caseRec : newCaseMap.values()){
            
            String caseRecTypeDevName = mapCaseRecordTypesById.get(caseRec.RecordTypeId).getDeveloperName();
            if(accountCaseRecordTypes.contains(caseRecTypeDevName) && caseRec.US_WSREMS__REMS_Program__c != null && caseRec.US_WSREMS__Program_Name__c == Label.Sodium_Oxybate_REMS_Program_Name){
                
                filteredCases.add(caseRec); 
            }
        }
        
        if(!filteredCases.isEmpty()){
            
            
            List<Account> accListToInsert = New List<Account>();
            Account stakeHolderAccount = new Account();      
            Id prescriberCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_Person_Account').getRecordTypeId();        
            Id presInstrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution').getRecordTypeId();        
            Map<String,String> sourceAndTargetFieldMapping = new Map<String,String>();
            Map<String,Object> CaseFieldsVsValuesMap = New Map<String,Object>();
            Map<String,Object> AccFieldsAPIVsCaseFieldValuesMap = New Map<String,Object>(); //Not used yet        
            Map<String,Id> mapofCaseRecordTypeNameandId = RemsPagelayoutComponent.getAllRecordTypeDetailsById('Case'); //Not used yet
            Map<String,Id> mapofAccountRecordTypeNameandId = RemsPagelayoutComponent.getAllRecordTypeDetailsById('Account');        
            Map<Id,String> mapofCaseRecordTypeIdandName = RemsPagelayoutComponent.getAllRecordTypeDetailsByName('Case');
            Map<Id,String> mapofAccountRecordTypeIdandName = RemsPagelayoutComponent.getAllRecordTypeDetailsByName('Account'); //Not used yet        
            Map<String,String> mapofCaseRecordTypeNameVSAccName = New Map<String,String>();
            
            List<SYNRecordTypeConfig__mdt> recordTypes = New List<SYNRecordTypeConfig__mdt>(
                [SELECT Source_Record_Type__c,Target_Record_Type__c FROM SYNRecordTypeConfig__mdt]
            );
            
            List<SYN_FieldMapping_Config__mdt> fieldMappingList = getSourceAndTargetFieldMapping();        
            Map<String, Map<String, String>> recordTypeAndFieldMapping = new Map<String, Map<String, String>>();
            
            for(SYNRecordTypeConfig__mdt rec : recordTypes){
                
                mapofCaseRecordTypeNameVSAccName.put(rec.Source_Record_Type__c, rec.Target_Record_Type__c);
            }        
            
            for(SYN_FieldMapping_Config__mdt fm : fieldMappingList){
                
                if(!recordTypeAndFieldMapping.containsKey(fm.Source_RecordType_Name__c)){
                    
                    recordTypeAndFieldMapping.put(fm.Source_RecordType_Name__c, new Map<String, String>());
                }
                
                Map<String, String> tempMap = recordTypeAndFieldMapping.get(fm.Source_RecordType_Name__c);                            
                tempMap.put(fm.Source_Field__c, fm.Target_Field__c);
                recordTypeAndFieldMapping.put(fm.Source_RecordType_Name__c, tempMap);
            } 
            
            for(Case cs: filteredCases){
                
                stakeHolderAccount = New Account();
                
                if(cs.US_WSREMS__Participant__c != NULL ){
                    
                    stakeHolderAccount.Id = cs.US_WSREMS__Participant__c;
                    
                    CaseFieldsVsValuesMap = New Map<String,Object>();
                    String recDevName = mapofCaseRecordTypeIdandName.get(cs.RecordTypeId);
                    sourceAndTargetFieldMapping = recordTypeAndFieldMapping.get(recDevName);
                    for(String cs1 : sourceAndTargetFieldMapping.keySet()){
                        
                        CaseFieldsVsValuesMap.put(cs1, cs.get(cs1));                
                    }
                    
                    for(String cs1 : sourceAndTargetFieldMapping.keySet()){
                        
                        stakeHolderAccount.put(sourceAndTargetFieldMapping.get(cs1), CaseFieldsVsValuesMap.get(cs1));
                    }
                    
                    
                    
                    if((cs.RecordTypeId == prescriberCaseRecordTypeId) ){                    
                        
                        stakeHolderAccount.ShippingStreet = cs.US_WSREMS__Address_Line_1__c;
                        stakeHolderAccount.SYN_Shipping_Address_2__c = cs.US_WSREMS__Address_Line_2__c;
                        stakeHolderAccount.ShippingCity=cs.US_WSREMS__City__c;
                        stakeHolderAccount.ShippingState = cs.US_WSREMS__State__c;
                        stakeHolderAccount.ShippingPostalCode=cs.SYN_Zip_Code__c;
                        stakeHolderAccount.ShippingCountry=cs.SYN_Country__c;
                        stakeHolderAccount.Phone = cs.US_WSREMS__Phone__c;
                        stakeHolderAccount.FAX = cs.US_WSREMS__Fax__c;
                        stakeHolderAccount.SYN_Ext__c = cs.SYN_Ext__c;
                        stakeHolderAccount.US_WSREMS__Email__c = cs.US_WSREMS__Email__c;
                        stakeHolderAccount.US_WSREMS__Preferred_Contact_Method__c = cs.US_WSREMS__Preferred_Contact_Method__c;
                    }                     
                    accListToInsert.add(stakeHolderAccount);
                }
            }
            
            if(!accListToInsert.isEmpty()){
                
                List<Database.SaveResult> accInserted = Database.update(accListToInsert, false);      
            }           
        }        
    }
    public static List<SYN_FieldMapping_Config__mdt> getSourceAndTargetFieldMapping(){
        
        return [
            SELECT Source_Field__c, Source_Object__c,Source_RecordType_Name__c,Target_Field__c,Target_Object__c,
            Target_RecordType_Name__c
            FROM SYN_FieldMapping_Config__mdt 
            WHERE Account_Creation__c = True
        ];
    }
    
    public static void completeCasestatusOnUpdate(List<Case> newList , Map<Id,Case> oldMap){
        Set<Id> ParticipantIdLst = new Set<Id>();
        List<case> caseToAffiliations_Lst = new List<Case>();
        List<Account> accountMonthlyPregnancyList = new List<Account>();
        List<case> patientPregnancyRDAList = new List<Case>();
        List<case> patientCounsellingRDAList = new List<Case>();
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        Id patientReenrollCaseRecTypeId =  caseRecordTypeMap.get('Patient_Reenrollment');
        Id patientEnrollCaseRecordTypeId =  caseRecordTypeMap.get('Patient_Enrollement');
        Id patientPregnancyTestCaseRecordTypeId = caseRecordTypeMap.get('Patient_Pregnancy_Test');
        Id patientcounsellingRecordTypeId = caseRecordTypeMap.get('Patient_Counseling_Checklist');
        Id caseRDARecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();
        Id programId= SYN_CommonUtility.MACIprogramId();
		Id caseCRPSRecordTypeId = caseRecordTypeMap.get('Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');
        if(caseCRPSRecordTypeId == Null){
        caseCRPSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification').getRecordTypeId();
        
        }
        Set<Id> pharmacyId = new Set<Id>(); 
        String MisclassificationRP='Misclassification Review Pending';
        String Misclassification='Misclassification';
        Map<Id,Account> pharmacyMap;
        Map<Id,String> mapPharmaParToARcat = new Map<Id,String>();
        Map<Id,Id> mapPharmacyToParticipant = new Map<Id,Id>();
        Map<String,Case> mapPharmaParToCase = new Map<String,Case>();
        Set<String> participantCreationCase = new Set<String>{
            'SYN_Distributor_Account','General_Contact','SYN_Patient_Person_Account','Pharmacy_Account','Pharmacy_Participant_Account',
                'Prescriber_Person_Account','Prescribing_Institution_Account'
                };                  
                    
                    for (case cse : newList){
                        if( cse.RecordTypeId == caseRDARecordTypeId && cse.US_WSREMS__Outcome__c =='Approved'){
                            if(cse.US_WSREMS__Pharmacy__c != null){
                                pharmacyId.add(cse.US_WSREMS__Pharmacy__c);
                            }
                            if(cse.US_WSREMS__Patient__c != null){
                                pharmacyId.add(cse.US_WSREMS__Patient__c);
                            }
                        }   
                    }
                    if(!pharmacyId.isEmpty()){
                     pharmacyMap=new Map<Id,Account>([select Id,Program_Name__c,US_WSREMS__REMS_Program__c,US_WSREMS__DOB__c,Patient_Reproductive_Status_Date__c,Monthly_Pregnancy_Test_Recorded__c,Counseling_Recorded__c from Account where Id IN :pharmacyId]);  
                    }
                    for (case cse : newList){
                        if(oldMap != null && cse.Status != oldMap.get(cse.id).Status && cse.Status == 'Complete'  && !String.isBlank(cse.US_WSREMS__Participant__c) && participantCreationCase.contains(mapCaseRecordTypesById.get(cse.RecordTypeId).getDeveloperName()) ){
                            ParticipantIdLst.add(cse.US_WSREMS__Participant__c);
                        }
                        if( cse.Status == 'Complete' && (oldMap == null || oldMap.get(cse.Id).Status != 'Complete' ) && cse.US_WSREMS__Program_Picklist__c == 'Macitentan REMS'){
                            if (CaseenrollmentStr.contains( mapCaseRecordTypesById.get(cse.recordtypeId).getDeveloperName()) ){
                                caseToAffiliations_Lst.add(cse);
                            }
                            if (mapCaseRecordTypesById.get(cse.recordtypeId).getDeveloperName() == SYN_Utilitycls.Change_Authorized_Representative ){
                                mapPharmaParToARcat.put(cse.Pharmacy_Participant__c, cse.US_WSREMS__Primary_Authorized_Rep__c ? 'Primary' : 'Secondary');
                                mapPharmacyToParticipant.put(cse.US_WSREMS__Pharmacy__c, cse.Pharmacy_Participant__c);
                                mapPharmaParToCase.put(cse.US_WSREMS__Pharmacy__c+'-'+cse.Pharmacy_Participant__c , cse);
                            }
                            
                          

                        }

                        
                        if(cse.Status == 'Complete' && (oldMap == null || oldMap.get(cse.Id).Status != 'Complete' || oldMap.get(cse.Id).US_WSREMS__Outcome__c != cse.US_WSREMS__Outcome__c ) 
                           && cse.US_WSREMS__Program_Picklist__c == 'Macitentan REMS' && cse.US_WSREMS__Patient_Risk_Category__c == 'Female of Reproductive Potential (FRP)' && cse.US_WSREMS__Patient__c != null){  
                               
                            Account patientacc = new Account(Id =cse.US_WSREMS__Patient__c);           
                   System.debug('Creating patient acc with Id: ' + cse.US_WSREMS__Patient__c);
                   if(cse.US_WSREMS__Outcome__c =='Complete' && cse.RecordTypeId == patientEnrollCaseRecordTypeId){
                       System.debug('PatientEnrollCaseRecordTypeId block for case: ' + cse.Id);
                                    patientacc.Monthly_Pregnancy_Test_Recorded__c=cse.Negative_Pregnancy_Test_Completed__c;
                                    if(cse.Negative_Pregnancy_Test_Completed__c =='Yes'){
                                       patientacc.Monthly_Pregnancy_Test_Date__c=cse.SYN_Prescriber_Signature_Date__c;
                                    }else{
                                       patientacc.Monthly_Pregnancy_Test_Date__c=null;
                                    }
                                    accountMonthlyPregnancyList.add(patientacc);
                                }
                                
                            if((cse.US_WSREMS__Outcome__c =='Complete' || cse.US_WSREMS__Outcome__c =='Approved') && cse.RecordTypeId == patientReenrollCaseRecTypeId){                   
                                    patientacc.Monthly_Pregnancy_Test_Recorded__c=cse.Negative_Pregnancy_Test_Completed__c;
                                    if(cse.Negative_Pregnancy_Test_Completed__c =='Yes'){
                                       patientacc.Monthly_Pregnancy_Test_Date__c=cse.SYN_Prescriber_Signature_Date__c;
                                    }else{
                                       patientacc.Monthly_Pregnancy_Test_Date__c=null;
                                    }
                                    accountMonthlyPregnancyList.add(patientacc);
                                }
                               
                            if( cse.RecordTypeId == caseRDARecordTypeId && cse.US_WSREMS__Outcome__c =='Approved'){
                            
                                    US_WSREMS.REMSAvoidRecursiveCls.stop_caseUpdate = true; 
                                    US_WSREMS.REMSAvoidRecursiveCls.stop_accountUpdate = true; 
                                    US_WSREMS.REMSAvoidRecursiveCls.stop_TaskCreation= true; 
                                    US_WSREMS.REMSAvoidRecursiveCls.stop_AvoidCaseTaskTriggerActFieldUpdate= true; 
                                    
                                   Account pharmacyAccount =pharmacyMap.get(cse.US_WSREMS__Pharmacy__c);
                                   Account authRepAccount = new Account(Id =cse.Pharmacy_Participant__c);
                                   Account prescriberAccount = new Account(Id =cse.SYN_Prescriber__c);
                                   Account patientAccount = pharmacyMap.get(cse.US_WSREMS__Patient__c);
                                   
                                                                      
                            if(cse.Monthly_Pregnancy_Test_Recorded__c == true && (oldMap == null || oldMap.get(cse.Id).Monthly_Pregnancy_Test_Recorded__c != true) && patientAccount.Monthly_Pregnancy_Test_Recorded__c !='Yes' 
                                && cse.US_WSREMS__Channel__c != 'Portal' && cse.US_WSREMS__Channel__c != 'Migration'){
                                  patientPregnancyRDAList.add(cse);
                                }   
                            if(cse.Counseling_Recorded__c == true && (oldMap == null || oldMap.get(cse.Id).Counseling_Recorded__c != true) && patientAccount.Counseling_Recorded__c == false
                                && cse.US_WSREMS__Channel__c != 'Portal' && cse.US_WSREMS__Channel__c != 'Migration'){
                                  patientCounsellingRDAList.add(cse); 
                                }
                                if(cse.Counseling_Recorded__c == true && patientAccount.Counseling_Recorded__c == false){
                                    patientacc.Counseling_Completion_Date__c=System.today();
                                    patientacc.Counseling_Recorded__c=cse.Counseling_Recorded__c;
                                }
                                if(cse.Monthly_Pregnancy_Test_Recorded__c == true  && patientAccount.Monthly_Pregnancy_Test_Recorded__c != 'Yes'){
                                     patientacc.Monthly_Pregnancy_Test_Date__c=System.today();
                                }
                                
                                if(cse.Monthly_Pregnancy_Test_Recorded__c){
                                     patientacc.Monthly_Pregnancy_Test_Recorded__c='Yes';
                                    }else{
                                     patientacc.Monthly_Pregnancy_Test_Recorded__c='No';
                                   }
                                    accountMonthlyPregnancyList.add(patientacc);
                                }
                               
                            if(cse.RecordTypeId == patientPregnancyTestCaseRecordTypeId && cse.US_WSREMS__Outcome__c =='Complete'){                   
                                if(cse.Monthly_Pregnancy_Test_Recorded__c){
                                    patientacc.Monthly_Pregnancy_Test_Recorded__c='Yes';
                                   }else{
                                    patientacc.Monthly_Pregnancy_Test_Recorded__c='No';
                                   }
                                   patientacc.Monthly_Pregnancy_Test_Date__c=cse.Date_of_Confirmation__c;
                                   accountMonthlyPregnancyList.add(patientacc);
                               }
                               
                            if(cse.RecordTypeId == patientcounsellingRecordTypeId && cse.US_WSREMS__Outcome__c =='Complete'){                   
                                   patientacc.Counseling_Recorded__c=cse.Counseling_Recorded__c;
                                   patientacc.Counseling_Completion_Date__c=cse.Counseling_Completion_Date__c;
                                   accountMonthlyPregnancyList.add(patientacc);
                               }
                        }
                    }
        if (!ParticipantIdLst.isEmpty()){
            completeCasestatus(ParticipantIdLst);
        }
        
        if (!caseToAffiliations_Lst.isEmpty()){
            SYN_CaseTriggerHelper.AffiliationsbyCase(caseToAffiliations_Lst);
        }
        
        if (!patientPregnancyRDAList.isEmpty()){
            SYN_CaseTriggerHelper.patientPregnancyRDACase(patientPregnancyRDAList);
        }
        
        if (!patientcounsellingRDAList.isEmpty()){
            SYN_CaseTriggerHelper.patientCounsellingRDACase(patientCounsellingRDAList);
        }
        
        if(!accountMonthlyPregnancyList.isEmpty()){
            try{
               update accountMonthlyPregnancyList;
               }catch(exception e){
               system.debug('---MonthlyPregnancyError---'+e.getMessage());
            }
        }
        if (!mapPharmaParToARcat.keyset().isEmpty() && !mapPharmacyToParticipant.keyset().isEmpty()){
            SYN_CaseTriggerHelper.MACIChangeAuthRep(mapPharmaParToARcat, mapPharmacyToParticipant,mapPharmaParToCase);
        }
    }
    
    public static void completeCasestatus( Set<Id> ParticipantIdLst  ){
        List<US_WSREMS__REMS_Service_Summary__c> closeRemsServiceLst = new List<US_WSREMS__REMS_Service_Summary__c>();
        
        
        for ( US_WSREMS__REMS_Service_Summary__c  REMSS : [select id , US_WSREMS__StageName__c,US_WSREMS__Status__c,US_WSREMS__Path_Complete__c ,US_WSREMS__Path_Stage_Name__c  from US_WSREMS__REMS_Service_Summary__c where recordtypeId =: mapRemsRecordTypesByDeveloperName.get('Participant_Account_Creation').getRecordTypeId()
                                                           and US_WSREMS__Participant__c In: ParticipantIdLst ]){
                                                               //REMSS.US_WSREMS__StageName__c = 'closed'; 
                                                               REMSS.US_WSREMS__Path_Stage_Name__c  = 'closed';
                                                               REMSS.US_WSREMS__Status__c = 'closed';
                                                               REMSS.US_WSREMS__Service_Outcome__c = 'Successful';
                                                               REMSS.US_WSREMS__Path_Complete__c = true;
                                                               
                                                               closeRemsServiceLst.add(REMSS);            
                                                           }
        
        if (!closeRemsServiceLst.isEmpty() ){
            update closeRemsServiceLst;
        }
        
    }  
    
    //BT6825-91--->Affiliciation between prescriber status is certified case status will be complete.
    public static Map<Id, Account> checkPrescriberStatus(List<Case> newCases) {
        
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Account> accountsMap = new Map<Id,Account>();
        for(Case c  : newCases) {
            accountIds.add(c.SYN_Prescriber__c); 
        }
        accountsMap = new Map<Id,Account>([SELECT Id,Name, US_WSREMS__Status__c FROM Account WHERE Id IN:accountIds]);
        
        return accountsMap;
        
    }
   //377 getting phamacy Accounts
   public static Map<Id, Account> checkPharmacyStatus(List<Case> newCases) {
        
    Set<Id> accountIds = new Set<Id>();
    Map<Id,Account> accountsMap = new Map<Id,Account>();
    for(Case c  : newCases) {
        if(c.US_WSREMS__Pharmacy__c != null)
        accountIds.add(c.US_WSREMS__Pharmacy__c);
        if(c.Pharmacy_Participant__c != null)
        accountIds.add(c.Pharmacy_Participant__c);
    }
    accountsMap = new Map<Id,Account>([SELECT Id,Name, US_WSREMS__Status__c FROM Account WHERE Id IN:accountIds]);
    
    return accountsMap;
} //377
    // BT6825- 249 Change of Information.
    public static void ChangeOfInformation(Map<Id,Case> newCaseMap,Map<Id,Case> oldCaseMap){
        List<Id> CaseCOIRcTyIdLst = new List<Id>();
        Id programId= SYN_CommonUtility.SOXprogramId();
        Set<Id>SOXCOICaseIdSet = new Set<Id>();
        Set<Id>COICaseIdSet = new Set<Id>();
        Set<String> ChangeOfInfoCase = new Set<String>{
            'Distributor_COI','General_Contact_COI','Patient_COI','Pharmacy_COI','Pharmacy_Participant_COI',
                'Prescriber_COI','Prescribing_Institution_COI','MACI_Office_Contact_COI'
                };                  
                    for(string CaseRC : ChangeOfInfoCase){
                        CaseCOIRcTyIdLst.add(mapCaseRcTyByDevName.get(CaseRC).getRecordTypeId());
                    }
        for(case newCse : newCaseMap.values()){

            if(newCse.US_WSREMS__REMS_Program__c == programId)
            {
                if (CaseCOIRcTyIdLst.contains(newCse.RecordTypeId) && newCse.Status == 'Complete' && newCse.US_WSREMS__Outcome__c == 'Complete'){
                    SOXCOICaseIdSet.add(newCse.id);
                }
            }
            /*
            else{
                if(oldCaseMap != null)
                {
                if (CaseCOIRcTyIdLst.contains(newCse.RecordTypeId) && newCse.Status == 'Complete' && oldCaseMap.get(newCse.id).Status != newCse.Status ){
                    COICaseIdSet.add(newCse.id);
                   }
                }
            }
            */
            
        }
        if(!SOXCOICaseIdSet.isEmpty()){
        SYN_CaseTriggerHelper.updateAccount(newCaseMap, oldCaseMap, SOXCOICaseIdSet); 
        } 
        if(!COICaseIdSet.isEmpty()){
        SYN_CaseTriggerHelper.updateAccount(newCaseMap, oldCaseMap, COICaseIdSet);    
    }  
    }  
    // BT6825- 116 --> Affiliation between a patient and a precriber when a case is created from enrollment service.
    public static void patientAndPrescriberAffiliation(List<Case> newCases) {
        
        Id prescriberAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Id patientAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();  
        Id patientCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();
        Id patientAffiliationRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Patient_Affiliation').getRecordTypeId();
        
        List<US_WSREMS__Affiliation__c> affliationListToInsert = New List<US_WSREMS__Affiliation__c>();
        Set<Id> serviceIds = New Set<Id>();
        Map<Id,Id> serviceVSProgram = New Map<Id,Id>();
        
        for(case cs:newCases){
            serviceIds.add(cs.US_WSREMS__REMS_Service_Summary__c);
        }
        
        List<US_WSREMS__REMS_Service_Summary__c> remsServiceSummaryList = New List<US_WSREMS__REMS_Service_Summary__c>([SELECT Id,US_WSREMS__REMSProgram__c FROM US_WSREMS__REMS_Service_Summary__c WHERE ID IN: serviceIds]);
        if(remsServiceSummaryList.size()>0){
            for(US_WSREMS__REMS_Service_Summary__c rs:remsServiceSummaryList){
                serviceVSProgram.put(rs.Id,rs.US_WSREMS__REMSProgram__c);
            }
        }
        
        for(case cs:newCases){
            if(cs.RecordTypeId == patientCaseRecordTypeId && cs.SYN_Prescriber__c != null && cs.US_WSREMS__Patient__c != null){
                US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c(
                    US_WSREMS__Prescriber__c = cs.SYN_Prescriber__c,
                    US_WSREMS__Patient__c = cs.US_WSREMS__Patient__c,
                    US_WSREMS__REMSProgram__c = serviceVSProgram.get(cs.US_WSREMS__REMS_Service_Summary__c),
                    US_WSREMS__Start_Date__c = System.Today(),
                    US_WSREMS__isActive__c = TRUE,
                    US_WSREMS__REMS_Service__c = cs.US_WSREMS__REMS_Service_Summary__c,
                    RecordTypeId = patientAffiliationRecordTypeId
                ); 
                affliationListToInsert.add(affiliationRecord);  
            }
        }
        
        Database.SaveResult[] srList1 = Database.insert(affliationListToInsert, false);
        for (Database.SaveResult sr : srList1) {
            if (sr.isSuccess()) {
                // This condition will be executed for successful records and will fetch the ids 
                // of successful records
            } else {
                // This condition will be executed for failed records
                for(Database.Error objErr : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    // Printing error message in Debug log
                    System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                    System.debug('Invoice oject field which are affected by the error:' 
                                 + objErr.getFields());
                }
            }
        }
    }
    //BT6825-444
    //This is changed as per BT7433-2446
    public static void updateAccount(List<Case> cases,Map<Id,Case> oldMap){
        Map<Id,Case> mapcasePrescriberAccount=new Map<Id,Case>();
        Map<Id,Case> mapcasePatientAccount=new Map<Id,Case>();
        Map<Id,Case> mapcaseDistributorAccount=new Map<Id,Case>();
        Map<Id,Case> mapcasePharmacyAccount=new Map<Id,Case>();
        Map<Id,Case> mapcaseChangeAuthRep=new Map<Id,Case>();
        Map<Id,Case> mapReenrollCasePrescriberAccount = new Map<Id,Case>();
        Map<Id,Case> mapReenrollcasePatientAccount=new Map<Id,Case>();
        Map<Id,Case> mapReenrollcaseDistributorAccount=new Map<Id,Case>();
        Map<Id,Case> mapReenrollcasePharmacyAccount=new Map<Id,Case>();
        Map<Id,Case> mapcaseKAAPharmacyPartiAccount=new Map<Id,Case>();
        Map<Id,Case> mapcaseKABPharmacyPartiAccount=new Map<Id,Case>();
        Map<Id,Case> mapcaseOutPharmacyAccount=new Map<Id,Case>();
        Map<Id,Case> mapcaseInPharmacyAccount=new Map<Id,Case>();
        Map<Id,Case> mapcaseInReenrollPharmacyAccount=new Map<Id,Case>();
        Map<Id,Case> mapcaseOutReenrollPharmacyAccount=new Map<Id,Case>();
        Map<Id,Case> mapCOIPatientAccount=new Map<Id,Case>();
        Map<Id,Case> mapCOIPharmacyAccount=new Map<Id,Case>();
        Map<Id,Case> mapCOIPrecriberAccount=new Map<Id,Case>();
        Map<Id,Case> mapCOIGeneralContactAccount=new Map<Id,Case>();
        Map<Id,Case> mapCOIDistributorAccount=new Map<Id,Case>();
        Map<Id,Case> mapCOIPharmacyParticipantAccount=new Map<Id,Case>();
        Map<Id,Case> mapCOIOfficeContctAccount = new Map<Id,Case>();
        
        Id outpharmacyEnrollCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.SYN_Outpatient_Pharmacy).getRecordTypeId();
        Id inpharmacyEnrollCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.SYN_Inpatient_Pharmacy).getRecordTypeId();
        Id inpharmacyReenrollCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.SYN_Inpatient_Pharmacy_Reenrollment).getRecordTypeId();
        Id outpharmacyReenrollCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.SYN_Outpatient_Pharmacy_Reenrollment).getRecordTypeId();
        Id prescriberCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Prescriber_enrollRCTypeDev).getRecordTypeId();
        Id patientCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Patient_Enrollement).getRecordTypeId();
        Id distributorCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Distributor_Enrollement).getRecordTypeId();
        Id pharmacyCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Pharmacy_Enrollment).getRecordTypeId();
        Id ChangeARCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Change_Authorized_Representative).getRecordTypeId();
        Id patientReenrollCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Patient_Reenrollement).getRecordTypeId();
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        Id distributorReenrollCaseRecTypeId =caseRecordTypeMap.get(SYN_Utilitycls.Distributor_Reenrollement);//Change made by DILEEP regarding Duplicate record type issue
        Id prescriberReenrollCaseRecTypeId = caseRecordTypeMap.get(SYN_Utilitycls.Prescriber_ReenrollRCTypeDev); ////Change made by DG regarding Duplicate record type issue
        Id pharmacyReenrollCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Pharmacy_Reenrollment).getRecordTypeId();
        Id KAACaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Knowlege_Assessment_A).getRecordTypeId();
        Id KABCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Knowlege_Assessment_B).getRecordTypeId();
        Id PatientCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_COI').getRecordTypeId();
        Id PrescriberCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_COI').getRecordTypeId();
        Id DistributorCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Distributor_COI').getRecordTypeId();
        Id GeneralConCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('General_Contact_COI').getRecordTypeId();
        Id PharmacyCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_COI').getRecordTypeId();
        Id PharmacyParticipantCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant_COI').getRecordTypeId();
        Id OfficeContactCOICaseRecTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MACI_Office_Contact_COI').getRecordTypeId();
        
        Id programId= SYN_CommonUtility.SOXprogramId();
        
        string ProgramName;
        for(Case c:cases){
                if(c.US_WSREMS__REMS_Program__c == programId){
                 ProgramName=SYN_Utilitycls.SOX_PROGRAM_NAME;
                if( c.RecordTypeId == prescriberCaseRecordTypeId && c.Status == 'Complete' && c.US_WSREMS__Outcome__c == 'Complete'){
                    mapcasePrescriberAccount.put(c.Id,c);
                }
                if( c.RecordTypeId == patientCaseRecordTypeId && c.Status == 'Complete' && c.US_WSREMS__Outcome__c == 'Complete'){
                    mapcasePatientAccount.put(c.Id,c);
                }
                if( c.RecordTypeId == distributorCaseRecordTypeId && c.Status == 'Complete' && c.US_WSREMS__Outcome__c == 'Complete'){
                    mapcaseDistributorAccount.put(c.Id,c);   
                }
                if( c.RecordTypeId == pharmacyCaseRecordTypeId && c.Status == 'Complete' && c.US_WSREMS__Outcome__c == 'Complete'){
                    mapcasePharmacyAccount.put(c.Id,c); 
                    
                }
                if( c.RecordTypeId == ChangeARCaseRecordTypeId && c.Status == 'Complete' && c.US_WSREMS__Outcome__c == 'Complete'){
                    mapcaseChangeAuthRep.put(c.Id,c); 
                    
                }
                if( c.RecordTypeId == prescriberReenrollCaseRecTypeId && c.Status == 'Complete' && c.US_WSREMS__Outcome__c == 'Complete'){
                    mapReenrollCasePrescriberAccount.put(c.Id,c); 
                    
                }
                if( c.RecordTypeId == patientReenrollCaseRecTypeId && c.Status == 'Complete' && c.US_WSREMS__Outcome__c == 'Complete'){
                    mapReenrollcasePatientAccount.put(c.Id,c); 
                    
                }
                if( c.RecordTypeId == distributorReenrollCaseRecTypeId && c.Status == 'Complete' && c.US_WSREMS__Outcome__c == 'Complete'){
                    mapReenrollcaseDistributorAccount.put(c.Id,c); 
                    
                }
                if( c.RecordTypeId == pharmacyReenrollCaseRecTypeId && c.Status == 'Complete' && c.US_WSREMS__Outcome__c == 'Complete'){
                    mapReenrollcasePharmacyAccount.put(c.Id,c); 
                    
                }
                if( c.RecordTypeId == KAACaseRecTypeId && c.Status == 'Complete' && c.US_WSREMS__Outcome__c == 'Pass'){
                    mapcaseKAAPharmacyPartiAccount.put(c.Id,c); 
                    
                }
                if( c.RecordTypeId == KABCaseRecTypeId && c.Status == 'Complete' && c.US_WSREMS__Outcome__c == 'Pass'){
                    mapcaseKABPharmacyPartiAccount.put(c.Id,c); 
                    
                }
            }
            
             
            if(c.REMS_Project_Code__c == Label.MACIProgramProjectCode && c.Status=='Complete')
            {
                ProgramName=SYN_Utilitycls.MACI_PROGRAM_NAME;//'Macitentan REMS';
              if( c.RecordTypeId == prescriberCaseRecordTypeId){
                    mapcasePrescriberAccount.put(c.Id,c);
                }
                if(c.RecordTypeId == patientCaseRecordTypeId && oldMap != null && oldMap.get(c.Id) !=null && c.Status != oldMap.get(c.Id).Status ){
                    mapcasePatientAccount.put(c.Id,c);
                }
                if( c.RecordTypeId == distributorCaseRecordTypeId){
                    mapcaseDistributorAccount.put(c.Id,c);   
                }
                if( c.RecordTypeId == pharmacyCaseRecordTypeId){
                    mapcasePharmacyAccount.put(c.Id,c); 
                    
                }
               
                if( c.RecordTypeId == prescriberReenrollCaseRecTypeId){
                    mapReenrollCasePrescriberAccount.put(c.Id,c); 
                    
                }
                if( c.RecordTypeId == patientReenrollCaseRecTypeId){
                    mapReenrollcasePatientAccount.put(c.Id,c); 
                    
                }
                if( c.RecordTypeId == distributorReenrollCaseRecTypeId){
                    mapReenrollcaseDistributorAccount.put(c.Id,c); 
                    
                }
                if( c.RecordTypeId == pharmacyReenrollCaseRecTypeId){
                    mapReenrollcasePharmacyAccount.put(c.Id,c); 
                    
                }
                //OutPatientpharmacy Entroll
                if( c.RecordTypeId == outpharmacyEnrollCaseRecTypeId){
                    mapcaseOutPharmacyAccount.put(c.Id,c); 
                    
                }
                
                 //inPatientpharmacy Entroll
                if( c.RecordTypeId == inpharmacyEnrollCaseRecTypeId){
                    mapcaseInPharmacyAccount.put(c.Id,c); 
                    
                }
                
                  //inPatientpharmacy Reentroll
                if( c.RecordTypeId ==inpharmacyReenrollCaseRecTypeId ){
                    mapcaseInReenrollPharmacyAccount.put(c.Id,c); 
                    
                }
                
                  //Out Patientpharmacy Reentroll
                if( c.RecordTypeId ==outpharmacyReenrollCaseRecTypeId ){
                    mapcaseOutReenrollPharmacyAccount.put(c.Id,c); 
                    
                }
                // Patient COI
                if(c.RecordTypeId == PatientCOICaseRecTypeId){
                    mapCOIPatientAccount.put(c.Id,c);
                }
                
                // Precriber COI
                if(c.RecordTypeId == PrescriberCOICaseRecTypeId ){
                    mapCOIPrecriberAccount.put(c.Id,c);
                }
                
                
                // Distributor COI
                if(c.RecordTypeId == DistributorCOICaseRecTypeId ){
                    mapCOIDistributorAccount.put(c.Id,c);
                }
                
                
                // General COI
                if(c.RecordTypeId == GeneralConCOICaseRecTypeId ){
                    mapCOIGeneralContactAccount.put(c.Id,c);
                }
                
                // Pharmacy COI
                if(c.RecordTypeId == PharmacyCOICaseRecTypeId ){
                    mapCOIPharmacyAccount.put(c.Id,c);
                }
                
                
                // Pharmacy Participant COI
                if(c.RecordTypeId == PharmacyParticipantCOICaseRecTypeId){
                    mapCOIPharmacyParticipantAccount.put(c.Id,c);
                }
               
                //Office Contact COI
                 if(c.RecordTypeId == OfficeContactCOICaseRecTypeId ){
                    mapCOIOfficeContctAccount.put(c.Id,c);
                }
                  
            }
        }
        
        //For Prescriber
        if (mapcasePrescriberAccount != null && (! mapcasePrescriberAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Prescriber_enrollRCTypeDev,SYN_Utilitycls.Prescriber,ProgramName);
            updateCaseAccountvalues(mapcasePrescriberAccount,TargetSourceFieldMapping,false);
        }
        //For Patient
        if (mapcasePatientAccount != null && (! mapcasePatientAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_patient =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Patient_Enrollement,SYN_Utilitycls.Patient,ProgramName);
            updateCaseAccountvalues(mapcasePatientAccount,TargetSourceFieldMapping_patient,false);
        }
        //For Distributor
         if (mapcaseDistributorAccount != null && (! mapcaseDistributorAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_dis =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Distributor_Enrollement,SYN_Utilitycls.Distributor_Account,ProgramName);
            updateCaseAccountvalues(mapcaseDistributorAccount,TargetSourceFieldMapping_dis,false);
        }
        // For Pharmacy
         if (mapcasePharmacyAccount != null && (! mapcasePharmacyAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_pharma =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Pharmacy_Enrollment,SYN_Utilitycls.Pharmacy_Account,ProgramName);
            Map<string,string> TargetSourceFieldMapping_pp =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Pharmacy_Enrollment,SYN_Utilitycls.Pharmacy_Participant_account,ProgramName);
            updateCaseAccountvalues(mapcasePharmacyAccount,TargetSourceFieldMapping_pharma,false);
            updateCaseAccountvalues(mapcasePharmacyAccount,TargetSourceFieldMapping_pp,true);
        }
        //For ChangeAR
        if (mapcaseChangeAuthRep != null && (! mapcaseChangeAuthRep.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_pharma_AR =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Change_Authorized_Representative,SYN_Utilitycls.Pharmacy_Account,ProgramName);
            Map<string,string> TargetSourceFieldMapping_pp_AR =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Change_Authorized_Representative,SYN_Utilitycls.Pharmacy_Participant_account,ProgramName);
            updateCaseAccountvalues(mapcaseChangeAuthRep,TargetSourceFieldMapping_pharma_AR,false);
            updateCaseAccountvalues(mapcaseChangeAuthRep,TargetSourceFieldMapping_pp_AR,true);
        }
        //For Prescriber Reenrollment
        if (mapReenrollCasePrescriberAccount != null && (! mapReenrollCasePrescriberAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_presReenr =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Prescriber_ReenrollRCTypeDev,SYN_Utilitycls.Prescriber,ProgramName);
            updateCaseAccountvalues(mapReenrollCasePrescriberAccount,TargetSourceFieldMapping_presReenr,false);
        }
        //For Patient Reenrollment
        if (mapReenrollcasePatientAccount != null && (! mapReenrollcasePatientAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_patientReenr =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Patient_Reenrollement,SYN_Utilitycls.Patient,ProgramName);
            updateCaseAccountvalues(mapReenrollcasePatientAccount,TargetSourceFieldMapping_patientReenr,false);
        }
        //For Distributor Reenrollment
        if (mapReenrollcaseDistributorAccount != null && (! mapReenrollcaseDistributorAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_disReenr =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Distributor_Reenrollement,SYN_Utilitycls.Distributor_Account,ProgramName);
            updateCaseAccountvalues(mapReenrollcaseDistributorAccount,TargetSourceFieldMapping_disReenr,false);
        }
        // For Pharmacy Reenrollment
        if (mapReenrollcasePharmacyAccount != null && (! mapReenrollcasePharmacyAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_pharmaReenr =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Pharmacy_Reenrollment,SYN_Utilitycls.Pharmacy_Account,ProgramName);
            Map<string,string> TargetSourceFieldMapping_ppReenr =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Pharmacy_Reenrollment,SYN_Utilitycls.Pharmacy_Participant_account,ProgramName);
            updateCaseAccountvalues(mapReenrollcasePharmacyAccount,TargetSourceFieldMapping_pharmaReenr,false);
            updateCaseAccountvalues(mapReenrollcasePharmacyAccount,TargetSourceFieldMapping_ppReenr,true);
        }
        // For KAA
        if (mapcaseKAAPharmacyPartiAccount != null && (! mapcaseKAAPharmacyPartiAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_KAA =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Knowlege_Assessment_A,SYN_Utilitycls.Pharmacy_Account,ProgramName);
            Map<string,string> TargetSourceFieldMapping_ppKAA =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Knowlege_Assessment_A,SYN_Utilitycls.Pharmacy_Participant_account,ProgramName);
            updateCaseAccountvalues(mapcaseKAAPharmacyPartiAccount,TargetSourceFieldMapping_KAA,false);
            updateCaseAccountvalues(mapcaseKAAPharmacyPartiAccount,TargetSourceFieldMapping_ppKAA,true);
        }
        
        // For KAB
        if (mapcaseKABPharmacyPartiAccount != null && (! mapcaseKABPharmacyPartiAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_KAB =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Knowlege_Assessment_B,SYN_Utilitycls.Pharmacy_Account,ProgramName);
            Map<string,string> TargetSourceFieldMapping_ppKAB =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.Knowlege_Assessment_B,SYN_Utilitycls.Pharmacy_Participant_account,ProgramName);
            updateCaseAccountvalues(mapcaseKABPharmacyPartiAccount,TargetSourceFieldMapping_KAB,false);
            updateCaseAccountvalues(mapcaseKABPharmacyPartiAccount,TargetSourceFieldMapping_ppKAB,true);
        }
        
        // For OutPharmacy Enrollment
         if (mapcaseOutPharmacyAccount != null && (! mapcaseOutPharmacyAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_Outpharma =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.SYN_Outpatient_Pharmacy,SYN_Utilitycls.Pharmacy_Account,ProgramName);
            Map<string,string> TargetSourceFieldMapping_OutpharmaAr =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.SYN_Outpatient_Pharmacy,SYN_Utilitycls.Pharmacy_Participant_account,ProgramName);
            updateCaseAccountvalues(mapcaseOutPharmacyAccount,TargetSourceFieldMapping_Outpharma,false);
            updateCaseAccountvalues(mapcaseOutPharmacyAccount,TargetSourceFieldMapping_OutpharmaAr,true);
        
        }
        
         // For InPharmacy Enrollment
         if (inpharmacyEnrollCaseRecTypeId != null && (! mapcaseInPharmacyAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_Inpharma =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.SYN_Inpatient_Pharmacy,SYN_Utilitycls.Pharmacy_Account,ProgramName);
            Map<string,string> TargetSourceFieldMapping_InpharmaAr =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.SYN_Inpatient_Pharmacy,SYN_Utilitycls.Pharmacy_Participant_account,ProgramName);
            updateCaseAccountvalues(mapcaseInPharmacyAccount,TargetSourceFieldMapping_Inpharma,false);
            updateCaseAccountvalues(mapcaseInPharmacyAccount,TargetSourceFieldMapping_InpharmaAr,true);
                    }
        
        
         // For InPharmacy reenrollment 
         if (inpharmacyReenrollCaseRecTypeId != null && (! mapcaseInReenrollPharmacyAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_InpharmaRee =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.SYN_Inpatient_Pharmacy_Reenrollment,SYN_Utilitycls.Pharmacy_Account,ProgramName);
            updateCaseAccountvalues(mapcaseInReenrollPharmacyAccount,TargetSourceFieldMapping_InpharmaRee,false);
           }
        
         // For OutPharmacy reenrollment 
         if (outpharmacyReenrollCaseRecTypeId != null && (! mapcaseOutReenrollPharmacyAccount.isEmpty())) {
            Map<string,string> TargetSourceFieldMapping_OutpharmaRee =getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.SYN_Outpatient_Pharmacy_Reenrollment,SYN_Utilitycls.Pharmacy_Account,ProgramName);
            updateCaseAccountvalues(mapcaseOutReenrollPharmacyAccount,TargetSourceFieldMapping_OutpharmaRee,false);
                   }
        
        //For Patient COI
        if(mapCOIPatientAccount!= null && (!mapCOIPatientAccount.isEmpty())) {
            Map<String,String> TargetSourceFieldMapping_patientcoi = new Map<String,String>();   
            Map<string,string> TargetSourceFieldMappingpatient =getFieldMapping(SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.Patient,'SYN_Patient_Person_Account',ProgramName);
            if(TargetSourceFieldMappingpatient != null && !TargetSourceFieldMappingpatient.isEmpty()){
                    for(String KeyValue : TargetSourceFieldMappingpatient.keySet()){
                        TargetSourceFieldMapping_patientcoi.put(TargetSourceFieldMappingpatient.get(keyValue),keyValue);
                    }
            }
            updateCaseAccountvalues(mapCOIPatientAccount,TargetSourceFieldMapping_patientcoi,false);
        }
        
         //For Pharmacy COI
        if(mapCOIPharmacyAccount != null && (!mapCOIPharmacyAccount.isEmpty())) {
            Map<String,String> TargetSourceFieldMapping_pharmacycoi = new Map<String,String>();   
            Map<string,string> TargetSourceFieldMappingpharmacy =getFieldMapping(SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.Pharmacy_Account,'Pharmacy_Account',ProgramName);
            if(TargetSourceFieldMappingpharmacy != null && !TargetSourceFieldMappingpharmacy.isEmpty()){
                    for(String KeyValue : TargetSourceFieldMappingpharmacy.keySet()){
                        TargetSourceFieldMapping_pharmacycoi.put(TargetSourceFieldMappingpharmacy.get(keyValue),keyValue);
                    }
            }
            updateCaseAccountvalues(mapCOIPharmacyAccount,TargetSourceFieldMapping_pharmacycoi,false);
        }
        
         //For Prescriber COI
        if(mapCOIPrecriberAccount != null && (!mapCOIPrecriberAccount .isEmpty())) {
            Map<String,String> TargetSourceFieldMapping_PrescriberCOI = new Map<String,String>();   
            Map<string,string> TargetSourceFieldMappingPrescriber =getFieldMapping(SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.Prescriber ,'Prescriber_Person_Account',ProgramName);
            if(TargetSourceFieldMappingPrescriber != null && !TargetSourceFieldMappingPrescriber .isEmpty()){
                    for(String KeyValue : TargetSourceFieldMappingPrescriber .keySet()){
                        TargetSourceFieldMapping_PrescriberCOI.put(TargetSourceFieldMappingPrescriber.get(keyValue),keyValue);
                    }
            }
            updateCaseAccountvalues(mapCOIPrecriberAccount,TargetSourceFieldMapping_PrescriberCOI,false);
        }
        
        
         //For General Contact COI
        if(mapCOIGeneralContactAccount != null && (!mapCOIGeneralContactAccount.isEmpty())) {
            Map<String,String> TargetSourceFieldMapping_GeneralConCOI = new Map<String,String>();   
            Map<string,string> TargetSourceFieldMappingGeneralCon =getFieldMapping(SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.CASE_OBJECT,'General_Contact','General_Contact',ProgramName);
            if(TargetSourceFieldMappingGeneralCon != null && !TargetSourceFieldMappingGeneralCon .isEmpty()){
                    for(String KeyValue : TargetSourceFieldMappingGeneralCon.keySet()){
                        TargetSourceFieldMapping_GeneralConCOI.put(TargetSourceFieldMappingGeneralCon.get(keyValue),keyValue);
                    }
            }
            updateCaseAccountvalues(mapCOIGeneralContactAccount,TargetSourceFieldMapping_GeneralConCOI,false);
        }
        
         //For General Contact COI
        if(mapCOIDistributorAccount != null && (!mapCOIDistributorAccount.isEmpty())) {
            Map<String,String> TargetSourceFieldMapping_DistributorCOI = new Map<String,String>();   
            Map<string,string> TargetSourceFieldMappingDistributor =getFieldMapping(SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.CASE_OBJECT,'REMS_Distributor_Account','SYN_Distributor_Account',ProgramName);
            if(TargetSourceFieldMappingDistributor != null && !TargetSourceFieldMappingDistributor .isEmpty()){
                    for(String KeyValue : TargetSourceFieldMappingDistributor.keySet()){
                        TargetSourceFieldMapping_DistributorCOI.put(TargetSourceFieldMappingDistributor.get(keyValue),keyValue);
                    }
            }
            updateCaseAccountvalues(mapCOIDistributorAccount,TargetSourceFieldMapping_DistributorCOI,false);
        }
        
        //For Pharmacy Participant COI
        if(mapCOIPharmacyParticipantAccount!= null && (!mapCOIPharmacyParticipantAccount.isEmpty())) {
            Map<String,String> TargetSourceFieldMapping_PPAccountCOI = new Map<String,String>();   
            Map<string,string> TargetSourceFieldMappingPPAccount =getFieldMapping(SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.CASE_OBJECT,'Pharmacy_Participant','Pharmacy_Participant_Account',ProgramName);
            if(TargetSourceFieldMappingPPAccount != null && !TargetSourceFieldMappingPPAccount .isEmpty()){
                    for(String KeyValue : TargetSourceFieldMappingPPAccount .keySet()){
                        TargetSourceFieldMapping_PPAccountCOI.put(TargetSourceFieldMappingPPAccount.get(keyValue),keyValue);
                    }
            }
            updateCaseAccountvalues(mapCOIPharmacyParticipantAccount,TargetSourceFieldMapping_PPAccountCOI,false);
        }
          //For Office Contact
        if(mapCOIOfficeContctAccount != null && (!mapCOIOfficeContctAccount .isEmpty())) {
            Map<String,String> TargetSourceFieldMapping_OfficeContactCOI = new Map<String,String>();
            Map<string,string> TargetSourceFieldMappingOfficeContact =getFieldMapping(SYN_Utilitycls.ACCOUNT_OBJECT,SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.OfficeContact ,'Office_Contact',ProgramName);
            if(TargetSourceFieldMappingOfficeContact != null && !TargetSourceFieldMappingOfficeContact .isEmpty()){
                    for(String KeyValue : TargetSourceFieldMappingOfficeContact.keySet()){
                        TargetSourceFieldMapping_OfficeContactCOI.put(TargetSourceFieldMappingOfficeContact.get(keyValue),keyValue);
                    }
            }
            updateCaseAccountvalues(mapCOIOfficeContctAccount,TargetSourceFieldMapping_OfficeContactCOI,false);
        }
        
            
    }
    //BT6825-444
    public static void updateCaseAccountvalues(Map<Id,Case> accountCasemap, Map<string,string> TargetSourceFieldMapping,boolean updatePP){
        Id prescriberCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Prescriber_enrollRCTypeDev).getRecordTypeId();
        Id patientCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Patient_Enrollement).getRecordTypeId();
        Id distributorCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Distributor_Enrollement).getRecordTypeId();
        Id pharmacyCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Pharmacy_Enrollment).getRecordTypeId();
         Id ChangeARCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Change_Authorized_Representative).getRecordTypeId();
         Id prescriberReenrollCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Prescriber_ReenrollRCTypeDev).getRecordTypeId();
         Id patientReenrollCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Patient_Reenrollement).getRecordTypeId();
         Id distributorReenrollCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Distributor_Reenrollement).getRecordTypeId();
         Id pharmacyReenrollCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Pharmacy_Reenrollment).getRecordTypeId();
         Id KAACaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Knowlege_Assessment_A).getRecordTypeId();
         Id KABCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Knowlege_Assessment_B).getRecordTypeId();
         Id PatientCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_COI').getRecordTypeId();
        Id PrescriberCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_COI').getRecordTypeId();
        Id DistributorCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Distributor_COI').getRecordTypeId();
        Id GeneralConCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('General_Contact_COI').getRecordTypeId();
        Id PharmacyCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_COI').getRecordTypeId();
        Id PharmacyParticipantCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant_COI').getRecordTypeId();
        Id OfficeContactCOICaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MACI_Office_Contact_COI').getRecordTypeId();
        Id outPharmacyCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.SYN_Outpatient_Pharmacy).getRecordTypeId();
        Id inPharmacyCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.SYN_Inpatient_Pharmacy).getRecordTypeId();
        Id outPharmacyReenrollmentCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.SYN_Outpatient_Pharmacy_Reenrollment).getRecordTypeId();
        Id inPharmacyReenrollmentCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.SYN_Inpatient_Pharmacy_Reenrollment).getRecordTypeId();

         Set<Id> allParticipantIdSet = new Set<Id>();
         Case caseObj;
        for(Id acc : accountCasemap.Keyset()){
            
            Case c = accountCasemap.get(acc);
            caseObj=c;
            Account account_obj = new Account();
            if( c.RecordTypeId == prescriberCaseRecordTypeId){
               account_obj.Id=c.SYN_Prescriber__c;
            }
            if( c.RecordTypeId == patientCaseRecordTypeId){
                account_obj.Id=c.US_WSREMS__Patient__c;
            }
            if( c.RecordTypeId == distributorCaseRecordTypeId){
                 account_obj.Id=c.US_WSREMS__Distributor__c;
            }
             if( c.RecordTypeId == pharmacyCaseRecordTypeId){
                 if(updatePP){
                     account_obj.Id=c.SYN_Authorized_Rep__c;
                 }else{
                 account_obj.Id=c.SYN_Pharmacy__c;   
                 }
                  
             }
            
             if( c.RecordTypeId == ChangeARCaseRecordTypeId ){
                 if(updatePP){
                  account_obj.Id=c.Pharmacy_Participant__c;
                 }else{
                   account_obj.Id = c.US_WSREMS__Pharmacy__c;   
                 }
                 
             }
             if( c.RecordTypeId == prescriberReenrollCaseRecTypeId){
                
                account_obj.Id=c.SYN_Prescriber__c;
            }
            if( c.RecordTypeId == patientReenrollCaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Patient__c;
            }
            if( c.RecordTypeId == distributorReenrollCaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Distributor__c;
            }
            
            //Out Patient Pharmacy Enrollment 884
               if( c.RecordTypeId == outPharmacyCaseRecordTypeId || c.RecordTypeId == inPharmacyCaseRecordTypeId || c.RecordTypeId == inPharmacyReenrollmentCaseRecordTypeId ||c.RecordTypeId == outPharmacyReenrollmentCaseRecordTypeId){
                if(updatePP){
                    account_obj.Id=c.SYN_Authorized_Rep__c;
                }else{
                    account_obj.Id=c.SYN_Pharmacy__c;   
                }
            }  
            
            
            if( c.RecordTypeId == pharmacyReenrollCaseRecTypeId){
                if(updatePP){
                    account_obj.Id=c.SYN_Authorized_Rep__c;
                }else{
                    account_obj.Id=c.SYN_Pharmacy__c;   
                }
                
            }
            if( c.RecordTypeId == KAACaseRecTypeId ||c.RecordTypeId == KABCaseRecTypeId){
                if(updatePP){
                    account_obj.Id=c.Pharmacy_Participant__c;
                }else{
                    account_obj.Id=c.SYN_Pharmacy__c;   
                }
            }          
            //Patient COI 
            if( c.RecordTypeId == PatientCOICaseRecTypeId ){
                account_obj.Id=c.US_WSREMS__Participant__c;   
            } 
            
            // Precriber COI
            if( c.RecordTypeId == PrescriberCOICaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Participant__c;   
            }
            
            // Pharmcy COI
            if( c.RecordTypeId == PharmacyCOICaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Participant__c;   
            }
            
            // General Contact COI
            if( c.RecordTypeId == GeneralConCOICaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Participant__c;   
            }
            
            // Distributor COI
            if( c.RecordTypeId == DistributorCOICaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Participant__c;   
            } 
            
            // PP Account COI
            if( c.RecordTypeId == PharmacyParticipantCOICaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Participant__c;   
            }        
            
              // Office Contact COI
            if( c.RecordTypeId == OfficeContactCOICaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Participant__c;
            }
            
            allParticipantIdSet.add(account_obj.Id);
        }
        
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, SYN_User_Type__c FROM Account WHERE ID IN: allParticipantIdSet ]);
       
        List<Account> acc_list=new List<Account>();
        for(Id acc:accountCasemap.Keyset()){
            case c=accountCasemap.get(acc);
            Account account_obj=new Account();
              if( c.RecordTypeId == prescriberCaseRecordTypeId){
               account_obj.Id=c.SYN_Prescriber__c;
            }
            if( c.RecordTypeId == patientCaseRecordTypeId){
                account_obj.Id=c.US_WSREMS__Patient__c;
            }
            if( c.RecordTypeId == distributorCaseRecordTypeId){
                 account_obj.Id=c.US_WSREMS__Distributor__c;
            }
             if( c.RecordTypeId == pharmacyCaseRecordTypeId){
                 if(updatePP){
                     account_obj.Id=c.SYN_Authorized_Rep__c;
                 }else{
                 account_obj.Id=c.SYN_Pharmacy__c;   
                 }
                  
             }
             
             //Out Patient Pharmacy Enrollment 884
               if( c.RecordTypeId == outPharmacyCaseRecordTypeId || c.RecordTypeId == inPharmacyCaseRecordTypeId || c.RecordTypeId == inPharmacyReenrollmentCaseRecordTypeId || c.RecordTypeId == outPharmacyReenrollmentCaseRecordTypeId){
                if(updatePP){
                    account_obj.Id=c.SYN_Authorized_Rep__c;
                }else{
                    account_obj.Id=c.SYN_Pharmacy__c;   
                }
            }  
                
             
            
             if( c.RecordTypeId == ChangeARCaseRecordTypeId ){
                 if(updatePP){
                  account_obj.Id=c.Pharmacy_Participant__c;
                 }else{
                   account_obj.Id=c.US_WSREMS__Pharmacy__c;   
                 }
                 
             }
             if( c.RecordTypeId == prescriberReenrollCaseRecTypeId){
                
                account_obj.Id=c.SYN_Prescriber__c;
            }
            if( c.RecordTypeId == patientReenrollCaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Patient__c;
            }
            if( c.RecordTypeId == distributorReenrollCaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Distributor__c;
            }
            if( c.RecordTypeId == pharmacyReenrollCaseRecTypeId){
                if(updatePP){
                    account_obj.Id=c.SYN_Authorized_Rep__c;
                }else{
                    account_obj.Id=c.SYN_Pharmacy__c;   
                }
                
            }
            if( c.RecordTypeId == KAACaseRecTypeId ||c.RecordTypeId == KABCaseRecTypeId){
                if(updatePP){
                    account_obj.Id=c.Pharmacy_Participant__c;
                }else{
                    account_obj.Id=c.SYN_Pharmacy__c;   
                }
                
            }
              
            // Patient COI
            if( c.RecordTypeId == PatientCOICaseRecTypeId ){
                account_obj.Id=c.US_WSREMS__Participant__c;
            } 
            
             // Precriber COI
            if( c.RecordTypeId == PrescriberCOICaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Participant__c;   
            }
            
            // Pharmcy COI
            if( c.RecordTypeId == PharmacyCOICaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Participant__c;   
            }
            
            // General Contact COI
            if( c.RecordTypeId == GeneralConCOICaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Participant__c;   
            }
            
            // Distributor COI
            if( c.RecordTypeId == DistributorCOICaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Participant__c;   
            } 
            
            // PP Account COI
            if( c.RecordTypeId == PharmacyParticipantCOICaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Participant__c;   
            }    
              
            // Office Contact COI
            if( c.RecordTypeId == OfficeContactCOICaseRecTypeId){
                account_obj.Id=c.US_WSREMS__Participant__c;
            }

            account_obj=(Account)updateAccountValues(c,account_obj,TargetSourceFieldMapping, accMap);
            if(account_obj.Id != Null)
            acc_list.add(account_obj);
          
            
        }
        try{
            update acc_list;
            }catch(Exception e){
                if(e.getMessage().contains('US_WSREMS__NPI__c')){
                   caseObj.addError('Duplicate NPI found'); 
                }else{
                    caseObj.addError(e.getMessage());  
                }
    
            }
        
    }
     //BT6825-444
     public static Sobject updateAccountValues(Case cs, sobject acc, Map<String,String> mapConfig, Map<Id, Account> accMapVal){
        for(String targetField : mapConfig.keySet()){
            if((cs.get(mapConfig.get(targetField))) != Null || targetField == 'Two_Factor_Authentication_Selection__c'){
                    if(targetField != 'SYN_User_Type__c' && targetField != 'SYN_Ref_Id__c') {
                      acc.put(targetField, (cs.get(mapConfig.get(targetField))));
                    }
                   
                }
        }
        return acc;
    }
    
     //BT6825-444
    public static Map<String,string> getFieldMapping(String sourceObj , String tarObj, String sourceRCtyName , String tarRCtypeName,string programName ){
        Map<string,string> targetSourceFieldMapping = new Map<String,string>();
        
        if(programName=='Sodium Oxybate REMS') 
            {
        for (US_WSREMS__Field_Mapping_Config__mdt mdt : [SELECT MasterLabel, US_WSREMS__Source_Object__c, US_WSREMS__Target_Object__c ,US_WSREMS__Source_RecordType_Name__c,US_WSREMS__Target_RecordType_Name__c,US_WSREMS__Target_Field__c,US_WSREMS__Source_Field__c FROM US_WSREMS__Field_Mapping_Config__mdt where  US_WSREMS__Program__r.MasterLabel=:programName and US_WSREMS__Source_Object__c=:sourceObj and US_WSREMS__Target_Object__c=:tarObj ]){
            if ( mdt.US_WSREMS__Source_RecordType_Name__c != sourceRCtyName || mdt.US_WSREMS__Target_RecordType_Name__c  != tarRCtypeName){
                continue;
            }
            targetSourceFieldMapping.put( mdt.US_WSREMS__Target_Field__c , mdt.US_WSREMS__Source_Field__c );
        }
       }
        if(programName=='Macitentan REMS')
            
        {
            for (US_WSREMS__Field_Mapping_Config__mdt mdt : [SELECT MasterLabel, US_WSREMS__Source_Object__c, US_WSREMS__Target_Object__c ,US_WSREMS__Source_RecordType_Name__c,US_WSREMS__Target_RecordType_Name__c,US_WSREMS__Target_Field__c,US_WSREMS__Source_Field__c FROM US_WSREMS__Field_Mapping_Config__mdt where  US_WSREMS__Program__r.MasterLabel=:programName and US_WSREMS__Source_Object__c=:tarObj and US_WSREMS__Target_Object__c=:sourceObj AND US_WSREMS__IsActive__c = True ANd US_WSREMS__Source_Field__c!='Name' ]){
            if ( mdt.US_WSREMS__Source_RecordType_Name__c != tarRCtypeName || mdt.US_WSREMS__Target_RecordType_Name__c  != sourceRCtyName){
                continue;
            }
            targetSourceFieldMapping.put(mdt.US_WSREMS__Source_Field__c,mdt.US_WSREMS__Target_Field__c  );
        }
            
        }
   
        return targetSourceFieldMapping;
    }
    public static void createfacility(List<Case> caseList) {
        
        user userInfo = [SELECT Id,UserName,Program__c,ContactId,AccountId FROM USER WHERE ID=:userInfo.getUserId()];
        if(userInfo != null && userInfo.AccountId != null && userInfo.Program__c != 'Macitentan REMS') {
            List<String> facityNameList = new List<String>();
            Id prescriberInstitutionAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution').getRecordTypeId();
            Map<String, Id> accNameMap = new Map<String,Id>();
            Id prescriberInstitutionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution_Account').getRecordTypeId();
            Id prescriberPersonRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
            
            Map<String, Id> newaccMap = new Map<String,Id>();
            List<String> missedNamesList = new List<String>();
            List<Case> missedcasesList = new List<case>();
            List<String>ShippingPostalCodeList = new List<String>();
            List<String> phoneList = New List<String>();
            List<String> faxList = new LIst<String>();
            
            
            
            for(Case caseRec : caseList) {
                if(caseRec.recordTypeId  == prescriberInstitutionRecordTypeId || caseRec.recordTypeId ==prescriberPersonRecordTypeId ) {
                    if(String.isNotBlank(caseRec.SYN_Facility__c)){
                        facityNameList.add(caseRec.SYN_Facility__c);
                        phoneList.add(caseRec.US_WSREMS__Phone__c);
                        ShippingPostalCodeList.add(caseRec.SYN_Zip_Code__c);
                        faxList.add(caseRec.US_WSREMS__Fax__c);  
                    }
                }
            }
            
            if(facityNameList.size() > 0) {
                
                accNameMap = getExistingAccounts(prescriberInstitutionAccountRecordTypeId, facityNameList, phoneList, faxList, ShippingPostalCodeList);
            }
             List<Account> accList = new List<Account>();
            for(Case caseRec : caseList) {
               
                 Account acc;
                if(caseRec.recordTypeId  == prescriberInstitutionRecordTypeId || caseRec.recordTypeId ==prescriberPersonRecordTypeId ) {
                    if(accNameMap.containsKey(caseRec.US_WSREMS__Phone__c+'_'+caseRec.SYN_Zip_Code__c)) {
                        caseRec.US_WSREMS__Facility__c  =  accNameMap.get(caseRec.US_WSREMS__Phone__c+'_'+caseRec.SYN_Zip_Code__c);
                        acc = new Account();
                        acc.Id = accNameMap.get(caseRec.US_WSREMS__Phone__c+'_'+caseRec.SYN_Zip_Code__c);
                        acc.phone = caseRec.US_WSREMS__Phone__c;
                        acc.shippingCity = caseRec.US_WSREMS__City__c;
                        acc.ShippingState = caseRec.US_WSREMS__State__c;
                        acc.ShippingStreet = caseRec.SYN_Street_Address__c;
                        acc.fax = caseRec.US_WSREMS__Fax__c;
                        accList.add(acc);
                        
                    } else if(accNameMap.containsKey(caseRec.US_WSREMS__Fax__c+'_'+caseRec.SYN_Zip_Code__c)) {
                        caseRec.US_WSREMS__Facility__c  =  accNameMap.get(caseRec.US_WSREMS__Fax__c+'_'+caseRec.SYN_Zip_Code__c);
                         acc = new Account();
                        acc.Id = accNameMap.get(caseRec.US_WSREMS__Fax__c+'_'+caseRec.SYN_Zip_Code__c);
                        acc.phone = caseRec.US_WSREMS__Phone__c;
                        acc.shippingCity = caseRec.US_WSREMS__City__c;
                        acc.ShippingState = caseRec.US_WSREMS__State__c;
                        acc.ShippingStreet = caseRec.SYN_Street_Address__c;
                        acc.fax = caseRec.US_WSREMS__Fax__c;
                        accList.add(acc);
                    } else if(accNameMap.containsKey(caseRec.SYN_Facility__c+'_'+caseRec.SYN_Zip_Code__c)) {
                        caseRec.US_WSREMS__Facility__c  =  accNameMap.get(caseRec.SYN_Facility__c+'_'+caseRec.SYN_Zip_Code__c);
                         acc = new Account();
                        acc.Id = accNameMap.get(caseRec.SYN_Facility__c+'_'+caseRec.SYN_Zip_Code__c);
                        acc.phone = caseRec.US_WSREMS__Phone__c;
                        acc.shippingCity = caseRec.US_WSREMS__City__c;
                        acc.ShippingState = caseRec.US_WSREMS__State__c;
                        acc.ShippingStreet = caseRec.SYN_Street_Address__c;
                        acc.fax = caseRec.US_WSREMS__Fax__c;
                        accList.add(acc);
                    } else {                    
                        missedNamesList.add(caseRec.SYN_Facility__c);
                        missedcasesList.add(caseRec);
                    }
                }
            }
            if(accList.size()>0) {
                update accList;
            }
            if(missedNamesList.size() > 0)  {
                
                newaccMap = createAccount(missedcasesList, missedNamesList, prescriberInstitutionAccountRecordTypeId, phoneList, faxList, ShippingPostalCodeList);
                            mapFacility(missedcasesList, newaccMap);

            }
            
            mapFacility(missedcasesList, newaccMap);
        }
    }
    
    public static void mapFacility(List<Case> casesList, Map<String,Id> accRecsMap) {
        
        for(Case caseRec : casesList) {
            
            if(accRecsMap.containsKey(caseRec.US_WSREMS__Phone__c+'_'+caseRec.SYN_Zip_Code__c)) {
                caseRec.US_WSREMS__Facility__c  =  accRecsMap.get(caseRec.US_WSREMS__Phone__c+'_'+caseRec.SYN_Zip_Code__c);
            } else if(accRecsMap.containsKey(caseRec.US_WSREMS__Fax__c+'_'+caseRec.SYN_Zip_Code__c)) {
                caseRec.US_WSREMS__Facility__c  =  accRecsMap.get(caseRec.US_WSREMS__Fax__c+'_'+caseRec.SYN_Zip_Code__c);
            }  else if(accRecsMap.containsKey(caseRec.SYN_Facility__c+'_'+caseRec.SYN_Zip_Code__c)) {
                caseRec.US_WSREMS__Facility__c  =  accRecsMap.get(caseRec.SYN_Facility__c+'_'+caseRec.SYN_Zip_Code__c);
            }
        }
    }
    
    public static  Map<String, Id> getExistingAccounts(String recordTypeId,List<String> facityNameList,List<String> phoneList,List<String> faxList,List<String> ShippingPostalCodeList){
        
        Map<String, Id> accNameMap = new Map<String,Id>();
        for(Account acc : [Select Id,Name, ShippingPostalCode, phone, fax FROM Account WHERE 
                           (Phone IN: phoneList OR
                            FAX IN: faxList OR 
                            Name IN :facityNameList) AND 
                           (recordTypeId=:recordTypeId AND ShippingPostalCode IN : ShippingPostalCodeList)
                           order by CreatedDate DESC ]){
                               
                               accNameMap.put(acc.phone +'_'+ acc.ShippingPostalCode, acc.Id);
                               accNameMap.put(acc.fax +'_'+ acc.ShippingPostalCode, acc.Id);
                               accNameMap.put(acc.Name +'_'+ acc.ShippingPostalCode, acc.Id);
                           }
        return accNameMap;
    }
    
    public static Map<String,Id> createAccount(List<Case> missedcasesList, List<String> missedNamesList,string accRecordTypeId ,List<String> phoneList, List<String> faxList, List<String> ShippingPostalCodeList) {
        
        List<Account> accList = new List<Account>();
        Map<String, Id> accNameMap = new Map<String,Id>();
        
        for(Case caseRec  : missedcasesList){
            
            Account acc = new Account();
            acc.recordTypeID = accRecordTypeId;
            acc.Name  = caseRec.SYN_Facility__c;
            acc.US_WSREMS__REMS_Program__c = caseRec.US_WSREMS__REMS_Program__c;
            acc.phone = caseRec.US_WSREMS__Phone__c;
            acc.fax = caseRec.US_WSREMS__Fax__c;
            acc.ShippingPostalCode = caseRec.SYN_Zip_Code__c;
            acc.ShippingCity = caseRec.US_WSREMS__City__c;
            acc.ShippingState = caseRec.US_WSREMS__State__c;
            acc.ShippingStreet = caseRec.SYN_Street_Address__c;
            acc.US_WSREMS__Channel__c = caseRec.US_WSREMS__Channel__c;
            
            accList.add(acc);
        }
        if(accList.size() >0 ){
            
            insert accList;
            for(Account acc: accList){
                
                accNameMap.put(acc.phone +'_'+ acc.ShippingPostalCode, acc.Id);
                accNameMap.put(acc.fax +'_'+ acc.ShippingPostalCode, acc.Id);
                accNameMap.put(acc.Name +'_'+ acc.ShippingPostalCode, acc.Id);
            }
        }
        return accNameMap;
    }
    private static Map<string, List<String>> createProgramBasedCustomValidationMap(String ObjectAPI,Set<String> progamNames){
           Map<string, List<String>> customValidationMap = new map<String, List<String>>();
           errorMap  = new Map<String,String>();
           for (US_WSREMS__REMS_Objvalidation_and_status_automation__mdt objVaL_mdt : [SELECT US_WSREMS__Object_API_Name__c, US_WSREMS__Object_recordType_DevName__c,US_WSREMS__Rems_Service_RCtype__c, US_WSREMS__Required_fields__c, US_WSREMS__ErrorMsg__c
                                                                           FROM US_WSREMS__REMS_Objvalidation_and_status_automation__mdt
                                                                           where US_WSREMS__Object_API_Name__c =: ObjectAPI AND US_WSREMS__Program__c != null AND US_WSREMS__Program__r.MasterLabel = : progamNames AND US_WSREMS__IsActive__c = true]){
                                                                               String uniqueKeyStr = objVaL_mdt.US_WSREMS__Object_recordType_DevName__c+'$$'+objVaL_mdt.US_WSREMS__Rems_Service_RCtype__c;
                                                                               if(!customValidationMap.containsKey(uniqueKeyStr)){
                                                                                   customValidationMap.put(uniqueKeyStr,new List<String> {objVaL_mdt.US_WSREMS__Required_fields__c});
                                                                                   errorMap.put(uniqueKeyStr,objVaL_mdt.US_WSREMS__ErrorMsg__c);
                                                                               }else{
                                                                                   customValidationMap.get(uniqueKeyStr).add(objVaL_mdt.US_WSREMS__Required_fields__c);
                                                                               }
                                                                           }
           return customValidationMap;
       }

       public static void  caseValuesForAccountStatusUpdation(List<case> caseList, Map<Id,Case> caseMap){
            Set<Id> rssIdSet = new Set<Id>();
            for(case cas : caseList){
                if(caseMap == null || caseMap.isEmpty()){
                    rssIdSet.add(cas.US_WSREMS__REMS_Service_Summary__c);
                }
                else if(cas.status != caseMap.get(cas.Id).Status  || cas.US_WSREMS__Outcome__c != caseMap.get(cas.Id).US_WSREMS__Outcome__c){
                    rssIdSet.add(cas.US_WSREMS__REMS_Service_Summary__c);
                }  
            }
            if(rssIdSet != null){
                SYN_AccountStatusUpdation.remsServiceIdsUtilityMethod(rssIdSet);
            }
        }

        public static void restrictPCCLRDACases(List<case> casesList) {
            Set<Id> participantIds = new set<Id>();
            Set<Id> RemsProgramIds = new set<Id>();
            Map<Id,Account> accMap;
            Map<Id,US_WSREMS__REMS_Program__c> remsMap;
            Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
            id pccRecordTypeId = caseRecordTypeMap.get('Patient_Counseling_Checklist');
            id caseRDARCTyId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();
    
            for(case c : casesList) {
                if(c.X1_Pharmacy_Participant__c != null) {
                    participantIds.add(c.X1_Pharmacy_Participant__c);
                    RemsProgramIds.add(c.US_WSREMS__REMS_Program__c);
                }
            }
            if(participantIds.size() >0) {
               accMap = new Map<Id,Account>([select Id,US_WSREMS__Status__c FROM Account WHERE Id IN :participantIds]);
            }
            if(RemsProgramIds.size()>0) {
                remsMap = new Map<Id,US_WSREMS__REMS_Program__c>([Select id,Name FROM US_WSREMS__REMS_Program__c WHERE Id IN:RemsProgramIds]);
            }
            for(case cs : casesList) {
                if(cs.X1_Pharmacy_Participant__c != null){
                    if(accMap.containsKey(cs.X1_Pharmacy_Participant__c) && 
                   accMap.get(cs.X1_Pharmacy_Participant__c).US_WSREMS__Status__c=='Inactive' &&
                       cs.US_WSREMS__Outcome__c !='Due Dilligence Exhausted' &&
                       cs.US_WSREMS__Outcome__c != 'Created in Error' &&
                       cs.Status == 'Complete' && remsMap.get(cs.US_WSREMS__REMS_Program__c).Name == Label.Sodium_Oxybate_REMS_Program_Name &&
                       (cs.RecordTypeId == pccRecordTypeId  || cs.RecordTypeId == caseRDARCTyId)
                      ) {
                          cs.addError('This Request can only be submitted by active pharmacy participants. The selected account is inactive.');
                      }
                }
            }
        }
        
        /******************************************
        Method Name : updateCaseAccount
        Description : updating patient account from case level
        *******************************************************/ 
        public static void updateCaseAccount(List<Case> cases){
          
          Id patientCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Patient_Enrollement).getRecordTypeId();
          Id patientReenrollCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.Patient_Reenrollement).getRecordTypeId();
         
          Set<String> programName = new Set<String>();
          List<Account> updateAccountList = new List<Account>();
          
          for (Case cs:cases){
              if(cs.US_WSREMS__REMS_Program__c != null && cs.US_WSREMS__Program_Name__c == Label.Macitentan_REMS_Program_Name && (cs.RecordTypeId == patientCaseRecordTypeId||cs.RecordTypeId == patientReenrollCaseRecTypeId)){
                  if(cs.US_WSREMS__Patient__c != null){                   
                      Account patientacc = new Account();
                      patientacc.id = cs.US_WSREMS__Patient__c;
                      patientacc.Emergency_Contact_Name__c=cs.Emergency_Contact_Name__c;
                      patientacc.Emergency_Contact_Phone__c=cs.Emergency_Contact_Phone__c;
                      patientacc.Emergency_Contact_Relationship__c=cs.Emergency_Contact_Relationship__c;
                      patientacc.Legal_Guardian_Name__c=cs.Legal_Guardian_Name__c;
                      patientacc.Legal_Guardian_Phone__c=cs.Legal_Guardian_Phone__c;
                      patientacc.Legal_Guardian_Email__c=cs.Legal_Guardian_Email__c;
                      patientacc.Legal_Guardian_Relationship__c=cs.Legal_Guardian_Relationship__c;
                                            
                      updateAccountList.add(patientacc);
                  }
              }
            }
          
          if(!updateAccountList.isEmpty() ){
              update updateAccountList;
          }
         
      }

    public static void RDAMatchReverseRDAPharmacy(List<Case> casesList) {
        id caseRDARCTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();
        id caseReverseRDARCTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Reverse_RDA').getRecordTypeId();
      
        Map<Id,case> rdaCasesMap= new Map<Id,Case>();
        List<Id> remsService = new List<Id>();
        for(case c :casesList) {
           remsService.add(c.US_WSREMS__REMS_Service_Summary__c);
       }

        if(remsService.size()>0 ){
            for(case c : [SELECT Id,US_WSREMS__REMS_Program__c,US_WSREMS__Pharmacy__c,US_WSREMS__REMS_Service_Summary__c FROM Case WHERE RecordTypeId =:caseRDARCTypeId AND US_WSREMS__REMS_Program__r.Name =:Label.Sodium_Oxybate_REMS_Program_Name  AND US_WSREMS__REMS_Service_Summary__c IN :remsService ]) {
                      rdaCasesMap.put(c.US_WSREMS__REMS_Service_Summary__c,c);  
            }
        }
        for(case rc : casesList) {
            if(rdaCasesMap.containsKey(rc.US_WSREMS__REMS_Service_Summary__c) && rdaCasesMap.get(rc.US_WSREMS__REMS_Service_Summary__c).US_WSREMS__Pharmacy__c !=rc.US_WSREMS__Pharmacy__c ) {
                rc.addError('The selected pharmacy is not associated with the RDA, please select the correct pharmacy or cancel the RDA reversal.');
            }
        }
       
   }

    
    
    /*Below method is for submitting the Approval Process automatically : AshishY(Wilco)*/
    public static void submitApprovalProcess(List<case> caseDetails){
        Id patientId;
        Id prescriberId;
        If(caseDetails[0].US_WSREMS__Record_Type_Name__c == 'Patient_Reenrollment'){
           patientId = caseDetails[0].US_WSREMS__Patient__c;
        } else if(caseDetails[0].US_WSREMS__Record_Type_Name__c == 'Prescriber_Reenrollment'){
            prescriberId = caseDetails[0].SYN_Prescriber__c;
        }

        //for only records which have service type as reenrollment
        if(caseDetails[0].Case_Record_Type_Name__c == 'Reenrollment'){
        // Need to get two field values from account as they are part of the entry criteria
        Account accDetails = [Select Id,US_WSREMS__Status__c,Sub_Status__c from Account where Id =:caseDetails[0].SYN_Pharmacy__c OR Id =:caseDetails[0].US_WSREMS__Distributor__c
        OR Id =:caseDetails[0].US_WSREMS__Pharmacy__c OR Id =:patientId
        OR Id =:prescriberId];
        Map<Id, List<ProcessInstanceWorkitem>> caseAndProcssInsMap = new Map<Id, List<ProcessInstanceWorkitem>>();
        for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId IN: caseDetails
        ]){

            if(caseAndProcssInsMap.containsKey(workItem.ProcessInstance.TargetObjectId)){
                    
                caseAndProcssInsMap.put(workItem.ProcessInstance.TargetObjectId, new List<ProcessInstanceWorkitem>());
            }
             
            List<ProcessInstanceWorkitem> tempProsIns = caseAndProcssInsMap.get(workItem.ProcessInstance.TargetObjectId);
            tempProsIns.add(workItem);
            caseAndProcssInsMap.put(workItem.ProcessInstance.TargetObjectId, tempProsIns);
             
        }
        for(Case caseId : caseDetails) {
        List<ProcessInstanceWorkitem> workItems = new List<ProcessInstanceWorkitem>();
        if(caseAndProcssInsMap.containsKey(caseId.Id)){
        
            workItems = caseAndProcssInsMap.get(caseId.Id);
        }
        
        //Entry Criteria for the approval to get submit part of 335 story                                       
        If((workItems.size()==0) 
            && caseId.Case_Record_Type_Name__c == 'Reenrollment' 
            && (accDetails.US_WSREMS__Status__c== 'Disenrolled' || accDetails.US_WSREMS__Status__c=='Inactive')
            && (accDetails.Sub_Status__c=='Noncompliant' || accDetails.Sub_Status__c=='Abuse, Misuse or Diversion')
            && (caseId.status == 'Complete')
            && (caseId.US_WSREMS__Outcome__c =='Complete')
            && (caseId.Approval_Status__c !='Approved') &&(caseId.Approval_Status__c !='Rejected')
            ){                
                Approval.ProcessSubmitRequest requestApp = new Approval.ProcessSubmitRequest();
                //Pass the object recordId 
                requestApp.setObjectId(caseId.Id);
                requestApp.setProcessDefinitionNameOrId('Reenrollment_Approval');
                requestApp.setSkipEntryCriteria(true);
                
                //submit the approval request
                Approval.ProcessResult processResult = Approval.process(requestApp);      
        }
         
        }
        }//if conditions
    } // End of submitApprovalProcess
    
     /******************************************
  Method Name : assignProgram
  Description : assign program based on program picllist value
  *******************************************************/ 
  public static void assignProgram(list<case> newCaseList){
    Map<String,US_WSREMS__REMS_Program__c> programMap = SYN_CommonUtility.getActiveProgramIds();
    Map<Id,String> caseRecordTypeMap = REMSUtility.retrieveRecTypeIdDeveloperName(REMSAppLiterals.CASE_OBJECT);
        for(case c :newCaseList){
           if(c.US_WSREMS__Program_Picklist__c != null && c.US_WSREMS__REMS_Program__c == null && programMap.containsKey(c.US_WSREMS__Program_Picklist__c)){
               c.US_WSREMS__REMS_Program__c = programMap.get(c.US_WSREMS__Program_Picklist__c).Id;
           }
           if(c.US_WSREMS__Program_Picklist__c != null && c.Program_Record_Type_Control__c != c.US_WSREMS__Program_Picklist__c +'-'+mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName()) {
             c.Program_Record_Type_Control__c = c.US_WSREMS__Program_Picklist__c +'-'+mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName();
           }
            
           if(c.US_WSREMS__Program_Picklist__c != maciProgram  && c.US_WSREMS__Program_Picklist__c != soxProgram){
            // prepopulate requestory type based on stake holder for Disenrollment case
            if(caseRecordTypeMap.get(c.RecordTypeId) =='Deactivation' && c.US_WSREMS__Requestor_Type__c == null){
              c.US_WSREMS__Requestor_Type__c = c.Account_Record_Type__c;
            }
               
        }
    }
}


    /* Below method is for updating Account status and Sub status values from Disenrollment case : Aneesha(BT6825-257)*/
    public static void updateAccountStatus(list<case> newCaseLst){
        Id disenrollmentRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Deactivation').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        
        for(case cse: newCaseLst){
            Account acc = new Account();
            acc.id = cse.US_WSREMS__Participant__c;
            if(cse.RecordTypeId == disenrollmentRecordTypeId){
                if(cse.Status == 'Complete' && cse.US_WSREMS__Outcome__c == 'Complete' && cse.US_WSREMS__Requestor_Type__c =='Pharmacy Participant' ){
                    acc.US_WSREMS__Status__c = 'Inactive';
                    acc.Sub_Status__c = cse.US_WSREMS__Deactivation_Reason__c;
                } 
                else if(cse.Status == 'Complete' && cse.US_WSREMS__Outcome__c == 'Complete' && cse.US_WSREMS__Requestor_Type__c !='Pharmacy Participant'){
                    acc.US_WSREMS__Status__c = 'Disenrolled';
                    acc.Sub_Status__c = cse.US_WSREMS__Deactivation_Reason__c;
                } 
                accList.add(acc);
            } // End of cse.recordtypeid comparison
        }
        if(!accList.isEmpty() ){
            update accList;
        }
    }  


     /* BelupdateAccountMonitorow method is for Account field update named Monitor Participant from Case
     * It is a part of Story BT6825-290: RMR Patient Alert: 
     * Developed by: @Wilco Ashish Y
     */
      
     public static void updateAccountMonitor(list<case> newCase){
        Id prescriberCOIRectypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_COI').getRecordTypeId();
        Id rmrRectypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
        List<Account> updateAccount = new List<Account>();
        
        for(Case caselist : newCase ){ 
            
            if(caselist.Case_Record_Type_Name__c == 'Risk Management Report' && caselist.US_WSREMS__Patient__c !=null
                && caselist.status =='Complete' && caselist.US_WSREMS__Outcome__c == 'Complete'){
                if(caselist.SYN_Should_patient_be_monitored__c == 'Yes'){                
                    Account acc = new Account();
                    acc.id = caselist.US_WSREMS__Patient__c;
                    acc.Monitor_Participant__c = true;
                    updateAccount.add(acc);
                 } 
                
            }//End of if Risk management report condition
            if(caselist.RecordTypeId == rmrRectypeId && caselist.SYN_Prescriber__c !=null && caselist.status =='Complete' && caselist.US_WSREMS__Outcome__c == 'Complete'){
                if(caselist.Should_prescriber_be_monitored__c == 'Yes'){                
                     Account acc = new Account();
                     acc.id = caselist.SYN_Prescriber__c;
                     acc.Monitor_Participant__c = true;
                     updateAccount.add(acc);
                  } 
             }else if(caselist.RecordTypeId == prescriberCOIRectypeId && caselist.US_WSREMS__Participant__c !=null ){
                 if(caselist.Should_prescriber_be_monitored__c == 'No'){                
                     Account acc = new Account();
                     acc.id = caselist.US_WSREMS__Participant__c;
                     acc.Monitor_Participant__c = False;
                     updateAccount.add(acc);
                 }
             }
            
            if(caselist.Case_Record_Type_Name__c == 'Change of Information' && caselist.US_WSREMS__Participant__c !=null){
                
                if(caselist.SYN_Should_patient_be_monitored__c == 'No'){                
                    Account acc = new Account();
                    acc.id = caselist.US_WSREMS__Participant__c;
                    acc.Monitor_Participant__c = False;
                    updateAccount.add(acc);
                } 
             }//End of if Change of Information condition
                        
            }
            update updateAccount;
        
     } // end of updateAccountMonitor
     
     
    /******************************************
    Method Name : UpdateAccountAndServiceStatus
    Description : update Account and Service Status based on service
    *******************************************************/ 
  public static void UpdateAccountAndServiceStatus(list<case> newCaseList,Map<Id,case> oldCaseMap){
    Id prescriberEnrollmentRecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
    Id prescriberPersonAccountRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_Person_Account');
    Id inPatientPharmacyAccountEnrollRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Inpatient_Pharmacy');
    Id inPatientPharmacyParticipantAccountRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Pharmacy_Participant_Account');
    Id inPatientPharmacyAccountRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Pharmacy_Account');
    Id PatientEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');
    Id PatientDisEnrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Deactivation');
    Id COIenrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_COI');
    Id PatientReenrollmentCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Reenrollment');
    Id outPatientPharmacyAccountEnrollRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Outpatient_Pharmacy');

    Set<Id> AccountIds = new Set<Id>();
    Set<Id> RemsServiceIds = new Set<Id>();
    Set<Id> DisenrolledAccountIds = new Set<Id>();
    Set<Id> patientServiceIds = new Set<Id>();
    
    Set<Id> inPatientpharmcyAccountIds = new Set<Id>();
    Set<Id> outPatientpharmcyAccountIds = new Set<Id>();
    Set<Id> authRepAccountIds = new Set<Id>();
    List<Account> accountListToUpdate = new List<Account>();

        for(case c :newCaseList){

          if(c.Status == 'Complete' && c.US_WSREMS__Program_Picklist__c == 'Macitentan REMS' && c.US_WSREMS__Channel__c == 'Portal'){  

                if(oldCaseMap == null || (oldCaseMap != null && c.Status == 'Complete' && oldCaseMap.get(c.Id).Status != 'Complete') || (c.US_WSREMS__REMS_Service_Summary__c != oldCaseMap.get(c.Id).US_WSREMS__REMS_Service_Summary__c)){

                  // Prescriber Enrollment
                  if(c.recordTypeId == prescriberEnrollmentRecTypeId && c.SYN_Prescriber__c != null && c.US_WSREMS__REMS_Service_Summary__c != null){
                        AccountIds.add(c.SYN_Prescriber__c);
                        RemsServiceIds.add(c.US_WSREMS__REMS_Service_Summary__c);
                  }
                  // prescribver person account
                        if(c.recordTypeId == prescriberPersonAccountRecTypeId && c.US_WSREMS__REMS_Service_Summary__c != null){
                            RemsServiceIds.add(c.US_WSREMS__REMS_Service_Summary__c);
                        }
                        
                        //Pharamcy Account 
                         if(c.recordTypeId == inPatientPharmacyAccountEnrollRecTypeId && c.SYN_Pharmacy__c!= null && c.US_WSREMS__REMS_Service_Summary__c != null){
                            AccountIds.add(c.SYN_Pharmacy__c);
                            RemsServiceIds.add(c.US_WSREMS__REMS_Service_Summary__c);
                        }
                        
                        // Pharmacy Participant Account
                        if(c.recordTypeId == inPatientPharmacyParticipantAccountRecTypeId  && c.US_WSREMS__REMS_Service_Summary__c != null){
                            RemsServiceIds.add(c.US_WSREMS__REMS_Service_Summary__c);
                        }
                        
                        // Pharmacy Account Service
                        if(c.recordTypeId == inPatientPharmacyAccountRecTypeId && c.US_WSREMS__REMS_Service_Summary__c != null){
                            RemsServiceIds.add(c.US_WSREMS__REMS_Service_Summary__c);
                        }
                        
                        // patient Enrollment Case Record Type Id
                        if(c.recordTypeId == PatientEnrollmentCaseRecTypeId && c.US_WSREMS__REMS_Service_Summary__c != null && c.US_WSREMS__Patient__c != null){
                            AccountIds.add(c.US_WSREMS__Patient__c);
                            RemsServiceIds.add(c.US_WSREMS__REMS_Service_Summary__c);
                            patientServiceIds.add(c.US_WSREMS__REMS_Service_Summary__c);
                        }
                        
                        // DisPatientEnrollment (Deactivation) Case Record Type Id
                        if(c.recordTypeId == PatientDisEnrollmentCaseRecTypeId && c.US_WSREMS__REMS_Service_Summary__c != null && c.US_WSREMS__Participant__c != null){
                            //DisenrolledAccountIds.add(c.US_WSREMS__Participant__c);
                            RemsServiceIds.add(c.US_WSREMS__REMS_Service_Summary__c);
                            
                            Account acc = new Account (Id=c.US_WSREMS__Participant__c);
                            acc.US_WSREMS__Status__c = 'Disenrolled';
                            acc.Sub_Status__c = c.US_WSREMS__Deactivation_Reason__c;
                            accountListToUpdate.add(acc);
                            
                        }
                        
                        // Prescriber_COI Case Record Type Id
                        if(c.recordTypeId == COIenrollmentCaseRecTypeId && c.US_WSREMS__REMS_Service_Summary__c != null ){
                        RemsServiceIds.add(c.US_WSREMS__REMS_Service_Summary__c);
                        }
                        
                        // Patient Reenrollment Case Record Type Id
                        if(c.recordTypeId == PatientReenrollmentCaseRecTypeId  && c.US_WSREMS__REMS_Service_Summary__c != null ){
                        RemsServiceIds.add(c.US_WSREMS__REMS_Service_Summary__c);
                        AccountIds.add(c.US_WSREMS__Patient__c);
                        patientServiceIds.add(c.US_WSREMS__REMS_Service_Summary__c);
                        }
                  
                }
                
            }
                // updating pharmcy type on pharmcy account and Ar Catergory , user type on Pharmcy participant account 
                if(c.Status == 'Complete' && c.US_WSREMS__Program_Picklist__c == 'Macitentan REMS' && c.US_WSREMS__Channel__c != 'Portal' && (oldCaseMap == null || (oldCaseMap != null && c.Status == 'Complete' && oldCaseMap.get(c.Id).Status != 'Complete'))){
            
                    if(c.recordTypeId == inPatientPharmacyAccountEnrollRecTypeId && c.SYN_Pharmacy__c!= null && c.SYN_Authorized_Rep__c != null){
                        inPatientpharmcyAccountIds.add(c.SYN_Pharmacy__c);
                        authRepAccountIds.add(c.SYN_Authorized_Rep__c);
                        
                    }
                                
                    if(c.recordTypeId == outPatientPharmacyAccountEnrollRecTypeId  && c.SYN_Pharmacy__c!= null && c.SYN_Authorized_Rep__c != null){
                        outPatientpharmcyAccountIds.add(c.SYN_Pharmacy__c);
                        authRepAccountIds.add(c.SYN_Authorized_Rep__c);
                    }
                }
        }

        if(!AccountIds.isEmpty()){
            SYN_CaseTriggerHelper.updatePortalAccountStatus(AccountIds);
        }

        if(!RemsServiceIds.isEmpty()){ 
            SYN_CaseTriggerHelper.updatePortalREMSServiceStatus(RemsServiceIds);
        }

        if(!accountListToUpdate.isEmpty()){
            database.update(accountListToUpdate,false);
        }
        if(!patientServiceIds.isEmpty()){
            setTaskToComplete(patientServiceIds);
        }
        if(!inPatientpharmcyAccountIds.isEmpty()){
            updatePharmacyType(inPatientpharmcyAccountIds,'Inpatient');
        }
        
        if(!outPatientpharmcyAccountIds.isEmpty()){
             updatePharmacyType(outPatientpharmcyAccountIds,'Outpatient');
        }
        
        if(!authRepAccountIds.isEmpty()){
            updateArCategory(authRepAccountIds);
        }

    }
    
    /*
    * Method Name : createChecklists
    * Description : create checklist for Macitentan REMS program
    * createdBy : Priya
    * createdDate : 1/26/2023
    */
    public static void createChecklists(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        List<Case> caseToCreateChecklist = new List<Case>();

        for(Case c : newCaseMap.values()){
            if(c.Status == 'Complete' && ((oldCaseMap != null && oldCaseMap.get(c.Id).Status != 'Complete') || oldCaseMap == null) && c.US_WSREMS__Program_Picklist__c == 'Macitentan REMS'){
                caseToCreateChecklist.add(c);
            }
        }
       
        SYN_CaseTriggerHelper.createChecklist(caseToCreateChecklist);
    }

    /*
    * Method Name : piaskyAffiliatedwithCertifiedPharmacy
    * Description :check affiliated with a certified pharmacy for PiaSky REMS program
    * createdBy : Ismail
    * createdDate : 17/05/2024
    */

    public static void piaskyAffiliatedwithCertifiedPharmacy(list<case> newCaseList, Map<Id,Case> oldCaseMap) {
        Set<Id> paiskypharmacyParticipantIds = new Set<Id>(); //piasky change by ismail
        Set<Id> piaskyPharmacyIds = new Set<Id>();
        List<US_WSREMS__Affiliation__c> affiliationList = new List <US_WSREMS__Affiliation__c>();
        Id RDACaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();


        for(case cs : newCaseList) {
           if(cs.RecordTypeId==RDACaseRecordTypeId && cs.US_WSREMS__Program_Picklist__c == Label.PiaSky_REMS_Program_Name) {
            paiskypharmacyParticipantIds.add(cs.US_WSREMS__REMS_Authorized_Rep__c);
            piaskyPharmacyIds.add(cs.US_WSREMS__Pharmacy__c);
         } 
        }
        if(!paiskypharmacyParticipantIds.isEmpty()) {
            affiliationList = [SELECT Id, Status__c,US_WSREMS__Prescriber__c,US_WSREMS__isActive__c,US_WSREMS__Pharmacy_User__c, RecordType.Name, US_WSREMS__Pharmacy__c, US_WSREMS__Pharmacy__r.US_WSREMS__Status__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__isActive__c = True AND US_WSREMS__Pharmacy_User__c IN :paiskypharmacyParticipantIds  AND US_WSREMS__Pharmacy__c In : piaskyPharmacyIds];     
            
        }
        map<id,US_WSREMS__Affiliation__c> affiliationMap = new Map<Id,US_WSREMS__Affiliation__c>();
        if(!affiliationList.isEmpty()){
            for (US_WSREMS__Affiliation__c af : affiliationList) {
                if(af.US_WSREMS__isActive__c = true){
                    affiliationMap.put(af.US_WSREMS__Pharmacy_User__c,af);
                }
            }
        }
        for(case cs :newCaseList){
            if(cs.US_WSREMS__Program_Picklist__c == Label.PiaSky_REMS_Program_Name &&
               cs.Status == 'Complete' && (oldCaseMap == null || 
                                           (oldCaseMap != null && cs.US_WSREMS__REMS_Authorized_Rep__c != oldCaseMap.get(cs.Id).US_WSREMS__REMS_Authorized_Rep__c))
               && cs.US_WSREMS__REMS_Authorized_Rep__c != null && cs.RecordTypeId==RDACaseRecordTypeId && 
               (affiliationList.isEmpty() || 
                (affiliationMap!= null && affiliationMap.containsKey(cs.US_WSREMS__REMS_Authorized_Rep__c) && 
                 (
                     affiliationMap.get(cs.US_WSREMS__REMS_Authorized_Rep__c).US_WSREMS__Pharmacy__r.US_WSREMS__Status__c != 'certified' 
                     || affiliationMap.get(cs.US_WSREMS__REMS_Authorized_Rep__c).US_WSREMS__Pharmacy__c ==null 
                     || affiliationMap.get(cs.US_WSREMS__REMS_Authorized_Rep__c).US_WSREMS__Pharmacy__c !=cs.US_WSREMS__Pharmacy__c)))){
                         cs.addError('Pharmacy Participant must be affiliated with a certified pharmacy.');
                     }
        }
        
    }
 
    /*
    * Method Name : affiliatedwithCertifiedPharmacy
    * Description :check affiliated with a certified pharmacy for Macitentan REMS program
    * createdBy : Samidurai
    * createdDate : 14/02/2023
    */
    
   public static void affiliatedwithCertifiedPharmacy(list<case> newCaseList, Map<Id,Case> oldCaseMap) {
    Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
    Id patientPregnancyTestCaseRecordTypeId = caseRecordTypeMap.get('Patient_Pregnancy_Test');
    Id RDACaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();
    Id patientCounselingChecklistCaseRecordTypeId = caseRecordTypeMap.get('Patient_Counseling_Checklist');
    Set<Id> pharmacyParticipantIds = new Set<Id>();
    Set<Id> prescriberIds = new Set<Id>();
    Set<Id> pharmacyIds = new Set<Id>();
    Map<Id, Case> caseMap = new Map<Id, Case>();
    List<US_WSREMS__Affiliation__c> affiliationList = new List <US_WSREMS__Affiliation__c>();
    String pharmacyParticipantId;
    Boolean patientpregRecord = false;
    Boolean RDACaseRecord = false;
    
    for (Case cs : newCaseList) {  

        if ((cs.RecordTypeId == patientPregnancyTestCaseRecordTypeId ||cs.RecordTypeId==RDACaseRecordTypeId) && cs.Pharmacy_Participant__c != null && (oldCaseMap == null || (oldCaseMap != null && cs.Pharmacy_Participant__c != oldCaseMap.get(cs.Id).Pharmacy_Participant__c)) && cs.US_WSREMS__Program_Picklist__c == 'Macitentan REMS' && cs.Status == 'Complete') {
            patientpregRecord = true;
            pharmacyParticipantIds.add(cs.Pharmacy_Participant__c); 
            if(cs.US_WSREMS__Pharmacy__c != null){ 
                pharmacyIds.add(cs.US_WSREMS__Pharmacy__c);
                RDACaseRecord = true;
            }
            if(cs.SYN_Pharmacy__c!= null){
                pharmacyIds.add(cs.SYN_Pharmacy__c); 
                RDACaseRecord = true;
            }
        }
            if((cs.RecordTypeId == patientCounselingChecklistCaseRecordTypeId  && cs.US_WSREMS__Program_Picklist__c == 'Macitentan REMS' )){
            if(cs.Pharmacy_Participant__c != null){ 
            pharmacyParticipantIds.add(cs.Pharmacy_Participant__c);
            }
            if(cs.US_WSREMS__Pharmacy__c != null){ 
                pharmacyIds.add(cs.US_WSREMS__Pharmacy__c);
                RDACaseRecord = false;
            }
            if(cs.SYN_Pharmacy__c!= null){
                pharmacyIds.add(cs.SYN_Pharmacy__c); 
                RDACaseRecord = false;
            }
        }
    }
    
    if(!pharmacyParticipantIds.isEmpty()){
        if(patientpregRecord == true && RDACaseRecord == true){
            affiliationList = [SELECT Id,Status__c, US_WSREMS__Prescriber__c, US_WSREMS__Pharmacy_User__c, RecordType.Name, US_WSREMS__Pharmacy__c, US_WSREMS__Pharmacy__r.US_WSREMS__Status__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Pharmacy_User__c IN :pharmacyParticipantIds AND US_WSREMS__Pharmacy__c IN : pharmacyIds]; 
        }else{   
             affiliationList = [SELECT Id, Status__c,US_WSREMS__Prescriber__c,US_WSREMS__Pharmacy_User__c, RecordType.Name, US_WSREMS__Pharmacy__c, US_WSREMS__Pharmacy__r.US_WSREMS__Status__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Pharmacy_User__c IN :pharmacyParticipantIds];     
    }
}

    map<id,US_WSREMS__Affiliation__c> affiliationMap = new Map<Id,US_WSREMS__Affiliation__c>();
    if(!affiliationList.isEmpty()){
        for (US_WSREMS__Affiliation__c af : affiliationList) {
            affiliationMap.put(af.US_WSREMS__Pharmacy_User__c,af);
        }
    }

    for(case cs :newCaseList){
        if(cs.US_WSREMS__Program_Picklist__c == 'Macitentan REMS' && cs.Status == 'Complete' && (oldCaseMap == null || (oldCaseMap != null && cs.Pharmacy_Participant__c != oldCaseMap.get(cs.Id).Pharmacy_Participant__c))&& cs.Pharmacy_Participant__c != null &&  cs.RecordTypeId == patientPregnancyTestCaseRecordTypeId && (affiliationList.isEmpty() || (affiliationMap!= null && affiliationMap.containsKey(cs.Pharmacy_Participant__c) && ( affiliationMap.get(cs.Pharmacy_Participant__c).US_WSREMS__Pharmacy__r.US_WSREMS__Status__c != 'certified' || affiliationMap.get(cs.Pharmacy_Participant__c).US_WSREMS__Pharmacy__c ==null)))){
            cs.addError('Pharmacy Participant must be Active and affiliated with a certified pharmacy.');
        }
        if(cs.US_WSREMS__Program_Picklist__c == 'Macitentan REMS' && cs.Status == 'Complete' && (oldCaseMap == null || (oldCaseMap != null && cs.Pharmacy_Participant__c != oldCaseMap.get(cs.Id).Pharmacy_Participant__c))
           && cs.Pharmacy_Participant__c != null && cs.RecordTypeId==RDACaseRecordTypeId && (affiliationList.isEmpty() || (affiliationMap!= null && affiliationMap.containsKey(cs.Pharmacy_Participant__c) && ( affiliationMap.get(cs.Pharmacy_Participant__c).US_WSREMS__Pharmacy__r.US_WSREMS__Status__c != 'certified' || affiliationMap.get(cs.Pharmacy_Participant__c).US_WSREMS__Pharmacy__c ==null || affiliationMap.get(cs.Pharmacy_Participant__c).US_WSREMS__Pharmacy__c !=cs.US_WSREMS__Pharmacy__c)))){
               cs.addError('Pharmacy Participant must be Active and affiliated with a certified pharmacy.');
           }
       
            if((cs.US_WSREMS__Program_Picklist__c == 'Macitentan REMS' && cs.Pharmacy_Participant__r.US_WSREMS__Status__c != 'Active' && cs.Pharmacy_Participant__c != null && cs.RecordTypeId == patientCounselingChecklistCaseRecordTypeId)
               && (oldCaseMap == null || (oldCaseMap != null && cs.Pharmacy_Participant__c != oldCaseMap.get(cs.Id).Pharmacy_Participant__c))
            && (affiliationMap.isEmpty() || (affiliationMap!= null && affiliationMap.containsKey(cs.Pharmacy_Participant__c) && ( affiliationMap.get(cs.Pharmacy_Participant__c).US_WSREMS__Pharmacy__r.US_WSREMS__Status__c != 'Certified' || affiliationMap.get(cs.Pharmacy_Participant__c).Status__c != 'Active' ||affiliationMap.get(cs.Pharmacy_Participant__c).US_WSREMS__Pharmacy__c ==null)))){
                                               cs.addError(System.Label.MACI_Pharmcy_Staff_PCCL_Validation);
                                           }
        
    
    }
    }
/******************************************
  Method Name : ValidateKnowledgeAssesment
  CreatedBy: Sarath R Date:07-02-2023
  Description : User story details:
 *******************************************************/ 
public static void validateKnowledgeAssessment(List<Case> newcaselist)
{
    if(UserInfo.getUserType() != 'PowerCustomerSuccess')
    {
        Id kAACaseRecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', SYN_Utilitycls.Knowlege_Assessment_A);
        Id kABCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', SYN_Utilitycls.Knowlege_Assessment_B);
        Id programId= SYN_CommonUtility.SOXprogramId();
        set<String> remsServiceNameSet = new set<String>();
        set<String> existedCaseNumbers = new set<String>();
        for(case cs: newcaselist)
        {
            if(cs.US_WSREMS__REMS_Program__c == programId)
                remsServiceNameSet.add(cs.US_WSREMS__REMS_Service_Summary__c);
                existedCaseNumbers.add(cs.CaseNumber);
        }
        if(remsServiceNameSet.size()>0)
        {
            List<Case> existedKAcaselist =[select Id,US_WSREMS__REMS_Service_Summary__r.Name,Pharmacy_Participant__c,Pharmacy_Employee_Type__c,SYN_Pharmacy__c from Case Where (RecordTypeId=:kAACaseRecTypeId OR RecordTypeId=:kABCaseRecTypeId) AND US_WSREMS__REMS_Service_Summary__c IN: remsServiceNameSet AND CaseNumber NOT IN:existedCaseNumbers];
            Map<String, Case> mapOfServiceVsCase = new Map<String, Case>();
            for(case cs:existedKAcaselist)
            {
                if(!mapOfServiceVsCase.containsKey(cs.US_WSREMS__REMS_Service_Summary__c))
                {
                    mapOfServiceVsCase.put(cs.US_WSREMS__REMS_Service_Summary__c,cs);
                }   
                
            }
            if(mapOfServiceVsCase !=null && !mapOfServiceVsCase.isEmpty())
            {       
                for(case cs: newcaselist)
                {

                    set<String> valuesetCaseA;
                    set<String> valuesetCaseB;
                    if(cs.US_WSREMS__REMS_Program__c == programId)
                    {
                        //Added by surekha to resolve the patient account creation error.
                        if( cs.US_WSREMS__REMS_Service_Summary__c != null && mapOfServiceVsCase.get(cs.US_WSREMS__REMS_Service_Summary__c)!=null){
                            if(String.isNotBlank(mapOfServiceVsCase.get(cs.US_WSREMS__REMS_Service_Summary__c).Pharmacy_Employee_Type__c))
                            {
                                valuesetCaseA = new set<String>(mapOfServiceVsCase.get(cs.US_WSREMS__REMS_Service_Summary__c).Pharmacy_Employee_Type__c.split(';'));
                                valuesetCaseA.remove('Pharmacy Staff');
                            }       
                            else{valuesetCaseA = new set<String>();}           
                            if(String.isNotBlank(cs.Pharmacy_Employee_Type__c))
                            {
                                valuesetCaseB = new set<String>(cs.Pharmacy_Employee_Type__c.split(';'));
                                valuesetCaseB.remove('Pharmacy Staff');
                            } 
                            else{valuesetCaseB = new set<String>();}                        
                            if(cs.Pharmacy_Participant__c != mapOfServiceVsCase.get(cs.US_WSREMS__REMS_Service_Summary__c).Pharmacy_Participant__c || (!valuesetCaseA.equals(valuesetCaseB)) || cs.SYN_Pharmacy__c != mapOfServiceVsCase.get(cs.US_WSREMS__REMS_Service_Summary__c).SYN_Pharmacy__c)
                            {
                                cs.addError('The pharmacy, pharmacy participant, and participant type must match the first Knowledge Assessment created for this service.');
                            }  
                        }
                        
                        
                    }   
                    
                }
                
                
            }
        }
    }
}

/*
    * Method Name : updateCaseDateonComplete
    * Description : Update Case Date fields  on Complete
    * createdBy : Priya
    * createdDate : 3/8/2023
    */
    public static void updateCaseDateonComplete(List<Case> newCase, Map<Id,Case> oldMap){
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        Id patientPregnancyTestCaseRecordTypeId =caseRecordTypeMap.get('Patient_Pregnancy_Test');
        Id patientcounsellingRTId = caseRecordTypeMap.get('Patient_Counseling_Checklist');
        Id disEnrollmentRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deactivation').getRecordTypeId();
        Id PAERecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PAE_PC_MI').getRecordTypeId();
        List<Case> caseToUpdate = new List<Case>();

        for(Case c : newCase){
            if(c.Status == 'Complete' && ((oldMap != null && oldMap.get(c.Id).Status != 'Complete') || oldMap == null) && c.US_WSREMS__Program_Picklist__c == 'Macitentan REMS'){
                if(c.RecordTypeId == patientPregnancyTestCaseRecordTypeId){
                    c.Date_of_Confirmation__c = System.today();
                }
                if(c.RecordTypeId == patientcounsellingRTId){
                    c.Counseling_Completion_Date__c = System.today();
                }
                if(c.RecordTypeId == disEnrollmentRTID){
                    c.US_WSREMS__Deactivation_Date__c = System.today();
                }
                if(c.RecordTypeId == PAERecordTypeId){
                    c.Date_of_Report__c = System.today();
                }
            }
        }

        
    }
    //732 user story
    public static void updateAccountUserType(List<Case> newList, Map<Id, Case> oldMap) { 
        Map<Id, Set<String>> accountUserTypeMap = new Map<Id, Set<String>>();
        Id kAACaseRecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', SYN_Utilitycls.Knowlege_Assessment_A);
        Id kABCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', SYN_Utilitycls.Knowlege_Assessment_B);
        for(Case caseIns : newList) {
            if(caseIns.US_WSREMS__Program_Picklist__c == Label.Sodium_Oxybate_REMS_Program_Name && (caseIns.RecordTypeId == kAACaseRecTypeId || caseIns.RecordTypeId == kABCaseRecTypeId) 
                && caseIns.Status == 'Complete' &&  caseIns.US_WSREMS__Outcome__c == 'Pass' && caseIns.Pharmacy_Participant__c != NULL 
                    && caseIns.Pharmacy_Employee_Type__c != NULL && (oldMap == null || (oldMap != NULL 
                        && (oldMap.get(caseIns.Id).Pharmacy_Employee_Type__c != caseIns.Pharmacy_Employee_Type__c || oldMap.get(caseIns.Id).Status != caseIns.Status || oldMap.get(caseIns.Id).US_WSREMS__Outcome__c != caseIns.US_WSREMS__Outcome__c) ))) {
                accountUserTypeMap.put(caseIns.Pharmacy_Participant__c, new Set<String>());
            }
        }
    
      if(accountUserTypeMap.size() > 0) {
            for(case c : [Select Id,Pharmacy_Participant__c, Pharmacy_Employee_Type__c FROM Case 
                          WHERE Pharmacy_Participant__c IN: accountUserTypeMap.keySet() 
                          AND (RecordTypeId = :kAACaseRecTypeId OR RecordTypeId = :kABCaseRecTypeId) 
                          AND Pharmacy_Employee_Type__c != NULL
                          AND Status = 'Complete' 
                          AND US_WSREMS__Outcome__c = 'Pass']) {
                              accountUserTypeMap.get(c.Pharmacy_Participant__c).addAll(c.Pharmacy_Employee_Type__c.split(';'));
                          }
                        
            List<Account> accList = new List<Account>();
    
            for(Id accountIdd : accountUserTypeMap.keySet()) {
                Account acc= new Account();
                acc.Id = accountIdd;
                acc.SYN_User_Type__c = String.join(new List<String>(accountUserTypeMap.get(accountIdd)),';');
                accList.add(acc);
            }
            if(accList.size()>0) {
                update accList;
            }
        }
    }
    public static Map<String, Map<Id, List<Case>>> filterCasesByPrgm(List<Case> newList){

        Map<String, Map<Id, List<Case>>> prgmRTAndCaseMap = new Map<String, Map<Id, List<Case>>>();  
        prgmRTAndCaseMap = new Map<String, Map<Id, List<Case>>>();
        string programName;

        for(Case CaseRec : newList){

            if(CaseRec.US_WSREMS__Program_Picklist__c != null){
                programName = CaseRec.US_WSREMS__Program_Picklist__c;
            }else{
                programName = CaseRec.US_WSREMS__Program_Name__c;
            }

            if(!prgmRTAndCaseMap.containsKey(programName)){
                prgmRTAndCaseMap.put(programName, new Map<Id, List<Case>>());    
            }

            Map<Id, List<Case>> existingRTAndCaseMap = prgmRTAndCaseMap.get(programName);

            if(!existingRTAndCaseMap.containsKey(CaseRec.RecordTypeId)){

            existingRTAndCaseMap.put(CaseRec.RecordTypeId,new List<Case>{});
            }            
            existingRTAndCaseMap.get(CaseRec.RecordTypeId).add(CaseRec);
            prgmRTAndCaseMap.put(programName, existingRTAndCaseMap);
                 
        }           
        return prgmRTAndCaseMap; 
    }
    
     // Method to set the Account case to complete and outcome to complete.
    public static void setAccountCaseStatusToComplete(list<case> newCaseList){
        for(case c :newCaseList){
            if(((mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'SYN_Patient_Person_Account')||(mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'General_Contact')||(mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'Office_Contact')||(mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'Pharmacy_Account')||(mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'SYN_Distributor_Account')||(mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'Prescriber_Person_Account')||(mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'Pharmacy_Participant_Account'))&& c.US_WSREMS__Program_Picklist__c == 'Macitentan REMS'){
                c.Status = 'Complete';
                c.US_WSREMS__Outcome__c = 'Complete';
            }
            
            if(c.US_WSREMS__Channel__c =='Portal' && c.US_WSREMS__REMS_Program__c != null && c.US_WSREMS__Program_Name__c == Label.Macitentan_REMS_Program_Name && c.US_WSREMS__NPI__c != null && SYN_Utilitycls.CASE_ENROLLMENT_RECTYPE_SET_VEEVA.contains(mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName())){
                c.US_WSREMS__Status__c ='Active';
            }
        }
    } 
   

     // Method to create RCA RRS/Case/Task
     public static void RootCauseAnalysis(List<Case> newCases , Map<Id,Case> oldMap ){
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        
        String CaseTypeStr; 
        List<Case> RCA_Case_Lst = new List<case>();
        participantIdtoPersonAccMap = new Map<Id,Id>();

        for (case cse: newCases ){
            
            if (cse.US_WSREMS__Program_Picklist__c == 'Macitentan REMS' && cse.Status == 'Complete' && ( oldMap == null || oldMap.get(cse.Id).US_WSREMS__Outcome__c != cse.US_WSREMS__Outcome__c || oldMap.get(cse.Id).Status != cse.Status)  ){
                
                // PDA case to create Treatment Interruption RCA
                if (cse.RecordTypeId == mapCaseRcTyByDevName.get('PDA').getRecordTypeId()){
                    //As part of BT7433-2041 We are removing Unknown value here
                    if (cse.US_WSREMS__Outcome__c == 'Approved' && cse.Reason_for_Treatment_Interruption__c == 'Pregnancy test not completed' ){
                        CaseTypeStr = 'Treatment_Interruption'; 
                        participantIdtoPersonAccMap.put(cse.US_WSREMS__Patient__c ,null);
                        RCA_Case_Lst.add(cse);
                    }
                } 
                // PAE_PC_MI case to create Pregnancy RCA 
                else if (cse.RecordTypeId == mapCaseRcTyByDevName.get('PAE_PC_MI').getRecordTypeId()){
                    if (cse.US_WSREMS__Outcome__c == 'Acknowledgment Pending' && (cse.SYN_Type_of_Report__c  == 'Pregnancy' || cse.SYN_Type_of_Report__c == 'Pregnancy w/ Adverse Event') ){
                        CaseTypeStr = 'Pregnancy';
                        participantIdtoPersonAccMap.put(cse.US_WSREMS__Patient__c ,null); 
                        RCA_Case_Lst.add(cse);
                    }
                }
                //CRPS case to create Misclassification RCA
                else if (cse.RecordTypeId == caseRecordTypeMap.get('Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification')){
                    if (cse.US_WSREMS__Outcome__c == 'Misclassification' ){
                        CaseTypeStr = 'Misclassification';
                        participantIdtoPersonAccMap.put(cse.US_WSREMS__Patient__c ,null); 
                        RCA_Case_Lst.add(cse);
                    }
                }
                
            }
        }
        
        if (! participantIdtoPersonAccMap.keySet().isEmpty()){
            for (Account parId : [select Id ,PersonContactId  from Account where ID IN : participantIdtoPersonAccMap.keySet() ]){
                participantIdtoPersonAccMap.put(parId.Id , parId.PersonContactId);
            } 
        }

        if (!RCA_Case_Lst.isEmpty() && !String.isBlank(CaseTypeStr)){
            RCA_Automation.case_RCA(CaseTypeStr, RCA_Case_Lst );
        }
        
    } 
    
     // Method to set the Enrollment case outcome to complete.
    public static void setEnrollmentCaseOutcomeToComplete(list<case> newCaseList, Map<Id,Case> oldCaseMap){
        for(case c :newCaseList){
            if(c.US_WSREMS__Program_Picklist__c == Label.Macitentan_REMS_Program_Name && c.Status == 'Complete' && (oldCaseMap == null || (oldCaseMap != null && c.Status != oldCaseMap.get(c.Id).Status)) && 
            (mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'SYN_Inpatient_Pharmacy' || mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'SYN_Outpatient_Pharmacy' || mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'SYN_Distributor_Enrollment' || 
                mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'Prescriber_enrollment' || mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'Patient_Enrollement' || mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'Deactivation' )){
                c.US_WSREMS__Outcome__c = 'Complete';
            }
        } 
    } 

    //977 Related Changes
    public static void remsServiceUpdate(List<Case> newCaseLst,Map<Id,case> oldCaseMap){
        id caseRiskManagementRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
        id TaskManualRecordtypeId = Schema.SObjectType.task.getRecordTypeInfosByDeveloperName().get('Manual_Task').getRecordTypeId();
        Boolean isNatureOfReportValid = FALSE;

        Map<Id,case> remsPersonContactId = new Map<Id,case>();
        List<Task> newTask = new List<Task>();
        List<String> NatureOfReportValuesList = new List<String> {'Misuse','Abuse','Diversion','Product tampering by an individual in contact with product',
            'Counterfeit/contaminated product','Suicide attempt and/or ideation and/or death',
            'Treatment Delay/Interruption'};

                for(case cs :[select id,US_WSREMS__Participant__r.PersonContactId from case where id = : newCaseLst])
            {
                remsPersonContactId.put(cs.id,cs);
            }


        Group TaskOwner = [Select id
                           from Group
                           Where DeveloperName = 'SOX_Task_Queue'
                           AND Type = 'Queue' LIMIT 1];
        // NextstartDate of Businesshours
        Date dueDate = SYN_CaseTriggerHelper.getNextBusinessDate(System.now(),System.Label.SOXBusinessHoursName);

        for(Case CaseRec : newCaseLst){
            isNatureOfReportValid = FALSE;
            if(CaseRec.US_WSREMS__Program_Picklist__c == Label.Sodium_Oxybate_REMS_Program_Name && CaseRec.RecordTypeId == caseRiskManagementRecordTypeId
               && CaseRec.Status == 'Complete' && CaseRec.US_WSREMS__Outcome__c == 'Complete' && CaseRec.US_WSREMS__REMS_Service_Summary__c != NULL&&
               (oldCaseMap==null || (oldCaseMap != NULL && oldCaseMap.get(CaseRec.Id).Status != CaseRec.Status && oldCaseMap.get(CaseRec.Id).US_WSREMS__Outcome__c != CaseRec.US_WSREMS__Outcome__c)))
            {

                US_WSREMS__REMS_Service_Summary__c remsService = new US_WSREMS__REMS_Service_Summary__c();
                remsService.id = CaseRec.US_WSREMS__REMS_Service_Summary__c;


                if(CaseRec.SYN_Nature_of_Report__c != NULL) {

                    for(String natureOfReport : CaseRec.SYN_Nature_of_Report__c.split(';')) {
                        if(NatureOfReportValuesList.contains(natureOfReport )) {
                            isNatureOfReportValid = TRUE;
                        }
                    }
                }
                if(isNatureOfReportValid || CaseRec.PAE_associated_with_report__c == 'Yes'){
                    Task ts = new Task();
                    ts.Subject = 'Review and Submit PAE';
                    ts.OwnerId = TaskOwner.id;
                    ts.Type = 'Other';
                    ts.Status = 'Draft';
                    ts.WhatId= remsService.id;
                    ts.REMS_Program__c = 'Sodium Oxybate REMS';
                    ts.ActivityDate = dueDate;
                    ts.RecordTypeId = TaskManualRecordtypeId;
                    ts.WhoId = remsPersonContactId.get(CaseRec.id).US_WSREMS__Participant__r.PersonContactId;
                    newTask.add(ts);
                }
                if(CaseRec.SYN_Requesting_disenrollment__c == 'Yes'){
                    Task tsnew = new Task();
                    tsnew.Subject = 'Review Disenrollment';
                    tsnew.OwnerId = TaskOwner.id;
                    tsnew.Type = 'Other';
                    tsnew.Status = 'Draft';
                    tsnew.WhatId= remsService.id;
                    tsnew.REMS_Program__c = 'Sodium Oxybate REMS';
                    tsnew.ActivityDate = dueDate;
                    tsnew.RecordTypeId = TaskManualRecordtypeId;
                    tsnew.WhoId = remsPersonContactId.get(CaseRec.id).US_WSREMS__Participant__r.PersonContactId;
                    newTask.add(tsnew);

                   }
            }
        }


        if(newTask.size()>0){
            Insert newTask;
                    }
                 
           
        }
    // Method to complete task status.
    public static void setTaskToComplete(Set<Id> parentIds){
       List<Task> tasklistToUpdate = new List<Task>();
       List<Task> taskList = [SELECT Id,Status FROM Task WHERE WhatId != null AND WhatId IN : parentIds AND Status != 'Completed'];
       if(!taskList.isEmpty()){
           for(Task t : taskList){
               t.Status = 'Completed';
               tasklistToUpdate.add(t);
           }
       }
       
       if(!tasklistToUpdate.isEmpty()){
           database.update(tasklistToUpdate,false);
       }
    } 
    
    // Method to update pharmacy type on pharmcy account.
    public static void updatePharmacyType(Set<Id> accountIds, String pharmcyType){
        List<Account> accountListToUpdate = new List<Account>();
        for(Account acc : [SELECT Id,Pharmacy_Type__c FROM Account WHERE Id IN : accountIds]){
            acc.Pharmacy_Type__c = pharmcyType;
            accountListToUpdate.add(acc);
        }
        
        if(!accountListToUpdate.isEmpty()){
            database.update(accountListToUpdate,false);
        }
       
    } 
    
    // Method to update Ar Caegory and user type on AR account.
    public static void updateArCategory(Set<Id> accountIds){
      List<Account> accountListToUpdate = new List<Account>();
      for(Account acc : [SELECT Id,SYN_User_Type__c,AR_Category__c FROM Account WHERE Id IN : accountIds]){
            acc.SYN_User_Type__c= 'Authorized Representative';
            acc.AR_Category__c = 'Primary';
            accountListToUpdate.add(acc);
        }
        
        if(!accountListToUpdate.isEmpty()){
            database.update(accountListToUpdate,false);
        }
    } 
    public static void updateReverseRDACaseStatus(list<case> newCaseList){
        Id ReverseRDARecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Reverse_RDA');
        Id RDARecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'PDA');
        Map<Id,case> oldcaseMap=new Map<Id,case>();
        Set<Id> remsServicesIDSet= New Set<Id>();
        Set<Id> participantIdSet = new Set<Id>();
        for(Case newCase:newCaseList){
            If(newCase.RecordTypeId == ReverseRDARecTypeId){
                remsServicesIDSet.add(newCase.US_WSREMS__REMS_Service_Summary__c);
                participantIdSet.add(newCase.X1_Pharmacy_Participant__c);
            }
        }
        Map<Id, Account> participantDetailsMap = fetchParticipantDetails(participantIdSet);
        if(remsServicesIDSet.size()>0){
            for(Case cs: [Select id, US_WSREMS__REMS_Service_Summary__c, RDA_Authorization_Code__c, US_WSREMS__DOB__c, Participant_FirstName__c, Participant_LastName__c,
                            US_WSREMS__Patient__c, RDA_Authorization_Code_Date__c FROM CASE WHERE US_WSREMS__REMS_Service_Summary__c IN:remsServicesIDSet AND RecordTypeId=: RDARecTypeId]) {
                oldcaseMap.Put(cs.US_WSREMS__REMS_Service_Summary__c,cs);
            }
            for(Case newCase : newCaseList){
                if(oldcaseMap.containsKey(newCase.US_WSREMS__REMS_Service_Summary__c)) {
                    Case oldCase = oldcaseMap.get(newCase.US_WSREMS__REMS_Service_Summary__c);

                    newCase.US_WSREMS__Patient__c = oldCase.US_WSREMS__Patient__c;
                    newCase.RDA_Authorization_Code__c = oldCase.RDA_Authorization_Code__c;
                    newCase.RDA_Authorization_Code_Date__c = oldCase.RDA_Authorization_Code_Date__c;
                    newCase.US_WSREMS__DOB__c = oldCase.US_WSREMS__DOB__c; 
                }
                if(participantDetailsMap.containsKey(newCase.X1_Pharmacy_Participant__c)) {
                    newCase.Participant_FirstName__c = participantDetailsMap.get(newCase.X1_Pharmacy_Participant__c).FirstName;
                    newCase.Participant_LastName__c = participantDetailsMap.get(newCase.X1_Pharmacy_Participant__c).LastName;
                }
            }
        }
    }

    private static Map<Id, Account> fetchParticipantDetails(Set<Id> participantIdSet) {
        return new Map<Id, Account>([Select id, FirstName, LastName FROM Account where Id IN: participantIdSet]);
    }
    
    public static void updateChannelonAccountFromCase(list<case> newCaseList){
        id patientEnrollmentCaseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');
        id prescriberEnrollmentCaseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        id distributorEnrollmentCaseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Distributor_Enrollment');
        id outpatientEnrollmentCaseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Outpatient_Pharmacy');
        id inpatientEnrollmentCaseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Inpatient_Pharmacy');
      Set<Id> accountIds = new Set<Id>();
       Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
       List<Case> caseList= new List<case>();
        for(Case cs : newCaseList){
           if(cs.US_WSREMS__Channel__c != null && cs.Status == 'Complete' && cs.US_WSREMS__Outcome__c == 'Complete' && cs.US_WSREMS__Participant__c!=null){
            
              accountIds.add(cs.US_WSREMS__Participant__c);
              caseList.add(cs);
            
        }
    }
       

       if(!accountIds.isEmpty()){
         Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, US_WSREMS__Channel__c, RecordTypeId FROM Account WHERE Id IN :accountIds]);
         
          for(Case c : caseList){
            Account relatedAccount = accountMap.get(c.US_WSREMS__Participant__c);
             
              if(relatedAccount != null){
                
                if(c.RecordTypeId == patientEnrollmentCaseRecordTypeId){
                    relatedAccount.US_WSREMS__Channel__c = c.US_WSREMS__Channel__c;
                }
                else if(c.RecordTypeId == prescriberEnrollmentCaseRecordTypeId){
                    relatedAccount.US_WSREMS__Channel__c = c.US_WSREMS__Channel__c;
                }
                  else if(c.RecordTypeId == distributorEnrollmentCaseRecordTypeId){
                    
                     relatedAccount.US_WSREMS__Channel__c=c.US_WSREMS__Channel__c;
                     
                 }
                 else if(c.RecordTypeId == outpatientEnrollmentCaseRecordTypeId){
                       relatedAccount.US_WSREMS__Channel__c=c.US_WSREMS__Channel__c;
                    
                 }
                 else if(c.RecordTypeId == inpatientEnrollmentCaseRecordTypeId){
                         relatedAccount.US_WSREMS__Channel__c=c.US_WSREMS__Channel__c;
                     
                 }
                
            }
        }
        try{
        update accountMap.values();
    }catch(exception e ){
        system.debug('----Error------'+e.getMessage());
    }
    }
}

 public static void populateSponserDate(List<Case> paeCasesList) {
    id paeCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PAE').getRecordTypeId();
    for(case cse : paeCasesList) {
        if(cse.RecordTypeId == paeCaseRecordTypeId && cse.status == 'complete' && (cse.US_WSREMS__Program_Picklist__c == Label.PiaSky_REMS_Program_Name || cse.US_WSREMS__Program_Picklist__c == Label.Tryvio_REMS_Program_Name)) {
            cse.Date_reported_to_Sponsor__c  = Date.today();
        }
    }
}
public static void updateChangeARStatus(list<case> newCaseList, Map<Id,Case> oldCaseMap){
    for(case c :newCaseList){            
        if(c.US_WSREMS__Program_Picklist__c == Label.Macitentan_REMS_Program_Name && mapCaseRecordTypesById.get(c.RecordTypeId).getDeveloperName() == 'Change_Authorized_Representative' && c.Pharmacy_Participant__c != null &&  c.Status != 'Complete'){
            c.Status = 'Complete';
        }
        
    } 
}

    public static void updatePrograRecTypeControl(List<Case> newCaseList){
            
        Map<Id, Schema.RecordTypeInfo> mapCaseRecordTypesById = Schema.SObjectType.Case.getRecordTypeInfosById();

        List<US_WSREMS__REMS_Service_Summary__c> RSSList = [Select id, US_WSREMS__Participant__c,US_WSREMS__REMSProgram__c,US_WSREMS__REMSProgram__r.Name FROM US_WSREMS__REMS_Service_Summary__c WHERE Id = :newCaseList[0].US_WSREMS__REMS_Service_Summary__c limit 1 ];

        for(Case cs:newCaseList){
            if ((!RSSList.isempty())&&cs.Program_Record_Type_Control__c == Null && (mapCaseRecordTypesById.get(cs.RecordTypeId).getDeveloperName().contains('ReCertification') || mapCaseRecordTypesById.get(cs.RecordTypeId).getDeveloperName().contains('ARVerification')) ){
                cs.Program_Record_Type_Control__c = RSSList[0].US_WSREMS__REMSProgram__r.Name+'-'+cs.US_WSREMS__Record_Type_Name__c;
                cs.US_WSREMS__Program_Picklist__c = RSSList[0].US_WSREMS__REMSProgram__r.Name;
            }
            else if(cs.Program_Record_Type_Control__c == Null && (mapCaseRecordTypesById.get(cs.RecordTypeId).getDeveloperName().contains('ReCertification') || mapCaseRecordTypesById.get(cs.RecordTypeId).getDeveloperName().contains('ARVerification')) ){
                cs.Program_Record_Type_Control__c = cs.US_WSREMS__Program_Picklist__c+'-'+cs.US_WSREMS__Record_Type_Name__c;
                cs.US_WSREMS__Program_Picklist__c = cs.US_WSREMS__Program_Picklist__c;
            }
        }
    }
    
    public static void updateKACheckBoxonAccount(List<Case> newCaseList){
        
    List<Account> updateAccountList = new List<Account>();
    Id recertificationRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'ReCertification');
    Id hcsEnrollRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
    Id hcsReEnrollRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Reenrollment');
    Set<Id> enrollmentId = new Set<Id>();
    enrollmentId.add(recertificationRecordType);
 //   enrollmentId.add(hcsEnrollRecordType);
  //  enrollmentId.add(hcsReEnrollRecordType);
    Set<Id> accountIds = new Set<Id>();
    for(Case caseRecord :newCaseList){
        if(enrollmentId.contains(caseRecord.RecordTypeId) && caseRecord.Status == CompleteStatus){
            accountIds.add(caseRecord.US_WSREMS__Participant__c);
        }
    }
    List<Account> accountList = [SELECT Id,US_WSREMS__Recertification_Complete__c FROM Account WHERE Id = :accountIds];
        for(Account accountRecord :accountList){
            accountRecord.US_WSREMS__Recertification_Complete__c = true;
            updateAccountList.add(accountRecord);
        }
        update updateAccountList;
    }

    public static void updateAVEEDARonHCSAccount(list<case> caseList)
    {
        id enrollmentHCSCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        id reenrollmentHCSCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Reenrollment').getRecordTypeId();
        id recertificationHCSCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('ReCertification').getRecordTypeId();
        Map<Id, Case> certifiedCaseMap = new Map<Id, Case>();
        for(case enrollmentCase : caseList)
        {
            if((enrollmentCase.RecordTypeId == enrollmentHCSCaseRecordTypeId || enrollmentCase.RecordTypeId == reenrollmentHCSCaseRecordTypeId || enrollmentCase.RecordTypeId == recertificationHCSCaseRecordTypeId ) &&  enrollmentCase.US_WSREMS__Participant__c != null && enrollmentCase.US_WSREMS__REMS_Authorized_Rep__c != null && enrollmentCase.status == 'Complete')
            {
                certifiedCaseMap.put(enrollmentCase.US_WSREMS__Participant__c, enrollmentCase);
            }
        }
        List<Account> newAccList = new List<Account>();
        List<Account> accList = [SELECT Id, US_WSREMS__Authorized_Representative__c,US_WSREMS__Status__c FROM Account WHERE ID IN : certifiedCaseMap.keySet()];
        for(Account account :accList){
            if(account.US_WSREMS__Status__c == 'Certified') {
                Case caserec = certifiedCaseMap.get(account.Id);
                account.US_WSREMS__Authorized_Representative__c = caserec.US_WSREMS__REMS_Authorized_Rep__c;
                newAccList.add(account);
            }
        }

        update newAccList;
        
     }   
    
    public static void checkKAAttempts(list<case> newCaseList, Map<Id,Case> oldCaseMap){
        id kaCaseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', SYN_Utilitycls.Knowlege_Assessment);
        for(case cs :newCaseList){
            if(oldCaseMap != NULL && oldCaseMap.get(cs.Id) != NULL && cs.US_WSREMS__Attempts_Made__c != oldCaseMap.get(cs.Id).US_WSREMS__Attempts_Made__c && cs.RecordTypeId == kaCaseRecordTypeId){
                US_WSREMS.REMSAvoidRecursiveCls.stop_tasktrigger = true;
                US_WSREMS.REMSAvoidRecursiveCls.stop_TaskCreation = true;
            }
        } 
    } 

    public static void updateIncompleteReasonForIdentifier(List<Case> newCaseList){
        Id enrollmentHCSCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        Id reenrollmentHCSCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Reenrollment').getRecordTypeId();
        for(Case caseRecord :newCaseList){
            if(caseRecord.US_WSREMS__REMS_Service_Summary__c!=null && caseRecord.RecordTypeId == enrollmentHCSCaseRecordTypeId || caseRecord.RecordTypeId == reenrollmentHCSCaseRecordTypeId){
                if(caseRecord.US_WSREMS__DEA__c == '' || caseRecord.US_WSREMS__DEA__c == null){
                    caseRecord.US_WSREMS__DEA_Status__c = '';
                }
                if(caseRecord.US_WSREMS__HIN__c == '' || caseRecord.US_WSREMS__HIN__c == null){
                    caseRecord.US_WSREMS__HIN_Status__c = '';
                }
                if((caseRecord.US_WSREMS__NPI__c != null && caseRecord.US_WSREMS__NPI__c != '') && 
                   (caseRecord.US_WSREMS__NPI_Status__c == 'Invalid' || caseRecord.US_WSREMS__NPI_Status__c == '' || 
                   caseRecord.US_WSREMS__NPI_Status__c == null)){
                       if(caseRecord.US_WSREMS__Incomplete_Reasons__c != null && caseRecord.US_WSREMS__Incomplete_Reasons__c != '' 
                  		 &&!caseRecord.US_WSREMS__Incomplete_Reasons__c.contains('NPI;')){
                       	caseRecord.US_WSREMS__Incomplete_Reasons__c = caseRecord.US_WSREMS__Incomplete_Reasons__c + 'NPI;' ;
                         }else if(caseRecord.US_WSREMS__Incomplete_Reasons__c == null || caseRecord.US_WSREMS__Incomplete_Reasons__c == ''){
                             caseRecord.US_WSREMS__Incomplete_Reasons__c = 'NPI;';
                         }
                   }
                else{
                    if((caseRecord.US_WSREMS__Incomplete_Reasons__c != null && caseRecord.US_WSREMS__Incomplete_Reasons__c != '')  &&
                    (caseRecord.US_WSREMS__Incomplete_Reasons__c.contains('NPI;') || caseRecord.US_WSREMS__Incomplete_Reasons__c.contains('NPI Status;'))){
                           caseRecord.US_WSREMS__Incomplete_Reasons__c = caseRecord.US_WSREMS__Incomplete_Reasons__c.replace('NPI Status;','');
                           caseRecord.US_WSREMS__Incomplete_Reasons__c = caseRecord.US_WSREMS__Incomplete_Reasons__c.replace('NPI;','');
                       }
                }
                if(caseRecord.US_WSREMS__DEA__c != null && caseRecord.US_WSREMS__DEA__c != ''&& 
                    (caseRecord.US_WSREMS__DEA_Status__c == 'Invalid'|| caseRecord.US_WSREMS__DEA_Status__c == '' || 
                    caseRecord.US_WSREMS__DEA_Status__c == null)){
                        if(caseRecord.US_WSREMS__Incomplete_Reasons__c != null && caseRecord.US_WSREMS__Incomplete_Reasons__c != '' &&
                   			!caseRecord.US_WSREMS__Incomplete_Reasons__c.contains('DEA;')){
                       			caseRecord.US_WSREMS__Incomplete_Reasons__c = caseRecord.US_WSREMS__Incomplete_Reasons__c + 'DEA;' ;
                            }else if(caseRecord.US_WSREMS__Incomplete_Reasons__c == null || caseRecord.US_WSREMS__Incomplete_Reasons__c == ''){
                                caseRecord.US_WSREMS__Incomplete_Reasons__c = 'DEA;';
                            }
                    }
                else{
                    if((caseRecord.US_WSREMS__Incomplete_Reasons__c != null && caseRecord.US_WSREMS__Incomplete_Reasons__c != '')  &&
                       (caseRecord.US_WSREMS__Incomplete_Reasons__c.contains('DEA Status;') || caseRecord.US_WSREMS__Incomplete_Reasons__c.contains('DEA;'))){
                           caseRecord.US_WSREMS__Incomplete_Reasons__c = caseRecord.US_WSREMS__Incomplete_Reasons__c.replace('DEA Status;','');
                           caseRecord.US_WSREMS__Incomplete_Reasons__c = caseRecord.US_WSREMS__Incomplete_Reasons__c.replace('DEA;','');
                       }
                }
                if(caseRecord.US_WSREMS__HIN__c != null && caseRecord.US_WSREMS__HIN__c != '' && 
                    (caseRecord.US_WSREMS__HIN_Status__c == 'Invalid' || caseRecord.US_WSREMS__HIN_Status__c == '' || 
                    caseRecord.US_WSREMS__HIN_Status__c == null)){
                        if((caseRecord.US_WSREMS__Incomplete_Reasons__c != null && caseRecord.US_WSREMS__Incomplete_Reasons__c != '') 
                   			&& !caseRecord.US_WSREMS__Incomplete_Reasons__c.contains('HIN;')){
                       			caseRecord.US_WSREMS__Incomplete_Reasons__c = caseRecord.US_WSREMS__Incomplete_Reasons__c + 'HIN;' ;
                            }else if(caseRecord.US_WSREMS__Incomplete_Reasons__c == null || caseRecord.US_WSREMS__Incomplete_Reasons__c == ''){
                                caseRecord.US_WSREMS__Incomplete_Reasons__c = 'HIN;';
                            }
                    } 
                   
                else{
                    if((caseRecord.US_WSREMS__Incomplete_Reasons__c != null && caseRecord.US_WSREMS__Incomplete_Reasons__c != '') &&
                       (caseRecord.US_WSREMS__Incomplete_Reasons__c.contains('HIN;') || caseRecord.US_WSREMS__Incomplete_Reasons__c.contains('HIN Status;'))){
                           caseRecord.US_WSREMS__Incomplete_Reasons__c = caseRecord.US_WSREMS__Incomplete_Reasons__c.replace('HIN;','');
                           caseRecord.US_WSREMS__Incomplete_Reasons__c = caseRecord.US_WSREMS__Incomplete_Reasons__c.replace('HIN Status;','');
                       }
                }
                if((caseRecord.US_WSREMS__NCPDP__c != null && caseRecord.US_WSREMS__NCPDP__c != '') && 
                   (caseRecord.US_WSREMS__Incomplete_Reasons__c != null || caseRecord.US_WSREMS__Incomplete_Reasons__c == '') 
                   && caseRecord.US_WSREMS__Incomplete_Reasons__c.contains('NCPDP;')){
                       caseRecord.US_WSREMS__Incomplete_Reasons__c = caseRecord.US_WSREMS__Incomplete_Reasons__c.replace('NCPDP;','');
                   }
                
                if((caseRecord.US_WSREMS__HIN__c == '' || caseRecord.US_WSREMS__HIN__c == null)
                   && (caseRecord.US_WSREMS__DEA__c == '' || caseRecord.US_WSREMS__DEA__c == null) &&
                   (caseRecord.US_WSREMS__NPI__c == '' || caseRecord.US_WSREMS__NPI__c == null) && 
                   (caseRecord.US_WSREMS__NCPDP__c == '' || caseRecord.US_WSREMS__NCPDP__c == null)){
                       caseRecord.US_WSREMS__Incomplete_Reasons__c = caseRecord.US_WSREMS__Incomplete_Reasons__c + 'HIN;DEA;NPI;NCPDP;';
                   }
                if(caseRecord.Status == 'Draft' && (caseRecord.US_WSREMS__Incomplete_Reasons__c == '' || caseRecord.US_WSREMS__Incomplete_Reasons__c== null)){
                     caseRecord.US_WSREMS__Outcome__c = 'Complete';
                    caseRecord.Status = 'Complete';
                }
                if(caseRecord.US_WSREMS__Incomplete_Reasons__c != null && caseRecord.US_WSREMS__Incomplete_Reasons__c != '' && caseRecord.Status != 'Cancelled'){
                    caseRecord.Status = 'Draft';
                    caseRecord.US_WSREMS__Outcome__c = '';
                }
                
            }
        } 
    }
    public static void preventPrescriberDuplicateNPI(List<Case> newCaseList){
            
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        Map<String,Id> accountRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account');
        Id prescriberAccountCaseRecordTypeId = caseRecordTypeMap.get('Prescriber_Person_Account');
        Id prescriberAccountRecordTypeId = accountRecordTypeMap.get('Prescriber');
        Map<String,String> prescriberNpiMap = new Map<String,String>();
        List<Account> prescriberAccounts = new List<Account>();
        Map<String, Account> npiMap = new Map<String, Account>();
        List<Case> prescriberCases = new List<Case>();
        for(Case cs:newCaseList){
            if(!cs.US_WSREMS__Is_Portal__c && cs.US_WSREMS__Channel__c != REMSAppLiterals.CASE_CHANNEL_PORTAL && cs.RecordTypeId == prescriberAccountCaseRecordTypeId && String.isNotBlank(cs.US_WSREMS__NPI__c) && cs.US_WSREMS__Program_Type__c != null){
                prescriberNpiMap.put(cs.US_WSREMS__NPI__c, cs.US_WSREMS__Program_Type__c);
                prescriberCases.add(cs);
            }
        }
        if(!prescriberNpiMap.isEmpty() && prescriberNpiMap != null){
        
            prescriberAccounts = [SELECT Id, US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Program_Type__c FROM Account 
                                                                                                    WHERE US_WSREMS__National_Provider_Identifier__c != ''
                                                                                                    AND US_WSREMS__National_Provider_Identifier__c =: prescriberNpiMap.keySet()
                                                                                                    AND US_WSREMS__Program_Type__c != null
                                                                                                    AND US_WSREMS__Program_Type__c =: prescriberNpiMap.Values()
                                                                                                    AND US_WSREMS__Program_Name__c = 'XIAFLEX'
                                                                                                    AND RecordTypeId = : prescriberAccountRecordTypeId];
        }
        
        if(prescriberAccounts.isEmpty()){
            return;
        }
        
        for(Account acc : prescriberAccounts){
           npiMap.put(acc.US_WSREMS__National_Provider_Identifier__c, acc); 
        }
        
        for(Case cs: prescriberCases){
            if(cs.RecordTypeId == prescriberAccountCaseRecordTypeId && npiMap.containsKey(cs.US_WSREMS__NPI__c) && cs.US_WSREMS__Program_Type__c == npiMap.get(cs.US_WSREMS__NPI__c).US_WSREMS__Program_Type__c){
                cs.addError('You cannot create a account with duplicate NPI');
            }
        } 
    }
    
    public static void updateAccounts(List<case> newCaseList, Map<Id,Case> oldMap){
        id enrollmentHCSCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        id prescriberEnrollmentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        List<Account> accountUpdateList = new List<Account>();
        for(case caseObj: newCaseList){
            If((caseObj.recordTypeId == enrollmentHCSCaseRecordTypeId || caseObj.recordTypeId == prescriberEnrollmentRecordTypeId) 
               && caseObj.US_WSREMS__Participant__c!=null
              && caseObj.US_WSREMS__Channel__c != null && caseObj.US_WSREMS__Channel__c == 'Portal'
              && ((oldMap!=null && caseObj.Status != oldMap.get(caseObj.Id).Status && caseObj.Status == 'Complete')
                 || (oldMap==null && caseObj.Status == 'Complete'))){
                  Account accObj = new Account();
                  accObj.Id = caseObj.US_WSREMS__Participant__c;
                  accObj.US_WSREMS__Status__c = 'Certified';
                  accObj.US_WSREMS__Recertification_Due_Date__c = Date.today().addYears(2);
                  accountUpdateList.add(accObj);
            }
        }
               
               If(!accountUpdateList.isEmpty()){
                   try{
                       update accountUpdateList;
                   }catch(exception ex){
                       system.debug('Error'+ex.getMessage());
                   }
               }        
    }
    
    //BT2815-121 PAE/PQC/MIR - SponsorAcknowledgementDate
    public static void SponsorAcknowledgementDate(List<Case> paeCasesList) {
        id paeCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PAE').getRecordTypeId();
            for(case cse : paeCasesList) {
                if(cse.RecordTypeId == paeCaseRecordTypeId && (cse.US_WSREMS__Program_Picklist__c == SYN_Utilitycls.AVEED_PROGRAM_NAME || cse.US_WSREMS__Program_Picklist__c == SYN_Utilitycls.XIAFLEX_PROGRAM_NAME) && cse.Status == 'Complete' && cse.US_WSREMS__Outcome__c == 'Acknowledgement Received') {
                    cse.Sponsor_Acknowledgement_Date__c = System.today(); 
                }
            }
    }
    
    public static void CompleteTaskoncaseclosure(List<case>updatedCases, Map<Id, Case>oldCaseMap){
        for (Case updatedCase : updatedCases){
         Case oldCase = oldCaseMap.get(updatedCase.Id);
        if(REMSAppLiterals.CASE_ENROLLMENT_RECTYPE_SET_TASK.contains(oldCase.US_WSREMS__Record_Type_Name__c)){
        if (oldCase.Status != REMSAppLiterals.CASE_STATUS_COMPLETED && updatedCase.Status == REMSAppLiterals.CASE_STATUS_COMPLETED){
        List<Task> relatedTask = [SELECT Id,Status,Subject,Description From Task WHERE WhatId =:updatedCase.Id];
        if(relatedTask != null){
          relatedTask[0].Status = REMSAppLiterals.TASK_STATUS_COMPLETED;
          String todayDate = DateTime.now().format('MM/dd/yyyy');
          relatedTask[0].Description += '\\r\\n'+'Task closed, stakeholder provided missing information on' + ' ' +todayDate;
          update relatedTask;
         }
        }
       }
      }
     }
    
     /****************************************************************************************************************
    * Method Name : insertOrUpdateDateEnrolled
    * @description : Method to insert Enrolled Date
    * @author Saiteja | 18-11-2024 
    * @param caseList : Triggered Case List(Trigger.New)
    * @return void 
    ****************************************************************************************************************/
    public static void insertOrUpdateDateEnrolled(List<case>caseList){
        Id hcsEnrollRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
        Id prescriberEnrollmentCaseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        List<Account> accList = new List<Account>();
        for(case checkCase : caseList)
        {
			if((checkCase.RecordTypeId == hcsEnrollRecordType || checkCase.RecordTypeId == prescriberEnrollmentCaseRecordTypeId) && checkCase.Status == 'Complete' && checkCase.US_WSREMS__Outcome__c == 'Complete')
            {
                account acc = new account(
                        id = checkCase.US_WSREMS__Participant__c,
                        Date_Enrolled__c = system.today(),
                        US_WSREMS__Date_Enrolled__c = system.today()
                        );
                accList.add(acc);
            }
            update accList;
        }
    }

}