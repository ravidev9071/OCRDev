/**
 * @description       : Apex class used for the portal login pages.
 * @author            : Surekha
 * @group             : 
 * @last modified on  : 20-11-2024
 * @last modified by  : Utthirakumar
**/
global without sharing class REMSDigitalSiteLightningLoginForm {

    /*
    *********************************************************
    @Method Name    : login
    @author         : Surekha
    @description    : generic method is used to login the portal user with the credentials from the community site.
    @param          : username - site user's username
                      password - site user's password
                      startUrl - url to redirect after successful login
                      programName - program name 
    @return         : Error message for the failure or Null for the success
    ********************************************************
    */
    @AuraEnabled
    public static String login(String username, String password, String startUrl,String programName) {
        try{
            list<User> userList = [SELECT id,username FROM User WHERE email=:username AND US_WSREMS__REMS_Program__c=: programName];
            if(userList.isEmpty()) {
                string returnMessage = System.label.User_Not_Found_Portal;
                return returnMessage+programName;   
            }
            ApexPages.PageReference lgn = Site.login(userList[0].username, password, startUrl);
            aura.redirect(lgn);
            return null;
        }catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            return ex.getMessage();            
        }
    }
    
    /*
    *********************************************************
    @Method Name    : loginXiaflex
    @author         : Dilbag
    @description    : method is used to login the Xiaflex portal user with the credentials from the community site.
    @param          : username - site user's username
                      password - site user's password
                      startUrl - url to redirect after successful login
                      programName - program name 
    @return         : Error message for the failure or Null for the success
    ********************************************************
    */
    @AuraEnabled
    public static String loginXiaflex(String username, String password, String startUrl,String programName,String persona) {
        try{
            string Username1;
            list<User> userList = [SELECT id,username,accountId, Account.RecordType.DeveloperName FROM User WHERE email=:username AND US_WSREMS__REMS_Program__c=:programName];
            if(userList.isEmpty()) {
                return 'User is not registered under the program : '+programName;   
            }else{
                for(user pUser: userList){
                    // for REMS
                    if(persona == 'PR' && pUser.Account.RecordType.DeveloperName == SYN_Utilitycls.Prescriber ){
                       boolean checkEnroll = checkEnrollment(pUser.accountId);
                        if(checkEnroll){
                         startUrl = '/s/hcp-manage-hcs';    
                        }else{
                          startUrl = '/s/review-material';    
                        }
                        ApexPages.PageReference lgn = Site.login(pUser.username, password, startUrl);
                        aura.redirect(lgn);                        
                    }else if(persona == 'Pr' && pUser.Account.RecordType.DeveloperName != SYN_Utilitycls.Prescriber ){
                        return 'No Prescriber with this Email is registered under the program : '+programName;
                    }
                    if(persona == 'AR' && pUser.Account.RecordType.DeveloperName == SYN_Utilitycls.ACC_RCTY_Pharmacy_Participant ){
                        startUrl = '/s/manage-hcs';
                        ApexPages.PageReference lgn = Site.login(pUser.username, password, startUrl);
                        aura.redirect(lgn);                        
                    }else if(persona == 'AR' && pUser.Account.RecordType.DeveloperName != SYN_Utilitycls.ACC_RCTY_Pharmacy_Participant ){
                        return 'No Authorized Repersentative with this Email is registered under the program : '+programName;
                   }
                    // for MDP
                    if(persona == 'PRMDP' && pUser.Account.RecordType.DeveloperName == SYN_Utilitycls.Prescriber ){
                        startUrl = '/s/hcp-managehcs';    
                        ApexPages.PageReference lgn = Site.login(pUser.username, password, startUrl);
                        aura.redirect(lgn);                        
                    }else if(persona == 'PRMDP' && pUser.Account.RecordType.DeveloperName != SYN_Utilitycls.Prescriber ){
                        return 'No Prescriber with this Email is registered under the program : '+programName;
                    }
                    if(persona == 'ARMDP' && pUser.Account.RecordType.DeveloperName == SYN_Utilitycls.ACC_RCTY_Pharmacy_Participant ){
                        startUrl = '/s/manage-hcs';
                        ApexPages.PageReference lgn = Site.login(pUser.username, password, startUrl);
                        aura.redirect(lgn);                        
                    }else if(persona == 'ARMDP' && pUser.Account.RecordType.DeveloperName != SYN_Utilitycls.ACC_RCTY_Pharmacy_Participant ){
                        return 'No Authorized Repersentative with this Email is registered under the program : '+programName;
                   } 
                }
            }
           
            return null;
        }catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            return ex.getMessage();            
        }
    }
    
    /*
    *********************************************************
    @Method Name    : checkEnrollment
    @author         : Dilbag
    @description    : method is used to check if the prescriber stakeholder is enrolled or not.
    @param          : accountId - prescriber's Id
    @return         : true if the prescriber has enrollement otherwise false
    ********************************************************
    */
    @AuraEnabled 
    public static boolean checkEnrollment(id accountID){
        List<case> checkEnrollment = [SELECT id FROM case WHERE recordtype.developername =: SYN_Utilitycls.Prescriber_enrollRCTypeDev AND US_WSREMS__Participant__c =: accountID ];
        if(checkEnrollment.size() > 0){
                    return true;
        }
        else return false;
    }

    /*
    *********************************************************
    @Method Name    : loginAveed
    @author         : Mateen
    @description    : method is used to login the AVEED portal user with the credentials from the community site.
    @param          : username - site user's username
                      password - site user's password
                      startUrl - url to redirect after successful login
                      programName - program name 
    @return         : Error message for the failure or Null for the success
    ********************************************************
    */
    @AuraEnabled
    public static String loginAveed(String username, String password, String startUrl,String programName,String persona) {
        try{
            if(username!= '' && password!= '' && persona!= '')
            {    
                String userRole = '';
                if(persona == 'PR'){
                    userRole = SYN_Utilitycls.Prescriber;
                }else{
                    userRole = 'Pharmacy Participant';
                }
                list<User> userList = [SELECT Id, username, Account.RecordType.DeveloperName FROM User WHERE email=:username AND US_WSREMS__REMS_Program__c=:programName AND Role__c =: userRole];
                if(userList.isEmpty()) {
                    return 'User is not registered under AVEED REMS';   
                }else{
                    for(user pUser: userList){
                        if(persona == 'PR' && pUser.Account.RecordType.DeveloperName== SYN_Utilitycls.Prescriber ){
                            ApexPages.PageReference lgn = Site.login(pUser.username, password, startUrl);
                            aura.redirect(lgn);
                            return null;                        
                        }
                        else if(persona == 'PR' && (pUser.Account.RecordType.DeveloperName!= SYN_Utilitycls.Prescriber )){
                            return 'No Prescriber with this email is registered under AVEED REMS';
                        }
                        if(persona == 'AR' && pUser.Account.RecordType.DeveloperName== SYN_Utilitycls.ACC_RCTY_Pharmacy_Participant ){
                            
                            ApexPages.PageReference lgn = Site.login(pUser.username, password, startUrl);
                            aura.redirect(lgn);
                            return null;                          
                        }else if(persona == 'AR' && (pUser.Account.RecordType.DeveloperName!= SYN_Utilitycls.ACC_RCTY_Pharmacy_Participant )){
                            return 'No Authorized Repersentative with this email is registered under AVEED REMS';
                        }
                    }
                }
                return null;
            }
            else{
                return 'Please fill all details to login';
            }
        }
        
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            return ex.getMessage();            
        }
    }
    
    /*
    *********************************************************
    @Method Name    : getIsUsernamePasswordEnabled
    @author         : Surekha
    @description    : method is used to check if UsernamePasswordEnabled or not.
    @param          : 
    @return         : true if it is configured otherwise false
    ********************************************************
    */
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    /*
    *********************************************************
    @Method Name    : getIsSelfRegistrationEnabled
    @author         : Surekha
    @description    : method is used to check if SelfRegistrationEnabled or not.
    @param          : 
    @return         : true if SelfRegistrationEnabled otherwise false
    ********************************************************
    */
    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    /*
    *********************************************************
    @Method Name    : getSelfRegistrationUrl
    @author         : Surekha
    @description    : method is used to get self registration URL.
    @param          : 
    @return         : URL for the self registration
    ********************************************************
    */
    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    /*
    *********************************************************
    @Method Name    : getForgotPasswordUrl
    @author         : Surekha
    @description    : method is used to get forgot password URL.
    @param          : 
    @return         : URL for the forgot password
    ********************************************************
    */
    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    /*
    *********************************************************
    @Method Name    : getAuthConfig
    @author         : Surekha
    @description    : method is used to get authconfiguration.
    @param          : 
    @return         : Auth.AuthConfiguration
    ********************************************************
    */
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    /*
    *********************************************************
    @Method Name    : setExperienceId
    @author         : Surekha
    @description    : method is used to set experience Id.
    @param          : 
    @return         : error message if failed otherwise null
    ********************************************************
    */
    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null; 
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            return ex.getMessage();            
        }
    }   
    
    /*
    *********************************************************
    @Method Name    : loginUser
    @author         : Aneesha Shaik
    @description    : method is used to login.
    @param          : username - site user's username
                      password - site user's password
                      startUrl - url to redirect after successful login
                      programName - program name 
    @return         : error message if failed otherwise null
    ********************************************************
    */
    @AuraEnabled
    public static String loginUser(String username, String password, String startUrl,String programName) {
                  
         try{
             
            list<User> userList = [SELECT id,username,AccountId FROM User WHERE email=:username AND US_WSREMS__REMS_Program__c=:programName];
           if(!userList.isEmpty()) {
            List<US_WSREMS__Affiliation__c> certifiedPharmacyAff = [
                    SELECT Id, US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy__r.US_WSREMS__Status__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__isActive__c
                    FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Pharmacy_User__c =:userList[0].AccountId 
                    AND US_WSREMS__Pharmacy__r.US_WSREMS__Status__c ='Certified' AND  US_WSREMS__isActive__c = true LIMIT 1];
            
            if(!certifiedPharmacyAff.isEmpty() ) {
                ApexPages.PageReference lgn = Site.login(userList[0].username, password, startUrl);
                aura.redirect(lgn);
                return null;
            } else {
                return 'User account no longer valid, please call the PiaSky Contact Center at 1-866-4My-Skyy (1-866-469-7599)';   
                
            }
            } else{              
                return 'User account not found, please re-enter the username/password or contact your Pharmacys Authorized Representative.';
        }
        }catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            return ex.getMessage();            
        }
    }
}