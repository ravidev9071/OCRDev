/**
* @File Name          : SYN_RemsSummaryTrigger_HTest
* @Description        : This is a test class for SYN_RemsServiceSummaryTriggerHandler.
* @Trigger            : SYN_RemsServiceSummaryTrigger
* @Author             : Wilcosource
* @Modification Log   :
* Ver    Date               Developer                        Modification
* 2.0    03/29/2022         Dnyaneshwar Gothakade (Wilco)    New:Line 886-903: Added 'accountFieldUpdate_Test' method
**/

@isTest
public class SYN_RemsSummaryTrigger_HTest {
  /* public static testmethod void  testMethod1() {
        
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.REMS_Project_Code__c = 'BT6825';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;
        
        //Pharmacy user Account Creation
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
               // List<US_WSREMS__REMS_Program__c> remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);

             // Account A = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', true,pgrmObj.id );
        
        
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
        //serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Incomplete';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        
        
        
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
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
        caseObj.Pharmacy_Participant__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy__c = SYN_TestDataFactory.createPharmacyAccount('1234','1234567890',true,pgrmObj.Id).Id;
             
        insert caseObj;
        
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Complete';
        update serviceObj;
        
        
        System.debug(caseObj.Id+'Case ID '+caseObj.US_WSREMS__REMS_Service_Summary__c);
        
        
        
        
        SYN_RemsServiceSummaryTriggerHandler.retrieveRecTypeIdDeveloperName('Case');
        SYN_RemsServiceSummaryTriggerHandler.retrieveRecTypeDeveloperNameId('case');
    }*/
    public static testmethod void  testMethod2() {
        
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        String pharmacyPartcipantRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;
        
        //Pharmacy user Account Creation
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
        //Pharmacy participant Account Creation
        Account accPharmUserObj1= new Account();
        accPharmUserObj1.FirstName= 'Test';
        accPharmUserObj1.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj1.PersonEmail= 'abc@gmail.com';
        accPharmUserObj1.Phone='9685748572';
        accPharmUserObj1.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj1.RecordTypeId = pharmacyPartcipantRecordTypeId;
        insert accPharmUserObj1;
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Unsuccessful';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        
        
        
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPharmUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPharmUserObj.Phone;
        caseObj.US_WSREMS__Pharmacy_User__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy_User_ar__c = accPharmUserObj.Id;
        caseObj.Pharmacy_Participant__c = accPharmUserObj1.Id;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.Program_Record_Type_Control__c =pgrmObj.Name+'-Change_Authorized_Representative';
        insert caseObj;
        
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Successful';
        update serviceObj;
        
        
        System.debug(caseObj.Id+'Case ID '+caseObj.US_WSREMS__REMS_Service_Summary__c);
        
        
        
        
        SYN_RemsServiceSummaryTriggerHandler.retrieveRecTypeIdDeveloperName('Case');
        SYN_RemsServiceSummaryTriggerHandler.retrieveRecTypeDeveloperNameId('case');
    } 
    public static testmethod void  testMethod3() {
        
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        String pharmacyPartcipantRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
        String Prescribing_InstitutionRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution').getRecordTypeId();
        String PrescriberRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        String facilityRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Facility_Account').getRecordTypeId();
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;

          //Facility Account Creation
        Account accfacility = new Account();
        accfacility.Name = 'Test Pharmacy'; 
        accfacility.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accfacility.RecordTypeId = facilityRecordTypeId;      
        insert accfacility;
        
        //Pharmacy user Account Creation
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
        
        //Pharmacy Account Creation
        Account accPharmUserObj1 = new Account();
        accPharmUserObj1.Name = 'Test Pharmacy'; 
        accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj1.Phone='9685748572';
        accPharmUserObj1.FAx='9685748572';
        accPharmUserObj1.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmUserObj1.RecordTypeId = Prescribing_InstitutionRecordTypeId;      
        insert accPharmUserObj1;
        
        
        //Pharmacy participant Account Creation
        Account accPharmUserObj11= new Account();
        accPharmUserObj11.FirstName= 'Test';
        accPharmUserObj11.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj11.PersonEmail= 'abc@gmail.com';
        accPharmUserObj11.Phone='9685748572';
        accPharmUserObj11.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj11.RecordTypeId = PrescriberRecordTypeId;
        insert accPharmUserObj11;
        
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Participant__c = accPharmUserObj11.Id;
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Unsuccessful';
        serviceObj.recordTypeId = recordTypeId;
        
        insert serviceObj;
        
        
        
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPharmUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPharmUserObj.Phone;
        caseObj.US_WSREMS__Pharmacy_User__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy_User_ar__c = accPharmUserObj.Id;
        //   caseObj.Pharmacy_Participant__c = accPharmUserObj1.Id;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.US_WSREMS__Facility__c = accfacility.Id;
        caseObj.SYN_Prescriber__c = accPharmUserObj11.Id;
        caseObj.Status ='Complete';
        caseObj.Program_Record_Type_Control__c =pgrmObj.Name+'-Change_Authorized_Representative';
        insert caseObj;
        
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Successful';
        update serviceObj;
        
        System.debug(caseObj.Id+'Case ID '+caseObj.US_WSREMS__REMS_Service_Summary__c);
        
        
    }
    public static testmethod void  testMethod4() {
        
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        String recordTypePatientId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        String pharmacyPartcipantRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
        String Prescribing_InstitutionRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution').getRecordTypeId();
        String PrescriberRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        String facilityRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Facility_Account').getRecordTypeId();
        
        
        //Pharmacy user Account Creation
        Account accPatientUserObj = new Account();
        accPatientUserObj.FirstName= 'Test';
        accPatientUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPatientUserObj.PersonEmail= 'abc@gmail.com';
        accPatientUserObj.Phone='9685748572';
        accPatientUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPatientUserObj.RecordTypeId = recordTypePatientId;
        insert accPatientUserObj;
        
         Account accfacility = new Account();
        accfacility.Name = 'Test Pharmacy'; 
        accfacility.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accfacility.RecordTypeId = facilityRecordTypeId;      
        insert accfacility;
        
        //Pharmacy Account Creation
        Account accPharmUserObj1 = new Account();
        accPharmUserObj1.Name = 'Test Pharmacy'; 
        //   accPharmUserObj1.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj1.Phone='9685748572';
        accPharmUserObj1.FAx='9685748572';
        accPharmUserObj1.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmUserObj1.RecordTypeId = Prescribing_InstitutionRecordTypeId;      
        insert accPharmUserObj1;
        
        
        
        //Pharmacy participant Account Creation
        Account accPharmUserObj11= new Account();
        accPharmUserObj11.FirstName= 'Test';
        accPharmUserObj11.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj11.PersonEmail= 'abc@gmail.com';
        accPharmUserObj11.Phone='9685748572';
        accPharmUserObj11.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj11.RecordTypeId = PrescriberRecordTypeId;
        insert accPharmUserObj11;
        
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Patient';
        //  serviceObj.US_WSREMS__Participant__c = accPharmUserObj11.Id;
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Unsuccessful';
        serviceObj.recordTypeId = recordTypeId;
        
        insert serviceObj;
        
        
        
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPatientUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPatientUserObj.Phone;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.US_WSREMS__Facility__c = accfacility.Id;
        caseObj.SYN_Prescriber__c = accPharmUserObj11.Id;
        caseObj.US_WSREMS__Patient__c = accPatientUserObj.id;
        // caseObj.SYN_Prescriber__c
        caseObj.Status ='Complete';
        caseObj.Program_Record_Type_Control__c =pgrmObj.Name+'-Change_Authorized_Representative';
        insert caseObj;
        
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Successful';
        update serviceObj;
        System.debug(caseObj.Id+'Case ID '+caseObj.US_WSREMS__REMS_Service_Summary__c);
        
        
    } 
    public static testmethod void  testMethod5() {
        
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        String recordTypePatientId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String pharmacyPartcipantRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        String Prescribing_InstitutionRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution').getRecordTypeId();
        String PrescriberRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        
        //Pharmacy user Account Creation
        Account accPatientUserObj = new Account();
        accPatientUserObj.FirstName= 'Test';
        accPatientUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPatientUserObj.PersonEmail= 'abc@gmail.com';
        accPatientUserObj.Phone='9685748572';
        accPatientUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPatientUserObj.RecordTypeId = pharmacyPartcipantRecordTypeId;
        insert accPatientUserObj;
        
        
        //Pharmacy Account Creation
        Account accPharmUserObj1 = new Account();
        accPharmUserObj1.Name = 'Test Pharmacy'; 
        accPharmUserObj1.Phone='9685748572';
        accPharmUserObj1.FAx='9685748572';
        accPharmUserObj1.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmUserObj1.RecordTypeId = recordTypePharmacyId;      
        insert accPharmUserObj1;
        
        
        
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        //  serviceObj.US_WSREMS__Participant__c = accPharmUserObj11.Id;
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Unsuccessful';
        serviceObj.recordTypeId = recordTypeId;
        
        insert serviceObj;
        
        
        
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPatientUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPatientUserObj.Phone;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        // caseObj.US_WSREMS__Facility__c = accPharmUserObj1.Id;
        caseObj.SYN_Pharmacy__c = accPharmUserObj1.Id;
        caseObj.SYN_Authorized_Rep__c = accPatientUserObj.id;
        // caseObj.SYN_Prescriber__c
        caseObj.Status ='Complete';
        caseObj.Program_Record_Type_Control__c =pgrmObj.Name+'-Change_Authorized_Representative';
        insert caseObj;
        
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Successful';
        update serviceObj;
        System.debug(caseObj.Id+'Case ID '+caseObj.US_WSREMS__REMS_Service_Summary__c);
        
        
    } 
    public static testmethod void  testMethod6() {
        
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        String recordTypePatientId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String pharmacyPartcipantRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        String Prescribing_InstitutionRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution').getRecordTypeId();
        String PrescriberRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        
        
        
        Account accPharmUserObj12= new Account();
        accPharmUserObj12.FirstName= 'Test';
        accPharmUserObj12.LastName = 'Pharmacy User';
        accPharmUserObj12.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj12.PersonEmail= 'abc@gmail.com';
        accPharmUserObj12.Phone='9685748572';
        accPharmUserObj12.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj12.RecordTypeId = pharmacyPartcipantRecordTypeId;
        insert accPharmUserObj12;
        
        
        //Pharmacy user Account Creation
        Account accPatientUserObj = new Account();
        accPatientUserObj.FirstName= 'Test';
        accPatientUserObj.LastName = 'Pharmacy User';
        // accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPatientUserObj.PersonEmail= 'abc@gmail.com';
        accPatientUserObj.Phone='9685748572';
        accPatientUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPatientUserObj.RecordTypeId = pharmacyPartcipantRecordTypeId;
        insert accPatientUserObj;
        
        
        //Pharmacy Account Creation
        Account accPharmUserObj1 = new Account();
        accPharmUserObj1.Name = 'Test Pharmacy'; 
        accPharmUserObj1.Phone='9685748572';
        accPharmUserObj1.FAx='9685748572';
        accPharmUserObj1.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmUserObj1.RecordTypeId = recordTypePharmacyId;      
        insert accPharmUserObj1;
        
        
        
        
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get('Knowledge Assessment').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy Participant';
        //  serviceObj.US_WSREMS__Participant__c = accPharmUserObj11.Id;
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Successful';
        serviceObj.recordTypeId = recordTypeId;
        
        insert serviceObj;
        
        
        
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPatientUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPatientUserObj.Phone;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        // caseObj.US_WSREMS__Facility__c = accPharmUserObj1.Id;
        caseObj.SYN_Pharmacy__c = accPharmUserObj1.Id;
        caseObj.Pharmacy_Participant__c = accPharmUserObj12.id;
        //  caseObj.SYN_Authorized_Rep__c = accPharmUserObj12.id;
        // caseObj.SYN_Prescriber__c
        caseObj.Status ='Complete';
        //caseObj.US_WSREMS__Outcome__c='Pass';
        caseObj.Program_Record_Type_Control__c =pgrmObj.Name+'-Change_Authorized_Representative';
        insert caseObj;
        
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Successful';
        //update serviceObj;
        System.debug(caseObj.Id+'Case ID '+caseObj.US_WSREMS__REMS_Service_Summary__c);
        
    } 
    
    /*
     public static testmethod void  testMethod10() {
        
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        String recordTypePatientId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String pharmacyPartcipantRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        String Prescribing_InstitutionRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution').getRecordTypeId();
        String PrescriberRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        
        
        
        Account accPharmUserObj12= new Account();
        accPharmUserObj12.FirstName= 'Test';
        accPharmUserObj12.LastName = 'Pharmacy User';
        accPharmUserObj12.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj12.PersonEmail= 'abc@gmail.com';
        accPharmUserObj12.Phone='9685748572';
        accPharmUserObj12.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj12.RecordTypeId = pharmacyPartcipantRecordTypeId;
        insert accPharmUserObj12;
        
        
        //Pharmacy user Account Creation
        Account accPatientUserObj = new Account();
        accPatientUserObj.FirstName= 'Test';
        accPatientUserObj.LastName = 'Pharmacy User';
        accPatientUserObj.US_WSREMS__Status__c = 'Active'; 
        accPatientUserObj.US_WSREMS__Email__c= 'abc@gmail.com';
        accPatientUserObj.Phone='9685748572';
        accPatientUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPatientUserObj.RecordTypeId = pharmacyPartcipantRecordTypeId;
        insert accPatientUserObj;
        
        
        //Pharmacy Account Creation
        Account accPharmUserObj1 = new Account();
        accPharmUserObj1.Name = 'Test Pharmacy'; 
        accPharmUserObj1.Phone='9685748572';
        accPharmUserObj1.FAx='9685748572';
        accPharmUserObj1.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmUserObj1.RecordTypeId = recordTypePharmacyId;      
        insert accPharmUserObj1;
        
        
        
        
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get('Knowledge Assessment').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy/HCS Participant';
        serviceObj.US_WSREMS__Participant__c = accPatientUserObj.Id;
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Unsuccessful';
        serviceObj.recordTypeId = recordTypeId;
        
        insert serviceObj;
        
        
        
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Knowledge_Assessment_A').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.Pharmacy_Employee_Type__c='Pharmacy Staff';
        caseObj.US_WSREMS__Email__c= 'testABC@gmail.com';
        caseObj.US_WSREMS__Phone__c= accPatientUserObj.Phone;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        // caseObj.US_WSREMS__Facility__c = accPharmUserObj1.Id;
        caseObj.SYN_Pharmacy__c = accPharmUserObj1.Id;
        caseObj.Pharmacy_Participant__c = accPatientUserObj.id;
        //  caseObj.SYN_Authorized_Rep__c = accPharmUserObj12.id;
        // caseObj.SYN_Prescriber__c
        caseObj.US_WSREMS__Program_Picklist__c ='Sodium Oxybate REMS';
        caseObj.Status ='Complete';
        caseObj.US_WSREMS__Outcome__c='Pass';
        insert caseObj;
        
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Successful';
        update serviceObj;
        System.debug(caseObj.Id+'Case ID '+caseObj.US_WSREMS__REMS_Service_Summary__c);
        
    } 
    */
    
    Public static testMethod void accountFieldUpdate_Test() {
        
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummary(createPatientAccount.Id,programObj.Id);
        Case createPatientEnrollmentCase= SYN_TestDataUtility.createaPatientEnrollmentPatientCase(caseRecordTypeId, programObj.Id,'Test FirstName','Test LastName',objService.id,createPatientAccount.Id);
        
        Test.startTest();
        
        objService.US_WSREMS__Service_Outcome__c='Successful';
        objService.US_WSREMS__Status__c ='Closed';
        update objService;
        
        Test.stopTest();
     }
    Public static testMethod void TemplatePatientEnrolltest() {
        
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Sodium Oxybate REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummary(createPatientAccount.Id,programObj.Id);
        Case createPatientEnrollmentCase= SYN_TestDataUtility.createaPatientEnrollmentPatientCase(caseRecordTypeId, programObj.Id,'Test FirstName','Test LastName',objService.id,createPatientAccount.Id);

        Test.startTest();
        objService.US_WSREMS__Service_Outcome__c='Successful';
        objService.US_WSREMS__Status__c ='Closed';
        update objService;
        
        Test.stopTest();
     }
    Public static testMethod void TemplateDistributortest() {
        
        id recordTypeIdDistributor = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('SYN_Distributor_Enrollment').getRecordTypeId();
        
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Sodium Oxybate REMS','Active');
        
        Account distAcc = new Account();
        distAcc.Name = 'Test Pharmacy'; 
        distAcc.Phone='9685748572';
        distAcc.FAx='9685748572';
        distAcc.US_WSREMS__Email__c = 'aneesha@gmail.com';
        distAcc.US_WSREMS__REMS_Program__c =  programObj.Id;
        distAcc.RecordTypeId = recordTypeIdDistributor;      
        insert distAcc;
       
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Distributor';
        serviceObj.US_WSREMS__Participant__c = distAcc.Id;
        serviceObj.US_WSREMS__Status__c = 'Open';
        serviceObj.recordTypeId = recordTypeId;
        
        insert serviceObj;

        Test.startTest();
        serviceObj.US_WSREMS__Service_Outcome__c='Successful';
        serviceObj.US_WSREMS__Status__c ='Closed';
        update serviceObj;
        Test.stopTest();
     }
     @IsTest
    static void testEndAffiliation() {
        
       String recordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Prescriber_Affiliation').getRecordTypeId();

        // Create a test record
        US_WSREMS__Affiliation__c testAffiliation = new US_WSREMS__Affiliation__c();

        testAffiliation.US_WSREMS__End_Date__c = system.today();
        testAffiliation.US_WSREMS__isActive__c = false;
        insert testAffiliation;

        // Create a keyId to use in the method call
        Id keyId = testAffiliation.Id;

        // Call the method
        Test.startTest();
        SYN_RemsServiceSummaryTriggerHandler.endAffiliation(keyId, recordTypeId);
        Test.stopTest();

        // Retrieve the updated record
        US_WSREMS__Affiliation__c updatedAffiliation = [SELECT US_WSREMS__End_Date__c, US_WSREMS__isActive__c FROM US_WSREMS__Affiliation__c WHERE Id = :testAffiliation.Id];

        // Verify the changes
        System.assertEquals(System.today(), updatedAffiliation.US_WSREMS__End_Date__c, 'End Date should be today');
        System.assertEquals(false, updatedAffiliation.US_WSREMS__isActive__c, 'isActive should be false');
    }

    @IsTest
    static void testEndAffiliationOnDisEnroll() {
        // Create a test record
        US_WSREMS__Affiliation__c testAffiliation = new US_WSREMS__Affiliation__c();
        testAffiliation.US_WSREMS__End_Date__c = system.today();
        testAffiliation.US_WSREMS__isActive__c = false;
        insert testAffiliation;

        // Create a keyId to use in the method call
        Id keyId = testAffiliation.Id;

        // Call the method
        Test.startTest();
        SYN_RemsServiceSummaryTriggerHandler.endAffiliationOnDisEnroll(keyId);
        Test.stopTest();

        // Retrieve the updated record
        US_WSREMS__Affiliation__c updatedAffiliation = [SELECT US_WSREMS__End_Date__c, US_WSREMS__isActive__c FROM US_WSREMS__Affiliation__c WHERE Id = :testAffiliation.Id];

        // Verify the changes
        System.assertEquals(System.today(), updatedAffiliation.US_WSREMS__End_Date__c, 'End Date should be today');
        System.assertEquals(false, updatedAffiliation.US_WSREMS__isActive__c, 'isActive should be false');
    }
     @IsTest
    static void testCreateAffiliationRecords() {
        
        id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();
        
        // Create test data
        US_WSREMS__REMS_Program__c programId = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Account accountObj = new Account();
        accountObj.FirstName= 'Patient';
        accountObj.LastName = 'Account';
        accountObj.RecordTypeId = recordTypeIdPatient;
        accountObj.US_WSREMS__Channel__c  = 'fax';
        accountObj.Phone = '9089090909';
        accountObj.US_WSREMS__Status__c = 'Initiated';
        accountObj.US_WSREMS__Email__c  ='test@test.com';
        accountObj.US_WSREMS__REMS_Program__c = programId.Id;
        Insert accountObj;
        Account presAcc = SYN_TestDataFactory.createPrescriberAccountWithNPI(programId.Id,recordTypeIdPrescriber);
        US_WSREMS__REMS_Service_Summary__c enrollService = SYN_TestDataUtility.createRemsServiceSummary(accountObj.Id,programId.Id);
        Case enrollCase = SYN_TestDataFactory.createaPatientEnrollmentPatientCase(caseRecordTypeId, programId.Id,'Test FirstName','Test LastName',enrollService.id,accountObj.Id,presAcc.Id);
       
        // Call the method to be tested
        Test.startTest();
        
       
        
        enrollService.US_WSREMS__Status__c = 'Closed';
        enrollService.US_WSREMS__Path_Stage_Name__c ='Closed';
        enrollService.US_WSREMS__Service_Outcome__c = 'Successful';
        update enrollService;
        
        
       // SYN_RemsServiceSummaryTriggerHandler.createAffiliationRecords(enrollService.Id, oldServiceMap);
        Test.stopTest();

    }
    
    @IsTest
    public static void testCheckOpenTasks() {
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        // Create test data
        US_WSREMS__REMS_Service_Summary__c remss1 = new US_WSREMS__REMS_Service_Summary__c();
       // remss1.Name = 'Test REMS Service 1';
        remss1.US_WSREMS__Status__c = 'Closed';
        remss1.US_WSREMS__Service_Outcome__c = 'Successful';
        remss1.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        remss1.US_WSREMS__REMSProgram__c = programObj.Id; // Replace with valid Program Id
        
        US_WSREMS__REMS_Service_Summary__c remss2 = new US_WSREMS__REMS_Service_Summary__c();
       // remss2.Name = 'Test REMS Service 2';
        remss2.US_WSREMS__Status__c = 'Closed';
        remss2.US_WSREMS__Service_Outcome__c = 'Successful';
        remss2.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        remss2.US_WSREMS__REMSProgram__c = programObj.Id; // Replace with valid Program Id
        
        List<US_WSREMS__REMS_Service_Summary__c> remssList = new List<US_WSREMS__REMS_Service_Summary__c>{remss1, remss2};
        insert remssList;
        
        Task task1 = new Task();
        task1.WhatId = remss1.Id;
        task1.Status = 'In Progress';
        
        Task task2 = new Task();
        task2.WhatId = remss2.Id;
        task2.Status = 'Completed';
        
        List<Task> taskList = new List<Task>{task1, task2};
        insert taskList;
        
        // Call the method to be tested
        Test.startTest();
        SYN_RemsServiceSummaryTriggerHandler.checkOpenTasks(new Map<Id, US_WSREMS__REMS_Service_Summary__c>([SELECT Id, Name, US_WSREMS__Status__c, US_WSREMS__Service_Outcome__c, US_WSREMS__Requestor_Type__c, US_WSREMS__REMSProgram__c FROM US_WSREMS__REMS_Service_Summary__c]));
        Test.stopTest();
        
    }
   
    }