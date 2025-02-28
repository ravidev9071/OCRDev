/**************************************************************************
    * Name :   SYN_PortalEnrollmentController 
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  23/11/2022             Initial Version
    *********************************************************************************/
public without sharing class SYN_PortalEnrollmentController {
      private static Id Maci_Escalation_QueueId = SYN_CommonUtility.getMaciEscQueue(); 

/********************************************************************************************************************************************************
    Method Name     : getCurrentUserType()
    Description     : Get the current logged in portal user
                      return: Logged in portal user.
    ********************************************************************************************************************************************************** */    
    @AuraEnabled(cacheable=true)
    public static user getCurrentUserType() {
        String usertype = '';
        User u = [SELECT Id, Name,Email, UserType, Role__c, ContactId, Account.US_WSREMS__Status__c,Account.SYN_Signature__c,Is_Reset_Password_Req__c FROM User WHERE Id =: UserInfo.getUserId() ];
           return u;
    }
    
    
    /********************************************************************************************************************************************************
    Method Name     : getCurrentUserAccountInfo()
    Description     : Get the person account of the current logged in portal user .
                      return: Account data of the logged in portal user.
    ********************************************************************************************************************************************************** */
    @AuraEnabled /*(cacheable=true)*/
    public static Account getCurrentUserAccountInfo() {
        User u = [SELECT Id, Name,Email, UserType, Role__c, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId() AND ContactId != null LIMIT 1];         
        return [SELECT Id, Name,FirstName,Specialty__c,LastName,MiddleName, US_WSREMS__NPI__c,SYN_Signature__c,SYN_Signature_Date__c, US_WSREMS__REMS_Program__c,Program_Name__c,
                US_WSREMS__Role__c,ShippingPostalCode,ShippingCity,ShippingState,ShippingCountry,ShippingStreet,Account_Name__c, Account_Name_Secondary_Office__c,SYN_Pharmacy__c,
                SYN_Pharmacy__r.Name,SYN_Pharmacy__r.US_WSREMS__NPI__c,SYN_Pharmacy__r.SYN_Signature_Date__c, SYN_Professional_Designation__c,US_WSREMS__Status__c,
                Date_Enrolled__c,SYN_Gender__c,Counseling_Completion_Date__c,Monthly_Pregnancy_Test_Date__c,US_WSREMS__Patient_Risk_Category__c,Patient_Reproductive_Status_Date__c,
                Email_address__c,Phone,SYN_Alternate_Phone__c,Office_Practice_Clinic_Name__c,Primary_contact_name__c,office_contact_phone_Primary_Office__c,US_WSREMS__Email__c,
                Phone_Secondary_Office__c,Address_1_Secondary_Office__c,City_Secondary_Office__c,State_Secondary_Office__c,Secondary_contact_name__c,Secondary_contact_phone__c,
                Email_Secondary_Office__c,Credentials__c, RecordType.Name
                FROM Account WHERE Id =:  u.Contact.AccountId];
        
    }

    @AuraEnabled
    public static Map<String, String> getOCAssociatedPrescriberList(Account officeContact){
        try {
            Map<String, String> prescriberNameList = new Map<String, String>();
            List<US_WSREMS__Affiliation__c> affiliations = [
                                                                SELECT 
                                                                    Id, 
                                                                    Name,
                                                                    US_WSREMS__Prescriber__r.US_WSREMS__NPI__c,US_WSREMS__Prescriber__r.Name
                                                                FROM US_WSREMS__Affiliation__c 
                                                                WHERE Office_Contact__c =: officeContact.Id
                                                                AND US_WSREMS__isActive__c = TRUE
                                                                AND (
                                                                        US_WSREMS__End_Date__c > TODAY 
                                                                        OR US_WSREMS__End_Date__c = null
                                                                    )
                                                            ];
                                                    
            for(US_WSREMS__Affiliation__c aff: affiliations) {
                prescriberNameList.put(aff.US_WSREMS__Prescriber__r.US_WSREMS__NPI__c, aff.US_WSREMS__Prescriber__r.Name);
            }
            return prescriberNameList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /********************************************************************************************************************************************************
    Method Name     : getPrescriberAssociatedOCList()
    Parameters      :accountId: Account Id of the logged in prescriber user; 
    Description     :Get the list of associated office contact records
    Return          : ''
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static List<Account> getPrescriberAssociatedOCList(){
        Account prescriber = getCurrentUserAccountInfo();
          try {
            List<Account> officeContactList = new List<Account>();
            List<String> officeContactIds = new List<String>();
            List<US_WSREMS__Affiliation__c> affiliations = [SELECT Id, Office_Contact__c,
                                                                Office_Contact__r.Name,Office_Contact__r.US_WSREMS__Email__c,Office_Contact__r.Phone,
                                                                Office_Contact__r.isActive, Office_Contact__r.Notifications__c
                                                            FROM US_WSREMS__Affiliation__c 
                                                            WHERE US_WSREMS__Prescriber__c =:prescriber.Id
                                                            ];
            for(US_WSREMS__Affiliation__c aff: affiliations) {
                officeContactIds.add(aff.Office_Contact__c);
            }
            for(Account ofcConRec: [SELECT id, Name,US_WSREMS__Email__c,Phone,US_WSREMS__Status__c, Two_Factor_Authentication_Selection__c from Account where id in :officeContactIds ]) {
                officeContactList.add(ofcConRec);
            }
            return officeContactList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /********************************************************************************************************************************************************
    Method Name     : SavePrescriberSignature()
    Parameters      :accountId: Account Id of the portal user; 
                     agreementStatus: Getting value, Signed/Not Signed from the prescriberEnrollment() below.
                     b64SignData: Signature from the prescriberEnrollment() below.
    Description     :Prescriber signature is updated to the prescriber account record and attachment is created.
                     return: ''
    ********************************************************************************************************************************************************** */
    public static String SavePrescriberSignature(String accountId, String agreementStatus, String b64SignData){
        try {
            Account acc = new Account(Id=accountId,SYN_Signature__c = 'Yes',SYN_Signature_Date__c = System.today());
            update acc;
            //Create Attachment
            Attachment n = new Attachment(ParentId = accountId,Name = 'Signature_'+String.valueOf(Date.today()).substring(0,10),
                                         Body =  EncodingUtil.base64Decode(b64SignData),contentType = 'image/jpeg');
            insert n;
            return '';
        }
        catch (Exception e)
        {
            String errorMessage = e.getMessage();
            Integer occurence;
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                occurence = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;
                errorMessage = errorMessage.mid(occurence, errorMessage.length());
                occurence = errorMessage.lastIndexOf(':');
                errorMessage = errorMessage.mid(0, occurence);
            }            
            return errorMessage;
        }
    }
    
    
    /********************************************************************************************************************************************************
    Method Name     : prescriberEnrollment()
    Parameters      :accountId: Prescriber Account Id of the portal user; 
                     agreementStatus: Getting value, Signed/Not Signed from the component.
                     b64SignData: Signature from the component screen.
    Description     : 1. Create a REMS Service;
                      2. Prescriber enrollment case record is created, above service is related, when the prescriber data is inputted/updated with the signature data;
                      return: Invokes the savePrescriberSignature to save that data to the logged in user prescriber account.
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static string prescriberEnrollment(Account act,String agreementStatus, String b64SignData){
        // Creating Rems service
        String remsServiceId = createREMSService('Enrollment',act.id,act.US_WSREMS__REMS_Program__c,'Prescriber');
        Map<String,String> PrescriberInfoMap = new Map<String,String>();
        Map<String,String> PrimaryOfficeInfoMap= new Map<String,String>();
        Map<String,String> SecondaryOfficeInfoMap = new Map<String,String>();
        AffilationContactWrapper accountAffilationWrapper = new AffilationContactWrapper();
        accountAffilationWrapper = SYN_PortalEnrollmentController.prescriberAffiliationCreation(act);
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        
        if(act.id != null){
            String sect = 'Prescriber'+';'+'SYN_Prescriber__c'+';'+act.Program_Name__c;
            PrescriberInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(act.id,'Case',caseRecordTypeId ,sect);
        }
        
        if(act.Account_Name__c != null){
            String sect = 'Prescriber'+';'+'US_WSREMS__Facility__c'+';'+act.Program_Name__c;
            PrimaryOfficeInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(act.Account_Name__c,'Case',caseRecordTypeId ,sect);
        }
        
        if(act.Account_Name_Secondary_Office__c != null){
            String sect = 'Prescriber'+';'+'Account_Name_Secondary_Office__c'+';'+act.Program_Name__c;
            SecondaryOfficeInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(act.Account_Name_Secondary_Office__c,'Case',caseRecordTypeId,sect);
        }
        
        Map<String,String> prescriberEnrollmentMap = new Map<String,String>();
        
        if(!PrescriberInfoMap.isEmpty() && PrescriberInfoMap != null){
            prescriberEnrollmentMap.putAll(PrescriberInfoMap); 
        }
        
        if(!PrimaryOfficeInfoMap.isEmpty() && PrimaryOfficeInfoMap != null){
            prescriberEnrollmentMap.putAll(PrimaryOfficeInfoMap);
        }
        
        if(!SecondaryOfficeInfoMap.isEmpty() && SecondaryOfficeInfoMap != null){
            prescriberEnrollmentMap.putAll(SecondaryOfficeInfoMap);
        }
        
        
        Case pCase= New Case(RecordTypeId = caseRecordTypeId, SYN_Prescriber__c = act.Id, US_WSREMS__Program_Picklist__c = act.Program_Name__c,US_WSREMS__Channel__c='Portal',
                             US_WSREMS__REMS_Program__c = act.US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__Signature__c='Yes',US_WSREMS__Date__c=System.today());
        if(act.Account_Name__c != null){
            pCase.US_WSREMS__Facility__c = act.Account_Name__c;
        }
         if(act.Specialty__c != null){
            pCase.Specialty__c = act.Specialty__c;
        }

        if(act.Account_Name_Secondary_Office__c != null){
            pCase.Account_Name_Secondary_Office__c = act.Account_Name_Secondary_Office__c;
        }
pCase.US_WSREMS__REMS_Office_Contact_Phone__c = accountAffilationWrapper.prescribeCase.US_WSREMS__REMS_Office_Contact_Phone__c != null ?  accountAffilationWrapper.prescribeCase.US_WSREMS__REMS_Office_Contact_Phone__c : null;
        pCase.office_contact_phone_Secondary_Office__c = accountAffilationWrapper.prescribeCase.office_contact_phone_Secondary_Office__c != null ? accountAffilationWrapper.prescribeCase.office_contact_phone_Secondary_Office__c : null;
        if(accountAffilationWrapper.primaryId !=null) {
            pCase.US_WSREMS__Office_Contact__c = accountAffilationWrapper.primaryId;
            pCase.US_WSREMS__First_Name_ar__c = accountAffilationWrapper.primaryAccount.FirstName;
            pCase.US_WSREMS__Last_Name_ar__c = accountAffilationWrapper.primaryAccount.LastName;
			pCase.US_WSREMS__Email_ar__c = accountAffilationWrapper.primaryAccount.US_WSREMS__Email__c;
            pCase.US_WSREMS__REMS_Office_Contact_Phone__c = accountAffilationWrapper.primaryAccount.Phone;
            if(accountAffilationWrapper.primaryAccount.Specialty__c != null){
                pCase.Specialty__c = accountAffilationWrapper.primaryAccount.Specialty__c;
            }

        }
        if(accountAffilationWrapper.secondaryId !=null) {
            pCase.US_WSREMS__Secondary_Office_Contact__c = accountAffilationWrapper.secondaryId;
            pCase.First_Name_ar2__c = accountAffilationWrapper.secondaryAccount.FirstName;
            pCase.Last_Name_ar2__c = accountAffilationWrapper.secondaryAccount.LastName;
            pCase.Email_Secondary_Office__c = accountAffilationWrapper.secondaryAccount.US_WSREMS__Email__c;
            pCase.office_contact_phone_Secondary_Office__c = accountAffilationWrapper.secondaryAccount.Phone;
        }
        if(!prescriberEnrollmentMap.isEmpty() && prescriberEnrollmentMap!= null){
            for(String fld : prescriberEnrollmentMap.keySet()){
                if(fld != 'US_WSREMS__Date__c' && fld != 'US_WSREMS__Signature__c'){
                    pCase.put(fld,prescriberEnrollmentMap.get(fld));
                }
            }
        }
        
        try{
            //Set NPI Status to Active 
            pCase.US_WSREMS__Status__c = 'Active';
            insert pCase;
              if(accountAffilationWrapper.primaryAffilation.Status__c =='Active') {
                US_WSREMS__Affiliation__c affilation = accountAffilationWrapper.primaryAffilation;
                insert affilation;
            }
            if(accountAffilationWrapper.secondaryAffilation.Status__c =='Active') {
                US_WSREMS__Affiliation__c affilation = accountAffilationWrapper.secondaryAffilation;
                insert affilation;
            }
            return SavePrescriberSignature(act.Id, agreementStatus, b64SignData);
        }catch (exception e){
            System.debug(' EnrollmentCase Error ' + e.getMessage());
            return e.getMessage();
        }
        
    }
    
    /********************************************************************************************************************************************************
    Method Name     : prescriberAffiliationCreation()
    Parameters      :accountId: Prescriber Account Id of the portal user; 
    Description     : 1. Create a Affiliation;
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static AffilationContactWrapper prescriberAffiliationCreation(Account act){
        AffilationContactWrapper wrapper = new AffilationContactWrapper();
        wrapper.prescribeCase = new Case();
        for(Case record : [SELECT Id, US_WSREMS__Office_Contact__c, US_WSREMS__Secondary_Office_Contact__c , US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Office_Contact_Phone__c,office_contact_phone_Secondary_Office__c   FROM Case WHERE US_WSREMS__Participant__c =: act.Id AND RecordType.DeveloperName = 'Prescriber_Person_Account'  LIMIT 1]) {
            wrapper.prescribeCase = record;

        }
        List<String> accountIdList = new List<String>();
        
        wrapper.primaryId = null;
        wrapper.secondaryId = null;
wrapper.primaryAffilation = new US_WSREMS__Affiliation__c();
        wrapper.secondaryAffilation = new US_WSREMS__Affiliation__c();
        Id affilationRecordType = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Office_Contact_Affiliation').getRecordTypeId();
        if(wrapper.prescribeCase.US_WSREMS__Office_Contact__c != null) {
            accountIdList.add(wrapper.prescribeCase.US_WSREMS__Office_Contact__c);
            wrapper.primaryId = wrapper.prescribeCase.US_WSREMS__Office_Contact__c;
            wrapper.primaryAffilation = new US_WSREMS__Affiliation__c();
            wrapper.primaryAffilation.RecordTypeId = affilationRecordType;
            wrapper.primaryAffilation.US_WSREMS__REMSProgram__c = wrapper.prescribeCase.US_WSREMS__REMS_Program__c;
            wrapper.primaryAffilation.Status__c = 'Active';
            wrapper.primaryAffilation.US_WSREMS__isActive__c = true;
            wrapper.primaryAffilation.US_WSREMS__Start_Date__c = System.today();
            wrapper.primaryAffilation.Office_Contact__c = wrapper.prescribeCase.US_WSREMS__Office_Contact__c;
            wrapper.primaryAffilation.US_WSREMS__Prescriber__c = act.Id;
                    }
        if(wrapper.prescribeCase.US_WSREMS__Secondary_Office_Contact__c != null) {
            accountIdList.add(wrapper.prescribeCase.US_WSREMS__Secondary_Office_Contact__c);
            wrapper.secondaryId = wrapper.prescribeCase.US_WSREMS__Secondary_Office_Contact__c;
            wrapper.secondaryAffilation = new US_WSREMS__Affiliation__c();
            wrapper.secondaryAffilation.RecordTypeId = affilationRecordType;
            wrapper.secondaryAffilation.US_WSREMS__REMSProgram__c = wrapper.prescribeCase.US_WSREMS__REMS_Program__c;
            wrapper.secondaryAffilation.Status__c = 'Active';
            wrapper.secondaryAffilation.US_WSREMS__isActive__c = true;
            wrapper.secondaryAffilation.US_WSREMS__Start_Date__c = System.today();
            wrapper.secondaryAffilation.Office_Contact__c = wrapper.prescribeCase.US_WSREMS__Secondary_Office_Contact__c;
            wrapper.secondaryAffilation.US_WSREMS__Prescriber__c = act.Id;
        }
        wrapper.primaryAccount = new Account();
        wrapper.secondaryAccount = new Account();
        if(!accountIdList.isEmpty()) {
            for(Account record : [SELECT Id,FirstName,LastName,US_WSREMS__Email__c,Specialty__c,office_contact_phone_Primary_Office__c,US_WSREMS__REMS_Program__c,Phone FROM Account WHERE ID IN :accountIdList  ]) {
                if(wrapper.primaryId != null && record.Id == wrapper.primaryId ) {
                    wrapper.primaryAccount = record;
                }  
                if(wrapper.secondaryId != null && record.Id == wrapper.secondaryId) {
                    wrapper.secondaryAccount = record;
                }
            }
        }
        return wrapper;
    }
    public class AffilationContactWrapper {
        @AuraEnabled public Case prescribeCase                                                          {get; set;}
        @AuraEnabled public String primaryId                                                            {get; set;}
        @AuraEnabled public String secondaryId                                                          {get; set;}
        @AuraEnabled public Account primaryAccount                                                      {get; set;}
        @AuraEnabled public Account secondaryAccount                                                    {get; set;}
        @AuraEnabled public US_WSREMS__Affiliation__c primaryAffilation                                 {get; set;}
        @AuraEnabled public US_WSREMS__Affiliation__c secondaryAffilation                               {get; set;}

    }
    
    /********************************************************************************************************************************************************
    Method Name     : createREMSService()
    Parameters      : recordTypeDeveloperName: Recordtype name of the service that has to be created.
                      accountId: Prescriber Account Id of the portal user; 
                      programId: Maci program Id of the user account.
                      requestorType: Requestor type who enrolled.
    Description     : Create a REMS Service for the prescriber enrollment case record that is being created in the prescriberEnrollment() above.;
                      return: created service Id.
    ********************************************************************************************************************************************************** */
    Public static string createREMSService(String recordTypeDeveloperName, Id accountId, Id programId, String requestorType){
        Map<String,Id> serviceRecordTypes = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c');
        Id remsServiceRecordTypeId = serviceRecordTypes.get(recordTypeDeveloperName);
       if(remsServiceRecordTypeId == Null){
             remsServiceRecordTypeId= Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
        }
                US_WSREMS__REMS_Service_Summary__c remsService = new US_WSREMS__REMS_Service_Summary__c(recordTypeId = remsServiceRecordTypeId,
                                                                                               US_WSREMS__Is_Portal__c = true,US_WSREMS__Participant__c = accountId,
                                                                                               US_WSREMS__Path_Stage_Name__c = 'Intake',US_WSREMS__Registration_Status__c ='Pending',
                                                                                               US_WSREMS__REMSProgram__c = programId,US_WSREMS__Requestor_Type__c=requestorType,
                                                                                               US_WSREMS__StageName__c='Intake',US_WSREMS__Status__c='Open');
       
        try{
            if(recordTypeDeveloperName == 'Pre_Dispense_Authorization' || (recordTypeDeveloperName == 'Change_of_Information' && requestorType == 'Office Contact')){
             remsService.US_WSREMS__StageName__c='Closed';
             remsService.US_WSREMS__Path_Stage_Name__c  ='Closed';
             remsService.US_WSREMS__Status__c='Closed';
             remsService.US_WSREMS__Path_Complete__c=true;
             remsService.US_WSREMS__Service_Outcome__c='Successful';
            }
            insert remsService;
              return remsService.Id;
        }catch(exception e){
            system.debug('---Error in REMS Service' + +e.getMessage());
            return null;
        }
        
      
    }
    
      /********************************************************************************************************************************************************
    Method Name     : pharmacyAccountCreationAndEnrollment()
    Parameters      : enrollRecTypeDevName: Recordtype name of the enrollment case that has to be created.
                      pharmcCase: Case details of the pharmacy account to be created collected from the pharmacy info page from the portal; 
                      act: Account data of the logged in user account - pharmacy participant.
                      b64SignData: Signature data from the signature page.
    Description     : Create a pharmacy case of account, an account, a service and then a case for the prescriber enrollment, service;
                      return: String - SavePrescriberSignature method with the needed params.
    ********************************************************************************************************************************************************** */
     @AuraEnabled
    public static string pharmacyAccountCreationAndEnrollment(String enrollRecTypeDevName,Case pharmcCase, Account act,String agreementStatus, String b64SignData){
        
        String accountId;
        String createdPharmacyAccountID;
        Map<String,String> PharmacyInfoMap = new Map<String,String>();
        Map<String,String> AuthRepInfoMap= new Map<String,String>();
        Map<String,String> outpatPharmcEnrollmentMap = new Map<String,String>();
        Case pCase;
        Account pharmcParticipantUserAccount;
        
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');

        id pharmCOutPatCaseRecTypeId = caseRecordTypeMap.get(enrollRecTypeDevName);
        id pharmCAccCaseRecTypeId = caseRecordTypeMap.get('Pharmacy_Account');

        // Update inpatient AR Account with Inpatient Pharmacist Position/Title value 
        if(pharmcCase.Pharmacy_Type__c == 'Inpatient'){
              pharmcCase.Status = 'Complete';
        }
        
        //Create pharmacy account - case record...
        pharmcCase.RecordTypeId = pharmCAccCaseRecTypeId;
        pharmcCase.US_WSREMS__REMS_Program__c = act.US_WSREMS__REMS_Program__c;
        
        if(pharmcCase.US_WSREMS__NPI__c != null){
            accountId = validateAccountInfo(pharmcCase.US_WSREMS__NPI__c);
        }
        
        
        if(!String.isEmpty(pharmcCase.US_WSREMS__Phone__c)){
            pharmcCase.US_WSREMS__Phone__c= pharmcCase.US_WSREMS__Phone__c.replaceAll('[^0-9]','');
        }
        
        
        if(!String.isEmpty(pharmcCase.US_WSREMS__Fax__c)){
            pharmcCase.US_WSREMS__Fax__c= pharmcCase.US_WSREMS__Fax__c.replaceAll('[^0-9]','');
        }
        
        if(accountId == null){
            try{
                insert pharmcCase;
            }catch(exception e ){
                system.debug('----Error--PharmCAccCase----'+e.getMessage());
            }
        }
        
        //Create pharmacy Account from the above created pharmc Account case record...
         if(pharmcCase.Id != null){
             REMSPagelayoutConfigComponentController.AccountCreationDetails  acd= REMSPagelayoutConfigComponentController.createAccountOnCaseCreation(pharmcCase.id);
             createdPharmacyAccountID = acd.AccountId;
        }
        
        if(createdPharmacyAccountID != null){
            //SYN_Outpatient_Pharmacy
            //Insert outpatient pharmacy enrollment record..... 
            // Creating Rems service
            String remsServiceId = createREMSService('Enrollment',createdPharmacyAccountID,act.US_WSREMS__REMS_Program__c,'Pharmacy');
            if(createdPharmacyAccountID != null){
                String sect = 'Pharmacy'+';'+'SYN_Pharmacy__c'+';'+act.Program_Name__c;
                PharmacyInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(createdPharmacyAccountID,'Case',pharmCOutPatCaseRecTypeId ,sect);
            }
            
            if(act.Id != null){
                String sect = 'Pharmacy'+';'+'SYN_Authorized_Rep__c'+';'+act.Program_Name__c;
                AuthRepInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(act.Id,'Case',pharmCOutPatCaseRecTypeId ,sect);
            }
            
            if(!PharmacyInfoMap.isEmpty() && PharmacyInfoMap != null){
                outpatPharmcEnrollmentMap.putAll(PharmacyInfoMap); 
            }
            
            if(!AuthRepInfoMap.isEmpty() && AuthRepInfoMap != null){
                outpatPharmcEnrollmentMap.putAll(AuthRepInfoMap);
            }
            //Create pharmCOutpatient case record....
            pCase= New Case(RecordTypeId = pharmCOutPatCaseRecTypeId, SYN_Pharmacy__c = createdPharmacyAccountID,SYN_Authorized_Rep__c=act.Id, US_WSREMS__Program_Picklist__c = act.Program_Name__c,US_WSREMS__Channel__c='Portal',
                                 US_WSREMS__REMS_Program__c = act.US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__Signature__c='Yes',US_WSREMS__Date__c=System.today());
            if(act.Id != null){
                pCase.SYN_Authorized_Rep__c = act.Id;
                pCase.SYN_Pharmacy__c = createdPharmacyAccountID;
            } 
        }
        if(!outpatPharmcEnrollmentMap.isEmpty() && outpatPharmcEnrollmentMap!= null){
            for(String fld : outpatPharmcEnrollmentMap.keySet()){
                if(fld != 'US_WSREMS__Date__c' && fld != 'US_WSREMS__Signature__c'){
                    pCase.put(fld,outpatPharmcEnrollmentMap.get(fld));
        }    
            }
        }
        try{
            insert pCase;
             if(pharmcCase.Pharmacy_Type__c != 'Inpatient'){
                  return SavePrescriberSignature(createdPharmacyAccountID, agreementStatus, b64SignData);
             }else{
                 return '';
             }
        }catch (exception e){
             system.debug('----Error-insert PharmEnroll Case-----'+e.getMessage());
            return e.getMessage();
        }
        
    }
    
     
    /***********************************************************************************************************************************
    MethodName : validateAccountInfo
    Description : 
    ************************************************************************************************************************************/
    Public static id validateAccountInfo(String accountNPI){
        Id AccountID;
        List<Account> accountList = [SELECT Id FROM Account WHERE US_WSREMS__NPI__c = : accountNPI LIMIT 1];
        if(!accountList.isEmpty()){
            AccountID = accountList[0].Id;
        }
        return AccountID;
    }
      
    /***********************************************************************************************************************************
    MethodName : getCaseDetails
    Description : BT7433-2210 For prescriber and patient signature wer are fetching case details to send prescriber and patient emails with their names
    ************************************************************************************************************************************/
    @AuraEnabled
    public static case getCaseDetails(Id caseId){
        return [SELECT Id,SYN_Prescriber__c,US_WSREMS__Patient__c,SYN_Prescriber__r.Name,US_WSREMS__Patient__r.Name,US_WSREMS__Patient__r.SYN_Ref_Id__c,
                           US_WSREMS__Patient__r.US_WSREMS__DOB__c,US_WSREMS__Patient__r.US_WSREMS__Patient_Risk_Category__c,US_WSREMS__Patient__r.SYN_Signature__c,US_WSREMS__Patient_Risk_Category__c,
                           SYN_Prescriber__r.SYN_Signature__c,US_WSREMS__Patient__r.US_WSREMS__Status__c,US_WSREMS__Patient__r.Date_Enrolled__c,Negative_Pregnancy_Test_Completed__c ,SYN_Prescriber_Signature__c
                            FROM case WHERE Id = :caseId LIMIT 1]; 
    }
     /***********************************************************************************************************************************
    MethodName : sendEmailToPresciberForSignature
    Description : BT7433-2210 For prescriber and patient signature we are fetching case details to send prescriber and patient emails with their names
    ************************************************************************************************************************************/
    @AuraEnabled
    public static string sendEmailToPresciberForSignature(String caseId, String templateName,String personAccount){
        List<String> toAddresses = new List<String>();
        string toaddressValue='';
        string prescriber='Prescriber';
        string patient='Patient';
        String conRecId;
        String PrgName ='Macitentan REMS';
        try{
            EmailTemplate temp = SYN_Utilitycls.getEmailTemplate(templateName);
            OrgWideEmailAddress owa = SYN_Utilitycls.getOrgWideEmailAddress(Label.MACIToAddress);
            Contact con = MACIAutomationCommunicationUtility.getContact();
            case caseRecord = [SELECT Id,SYN_Prescriber__c,SYN_Prescriber__r.PersonContactId,US_WSREMS__Patient__c,US_WSREMS__Patient__r.PersonContactId,SYN_Prescriber__r.Name,SYN_Prescriber__r.US_WSREMS__Email__c,US_WSREMS__Patient__r.Name,US_WSREMS__Patient__r.SYN_Ref_Id__c,
                               US_WSREMS__Patient__r.US_WSREMS__DOB__c,US_WSREMS__Patient__r.US_WSREMS__Email__c,US_WSREMS__Patient__r.Legal_Guardian_Email__c,US_WSREMS__Patient__r.US_WSREMS__Patient_Risk_Category__c,US_WSREMS__Patient__r.SYN_Signature__c,
                               SYN_Prescriber__r.SYN_Signature__c,US_WSREMS__Patient__r.US_WSREMS__Status__c,US_WSREMS__Patient__r.Date_Enrolled__c, SYN_Prescriber__r.Email_address__c
                               FROM case WHERE Id = :caseId and SYN_Prescriber__c != NULL AND US_WSREMS__Patient__c != NULL AND  US_WSREMS__Program_Name__c =:PrgName  LIMIT 1]; 
            If(personAccount == prescriber){  
                conRecId= caseRecord.SYN_Prescriber__r.PersonContactId;
                toaddressValue = (String) caseRecord.SYN_Prescriber__r.Email_address__c;
                 toAddresses.add(toaddressValue);
            }
            
            else if (personAccount == patient && caseRecord.US_WSREMS__Patient__r.US_WSREMS__DOB__c != NULL) {
            conRecId = caseRecord.US_WSREMS__Patient__r.PersonContactId;
            Integer userAge = calculateAge(caseRecord.US_WSREMS__Patient__r.US_WSREMS__DOB__c);
            
            if (userAge >= 18) {
                 toaddressValue = (String) caseRecord.US_WSREMS__Patient__r.US_WSREMS__Email__c;
            } else {
                toaddressValue = (String) caseRecord.US_WSREMS__Patient__r.Legal_Guardian_Email__c;
            }
              if(toaddressValue!= null){
                 toAddresses.add(toaddressValue);
            }
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(true);
            mail.setTemplateId(temp.id);
            mail.setWhatId(caseRecord.id);
            if(con != null)
                mail.setTargetObjectId(con.id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setOrgWideEmailAddressId(owa.id);
            Messaging.SendEmailResult[] results =  Messaging.sendEmail(new  Messaging.SingleEmailMessage[] { mail });
            if(results.size() > 0 && results[0].isSuccess()){
                return 'Email Sent Successfully';
            }else{
                return 'Failed to Send Email'+results[0].getErrors()[0].getMessage();
            }
            
        }catch(exception e){
            system.debug('---Error---'+e.getMessage());
            return 'Exception in sending Email'+e.getMessage();
    }
        
    }
     /************************************************************************
    MethodName :  calculate Patient Age
    Description : Helper method to calculate Patient age
    *************************************************************************/
    public static Integer calculateAge(Date birthdate) {
    Date today = Date.today();
    Integer age = today.year() - birthdate.year();
    
    // Adjust age if birthdate has not occurred this year yet
    if (today.month() < birthdate.month() || (today.month() == birthdate.month() && today.day() < birthdate.day())) {
        age--;
    }
    return age;
    }
    
    /************************************************************************
    MethodName : getPatients
    Description : retiurn list of enroled patients and displaying in manage patients table in portal  (Prescriber).
    *************************************************************************/
    @AuraEnabled
    public static List<Case> getPatients(String programId, Account acc){

            List<Case> CaseShowDataList =new List<Case>();
         Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
         Id patEnrollCaseRecordTypeId = caseRecordTypeMap.get('Patient_Enrollement');
         Id patreEnrollCaseRecordTypeId = caseRecordTypeMap.get('Patient_Reenrollment');

            For(Case casData: [SELECT Id,SYN_Prescriber__c,US_WSREMS__Patient__c,SYN_Prescriber__r.Name,US_WSREMS__Patient__r.Name,US_WSREMS__Patient__r.SYN_Ref_Id__c,
                           US_WSREMS__Patient__r.US_WSREMS__DOB__c,US_WSREMS__Patient__r.US_WSREMS__Patient_Risk_Category__c,US_WSREMS__Patient__r.SYN_Signature__c,US_WSREMS__Patient_Risk_Category__c,
                           SYN_Prescriber__r.SYN_Signature__c,US_WSREMS__Patient__r.US_WSREMS__Status__c,US_WSREMS__Patient__r.Date_Enrolled__c,SYN_Prescriber_Signature__c,US_WSREMS__Signature__c
                           FROM Case WHERE SYN_Prescriber__c = :acc.id
                           AND US_WSREMS__REMS_Program__c =: programId
                           AND (RecordTypeId = :patEnrollCaseRecordTypeId OR RecordTypeId = :patreEnrollCaseRecordTypeId)
                           AND US_WSREMS__Patient__c !=null AND (Status='Complete' OR Status='Draft')
                          ]){
                               CaseShowDataList.add(casData);
                           }
        if(!CaseShowDataList.isEmpty()){
            return CaseShowDataList;
        } else {
            System.debug('No records found');
                return null;
            }
            
    }

    @AuraEnabled
    public static Case getCaseRecord(Id caseId){
        try {
            Case cse = [SELECT Id, SYN_Prescriber__r.Name, US_WSREMS__Patient__c, US_WSREMS__NPI__c, SYN_Prescriber__r.SYN_Signature_Date__c, US_WSREMS__Patient__r.SYN_Signature_Date__c,SYN_Prescriber_Signature__c , US_WSREMS__Signature__c,SYN_Prescriber_Signature_Date__c,US_WSREMS__Date__c FROM Case WHERE Id =:caseId];
            return cse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Case> getAllPatients(String programId,Account acc){

        Set<Id> prescriberIds = new Set<Id>();
        List<Case> CaseShowDataList =new List<Case>();
         Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
         Id patEnrollCaseRecordTypeId = caseRecordTypeMap.get('Patient_Enrollement');
         Id patreEnrollCaseRecordTypeId = caseRecordTypeMap.get('Patient_Reenrollment');
        List<US_WSREMS__Affiliation__c> AffilList= [SELECT id,
         Name, US_WSREMS__Prescriber__c,Office_Contact__c From US_WSREMS__Affiliation__c where US_WSREMS__Prescriber__c!= NULL AND Office_Contact__c != NULL AND Office_Contact__c=:acc.Id AND US_WSREMS__isActive__c = TRUE];
        if(AffilList !=NULL){
            for(US_WSREMS__Affiliation__c afilia:AffilList){
                prescriberIds.add(afilia.US_WSREMS__Prescriber__c);
                }
            }

        For(Case casData: [SELECT Id,SYN_Prescriber__c,US_WSREMS__Patient__c,SYN_Prescriber__r.Name,US_WSREMS__Patient__r.Name,US_WSREMS__Patient__r.SYN_Ref_Id__c,
                           US_WSREMS__Patient__r.US_WSREMS__DOB__c,US_WSREMS__Patient__r.US_WSREMS__Patient_Risk_Category__c,US_WSREMS__Patient__r.SYN_Signature__c,
                           SYN_Prescriber__r.SYN_Signature__c,US_WSREMS__Patient__r.US_WSREMS__Status__c,US_WSREMS__Patient__r.Date_Enrolled__c,US_WSREMS__Signature__c,SYN_Prescriber_Signature__c
                           FROM Case WHERE SYN_Prescriber__c IN :prescriberIds
                           AND US_WSREMS__REMS_Program__c =: programId
                           AND (RecordTypeId = :patEnrollCaseRecordTypeId OR RecordTypeId = :patreEnrollCaseRecordTypeId)
                           AND US_WSREMS__Patient__c !=null AND (Status='Complete' OR Status='Draft')
                          ]){

                              CaseShowDataList.add(casData);
                          }        
        if(!CaseShowDataList.isEmpty()){
            return CaseShowDataList;
        } else {
            System.debug('No records found');
            return null;
        }
    }
    
    /***********************************************************************************************************************************
    MethodName : getStates
    Description : Prescriber Enrollment(Portal Screen) - get Case State Picklist Values
    ************************************************************************************************************************************/
    @AuraEnabled //get Case State Picklist Values
    public static Map<String, String> getStates(){
        Map<String, String> stateValues = new Map<String, String>();
        //get Case State Field Describe
        Schema.DescribeFieldResult fieldResult = Case.US_WSREMS__State__c.getDescribe();
        //get Case State Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            stateValues.put(p.getValue(), p.getLabel());
        }        
        return stateValues;               
    }
    
     /***********************************************************************************************************************************
    MethodName : createPortalUserAccount
    Description :
    ************************************************************************************************************************************/
    @AuraEnabled
    public static string patientEnrollment(Case patientAccountInfo, Case patientEnrollmentInfo, Account prescriberAccount,string prescNPI,Boolean officeContact) {
         id patientAccountId; 
         Map<String,String> patientInfoMap = new Map<String,String>();
         Map<String,String> prescriberInfoMap = new Map<String,String>();
         Map<String,String> patientEnrollmentMap = new Map<String,String>();
         Map<String,Id> accountRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account');
         Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
         Id caseRecordTypeId = caseRecordTypeMap.get('Patient_Enrollement');
                 Id accRecordTypeId = accountRecordTypeMap.get('Prescriber');
              Account prescAcc;
        if(prescNPI!=null) {
         prescAcc=[SELECT ID,US_WSREMS__REMS_Program__c,Program_Name__c,US_WSREMS__NPI__c FROM ACCOUNT WHERE US_WSREMS__NPI__c =:prescNPI AND RecordTypeID =:accRecordTypeId];         
        }
        if(!String.isEmpty(patientAccountInfo.US_WSREMS__Phone__c)){
             patientAccountInfo.US_WSREMS__Phone__c= patientAccountInfo.US_WSREMS__Phone__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(patientAccountInfo.SYN_Alternate_Phone__c)){
            patientAccountInfo.SYN_Alternate_Phone__c= patientAccountInfo.SYN_Alternate_Phone__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(patientAccountInfo.Emergency_Contact_Phone__c)){
            patientAccountInfo.Emergency_Contact_Phone__c= patientAccountInfo.Emergency_Contact_Phone__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(patientAccountInfo.Legal_Guardian_Phone__c)){
            patientAccountInfo.Legal_Guardian_Phone__c= patientAccountInfo.Legal_Guardian_Phone__c.replaceAll('[^0-9]','');
        }
        
        
        if(!String.isEmpty(patientEnrollmentInfo.US_WSREMS__Phone__c)){
             patientEnrollmentInfo.US_WSREMS__Phone__c= patientEnrollmentInfo.US_WSREMS__Phone__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(patientEnrollmentInfo.SYN_Alternate_Phone__c)){
            patientEnrollmentInfo.SYN_Alternate_Phone__c= patientEnrollmentInfo.SYN_Alternate_Phone__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(patientEnrollmentInfo.Emergency_Contact_Phone__c)){
            patientEnrollmentInfo.Emergency_Contact_Phone__c= patientEnrollmentInfo.Emergency_Contact_Phone__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(patientEnrollmentInfo.Legal_Guardian_Phone__c)){
            patientEnrollmentInfo.Legal_Guardian_Phone__c= patientEnrollmentInfo.Legal_Guardian_Phone__c.replaceAll('[^0-9]','');
        }
         String remsServiceId ;
         // Create patient Account.
          if(!officeContact){
         patientAccountId = createPatientAccount(patientAccountInfo);
          if(prescriberAccount!=null){
         // Creating Rems service
          remsServiceId = createREMSService('Enrollment',patientAccountId,prescriberAccount.US_WSREMS__REMS_Program__c,'Patient');
          }else if(prescNPI!=null){
              remsServiceId = createREMSService('Enrollment',patientAccountId,prescAcc.US_WSREMS__REMS_Program__c,'Patient');
         
          }
         // Assign Record type 
         patientEnrollmentInfo.RecordTypeId = caseRecordTypeId;
          } 
         if(patientAccountId !=null){
             String patientsect ;
             patientEnrollmentInfo.US_WSREMS__Patient__c = patientAccountId;
               if(prescriberAccount!=null)
              patientsect = 'Patient'+';'+'US_WSREMS__Patient__c'+';'+prescriberAccount.Program_Name__c;
             if(prescNPI!=null)
              patientsect = 'Patient'+';'+'US_WSREMS__Patient__c'+';'+prescAcc.Program_Name__c;
             patientInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(patientAccountId,'Case',caseRecordTypeId ,patientsect);
         }
        
         if(prescriberAccount!=null){
             patientEnrollmentInfo.SYN_Prescriber__c = prescriberAccount.id;
             String sect = 'Patient'+';'+'SYN_Prescriber__c'+';'+prescriberAccount.Program_Name__c;
             prescriberInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(prescriberAccount.id,'Case',caseRecordTypeId ,sect);
           
         }
             if(prescAcc != null && prescNPI!=null){
             patientEnrollmentInfo.SYN_Prescriber__c = prescAcc.id;
             String sect = 'Patient'+';'+'SYN_Prescriber__c'+';'+prescAcc.Program_Name__c;
             prescriberInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(prescAcc.id,'Case',caseRecordTypeId ,sect);
         }
         
         if(patientEnrollmentInfo.SYN_Prescriber_Signature__c == 'Yes'){
             patientEnrollmentInfo.SYN_Prescriber_Signature_Date__c = system.today();
         }
         if(remsServiceId != null){
             patientEnrollmentInfo.US_WSREMS__REMS_Service_Summary__c = remsServiceId;
         }
         
         if(!patientInfoMap.isEmpty() && patientInfoMap != null){
             patientEnrollmentMap.putAll(patientInfoMap);  
         }
         
         if(!prescriberInfoMap.isEmpty() && prescriberInfoMap != null){
             patientEnrollmentMap.putAll(prescriberInfoMap);  
         }
         
         if(!patientEnrollmentMap.isEmpty() && patientEnrollmentMap!= null){
            for(String fld : patientEnrollmentMap.keySet()){
                if(fld != 'US_WSREMS__DOB__c'){
                    patientEnrollmentInfo.put(fld,patientEnrollmentMap.get(fld));
                }
            }
        } 
        
        try{
            upsert patientEnrollmentInfo;
           
        }catch(exception e ){
            system.debug('----Error------'+e.getMessage());
        }
        return patientEnrollmentInfo.id;


    }
    
     /***********************************************************************************************************************************
    MethodName : createPatientAccount
    Description : Patient Enrollment(Portal Screen) - Create Patient Account and Case
    ************************************************************************************************************************************/
    Public static id createPatientAccount(Case patientCase){
        Map<String,Id> caseRecordTypes = REMSUtility.retrieveRecTypeDeveloperNameId_Product('case');
	
        patientCase.RecordTypeId =caseRecordTypes.get('SYN_Patient_Person_Account');
        try{
            
            insert patientCase;
             REMSPagelayoutConfigComponentController.AccountCreationDetails  patientAccount= REMSPagelayoutConfigComponentController.createAccountOnCaseCreation(patientCase.id);
            return patientAccount.AccountId;
            
        }catch(exception e){
            system.debug('---Error----'+e.getMessage());
            return null;
        }        
    }
    
    
     /***********************************************************************************************************************************
    MethodName : getRelatedFilesByRecordId
    Description : Patient Enrollment(Portal Screen) - download prescriber related files
    ************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<ID, ContentDistribution> getRelatedFilesByRecordId(String recordTypeDevName,String programId,String portalRole) {
        return REMSfileDownloadController.getRelatedFilesByRecordId(recordTypeDevName,programId,portalRole);
    }
    
    /********************************************************************************************************************************************************
    Method Name     : getCurrentUserPharmacyInfo()
    Description     : Get the current login user pharmacy details
                      return: Account data of the logged in portal user.
    ********************************************************************************************************************************************************** */
    @AuraEnabled(cacheable=true)
    public static Case getCurrentUserPharmacyInfo(String UserId) {
        User u = [SELECT Id, Name,Email, UserType, Role__c, ContactId, AccountId, Program__c FROM User WHERE Id =: UserId LIMIT 1];         
        List<US_WSREMS__Affiliation__c>  aff;
        List<Case> caselist = new list<Case>();
        String recordTypeName;
        if(u != null && u.Role__c != null){
            if(u.Role__c == 'Outpatient Pharmacy' ){
                recordTypeName = 'SYN_Outpatient_Pharmacy';
            }else if(u.Role__c == 'Inpatient Pharmacy'){
                recordTypeName = 'SYN_Inpatient_Pharmacy';
            }
        }
        if(u.AccountId != null){
             caselist = [SELECT Id, SYN_Pharmacy__r.Name, SYN_Pharmacy__r.US_WSREMS__NPI__c, SYN_Pharmacy__r.SYN_Signature_Date__c, SYN_Authorized_Rep__r.Name,US_WSREMS__REMS_Service_Summary__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Status__c, US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c,
                 SYN_Pharmacy__c,US_WSREMS__Date__c,SYN_Pharmacy__r.US_WSREMS__Status__c,SYN_Authorized_Rep__c,SYN_Authorized_Rep__r.US_WSREMS__Status__c,SYN_Authorized_Rep__r.Credentials__c FROM Case WHERE SYN_Pharmacy__c != null AND SYN_Authorized_Rep__c =: u.AccountId AND Recordtype.DeveloperName =: recordTypeName LIMIT 1];
        }
        if(!caselist.isEmpty()){
            return caselist[0];
        }
        
        return null;
    }
    
    
        
    /********************************************************************************************************************************************************
    Method Name     : getCurrentUserPharmacyInfo()
    Description     : Get the current login user pharmacy details
                      return: Account data of the logged in portal user.
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static US_WSREMS__Affiliation__c getUserDefaultPharmacyInfo(String UserId) {
        
        return SYN_SwitchPharmacyController.getUserDefaultPharmacyInfo(UserId);
    }

    
    /********************************************************************************************************************************************************
    Method Name     : updateAuthorizedRepAccount
    Description     : Update "Is the Certification page complete" checkbox when pharmcy user login into portal (first time)
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static void updateAuthorizedRepAccount(String accountId) {
        Account acc = new Account(Id=accountId);
        acc.Is_the_Certification_Page_Complete__c = true;
        try{
            update acc;
        }catch(exception e){
            system.debug('---Error---'+e.getMessage());
        }
       
    }
    
    /********************************************************************************************************************************************************
    Method Name     : updateInPatientAuthorizedRepresentativeInfo
    Description     : Update inpatient AR Account with Inpatient Pharmacist Position/Title value 
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static void updateInPatientAuthorizedRepresentativeInfoOnAccount(Account acc) {
        try{
            acc.US_WSREMS__Status__c ='Active';
            acc.SYN_Signature__c = 'Yes';
            acc.SYN_Signature_Date__c = System.today();
            update acc;
            updateInPatientAuthorizedRepresentativeInfoOnCase(acc);
        }catch(exception e){
            system.debug('--Error--'+e.getMessage());
        }
       
    }
    
    /********************************************************************************************************************************************************
    Method Name     : updateInPatientAuthorizedRepresentativeInfo
    Description     : Update inpatient AR Account with Inpatient Pharmacist Position/Title value 
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static void updateInPatientAuthorizedRepresentativeInfoOnCase(Account acc) {
        Case cs = [SELECT Id,Title__c,Other_Title__c FROM Case WHERE US_WSREMS__Participant__c =: acc.Id AND RecordType.DeveloperName ='Pharmacy_Participant_Account' LIMIT 1];

        try{
            cs.Title__c = acc.Title__c;
            cs.Other_Title__c = acc.Other_Title__c;
            cs.Status = 'Complete';
            update cs;
        }catch(exception e){
            system.debug('--Error--'+e.getMessage());
        }
       
    }
    
    
    /********************************************************************************************************************************************************
    Method Name     : insertSignatureAttachment()
    Description     : Create a pharmacy case of account, an account, a service and then a case for the prescriber enrollment, service;
                      return: String - SavePrescriberSignature method with the needed params.
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static string saveSignatureAttachment(Account act,String agreementStatus, String b64SignData, String pharmacyactId){
    
        updateInPatientAuthorizedRepresentativeInfoOnAccount(act);
        
        try{
            return SavePrescriberSignature(pharmacyactId, agreementStatus, b64SignData);
        }catch (exception e){
             system.debug('----Error-insert PharmEnroll Case-----'+e.getMessage());
            return e.getMessage();
        }
        
    }
    
    /************************************************************************
    MethodName : getPatientPregnancy Info
    Description : return patient info for patient pregnancy type
    *************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Account getPatientPregnancyInfo(String program, String patientId){
        String accountId;
        if(patientId.startsWith('001')) {
            accountId = patientId;
        } else {
            for(Case caseRecord : [SELECT Id, US_WSREMS__Patient__c  FROM Case WHERE Id=: patientId ])  {
                accountId = caseRecord.US_WSREMS__Patient__c;
            }
        }
                  return [SELECT Id, Name,FirstName,LastName, US_WSREMS__NPI__c,SYN_Signature__c,SYN_Signature_Date__c, US_WSREMS__REMS_Program__c,Program_Name__c,US_WSREMS__DOB__c,
                    US_WSREMS__Role__c,ShippingPostalCode,ShippingCity,ShippingCountry,ShippingStreet,Account_Name__c, Account_Name_Secondary_Office__c,SYN_Pharmacy__c,
                    SYN_Pharmacy__r.Name,SYN_Pharmacy__r.US_WSREMS__NPI__c,SYN_Pharmacy__r.SYN_Signature_Date__c, SYN_Professional_Designation__c,US_WSREMS__Status__c,
                    Date_Enrolled__c,SYN_Gender__c,Counseling_Completion_Date__c,Monthly_Pregnancy_Test_Date__c,US_WSREMS__Patient_Risk_Category__c, Phone, US_WSREMS__Email__c,
                    Patient_Reproductive_Status_Date__c,SYN_Ref_Id__c FROM Account WHERE Id =: accountId AND Recordtype.DeveloperName ='Patient' AND Program_Name__c =: program];
      }

/************************************************************************
    MethodName : get Patient Pregnancy Enrollment Case
    Description : return patient info for patient pregnancy type
    *************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Case getPatientPregnancyEnrolledCase( String patientId){
        Case cse = [SELECT Id, SYN_Prescriber_Signature_Date__c , US_WSREMS__Date__c FROM Case WHERE US_WSREMS__Participant__c =:patientId AND Recordtype.DeveloperName ='Patient_Enrollement' ];
        return cse;
      }


    /************************************************************************
    Monthly Pregnancy for Office Contact
    MethodName : getPrescriberPregnancy Info
    Description : return Prescriber and patient info for office contact
    *************************************************************************/
     @AuraEnabled(cacheable=true)
    public static Case getPrescriberAndPatientPregnancyInfo(String program, String PatientId){
        Set<Id> patientIdsSet = new Set<Id>();
        Set<Id> getPrescriberIDS = new Set<Id>();
        Set<Id> getPatientIDS =  new Set<Id>();
        
        return [SELECT Id,SYN_Prescriber__r.US_WSREMS__NPI__c,SYN_Prescriber__c,US_WSREMS__Patient__c,SYN_Prescriber__r.Name,SYN_Prescriber__r.FirstName,SYN_Prescriber__r.LastName,US_WSREMS__Patient__r.Name,US_WSREMS__Patient__r.FirstName,US_WSREMS__Patient__r.LastName,US_WSREMS__Patient__r.SYN_Ref_Id__c,
                US_WSREMS__Patient__r.US_WSREMS__DOB__c,US_WSREMS__Patient__r.US_WSREMS__Patient_Risk_Category__c,US_WSREMS__Patient__r.SYN_Signature__c,SYN_Prescriber__r.SYN_Signature__c,US_WSREMS__Patient__r.US_WSREMS__Status__c,US_WSREMS__Patient__r.Date_Enrolled__c
                
                FROM Case WHERE US_WSREMS__Patient__c=: PatientId
                AND US_WSREMS__REMS_Program__c =: program 
                AND Recordtype.DeveloperName ='Patient_Enrollement'
                AND SYN_Prescriber__c != Null 
                AND US_WSREMS__Patient__c != null 
                AND US_WSREMS__REMS_Program__c != null 
               ];

    }
    
    

    
    /************************************************************************
    MethodName : create PatientPregancy Records
    Description : Create Rems Service and case Records for patient pregnancy type
    *************************************************************************/
    @AuraEnabled
    public static String createPatientPregancyRecords(String program, String patientId,Account prescriber,String programName,String channel){
        Map<String,String> PatientInfoMap = new Map<String,String>();
        Map<String,Id> CaseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');

        // Creating Rems service
        Id caseRecordTypeId =  CaseRecordTypeMap.get('Patient_Pregnancy_Test');
        String PrescriberId;
        String patId;
        String PrescId;
        if(patientId.containsAny('_')) {
            list<String> Ids = patientId != null ? patientId.Split('_') : new List<String>();
            patId  = Ids.isEmpty() ? '' : Ids[0];
            PrescId = Ids.isEmpty() ? '' : Ids[1];
        } else {
            patId = patientId;
        }
        if(!String.isBlank(PrescId)){
            PrescriberId = PrescId;
        } else if(prescriber != null) {
            PrescriberId = prescriber.id;
        }
        String remsServiceId = createPatientPregnancyREMSService('Patient_Pregnancy_Test',PrescriberId,program,'Prescriber',patId);
        if(patId != null){
            String sect = 'Prescriber'+';'+'US_WSREMS__Patient__c'+';'+'Macitentan REMS';
            PatientInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(patId,'Case',caseRecordTypeId ,sect);
        }
        // Creating Patient Pregnancy Case
        Case pCase= New Case(RecordTypeId = caseRecordTypeId, SYN_Prescriber__c = PrescriberId, US_WSREMS__Program_Picklist__c = programName,US_WSREMS__Channel__c=channel,
                             US_WSREMS__REMS_Program__c = program,US_WSREMS__Patient__c=patId,Monthly_Pregnancy_Test_Recorded__c =true,
                             US_WSREMS__REMS_Service_Summary__c = remsServiceId,Date_of_Confirmation__c=System.today(),US_WSREMS__Outcome__c='Complete',
                             US_WSREMS__Patient_Risk_Category__c = 'Female of Reproductive Potential (FRP)',US_WSREMS__Participant__c=patId);
        
        if(!PatientInfoMap.isEmpty() && PatientInfoMap!= null){
            for(String fld : PatientInfoMap.keySet()){
                pCase.put(fld,PatientInfoMap.get(fld));
            }
        }
        
        try{
            insert pCase;
            return remsServiceId;
        }catch (exception e){
            return e.getMessage();
        }
    }
    
      /********************************************************************************************************************************************************
    Method Name     : updatePharmacyParticipantAffiliation()
    Description     : 
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static string updatePharmacyParticipantAffiliation(Account pharmacyArAccount, String pharmacyAcctId){
    
        US_WSREMS__Affiliation__c affiliation = [SELECT Id,US_WSREMS__UserType__c,Status__c,US_WSREMS__Start_Date__c,AR_Category__c FROM US_WSREMS__Affiliation__c 
                                                                                                                WHERE US_WSREMS__Pharmacy__c != null AND US_WSREMS__Pharmacy__c =: pharmacyAcctId
                                                                                                                AND US_WSREMS__isActive__c = true AND US_WSREMS__REMSProgram__c =: pharmacyArAccount.US_WSREMS__REMS_Program__c
                                                                                                                AND US_WSREMS__Pharmacy_User__c != null AND US_WSREMS__Pharmacy_User__c =: pharmacyArAccount.Id LIMIT 1];
         if(affiliation != null){
            affiliation.Status__c = 'Active';
            affiliation.US_WSREMS__Start_Date__c = Date.today();
            affiliation.US_WSREMS__UserType__c = 'Authorized Representative';
            affiliation.AR_Category__c ='Primary';
         }                                                                                                      
           
        try{
            update affiliation;
        }catch (exception e){
             system.debug('----Error-insert PharmEnroll Case-----'+e.getMessage());
            return e.getMessage();
        }
        return '';
    }
    
    @AuraEnabled
    public static string insertPharmacyInfo(String enrollRecTypeDevName,Case pharmcCase, Account act){
        
        String accountId;
        String createdPharmacyAccountID;
                 Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
                Id pharmCAccCaseRecTypeId =  caseRecordTypeMap.get('Pharmacy_Account');
                // id pharmCAccCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Account').getRecordTypeId();
        
        // Update inpatient AR Account with Inpatient Pharmacist Position/Title value 
        if(pharmcCase.Pharmacy_Type__c == 'Inpatient'){
              pharmcCase.Status = 'Complete';
        }
        
        //Create pharmacy account - case record...
        pharmcCase.RecordTypeId = pharmCAccCaseRecTypeId;
        pharmcCase.US_WSREMS__REMS_Program__c = act.US_WSREMS__REMS_Program__c;
        
        if(!String.isEmpty(pharmcCase.US_WSREMS__Phone__c)){
            pharmcCase.US_WSREMS__Phone__c= pharmcCase.US_WSREMS__Phone__c.replaceAll('[^0-9]','');
        }
        
        if(!String.isEmpty(pharmcCase.US_WSREMS__Fax__c)){
            pharmcCase.US_WSREMS__Fax__c= pharmcCase.US_WSREMS__Fax__c.replaceAll('[^0-9]','');
        }
        
        if(!String.isEmpty(pharmcCase.Phone_Secondary_Office__c)){
            pharmcCase.Phone_Secondary_Office__c= pharmcCase.Phone_Secondary_Office__c.replaceAll('[^0-9]','');
        }
        
        if(!String.isEmpty(pharmcCase.Fax_Secondary_Office__c)){
            pharmcCase.Fax_Secondary_Office__c= pharmcCase.Fax_Secondary_Office__c.replaceAll('[^0-9]','');
        }
        
        
        try{
            insert pharmcCase;
        }catch(exception e ){
            system.debug('----Error--PharmCAccCase----'+e.getMessage());
        }
        
        //Create pharmacy Account from the above created pharmc Account case record...
        if(pharmcCase.Id != null){
             REMSPagelayoutConfigComponentController.AccountCreationDetails  acd= REMSPagelayoutConfigComponentController.createAccountOnCaseCreation(pharmcCase.id);
             createdPharmacyAccountID = acd.AccountId;
        }
        
        return createdPharmacyAccountID;
    }

   /** 09/13/2024 changes added regarding Duplicate record type issye by relacing schema.sobject with  REMSUtility.retrieveRecTypeDeveloperNameId_Product() to get recordID BY Dileep Gurram  */ 
    @AuraEnabled
    public static Case getPharmacyEnrollmentInfo(String enrollRecTypeDevName,Case pharmcCase, Account act, String createdPharmacyAccountID){
        
        String accountId;
        Map<String,String> PharmacyInfoMap = new Map<String,String>();
        Map<String,String> AuthRepInfoMap= new Map<String,String>();
        Map<String,String> outpatPharmcEnrollmentMap = new Map<String,String>();
        Case pCase;
        Account pharmcParticipantUserAccount;
        
               Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
               id pharmCOutPatCaseRecTypeId = caseRecordTypeMap.get(enrollRecTypeDevName);
        if(createdPharmacyAccountID != null){
            // Creating Rems service
            String remsServiceId = createREMSService('Enrollment',createdPharmacyAccountID,act.US_WSREMS__REMS_Program__c,'Pharmacy');
            if(createdPharmacyAccountID != null){
                String sect = 'Pharmacy'+';'+'SYN_Pharmacy__c'+';'+act.Program_Name__c;
                PharmacyInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(createdPharmacyAccountID,'Case',pharmCOutPatCaseRecTypeId ,sect);
            }
            
            if(act.Id != null){
                String sect = 'Pharmacy'+';'+'SYN_Authorized_Rep__c'+';'+act.Program_Name__c;
                AuthRepInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(act.Id,'Case',pharmCOutPatCaseRecTypeId ,sect);
            }
            
            if(!PharmacyInfoMap.isEmpty() && PharmacyInfoMap != null){
                outpatPharmcEnrollmentMap.putAll(PharmacyInfoMap); 
            }
            
            if(!AuthRepInfoMap.isEmpty() && AuthRepInfoMap != null){
                outpatPharmcEnrollmentMap.putAll(AuthRepInfoMap);
            }
            //Create pharmCOutpatient case record....
            pCase= New Case(RecordTypeId = pharmCOutPatCaseRecTypeId, SYN_Pharmacy__c = createdPharmacyAccountID,SYN_Authorized_Rep__c=act.Id, US_WSREMS__Program_Picklist__c = act.Program_Name__c,US_WSREMS__Channel__c='Portal',
                                 US_WSREMS__REMS_Program__c = act.US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__Signature__c='Yes',US_WSREMS__Date__c=System.today());
            if(act.Id != null){
                pCase.SYN_Authorized_Rep__c = act.Id;
                pCase.SYN_Pharmacy__c = createdPharmacyAccountID;
            } 
        }
        if(!outpatPharmcEnrollmentMap.isEmpty() && outpatPharmcEnrollmentMap!= null){
            for(String fld : outpatPharmcEnrollmentMap.keySet()){
                pCase.put(fld,outpatPharmcEnrollmentMap.get(fld));
            }
        }
        return pCase;
    }
    
    
    @AuraEnabled
    public static String insertPharmacyEnrollmentCase(case pharmacyEnrollmentCase,Case pharmcCase, string createdPharmacyAccountID, String agreementStatus, String b64SignData){
         try{
            if(pharmcCase.Pharmacy_Type__c == 'Inpatient'){
                 pharmacyEnrollmentCase.Status = 'Complete';
            }
            //Set NPI Status to Active 
            pharmacyEnrollmentCase.US_WSREMS__Status__c = 'Active';
            insert pharmacyEnrollmentCase;
             if(pharmcCase.Pharmacy_Type__c != 'Inpatient'){
                  return SavePrescriberSignature(createdPharmacyAccountID, agreementStatus, b64SignData);
             }else{
                 return '';
             }
        }catch (exception e){
             system.debug('----Error-insert PharmEnroll Case-----'+e.getMessage());
            return e.getMessage();
        }
    }
    
    
    
   /********************************************************************************************************************************************************
    Method Name     : getPrescriberEnrollmentForm()
    Description     : get the Prescriber Enrollement form Vf page.
    ********************************************************************************************************************************************************** */  
    @AuraEnabled
    public static String getPrescriberEnrollmentForm() {               
        PageReference pageRef= Page.Maci_Prescriber_Enrollment_and_Agreement;
        return EncodingUtil.base64Encode(pageRef.getContentAsPDF());
    }
    
    /********************************************************************************************************************************************************
    Method Name     : getPatientEnrollmentForm()
    Description     : get the Patient Enrollement form Vf page.
    ********************************************************************************************************************************************************** */  
    @AuraEnabled
    public static String getPatientEnrollmentForm(String recordId) {               
        PageReference pageRef= Page.Maci_Patient_Enrollment_Form;
        pageRef.getParameters().put('Id',recordId);
        return EncodingUtil.base64Encode(pageRef.getContentAsPDF());
    }
    
    
     /********************************************************************************************************************************************************
    Method Name     : getInPatientPharmacyEnrollmentForm()
    Description     : get the InPatientPharmacyEnrollmentForm form Vf page.
    ********************************************************************************************************************************************************** */
    
    @AuraEnabled
    public static String getInPatientPharmacyEnrollmentForm(String recordId) {               
        PageReference pageRef= Page.Maci_Inpatient_enrollment;
        pageRef.getParameters().put('Id',recordId);
        return EncodingUtil.base64Encode(pageRef.getContentAsPDF());
    }
    
    
     /********************************************************************************************************************************************************
    Method Name     : getOutPatientPharmacyEnrollmentForm()
    Description     :get the OutPatientPharmacyEnrollmentForm form Vf page.
    ********************************************************************************************************************************************************** */
     @AuraEnabled
    public static String getOutPatientPharmacyEnrollmentForm(String recordId) {               
        PageReference pageRef= Page.Maci_Outpatient_enrollment;
        pageRef.getParameters().put('Id',recordId);
        return EncodingUtil.base64Encode(pageRef.getContentAsPDF());
    }
    
     /********************************************************************************************************************************************************
    Method Name     : prescriberEnrollment()
    Parameters      :accountId: Prescriber Account Id of the portal user; 
                     agreementStatus: Getting value, Signed/Not Signed from the component.
                     b64SignData: Signature from the component screen.
    Description     : 1. Create a REMS Service;
                      
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static string patientDisEnrollment(Case dcase){
        Task disEnrollmentTask;
        Task completeisEnrollmentTask;
        List<Task> taskListToInsert = new List<Task>();
        Id TaskrctypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SocialDeterminant').getRecordTypeId();
        // Creating Rems service
        String remsServiceId = createREMSService('Disenrollment',dcase.US_WSREMS__Participant__c,dcase.US_WSREMS__REMS_Program__c,'Patient');
        Map<String,String> PrescriberInfoMap = new Map<String,String>();
        Map<String,String> PrimaryOfficeInfoMap= new Map<String,String>();
        Map<String,String> SecondaryOfficeInfoMap = new Map<String,String>();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deactivation').getRecordTypeId();
        
        dcase.US_WSREMS__REMS_Service_Summary__c = remsServiceId;
        dcase.US_WSREMS__Deactivation_Date__c = date.today();
        dcase.recordTypeId = caseRecordTypeId;
        dcase.Status='Complete';
        try{
            insert dcase;
            if(dcase.US_WSREMS__Deactivation_Reason__c == 'Patient Death'){
                disEnrollmentTask = create_Task(dcase.US_WSREMS__REMS_Program__c,System.today(),Maci_Escalation_QueueId,'Patient Disenrollment - Patient Death', TaskrctypeId, remsServiceId,'Prescriber updated patient status to Disenrolled due to reason Patient Death. Submit Reportable Event Form via the PAE/PC/MIR Service within 1 business date of awareness.');
            }else if(dcase.US_WSREMS__Deactivation_Reason__c == 'Discontinued Therapy'){
                disEnrollmentTask = create_Task(dcase.US_WSREMS__REMS_Program__c,System.today(),Maci_Escalation_QueueId,'Patient Disenrollment - Discontinued Therapy',TaskrctypeId,remsServiceId,'Prescriber updated patient status to Disenrolled due to reason Discontinued Therapy.');
            }else if(dcase.US_WSREMS__Deactivation_Reason__c == 'Patient Decision'){
                disEnrollmentTask = create_Task(dcase.US_WSREMS__REMS_Program__c,System.today(),Maci_Escalation_QueueId,'Patient Disenrollment - Patient Decision',TaskrctypeId, remsServiceId,'Prescriber updated patient status to Disenrolled due to reason Patient Decision.' );        
            }else if(dcase.US_WSREMS__Deactivation_Reason__c == 'Prescriber Decision'){
                disEnrollmentTask = create_Task(dcase.US_WSREMS__REMS_Program__c,System.today(),Maci_Escalation_QueueId,'Patient Disenrollment - Prescriber Decision',TaskrctypeId, remsServiceId,'Prescriber updated patient status to Disenrolled due to reason Prescriber Decision.' );          
            }
            completeisEnrollmentTask = create_Task(dcase.US_WSREMS__REMS_Program__c,System.today(),Maci_Escalation_QueueId,'Confirm Email/Fax was Sent',TaskrctypeId, remsServiceId,'' ); 
            if(dcase.US_WSREMS__Deactivation_Reason__c != 'Patient Death'){
                disEnrollmentTask.Status ='Completed';
            }else{
                disEnrollmentTask.Status ='In Progress';
                disEnrollmentTask.Type='Escalation';
            }
            completeisEnrollmentTask .Status ='Completed';
            taskListToInsert.add(completeisEnrollmentTask);
            taskListToInsert.add(disEnrollmentTask);
            if(!taskListToInsert.isEmpty()){
                insert taskListToInsert;
            }
            return '';
        }catch (exception e){
            system.debug('--error----'+e.getMessage());
            return e.getMessage();
        }
        
    }
     /********************************************************************************************************************************************************
    Method Name     : getPresriberAccountInfo()
    Description     : Get the person account of the current logged in portal user .
                      return: Account data of the logged in portal user.
    ********************************************************************************************************************************************************** */

    @AuraEnabled(cacheable=true)
    public static Case getPresriberAccountInfo() {
         User u = [SELECT Id, Name,Email, UserType, Role__c, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId() AND ContactId != null LIMIT 1];    
         Map<String,String> PrescriberInfoMap = new Map<String,String>();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_COI').getRecordTypeId();
        String sect = 'Prescriber'+';'+'US_WSREMS__Participant__c'+';'+'Macitentan REMS';
        PrescriberInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields( u.Contact.AccountId,'Case',caseRecordTypeId ,sect);
        Case pCase = new Case();
        if(!PrescriberInfoMap.isEmpty() && PrescriberInfoMap != null){
            for(String fld : PrescriberInfoMap.keySet()){
                if(PrescriberInfoMap.get(fld) != ' '){
                    pCase.put(fld,PrescriberInfoMap.get(fld));
                }
            }
        }
        pCase.US_WSREMS__Participant__c = u.Contact.AccountId;
        return pCase;
        
    }
    
    
     @AuraEnabled(cacheable=true)
    public static Case getOfficeContactAccountInfo() {
         User u = [SELECT Id, Name,Email, UserType, Role__c, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId() AND ContactId != null LIMIT 1];    
         Map<String,String> officeContactInfoMap = new Map<String,String>();
         Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MACI_Office_Contact_COI').getRecordTypeId();
         String sect = 'Office_Contact'+';'+'US_WSREMS__Participant__c'+';'+'Macitentan REMS';
        officeContactInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields( u.Contact.AccountId,'Case',caseRecordTypeId ,sect);
        Case pCase = new Case();
        if(!officeContactInfoMap.isEmpty() && officeContactInfoMap != null){
            for(String fld : officeContactInfoMap.keySet()){
                if(officeContactInfoMap.get(fld) != ' '){
                    pCase.put(fld,officeContactInfoMap.get(fld));
                }
            }
        }
        pCase.US_WSREMS__Participant__c = u.Contact.AccountId;
          return pCase;
     
    }   
    
     /***********************************************************************************************************************************
    MethodName : getProfessionalDesignation
    Description : Prescriber Enrollment(Portal Screen) - get Case Professional Designation Picklist Values
    ************************************************************************************************************************************/
    @AuraEnabled //get Case Professional Designation Picklist Values
    public static Map<String, String> getProfessionalDesignation(){
        Set<String> designation = new Set<String>{'MD','DO','PA','NP'};
        Map<String, String> ProfessionalDesignationValues = new Map<String, String>();
        //get Case State Field Describe
        Schema.DescribeFieldResult fieldResult = Case.Professional_Designation__c.getDescribe();
        //get Case Professional Designation Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            if(designation.contains(p.getValue())){
            ProfessionalDesignationValues.put(p.getValue(), p.getLabel());
            }
        }        
        return ProfessionalDesignationValues ;        
    }
    
     /********************************************************************************************************************************************************
    Method Name     : savePrescriberAccountInfo ()
    Parameters      :accountId: Prescriber Account Id of the portal user; 
                     agreementStatus: Getting value, Signed/Not Signed from the component.
                     b64SignData: Signature from the component screen.
    Description     : 1. Create a REMS Service;
                      
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static string savePrescriberAccountInfo (Case newCase, String programId , String programName, String channel){
         String returnstring ='';
        Set<String> chagedFieldValue = new Set<String>();
        String accountId = newCase.US_WSREMS__Participant__c;
        Case oldCase= getPresriberAccountInfo();
        Map<String, Object> newValues= newCase.getPopulatedFieldsAsMap();
        Map<String, Object> oldValues= oldCase.getPopulatedFieldsAsMap();
        Boolean isValueChaged = false;
        Map<String,String> PrescriberInfoMap = new Map<String,String>();

        for(String key: newValues.keySet()) {
            
            if(newValues.get(key) != oldValues.get(key)) {
                isValueChaged  = true;
            }
        }
        
        if(isValueChaged){
             // Creating Rems service
            String remsServiceId = createREMSService('Change_of_Information',accountId,programId,'Prescriber');
            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_COI').getRecordTypeId();
            newCase.US_WSREMS__Program_Picklist__c = programName;
            newCase.US_WSREMS__Channel__c=channel;
            newCase.US_WSREMS__REMS_Program__c = programId;
            newCase.US_WSREMS__REMS_Service_Summary__c = remsServiceId;
            newCase.Status='Complete';
            newCase.RecordTypeId = caseRecordTypeId;
            newCase.US_WSREMS__Participant__c = accountId;
            newCase.US_WSREMS__Outcome__c = 'Complete';
            if(!String.isEmpty(newCase.US_WSREMS__Phone__c)){
                newCase.US_WSREMS__Phone__c= newCase.US_WSREMS__Phone__c.replaceAll('[^0-9]','');
            }
            if(!String.isEmpty(newCase.US_WSREMS__Fax__c)){
                newCase.US_WSREMS__Fax__c= newCase.US_WSREMS__Fax__c.replaceAll('[^0-9]','');
            }

            try{
                insert newCase;
                Map<string,string> TargetSourceMap =SYN_CaseTriggerHanlder.getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,'Prescriber_COI',SYN_Utilitycls.Prescriber,ProgramName);
                Map<String, String> TargetFieldToValueMap = getPrepopulatedValues(TargetSourceMap,newCase.Id);
                Account acc = new Account(Id=accountId);
                for(String fld : TargetFieldToValueMap.keySet()){
                    acc.put(fld,TargetFieldToValueMap.get(fld));
                }
                update acc;
                returnstring = '';
            }catch(Exception e){
                system.debug('--Error---'+e.getMessage());
                returnstring = e.getMessage();
            }
        }
        return returnstring;
    }
        
        
    /********************************************************************************************************************************************************
    Method Name     : saveOfficeContactAccountInfo ()
    Parameters      :accountId: OfficeContact Account Id of the portal user; 
                     agreementStatus: Getting value, Signed/Not Signed from the component.
                     b64SignData: Signature from the component screen.
    Description     : 1. Create a REMS Service;
                      
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static string saveOfficeContactAccountCaseInfo (Case newCase, String programId , String programName, String channel){
         String returnstring ='';
        Set<String> chagedFieldValue = new Set<String>();
        String accountId =  newCase.US_WSREMS__Participant__c;
        Case oldCase = getOfficeContactAccountInfo();
        Map<String, Object> newValues= newCase.getPopulatedFieldsAsMap();
        Map<String, Object> oldValues= oldCase.getPopulatedFieldsAsMap();
        Boolean isValueChaged = false;
        Map<String,String> PrescriberInfoMap = new Map<String,String>();

        for(String key: newValues.keySet()) {
            
            if(newValues.get(key) != oldValues.get(key)) {
                isValueChaged  = true;
            }
        }
        
        if(isValueChaged){
       
             // Creating Rems service
            String remsServiceId = createREMSService('Change_of_Information',accountId,programId,'Office Contact');
            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MACI_Office_Contact_COI').getRecordTypeId();
           Case newCaseOc = new Case();
            newCaseOc.US_WSREMS__Program_Picklist__c = programName;
            newCaseOc.US_WSREMS__First_Name__c = newCase.US_WSREMS__First_Name__c;
            newCaseOc.US_WSREMS__Last_Name__c = newCase.US_WSREMS__Last_Name__c;
            newCaseOc.US_WSREMS__Email_ar__c =  newCase.US_WSREMS__Email_ar__c;
            newCaseOc.Two_Factor_Authentication_Selection__c = newCase.Two_Factor_Authentication_Selection__c;
            newCaseOc.US_WSREMS__Channel__c=channel;
            newCaseOc.US_WSREMS__REMS_Program__c = programId;
            newCaseOc.US_WSREMS__REMS_Service_Summary__c = remsServiceId;
            newCaseOc.Status='Complete';
            newCaseOc.US_WSREMS__Status__c=newCase.US_WSREMS__Status__c;
            newCaseOc.RecordTypeId = caseRecordTypeId;
           newCaseOc.US_WSREMS__Participant__c = accountId;
            newCaseOc.US_WSREMS__Outcome__c = 'Complete';
             if(!String.isEmpty(newCase.Phone_Secondary_Office__c)){
                newCaseOc.Phone_Secondary_Office__c= newCase.Phone_Secondary_Office__c.replaceAll('[^0-9]','');
            }
            try{
                insert newCaseOc;
              
				Map<string,string> TargetSourceMap =SYN_CaseTriggerHanlder.getFieldMapping(SYN_Utilitycls.CASE_OBJECT,SYN_Utilitycls.ACCOUNT_OBJECT,'MACI_Office_Contact_COI',SYN_Utilitycls.OfficeContact,ProgramName);
                
                Map<String, String> TargetFieldToValueMap = getPrepopulatedValues(TargetSourceMap,newCaseOc.Id);
                
                Account acc = new Account(Id=accountId);
                
                for(String fld : TargetFieldToValueMap.keySet()){
                    
                    if(TargetFieldToValueMap.get(fld) != null && string.isNotBlank(TargetFieldToValueMap.get(fld))) {
                        acc.put(fld,TargetFieldToValueMap.get(fld));
                    }
                }
                
                update acc;
                returnstring = '';
            }catch(Exception e){
                
                returnstring = e.getMessage();
            }
        }
        return returnstring;
    }
    
    
    
    @AuraEnabled
    public static Map<String,String> getPrepopulatedValues( Map<String, String> TargetSourceMap , Id recordId){
        
            Map<String, String> TargetFieldToValueMap = new Map<String, String>();
            List<Sobject> SobjectRecLst = new List<Sobject>();
            
            if(TargetSourceMap != null && !TargetSourceMap.isEmpty()){
                String SourceobjNameStr =  String.valueOf(recordId?.getsobjecttype());
            
                SobjectRecLst = SobjectDynamicFields(TargetSourceMap.values() , SourceobjNameStr , recordId); 
                for (string Field : TargetSourceMap.Keyset()){
                
                    String Value = TargetSourceMap.get(Field);
                    String FieldValue = String.valueOf(SobjectRecLst[0].get(Value));
                    If(Field == SYN_Utilitycls.NonComplianceImpactedRTNameField && FieldValue != Null){
                        String RtName = SYN_ParticipantEnrollmentController.getRecordTypeNameById(FieldValue);
                        TargetFieldToValueMap.put(Field, RtName);
                    }
                    else if(Field == SYN_Utilitycls.NonComplianceInvestigatedRTNameField && FieldValue != Null){
                        String RtName = SYN_ParticipantEnrollmentController.getRecordTypeNameById(FieldValue);
                        TargetFieldToValueMap.put(Field, RtName);
                    }else if(Field == SYN_Utilitycls.NonComplianceReporterRTNameField && FieldValue != Null){
                        String RtName = SYN_ParticipantEnrollmentController.getRecordTypeNameById(FieldValue);
                        TargetFieldToValueMap.put(Field, RtName); //BT6825-135
                    }else{
                        TargetFieldToValueMap.put(Field ,  String.isBlank(FieldValue) ? ' ': FieldValue);
                    }
                }
            }
            return TargetFieldToValueMap;
    }     
        
    
    Public static List<Sobject> SobjectDynamicFields(List<String> dynamiceFieldLst, string SourceObj,  Id recordId){
        List<sobject> sourceRecLst = new List<Sobject>();
        Set<String> dynamiceFieldSet = new Set<String>();
        for(String s : dynamiceFieldLst){
            dynamiceFieldSet.add(s);    
        }
        String dynamicFieldStr = String.join(new List<String>(dynamiceFieldSet), ',');
        String dynamicQueryStr = 'SELECT '+dynamicFieldStr+' FROM '+ SourceObj+' WHERE Id =: recordId';
        return Database.query(dynamicQueryStr);
    }
    
    
     /***********************************************************************************************************************************
    MethodName : getProfessionalDesignation
    Description : Prescriber Enrollment(Portal Screen) - get Case Professional Designation Picklist Values
    ************************************************************************************************************************************/
    @AuraEnabled //get Case Dissenrollment Reason
    public static Map<String, String> getDisEnrollmentReason(){
        Set<String> designation = new Set<String>{'Discontinued Therapy','Patient Decision','Prescriber Decision','Patient Death'};
        Map<String, String> DisEnrollmentReasonMap= new Map<String, String>();
        //get Case State Field Describe
        Schema.DescribeFieldResult fieldResult = Case.US_WSREMS__Deactivation_Reason__c.getDescribe();
        //get Case Professional Designation Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            if(designation.contains(p.getValue())){
            DisEnrollmentReasonMap.put(p.getValue(), p.getLabel());
            }
        }        
        return DisEnrollmentReasonMap;   
    }       
    
      /***********************************************************************************************************************************
    MethodName : getPharmacyTitle
    Description : OutPatient Pharmacy Enrollment - get Case Title Picklist Values
    ************************************************************************************************************************************/
    @AuraEnabled 
    public static Map<String, String> getPharmacyTitle(){
        Map<String, String> titleValues = new Map<String, String>();
        titleValues = MaciPortalCustomController.getPharmacyTitle();
        return titleValues;        
    }
    
     /***********************************************************************************************************************************
    MethodName : getPharmacyCredentails
    Description : OutPatient Pharmacy Enrollment - get Case Credentials Picklist Values.
    ***********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> getPharmacyCredentails(){
        Map<String, String> credentailsValues = new Map<String, String>();
        credentailsValues = MaciPortalCustomController.getPharmacyCredentails();
        return credentailsValues ;        
    }
    
    /********************************************************************************************************************************************************
    Method Name     : getPresriberAccountInfo()
    Description     : Get the person account of the current logged in portal user .
                      return: Account data of the logged in portal user.
    ********************************************************************************************************************************************************** */
    @AuraEnabled(cacheable=true)
    public static Account getPharmacyARInfo() {
        User u = [SELECT Id, Name,Email, UserType, Role__c, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId() AND ContactId != null LIMIT 1];    
          
        return [SELECT Id, Name,US_WSREMS__NPI__c,FirstName,LastName,MiddleName,Email_address__c,Phone,SYN_Alternate_Phone__c,SYN_Job_Title__c,Title__c,Other_Credential__c,US_WSREMS__Email__c,Credentials__c,Fax,US_WSREMS__Credentials__c
                ,Two_Factor_Authentication_Selection__c,RecordType.Name
                FROM Account WHERE Id =:  u.Contact.AccountId];
       
    }


    /********************************************************************************************************************************************************

    Method Name     : createPatientPregnancyREMSService()
    Description     : Create a REMS Service for the patient pregnancy case record.
                      return: created service Id.
    ********************************************************************************************************************************************************** */
    Public static string createPatientPregnancyREMSService(String recordTypeDeveloperName, Id accountId, Id programId, String requestorType,Id PatientId){
        Map<String,Id> serviceRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c');
        Id remsServiceRecordTypeId= serviceRecordTypeMap.get(recordTypeDeveloperName);
        US_WSREMS__REMS_Service_Summary__c remsService = new US_WSREMS__REMS_Service_Summary__c(recordTypeId = remsServiceRecordTypeId,Patient__c=PatientId,
                                                                                                US_WSREMS__Is_Portal__c = true,US_WSREMS__Participant__c = accountId,
                                                                                                US_WSREMS__Path_Stage_Name__c = 'Closed',US_WSREMS__Registration_Status__c ='Pending',
                                                                                                US_WSREMS__REMSProgram__c = programId,US_WSREMS__Requestor_Type__c=requestorType,
                                                                                                US_WSREMS__StageName__c='Closed',US_WSREMS__Status__c='Closed',
                                                                                                US_WSREMS__Path_Complete__c=true,US_WSREMS__Service_Outcome__c='Successful');
        
        try{
            insert remsService;
            return remsService.Id;
        }catch(exception e){
            return null;
        }
    }
    
    
    /********************************************************************************************************************************************************
    Method Name     : attachPrescriberEnrollmentFormonAccount()
    Description     : attach Macitentan REMS Prescriber Enrollment Form
    ********************************************************************************************************************************************************** */  
    
    @AuraEnabled
    public static string attachPrescriberEnrollmentFormonAccount(Account accobj) {
        string enrollmentName = accobj.FirstName+' '+accobj.LastName+' enrollment form.pdf';
        String emessage = '';
        List<Attachment> attchmentList = [SELECT Id,Name FROM Attachment WHERE ParentId =: accobj.Id AND Name =: enrollmentName LIMIT 1];
        if(attchmentList.isEmpty()){
            PageReference PDf =  Page.Maci_Prescriber_Enrollment_and_Agreement;//Replace attachmentPDf with the page you have rendered as PDF
            PDf.setRedirect(true);
            Attachment attach = new Attachment();
            Blob b ;
            if(Test.isRunningTest()) { 
                b = blob.valueOf('Some.Test');
            } else {
                b = PDf.getContent();
            }
            attach.Body = b;
            attach.Name = enrollmentName;
            attach.IsPrivate = false;
            attach.ParentId = accobj.Id;
            
            try{
               insert attach;
            }catch(exception e){
              system.debug('Error--------------'+e.getMessage());
               emessage= e.getMessage();
            }
        }
        return emessage;  
     }

     /********************************************************************************************************************************************************
    Method Name     : attachInpatientEnrollmentFormonAccount()
    Description     : attach Macitentan REMS Inpatient Enrollment Form
    ********************************************************************************************************************************************************** */  
    
    @AuraEnabled
    public static string attachInpatientEnrollmentFormonAccount(Case caseObj) {
        String enrollmentName = caseObj.SYN_Pharmacy__r.Name+' '+'enrollment form.pdf';
        String emessage = '';
        List<Attachment> attchmentList = [SELECT Id,Name FROM Attachment WHERE ParentId =: caseObj.SYN_Pharmacy__c AND Name =: enrollmentName LIMIT 1];
        if(attchmentList.isEmpty()){
            PageReference PDf =  Page.Maci_Inpatient_enrollment;//Replace attachmentPDf with the page you have rendered as PDF
            PDf.getParameters().put('Id',caseObj.SYN_Pharmacy__c);
            PDf.setRedirect(true);
            Attachment attach = new Attachment();
            Blob b ;
            if(Test.isRunningTest()) { 
                b = blob.valueOf('Some.Test');
            } else {
                b = PDf.getContent();
            }
            attach.Body = b;
            attach.Name = enrollmentName;
            attach.IsPrivate = false;
            attach.ParentId = caseObj.SYN_Pharmacy__c;
            try{
               insert attach;
            }catch(exception e){
              system.debug('Error--------------'+e.getMessage());
               emessage = e.getMessage();
            }
        }
        return emessage;  
     }   
/********************************************************************************************************************************************************
    Method Name     : attachOutpatientEnrollmentFormonAccount()
    Description     : attach Macitentan REMS Outpatient Enrollment Form
    ********************************************************************************************************************************************************** */  
    
    @AuraEnabled
    public static string attachOutpatientEnrollmentFormonAccount(Case caseObj) {
        String enrollmentName = caseObj.SYN_Pharmacy__r.Name+' '+'enrollment form.pdf';
        String emessage = '';
        List<Attachment> attchmentList = [SELECT Id,Name FROM Attachment WHERE ParentId =: caseObj.SYN_Pharmacy__c AND Name =: enrollmentName LIMIT 1];
        
        PageReference PDf =  Page.Maci_Outpatient_enrollment;//Replace attachmentPDf with the page you have rendered as PDF
        PDf.getParameters().put('Id',caseObj.SYN_Pharmacy__c);
        PDf.setRedirect(true);
        Attachment attach = new Attachment();
        Blob b ;
        if(Test.isRunningTest()) { 
            b = blob.valueOf('Some.Test');
        } else {
            b = PDf.getContent();
        }
        attach.Body = b;
        attach.Name = enrollmentName;
        attach.IsPrivate = false;
        attach.ParentId = caseObj.SYN_Pharmacy__c;
        try{
           insert attach;
        }catch(exception e){
          system.debug('Error--------------'+e.getMessage());
           emessage = e.getMessage();
        }
        return emessage;  
     }
     
      /************************************************************************
    MethodName : getSelectedPatientInfo Info
    Description : return patient info for patient pregnancy type
    *************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Case getSelectedPatientInfo(String program, String patientId, Account prescriberAccount){
        Map<String,String> patientInfoMap = new Map<String,String>();
        Map<String,String> prescriberInfoMap = new Map<String,String>();
        Map<String,String> patientEnrollmentMap = new Map<String,String>();
        Map<String,Id> caseRecordTypes = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');

        Id reEnrollmentcaseRecordTypeId = caseRecordTypes.get('Patient_Reenrollment');   
        Account pAccount = [SELECT Id,SYN_Signature__c,SYN_Signature_Date__c,US_WSREMS__Patient_Risk_Category__c,Monthly_Pregnancy_Test_Recorded__c,US_WSREMS__DOB__c,
                            ShippingStreet, shippingpostalcode FROM Account WHERE Id =: patientId LIMIT 1];
                            
        Case patientCase = [SELECT Id,US_WSREMS__Patient__c, US_WSREMS__Patient__r.SYN_Signature__c, US_WSREMS__Patient__r.SYN_Signature_Date__c, US_WSREMS__Patient__r.US_WSREMS__Patient_Risk_Category__c,
                                US_WSREMS__Patient__r.Monthly_Pregnancy_Test_Recorded__c, US_WSREMS__Patient__r.US_WSREMS__DOB__c, US_WSREMS__Patient__r.ShippingStreet, US_WSREMS__Patient__r.shippingpostalcode,
                                US_WSREMS__Address_Line_2__c 
                                FROM Case WHERE US_WSREMS__Patient__c =: patientId AND Recordtype.DeveloperName ='Patient_Enrollement' AND US_WSREMS__Program_Name__c =: program AND SYN_Prescriber__c = : prescriberAccount.Id LIMIT 1];
                
        Case patientReenrollmentInfo = new case();


        if(patientId !=null){
            patientReenrollmentInfo.US_WSREMS__Patient__c = patientId;
            String patientsect = 'Patient'+';'+'US_WSREMS__Patient__c'+';'+prescriberAccount.Program_Name__c;
            patientInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(patientId ,'Case',reEnrollmentcaseRecordTypeId,patientsect);
        }
        if(prescriberAccount.id != null){
            patientReenrollmentInfo.SYN_Prescriber__c = prescriberAccount.id;
            String sect = 'Patient'+';'+'SYN_Prescriber__c'+';'+prescriberAccount.Program_Name__c;
            prescriberInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(prescriberAccount.id,'Case',reEnrollmentcaseRecordTypeId,sect);
        }
        
         if(!patientInfoMap.isEmpty() && patientInfoMap != null){
             patientEnrollmentMap.putAll(patientInfoMap);  
         }
         
         if(!prescriberInfoMap.isEmpty() && prescriberInfoMap != null){
             patientEnrollmentMap.putAll(prescriberInfoMap);  
         }
         
         if(!patientEnrollmentMap.isEmpty() && patientEnrollmentMap!= null){
            for(String fld : patientEnrollmentMap.keySet()){
                if(fld != 'US_WSREMS__DOB__c'){
                    if(patientEnrollmentMap.get(fld) != ' '){
                        patientReenrollmentInfo.put(fld,patientEnrollmentMap.get(fld));
                    }
                }
            }
        } 
        
        patientReenrollmentInfo.US_WSREMS__Signature__c = patientCase.US_WSREMS__Patient__r.SYN_Signature__c;
        patientReenrollmentInfo.US_WSREMS__Date__c = patientCase.US_WSREMS__Patient__r.SYN_Signature_Date__c;
        patientReenrollmentInfo.US_WSREMS__Patient_Risk_Category__c = patientCase.US_WSREMS__Patient__r.US_WSREMS__Patient_Risk_Category__c;
        patientReenrollmentInfo.Negative_Pregnancy_Test_Completed__c = patientCase.US_WSREMS__Patient__r.Monthly_Pregnancy_Test_Recorded__c;
        patientReenrollmentInfo.SYN_Prescriber_Signature__c = prescriberAccount.SYN_Signature__c;
        patientReenrollmentInfo.SYN_Prescriber_Signature_Date__c =  prescriberAccount.SYN_Signature_Date__c;
        patientReenrollmentInfo.US_WSREMS__DOB__c=  patientCase.US_WSREMS__Patient__r.US_WSREMS__DOB__c;
        patientReenrollmentInfo.US_WSREMS__Address_Line_2__c= patientCase.US_WSREMS__Address_Line_2__c ;
        
        return patientReenrollmentInfo;

        
    }
    
     /********************************************************************************************************************************************************
    Method Name     : getPatientReEnollmentInfo()
    Description     : attach Macitentan REMS Outpatient Enrollment Form
    ********************************************************************************************************************************************************** */  
    
    @AuraEnabled
    public static string createPatientReEnrollment(Case reEnrollCase,String programId) {
        Map<String,Id> caseRecordTypes = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        Id reEnrollmentcaseRecordTypeId = caseRecordTypes.get('Patient_Reenrollment');   
        if(!String.isEmpty(reEnrollCase.US_WSREMS__Phone__c)){
             reEnrollCase.US_WSREMS__Phone__c= reEnrollCase.US_WSREMS__Phone__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(reEnrollCase.SYN_Alternate_Phone__c)){
            reEnrollCase.SYN_Alternate_Phone__c= reEnrollCase.SYN_Alternate_Phone__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(reEnrollCase.Emergency_Contact_Phone__c)){
            reEnrollCase.Emergency_Contact_Phone__c= reEnrollCase.Emergency_Contact_Phone__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(reEnrollCase.Legal_Guardian_Phone__c)){
            reEnrollCase.Legal_Guardian_Phone__c= reEnrollCase.Legal_Guardian_Phone__c.replaceAll('[^0-9]','');
        }
         
         // Creating Rems service
        String remsServiceId = createREMSService('Reenrollment',reEnrollCase.US_WSREMS__Patient__c,programId,'Patient');
        
        reEnrollCase.US_WSREMS__REMS_Program__c = programId;
        //Cloning the above Account Record acc
        Case reEnrollmentCase= reEnrollCase.clone(false, false, false, false);
        reEnrollmentCase.US_WSREMS__REMS_Service_Summary__c = remsServiceId;
        reEnrollmentCase.RecordTypeId = reEnrollmentcaseRecordTypeId;
        reEnrollmentCase.Status = 'Complete';
        reEnrollmentCase.US_WSREMS__Outcome__c = 'Approved';
        try{
           insert reEnrollmentCase;
           return '';
       }catch(exception e){
           system.debug('---Error---'+e.getMessage());
           return e.getMessage();
       }

        
     }  

     /************************************************************************
    MethodName : create ChangeReproductiveStatus Record
    Description : Create Rems Service and case Records for Change in Reproductive Status
    *************************************************************************/
    @AuraEnabled
    public static String createChangeReproductiveStatusRecord(String program, Id patientId,Account prescriber,String programName,String channel,Case prescriberCase){
        Map<String,String> PatientInfoMap = new Map<String,String>();
        Map<String,String> PrescriberInfoMap = new Map<String,String>();
        // Creating Rems service
        Map<String,Id> caseRecordTypes = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
                String remsServiceId = createREMSService('Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification',prescriber.Id,program,'Prescriber');
                Id caseRecordTypeId = caseRecordTypes.get('Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');
		 if(caseRecordTypeId == Null){
	     	caseRecordTypeId = caseRecordTypes.get('Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');	
		} 
        if(patientId != null){
            String sect = 'Prescriber'+';'+'US_WSREMS__Patient__c'+';'+'Macitentan REMS';
            PatientInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(patientId,'Case',caseRecordTypeId ,sect);
        }
        
       if(prescriber != null){
            String sect = 'Prescriber'+';'+'SYN_Prescriber__c'+';'+'Macitentan REMS';
            PrescriberInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(prescriber.Id,'Case',caseRecordTypeId ,sect);
        }
        
        // Creating Change In Reproductive Status Case
        Case pCase= New Case(RecordTypeId = caseRecordTypeId, SYN_Prescriber__c = prescriber.Id, US_WSREMS__Program_Picklist__c = programName,US_WSREMS__Channel__c=channel,
                             US_WSREMS__REMS_Program__c = program,US_WSREMS__Patient__c=patientId,Annual_Verification__c =prescriberCase.Annual_Verification__c,SYN_Prescriber_Signature__c='Yes',Please_specify__c=prescriberCase.Please_specify__c,
                             US_WSREMS__REMS_Service_Summary__c = remsServiceId,SYN_Date__c=System.today(),US_WSREMS__DOB__c=prescriberCase.US_WSREMS__DOB__c,US_WSREMS__Outcome__c='Misclassification Review Pending',
                             US_WSREMS__Patient_Risk_Category__c = prescriberCase.US_WSREMS__Patient_Risk_Category__c,Reason_for_change_in_classification__c=prescriberCase.Reason_for_change_in_classification__c,US_WSREMS__Participant__c=prescriber.Id);
        

        if(!PatientInfoMap.isEmpty() && PatientInfoMap!= null){
            for(String fld : PatientInfoMap.keySet()){
                if(fld != 'US_WSREMS__DOB__c')
                pCase.put(fld,PatientInfoMap.get(fld));
            }
        }
        
                
        if(!PrescriberInfoMap.isEmpty() && PrescriberInfoMap!= null){
            for(String fld : PrescriberInfoMap.keySet()){
                pCase.put(fld,PrescriberInfoMap.get(fld));
            }
        }
        
        try{
            insert pCase;
            return remsServiceId;
        }catch (exception e){
            return e.getMessage();
        }
    }

     /************************************************************************
    MethodName : create create_Task Record
    Description : it is common method
    *************************************************************************/
     public static Task create_Task (Id programId , Date DueDate, Id AssignToId , String TaskSub,Id TaskrctypeId, Id whatId, String comments ){
        Task tk = new Task();
        tk.RecordTypeId = TaskrctypeId;
        tk.Program_Name__c = programId;
        tk.ActivityDate = DueDate;
        tk.OwnerId  = AssignToId;
        tk.REMS_Program__c = 'Macitentan REMS';
        tk.Subject = TaskSub;
        tk.WhatId= whatId;
        tk.Description = comments;
        return tk;
        
    }
    
    /********************************************************************************************************************************************************
    Method Name     : getActivePage()
    Description     : Get the active page when user login into portal via change password link 
    ********************************************************************************************************************************************************** */ 
    @AuraEnabled
    public static String getActivePage() {
        try{   
            string pagename;         
            list<User> userList = [select id,username,Role__c,AccountId,Account.SYN_Signature__c,Account.Is_the_Certification_Page_Complete__c, Account.US_WSREMS__Status__c, Account.Pharmacy_Type__c, Account.SYN_User_Type__c,Account.AR_Category__c FROM User WHERE Id =: UserInfo.getUserId()];
            if(userList[0].Role__c == 'Prescriber' && userList[0].Account.SYN_Signature__c != 'Yes' ){
                pagename = 'prescriber';
            }else if(userList[0].Role__c == 'Prescriber' && userList[0].Account.SYN_Signature__c == 'Yes'){
                pagename = 'manage-patients';
            }else if(userList[0].Role__c == 'Outpatient Pharmacy' && userList[0].Account.Is_the_Certification_Page_Complete__c == false && userList[0].Account.US_WSREMS__Status__c != 'Active' && userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') && userList[0].Account.AR_Category__c == 'Primary'){
                pagename = 'pharmacy';
            }else if(userList[0].Role__c == 'Outpatient Pharmacy' && userList[0].Account.Is_the_Certification_Page_Complete__c == false && userList[0].Account.US_WSREMS__Status__c == 'Active' && userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') && userList[0].Account.AR_Category__c == 'Primary'){
                pagename = 'outpatientpharmacycompletecertification';
            }else if(userList[0].Role__c == 'Outpatient Pharmacy' && userList[0].Account.Is_the_Certification_Page_Complete__c == true){
                pagename = 'pharmacy-manage-home';
            }else if(userList[0].Role__c == 'Outpatient Pharmacy' && (!userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') || userList[0].Account.SYN_User_Type__c.contains('Authorized Representative')) && userList[0].Account.AR_Category__c != 'Primary'){
                pagename = 'pharmacy-manage-home';
            }else if(userList[0].Role__c == 'Inpatient Pharmacy' && userList[0].Account.US_WSREMS__Status__c != 'Active' && userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') && userList[0].Account.AR_Category__c == 'Primary'){
                pagename = 'inpatientpharmacycompletecertification';
            }else if(userList[0].Role__c == 'Inpatient Pharmacy' && userList[0].Account.US_WSREMS__Status__c == 'Active' && userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') && userList[0].Account.AR_Category__c == 'Primary'){
                pagename = 'inpatient-manage-pharmacy';
            }else if(userList[0].Role__c == 'Inpatient Pharmacy' && (!userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') || userList[0].Account.SYN_User_Type__c.contains('Authorized Representative')) && userList[0].Account.AR_Category__c != 'Primary'){
                pagename = 'inpatient-manage-pharmacy';
            }
                   
            return pagename;          
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    
    /********************************************************************************************************************************************************
    Method Name     : updateIsResetPassword()
    Description     : update is reset password to false.
    ********************************************************************************************************************************************************** */ 
    @AuraEnabled
    public static String updateIsResetPassword(string UserId) {
        try{
            User u = new User(Id=UserId);
            u.Is_Reset_Password_Req__c = false;
            update u;
        }catch(exception e){
            return e.getMessage();
        }
        return '';
    }
    
    /********************************************************************************************************************************************************
    Method Name     : getCurrentUserType()
    Description     : Get the current logged in portal user .
                      return: Logged in portal user.
    ********************************************************************************************************************************************************** */    
    @AuraEnabled
    public static user verifyUserResetPasswrod() {
        String usertype = '';
        User u = [SELECT Id,Is_Reset_Password_Req__c,Role__c,Account.Is_the_Certification_Page_Complete__c, Account.US_WSREMS__Status__c, Account.Pharmacy_Type__c, Account.SYN_User_Type__c,Account.AR_Category__c  FROM User WHERE Id =: UserInfo.getUserId() ];
           return u;
    }

    /********************************************************************************************************************************************************
    Method Name     : updatePharmacyPreference
    Description     : Update Pharmacy 2FA Profile
    ********************************************************************************************************************************************************** */    
    @AuraEnabled
    public static string updatePharmacyPreference(Account newAccount, String programId , String programName, String channel) {
        String returnstring ='';
        Set<String> chagedFieldValue = new Set<String>();
        String accountId = newAccount.Id;
        Case newCase = getPresriberAccountInfo();
        
        
        // Creating Rems service
        Map<String,Id> caseRecordTypes = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
       
        String remsServiceId = createREMSService('Change_of_Information',accountId,programId,newAccount.RecordType.Name);
        Id caseRecordTypeId = caseRecordTypes.get('Pharmacy_Participant_COI');
        newCase.US_WSREMS__Program_Picklist__c = programName;
        newCase.US_WSREMS__Channel__c=channel;
        newCase.US_WSREMS__REMS_Program__c = programId;
        newCase.US_WSREMS__REMS_Service_Summary__c = remsServiceId;
        newCase.Status='Complete';
        newCase.RecordTypeId = caseRecordTypeId;
        newCase.US_WSREMS__Participant__c = accountId;
        newCase.US_WSREMS__Outcome__c = 'Complete';
        newCase.Two_Factor_Authentication_Selection__c = newAccount.Two_Factor_Authentication_Selection__c;
        
        try{
            insert newCase;
            US_WSREMS__REMS_Service_Summary__c remsService = new US_WSREMS__REMS_Service_Summary__c(Id = remsServiceId);
            remsService.US_WSREMS__Path_Stage_Name__c ='Closed';
            remsService.US_WSREMS__Service_Outcome__c = 'Successful';
            remsService.US_WSREMS__Status__c = 'Closed';
            remsService.US_WSREMS__Path_Complete__c= true;
            update remsService;                
            returnstring = '';
        }catch(Exception e){
            system.debug('--Error---'+e.getMessage());
            returnstring = e.getMessage();
        }
        
        return returnstring;
    }

}