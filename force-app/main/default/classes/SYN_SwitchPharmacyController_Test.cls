/**************************************************************************
    * Name :   SYN_SwitchPharmacyController_Test
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  06/04/2023             Initial Version
    *********************************************************************************/


@isTest
public class SYN_SwitchPharmacyController_Test{
    @isTest
    static void SYN_SwitchPharmacyController_PharmacyTest() {
        Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
        Id recordTypeIdPharmacy= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        
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
        US_WSREMS__Affiliation__c  aff;
        
        Test.StartTest();
        Account pharmCAccount;
        System.runAs (communitydefaulowner) {
            pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy);
            pharmCAccount.Pharmacy_Type__c = 'Inpatient';
            update pharmCAccount;
            
            // Create Pharmacy participant Account
            acc = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,RecordTypeIdPhPa);
            
            // Create a protal user 
            usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Pharmacy');
            
            aff = SYN_TestDataUtility.createAffiliation(programObj.Id,acc.id,pharmCAccount.Id);
            aff.Status__c = 'Active';
            update aff;
        }
        
        system.runAs(usr){
            
            // Covering code coverage for getPharmacyList method
            Map<String,String> pharmacyMap = SYN_SwitchPharmacyController.getPharmacyList(programObj.Id,'Inpatient');
            
            // Covering code coverage for get updateDefaultPharmacy method
            SYN_SwitchPharmacyController.updateDefaultPharmacy(aff.id);
            
             // Covering code coverage for get getUserDefaultPharmacyInfomethod
            SYN_SwitchPharmacyController.getUserDefaultPharmacyInfo(UserInfo.getUserId());
            
            
            // Covering code coverage for get attachEnrollmentFormonAccountmethod
            SYN_SwitchPharmacyController.attachEnrollmentFormonAccount(pharmCAccount.name,pharmCAccount.Id,'Inpatient');
           
        }
        
        Test.StopTest();         
    }
    
    }