/**************************************************************************
    * Name :   CustomLightningForgotPasswordController 
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  04/02/2023             Initial Version
    *********************************************************************************/

    Public without sharing class CustomLightningForgotPasswordController {

        public CustomLightningForgotPasswordController () {
    
        }
        
        @AuraEnabled
        public static Map<String,String> getUserName(String username, String programName) {
             Map<String,String> userMap = new Map<String,String>();
             list<User> userList = [select Id,username,Role__c, AccountId, Program__c FROM User WHERE email=:username AND Program__c=:programName AND IsActive = true]; 
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
        
         @AuraEnabled
        public static Map<String,String> getUserNameXiaflex(String username, String programName,String ProgramType,String persona) {
            Map<String,String> userMap = new Map<String,String>();
            List<User> filteredUser =  new List<User>();
            String recordType;
            if(persona=='PR'){
                recordType= REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER;
            }
            else if(persona=='AR'){
                 recordType= REMSAppLiterals.ACCOUNT_RECORDTYPE_AR;    
            }
             list<User> userList = [select Id,username,Role__c, AccountId, Program__c FROM User WHERE email=:username AND Program__c=:programName AND IsActive = true and Account.RecordType.DeveloperName =:recordType and Account.RecordType.NamespacePrefix='US_WSREMS']; 
             for(user aUser : userList) {
                if(ProgramType == 'MDP'){
                    if(aUser.username.endsWithIgnoreCase('PRMDP')|| aUser.username.endsWithIgnoreCase('ARMDP')){
                        filteredUser.add(aUser);
                    }
                }else if(ProgramType == 'REMS'){
                     if(aUser.username.endsWithIgnoreCase('PR')|| aUser.username.endsWithIgnoreCase('AR')){
                        filteredUser.add(aUser);
                    }
                }
            }
                if(!filteredUser.isEmpty()){
                    if(filteredUser.size() >1){
                        for(User usr : filteredUser){
                            userMap.put(usr.Id,usr.username);
                        }
                    }else if(filteredUser.size() == 1){
                        userMap.put(userList[0].Id,userList[0].username);
                    }  
                } 
             return userMap;        
        }
        
        
        @AuraEnabled
        public static String forgotPassowrd(String username, String checkEmailUrl) {
            try {
                Site.forgotPassword(username);
                ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
                if(!Site.isValidUsername(username)) {
                    return Label.Site.invalid_email;
                }
                aura.redirect(checkEmailRef);
                return null;
            }
            catch (Exception ex) {
                return ex.getMessage();
            }
        }
        
        @AuraEnabled
        public static string resetPasswordRequested(String username, String programName) {
            try {
                User cuser = [select Id,Is_Reset_Password_Req__c FROM User WHERE UserName=:username AND Program__c=:programName AND IsActive = true]; 
                cuser.Is_Reset_Password_Req__c  = true; 
                update cuser;  
          
            }
            catch (Exception ex) {
                system.debug('----Error---'+ex.getMessage());
                return ex.getmessage();
            }
            return '';
            
        }
        
    
    }