/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}   
    private static final String PIASKY_LOGIN_START_PATH = '/s/remsverification';      
    private static final String xiaflex_LOGIN_START_PATH = '/s/login-Signup';

    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }   
    
    public String XiaflexchangePassword() {      
        if(newPassword != verifyNewPassword){
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Please verify your password');
        ApexPages.addMessage(msg);
		return null;
        }else if(String.isblank(newPassword) && String.isblank(verifyNewPassword)){
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter your password');
        ApexPages.addMessage(msg);
		return null;
        }
        Pattern regexPattern=Pattern.compile('^(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$');
        Matcher matcher = regexPattern.matcher(newPassword);
        if(!matcher.matches()) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Password should be atleast be 8 characters long and include at least 1 letter,1 number, 1 special character.');
        ApexPages.addMessage(msg);
        return null;
        }   
        Pagereference pr = Site.changePassword(newPassword, verifyNewPassword, oldpassword); 
        if(pr!=null){
        SYN_PiaSkyRDAList.loggedOutUser();
        String pageRedirect = Site.getBaseUrl() + xiaflex_LOGIN_START_PATH;
        return pageRedirect;
        }
        else{
            return null;
        }
       
    }
    public String piaSkychangePassword() {
        Pagereference pr = Site.changePassword(newPassword, verifyNewPassword, oldpassword); 
        String pageRedirect = Site.getBaseUrl() + PIASKY_LOGIN_START_PATH;
        return pageRedirect;
       
    }
   	public ChangePasswordController() {}
}