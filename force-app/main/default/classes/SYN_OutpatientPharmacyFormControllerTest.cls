@isTest()
public class SYN_OutpatientPharmacyFormControllerTest {
    
    @isTest
    public static void SYN_OutpatientPharmacyForm_Test() {
        
        // Pharmacy account record type Id 
        Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        Id pharmOutPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Outpatient_Pharmacy').getRecordTypeId();

        // Create admin user with Systm admin profile and role 
        User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert communitydefaulowner;
        }
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        // Profile Query for Inserting community user 
        Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
        
        Test.StartTest();
        System.runAs (communitydefaulowner) {
            
         // Collecting Pharmacy Account and case
            account pharmacyAcc = SYN_TestDataUtility.createPharmacyAccountTest(programObj.id,PharmacyAccRecordTypeId);
            case pharmacyCase = SYN_TestDataUtility.createCasePharmacyTest(pharmOutPatCaseRecTypeId,programObj.Id,pharmacyAcc.Id);
            
            PageReference pageRef = Page.Maci_Outpatient_enrollment;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',pharmacyCase.SYN_Pharmacy__c);
            SYN_OutpatientPharmacyFormController outPatient = new SYN_OutpatientPharmacyFormController();
            System.assertEquals(pharmacyCase.SYN_Pharmacy__c, outPatient.getac().SYN_Pharmacy__c);
       
        }
        Test.StopTest();         
    }
   
}