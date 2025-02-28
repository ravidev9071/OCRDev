/**
 * An apex page controller that exposes the change password functionality
 */

public with sharing class Aveed_ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;} 

    
    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }
    
    public String aveedchangePassword() {
        Pagereference pr = Site.changePassword(newPassword, verifyNewPassword, oldpassword); 
        String pageRedirect = Site.getBaseUrl(); 
        return pageRedirect;
       
    }

    public Aveed_ChangePasswordController() {}
    
}