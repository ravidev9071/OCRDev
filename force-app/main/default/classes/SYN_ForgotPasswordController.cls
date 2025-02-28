global class SYN_ForgotPasswordController {

    public SYN_ForgotPasswordController () {

    }
    
    @AuraEnabled
    public static Map<String,String> getUserName(String username, String programName) {
         Map<String,String> userMap = new Map<String,String>();
         list<User> userList = [select Id,username, AccountId, Program__c FROM User WHERE email=:username AND IsActive = true]; 
         if(!userList.isEmpty()){
             if(userList.size() >1){
                 for(User usr : userList){
                     userMap.put(usr.Program__c,usr.username);
                 }
             }else if(userList.size() == 1){
                 userMap.put(userList[0].Program__c,userList[0].username);
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
    

}