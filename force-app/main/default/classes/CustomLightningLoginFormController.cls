/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-06-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class CustomLightningLoginFormController {

    public CustomLightningLoginFormController() {
        
    }

   @AuraEnabled
    public static string verifyUserCredentials(String username, String password, String startUrl,String programName,String twoFAValue) {
            boolean isUserPresent = false;
            boolean allowLogin = false;
            String userAccountStatus ='';
            
            list<User> userList = [select Id,username,Verification_Code__c,Role__c, AccountId, Account.US_WSREMS__Status__c,Program__c,Account.SYN_User_Type__c,Account.AR_Category__c,Two_Factor_Authentication_Selection__c FROM User WHERE username =:username AND Program__c=:programName AND IsActive = true LIMIT 1];
            if(!userList.isEmpty()){
                String  userStatus= CheckValidUserCredentials(userList[0].username, password, startUrl, programName);
                if(userStatus == null){
                    if(userList[0].Role__c == 'Outpatient Pharmacy' && userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') && userList[0].Account.AR_Category__c == 'Primary'){
                         allowLogin = verifyUserAccountStatus(userList[0].Id);
                         if(allowLogin == true){
                             userAccountStatus = 'valid';
                         }else{
                             userAccountStatus = 'notvalid';
                         }
                    }else{
                         userAccountStatus = 'valid';
                    }
                    if(userAccountStatus == 'valid'){
                        if(userList[0].Two_Factor_Authentication_Selection__c == 'Opt-Out'){
                            userAccountStatus = 'Opt-Out';
                         } else if(userList[0].Two_Factor_Authentication_Selection__c == 'Opt-In'){
                            userAccountStatus = 'Opt-In';
                         } else if(twoFAValue == 'Opt-In' || twoFAValue == 'Opt-Out'){

                            case coiCase = createCOICase(userList[0],programName,twoFAValue);
                            userAccountStatus = twoFAValue;
                         }
                    }                   

                    if(userAccountStatus == 'Opt-In'){  
                        MaciPortalCustomController.generatePortalVerificationCode(userList[0].Id);
                    }
                }else{
                     userAccountStatus = 'notfound';
                } 
                
            }
        return userAccountStatus;
    }
    
    @AuraEnabled
    public static boolean validateTwoFactorAuthentication(String username, String programName, String vcode) {
        boolean isCodeValid = false;
            list<User> userList = [select id,username,Verification_Code__c FROM User WHERE username =:username AND Program__c=:programName AND Verification_Code__c =: vcode AND IsActive = true LIMIT 1];
            if(!userList.isEmpty()){
                isCodeValid = true;
            }
        return isCodeValid ;
    }

    
    public static String CheckValidUserCredentials(String username, String password, String startUrl,String programName) {
        try{            
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);            
            return null;           
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    public static String login(String username, String password, String startUrl,String programName) {
        try{            
            list<User> userList = [select id,username,Role__c,AccountId,Account.SYN_Signature__c,Account.Is_the_Certification_Page_Complete__c, Account.US_WSREMS__Status__c, Account.Pharmacy_Type__c, Account.SYN_User_Type__c,Account.AR_Category__c FROM User WHERE username =:username AND Program__c=:programName AND isActive = true];
            if(userList[0].Role__c == 'Prescriber' && userList[0].Account.SYN_Signature__c != 'Yes' ){
                startUrl = '/s/prescriber';
            }else if(userList[0].Role__c == 'Prescriber' && userList[0].Account.SYN_Signature__c == 'Yes'){
                startUrl = '/s/manage-patients';
            }else if(userList[0].Role__c == 'Outpatient Pharmacy' && userList[0].Account.Is_the_Certification_Page_Complete__c == false && userList[0].Account.US_WSREMS__Status__c != 'Active' && userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') && userList[0].Account.AR_Category__c == 'Primary'){
                startUrl = '/s/pharmacy';
            }else if(userList[0].Role__c == 'Outpatient Pharmacy' && userList[0].Account.Is_the_Certification_Page_Complete__c == false && userList[0].Account.US_WSREMS__Status__c == 'Active' && userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') && userList[0].Account.AR_Category__c == 'Primary'){
                startUrl = '/s/outpatientpharmacycompletecertification';
            }else if(userList[0].Role__c == 'Outpatient Pharmacy' && userList[0].Account.Is_the_Certification_Page_Complete__c == true){
                startUrl = '/s/pharmacy-manage-home';
            }else if(userList[0].Role__c == 'Outpatient Pharmacy' && (!userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') || userList[0].Account.SYN_User_Type__c.contains('Authorized Representative')) && userList[0].Account.AR_Category__c != 'Primary'){
                startUrl = '/s/pharmacy-manage-home';
            }else if(userList[0].Role__c == 'Inpatient Pharmacy' && userList[0].Account.US_WSREMS__Status__c != 'Active' && userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') && userList[0].Account.AR_Category__c == 'Primary'){
                startUrl = '/s/inpatientpharmacycompletecertification';
            }else if(userList[0].Role__c == 'Inpatient Pharmacy' && userList[0].Account.US_WSREMS__Status__c == 'Active' && userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') && userList[0].Account.AR_Category__c == 'Primary'){
                startUrl = '/s/inpatient-manage-pharmacy';
            }else if(userList[0].Role__c == 'Inpatient Pharmacy' && (!userList[0].Account.SYN_User_Type__c.contains('Authorized Representative') || userList[0].Account.SYN_User_Type__c.contains('Authorized Representative')) && userList[0].Account.AR_Category__c != 'Primary'){
                startUrl = '/s/inpatient-manage-pharmacy';
            }else if(userList[0].Role__c == 'Office Contact' && userList[0].Account.US_WSREMS__Status__c == 'Active'){
                startUrl = '/s/officecontacthome';
            }
            
            ApexPages.PageReference lgn = Site.login(userList[0].username, password, startUrl); 
            aura.redirect(lgn);            
            return null;          
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }
    
    public static boolean verifyUserAccountStatus(String UserId){
      boolean allowLogin = false;
      case pharmacyEnrollmentCase = SYN_PortalEnrollmentController.getCurrentUserPharmacyInfo(UserId);
      if(pharmacyEnrollmentCase != null){
          if(pharmacyEnrollmentCase.SYN_Pharmacy__r.US_WSREMS__Status__c =='Certified' && pharmacyEnrollmentCase.SYN_Authorized_Rep__r.US_WSREMS__Status__c == 'Active'){
             allowLogin = true;            
          }
      }else{
           allowLogin = true;
      }
      return  allowLogin; 
    }
    
     @AuraEnabled
    public static Map<String,String> getUserName(String username, String programName) {
         Map<String,String> userMap = new Map<String,String>();
         list<User> userList = [select Id,username,Role__c, AccountId, Program__c FROM User WHERE email=:username AND Program__c=:programName AND IsActive = true AND ContactId != null]; 
         if(!userList.isEmpty()){
             if(userList.size() >1){
                 for(User usr : userList){
                     userMap.put(usr.Role__c,usr.username);
                 }
             }else if(userList.size() == 1){
                 userMap.put(userList[0].Role__c,userList[0].username);
             }  
         } 
         return userMap;        
    }

    /***********************
     Date:09/15/2024 changes added to resolve Duplicate record type issue from line 177 to 182 by DILEEP G  
   ***********************/
    public static case createCOICase(user loginUser,String programName,String twoFAValue){

        Account accnt = getAccountInfo(loginUser.AccountId);
        Map<String,Id> caserecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
      
        Id PrescriberCOICaseRecTypeId =caserecordTypeMap.get('Prescriber_COI');
        Id PharmacyCOICaseRecTypeId = caserecordTypeMap.get('Pharmacy_COI');
        Id PharmacyParticipantCOICaseRecTypeId =caserecordTypeMap.get('Pharmacy_Participant_COI');

            List<US_WSREMS__REMS_Program__c> remsPrgm = [Select id,Name FROM US_WSREMS__REMS_Program__c WHERE Name =: programName];
            String remsServiceId = SYN_PortalEnrollmentController.createREMSService('Change_of_Information',accnt.Id,remsPrgm[0].Id,accnt.RecordType.Name);
            case coiCase = new case();
            Map<String,String> PrescriberInfoMap = new Map<String,String>();
            String sect = 'Prescriber'+';'+'US_WSREMS__Participant__c'+';'+'Macitentan REMS';
            PrescriberInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields( accnt.Id,'Case',PrescriberCOICaseRecTypeId ,sect);
            if(!PrescriberInfoMap.isEmpty() && PrescriberInfoMap != null){
                for(String fld : PrescriberInfoMap.keySet()){
                    if(PrescriberInfoMap.get(fld) != ' '){
                        coiCase.put(fld,PrescriberInfoMap.get(fld));
                    }
                }
            }

            coiCase.US_WSREMS__Program_Picklist__c = programName;
            coiCase.US_WSREMS__Channel__c=accnt.US_WSREMS__Channel__c;
            coiCase.US_WSREMS__REMS_Program__c = remsPrgm[0].Id;
            coiCase.US_WSREMS__REMS_Service_Summary__c = remsServiceId;
            coiCase.Status='Complete';
            coiCase.US_WSREMS__Participant__c = accnt.Id;
            coiCase.US_WSREMS__Outcome__c = 'Complete';
            if(loginUser.Role__c == 'Prescriber') {
                coiCase.RecordTypeId = PrescriberCOICaseRecTypeId;
            }else if(loginUser.Role__c == 'Inpatient Pharmacy' || loginUser.Role__c == 'Outpatient Pharmacy') {
                coiCase.RecordTypeId = PharmacyParticipantCOICaseRecTypeId;
            }
            coiCase.Two_Factor_Authentication_Selection__c = twoFAValue;system.debug('----coiCase----'+coiCase);
            try{
                insert coiCase;
                UpdateRemsService(remsServiceId);
            }catch(Exception e){
                system.debug('--Error---'+e.getMessage());
            }

            return coiCase;
    }
    
     /********************************************************************************************************************************************************
    Method Name     : UpdateRemsService
    Description     : Update REMS Service status closed
    ********************************************************************************************************************************************************** */    
    public static void UpdateRemsService(String recordId){

        US_WSREMS__REMS_Service_Summary__c remsService  = new US_WSREMS__REMS_Service_Summary__c(Id=recordId);
        remsService.US_WSREMS__Path_Stage_Name__c ='Closed';
        remsService.US_WSREMS__Service_Outcome__c = 'Successful';
        remsService.US_WSREMS__Status__c = 'Closed';
        remsService.US_WSREMS__Path_Complete__c= true;
        try{
            update remsService;
        }catch(Exception e){
            system.debug('--Error---'+e.getMessage());
        }
    }

    public static Account  getAccountInfo(Id accountId){
        return [Select Id,Phone,FirstName,LastName,MiddleName,US_WSREMS__Channel__c,SYN_Professional_Designation__c,SYN_Ext__c,US_WSREMS__Email__c,US_WSREMS__DEA__c,RecordType.Name,
                US_WSREMS__NPI__c,US_WSREMS__SLN__c,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,Fax,US_WSREMS__Preferred_Contact_Method__c From Account where Id =: accountId];
    }
   
}