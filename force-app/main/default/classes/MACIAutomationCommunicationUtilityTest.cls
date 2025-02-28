/**
* @File Name          : MACIAutomationCommunicationUtilityTest .cls
* @Description        : This class provides test coverage for MACIAutomationCommunicationUtility.
* @TestClass          : MACIAutomationCommunicationUtilityTest
* @Author             : Wilco
* @Date               : 03/FEB/2022
**/
@isTest
public class MACIAutomationCommunicationUtilityTest {
    @testsetup
    public static void yourNewTestMethodName() {
        EmailTemplate et = new EmailTemplate(); 
        et.isActive = true; 
        et.Name = 'Test_Template'; 
        et.FolderId = UserInfo.getUserId();
        et.DeveloperName = 'Test_Template'; 
        et.TemplateType = 'text';
        et.Subject = 'Test Subject';
        et.Body = 'Test Body'; 
        
        // Insert the EmailTemplate record
        insert et;
        
        system.debug('et' + et);
        
        
    }
    @isTest
    public static void maciEmailAutomationCommunication_Test() {
        Id recordTypeIdPatient = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
        id recordTypeIdPrescriber = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        id caseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('case', 'Patient_Enrollement');
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        Account prescAcc = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummary(createPatientAccount.Id,programObj.Id);
        Case createPatientEnrollmentCase= SYN_TestDataUtility.createaPatientEnrollmentPatientCaseFRP(caseRecordTypeId, programObj.Id,'Test FirstName','Test LastName',objService.id,createPatientAccount.Id);
        Test.startTest();
        List<US_WSREMS__REMS_Service_Summary__c> rssList =New List<US_WSREMS__REMS_Service_Summary__c>();
        rssList.add(objService);
        Map<Id,US_WSREMS__REMS_Service_Summary__c> rssMap =New  Map<Id,US_WSREMS__REMS_Service_Summary__c>();
        rssMap.put(objService.id,objService);
        MACIAutomationCommunicationUtility.maciEmailAutomationCommunication(rssList,rssMap);
        Test.stopTest();
    }
    
    @isTest
    public static void maciEmailCommunicationForPAEPC_Test() {
        id recordTypeIdPatient = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
        id caseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'PAE_PC_MI');
        id recordTypeIdPrescriber = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        Account prescAcc = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummarypatientclosed(createPatientAccount.Id,programObj.Id);
        Case cs= SYN_TestDataUtility.createacaseforpatient(caseRecordTypeId, programObj.Id,objService.id,createPatientAccount.Id,prescAcc.id);
        List<Case> csList = New List<Case>();
        csList.add(cs);
        Test.StartTest();  
        MACIAutomationCommunicationUtility.getReportableEventFormMACI(csList);
        Test.StopTest();  
        
    }
    @isTest
    public static void maciEmailCommunicationForPAEPC_Test1() {
        id recordTypeIdPatient = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
        id caseRecordTypeId =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('case', 'PAE_PC_MI');
        id recordTypeIdPrescriber =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        Id patientEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        Account prescAcc = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummarypatientclosed(createPatientAccount.Id,programObj.Id);
        Case cs= SYN_TestDataUtility.createacaseforpatient(caseRecordTypeId, programObj.Id,objService.id,createPatientAccount.Id,prescAcc.id);
        MACIAutomationCommunicationUtility.patientAccIdvsDisenrollCaseRecMap.put(createPatientAccount.Id,  System.today());
        MACIAutomationCommunicationUtility.patientAccIdvsDisenrollCaseRecMap.put(prescAcc.Id,  System.today());
        Set<Id> disEnrollCasePatientIdSet = new Set<Id>{createPatientAccount.Id};
            List<Case> csList = New List<Case>();
        csList.add(cs);
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        id  Test_Template = SYN_TestDataUtility.createEmailTemplate('Test Subject','Test Body','text'); 
        Test.StartTest();  
        MACIAutomationCommunicationUtility.getReportableEventFormMACI(csList);
        MACIAutomationCommunicationUtility.sendFaxNotification(csList);
        MACIAutomationCommunicationUtility.sendNotification(csList);
        MACIAutomationCommunicationUtility.sendPatientDisenrollmentEmail(disEnrollCasePatientIdSet);
        MACIAutomationCommunicationUtility.checkEmailOrFax('Fax', 'Test', 'Test@gmail.com','Test'); 
        MACIAutomationCommunicationUtility.checkEmailOrFax('Test', '', 'Test@gmail.com','Test'); 
        EmailTemplate tem = [SELECT Id,Name,DeveloperName FROM EmailTemplate WHERE id =:Test_Template]; 
        Assert.areNotEqual(null, tem, 'tem should not be null'); 
        OrgWideEmailAddress addresses = [SELECT Id,Address FROM OrgWideEmailAddress LIMIT 1];
        Assert.areNotEqual(null, addresses, 'address should not be null'); 
        MACIAutomationCommunicationUtility.Requests testRequest = new MACIAutomationCommunicationUtility.Requests();
        testRequest.accountId = prescAcc.Id; // Replace with a valid Account ID
        testRequest.templateName =tem.DeveloperName; // Replace with an existing template name
        testRequest.toAddress = addresses.Address;
        testRequest.BccAddress = 'bcc@example.com';
        testRequest.fromAddress = addresses.Address;
        Assert.areNotEqual(null, testRequest, 'total request willn tbe null'); 
        Assert.areNotEqual(null, testRequest.accountId, 'account idwill not be null'); 
        Assert.areNotEqual(null, testRequest.templateName, 'template name should not be null');   
        Assert.areNotEqual(null, testRequest.toAddress, 'toaddress should not be null'); 
        Assert.areNotEqual(null, testRequest.fromAddress, 'fromaddress shouldnot be null'); 
        // Create a list to hold the test request
        List<MACIAutomationCommunicationUtility.Requests> requestList = new List<MACIAutomationCommunicationUtility.Requests>();
        requestList.add(testRequest);
        // Call the method to be tested
        MACIAutomationCommunicationUtility.sendNotificationFromFlow(requestList);
        Test.stopTest();
           }
    }
    
    // Define the Requests class structure here
    public class Requests {
        @InvocableVariable(label='accountId' description='currentAccountId' required=true)
        public Id accountId;
        @InvocableVariable(label='templateName' description='Template ID' required=true)
        public String templateName;
        @InvocableVariable(label='toAddress' description='toAddress' required=true)
        public string toAddress;
        @InvocableVariable(label='BccAddress' description='yourDescription' required=true)
        public String BccAddress;
        @InvocableVariable(label='fromAddress' description='yourDescription' required=false)
        public String fromAddress;
    }

    @isTest
    public static void maciEmailCommunicationForPAEPC_Test2() {
        id recordTypeIdPatient =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
        id caseRecordTypeId =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('case', 'PAE_PC_MI');
        id recordTypeIdPrescriber = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        Account prescAcc = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummaryprescriberclosed(prescAcc.Id,programObj.Id);  
        Case cs= SYN_TestDataUtility.createaPresciberEnrollmentPatientCase(caseRecordTypeId, programObj.Id,objService.id,createPatientAccount.Id,prescAcc.id);
        List<Case> csList = New List<Case>();
        csList.add(cs);
        Test.StartTest();  
        MACIAutomationCommunicationUtility.getReportableEventFormMACI(csList);
        Test.StopTest();  
    }

   /* @isTest
    public static void macipatientenrollmentcasewithprefcontactasemail() {
        id recordTypeIdPatient = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
        id caseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('case', 'Patient_Enrollement');
        id recordTypeIdPrescriber = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        createPatientAccount.Email_address__c = 'Enrolled@abc.com';
        update createPatientAccount;
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummaryopen(createPatientAccount.Id,programObj.Id);
        id disServiceRecTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Disenrollment').getRecordTypeId();
        id rmrServiceRecTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
        id caseRiskManagementRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
        String disenrollcaserecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deactivation').getRecordTypeId();
        Account actObj = SYN_TestDataUtility.createPatientAccountTest(programObj.Id, recordTypeIdPatient);
        actObj.Email_address__c = 'Enrolled@abc.com';
        update actObj;
        Account acc = [SELECT Id, US_WSREMS__Status__c FROM Account WHERE Id =:actObj.Id];
       Case caseObj = SYN_TestDataUtility.createaPatientEnrollmentCase(caseRecordTypeId,'FirstName','LastName', 'Draft',programObj.id,actObj);
        caseObj.US_WSREMS__REMS_Service_Summary__c = objService.Id;
        caseObj.Status = 'Complete';
        caseObj.SYN_Prescriber_Signature__c ='Yes';
        caseObj.US_WSREMS__Signature__c='Yes';
        caseObj.US_WSREMS__Date__c =System.today();
        caseObj.SYN_Prescriber_Signature_Date__c =System.today();
        caseObj.SYN_Prescriber__c = createPatientAccount.Id;
        caseObj.US_WSREMS__Outcome__c = 'Incomplete';
        caseObj.Approval_Status__c = 'Pending for DEA Override';
        update caseObj;
      
        Test.startTest();
        List<US_WSREMS__REMS_Service_Summary__c> rssList =New List<US_WSREMS__REMS_Service_Summary__c>();
        rssList.add(objService);
        Map<Id,US_WSREMS__REMS_Service_Summary__c> rssMap =New  Map<Id,US_WSREMS__REMS_Service_Summary__c>();
        rssMap.put(objService.id,objService);
        MACIAutomationCommunicationUtility.maciEmailAutomationCommunication(rssList,rssMap);
        Test.stopTest();
    }*/
    @isTest
    public static void macipatientenrollmentcasewithprefcontactasemail_Test() {
        id recordTypeIdPatient = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
        id caseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('case', 'Patient_Enrollement');
        id recordTypeIdPrescriber = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        createPatientAccount.Email_address__c = 'Enrolled@abc.com';
        update createPatientAccount;
        id disServiceRecTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Disenrollment').getRecordTypeId();
        id rmrServiceRecTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
        id caseRiskManagementRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
        String disenrollcaserecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deactivation').getRecordTypeId();
        Account actObj = SYN_TestDataUtility.createPatientAccountTest(programObj.Id, recordTypeIdPatient);
        actObj.Email_address__c = 'Enrolled@abc.com';
        update actObj;
        Account acc = [SELECT Id, US_WSREMS__Status__c FROM Account WHERE Id =:actObj.Id];
        US_WSREMS__REMS_Service_Summary__c objService1 = SYN_TestDataUtility.createRemsServiceSummaryDisenrollment(actObj.Id,programObj.Id);
        Case caseObj = SYN_TestDataUtility.createaPatientEnrollmentCase(caseRecordTypeId,'FirstName','LastName', 'Draft',programObj.id,actObj);
        caseObj.US_WSREMS__REMS_Service_Summary__c = objService1.Id;
        caseObj.Status = 'Complete';
        caseObj.SYN_Prescriber_Signature__c ='Yes';
        caseObj.US_WSREMS__Signature__c='Yes';
        caseObj.US_WSREMS__Date__c =System.today();
        caseObj.SYN_Prescriber_Signature_Date__c =System.today();
        caseObj.SYN_Prescriber__c = createPatientAccount.Id;
        caseObj.US_WSREMS__Outcome__c = 'Incomplete';
        caseObj.Approval_Status__c = 'Pending for DEA Override';
        update caseObj;
        Map<Id,US_WSREMS__REMS_Service_Summary__c> rssMap1 =New  Map<Id,US_WSREMS__REMS_Service_Summary__c>();
        rssMap1.put(objService1.id,objService1);
        objService1.US_WSREMS__Service_Outcome__c = 'Successful';
        objService1.US_WSREMS__Status__c = 'Closed';
        update objService1;
        List<US_WSREMS__REMS_Service_Summary__c> rssList1 =New List<US_WSREMS__REMS_Service_Summary__c>();
        rssList1.add(objService1);
        MACIAutomationCommunicationUtility.maciEmailAutomationCommunication(rssList1, rssMap1);
        Test.startTest();
        Map<Id,US_WSREMS__REMS_Service_Summary__c> rssMap =New  Map<Id,US_WSREMS__REMS_Service_Summary__c>();
        rssMap.put(objService1.id,objService1);
        Test.stopTest();
    }
    @isTest
    public static void macipatientenrollmentcasewithprefcontactasFax() {
        id recordTypeIdPatient =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient'); 
        id caseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('case', 'Patient_Enrollement');
        id recordTypeIdPrescriber =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        Account prescAcc1 = SYN_TestDataUtility.createPrescriberAccountWithNPIprefcontasFax(programObj.Id,recordTypeIdPrescriber);
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummaryopen(createPatientAccount.Id,programObj.Id);
        Case createPatientEnrollmentCase1= SYN_TestDataUtility.createaPatientEnrollmentPatientCasewithFaxasprefcontact(caseRecordTypeId, programObj.Id,'Test FirstName','Test LastName',objService.id,createPatientAccount.Id,prescAcc1.id);
        Test.startTest();
        List<US_WSREMS__REMS_Service_Summary__c> rssList =New List<US_WSREMS__REMS_Service_Summary__c>();
        rssList.add(objService);
        Map<Id,US_WSREMS__REMS_Service_Summary__c> rssMap =New  Map<Id,US_WSREMS__REMS_Service_Summary__c>();
        rssMap.put(objService.id,objService);
        MACIAutomationCommunicationUtility.maciEmailAutomationCommunication(rssList,rssMap);
        Test.stopTest();
    }

    @isTest
    public static void maciPrescriberrollmentcasewithprefcontactasemail() {
        id recordTypeIdPatient =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
        id caseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('case', 'Prescriber_enrollment');
        id recordTypeIdPrescriber =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber'); 
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        Account prescAcc = SYN_TestDataUtility.createPrescriberAccountWithNPIemail(programObj.Id,recordTypeIdPrescriber);
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummaryprescriberopen(prescAcc.Id,programObj.Id);
        Case createPatientEnrollmentCase= SYN_TestDataUtility.createaPresciberEnrollmentPatientCasedraftpcemail(caseRecordTypeId, programObj.Id,'Test FirstName','Test LastName',objService.id,createPatientAccount.Id,prescAcc.id);
        Test.startTest();
        List<US_WSREMS__REMS_Service_Summary__c> rssList =New List<US_WSREMS__REMS_Service_Summary__c>();
        rssList.add(objService);
        Map<Id,US_WSREMS__REMS_Service_Summary__c> rssMap =New  Map<Id,US_WSREMS__REMS_Service_Summary__c>();
        rssMap.put(objService.id,objService);
        MACIAutomationCommunicationUtility.maciEmailAutomationCommunication(rssList,rssMap);
        Test.stopTest();
    }
   
    @isTest
    public static void maciPrescriberenrollmentcasewithprefcontactasFax() {
        id recordTypeIdPatient =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
        id caseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('case', 'Prescriber_enrollment');
        id recordTypeIdPrescriber =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        Account prescAcc1 = SYN_TestDataUtility.createPrescriberAccountWithNPIprefcontasFax(programObj.Id,recordTypeIdPrescriber);
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummaryprescriberopen(prescAcc1.Id,programObj.Id);
        Case createPatientEnrollmentCase1= SYN_TestDataUtility.createaPresciberEnrollmentPatientCasedraftpcfax(caseRecordTypeId, programObj.Id,'Test FirstName','Test LastName',objService.id,createPatientAccount.Id,prescAcc1.id);
        Test.startTest();
        List<US_WSREMS__REMS_Service_Summary__c> rssList =New List<US_WSREMS__REMS_Service_Summary__c>();
        rssList.add(objService);
        Map<Id,US_WSREMS__REMS_Service_Summary__c> rssMap =New  Map<Id,US_WSREMS__REMS_Service_Summary__c>();
        rssMap.put(objService.id,objService);
        MACIAutomationCommunicationUtility.maciEmailAutomationCommunication(rssList,rssMap);
        Test.stopTest();
    }
    
}