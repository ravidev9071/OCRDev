/**************************************************************************
    * Name :   SYN_InvitePharamcyStaffController
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  09/02/2022             Initial Version
    *********************************************************************************/
public without sharing class SYN_InvitePharamcyStaffController {

    static final Map<Id, Schema.RecordTypeInfo> mapCaseRecordTypesById =
        Schema.SObjectType.Case.getRecordTypeInfosById();
    
 /***********************************************************************************************************************************
    MethodName : getPharmacistInfo
    Description : return current user account info
    ************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Account getPharmacistInfo() {
       return MaciPortalCustomController.getPharmacistInfo();
    }
    
     /***********************************************************************************************************************************
    MethodName : getPharmacyInfo
    Description : return current user account info
    ************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Account getPharmacyInfo(Account acc, String ProgramName) {
    return SYN_ManagePharamcyController.getPharmacyInfo(acc,ProgramName);
    }
    
     /***********************************************************************************************************************************
    MethodName : getPharmacyTitle
    Description : OutPatient Pharmacy Enrollment - get Case Title Picklist Values
    ************************************************************************************************************************************/
    @AuraEnabled 
    public static Map<String, String> getPharmacyTitle(){
         return MaciPortalCustomController.getPharmacyTitle();
    }
    
    /***********************************************************************************************************************************
    MethodName : getPharmacyCredentails
    Description : Pharmacy Enrollment - get Case Credentials Picklist Values
    ***********************************************************************************************************************************/
    @AuraEnabled 
    public static Map<String, String> getPharmacyCredentails(){
         return MaciPortalCustomController.getPharmacyCredentails();
    }
    
    /***********************************************************************************************************************************
    MethodName : validatePharmacyStaffDupCheck
    Description : return true/false based on patient account detail on enrollment
    //Date  : 09/15/2024 changes added to resolve Duplicate record type issue from line 63 AND 64 by DILEEP G  
   
 
    ************************************************************************************************************************************/
    @AuraEnabled
    public static boolean validatePharmacyStaffDupCheck(String fname, String lname, String email,String programId, Account pharmacyAcct){
        
        boolean duplicateflag = false;
        Set<Id> accountId = new Set<Id>();
        Map<String,Id> recordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account');
        id PharmacyParticipantAccRecordTypeId = recordTypeMap.get('Pharmacy_Participant');
        List<Account> patientAccList= [SELECT Id,Name,SYN_Pharmacy__c FROM Account
                                       WHERE US_WSREMS__REMS_Program__c =: programId AND RecordTypeId =: PharmacyParticipantAccRecordTypeId 
                                       AND (( LastName =: lname AND US_WSREMS__Email__c =: Email) OR (FirstName =: fname AND LastName =: lname) OR (FirstName =: fname AND LastName =: lname AND US_WSREMS__Email__c =: Email) OR (US_WSREMS__Email__c =: Email)) ];
        if(!patientAccList.isEmpty()){
            for(Account acc : patientAccList){
                if(acc.SYN_Pharmacy__c  != null && acc.SYN_Pharmacy__c == pharmacyAcct.id){
                     duplicateflag = true; 
                     break;
                }else{
                  accountId.add(acc.id);  
                }
            }  
        }

        if(duplicateflag == false && !accountId.isEmpty()){
              List<US_WSREMS__Affiliation__c> pharmacyAffiliations = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c
                                                                                                                         FROM US_WSREMS__Affiliation__c 
                                                                                                                         WHERE US_WSREMS__Pharmacy__c != null AND US_WSREMS__Pharmacy__c =: pharmacyAcct.id 
                                                                                                                         AND US_WSREMS__isActive__c = true AND US_WSREMS__REMSProgram__c =: programId
                                                                                                                         AND US_WSREMS__Pharmacy_User__c != null AND US_WSREMS__Pharmacy_User__c IN:accountId];

            if(!pharmacyAffiliations.isEmpty() ){
                duplicateflag = true;
            } 

        }                                                                                                        
        return duplicateflag;
    }
    
     /***********************************************************************************************************************************
    MethodName : createPharmacyPortalUserArAccount
    Description : OutPatient Pharmacy Enrollment - When user click on next button on password screen, 
    create Pharmacuy participant account and portal user under the account
    ***********************************************************************************************************************************/
    @AuraEnabled()
    public static string createPharmacyPortalUserArAccount(Case pharmacyObj,String pharmacyType, Account pharmacyAccount, String programId, String userType, Account authRepAccount, Date startDate) {
         Set<Id> accountIds = new Set<Id>();
         Set<Id> pharmacyTypeAccountIds = new Set<Id>();
         String pharmacyTypeAccountId;
         Map<String,Id> accountRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account');
         Id PharmacyParticipantAccRecordTypeId = accountRecordTypeMap.get('Pharmacy_Participant');
         List<Account> patientAccList= [SELECT Id,FirstName,LastName,US_WSREMS__Email__c,SYN_User_Type__c, SYN_Pharmacy__c FROM Account
                                       WHERE US_WSREMS__REMS_Program__c =: programId AND RecordTypeId =: PharmacyParticipantAccRecordTypeId 
                                       AND (( LastName =: pharmacyObj.US_WSREMS__Last_Name__c AND US_WSREMS__Email__c =: pharmacyObj.US_WSREMS__Email__c) OR (FirstName =: pharmacyObj.US_WSREMS__First_Name__c AND LastName =: pharmacyObj.US_WSREMS__Last_Name__c) OR (FirstName =: pharmacyObj.US_WSREMS__First_Name__c AND LastName =: pharmacyObj.US_WSREMS__Last_Name__c AND US_WSREMS__Email__c =: pharmacyObj.US_WSREMS__Email__c)) ];
         
         if(!patientAccList.isEmpty()){
             for(Account acc : patientAccList){
                 if(acc.FirstName == pharmacyObj.US_WSREMS__First_Name__c && acc.LastName == pharmacyObj.US_WSREMS__Last_Name__c && acc.US_WSREMS__Email__c == pharmacyObj.US_WSREMS__Email__c){
                    accountIds.add(acc.id);  
                    //break;
                 }else if(acc.FirstName == pharmacyObj.US_WSREMS__First_Name__c && acc.LastName == pharmacyObj.US_WSREMS__Last_Name__c){
                    accountIds.add(acc.id);  
                    //break;
                 }else if(acc.LastName == pharmacyObj.US_WSREMS__Last_Name__c && acc.US_WSREMS__Email__c == pharmacyObj.US_WSREMS__Email__c){
                    accountIds.add(acc.id);  
                    //break;
                 }
             }
         }
        
         if(!accountIds.isEmpty()){
         
             List<US_WSREMS__Affiliation__c> pharmacyAffiliations = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__r.Pharmacy_Type__c
                                                                                                                         FROM US_WSREMS__Affiliation__c 
                                                                                                                         WHERE US_WSREMS__Pharmacy__c != null
                                                                                                                         AND US_WSREMS__isActive__c = true AND US_WSREMS__REMSProgram__c =: programId
                                                                                                                         AND US_WSREMS__Pharmacy_User__c != null AND US_WSREMS__Pharmacy_User__c =: accountIds];
              for(US_WSREMS__Affiliation__c aff : pharmacyAffiliations){
                  if(aff.US_WSREMS__Pharmacy__r.Pharmacy_Type__c.contains(pharmacyType)){
                      pharmacyTypeAccountIds.add(aff.US_WSREMS__Pharmacy_User__c);
                      pharmacyTypeAccountId = aff.US_WSREMS__Pharmacy_User__c;
                      break;
                  }
              }  
                                                                                                             
         }
         
         if(!pharmacyTypeAccountIds.isEmpty()){
             updatePharmacyArRecord(pharmacyTypeAccountId,userType,authRepAccount, false);
             return createPharmacyAffiliationRecord(pharmacyTypeAccountId, pharmacyAccount, programId, userType, authRepAccount,startDate);
         }else if(patientAccList.isEmpty() || accountIds.isEmpty() || pharmacyTypeAccountIds.isEmpty()){
             return createPharmacyPortalUserAccount(pharmacyObj,pharmacyAccount, programId, userType, authRepAccount, startDate);
         }
         else{
             return null;
         }
    }
    
    
    /***********************************************************************************************************************************
    MethodName : createPharmacyPortalUserAccount
    Description : Pharmacy participant account when user invite the pharmacy staff / AR rep 
    ***********************************************************************************************************************************/
    @AuraEnabled
    public static string createPharmacyPortalUserAccount(Case pharmacyObj, Account pharmacyAccount, String programId, String userType,Account authRepAccount,Date startDate) {
        Set<Id> sucessCaseIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Id sucessCaseId;
        Id portalUserId = null;
        Id contactId = null;
        List<Contact> contactListToInsert = new List<Contact>();
        String accountId;
        String affiliationId;
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        id recordTypeId = caseRecordTypeMap.get('Pharmacy_Participant_Account');
        pharmacyObj.RecordTypeId = recordTypeId;
        if(userType == 'Authorized Representative'){
            pharmacyObj.AR_Category__c= 'Secondary';
        }

        try{
            insert pharmacyObj;
        }catch(exception e ){
            system.debug('----Error------'+e.getMessage());
        }
        
        if(pharmacyObj.Id != null){
             REMSPagelayoutConfigComponentController.AccountCreationDetails  acd= REMSPagelayoutConfigComponentController.createAccountOnCaseCreation(pharmacyObj.id);
             accountId = acd.AccountId;
             string errormessage = acd.notificationMsg;
                     
             affiliationId = createPharmacyAffiliationRecord(accountId, pharmacyAccount, programId, userType,authRepAccount,startDate);
             updatePharmacyArRecord(accountId,null,authRepAccount,true);
             
        }
         
       return affiliationId ;
    }
    
    /***********************************************************************************************************************************
    MethodName : createPharmacyAffiliationRecord
    Description : Creating addiliation record when invite pharmacy staff / AR rep 
    ***********************************************************************************************************************************/
    public static string createPharmacyAffiliationRecord(string accountId, Account pharmacyAccount, string programId, string userType,Account authRepAccount, Date startDate) {
        Id pharmacyUserAffiRecTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c paff = new US_WSREMS__Affiliation__c();
        paff.US_WSREMS__Pharmacy__c = pharmacyAccount.id;
        paff.US_WSREMS__Pharmacy_User__c = accountId;
        paff.US_WSREMS__isActive__c = true;
        paff.US_WSREMS__REMSProgram__c = programId;
        paff.US_WSREMS__UserType__c = userType;
        paff.US_WSREMS__Authorized_Representative__c = authRepAccount.id;
        paff.Status__c = 'Pending';
        if(startDate == null){
            paff.US_WSREMS__Start_Date__c = Date.Today();
        }else{
            paff.US_WSREMS__Start_Date__c = startDate;  
        }
        if(userType == 'Authorized Representative'){
            paff.AR_Category__c= 'Secondary';
        }else{
            paff.AR_Category__c= '';
        }
        paff.recordTypeId = pharmacyUserAffiRecTypeId;
        
        try{
            insert paff;
        }catch (exception e){
            system.debug('--Error---'+e.getMessage());
        }
        return paff.id;
    }
    
     /***********************************************************************************************************************************
    MethodName : updatePharmacyArRecord
    Description : we are upding Send invite checkbox to true when user click resent button / Send Invite from Pharmacy Staff/ AR Pages.
    ***********************************************************************************************************************************/
    
    public static void updatePharmacyArRecord(string accountId, string userType, Account authRepAcc, boolean isNewAccount) {
        Account authRep= [SELECT Id,OwnerId FROM Account WHERE id =:authRepAcc.Id LIMIT 1]; 
        Account acc = new Account (Id=accountId);
        if(isNewAccount){
            acc.US_WSREMS__Status__c ='Pending';
        }
        if(userType != null && acc.SYN_User_Type__c != null){
            acc.SYN_User_Type__c = acc.SYN_User_Type__c+userType;
        }
        //acc.Send_Invite__c = true;
        acc.OwnerId = authRep.OwnerId;
        try{
            update acc;
        }catch (exception e){
            system.debug('--Error---'+e.getMessage());
        }
    }
    
    
    /***********************************************************************************************************************************
    MethodName : validatePrescriberData
    Description : verifying prescriber data is valid or not
    ***********************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Account validatePrescriberData(String npi, String programId) {
      
       List<Account> prescriberAcc= [SELECT Id,Name,FirstName,LastName, US_WSREMS__NPI__c, US_WSREMS__Status__c FROM Account WHERE US_WSREMS__NPI__c != null AND US_WSREMS__NPI__c =: npi AND US_WSREMS__REMS_Program__c =:programId AND RecordType.DeveloperName = 'Prescriber' LIMIT 1];         

       return prescriberAcc[0];
    }
    
    /***********************************************************************************************************************************
    MethodName : validatePatientData
    Description : verifying patinet data is valid or not .
    ***********************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Account validatePatientData(String fname, String mname, String lname, date dob, String programId) {
        String firstname = fname.trim();
        String lastname = lname.trim();
        String middlename='';
        if(mname != null && mname != ''){
           middlename = mname.trim();
        }else{
            middlename = mname;
        }
     //Added by dileep  Monthly_Pregnancy_Test_Date__c,Counseling_Completion_Date__c into the EXISTING query as part of BT7433-2127 user story to fetch the values into the portal screen on maciRDA1 Cmp. 
       List<Account> patientAcc= [SELECT Id,
                                         Name,
                                         FirstName,
                                         LastName, 
                                         US_WSREMS__NPI__c, 
                                         US_WSREMS__Status__c,
                                         US_WSREMS__DOB__c,
                                         SYN_Ref_Id__c,
                                         US_WSREMS__Patient_Risk_Category__c,
                                         ShippingPostalCode,
                                         Patient_Reproductive_Status_Date__c,
                                         Counseling_Recorded__c,
                                         Monthly_Pregnancy_Test_Recorded__c,
                                         Monthly_Pregnancy_Test_Date__c,
                                         Counseling_Completion_Date__c  
                                         FROM Account
                                         WHERE US_WSREMS__REMS_Program__c =:programId
                                          AND RecordType.DeveloperName = 'Patient'
                                          AND ((FirstName =:firstname AND MiddleName =: middlename AND LastName =: lastname AND US_WSREMS__DOB__c =: dob) 
                                          OR (FirstName =:firstname AND LastName =: lastname AND US_WSREMS__DOB__c =: dob)) LIMIT 1];        
      
       return patientAcc[0];
    
    }

     
    /* POC Related Methods */
    
    @AuraEnabled(cacheable=true)
    public static Account getCurrentPharmacyInfo(String recordId) {
      
       Account pharmacyAcc= [SELECT Id,Name, US_WSREMS__NPI__c, Phone, Fax, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,SYN_Signature_Date__c,Address_1_Secondary_Office__c,City_Secondary_Office__c,
                          State_Secondary_Office__c,Zip_Secondary_Office__c FROM Account WHERE Id =: recordId LIMIT 1];         

       return pharmacyAcc;
    }
    
    /***********************************************************************************************************************************
    MethodName : getRDAManufacturerValues //BT-7433-994-SP17
    Description : Obtain RDA Button - get Case Manufacturer Picklist Values
    ***********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> getRDAManufacturerValues(){
         Map<String, String> fieldValues = new Map<String, String>();
        //get Case Credentials Field Describe
        Schema.DescribeFieldResult fieldResult = Case.Manufacturer__c.getDescribe();
        //get Case State Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            fieldValues.put(p.getValue(), p.getLabel());
        }        
        
        return fieldValues ;        
    }
    
    /***********************************************************************************************************************************
    MethodName : getRDANDCCodeValues //BT-7433-994-SP17
    Description : Obtain RDA Button - get Case NDC Code Picklist Values
    ***********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> getRDANDCCodeValues(){
         Map<String, String> fieldValues = new Map<String, String>();
        //get Case Credentials Field Describe
        Schema.DescribeFieldResult fieldResult = Case.NDC_Code__c.getDescribe();
        //get Case State Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            fieldValues.put(p.getValue(), p.getLabel());
        }        
        
        return fieldValues ;        
    }
     /***********************************************************************************************************************************
    MethodName : getResonsForDaysSupplyValues //BT-7433-994-SP17
    Description : Obtain RDA Button - get Case Reasons For Days supply Picklist Values
    ***********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> getResonsForDaysSupplyValues(){
         Map<String, String> fieldValues = new Map<String, String>();
        //get Case Credentials Field Describe
        Schema.DescribeFieldResult fieldResult = Case.Reason_for_Days_Supply_30__c.getDescribe();
        //get Case State Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            fieldValues.put(p.getValue(), p.getLabel());
        }        
        
        return fieldValues ;        
    }
    
   /***********************************************************************************************************************************
    MethodName : getResonsForTreatmentInterrValues //BT-7433-994-SP17 
    Description : Obtain RDA Button - get Case Reasons For treatment interruption Picklist Values
    ***********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> getResonsForTreatmentInterrValues(){
         Map<String, String> fieldValues = new Map<String, String>();
        //get Case Credentials Field Describe
        Schema.DescribeFieldResult fieldResult = Case.Reason_for_Treatment_Interruption__c.getDescribe();
        //get Case State Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            fieldValues.put(p.getValue(), p.getLabel());
        }        
        
        return fieldValues ;        
    }
    //BT-7433-994-SP17
    //Method to get the most recent RDA under the patient account of the inserting RDA and get the field values from the shipping and tracking recent record.
    //Changes made on 09/10/2024 regarding days of interruption calculation by Dileep Gurram(Wilco) regarding BT7433-2364
   @AuraEnabled
    public static Integer getShipmentRelatedDataForMACIRDA(Id patientId){
        
        Integer daysOfInterruption;
        List<Case> rdaCompletedCaseList = New List<Case>();
        List<US_WSREMS__Shipping_and_Tracking__c> shippingNDTrackingRecsList = New List<US_WSREMS__Shipping_and_Tracking__c>();
        Map<Id,Case> patientIdvsExistingRDARec = New Map<Id,Case>();
        Map<Id,US_WSREMS__Shipping_and_Tracking__c> completedRDAvsShippingTrackingRec = New Map<Id,US_WSREMS__Shipping_and_Tracking__c>();
        if(patientId != null){
            rdaCompletedCaseList = [SELECT Id,RecordTypeId,US_WSREMS__Patient__c,US_WSREMS__Patient__r.Days_Supply__c,US_WSREMS__Patient__r.Shipment_Date__c,REMS_Project_Code__c,Recordtype.Name,RecordType.DeveloperName FROM Case WHERE US_WSREMS__Patient__c =:patientId AND RecordType.DeveloperName = 'PDA' AND REMS_Project_Code__c =: Label.MACIProgramProjectCode ORDER BY CreatedDate DESC];
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
            
                if(patientIdvsExistingRDARec.containskey(patientId)){
                    if(patientId == patientIdvsExistingRDARec.get(patientId).US_WSREMS__Patient__c && mapCaseRecordTypesById.get(patientIdvsExistingRDARec.get(patientId).RecordTypeId).getDeveloperName() == 'PDA'){
                           Date calculatedShippingDate = patientIdvsExistingRDARec.get(patientId).US_WSREMS__Patient__r.Shipment_Date__c.addDays(Integer.valueOf(patientIdvsExistingRDARec.get(patientId).US_WSREMS__Patient__r.Days_Supply__c));
                           daysOfInterruption = calculatedShippingDate.daysBetween(date.today())-5;
                       }
                }
        }
        try{ 
            if(daysOfInterruption != null){
                return daysOfInterruption;
            }
                return null;
            
        }catch (exception e){
            system.debug('ErrorMSG---'+e.getMessage());
            return null;
        }
    }  
    
    //BT-7433: 994 - SP17
    @AuraEnabled
    public static Case getRDACaseData(Id createdRDACaseRecordId){
        Case rdaCase = New Case();
        if(createdRDACaseRecordId != null){
            rdaCase = [SELECT Id,RDA_Authorization_Code__c,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy__r.Name,US_WSREMS__Pharmacy__r.US_WSREMS__NPI__c,US_WSREMS__Pharmacy__r.SYN_Signature_Date__c,Pharmacy_Participant__c,Pharmacy_Participant__r.FirstName,Pharmacy_Participant__r.LastName,SYN_Prescriber__c,SYN_Prescriber__r.FirstName,SYN_Prescriber__r.LastName,US_WSREMS__Patient__c,US_WSREMS__Patient__r.FirstName,US_WSREMS__Patient__r.LastName,US_WSREMS__Patient__r.US_WSREMS__DOB__c,Manufacturer__c,NDC_Code__c,SYN_Days_Supply__c FROM Case where Id =: createdRDACaseRecordId LIMIT 1];
        }
        if(rdaCase != null){
          return rdaCase;  
        }
        return null;
    }
                                             
   //BT-7433: 994 - SP17
    @AuraEnabled
    public static string createRDACaseRecord(Case newCase,Account authRepAccount,Account pharmacyAccount,Account prescriberAccount,Account patientAccount){
        
        Map<String,String> PharmacyInfoMap = new Map<String,String>();
        Map<String,String> PharmacyParticipantInfoMap = new Map<String,String>();
        Map<String,String> PatientInfoMap = new Map<String,String>();
        Map<String,String> PrescriberInfoMap = new Map<String,String>();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();
       
        // Creating Rems service
        String remsServiceId = SYN_PortalEnrollmentController.createREMSService('Pre_Dispense_Authorization',pharmacyAccount.id,pharmacyAccount.US_WSREMS__REMS_Program__c,'Pharmacy');
        //ADD rec type chcek in the syn+portalenrollmentController class. createremsserviec method...
        
        if(pharmacyAccount != null){
            String sect = 'Pharmacy'+';'+'US_WSREMS__Pharmacy__c'+';'+pharmacyAccount.Program_Name__c;
            PharmacyInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(pharmacyAccount.id,'Case',caseRecordTypeId ,sect);
        }
        if(authRepAccount != null){
            String sect = 'Pharmacy'+';'+'Pharmacy_Participant__c'+';'+pharmacyAccount.Program_Name__c;
            PharmacyParticipantInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(authRepAccount.id,'Case',caseRecordTypeId ,sect);
        }
        if(patientAccount != null){
            String sect = 'Pharmacy'+';'+'US_WSREMS__Patient__c'+';'+pharmacyAccount.Program_Name__c;
            PatientInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(patientAccount.id,'Case',caseRecordTypeId ,sect);
        }
        if(prescriberAccount != null){
            String sect = 'Pharmacy'+';'+'SYN_Prescriber__c'+';'+pharmacyAccount.Program_Name__c;
            PrescriberInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(prescriberAccount.id,'Case',caseRecordTypeId ,sect);
        }
        
        if(!PharmacyInfoMap.isEmpty() && PharmacyInfoMap!= null){
            for(String fld : PharmacyInfoMap.keySet()){
                newCase.put(fld,PharmacyInfoMap.get(fld));
            }
        }
        
        if(!PharmacyParticipantInfoMap.isEmpty() && PharmacyParticipantInfoMap!= null){
            for(String fld : PharmacyParticipantInfoMap.keySet()){
                newCase.put(fld,PharmacyParticipantInfoMap.get(fld));
            }
        }
        
        if(!PatientInfoMap.isEmpty() && PatientInfoMap!= null){
            for(String fld : PatientInfoMap.keySet()){
                if(fld != 'Counseling_Recorded__c' && fld != 'Monthly_Pregnancy_Test_Recorded__c'
                   && fld != 'Recent_Patient_Reproductive_Status_Date__c' && fld != 'US_WSREMS__DOB__c'){
                    newCase.put(fld,PatientInfoMap.get(fld));
                }
            }
        }
        
        if(!PrescriberInfoMap.isEmpty() && PrescriberInfoMap!= null){
            for(String fld : PrescriberInfoMap.keySet()){
                newCase.put(fld,PrescriberInfoMap.get(fld));
            }
        }
        
        if(newCase != null){
            newCase.RecordTypeId = caseRecordTypeId;
            newCase.US_WSREMS__REMS_Program__c = pharmacyAccount.US_WSREMS__REMS_Program__c;
            newCase.US_WSREMS__REMS_Service_Summary__c = remsServiceId;
            newCase.SYN_Date__c = Date.Today();
            newCase.Status = 'Complete';
            newCase.US_WSREMS__Outcome__c = 'Approved';
            newCase.US_WSREMS__Participant__c = pharmacyAccount.Id;
            newCase.US_WSREMS__Pharmacy__c = pharmacyAccount.Id;
            newCase.Pharmacy_Participant__c = authRepAccount.Id;
            newCase.US_WSREMS__Patient__c = patientAccount.Id;
            newCase.SYN_Prescriber__c = prescriberAccount.Id;
        }
        
       try{
            insert newCase;
           
           if(newCase.Id != null){
              return newCase.Id; 
           }
           return null;
        }catch (exception e){
             system.debug('ErrorMessage-CreatingRDA--'+e.getMessage());
            return 'RDA creation error';
        }
        
        
    }
    
    //BT-7433: 994 - SP17 - This methd is responsible to create a Pregnancy test service, case when the checkbox is manually checked by the user...
    @AuraEnabled
    public static void createPharmacyPatientTestRecord(String program, Id patientId,Account pharmacy,String programName,String channel,String pharmacyParticipant,String prescriber){
        String remsServiceId = SYN_ManagePharamcyController.createPharmacyPatientTestRecord(program,patientId,pharmacy,programName,channel,pharmacyParticipant,prescriber);
    }
    
    /************************************************************************
    MethodName : createPatientCounselingCaseRecord Records
    Description : Create Rems Service and case Records for patient pregnancy type
    *************************************************************************/
    @AuraEnabled
    public static void createPatientCounselingChecklistCaseRecord(Account authRepAccount,Account pharmacyAccount,Account prescriberAccount,Account patientAccount,String channel){  
        Case newCase;
        Map<String,String> PharmacyInfoMap = new Map<String,String>();
        Map<String,String> PharmacyParticipantInfoMap = new Map<String,String>();
        Map<String,String> PatientInfoMap = new Map<String,String>();
        Map<String,String> PrescriberInfoMap = new Map<String,String>();
        // Creating Rems service
        Map<String,Id> CaseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
         Id caseRecordTypeId = CaseRecordTypeMap.get('Patient_Counseling_Checklist');
        String remsServiceId = SYN_PortalEnrollmentController.createPatientPregnancyREMSService('Patient_Counseling_Checklist',pharmacyAccount.Id,pharmacyAccount.US_WSREMS__REMS_Program__c,'Pharmacy',patientAccount.Id);
        
        if(pharmacyAccount != null){
            String sect = 'Pharmacy'+';'+'SYN_Pharmacy__c'+';'+pharmacyAccount.Program_Name__c;
            PharmacyInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(pharmacyAccount.id,'Case',caseRecordTypeId ,sect);
        }
        if(authRepAccount != null){
            String sect = 'Pharmacy'+';'+'Pharmacy_Participant__c'+';'+pharmacyAccount.Program_Name__c;
            PharmacyParticipantInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(authRepAccount.id,'Case',caseRecordTypeId ,sect);
        }
        if(patientAccount != null){
            String sect = 'Pharmacy'+';'+'US_WSREMS__Patient__c'+';'+pharmacyAccount.Program_Name__c;
            PatientInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(patientAccount.id,'Case',caseRecordTypeId ,sect);
        }
        if(prescriberAccount != null){
            String sect = 'Pharmacy'+';'+'SYN_Prescriber__c'+';'+pharmacyAccount.Program_Name__c;
            PrescriberInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(prescriberAccount.id,'Case',caseRecordTypeId ,sect);
        }
        
        newCase = New Case(RecordTypeId = caseRecordTypeId,US_WSREMS__Program_Picklist__c = pharmacyAccount.Program_Name__c,US_WSREMS__Channel__c=channel,
                        US_WSREMS__REMS_Program__c = pharmacyAccount.US_WSREMS__REMS_Program__c,US_WSREMS__Patient__c=patientAccount.Id,US_WSREMS__DOB__c=patientAccount.US_WSREMS__DOB__c,
                        Recent_Patient_Reproductive_Status_Date__c=patientAccount.Patient_Reproductive_Status_Date__c,SYN_Prescriber__c = prescriberAccount.Id,
                        SYN_Pharmacy__c = pharmacyAccount.Id,US_WSREMS__Participant__c=pharmacyAccount.Id,Pharmacy_Participant__c=authRepAccount.Id,Counseling_Recorded__c=true,
                        Counseling_Completion_Date__c=Date.Today(),US_WSREMS__Outcome__c='Complete',Status='Complete',US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__Pharmacy__c = pharmacyAccount.Id);
        
        if(!PharmacyInfoMap.isEmpty() && PharmacyInfoMap!= null){
            for(String fld : PharmacyInfoMap.keySet()){
                if(fld !='Pharmacy_Status__c '){
                  newCase.put(fld,PharmacyInfoMap.get(fld));  
                }
                
            }
        }
        
        if(!PharmacyParticipantInfoMap.isEmpty() && PharmacyParticipantInfoMap!= null){
            for(String fld : PharmacyParticipantInfoMap.keySet()){
                newCase.put(fld,PharmacyParticipantInfoMap.get(fld));
            }
        }
        
        if(!PatientInfoMap.isEmpty() && PatientInfoMap!= null){
            for(String fld : PatientInfoMap.keySet()){
                if(fld != 'Counseling_Recorded__c' && fld != 'Monthly_Pregnancy_Test_Recorded__c'
                   && fld != 'Recent_Patient_Reproductive_Status_Date__c' && fld != 'US_WSREMS__DOB__c'){
                    newCase.put(fld,PatientInfoMap.get(fld));
                }
            }
        }
        
        if(!PrescriberInfoMap.isEmpty() && PrescriberInfoMap!= null){
            for(String fld : PrescriberInfoMap.keySet()){
                newCase.put(fld,PrescriberInfoMap.get(fld));
            }
        }
        newCase.US_WSREMS__Patient__c=patientAccount.Id;
        newCase.SYN_Prescriber__c = prescriberAccount.Id;
        newCase.SYN_Pharmacy__c = pharmacyAccount.Id;
        newCase.Pharmacy_Participant__c=authRepAccount.Id;
       
        try{
            insert newCase;
        }catch (exception e){
            system.debug('In PatCOuns ERror'+e.getMessage());
        } 
    }
    
    /************************************************************************
    MethodName : getCurrentPharmacyAffilcationList
    Description : retiurn list of certified pharmacy record based on program.
    *************************************************************************/
    
    @AuraEnabled
    public static List<US_WSREMS__Affiliation__c> getCurrentPharmacyAffilcationList(String recordId){
        List<US_WSREMS__Affiliation__c> pharmacyAffiliations = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy_User__r.Name,US_WSREMS__Pharmacy_User__r.US_WSREMS__Status__c,US_WSREMS__Pharmacy_User__r.IsCustomerPortal,         
                                                                                                                             US_WSREMS__Pharmacy_User__r.Date_Enrolled__c,US_WSREMS__Pharmacy_User__r.SYN_User_Type__c,
                                                                                                                             Status__c,US_WSREMS__UserType__c,US_WSREMS__Start_Date__c,AR_Category__c,Default__c
                                                                                                                             FROM US_WSREMS__Affiliation__c 
                                                                                                                             WHERE US_WSREMS__Pharmacy__c != null AND US_WSREMS__Pharmacy__c =: recordId
                                                                                                                             AND US_WSREMS__isActive__c = true AND US_WSREMS__Pharmacy_User__c != null ];
        if(!pharmacyAffiliations.isEmpty()){
            return pharmacyAffiliations;                                                                                                                      
        }else{
            return null;
        }                                                                
    }
    
    
    /************************************************************************
    MethodName : checkInvitatoDate
    Description : retiurn list of certified pharmacy record based on program.
    *************************************************************************/
    
    @AuraEnabled
    public static boolean checkInvitatoDate(Date invitationDate){
      if(invitationDate < = date.today()){
          return false;
      }else{
          return true;
      }                                                  
    }
    
    /************************************************************************
    MethodName : sendPrescriberInvitation
    Description : Update prescriber email on contact and update Send Invite CheckBox on prescriber account when user click on Send Invite Button,
    By Using this checkbox , we are going to send email alert to prescriber.
    *************************************************************************/
    @Auraenabled
    public static string sendPrescriberInvitation(string recordId, String email, String accountId){
        updatePrescriberContact(recordId,email);
        Account acc = new Account (Id=accountId);
        acc.Send_Invite__c = true;
        try{
               update acc;
               return '';
        }catch(exception e){
               system.debug('Error----'+e.getMessage());
               return e.getMessage();
        }
    }
    
     /************************************************************************
    MethodName : updatePrescriberContact
    Description : Update prescriber email on contact when user click on Send Invite Button,
    *************************************************************************/
    public static void updatePrescriberContact(string recordId, String email){
        Contact con = new Contact(Id=recordId);
        con.Email = email;
        try{
               update con;
        }catch(exception e){
               system.debug('Error----'+e.getMessage());
        }
    }
    
    /************************************************************************
    MethodName : activatePharmcyARStatus
    Description : Account status to active when user click on Active,
    *************************************************************************/
    @AuraEnabled
    public static void updatePPActiveStatus(string recordId){
        Account acc= new Account(Id=recordId);
        acc.US_WSREMS__Status__c= 'Active';
        try{
               update acc;
        }catch(exception e){
               system.debug('Error----'+e.getMessage());
        }
    }
    
    
    /************************************************************************
    MethodName : updatePPAffilationActiveStatus
    Description : Affilation status to active when user click on Active,
    *************************************************************************/
    @AuraEnabled
    public static boolean updatePPAffilationActiveStatus(string recordId){
        String PharmcyId = '';
        String UserType = '';
        boolean duplicate = false;
        List<US_WSREMS__Affiliation__c> currentAffilation = [SELECT Id,Status__c,US_WSREMS__End_Date__c,US_WSREMS__isActive__c,US_WSREMS__UserType__c,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c FROM US_WSREMS__Affiliation__c WHERE Id =: recordId AND US_WSREMS__Pharmacy__c != null AND US_WSREMS__Pharmacy_User__c != null];
        if(!currentAffilation.isEmpty()){
            PharmcyId = currentAffilation[0].US_WSREMS__Pharmacy__c;
            UserType = currentAffilation[0].US_WSREMS__UserType__c;
        }
        
        if(UserType != '' && UserType =='Authorized Representative' && PharmcyId != ''){
            List<US_WSREMS__Affiliation__c> affilationList = [SELECT Id FROM US_WSREMS__Affiliation__c WHERE Status__c = 'Active' AND US_WSREMS__isActive__c  = true AND US_WSREMS__Pharmacy__c =: PharmcyId AND US_WSREMS__UserType__c =: UserType];
            if(!affilationList.isEmpty() && affilationList.size()>1 ){
                duplicate = true;
            }
        }
        if(duplicate == false){
            List<US_WSREMS__Affiliation__c> affilationList = [SELECT Id FROM US_WSREMS__Affiliation__c WHERE Status__c = 'Active' AND US_WSREMS__isActive__c  = true AND Default__c = true AND Id =: recordId ]; 
            US_WSREMS__Affiliation__c aff = new US_WSREMS__Affiliation__c(Id=recordId);
            aff.Status__c = 'Active';
            aff.US_WSREMS__End_Date__c = null;
            aff.US_WSREMS__isActive__c = true;
            if(affilationList.isEmpty()){
                aff.Default__c = true;
            }
            try{
                update aff;
                Account acc = new Account(Id = currentAffilation[0].US_WSREMS__Pharmacy_User__c);
                acc.US_WSREMS__Status__c = 'Active';
                update acc;
            }catch(exception e){
                system.debug('Error----'+e.getMessage());
            }
        }
        
        return duplicate;
    }
    /************************************************************************
    MethodName : sendOfficeContactInvitation
    Description : Update OfficeContact email on contact and update Send Invite CheckBox on OfficeContact account when user click on Send Invite Button,
    By Using this checkbox , we are going to send email alert to OfficeContact.
    *************************************************************************/
    @Auraenabled
    public static string sendOfficeContactInvitation(string recordId, String email, String accountId){
       id affRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Prescriber_Affiliation').getRecordTypeId();
      String prg =SYN_Utilitycls.MACI_PROGRAM_NAME;
      String validateAff=label.Affliation_Not_Found;
        try{
        updatePrescriberContact(recordId,email);
        updateOfficeContact(accountId);
        List<US_WSREMS__Affiliation__c> ocAff= getCurrentPrescriberAffilcationList(accountId,prg);
        if(ocAff == null){
            return validateAff;
        }
            return '';
        }catch(exception e){
               system.debug('Error----'+e.getMessage());
               return e.getMessage();
        }
    }
    @AuraEnabled
    public static List<US_WSREMS__Affiliation__c> getCurrentPrescriberAffilcationList(String recordId,String prg){
        id affRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Prescriber_Affiliation').getRecordTypeId();
        List<US_WSREMS__Affiliation__c> ocAff = [SELECT id FROM US_WSREMS__Affiliation__c WHERE Office_Contact__c = :recordId AND US_WSREMS__Prescriber__c != NULL AND Office_Contact__c != null AND US_WSREMS__isActive__c =TRUE AND US_WSREMS__REMSProgram__r.Name = :Prg LIMIT 1];
        if(!ocAff.isEmpty()){
            return ocAff;                                                                                                                      
        }else{
            return null;
        }  
        
    }
      /************************************************************************
    MethodName : updateOfficeContact
    Description : Update OfficeContact Send Invite  when user click on Send Invite Button,
    *************************************************************************/
    public static void  updateOfficeContact(string accountId){
        Account acc = new Account (Id = accountId);
        acc.Send_Invite__c = true;
       
        try{
            update acc;
           
        }catch(exception e){
               system.debug('Error----'+e.getMessage());
        }
    }
}