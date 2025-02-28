@isTest(SeeAllData=True)
public class SYN_IncontactAPIUtility_Test {
    public static testMethod void method1() {
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new SYN_IncontactAPIUtility_Mock_Test());
        SYN_InContactAPIUtility.generateAccessToken();
        SYN_InContactAPIUtility.generateRefreshToken('9889iiuyt67788uuii');
        SYN_InContactAPIUtility.makeACallURL('Yes','998877665544');
        SYN_InContactAPIUtility.makeFinalCallAPI('https://incontact.com');        
        Test.stopTest();
    }
    public static testMethod void Piaskymethod1() {
        user user1= SYN_ForgotPasswordController_Test.createUser();
        user1.Program__c = 'Piasky REMS';
        insert user1;
       System.runAs ( new User(Id = user1.Id) ) {
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new SYN_IncontactAPIUtility_Mock_Test());
        SYN_InContactAPIUtility.generateAccessToken();
        SYN_InContactAPIUtility.generateRefreshToken('9889iiuyt67788uuii');
        SYN_InContactAPIUtility.makeACallURL('Yes','998877665544');
        SYN_InContactAPIUtility.makeFinalCallAPI('https://incontact.com');        
        Test.stopTest();
        }
    }
    public static testMethod void Tryviomethod1() {
        user user1= SYN_ForgotPasswordController_Test.createUser();
        user1.Program__c = 'TRYVIO REMS';
        insert user1;
       System.runAs ( new User(Id = user1.Id) ) {
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new SYN_IncontactAPIUtility_Mock_Test());
        SYN_InContactAPIUtility.generateAccessToken();
        SYN_InContactAPIUtility.generateRefreshToken('9889iiuyt67788uuii');
        SYN_InContactAPIUtility.makeACallURL('Yes','998877665544');
        SYN_InContactAPIUtility.makeFinalCallAPI('https://incontact.com');        
        Test.stopTest();
        }
    }
    public static testMethod void Macimethod1() {
        user user1= SYN_ForgotPasswordController_Test.createUser();
        user1.Program__c = 'Macitentan REMS';
        insert user1;
       System.runAs ( new User(Id = user1.Id) ) {
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new SYN_IncontactAPIUtility_Mock_Test());
        SYN_InContactAPIUtility.generateAccessToken();
        SYN_InContactAPIUtility.generateRefreshToken('9889iiuyt67788uuii');
        SYN_InContactAPIUtility.makeACallURL('Yes','998877665544');
        SYN_InContactAPIUtility.makeFinalCallAPI('https://incontact.com');        
        Test.stopTest();
        }
    }
}