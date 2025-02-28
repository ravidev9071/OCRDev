/**
* @File Name          : SYN_AccountTriggerHandler_Test.cls
* @Description        : This is a test class for SYN_AccountTriggerHandler.
* @Trigger			  : SYN_AccountTrigger
* @Class    	      : SYN_AccountTriggerHandler
* @Author 			  : Wilcosource
* @Modification Log   :
* Ver       Date            Developer      		             Modification
* 1.0    02/22/2022        Chaitanya Nandamuri (Wilco)     Initial Implementation (Case Status Automation FrameWork)
* 2.0    05/17/2022        Ismail Shaik (Wilco)            Initial Implementation (Case Status Automation FrameWork)
**/
@isTest
public class SYN_AccountTriggerHandler_Test {
   
    @testSetUp
    static void createTestData(){
        
       //List<US_WSREMS__REMS_Program__c> remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);
      // Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
       //PrescriberObj.US_WSREMS__REMS_Program__c = remsProgramList[0].id;
       //insert PrescriberObj;
    }
        @isTest
    private static void testcreateRemsService(){
        List<US_WSREMS__REMS_Service_Summary__c > RssList = [select Id , US_WSREMS__Participant__c  from US_WSREMS__REMS_Service_Summary__c  limit 1];
        List<account> PrescriberList = [select Id,US_WSREMS__Status__c from account limit 1 ];
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Syneos Phase2';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        List<Account> accountList = new List<Account>();
        
        
        for(Integer i = 0; i<10;i++){
            Account acc=new Account();
            acc.LastName='TestAccount';
            acc.FirstName='TestAccountFN';
            acc.Phone ='1234567890';
            acc.US_WSREMS__Status__c ='Certified';
            acc.US_WSREMS__REMS_Program__c = programObj.Id;
            acc.US_WSREMS__Email__c = 'test'+i+'@test.com';
            acc.recordTypeId =Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
            accountList.add(acc);
        }
        insert accountList;
        
    accountList[0].recordTypeId =   Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();

     accountList[0].US_WSREMS__Status__c ='Enrolled';
        
      update accountList;
       
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
      /*  US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Sodium Oxybate REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        Insert programObj;*/
        id RemsRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId();

       
        
      /*  Case caseObj = new Case(RecordTypeId = caseRecordTypeId, Status = 'Draft',SYN_Prescriber__c=accountList[0].Id, US_WSREMS__REMS_Service_Summary__c = serviceObj.id);
        insert caseObj;*/
        
            US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
            pgrmObj.Name = 'Sodium Oxybate REMS';
            pgrmObj.US_WSREMS__Status__c ='Active';
            pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
            pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
            insert pgrmObj;
        
             String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
            String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        String recordTypeDistributorId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('REMS_Distributor_Account').getRecordTypeId();
            //Test Account for Portal Account Sharing
            Account portalSharingAccObj = new Account();
            portalSharingAccObj.Name = 'SOX Portal Sharing Account'; 
            portalSharingAccObj.US_WSREMS__Status__c = 'Certified'; 
            portalSharingAccObj.Phone = '1478956223';
            portalSharingAccObj.Fax = '1478956235';
            portalSharingAccObj.US_WSREMS__Email__c = 'test21@test.com';
            portalSharingAccObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
            portalSharingAccObj.RecordTypeId = recordTypeDistributorId;      
            insert portalSharingAccObj;

           //Pharmacy user Account Creation
            Account accPharmUserObj = new Account();
            accPharmUserObj.FirstName= 'Test';
            accPharmUserObj.LastName = 'Pharmacy User';
            accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
            accPharmUserObj.PersonEmail= 'abc@gmail.com';
            accPharmUserObj.US_WSREMS__Email__c = 'test31@test.com';
            accPharmUserObj.Phone='9685748572';
            accPharmUserObj.US_WSREMS__REMS_Program__c = programObj.Id;
            accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
            insert accPharmUserObj;
        
         //Pharmacy Account Creation
            Account accPharmObj = new Account();
            accPharmObj.Name = 'Test Pharmacy'; 
            accPharmObj.US_WSREMS__Status__c = 'Certified'; 
            accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
            accPharmObj.RecordTypeId = recordTypePharmacyId;
            accPharmObj.US_WSREMS__Email__c = 'test41@test.com';
            insert accPharmObj;
        //Distributor Account Creation
         Account accDistObj = new Account();
            accDistObj.Name = 'Test Pharmacy'; 
            accDistObj.US_WSREMS__Status__c = 'Certified'; 
            accDistObj.Phone = '1478956223';
            accDistObj.Fax = '1478956235';
            accDistObj.US_WSREMS__Email__c= 'test51@test.com';
            accDistObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
            accDistObj.RecordTypeId = recordTypeDistributorId;      
            insert accDistObj;
        
          String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Participant_Account_Creation').getRecordTypeId();
            US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
            serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
            serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
            serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
            //serviceObj.US_WSREMS__Status__c = 'In Progress';
            serviceObj.recordTypeId = recordTypeId;
            insert serviceObj;
        
        
           /*   US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
        serviceObj.recordTypeId = RemsRecordTypeId;
        Insert serviceObj;*/
        
        
          String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPharmUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPharmUserObj.Phone;
       // caseObj.US_WSREMS__Pharmacy_User__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy_User_ar__c = accPharmUserObj.Id;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.Program_Record_Type_Control__c = pgrmObj.Name+'-Change_Authorized_Representative';
        caseObj.US_WSREMS__Call_Outcome__c = 'TEST';
        insert caseObj;
        
   
        
        
        
        Id PharmacyuserAffiliation=Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId() ;
        
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = PharmacyuserAffiliation;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj; 
        
        
       // PrescriberList[0].US_WSREMS__Status__c = 'Certified';
       // update PrescriberList;
      //  system.assertEquals(PrescriberList[0].id , RssList[0].US_WSREMS__Participant__c );
     
       // SYN_AccountTriggerHandler.updatedAllCasesToclosed(accountList);
       // Ensure SOX Portal Sharing Account was updated in newly created account
      List<Account> createdAccounts = [SELECT Id, Name, Portal_Sharing_Account__c From Account WHERE Portal_Sharing_Account__c != NULL];
      //System.assertEquals(portalSharingAccObj.Id, createdAccounts[0].Portal_Sharing_Account__c); 
       //accountList[0].US_WSREMS__Channel__c = 'Portal';
        //update accountList;
       SYN_AccountTriggerHandler.createPortalUsers(accountList);
       SYN_AccountTriggerHandler.updatedEnrolledDate(accountList);
    }

    @isTest
    private static void updateEmailOnARAccountTest(){
        Account accountRec = new Account();
        accountRec.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        accountRec.RecordtypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
        accountRec.PersonEmail = 'test@test.com';
        List<Account> accList = new List<Account>();
        accList.add(accountRec);
        Test.startTest();
            SYN_AccountTriggerHandler.updateEmailOnARAccount(accList);
        Test.stopTest();
        system.assertEquals('test@test.com', accountRec.US_WSREMS__Email__c);
    }

    @isTest
    public static void updateRelatedAccountANDCasesTest(){
        Id accRectypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId(); 
        Id prescAccRectypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId(); 
        Id serviceRectypeId =  Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId(); 
        Id prescCaseRectypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId(); 
        Id caseRectypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId(); 
        List<US_WSREMS__REMS_Program__c> progObjList = SYN_TestDataFactory.createProgram(1,true,'XIAFLEX','001');
        Insert progObjList;
        List<Account> newAccList = new List<Account>();
        Account HcsAcc = new Account();
        HcsAcc.Name = 'Test HCS';
        HcsAcc.US_WSREMS__REMS_Program__c = progObjList[0].Id;
        HcsAcc.RecordTypeId = accRectypeId;
        HcsAcc.US_WSREMS__Program_Picklist__c = 'XIAFLEX';
        HcsAcc.US_WSREMS__Status__c = 'Pending';
        newAccList.add(HcsAcc);
        
        Account prescAcc = new Account();
        prescAcc.LastName = 'Test Prescriber';
        prescAcc.FirstName = 'First';
        prescAcc.US_WSREMS__REMS_Program__c = progObjList[0].Id;
        prescAcc.RecordTypeId = prescAccRectypeId;
        prescAcc.US_WSREMS__Program_Picklist__c = 'XIAFLEX';
        newAccList.add(prescAcc);
        Insert newAccList;
        
        List<US_WSREMS__REMS_Service_Summary__c> insertServiceObjList = new List<US_WSREMS__REMS_Service_Summary__c>();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__Participant__c  = HcsAcc.Id;
        serviceObj.US_WSREMS__REMSProgram__c = progObjList[0].Id;
        serviceObj.US_WSREMS__Requestor_Type__c ='Health Care Setting';
        serviceObj.US_WSREMS__StageName__c='Intake';
        serviceObj.RecordtypeId = serviceRectypeId;
        insertServiceObjList.add(serviceObj);
        
        US_WSREMS__REMS_Service_Summary__c prescServiceObj = new US_WSREMS__REMS_Service_Summary__c();
        prescServiceObj.US_WSREMS__Participant__c  = prescAcc.Id;
        prescServiceObj.US_WSREMS__REMSProgram__c = progObjList[0].Id;
        prescServiceObj.US_WSREMS__Requestor_Type__c ='Prescriber';
        prescServiceObj.US_WSREMS__StageName__c='Intake';
        prescServiceObj.RecordtypeId = serviceRectypeId;
        insertServiceObjList.add(prescServiceObj);
        insert insertServiceObjList;
        Test.StartTest();
        List<Case> insertCaseList = new List<Case>();
        Case caseObj = new case();
        caseObj.recordTypeId = caseRectypeId;
        caseObj.US_WSREMS__NPI__c = '1234567890';
        caseObj.US_WSREMS__HIN__c = 'HN12345';
        caseObj.US_WSREMS__DEA__c = 'DE1234567';
        caseObj.US_WSREMS__DEA_Status__c = 'Invalid';
        caseObj.US_WSREMS__NCPDP__c = '1234567';
        caseObj.US_WSREMS__HIN_Status__c = 'Invalid';
        caseObj.US_WSREMS__REMS_Program__c = progObjList[0].Id;
        caseObj.US_WSREMS__Incomplete_Reasons__c = '';
        caseObj.US_WSREMS__REMS_Service_Summary__c = serviceObj.Id;
        caseObj.US_WSREMS__Prescriber__c = prescAcc.Id;
        caseObj.HCPnotCertified__c = true;
        caseObj.US_WSREMS__Channel__c = '';
        caseObj.US_WSREMS__Product_Type__c = '';
        caseObj.US_WSREMS__Incomplete_Reasons__c = Label.Prescriber_Incomplete_Reason;
        insertCaseList.add(caseObj);
        
        Case presccaseObj = new case();
        presccaseObj.recordTypeId = prescCaseRectypeId;
        presccaseObj.US_WSREMS__NPI__c = '1234567890';
        presccaseObj.US_WSREMS__HIN__c = 'HN12345';
        presccaseObj.US_WSREMS__DEA__c = 'DE1234567';
        presccaseObj.US_WSREMS__DEA_Status__c = 'Invalid';
        presccaseObj.US_WSREMS__NCPDP__c = '1234567';
        presccaseObj.US_WSREMS__HIN_Status__c = 'Invalid';
        presccaseObj.US_WSREMS__REMS_Program__c = progObjList[0].Id;
        presccaseObj.US_WSREMS__Incomplete_Reasons__c = '';
        presccaseObj.US_WSREMS__REMS_Service_Summary__c = prescServiceObj.Id;
        presccaseObj.US_WSREMS__Channel__c = '';
        presccaseObj.US_WSREMS__Product_Type__c = '';
        insertCaseList.add(presccaseObj);
        Insert insertCaseList;
        
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__Prescriber__c = prescAcc.Id;
        affObj.US_WSREMS__Health_Care_Setting__c = hcsAcc.Id;
        affObj.US_WSREMS__REMSProgram__c = progObjList[0].Id;
        Insert affObj;
        
        prescAcc.US_WSREMS__Status__c = 'Certified';
        update prescAcc;
        system.assertEquals('Certified', prescAcc.US_WSREMS__Status__c);
        Test.StopTest();
    }
}//