@isTest
public class SYN_PatientAccountRMRHistListCntllrTest {
    
    public static testMethod void testMethod1() {
    
        String rT_Account_Patient_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        String rT_Account_Pharmacy_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        
        String rT_REMSServSumm_RMR_Id = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId(); 
        
        String rT_Case_RMR_Id = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
      
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c> {
            new US_WSREMS__REMS_Program__c(
                Name = 'Sodium Oxybate REMS',
                US_WSREMS__Status__c ='Active',
                US_WSREMS__Program_State_Date__c = System.today(),
                US_WSREMS__Program_End_Date__c = System.today().addDays(20)
            )
        };
        insert programList;
        
        List<Account> accountList = new List<Account> {
            
            new Account( // Patient Recordtype
                FirstName= 'Test',
                LastName = 'Pharmacy User1',
                PersonEmail= 'abc1@gmail.com',
                Phone='9685748572',
                US_WSREMS__REMS_Program__c = programList[0].Id,
                US_WSREMS__Preferred_Contact_Method__c ='Email',
                RecordTypeId = rT_Account_Patient_Id 
            )
        };      
        insert accountList;
        
        
        SYN_PatientAccountRMRHistListCntllr.getRMRAndCOICases(accountList[0].Id);
        
    }
}