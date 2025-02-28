/**
* @File Name          : MaciPortalCustomController.cls
* @Description        : This class download files .
* @TestClass          : REMSfileDownloadControllerTest
* @Author             : Shikha Chaurasia
* @Date               : 07-06-2022
**/

public without sharing class MaciPortalCustomController {

    /***********************************************************************************************************************************
    MethodName : getCurrentUserType
    Description :
    ************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static user getCurrentUserType() {
        String usertype = '';
        User u = [SELECT Id, Name,Email, UserType, Role__c,Account.US_WSREMS__Status__c FROM User WHERE Id =: UserInfo.getUserId()];
        return u;
    }
    
    /***********************************************************************************************************************************
    MethodName : validatePortalUser
    Description : retiurn true/false based on user availablity.
    ************************************************************************************************************************************/
    @AuraEnabled
    public static boolean validatePortalUser(String email, string npi, string role, string program){
    
        boolean duplicateflag = false;
        List<User> userList = [SELECT Id FROM User WHERE Email = : email AND Role__c = : role AND Program__c =: program];
        if(!userList.isEmpty()){
            duplicateflag = true;
        }else if(npi != null) {
            List<Contact> contactList = [SELECT Id, AccountId FROM Contact WHERE AccountId != null AND Account.US_WSREMS__NPI__c != null AND  Account.US_WSREMS__NPI__c =: npi
                                                                                 AND Account.US_WSREMS__REMS_Program__c != null AND Account.US_WSREMS__REMS_Program__r.Name =: program LIMIT 1];
            if(!contactList.isEmpty()) {
                List<User> poratlUserList = [SELECT Id FROM User WHERE ContactId != null AND ContactId =: contactList[0].Id];
                if(!poratlUserList.isEmpty()){
                    duplicateflag = true;
                }
            }                                                                                       
        }
        return duplicateflag;
    }
    /***********************************************************************************************************************************
    MethodName : validatePortalUserInfo
    Description : retiurn error message based on user availablity.
    ************************************************************************************************************************************/
    @AuraEnabled
    public static string validatePortalUserInfo(String email, string npi,  string role, string program, string lname, string phone){
        String duplicateMessage = '';
        List<Account> prescriberList= [SELECT Id,US_WSREMS__Channel__c,US_WSREMS__Status__c FROM Account WHERE ((US_WSREMS__NPI__c != null AND US_WSREMS__NPI__c =: npi) OR (Email_address__c != null AND Email_address__c =: email) OR (LastName =: lname AND US_WSREMS__NPI__c != null AND US_WSREMS__NPI__c =: npi)) AND Program_Name__c =: program AND RecordType.Developername = 'Prescriber' ORDER BY US_WSREMS__NPI__c NULLS Last];
        if(!prescriberList.isEmpty()){
            for(Account acc : prescriberList){
                if(acc.US_WSREMS__Channel__c == 'Portal' && acc.US_WSREMS__Status__c == 'Certified'){
                    duplicateMessage ='An account with this information already exists. Please log in or contact the Macitentan REMS at 1-888-572-2934 for assistance.';
                    break;
                }else if(acc.US_WSREMS__Channel__c != 'Portal' && acc.US_WSREMS__Status__c == 'Certified'){
                    duplicateMessage ='Please contact the Macitentan REMS at 1-888-572-2934 for login credentials.';
                    break;
                }else if(acc.US_WSREMS__Channel__c == 'Portal' && acc.US_WSREMS__Status__c == 'Disenrolled'){
                    duplicateMessage ='Your account is currently disenrolled.  Please contact the Macitentan REMS at 1-888-572-2934 for assistance.';
                    break;
                }else if(acc.US_WSREMS__Channel__c != 'Portal' && acc.US_WSREMS__Status__c == 'Disenrolled'){
                    duplicateMessage ='Please contact the Macitentan REMS at 1-888-572-2934 for assistance.';
                    break;
                }else if(acc.US_WSREMS__Channel__c != 'Portal' && acc.US_WSREMS__Status__c == 'Pending'){
                    duplicateMessage ='An account with this information already exists. Please contact the Macitentan REMS at 1-888-572-2934 for assistance.';
                    break;
                }else{
                    duplicateMessage = 'NotFound';
                }
            }
        }else{
               duplicateMessage = 'NotFound';
        }
        return duplicateMessage;
    }
    
    /***********************************************************************************************************************************
    MethodName : validatePharmacyNPIDupCheck
    Description : retiurn true/false based on user availablity.
    ************************************************************************************************************************************/
    @AuraEnabled
    public static boolean validatePharmacyNPIDupCheck(String npi, String recTypeDevName, String program){
        
        id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        boolean duplicateflag = false;
        if(npi != null) {
            List<Account> pharmacyAccList = [SELECT Id,Name FROM Account WHERE RecordTypeId =: PharmacyAccRecordTypeId AND US_WSREMS__NPI__c =: npi AND US_WSREMS__REMS_Program__r.Name =: program];
            if(!pharmacyAccList.isEmpty()){
                duplicateflag = true;
            }
        }
        return duplicateflag;
    }
    
    /***********************************************************************************************************************************
    MethodName : getProviderNPIDetails
    Description :
    ************************************************************************************************************************************/
    @AuraEnabled
    Public Static SYN_VeevaAPI_Search.prescriberInfoPrepopWrap getProviderNPIDetails(String providerNPI){
        
       SYN_VeevaAPI_Search.prescriberInfoPrepopWrap PresInfo =  SYN_VeevaAPI_Search.NPIreturnValue(providerNPI); 
       return PresInfo;
    }
    
    /***********************************************************************************************************************************
    MethodName : getPharmacyNPIDetails
    Description :
    ************************************************************************************************************************************/
    @AuraEnabled
    Public Static SYN_VeevaAPI_Search.pharmacyInfoPrepopWrap getPharmacyNPIDetails(String providerNPI){
        SYN_VeevaAPI_Search.pharmacyInfoPrepopWrap PharmaInfo = SYN_VeevaAPI_Search.PharmaNPIreturnValue(providerNPI);
        return PharmaInfo;
    } 
        
    /***********************************************************************************************************************************
    MethodName : createCommunityUser
    Description :
    ************************************************************************************************************************************/
    @AuraEnabled
    Public static string createCommunityUser(Id ContactId, Id ProfileId, String role,String pwd){
        return createCommunityUserWith2FA(ContactId,ProfileId,role,pwd,null); 
    }
    
    Public static string createCommunityUserWith2FA(Id ContactId, Id ProfileId, String role,String pwd,String twoFASelection){
       List<User> communityuserlist= New List<User>();
       id userId = null;
       User communityuser = New User();
       Contact con = [SELECT id,FirstName, LastName, Account.Email_address__c,Account.US_WSREMS__Email__c, AccountId, Account.US_WSREMS__REMS_Program__c, Account.US_WSREMS__REMS_Program__r.Name, Account.US_WSREMS__REMS_Program__r.REMS_Project_Code__c FROM Contact WHERE Id =: ContactId LIMIT 1];
               String email;
               if(con.Account.Email_address__c != null){
                   email = con.Account.Email_address__c;
               }else if(con.Account.US_WSREMS__Email__c != null){
                   email = con.Account.US_WSREMS__Email__c;
               }
               //Create Community User
                        String customalias;
                        if(con.Lastname.length()<9){
                            customalias= con.Lastname;   
                        }
                        else{
                            customalias= con.Lastname.left(7).substring(0, 7); 
                        } 
                        String nickname;
                        
                        if(con.Lastname.length()<40){
                            nickname= con.Lastname;   
                        }else{
                            nickname= con.Lastname.left(39).substring(0, 39); 
                        }
                        
                        communityuser.UserName = email+'.'+con.Account.US_WSREMS__REMS_Program__r.REMS_Project_Code__c+role.substring(0,2);
                        communityuser.FirstName = con.Firstname;
                        communityuser.LastName = con.Lastname;                    
                        communityuser.alias = customalias.trim();
                        communityuser.email = email;
                        communityuser.CommunityNickName = nickname+System.now().millisecond();
                        communityuser.ProfileID = ProfileId;
                        communityuser.TimeZoneSidKey = 'America/Mexico_City'; 
                        communityuser.LocaleSidKey = 'en_US';
                        communityuser.EmailEncodingKey = 'UTF-8'; 
                        communityuser.LanguageLocaleKey = 'en_US';
                        communityuser.isActive = true;
                        communityuser.ContactId = con.id;
                        communityuser.Program__c = con.Account.US_WSREMS__REMS_Program__r.Name;
                        communityuser.Role__c = role;
                        communityuser.Two_Factor_Authentication_Selection__c = twoFASelection;
        
            try{
                userId = Site.createExternalUser(communityuser, con.AccountId, pwd.trim());
                if(userId != null){
                    ManagerAccountSharingPermission(userId,con.AccountId);
                    ManagerProgramSharingPermission(userId,con.Account.US_WSREMS__REMS_Program__c);
                }
            }catch (exception e){
                System.debug('Error---'+e.getMessage());
            }
      return userId;
    }
    
   /***********************************************************************************************************************************
    MethodName : generatePortalVerificationCode
    Description :
    ************************************************************************************************************************************/
    Public static void generatePortalVerificationCode(id userId){
        //Generate Verification Code
        Integer rand = Math.round(Math.random() * 100000);
        String code = String.valueOf(rand);
          User u = new User (Id =userId);
          u.Verification_Code__c = code;
          try{
          update u;
          }catch (exception e){
           system.debug('---Error Log---'+e.getMessage());
          }
    }
    
    /***********************************************************************************************************************************
    MethodName : validateAccountInfo
    Description : 
    ************************************************************************************************************************************/
    Public static id validateAccountInfo(String email, string npi,string program, string lname){
        Id AccountID;
        List<Account> accountList = [SELECT Id FROM Account WHERE ((US_WSREMS__NPI__c != null AND US_WSREMS__NPI__c =: npi) OR (Email_address__c != null AND Email_address__c =: email) OR (LastName =: lname)) AND Program_Name__c =: program AND (US_WSREMS__Status__c  = 'Initiated' OR US_WSREMS__Status__c ='Canceled') AND US_WSREMS__Channel__c != 'Portal' AND RecordType.Developername = 'Prescriber' LIMIT 1];
        if(!accountList.isEmpty()){
            AccountID = accountList[0].Id;
        }
        return AccountID;
    }
    
    /***********************************************************************************************************************************
    MethodName : getCurrentUserAccountInfo
    Description : Prescriber / OutPatient Pharmacy Agreement Screen(Portal Screen) - Returning Curent user account info to display data on 
    Agreement Page
    ************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Account getCurrentUserAccountInfo() {
        User u = [SELECT Id, Name,Email, UserType, Role__c, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId() AND ContactId != null LIMIT 1];         
         return [SELECT Id, Name, US_WSREMS__NPI__c FROM Account WHERE Id =:  u.Contact.AccountId];
        
    }
    
    /***********************************************************************************************************************************
    MethodName : reSendConfimarionEmail
    Description : Prescriber Enrollment/ OutPatient Pharmacy Enrollment(Portal Screen) - Update Emaol Resent count field on user record, 
    once it is updated , we are sending email to poirtal user
    ************************************************************************************************************************************/
    @AuraEnabled
    Public static boolean reSendConfimarionEmail(id userId){
          boolean confirmEmailFlag;
          User u = [SELECT Id, Email_Reset_Count__c FROM User Where id =: userId];
          if(u.Email_Reset_Count__c < 2){
              u.Email_Reset_Count__c= u.Email_Reset_Count__c+1;
    
              try{
              update u;
              confirmEmailFlag = true;
              }catch (exception e){
               system.debug('---Error Log---'+e.getMessage());
              }
          }else{
              confirmEmailFlag = false;
          }
         return confirmEmailFlag;
    }
    
    /***********************************************************************************************************************************
    MethodName : getStates
    Description : Prescriber Enrollment(Portal Screen) - get Case State Picklist Values
    ************************************************************************************************************************************/
    @AuraEnabled //get Case State Picklist Values
    public static Map<String, String> getStates(){
        Map<String, String> stateValues = new Map<String, String>();
        //get Case State Field Describe
        Schema.DescribeFieldResult fieldResult = Case.State_Secondary_Office__c.getDescribe();
        //get Case State Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            stateValues.put(p.getValue(), p.getLabel());
        }        
        return stateValues;        
    }
    
    /***********************************************************************************************************************************
    MethodName : createPrimaryOfficeAccount
    Description : Prescriber Enrollment(Portal Screen) - Create Prescriber instituation Account and Case
    ************************************************************************************************************************************/
    Public static id createPrimaryOfficeAccount(Case prescriberAccount){
        prescriberAccount.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution_Account').getRecordTypeId();
        try{
            insert prescriberAccount;
            REMSPagelayoutConfigComponentController.AccountCreationDetails  primaryInstAccount= REMSPagelayoutConfigComponentController.createAccountOnCaseCreation(prescriberAccount.id);
            return primaryInstAccount.AccountId;
            
        }catch(exception e){
            system.debug('---Error----'+e.getMessage());
            return null;
        }        
    }
    
    /***********************************************************************************************************************************
    MethodName : getPharmacyTitle
    Description : OutPatient Pharmacy Enrollment - get Case Title Picklist Values
    ************************************************************************************************************************************/
    @AuraEnabled 
    public static Map<String, String> getPharmacyTitle(){
        Map<String, String> titleValues = new Map<String, String>();
         //get Case title Field Describe
        Schema.DescribeFieldResult fieldResult = Case.Title__c.getDescribe();
        //get Case State Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            titleValues.put(p.getValue(), p.getLabel());
        }        
        return titleValues;        
    }
    
    
    /***********************************************************************************************************************************
    MethodName : getPharmacyCredentails
    Description : OutPatient Pharmacy Enrollment - get Case Credentials Picklist Values
    ***********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> getPharmacyCredentails(){
         Map<String, String> credentailsValues = new Map<String, String>();
        //get Case Credentials Field Describe
        Schema.DescribeFieldResult fieldResult = Case.Credentials__c.getDescribe();
        //get Case State Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            credentailsValues.put(p.getValue(), p.getLabel());
        }        
        
        return credentailsValues ;        
    }
    
    
    /***********************************************************************************************************************************
    MethodName : createPharmacyPortalUserAccount
    Description : OutPatient Pharmacy Enrollment - When user click on next button on password screen, 
    create Pharmacuy participant account and portal user under the account
    Date:09/15/2024 changes added to resolve Duplicate record type issue from line 333 AND 342 by DILEEP G  
   
    ***********************************************************************************************************************************/
    @AuraEnabled()
    public static string createPharmacyPortalUserAccount(Case pharmacyObj, String profileId, String role, String password,String twoFASelection) {
        Map<String,Id> caserecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');

        Set<Id> sucessCaseIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Id sucessCaseId;
        Id portalUserId = null;
        Id contactId = null;
        List<Contact> contactListToInsert = new List<Contact>();
        String accountId;
        id recordTypeId = caserecordTypeMap.get('Pharmacy_Participant_Account');
        pharmacyObj.RecordTypeId = recordTypeId;
            
        if(!String.isEmpty(pharmacyObj.US_WSREMS__Phone__c)){
            pharmacyObj.US_WSREMS__Phone__c= pharmacyObj.US_WSREMS__Phone__c.replaceAll('[^0-9]','');
        }
        
        if(!String.isEmpty(pharmacyObj.US_WSREMS__Fax__c)){
            pharmacyObj.US_WSREMS__Fax__c= pharmacyObj.US_WSREMS__Fax__c.replaceAll('[^0-9]','');
        }
        
    
        try{
            insert pharmacyObj;
        }catch(exception e ){
            system.debug('----Error------'+e.getMessage());
        }
    
        
        if(pharmacyObj.Id != null){
             //object acc = REMSPagelayoutConfigComponentController.createAccountOnCaseCreation(cs.id);
             REMSPagelayoutConfigComponentController.AccountCreationDetails  acd= REMSPagelayoutConfigComponentController.createAccountOnCaseCreation(pharmacyObj.id);
             accountId = acd.AccountId;
        }
        
        Contact con = new Contact();
        if(accountId != null){
            Account acc = [SELECT id,FirstName,LastName,Email_address__c,US_WSREMS__REMS_Program__c,PersonContactId,OwnerId,owner.UserRoleid FROM Account WHERE Id = :accountId LIMIT 1];
                if(!string.isEmpty(acc.PersonContactId)){
                    contactId = acc.PersonContactId;
                }else{
                    con.AccountId = acc.Id;
                    con.FirstName = acc.FirstName;
                    con.LastName = acc.LastName;
                    con.Email = acc.Email_address__c;
                    insert con;
                    contactId = con.Id;
                }
                acc.Two_Factor_Authentication_Selection__c = twoFASelection;
                update acc;
        }
         
            
         if(contactId != null){
            portalUserId =  createCommunityUserWith2FA(contactId ,profileId,role,password,twoFASelection);
           
         }         
       return portalUserId;
    }
   
    
    /***********************************************************************************************************************************
    MethodName : ManagerAccountSharingPermission
    Description : Account Object - Provide Edit Access to Portal user
    *************************************************************************/
    Public static void ManagerAccountSharingPermission(string userId, Id AccountId){
                AccountShare provAcctShare = new AccountShare();
                provAcctShare.Accountid = AccountId;
                provAcctShare.UserOrGroupId = userId;
                provAcctShare.AccountAccessLevel = 'Edit';
                provAcctShare.OpportunityAccessLevel = 'Read';
                provAcctShare.CaseAccessLevel = 'Edit';
                provAcctShare.RowCause = 'Manual';
                try{
                    insert provAcctShare;
                }catch(exception e){
                    System.debug('--Error---'+e.getMessage());
                }
    }
    
    /***********************************************************************************************************************************
    MethodName : ManagerProgramSharingPermission
    Description : Rems Program Object - Provide Read Access to Portal user
    **********************************************************************************************************************************/    
    Public static void ManagerProgramSharingPermission(string userId, Id programId){
                US_WSREMS__REMS_Program__Share progShare= new US_WSREMS__REMS_Program__Share();
                progShare.UserOrGroupId = userId;
                progShare.ParentId = programId;
                progShare.AccessLevel  = 'Read';
                progShare.RowCause = 'Manual';
                try{
                    insert progShare;
                }catch(exception e){
                    System.debug('--Error---'+e.getMessage());
                }
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
    
    /***********************************************************************************************************************************
    MethodName : validatePatientDupCheck
    Description : return true/false based on patient account detail on enrollment
    ************************************************************************************************************************************/
    @AuraEnabled
    public static boolean validatePatientDupCheck(String fname, String lname, String zip, String program, Date dob){
        boolean duplicateflag = false;
        id PatientAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        List<Account> patientAccList= [SELECT Id,Name FROM Account
                                       WHERE Program_Name__c =: program AND RecordTypeId =: PatientAccRecordTypeId AND US_WSREMS__DOB__c =: dob
                                       AND ShippingPostalCode=: zip AND (( LastName =: lname) OR (FirstName =: fname AND LastName =: lname))];

            if(!patientAccList.isEmpty()){
                duplicateflag = true;
                
            }
        return duplicateflag;
    }
    
      /***********************************************************************************************************************************
    MethodName : getInpatientPharmacyTypePicklistValues
    Description : inpatient Pharmacy Enrollment(Portal Screen) - get Case Inpatient Pharmacy Type Picklist values
    ************************************************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> getInpatientPharmacyTypePicklistValues(){
         Map<String, String> inpatientPharmacyTypeValues = new Map<String, String>();
        //get Case Inpatient Pharmacy Type Field Describe
        Schema.DescribeFieldResult fieldResult = Case.Inpatient_Pharmacy_Type__c.getDescribe();
        //get Case IInpatient Pharmacy Type Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            inpatientPharmacyTypeValues.put(p.getValue(), p.getLabel());
        }        
        
        return inpatientPharmacyTypeValues;        
    }
    
    /***********************************************************************************************************************************
    MethodName : getPharmacistInfo
    Description :
    ************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Account getPharmacistInfo() {
        String usertype = '';
        Account acc;
        User u = [SELECT Id, Name,Email, UserType, Role__c, AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        
        if(u.AccountId != null){
            acc = [SELECT Id,FirstName,LastName,SYN_Signature__c, Title__c,US_WSREMS__REMS_Program__c,Program_Name__c,Other_Title__c,SYN_User_Type__c,US_WSREMS__Status__c,Date_Enrolled__c,SYN_Signature_Date__c FROM Account WHERE Id =: u.AccountId LIMIT 1];
        }
        return acc;
    }
    
    /***********************************************************************************************************************************
    MethodName : checkPrescriberAccount
    Description : before creating Prescriber Account, check the Account is present or not 
    ************************************************************************************************************************************/
    @AuraEnabled()
    public static string checkPrescriberAccount(Case prescriberObj) {
        String accountId;
        if(prescriberObj.US_WSREMS__NPI__c != null){
            accountId = validateAccountInfo(prescriberObj.Email_address__c,prescriberObj.US_WSREMS__NPI__c,prescriberObj.US_WSREMS__Program_Picklist__c,prescriberObj.US_WSREMS__Last_Name__c);
        }
        return accountId;
    }
    
    /***********************************************************************************************************************************
    MethodName : insertPrescriberAccount
    Description : in this method, we are creating Prescriber Case and Account by using Precriber Info and return precriber AccountId
    ************************************************************************************************************************************/
    @AuraEnabled()
    public static String insertPrescriberAccount(Case prescriberObj,Map<String,String> primaryAccount,Case primaryCase ,Map<String,String> secondaryAccount,Case secondaryCaseRecord ){
        String accountId;
         String primaryAccountId = null;
        String secondaryAccountId = null;
        List<case> caseList = new List<case>();
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        if(primaryAccount.containsKey('Id') && String.isNotBlank(primaryAccount.get('Id')) && primaryAccount.get('Id') != null && primaryAccount.get('Id') != '') {
            primaryAccountId = primaryAccount.get('Id');
        } else if(primaryAccount != null &&  primaryCase != null ) {
            OfficeContactCaseWrapper wrapperRecord = MaciPortalCustomController.createOfficeContact(primaryAccount, primaryCase);
            primaryAccountId = wrapperRecord.accountId;
              if( wrapperRecord != NULL  && wrapperRecord.caseRecord != NULL && primaryAccountId != null ){
            caseList.add(wrapperRecord.caseRecord);
        }
        }
        if(secondaryAccount.containsKey('Id') && String.isNotBlank(secondaryAccount.get('Id')) && secondaryAccount.get('Id') != null && secondaryAccount.get('Id') != '') {
            secondaryAccountId = secondaryAccount.get('Id');
        } else if(secondaryAccount != null &&  secondaryCaseRecord != null) {
            OfficeContactCaseWrapper wrapperRecord = new OfficeContactCaseWrapper();
            wrapperRecord = MaciPortalCustomController.createOfficeContact(secondaryAccount, secondaryCaseRecord);
            secondaryAccountId = wrapperRecord.accountId;
               if(wrapperRecord != NULL  && wrapperRecord.caseRecord != NULL && secondaryAccountId != null){
             wrapperRecord.caseRecord.Fax_Secondary_Office__c = null;
            caseList.add(wrapperRecord.caseRecord);
        }
        }
         id recordTypeId = caseRecordTypeMap .get('Prescriber_Person_Account');


        prescriberObj.RecordTypeId = recordTypeId;
        if(!String.isEmpty(secondaryAccountId) ) {
            prescriberObj.US_WSREMS__Secondary_Office_Contact__c  = secondaryAccountId;
        }
        if(!String.isEmpty(primaryAccountId)) {
            prescriberObj.US_WSREMS__Office_Contact__c  = primaryAccountId;
        }
        if(!String.isEmpty(prescriberObj.US_WSREMS__REMS_Alternate_Phone__c)){
            prescriberObj.US_WSREMS__REMS_Alternate_Phone__c = prescriberObj.US_WSREMS__REMS_Alternate_Phone__c.replaceAll('[^0-9]','');
        }
        
        
        if(!String.isEmpty(prescriberObj.US_WSREMS__Phone__c)){
             prescriberObj.US_WSREMS__Phone__c = prescriberObj.US_WSREMS__Phone__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(prescriberObj.US_WSREMS__REMS_Office_Contact_Phone__c)){
            prescriberObj.US_WSREMS__REMS_Office_Contact_Phone__c = prescriberObj.US_WSREMS__REMS_Office_Contact_Phone__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(prescriberObj.US_WSREMS__Fax__c)){
            prescriberObj.US_WSREMS__Fax__c = prescriberObj.US_WSREMS__Fax__c.replaceAll('[^0-9]','');
        }
        prescriberObj.US_WSREMS__Email__c = primaryCase.Email_address__c;
        if(!String.isEmpty(prescriberObj.Phone_Secondary_Office__c)){
            prescriberObj.Phone_Secondary_Office__c = prescriberObj.Phone_Secondary_Office__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(prescriberObj.office_contact_phone_Secondary_Office__c)){
            prescriberObj.office_contact_phone_Secondary_Office__c = prescriberObj.office_contact_phone_Secondary_Office__c.replaceAll('[^0-9]','');
        }
        if(!String.isEmpty(prescriberObj.Fax_Secondary_Office__c)){
            prescriberObj.Fax_Secondary_Office__c = prescriberObj.Fax_Secondary_Office__c.replaceAll('[^0-9]','');
        }
        
       // try{
        if(prescriberObj != NULL){
             	caseList.add(prescriberObj);   
        }
            
        SYN_AccountTriggerHandler.Stop_Account_Service_triggerCreation = false;
        try{
            if(!caseList.isEmpty()) {          
            insert caseList;
            }
        }catch(exception e ){
            system.debug('----Error------'+e.getMessage());
        }
        String casePrecriberId = null;
        for(case record : caseList) {
            if(record.recordTypeId == recordTypeId) {
                casePrecriberId = record.Id;
            }
        } 
        
        if(casePrecriberId != null){
               REMSPagelayoutConfigComponentController.AccountCreationDetails  acd= REMSPagelayoutConfigComponentController.createAccountOnCaseCreation(casePrecriberId);
         accountId = acd.AccountId;
        }
        
        return accountId;
    }
    /***********************************************************************************************************************************
    MethodName : CreatingOfficePrimaryContact
    Description : by using the account Id, we are getting contact Id and we are creating a contact when account is Business account
    ************************************************************************************************************************************/
    @AuraEnabled
    public static OfficeContactCaseWrapper createOfficeContact(Map<String,String> accountRecord, Case caseRecord){
        SYN_AccountTriggerHandler.Stop_Account_Service_triggerCreation = true;
        Map<String,Id> serviceRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c');
        Map<String,Id> accountRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account');
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        OfficeContactCaseWrapper wrapper = new OfficeContactCaseWrapper();
        wrapper.caseRecord = new Case();
        wrapper.accountId = null;
US_WSREMS__REMS_Program__c program = [SELECT Id FROM US_WSREMS__REMS_Program__c WHERE Name = 'Macitentan REMS' LIMIT 1];
        if(accountRecord.size() >0) {
            Id recordTypeAccountId = accountRecordTypeMap.get('Office_Contact');

            Account accRecord = new Account();
                accRecord.RecordTypeId = recordTypeAccountId;
                accRecord.FirstName = accountRecord.containsKey('firstName') ? accountRecord.get('firstName') : '';
                accRecord.LastName = accountRecord.containsKey('lastName') ? accountRecord.get('lastName') : '';
                accRecord.US_WSREMS__Email__c = accountRecord.containsKey('confirmEmail') ? accountRecord.get('confirmEmail') : '';
                accRecord.US_WSREMS__Channel__c = 'Portal';
                accRecord.Phone = caseRecord.Phone_Secondary_Office__c;
                accRecord.US_WSREMS__REMS_Program__c = program.Id;
                accRecord.US_WSREMS__Status__c = 'Initiated';
                accRecord.US_WSREMS__Role__c = 'Office Contact';
                accRecord.SYN_User_Type__c = 'Office Contact';
                if(accRecord.FirstName != '' && accRecord.LastName != '' && accRecord.US_WSREMS__Email__c != '') {
                    try {
                        insert accRecord;
                        wrapper.accountId = accRecord.Id;
                    } catch(exception e ){
                        system.debug('----Error Account ------'+e.getMessage());
                    }
                    if(wrapper.accountId != null) {
                        Id remsServiceRecordTypeId = serviceRecordTypeMap.get('Participant_Account_Creation');
                        US_WSREMS__REMS_Service_Summary__c remsService  = new US_WSREMS__REMS_Service_Summary__c();
                        remsService.RecordTypeId = remsServiceRecordTypeId;
                        remsService.US_WSREMS__REMSProgram__c = program.Id;
                        remsService.US_WSREMS__Requestor_Type__c = 'Office Contact';
                        remsService.US_WSREMS__Participant__c = wrapper.accountId;
                        remsService.US_WSREMS__Registration_Status__c = 'Pending';
                        remsService.US_WSREMS__Path_Stage_Name__c ='Closed';
                        remsService.US_WSREMS__Status__c = 'Closed';
                        remsService.US_WSREMS__Service_Outcome__c = 'Successful';
                        try {
                            insert remsService;
                        } catch(exception e ){
                            system.debug('----Error remsService ------'+e.getMessage());
                        }   

                         Id recordTypeId = caseRecordTypeMap.get('Office_Contact');

                        caseRecord.RecordTypeId = recordTypeId;
                        try {
                            caseRecord.US_WSREMS__First_Name__c = accountRecord.containsKey('firstName') ? accountRecord.get('firstName') : '';
                            caseRecord.US_WSREMS__Last_Name__c = accountRecord.containsKey('lastName') ? accountRecord.get('lastName') : '';
                            caseRecord.US_WSREMS__Email__c = accountRecord.containsKey('confirmEmail') ? accountRecord.get('confirmEmail') : '';
                            caseRecord.US_WSREMS__Participant__c = wrapper.accountId;
                            caseRecord.US_WSREMS__REMS_Service_Summary__c= remsService.Id;
                            caseRecord.Status = 'Complete';
                            caseRecord.US_WSREMS__REMS_Program__c = program.Id;
                            caseRecord.US_WSREMS__Channel__c  = 'Portal';
                            caseRecord.US_WSREMS__Program_Picklist__c = 'Macitentan REMS';
                            caseRecord.US_WSREMS__Outcome__c = 'Complete';
                            US_WSREMS.REMSAvoidRecursiveCls.stop_accountUpdate=true;
                            wrapper.caseRecord = caseRecord;
                        } catch(exception e ){
                            system.debug('----Error Case 2 ------'+e.getMessage());
                        }
                    }
                }
            return wrapper;
        }
        return null;
    }
    public class OfficeContactCaseWrapper {
        @AuraEnabled public Case caseRecord                            {get; set;}
        @AuraEnabled public String accountId                           {get; set;}
    }

    
    /***********************************************************************************************************************************
    MethodName : getContactId
    Description : by using the account Id, we are getting contact Id and we are creating a contact when account is Business account
    ************************************************************************************************************************************/
    @AuraEnabled
    public static String createPrescriberPortalUser(String accountId, Case prescriberObj, String profileId, String role, String password, String twoFASelection){
        Id contactId = null;
        Id portalUserId = null;

        if(accountId != null){
            Contact con = new Contact();
            Account acc = [SELECT id,FirstName,LastName,Email_address__c,US_WSREMS__REMS_Program__c,PersonContactId,OwnerId,owner.UserRoleid,US_WSREMS__Status__c FROM Account WHERE Id = :accountId LIMIT 1];
                 if(prescriberObj!= null && (acc.Email_address__c != prescriberObj.Email_address__c || acc.US_WSREMS__Status__c != 'Certified')){
                     Account pacc = new Account(Id=acc.Id);
                     pacc.Two_Factor_Authentication_Selection__c = twoFASelection;
                     if(acc.Email_address__c != prescriberObj.Email_address__c)
                     pacc.Email_address__c = prescriberObj.Email_address__c;
                     try{
                        update pacc;
                     }catch (exception e){
                        System.debug('--Error---'+e.getMessage());
                     }
                 } else if(prescriberObj == null && acc != null){
                        Site currentSiteRec = [SELECT id,Name,GuestRecordDefaultOwnerId from Site WHERE id=:Site.getSiteId()];
                    Account pacc = new Account(Id=acc.Id);
                    pacc.Two_Factor_Authentication_Selection__c = twoFASelection;
                        pacc.OwnerId = currentSiteRec.GuestRecordDefaultOwnerId;
                    
                    try{
                       update pacc;
                    }catch (exception e){
                       System.debug('--Error---'+e.getMessage());
                    }
                 }    
                        
                if(!string.isEmpty(acc.PersonContactId)){
                    //contactIds.add(acc.PersonContactId);
                    contactId = acc.PersonContactId;
                }else{
                    con.AccountId = acc.Id;
                    con.FirstName = acc.FirstName;
                    con.LastName = acc.LastName;
                    if(prescriberObj!= null){
                        con.Email = prescriberObj.Email_address__c;
                    }
                    insert con;
                    contactId = con.Id;
                }
        }
        
        if(contactId != null){
            portalUserId =  createCommunityUserWith2FA(contactId ,profileId,role,password,twoFASelection);
         }  
         
        return portalUserId;
    }
        
     /***********************************************************************************************************************************
    MethodName : getPharmacistInfo
    Description :
    ************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Account getCurrentAuthRepInfo(string recordId) { 
       Account  acc = [SELECT Id,US_WSREMS__Email__c,FirstName,LastName,Name,SYN_Signature__c, Title__c,US_WSREMS__REMS_Program__c,Program_Name__c,Other_Title__c,SYN_User_Type__c,US_WSREMS__Status__c,Date_Enrolled__c,SYN_Signature_Date__c,IsCustomerPortal,personcontactId  FROM Account WHERE Id =: recordId LIMIT 1];
        return acc;
    }
    
     /***********************************************************************************************************************************
    MethodName : updatePharmacyParticipantStatus
    Description :
    ************************************************************************************************************************************/
    @AuraEnabled
    public static void updatePharmacyParticipantStatus(string recordId) { 
         Account acc = new Account(Id=recordId);
         acc.US_WSREMS__Status__c = 'Active';
         try{
             update acc;
         }catch (Exception e){
             system.debug('---Error---'+e.getMessage());
         }
    }
    
    
       /***********************************************************************************************************************************
    MethodName : updatePharmacyParticipantStatus
    Description :
    ************************************************************************************************************************************/
    @AuraEnabled
    public static US_WSREMS__Affiliation__c checkAffiliationStatus(string recordId) { 
       US_WSREMS__Affiliation__c pAffiliation = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy_User__r.Name,US_WSREMS__Pharmacy_User__r.US_WSREMS__Status__c,US_WSREMS__Pharmacy_User__r.IsCustomerPortal,         
                                                                                                                         US_WSREMS__Pharmacy_User__r.Date_Enrolled__c,US_WSREMS__Pharmacy_User__r.SYN_User_Type__c,US_WSREMS__Pharmacy_User__r.US_WSREMS__Email__c,
                                                                                                                         Status__c,US_WSREMS__UserType__c,US_WSREMS__Start_Date__c,AR_Category__c,
                                                                                                                         US_WSREMS__Pharmacy__r.Pharmacy_Type__c
                                                                                                                         FROM US_WSREMS__Affiliation__c WHERE Id =: recordId];
      if(pAffiliation.US_WSREMS__Pharmacy_User__r.IsCustomerPortal == true && pAffiliation.Status__c == 'Pending'){
          pAffiliation.Status__c = 'Active';
          pAffiliation.US_WSREMS__Start_Date__c = Date.Today();
          try{
              update pAffiliation;
              SYN_SwitchPharmacyController.updateDefaultPharmacy(recordId);
          }catch(exception e){
              system.debug('Error---'+e.getmessage());
          }
      }else if(pAffiliation.US_WSREMS__Pharmacy_User__r.IsCustomerPortal == true && pAffiliation.Status__c == 'Active'){
          SYN_SwitchPharmacyController.updateDefaultPharmacy(recordId);
      }
       return pAffiliation;                                                                                                              
    }
    
    /***********************************************************************************************************************************
    MethodName : checkPrescriberAccountStatus
    Description :
    ************************************************************************************************************************************/
    @AuraEnabled
    public static Account checkPrescriberAccountStatus(string recordId) { 
       Account pAccount= [SELECT Id,US_WSREMS__Status__c,RecordType.DeveloperName,US_WSREMS__Email__c,IsCustomerPortal,Email_address__c,Two_Factor_Authentication_Selection__c FROM Account WHERE Id =: recordId];
       return pAccount;                                                                                                              
    }
    
    
    /***********************************************************************************************************************************
    MethodName : CheckDuplicateOfficeContactAccount

    Description : 
    ************************************************************************************************************************************/
    @AuraEnabled
    public static OfficeContactWrapper validateOfficeContactDupChecker(String email, String role, String program, String lname,String fname ,String phone) {
     Map<String,Id> accountRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account');        
    OfficeContactWrapper wrapper = new OfficeContactWrapper();
    wrapper.duplicateMessage = '';
    wrapper.officeContact = new Account();
      Id ocRcTypeID = accountRecordTypeMap.get('Office_Contact');
    List<Account> officeContactList = [SELECT Id,LastName,US_WSREMS__Email__c, US_WSREMS__Channel__c, US_WSREMS__Status__c, Email_address__c, Name
                                       FROM Account WHERE Program_Name__c = :program
                                       AND RecordTypeId = :ocRcTypeID
                                       AND (US_WSREMS__Email__c = :email OR LastName = :lname)];
    
    Boolean emailFound = false;
    Boolean lastNameAndEmailFound = false;
     if (!officeContactList.isEmpty()) {
        for (Account acc : officeContactList) {
             if (acc.US_WSREMS__Email__c == email && acc.LastName == lname) {
                lastNameAndEmailFound = true;
                wrapper.officeContact = acc;
                 break;
            } else if (acc.US_WSREMS__Email__c == email) {
                  emailFound = true;
            }
        }
        if (lastNameAndEmailFound) {
            wrapper.duplicateMessage = 'LastNameAndEmailFound';
        } else if (emailFound) {
            wrapper.duplicateMessage = 'EmailFound';
        } else {
            wrapper.duplicateMessage = 'NotFound';
        }
    } else {
        wrapper.duplicateMessage = 'NotFound';
    }
    
    return wrapper;
}
    public class OfficeContactWrapper {
        @AuraEnabled public Account officeContact                               {get; set;}
        @AuraEnabled public String duplicateMessage                             {get; set;}
    }
    
}