/**************************************************************************
    * Name :   CustomLightningForgotPasswordContlrTest
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  04/02/2023              Initial Version
    *********************************************************************************/

    @isTest
    public class CustomLightningForgotPasswordContlrTest{
        
        @isTest
        public static void sendPasswordLink_Test() {
             // Create admin user with Systm admin profile and role 
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account acc;
            Test.StartTest();
            System.runAs (communitydefaulowner) {
                // Create Prescriber Account
                acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
                // Create a protal user 
                usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Prescriber');
            }
            system.runAs(usr){
                CustomLightningForgotPasswordController cntlr = new CustomLightningForgotPasswordController();
                Map<String,String> userRoleMap = CustomLightningForgotPasswordController.getUserName(usr.email,'Macitentan REMS');
                System.Assert(!userRoleMap.isEmpty());
                String retrunValue= CustomLightningForgotPasswordController.forgotPassowrd(usr.userName,'www.test.com');
                system.Assert(retrunValue == null);
                String retrunValues= CustomLightningForgotPasswordController.forgotPassowrd('dsdasdsadsad','www.test.com');
                system.Assert(retrunValue == null);
                String restmesage = CustomLightningForgotPasswordController.resetPasswordRequested(usr.userName,'Macitentan REMS');
                system.Assert(restmesage == '');
            } 
            Test.StopTest();
        
        }
        
        //adss
        @isTest
    public static void sendPasswordLink_Xiaflex() {
        // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('XIAFLEX','Active');
        // Profile Query for Inserting community user 
        Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
        User usr;
        Account acc;
        Test.StartTest();
        System.runAs (communitydefaulowner) {
            // Create Prescriber Account
            acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
            // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Prescriber',false);
            usr.UserName=usr.UserName+'PRMDP';
            insert usr;            
        }
        Map<String,String> userRoleMap=new Map<String,String>(), userXiaFlexMap=new Map<String,String>();
        String returnValue,returnValue1,resetMessage;
        System.runAs(usr){
            CustomLightningForgotPasswordController cntlr = new CustomLightningForgotPasswordController();
            userRoleMap = CustomLightningForgotPasswordController.getUserName(usr.email,'XIAFLEX');
            userXiaFlexMap = CustomLightningForgotPasswordController.getUserNameXiaflex(usr.email,'XIAFLEX','MDP','PR');
            returnValue= CustomLightningForgotPasswordController.forgotPassowrd(usr.userName,'www.test.com');
            returnValue1= CustomLightningForgotPasswordController.forgotPassowrd('dsdasdsadsad','www.test.com');
            resetMessage = CustomLightningForgotPasswordController.resetPasswordRequested(usr.userName,'XIAFLEX');
        } 
        Test.StopTest();
        System.Assert(!userRoleMap.isEmpty());
        System.Assert(!userXiaFlexMap.isEmpty());
        System.Assert(returnValue == null);
        System.Assert(returnValue1 != null);
        System.Assert(resetMessage == '');
        
        
    }
    @isTest
    public static void sendPasswordLink_Xiaflex1() {
        // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('XIAFLEX','Active');
        // Profile Query for Inserting community user 
        Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
        User usr;
        Account acc;
        Test.StartTest();
        System.runAs (communitydefaulowner) {
            // Create Prescriber Account
            acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
            // Create a protal user 
            // Dont remove the comment to clean up
            usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Prescriber',false);
            usr.UserName=usr.UserName+'PR';
            insert usr;            
        }
        Map<String,String> userRoleMap=new Map<String,String>(), userXiaFlexMap=new Map<String,String>();
        String returnValue,returnValue1,resetMessage;
        System.runAs(usr){
            CustomLightningForgotPasswordController cntlr = new CustomLightningForgotPasswordController();
            userRoleMap = CustomLightningForgotPasswordController.getUserName(usr.email,'XIAFLEX');
            userXiaFlexMap = CustomLightningForgotPasswordController.getUserNameXiaflex(usr.email,'XIAFLEX','REMS','PR');
            returnValue= CustomLightningForgotPasswordController.forgotPassowrd(usr.userName,'www.test.com');
            returnValue1= CustomLightningForgotPasswordController.forgotPassowrd('dsdasdsadsad','www.test.com');
            resetMessage = CustomLightningForgotPasswordController.resetPasswordRequested(usr.userName,'XIAFLEX');
        } 
        Test.StopTest();
        System.Assert(!userRoleMap.isEmpty());
        System.Assert(!userXiaFlexMap.isEmpty());
        System.Assert(returnValue == null);
        System.Assert(returnValue1 != null);
        System.Assert(resetMessage == '');
        
    }
       
}