@IsTest
public class SYN_ForgotPasswordController_Test {
    @IsTest
    static void testIsloginForm(){
        user user1= createUser();
        insert user1;
        Test.startTest();
        Map<String,String> getUserMap = SYN_ForgotPasswordController.getUserName(user1.Email,user1.Program__c);
        String forgotPass = SYN_ForgotPasswordController.forgotPassowrd(user1.Email,'https://www.google.com');
        List<String> idList = new List<String>();
        for(String i:getUserMap.keySet())
        {
            idList.add(i);
        }
        System.assertEquals('Program1',idList[0]);
        System.assertEquals(null,forgotPass);
        Test.stopTest();
        
        SYN_ForgotPasswordController newForget = new SYN_ForgotPasswordController();
        SYN_ForgotPasswordController.forgotPassowrd('','https://www.google.com');
       
    }@IsTest
    static void testIsloginForm1(){
        user user2= createUser();
        insert user2;
        user user1= createUser();
        insert user1;
        Test.startTest();
        Map<String,String> getUserMap = SYN_ForgotPasswordController.getUserName(user2.Email,user2.Program__c);
        String forgotPass = SYN_ForgotPasswordController.forgotPassowrd(user2.Email,'https://www.google.com');
         List<String> idList = new List<String>();
         for(String i:getUserMap.keySet())
        {
            idList.add(i);
        }
        System.assertEquals('Program1',idList[0]);
        System.assertEquals(null,forgotPass);
        Test.stopTest();
    }
    
    public static user createUser() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User userObj = new User();
        userObj.Program__c ='Program1';
        userObj.UserRoleId = portalRole.Id;
        userObj.ProfileId = profile1.Id;
        userObj.Username = System.now().millisecond() + 'demo@test.com';
        userObj.Alias = 'demo';
        userObj.Email='program@gmail.com';
        userObj.EmailEncodingKey='UTF-8';
        userObj.Firstname='demo';
        userObj.Lastname='sample';
        userObj.LanguageLocaleKey='en_US';
        userObj.LocaleSidKey='en_US';
        userObj.TimeZoneSidKey='America/Chicago';
        return userObj;
    }
}