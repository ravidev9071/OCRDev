/**
 * An apex page controller that exposes the change password functionality
 */
@IsTest public with sharing class ChangePasswordControllerTest {
    @IsTest(SeeAllData=true) public static void testChangePasswordController() {
     // Instantiate a new controller with all parameters in the page
     ChangePasswordController controller = new ChangePasswordController();
     controller.oldPassword = '123456';
     controller.newPassword = 'qwerty1'; 
     controller.verifyNewPassword = 'qwerty1';                
     
     System.assertEquals(controller.changePassword(),null); 
     System.assertEquals(controller.piaSkychangePassword(),Site.getBaseUrl()+ '/s/remsverification'); 
 }   
 
     @IsTest public static void aveedTestChangePasswordController() {
     // Instantiate a new controller with all parameters in the page
     Aveed_ChangePasswordController controller = new Aveed_ChangePasswordController();
     controller.oldPassword = '123456';
     controller.newPassword = 'qwerty1'; 
     controller.verifyNewPassword = 'qwerty1';                
     System.assertEquals(controller.changePassword(),null); 
     System.assertEquals(controller.aveedchangePassword(),Site.getBaseUrl()); 
 }  
 
 @IsTest public static void xiaflexInCorrectNewConfirmPassword() {
     // Instantiate a new controller with all parameters in the page
     ChangePasswordController cc = new ChangePasswordController();
     cc.oldPassword = '123456';
     cc.newPassword = 'qwerty'; 
     cc.verifyNewPassword = 'qwerty1';   
     String str = cc.XiaflexchangePassword();
    System.assertEquals(str, null);
 }  
 
 @IsTest public static void xiaflexWithoutNewConfirmPassword() {
     // Instantiate a new controller with all parameters in the page
     ChangePasswordController cc = new ChangePasswordController();
     cc.oldPassword = '123456';
     cc.newPassword = ''; 
     cc.verifyNewPassword = '';   
     String str = cc.XiaflexchangePassword();
     System.assertEquals(str, null);
 }  
 
 @IsTest public static void xiaflexCorrectNewConfirmPassword() {
     // Instantiate a new controller with all parameters in the page
     ChangePasswordController cc = new ChangePasswordController();
     cc.oldPassword = '123456';
     cc.newPassword = 'qwerty1'; 
     cc.verifyNewPassword = 'qwerty1';   
     String str = cc.XiaflexchangePassword();
     System.assertEquals(str, null);
 }  
}