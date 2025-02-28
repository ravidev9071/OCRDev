/**************************************************************************
    * Name :   SYN_AffiliationTriggerHandlerTest
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  11/06/2022             Initial Version
    *********************************************************************************/

@isTest
public class SYN_AffiliationTriggerHandlerTest{
    @isTest
    public static void inactivateAffilcation_Test() {
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
            // Pharmacy account record type Id 
            Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
            Id pharmCINPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
            Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
             // Collecting Patient Account
            account pharmacyAcc = SYN_TestDataUtility.createPharmacyAccountTest(programObj.id,PharmacyAccRecordTypeId);
            case pharmacyCase = SYN_TestDataUtility.createCasePharmacyTest(pharmCINPatCaseRecTypeId,programObj.Id,pharmacyAcc.Id);
            account pharmacyParticipantAcc = SYN_TestDataUtility.createPharmacyParticipantAccountAuthrepTest(programObj.Id,RecordTypeIdPhPa,pharmacyAcc.Id);
            US_WSREMS__Affiliation__c affiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmacyParticipantAcc.Id,pharmacyAcc.Id);
             // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(pharmacyParticipantAcc ,prf.id,programObj.Name,'Inpatient Pharmacy');
            //CustomLightningLoginFormController.login(usr.UserName,'Wilco@123','/s/pharmacy','Macitentan REMS');
            affiliation.Status__c ='Inactive';
            update affiliation; 
        }
           
        Test.StopTest();
    
    }
    
     @isTest
    public static void InactiveInpatientAffilation_Test() {
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
            // Pharmacy account record type Id 
            Id PharmacyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
            Id pharmCINPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();
            Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
             // Collecting pharmacy Account
            account pharmacyAcc = SYN_TestDataUtility.createTestPharmacyAccount(programObj.id,PharmacyAccRecordTypeId);
            
            account spharmacAcc = SYN_TestDataUtility.createPharmacyAccount(programObj.id,PharmacyAccRecordTypeId);
            case pharmacyCase = SYN_TestDataUtility.createCasePharmacyTest(pharmCINPatCaseRecTypeId,programObj.Id,pharmacyAcc.Id);
            account pharmacyParticipantAcc = SYN_TestDataUtility.createPharmacyParticipantAccountAuthrepTest(programObj.Id,RecordTypeIdPhPa,pharmacyAcc.Id);
            US_WSREMS__Affiliation__c affiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmacyParticipantAcc.Id,pharmacyAcc.Id);
            US_WSREMS__Affiliation__c saffiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmacyParticipantAcc.Id,spharmacAcc.Id);

             // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(pharmacyParticipantAcc ,prf.id,programObj.Name,'Inpatient Pharmacy');
            //CustomLightningLoginFormController.login(usr.UserName,'Wilco@123','/s/pharmacy','Macitentan REMS');
            affiliation.Status__c ='Inactive';
            update affiliation; 
        }
           
        Test.StopTest();
    
    }
    

}