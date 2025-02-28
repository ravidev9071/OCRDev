@isTest
public class PharmacyPrescriberProfileControllerTest {
    public static testMethod void method1() {
        try {
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        Account accPharmObj = new Account();
        accPharmObj.LastName = 'Test Pharmacy';
        accPharmObj.firstName = 'Test Pharmacy';
        accPharmObj.US_WSREMS__Status__c = 'Certified'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId; 
        accPharmObj.US_WSREMS__Email__c = 'Test1@demo.com';
        insert accPharmObj;
        
        /*US_WSREMS__REMS_Service_Summary__c remsService  = new US_WSREMS__REMS_Service_Summary__c();
        remsService.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        remsService.US_WSREMS__Path_Complete__c= true;
        remsService.US_WSREMS__Status__c = 'Closed';
        remsService.US_WSREMS__Path_Stage_Name__c ='Closed';
        remsService.US_WSREMS__Service_Outcome__c = 'Successful';
        insert remsService;*/
        
        PharmacyPrescriberProfileController.updatePersonAccount(accPharmObj,'SOXPrescriberPortal');
       // PharmacyPrescriberProfileController.updatePersonAccount(accPharmObj,'PharmacyPortal');
        } catch(Exception e) {
            
        }
    }
    
    public static testMethod void method2() {
        try {
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        Account accPharmObj = new Account();
        accPharmObj.LastName = 'Test Pharmacy';
        accPharmObj.firstName = 'Test Pharmacy';
        accPharmObj.Phone='1122334455';
       // accPharmObj.US_WSREMS__Status__c = 'Certified'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;
        
        /*US_WSREMS__REMS_Service_Summary__c remsService  = new US_WSREMS__REMS_Service_Summary__c();
        remsService.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        remsService.US_WSREMS__Path_Complete__c= true;
        remsService.US_WSREMS__Status__c = 'Closed';
        remsService.US_WSREMS__Path_Stage_Name__c ='Closed';
        remsService.US_WSREMS__Service_Outcome__c = 'Successful';
        insert remsService;*/
        
       // PharmacyPrescriberProfileController.updatePersonAccount(accPharmObj,'SOXPrescriberPortal');
        PharmacyPrescriberProfileController.updatePersonAccount(accPharmObj,'PharmacyPortal');
        } catch(Exception e) {
            
        }
    }
}