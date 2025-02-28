global class SYN_LightningLoginFormController {

    public SYN_LightningLoginFormController() {
        
    }

    @AuraEnabled
    public static String login(String username, String password, String startUrl,String programName) {

            list<User> userList = [select id,username FROM User WHERE email=:username AND Program__c=:programName AND IsActive = true AND IsPortalEnabled = true LIMIT 1];
            if(userList.size()>0) {
                ApexPages.PageReference lgn = Site.login(userList[0].username, password, startUrl);
                aura.redirect(lgn);
                return '';
            } else {
                throw new AuraHandledException('Your login attempt has failed. Make sure the username and password are correct.');
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
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }
    }  
}