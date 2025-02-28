/*
 * Test class for : SYN_ProviderRegistrationController
 * Created by: Wilco
 * Modification:
  	Ashish Yadav(Wilco) | 24082022 | Added Method testDEAValidationBeforeParticipantCreation
 
*/

@isTest(seeAllData=true)
public class SYN_ProviderRegistrationController_test {
    
    
     public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('Salesforcescool');
            return res;
        }
     }   
    public static testMethod void testMethod1() {
       
      
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Sodium Oxybate REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        
       
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Reenrollment').getRecordTypeId();
        //Id accRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Account').getRecordTypeId();
		Id accRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Account').getRecordTypeId();        
        //String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypeId1 = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        
        
        
        Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
        PrescriberObj.US_WSREMS__REMS_Program__c = programObj.id;
        PrescriberObj.US_WSREMS__Email__c = 'uniqueprescriberemail1@gmail.com';
        insert PrescriberObj;
        
        /*US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Syneos Phase2';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;*/
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  programObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj; 
        
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = programObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
        Account accPharmUserObj1 = new Account();
        accPharmUserObj1.FirstName= 'Test';
        accPharmUserObj1.LastName = 'Pharmacy User2';
        accPharmUserObj1.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj1.PersonEmail= 'abc@gmail.com';
        accPharmUserObj1.Phone='9685748572';
        accPharmUserObj1.US_WSREMS__REMS_Program__c = programObj.Id;
        accPharmUserObj1.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj1;
        
        String payload = '{"Id":"","US_WSREMS__First_Name__c":"Test","US_WSREMS__Last_Name__c":"Test","recordTypeId":"'+recordTypeId+'"}';
        String payload1 = '{"Id":"","FirstName":"Test 1","US_WSREMS__Last_Name__c":"Test 2","US_WSREMS__Phone__c":"1234567890"}';
        String payload2 = '{"data": [{"Id":'+accPharmUserObj1.Id+',"Name":'+accPharmUserObj1.Name+'}]}';        
      
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
       // serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId1;
        insert serviceObj;
        Id patientAffiliationRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Patient_Affiliation').getRecordTypeId();
        
        
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPharmUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPharmUserObj.Phone;
        caseObj.US_WSREMS__Pharmacy_User__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy_User_ar__c = accPharmUserObj.Id;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS'+'-Change_Authorized_Representative';
        insert caseObj;
        
        SYN_ProviderRegistrationController.getRCTYPId('Pharmacy_Account');
        SYN_ProviderRegistrationController.createPortalAcctOnCaseCreation(caseObj.Id);
        SYN_ProviderRegistrationController.updateAccountOnCaseCreation(caseObj.Id,accPharmUserObj.Id);
   }
    
    public static testMethod void testDEAValidationBeforeParticipantCreation() {
        
       
        String recordTypePharmacyId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant_Account').getRecordTypeId();
		System.debug('recordTypePharmacyId***test'+recordTypePharmacyId);	        
                    
        String jsonFields = '{"Id":"","US_WSREMS__Name__c":"Test Case","US_WSREMS__First_Name__c":"Test","US_WSREMS__Last_Name__c":"Test","US_WSREMS__DEA__c":"123456789","US_WSREMS__Status__c":"Initiated","US_WSREMS__Phone__c":"1234567890","RecordTypeId":"'+recordTypePharmacyId+'"}';
        
		SYN_Credentials__mdt theRecord = [SELECT Id, DeveloperName,Username__c,Password__c,Endpoint_URL__c from SYN_Credentials__mdt LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        SYN_ProviderRegistrationController.DEAValidationBeforeParticipantCreation(recordTypePharmacyId,jsonFields);
        //SYN_VeevaAPI_Search.VeevaAuthenticationProcess(theRecord);
        SYN_ProviderRegistrationController.checkAccountDuplicates(recordTypePharmacyId,jsonFields);
        Test.stopTest();
       
    }// end of testDEAValidationBeforeParticipantCreation
    
    
}