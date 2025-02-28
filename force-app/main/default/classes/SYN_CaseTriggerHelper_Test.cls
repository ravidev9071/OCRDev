/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-16-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SYN_CaseTriggerHelper_Test {
    @testSetup
    static void createTestData(){
        List<US_WSREMS__REMS_Program__c> remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);
        SYN_TestDataFactory.createProgramServiceConfig(true, remsProgramList[0].id);
        Id remsRTId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Participant_Enrollment').getRecordTypeId();
        
        US_WSREMS__REMS_Service_Summary__c remsServiceObject = SYN_TestDataFactory.createService(true, remsProgramList[0].Id, remsRTId);
        US_WSREMS__REMS_Service_Summary__c remsServiceObject1 = SYN_TestDataFactory.createService(true, remsProgramList[0].Id, remsRTId);
        US_WSREMS__REMS_Service_Summary__c remsServiceObject2 = SYN_TestDataFactory.createService(true, remsProgramList[0].Id, remsRTId);
        Account BAcc = SYN_TestDataFactory.createPharmacyAccount('1234476', '9087654321', true, remsProgramList[0].id );
        Account A = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', true, remsProgramList[0].id );
        Account PatientAcc = SYN_TestDataFactory.createPersonAccountforPatient('5648603246', 12345, '8987654322', true, remsProgramList[0].id );
        Account PatientAcc1 = SYN_TestDataFactory.createPersonAccountforPatient('5648603241', 12345, '8987654342', true, remsProgramList[0].id );
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Pre_Dispense').getRecordTypeId();
        Id rdaCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pre_Dispense').getRecordTypeId();
        /*  Case caseObj = new Case(RecordTypeId = caseRecordTypeId, Status = 'Draft', US_WSREMS__REMS_Service_Summary__c = remsServiceObject.id);
        insert caseObj; */
        Id CseRDARCTyId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();
        case testCase = new case(RecordTypeId = CseRDARCTyId,US_WSREMS__Program_Picklist__c='Sodium Oxybate REMS', US_WSREMS__Outcome__c = 'Approved', SYN_Prescriber__c = a.id, Status = 'Draft', X2_Patient_currently_disenrolled__c='Yes',X4_Received_dispense_of_oxybate_product__c = 'Yes', US_WSREMS__Pharmacy__c = BAcc.id, US_WSREMS__Prescription_Date__c = Date.today().addDays(1), US_WSREMS__Patient__c = PatientAcc.id, X3_Prescriber_currently_disenrolled__c='Yes',
                                 date_of_Fill__c = Date.today().addDays(15), SYN_Days_Supply__c = 91,US_WSREMS__REMS_Service_Summary__c = remsServiceObject.id);
        insert testCase;
        Case RDAcaseObj = new Case(RecordTypeId = caseRecordTypeId,Program_Record_Type_Control__c = remsProgramList[0].Name+'-PDA',US_WSREMS__Channel__c ='Phone', Status = 'Draft',SYN_Days_Supply__c = 91,X2_Patient_currently_disenrolled__c='Yes', X3_Prescriber_currently_disenrolled__c='Yes', US_WSREMS__Pharmacy__c = BAcc.id, 
                                   X4_Received_dispense_of_oxybate_product__c = 'Yes',US_WSREMS__Prescription_Date__c = Date.today().addDays(1), date_of_Fill__c =Date.today().addDays(15), US_WSREMS__Patient__c = PatientAcc1.id, US_WSREMS__REMS_Service_Summary__c = remsServiceObject2.id);
        insert RDAcaseObj;  
        
        Case RDAcaseObj1 = new Case(RecordTypeId = caseRecordTypeId,Program_Record_Type_Control__c = remsProgramList[0].Name+'-PDA',US_WSREMS__Channel__c ='Phone', Status = 'Draft',SYN_Days_Supply__c = 0,X2_Patient_currently_disenrolled__c='Yes', X3_Prescriber_currently_disenrolled__c='Yes', US_WSREMS__Prescriber__c = A.id,
                                    X4_Received_dispense_of_oxybate_product__c = 'Yes',US_WSREMS__Prescription_Date__c = Date.today().addDays(1), date_of_Fill__c =Date.today().addDays(1), US_WSREMS__REMS_Service_Summary__c = remsServiceObject1.id);
        insert RDAcaseObj1;

        //Create Affiliation
        String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = remsServiceObject.Id;
        affObj.US_WSREMS__REMSProgram__c = remsServiceObject.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = recordTypeAffId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = remsServiceObject.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = testCase.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = testCase.US_WSREMS__UserType__c;
        insert affObj;
        
        Test.startTest();
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        Id PrescribingrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Facility').getRecordTypeId();
        Account accountObj = SYN_TestDataUtility.createPrescribingInstitutionAccount(programObj.Id,PrescribingrecordTypeId);
        Id PrescriberCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        Case caseObj1 = SYN_TestDataUtility.createaNewCase(PrescriberCaseRecTypeId,'TestCaseFirstName','TestCaseLastName123','Cancelled',programObj.Id);
        Id PrescriberReEnrollmentCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_Reenrollment').getRecordTypeId();
        Case caseObj2 = SYN_TestDataUtility.createaNewCase(PrescriberReEnrollmentCaseRecTypeId,'TestCaseFirstName','TestCaseLastName123','Cancelled',programObj.Id);
        Id synOutPatientCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Outpatient_Pharmacy').getRecordTypeId();
        Case caseObj3 = SYN_TestDataUtility.createaNewCase(synOutPatientCaseRecTypeId,'TestCaseFirstName','TestCaseLastName123','Cancelled',programObj.Id);
		Id synOutReEnrollmentCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Outpatient_Pharmacy_Reenrollment').getRecordTypeId();
        Case caseObj4 = SYN_TestDataUtility.createaNewCase(synOutReEnrollmentCaseRecTypeId,'TestCaseFirstName','TestCaseLastName123','Cancelled',programObj.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void updateAccountTest(){
        Test.startTest();
        List<US_WSREMS__Field_Mapping_Config__mdt> fMapSerRecord = [SELECT Id, US_WSREMS__IsActive__c, US_WSREMS__Order__c, US_WSREMS__Request_Type__c, US_WSREMS__Source_Field__c, US_WSREMS__Source_Object__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c, NamespacePrefix  FROM US_WSREMS__Field_Mapping_Config__mdt WHERE  US_WSREMS__Source_Object__c = 'Case' 
                                                                    AND US_WSREMS__Target_Object__c ='Account' AND NamespacePrefix != 'US_WSREMS' AND US_WSREMS__IsActive__c = true LIMIT 1 ];
        system.debug('fMapSerRec++++'+fMapSerRecord);
        List<US_WSREMS__Field_Mapping_Config__mdt> fMapSerRec1 = [SELECT Id, US_WSREMS__IsActive__c, US_WSREMS__Order__c, US_WSREMS__Source_Field__c, US_WSREMS__Source_Object__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c, NamespacePrefix  FROM US_WSREMS__Field_Mapping_Config__mdt WHERE  US_WSREMS__Source_Object__c = 'Case' 
                                                                  AND US_WSREMS__Target_Object__c ='Account' AND NamespacePrefix != 'US_WSREMS' AND US_WSREMS__IsActive__c = true LIMIT 1 ];
        Id rdaCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();    
        Map<Id,Case> oldcseMap = new Map<Id,Case>([select id, RecordTypeId,SYN_Case_Id__c,Description,US_WSREMS__First_Name_ar__c,Ext_Secondary_Office__c,Email_Secondary_Office__c,Alternate_Contact__c,Sub_Status__c,Office_contact_name_Primary_Office__c,US_WSREMS__Status__c,
                                                   office_contact_phone_Secondary_Office__c,SYN_Validation_Date__c,City_Secondary_Office__c,Preferred_Contact_Method_Secondary_Offic__c,AccountId,Account_Name_Secondary_Office__c,State_Secondary_Office__c,Fax_Secondary_Office__c,Specialty__c,US_WSREMS__REMS_Office_Contact_Phone__c,US_WSREMS__REMS_Ext__c,Phone_Secondary_Office__c,Address_1_Secondary_Office__c,US_WSREMS__REMS_Zip_Code__c,SYN_Alternate_Phone__c,US_WSREMS__Channel__c,Address_2_Secondary_Office__c,Alternate_Contact_Name__c,US_WSREMS__Last_Name_ar__c,Email_address__c,Affiliated_hospital_Secondary_Office__c,Office_contact_name_Secondary_Office__c,
                                                   Status,US_WSREMS__Patient__c,US_WSREMS__Participant__c,SYN_Prescriber__c, US_WSREMS__Fax__c, US_WSREMS__Account_Type__c,SYN_Country__c,US_WSREMS__Last_Name__c,SYN_Ext__c,
                                                   US_WSREMS__Email__c,SYN_DEA_Validation__c, US_WSREMS__User_Type__c,US_WSREMS__NPI__c,US_WSREMS__SLN__c,US_WSREMS__REMS_Program__c,US_WSREMS__Middle_Name__c,US_WSREMS__DEA__c,US_WSREMS__Preferred_Contact_Method__c,
                                                   SYN_Zip_Code__c,SYN_Medical_specialty__c,US_WSREMS__State__c,US_WSREMS__Role__c,US_WSREMS__Address_Line_1__c,Professional_Designation__c,US_WSREMS__City__c,US_WSREMS__Address_Line_2__c,US_WSREMS__Investigated_Stakeholder_Name__c,
                                                   US_WSREMS__Phone__c,Affiliated_hospital__c,US_WSREMS__First_Name__c, US_WSREMS__REMS_Service_Summary__c, US_WSREMS__Outcome__c, US_WSREMS__Service_Requestor_Type__c,US_WSREMS__Prescriber__c,US_WSREMS__Pharmacy__c,
                                                   SYN_Days_Supply__c,X2_Patient_currently_disenrolled__c,X3_Prescriber_currently_disenrolled__c,US_WSREMS__Prescription_Date__c,date_of_Fill__c,SYN_Quantity__c,X1_Number_of_attempts__c,
                                                   X4_Received_dispense_of_oxybate_product__c,Specialty_Secondary_Office__c,X4a_What_was_the_most_recent_fill_date__c,X4b_Days_supply_of_last_dispance__c,US_WSREMS__REMS_Alternate_Phone__c,US_WSREMS__Facility__c,SLN_Status__c,NPI_Status__c,Office_Practice_Clinic_Name__c,Office_Practice_Clinic_Name1__c,Two_Factor_Authentication_Selection__c,Notifications__c  FROM Case Limit 1]); 
        
        //  Map<Id,Case> oldcseMap = new Map<Id,Case>([select id, RecordTypeId, Status, US_WSREMS__Patient__c,US_WSREMS__Participant__c,US_WSREMS__REMS_Service_Summary__c, US_WSREMS__Outcome__c, US_WSREMS__Service_Requestor_Type__c FROM Case Limit 1]);
        
        Map<Id,Case> newCseMap = new Map<Id, Case>();
        Case cs = oldcseMap.values();
        cs.US_WSREMS__Outcome__c = 'Approved';
        update cs;
        newCseMap.put(cs.id, cs);
        Set<id> CaseIdSet = new Set<id>();
        List<Case> caseList = new List<Case>();
        for (Case CSE : newCseMap.values()){
            CaseIdSet.add(CSE.Id);
            caseList.add(CSE);
        }
        list<Case> caseList2 = [select id, RecordTypeId, Status, US_WSREMS__Patient__c,US_WSREMS__Participant__c,SYN_Prescriber__c, US_WSREMS__Fax__c, US_WSREMS__Account_Type__c,SYN_Country__c,US_WSREMS__Last_Name__c,SYN_Ext__c,
                                US_WSREMS__Email__c,SYN_Medical_specialty__c,SYN_DEA_Validation__c,Affiliated_hospital__c, US_WSREMS__User_Type__c,US_WSREMS__NPI__c,US_WSREMS__SLN__c,US_WSREMS__REMS_Program__c,US_WSREMS__Middle_Name__c,US_WSREMS__DEA__c,US_WSREMS__Preferred_Contact_Method__c,SYN_Case_Id__c,
                                SYN_Zip_Code__c,US_WSREMS__State__c,Description,US_WSREMS__First_Name_ar__c,Ext_Secondary_Office__c,Specialty_Secondary_Office__c,Sub_Status__c,Email_Secondary_Office__c,Office_contact_name_Primary_Office__c,Alternate_Contact__c,US_WSREMS__Role__c,US_WSREMS__Address_Line_1__c,Professional_Designation__c,US_WSREMS__City__c,US_WSREMS__Address_Line_2__c,
                                US_WSREMS__Phone__c,US_WSREMS__First_Name__c, US_WSREMS__REMS_Service_Summary__c, US_WSREMS__Outcome__c, US_WSREMS__Service_Requestor_Type__c,US_WSREMS__Prescriber__c,US_WSREMS__Pharmacy__c,
                                SYN_Days_Supply__c,X2_Patient_currently_disenrolled__c,X3_Prescriber_currently_disenrolled__c,US_WSREMS__Prescription_Date__c,date_of_Fill__c,SYN_Quantity__c,X1_Number_of_attempts__c,
                                X4_Received_dispense_of_oxybate_product__c,X4a_What_was_the_most_recent_fill_date__c,X4b_Days_supply_of_last_dispance__c,US_WSREMS__REMS_Alternate_Phone__c,US_WSREMS__Facility__c,SLN_Status__c,NPI_Status__c,Two_Factor_Authentication_Selection__c,Notifications__c  FROM Case];
        SYN_CaseTriggerHelper.updateAccount(newCseMap, oldcseMap, CaseIdSet);
        SYN_CaseTriggerHelper.RDACaseValidation(caseList);
        SYN_CaseTriggerHelper.RDACaseValidation(caseList2);
        // String str = '08/22/2021';
        //Date d = '08/22/2022';
        //Date mydate = Date.parse(str);
        SYN_CaseTriggerHelper.monthsBetween(System.today(),System.today()-90);
       // System.assertEquals(integer.valueOf('-3'),SYN_CaseTriggerHelper.monthsBetween(System.today(),System.today()-80));
        //  SYN_CaseTriggerHelper.monthsUntillToday(System.today());
        
        //  System.assertEquals(expected, actual);
        Map<string,List<Account>> accountMap = new Map<string,List<Account>>();
        for(Account acc : [SELECT Name, Description FROM Account LIMIT 100]){
            if(accountMap.containsKey(acc.Name)){
                accountMap.get(acc.Name).add(acc);
            } else {
                accountMap.put(acc.Id, new List<Account>{acc});
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void updateAccountTest1(){  
        Test.startTest();
        //set<id> sbcset=new set<id>(preseriberRemsServiceIds);
        set<id> preseriberRemsServiceIds=new set<id>();
        preseriberRemsServiceIds.add([select id,US_WSREMS__Status__c,US_WSREMS__Service_Outcome__c,US_WSREMS__Path_Stage_Name__c,US_WSREMS__StageName__c from US_WSREMS__REMS_Service_Summary__c limit 1].Id);
        SYN_CaseTriggerHelper.updatePortalREMSServiceStatus(preseriberRemsServiceIds);
        US_WSREMS__REMS_Service_Summary__c remSum = [select id,US_WSREMS__Status__c,US_WSREMS__Service_Outcome__c,US_WSREMS__Path_Stage_Name__c,US_WSREMS__StageName__c from US_WSREMS__REMS_Service_Summary__c limit 1];
        //System.assertEquals('Closed', remSum.US_WSREMS__Status__c);
        Test.stopTest();
    }
    
    @isTest
    static void updateAccountTest2(){  
        Test.startTest();
        //set<id> sbcset=new set<id>(prescriberAccountIds);
        set<id> prescriberAccountIds=new set<id>();
        US_WSREMS__REMS_Program__c programobj = [select id from US_WSREMS__REMS_Program__c where name='Sodium Oxybate REMS' limit 1];
        prescriberAccountIds.add([select id,US_WSREMS__Status__c from Account where US_WSREMS__REMS_Program__c=:programobj.Id limit 1].Id);
        SYN_CaseTriggerHelper.updatePortalAccountStatus(prescriberAccountIds);
        Account serviceSumm = [select id,US_WSREMS__Status__c from Account where US_WSREMS__REMS_Program__c=:programobj.Id limit 1];
        System.assertEquals('Certified',serviceSumm.US_WSREMS__Status__c);
        Test.stopTest();
    }
    
    @isTest
    static void updateAccountTest5(){
        List<US_WSREMS__Field_Mapping_Config__mdt> fMapSerRecord = [SELECT Id, US_WSREMS__IsActive__c, US_WSREMS__Order__c, US_WSREMS__Request_Type__c, US_WSREMS__Source_Field__c, US_WSREMS__Source_Object__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c, NamespacePrefix  FROM US_WSREMS__Field_Mapping_Config__mdt WHERE  US_WSREMS__Source_Object__c = 'Case' 
                                                                    AND US_WSREMS__Target_Object__c ='Account' AND NamespacePrefix != 'US_WSREMS' AND US_WSREMS__IsActive__c = true LIMIT 1 ];
        system.debug('fMapSerRec++++'+fMapSerRecord);
        List<US_WSREMS__Field_Mapping_Config__mdt> fMapSerRec1 = [SELECT Id, US_WSREMS__IsActive__c, US_WSREMS__Order__c, US_WSREMS__Source_Field__c, US_WSREMS__Source_Object__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c, NamespacePrefix  FROM US_WSREMS__Field_Mapping_Config__mdt WHERE  US_WSREMS__Source_Object__c = 'Case' 
                                                                  AND US_WSREMS__Target_Object__c ='Account' AND NamespacePrefix != 'US_WSREMS' AND US_WSREMS__IsActive__c = true LIMIT 1 ];
        
        List<Account> acc = [select id,name from account limit 1];
        Id PrescribingrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Facility').getRecordTypeId();
        Account accountObj = [select id,recordTypeId from account where recordTypeId =:PrescribingrecordTypeId ];
        
        List<Id> caseRecordTypeId = new List<Id>();
        Id PrescriberCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        caseRecordTypeId.add(PrescriberCaseRecTypeId);
        Id synOutReEnrollmentCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Outpatient_Pharmacy_Reenrollment').getRecordTypeId();
        caseRecordTypeId.add(synOutReEnrollmentCaseRecTypeId);
        Id synOutPAtientCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Outpatient_Pharmacy').getRecordTypeId();
        caseRecordTypeId.add(synOutPAtientCaseRecTypeId);
        Id PrescriberReEnrollmentCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Prescriber Reenrollment').getRecordTypeId();
        caseRecordTypeId.add(PrescriberReEnrollmentCaseRecTypeId);
        
        
        Id rdaCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();    
        Map<Id,Case> oldcseMap = new Map<Id,Case>([select id, RecordTypeId,SYN_Case_Id__c,Description,US_WSREMS__First_Name_ar__c,Ext_Secondary_Office__c,Email_Secondary_Office__c,Alternate_Contact__c,Sub_Status__c,Office_contact_name_Primary_Office__c,US_WSREMS__Status__c,US_WSREMS__DOB__c,SLN_Status__c,
                                                   office_contact_phone_Secondary_Office__c,SYN_Validation_Date__c,City_Secondary_Office__c,Preferred_Contact_Method_Secondary_Offic__c,AccountId,Account_Name_Secondary_Office__c,State_Secondary_Office__c,Fax_Secondary_Office__c,Specialty__c,US_WSREMS__REMS_Office_Contact_Phone__c,US_WSREMS__REMS_Ext__c,Phone_Secondary_Office__c,Address_1_Secondary_Office__c,US_WSREMS__REMS_Zip_Code__c,SYN_Alternate_Phone__c,US_WSREMS__Channel__c,Address_2_Secondary_Office__c,Alternate_Contact_Name__c,US_WSREMS__Last_Name_ar__c,Email_address__c,Affiliated_hospital_Secondary_Office__c,Office_contact_name_Secondary_Office__c,
                                                   Status,US_WSREMS__Patient__c,US_WSREMS__Participant__c,SYN_Prescriber__c, US_WSREMS__Fax__c, US_WSREMS__Account_Type__c,SYN_Country__c,US_WSREMS__Last_Name__c,SYN_Ext__c,
                                                   US_WSREMS__Email__c,SYN_DEA_Validation__c, US_WSREMS__User_Type__c,US_WSREMS__NPI__c,US_WSREMS__SLN__c,US_WSREMS__REMS_Program__c,US_WSREMS__Middle_Name__c,US_WSREMS__DEA__c,US_WSREMS__Preferred_Contact_Method__c,
                                                   SYN_Zip_Code__c,NPI_Status__c,US_WSREMS__State__c,US_WSREMS__Role__c,US_WSREMS__Address_Line_1__c,Professional_Designation__c,US_WSREMS__City__c,US_WSREMS__Address_Line_2__c,
                                                   US_WSREMS__Phone__c,Affiliated_hospital__c,US_WSREMS__First_Name__c, US_WSREMS__REMS_Service_Summary__c, US_WSREMS__Outcome__c, US_WSREMS__Service_Requestor_Type__c,US_WSREMS__Prescriber__c,US_WSREMS__Pharmacy__c,
                                                   SYN_Days_Supply__c,X2_Patient_currently_disenrolled__c,X3_Prescriber_currently_disenrolled__c,US_WSREMS__Prescription_Date__c,date_of_Fill__c,SYN_Quantity__c,X1_Number_of_attempts__c,
                                                   X4_Received_dispense_of_oxybate_product__c,SYN_Pharmacy__c,SYN_Authorized_Rep__c,Specialty_Secondary_Office__c,X4a_What_was_the_most_recent_fill_date__c,X4b_Days_supply_of_last_dispance__c,US_WSREMS__REMS_Alternate_Phone__c,US_WSREMS__Facility__c,US_WSREMS__Program_Picklist__c FROM Case where recordTypeId IN:caseRecordTypeId]); 
        
        Map<Id,Case> newCseMap = new Map<Id, Case>();
        List<Case> caseUpdate = new List<Case>();
        for(Case cs : oldcseMap.values()){
            cs.US_WSREMS__Program_Picklist__c = 'Macitentan REMS';
            cs.SYN_Prescriber__c = acc[0].Id;
            cs.US_WSREMS__Patient__c = acc[0].Id;
            cs.US_WSREMS__Facility__c = acc[0].Id;
            cs.Account_Name_Secondary_Office__c = acc[0].Id;
            cs.US_WSREMS__Facility__c = accountObj.Id;
            cs.SYN_Pharmacy__c = acc[0].Id;
            cs.SYN_Authorized_Rep__c = acc[0].Id;
            caseUpdate.add(cs);
        }
        Test.startTest();
//try {
        update caseUpdate;
/*} catch(Exception e) {
            System.assert(e.getMessage().contains('Attempt to de-reference a null object'));
        }*/
        //newCseMap.put(cs.id, cs);
        Set<id> CaseIdSet = new Set<id>();
        List<Case> caseList = new List<Case>();
        for (Case CSE : oldcseMap.values()){
            CaseIdSet.add(CSE.Id);
            caseList.add(CSE);
        }
        US_WSREMS__Affiliation__c Beforeaffus = [Select id,US_WSREMS__Prescriber__c,RecordTypeId from US_WSREMS__Affiliation__c ];
        SYN_CaseTriggerHelper.AffiliationsbyCase(caseList);
        US_WSREMS__Affiliation__c Afteraffus = [Select id,US_WSREMS__Prescriber__c,RecordTypeId from US_WSREMS__Affiliation__c ];
         System.assertEquals(Beforeaffus.RecordTypeId, Afteraffus.RecordTypeId);
        Test.stopTest();
    }
       @isTest
    static void affiliationTest(){
        List<US_WSREMS__Affiliation__c> useraff = [select id,recordTypeId,US_WSREMS__End_Date__c,US_WSREMS__isActive__c,US_WSREMS__Start_Date__c from US_WSREMS__Affiliation__c limit 1];
        Map<Id, List<US_WSREMS__Affiliation__c>> userAffiliation = new Map<Id, List<US_WSREMS__Affiliation__c>>();
        userAffiliation.put(useraff[0].Id,useraff);
        Test.startTest();
        SYN_CaseTriggerHelper.endAffiliation(useraff[0].Id,useraff[0].recordTypeId,userAffiliation,'method');
        SYN_CaseTriggerHelper.reEnrollAffiliation(useraff[0],useraff[0]);
        US_WSREMS__Affiliation__c aff = [select id,recordTypeId,US_WSREMS__End_Date__c,US_WSREMS__isActive__c,US_WSREMS__Start_Date__c from US_WSREMS__Affiliation__c limit 1];
        system.assertEquals(System.today(), aff.US_WSREMS__Start_Date__c);
        Test.stopTest();
    }

    @isTest
    static void SYN_AffiliationHandler_TCoverage(){
       Test.startTest();
       Id patientId = [select id from account where recordtype.developername = 'Patient' limit 1 ].id;
       Id prescriberId = [select id from account where recordtype.developername = 'Prescriber' limit 1 ].id;
       Id programId = [select id from US_WSREMS__REMS_Program__c limit 1 ].id;
       Id serviceId = [select id from US_WSREMS__REMS_Service_Summary__c limit 1].id;
       
        SYN_AffiliationHandler.createPatientAndPresAffil(patientId, prescriberId, programId,serviceId );
        Test.stopTest(); 
    }

	@isTest
        static void patientPregnancyRDACase_Test() {
        id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id recordTypeIdPharmacy = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        id casePDARecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();
        id recordTypeIdREMSService = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Pre_Dispense_Authorization').getRecordTypeId();
        List<case> caseRDAList = New List<case>();
        Set<Id> accountIds = new Set<Id>();
        US_WSREMS__REMS_Program__c programObj = [Select Id,Name from US_WSREMS__REMS_Program__c where Name='Macitentan REMS' Limit 1];
        US_WSREMS__Program_Users__c programUser = SYN_TestDataUtility.createProgramUser(UserInfo.getUserId(),programObj.id);
        Test.StartTest();   
        Account prescAccount = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        Account patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
        Account pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy);
        Account pharmCParticipanAccount = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,recordTypeIdPharmacyParticipant);
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c(US_WSREMS__REMSProgram__c = programObj.id,US_WSREMS__Requestor_Type__c = 'Pharmacy',US_WSREMS__Participant__c = pharmCAccount.id, recordTypeId = recordTypeIdREMSService);
        Insert serviceObj;
        US_WSREMS__Affiliation__c createAffiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmCParticipanAccount.Id,pharmCAccount.Id);
        Case caseObjNPI = SYN_TestDataUtility.createaRDACase(casePDARecordTypeId,programObj.id,prescAccount,patientAccount,pharmCAccount,pharmCParticipanAccount,serviceObj);
        US_WSREMS__Shipping_and_Tracking__c cs = SYN_TestDataUtility.createShippingAndTrackingRecordForRDACase(caseObjNPI.Id,patientAccount.Id);
        caseRDAList.add(caseObjNPI);
        accountIds.add(patientAccount.Id);
            // Covering Code Coverage for patientPregnancyRDACase
            SYN_CaseTriggerHelper.patientPregnancyRDACase(caseRDAList);
            // Covering Code Coverage for patientCounsellingRDACase
            SYN_CaseTriggerHelper.patientCounsellingRDACase(caseRDAList);
            // Covering Code Coverage for updatePortalAccountStatusToDisenrolled
            SYN_CaseTriggerHelper.updatePortalAccountStatusToDisenrolled(accountIds);
        Test.StopTest();
        
    }
    
    
}