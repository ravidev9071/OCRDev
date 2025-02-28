/**
* @File Name          : SYN_CaseTriggerHanlder_Test.cls
* @Description        : This is a test class for SYN_CaseTriggerHanlder.
* @Trigger			  : SYN_CaseTrigger
* @Class    	      : SYN_CaseTriggerHanlder
* @Author 			  : Wilcosource
* @Modification Log   :
* Ver       Date            Developer      		             Modification
* 1.0    02/22/2022        Chaitanya Nandamuri (Wilco)     Initial Implementation (Case Status Automation FrameWork)
* 2.0    03/29/2022        Chaitanya Nandamuri (Wilco)     CaseStatusComplete Method
* 3.0    30/06/2022        Aneesha Shaik (Wilco)           SYN_AppLiteralsTest Method
* 3.0    30/06/2022        Aneesha Shaik (Wilco)           SYN_UtilityclsTest Method
* 4.0    30/01/2024        Dnyaneshwar Gothakade(wilco)    updateChannelonAccountFromCaseTest
**/
@isTest()
public class SYN_CaseTriggerHanlder_Test {
    public static id RemsRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId();
   @testsetup
    static void createTestData(){

        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('SYN_Patient_Person_Account').getRecordTypeId();
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Sodium Oxybate REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        Insert programObj;

        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = RemsRecordTypeId;
        Insert serviceObj;

        Case caseObj = new Case(RecordTypeId = caseRecordTypeId,Program_Record_Type_Control__c = programObj.Name+'-SYN_Patient_Person_Account',US_WSREMS__Channel__c ='Phone', Status = 'Draft', US_WSREMS__REMS_Service_Summary__c = serviceObj.id,US_WSREMS__Program_Picklist__c='Sodium Oxybate REMS',US_WSREMS__DOB__c=date.Today()-900);        insert caseObj;

        caseObj.US_WSREMS__Outcome__c = 'Approved';
        update caseObj;
        US_WSREMS__Field_Mapping_Config__mdt fmcmdt = new US_WSREMS__Field_Mapping_Config__mdt(US_WSREMS__Source_Object__c = 'Case', US_WSREMS__Target_Object__c = 'Account', US_WSREMS__IsActive__c = true );
     /*  US_WSREMS__Field_Mapping_Config__mdt fMapSerRec : [SELECT Id, US_WSREMS__IsActive__c, US_WSREMS__Order__c, US_WSREMS__Request_Type__c, US_WSREMS__Source_Field__c, US_WSREMS__Source_Object__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c, NamespacePrefix  FROM
                                                                US_WSREMS__Field_Mapping_Config__mdt WHERE  US_WSREMS__Source_Object__c =:  SYN_Utilitycls.CASE_OBJECT
                                                                AND US_WSREMS__Target_Object__c =: SYN_Utilitycls.ACCOUNT_OBJECT AND NamespacePrefix != 'US_WSREMS' AND US_WSREMS__IsActive__c = true ] ;*/
     //   insert fmcmdt;

    }

  @isTest
    static void testCaseStatus(){
        List<US_WSREMS__REMS_Program__c> remsProgramList = [SELECT Id, Name FROM US_WSREMS__REMS_Program__c WHERE Name = 'Sodium Oxybate REMS' LIMIT 1];
        List<US_WSREMS__REMS_Service_Summary__c> remsServiceList = [SELECT Id, Name FROM US_WSREMS__REMS_Service_Summary__c WHERE RecordTypeId =: RemsRecordTypeId LIMIT 1];

        Test.startTest();
        List<case> caseObjlst = [select id , status from case where US_WSREMS__REMS_Service_Summary__c In : remsServiceList ];


        List<US_WSREMS__Field_Mapping_Config__mdt> fMapSerRec = [SELECT Id, US_WSREMS__IsActive__c, US_WSREMS__Order__c, US_WSREMS__Request_Type__c, US_WSREMS__Source_Field__c, US_WSREMS__Source_Object__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c, NamespacePrefix  FROM                                                              US_WSREMS__Field_Mapping_Config__mdt WHERE  US_WSREMS__Source_Object__c = 'Case'
                                                                 AND US_WSREMS__Target_Object__c ='Account' AND NamespacePrefix != 'US_WSREMS' AND US_WSREMS__IsActive__c = true];
        system.debug('fMapSerRec++++'+fMapSerRec);

       // caseObjlst[0].Status = 'Complete';
        try{
            Insert caseObjlst;

        caseObjlst[0].Status = 'Complete';
            update  caseObjlst;

        }catch(Exception E){
           // system.assert(E.getMessage().contains('Please complete all required fields in order to complete certification'));
           //
        }

        Test.stopTest();

    }

    @isTest
    static void CaseStatusComplete(){
        List<US_WSREMS__REMS_Program__c> remsProgramList = [SELECT Id, Name FROM US_WSREMS__REMS_Program__c WHERE Name = 'Sodium Oxybate REMS' LIMIT 1];
        id RemsRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Participant_Account_Creation').getRecordTypeId();
        id remsRectypeId =  Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_Person_Account').getRecordTypeId();

     Account PIacc = SYN_TestDataFactory.createBusinessAccount('5679899','9876587111',false,remsProgramList[0].id);
        PIacc.US_WSREMS__REMS_Program__c  = remsProgramList[0].id;
        insert PIacc ;

        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = remsProgramList[0].id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = RemsRecordTypeId;
        Insert serviceObj;

        serviceObj.US_WSREMS__Status__c ='Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Successful';
        serviceObj.recordtypeId = remsRectypeId;
        update serviceObj;
        Test.startTest();

        Case caseObjlst = new case();
        caseObjlst.US_WSREMS__Program_Picklist__c='Sodium Oxybate REMS';
        caseObjlst.US_WSREMS__Phone__c = '9876543210';
        caseObjlst.US_WSREMS__Fax__c='4802223561';
        caseObjlst.RecordTypeId = caseRecordTypeId;
        caseObjlst.US_WSREMS__REMS_Service_Summary__c = serviceObj.id;
        caseObjlst.US_WSREMS__Participant__c = PIacc.id;
         caseObjlst.US_WSREMS__Call_Notes__c = 'test';
        caseObjlst.US_WSREMS__Call_Outcome__c = 'Call Back';
        caseObjlst.US_WSREMS__Call_Outcome_Reason__c = 'Holiday';
        caseObjlst.US_WSREMS__Outcome__c='Approved';
         caseObjlst.status = 'New';
        caseObjlst.Pharmacy_Participant__c = PIacc.id;
        caseObjlst.Program_Record_Type_Control__c = remsProgramList[0].Name+'-Prescriber_Person_Account';
        Insert caseObjlst;

        caseObjlst.Status = 'Complete';
        update caseObjlst;

        system.assertEquals([select US_WSREMS__Path_Stage_Name__c  from US_WSREMS__REMS_Service_Summary__c where recordTypeId =:RemsRecordTypeId limit 1 ][0].US_WSREMS__Path_Stage_Name__c , 'Closed');


            Test.stopTest();



    }

    @isTest
    static void SLNNullvalidationBeforeInsert_Test(){
        List<US_WSREMS__REMS_Program__c> remsProgramList = [SELECT Id, Name FROM US_WSREMS__REMS_Program__c WHERE Name = 'Sodium Oxybate REMS' LIMIT 1];
        id RemsRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Participant_Account_Creation').getRecordTypeId();
      //  id remsRectypeId =  Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_Person_Account').getRecordTypeId();

     Account PIacc = SYN_TestDataFactory.createBusinessAccount('5679899','9876587111',false,remsProgramList[0].id);
        PIacc.US_WSREMS__REMS_Program__c  = remsProgramList[0].id;
        insert PIacc ;

        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = remsProgramList[0].id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = RemsRecordTypeId;
        Insert serviceObj;

        serviceObj.US_WSREMS__Status__c ='Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Successful';
        serviceObj.recordtypeId = RemsRecordTypeId;
        update serviceObj;
        Test.startTest();

        Case caseObjlst = new case();
        caseObjlst.US_WSREMS__Program_Picklist__c='Sodium Oxybate REMS';
        caseObjlst.US_WSREMS__Phone__c = '9876543210';
        caseObjlst.US_WSREMS__Fax__c='4802223561';
        caseObjlst.RecordTypeId = caseRecordTypeId;
        caseObjlst.US_WSREMS__REMS_Service_Summary__c = serviceObj.id;
        caseObjlst.US_WSREMS__Participant__c = PIacc.id;
         caseObjlst.US_WSREMS__Call_Notes__c = 'test';
        caseObjlst.US_WSREMS__Call_Outcome__c = 'Call Back';
        caseObjlst.US_WSREMS__Call_Outcome_Reason__c = 'Holiday';
        caseObjlst.Pharmacy_Participant__c = PIacc.id;
        caseObjlst.Program_Record_Type_Control__c = remsProgramList[0].Name+'-Prescriber_Person_Account';
        Insert caseObjlst;

        Test.stopTest();

    }
    @isTest
    static void SYN_AppLiteralsTest(){

        Test.startTest();
       // system.assertEquals([select US_WSREMS__Path_Stage_Name__c  from US_WSREMS__REMS_Service_Summary__c where recordTypeId =:RemsRecordTypeId limit 1 ][0].US_WSREMS__Path_Stage_Name__c , 'Closed');
           //SYN_AppLiterals
            SYN_AppLiterals controller = new SYN_AppLiterals() ;

            Test.stopTest();

}
      @isTest
    static void SYN_UtilityclsTest(){

        Test.startTest();

        //SYN_Utilitycls
         Map<String,Id> result = SYN_Utilitycls.retrieveRecTypeNameId(SYN_AppLiterals.SERVICE_SUMMARY_OBJECT);
         System.assertEquals(False, result.containsKey('Master'));

            Test.stopTest();
}
  /*  @isTest
    static void SYN_DOBValidationTest(){
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();
        id caseRiskManagementRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
        String strRecordTypeId = [Select Id From RecordType Where SobjectType ='Account' and Name ='Prescriber'].Id;
        String strRecordTypeIdPat = [Select Id From RecordType Where SobjectType ='Account' and Name ='Patient'].Id;

        US_WSREMS__REMS_Program__c programObj = [SELECT ID,Name FROM US_WSREMS__REMS_Program__c WHERE Name =: 'Sodium Oxybate REMS' limit 1 ];

        Account actobj = new Account();
        actobj.LastName='testLN';
        actobj.FirstName='testFN';
        actobj.phone = '8888587858';
        actobj.RecordTypeId =strRecordTypeId;
        actobj.US_WSREMS__REMS_Program__c =programObj.id;
        insert actobj;

        Account actobjPat = new Account();
        actobjPat.LastName='testLNPt';
        actobjPat.FirstName='testFNPT';
        actobjPat.phone = '8888587858';
        actobjPat.RecordTypeId =strRecordTypeIdPat;
        actobjPat.US_WSREMS__REMS_Program__c =programObj.id;
        insert actobjPat;

        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = RemsRecordTypeId;
        Insert serviceObj;

        Case caseObj = new Case(RecordTypeId = caseRecordTypeId, Status = 'Draft', US_WSREMS__REMS_Service_Summary__c = serviceObj.id,
                                US_WSREMS__DOB__c=null,RDA_Authorization_Code__c='8uyu87u78',SYN_Prescriber__c=actobj.Id,US_WSREMS__Patient__c=actobj.Id);
        insert caseObj;

    } */

    @isTest
    static void SYN_DOBValidationTestPCCL(){
        id pccRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Patient_Counseling_Checklist').getRecordTypeId();
        String strRecordTypeId = [Select Id From RecordType Where SobjectType ='Account' and Name ='Prescriber'].Id;
        String strRecordTypeIdPat = [Select Id From RecordType Where SobjectType ='Account' and Name ='Patient'].Id;

        US_WSREMS__REMS_Program__c programObj = [SELECT ID,Name FROM US_WSREMS__REMS_Program__c WHERE Name =: 'Sodium Oxybate REMS' limit 1 ];

        Account actobj = new Account();
        actobj.LastName='testLNPCCL';
        actobj.FirstName='FN';
        actobj.phone = '8888587858';
        actobj.RecordTypeId =strRecordTypeId;
        actobj.US_WSREMS__REMS_Program__c =programObj.id;
        insert actobj;

        Account actobjPat = new Account();
        actobjPat.LastName='testLNPt-PCCL';
        actobjPat.FirstName='testFNPT';
        actobjPat.phone = '8888587858';
        actobjPat.RecordTypeId =strRecordTypeIdPat;
        actobjPat.US_WSREMS__REMS_Program__c =programObj.id;
        insert actobjPat;

        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
       // serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = RemsRecordTypeId;
        Insert serviceObj;

        Case caseObj = new Case(RecordTypeId = pccRecordTypeId,Program_Record_Type_Control__c = programObj.Name+'-Patient_Counseling_Checklist', Status = 'Draft', US_WSREMS__REMS_Service_Summary__c = serviceObj.id,SYN_Please_select_one_of_the_following__c='New',
                                US_WSREMS__DOB__c=null,RDA_Authorization_Code__c='8uyu87u78',SYN_Prescriber__c=actobj.Id,US_WSREMS__Patient__c=actobj.Id);
        insert caseObj;

    }

   /*  @isTest
    static void SYN_DOBValidationTest1(){
      //  id caseRiskManagementRecordTypeId = Schema.SObjcreateCustomValidationMapectType.case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();//BT6825-46
           id pccRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Patient_Counseling_Checklist').getRecordTypeId();//BT6825-43

        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();
        id caseRiskManagementRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
        String strRecordTypeId = [Select Id From RecordType Where SobjectType ='Account' and Name ='Prescriber'].Id;
        String strRecordTypeIdPat = [Select Id From RecordType Where SobjectType ='Account' and Name ='Patient'].Id;

        US_WSREMS__REMS_Program__c programObj = [SELECT ID,Name FROM US_WSREMS__REMS_Program__c WHERE Name =: 'Sodium Oxybate REMS' limit 1 ];

        Account actobj = new Account();
        actobj.LastName='testLN';
        actobj.FirstName='testFN';
        actobj.phone = '8888587858';
        actobj.RecordTypeId =strRecordTypeId;
        actobj.US_WSREMS__REMS_Program__c =programObj.id;
        insert actobj;

        Account actobjPat = new Account();
        actobjPat.LastName='testLNPt';
        actobjPat.FirstName='testFNPT';
        actobjPat.phone = '8888587858';
        actobjPat.RecordTypeId =strRecordTypeIdPat;
        actobjPat.US_WSREMS__REMS_Program__c =programObj.id;
        insert actobjPat;

        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = RemsRecordTypeId;
        Insert serviceObj;

        Case caseObj = new Case(RecordTypeId = pccRecordTypeId, Status = 'Draft', US_WSREMS__REMS_Service_Summary__c = serviceObj.id,
                                SYN_Type_of_Reporter__c='Other',SYN_Early_Refill_Requested__c ='yes',SYN_Prescriber_Contacted__c='Yes',PAE_associated_with_report__c='Yes',
                                SYN_For_the_patient__c='Yes',SYN_For_the_prescriber__c='Yes', SYN_Was_early_refill_approved__c='Yes',US_WSREMS__DOB__c=null,
                                RDA_Authorization_Code__c='8uyu87u78',SYN_Prescriber__c=actobj.Id,US_WSREMS__Patient__c=actobj.Id);

        insert caseObj;

SYstem.debug(caseObj.RecordTypeId+'----'+caseRiskManagementRecordTypeId +'---'+caseObj.SYN_Type_of_Reporter__c+'--'+caseObj.SYN_If_Other_Type_of_Reporter__c);
    } */

	public static testMethod void UpdateCaseAccount_Test() {

         id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
         id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();

         US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
         Account accountObj = SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeId);
         US_WSREMS__Program_Users__c programUser = SYN_TestDataUtility.createProgramUser(UserInfo.getUserId(),programObj.id);

         Test.StartTest();
                    Case caseObj = SYN_TestDataUtility.createaPatientEnrollmentCase(caseRecordTypeId,'FirstName','LastName', 'Draft',programObj.id,accountObj);
         Test.StopTest();

    }

    public static testMethod void RDACase_Test() {
        id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id recordTypeIdPharmacy = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        id casePDARecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PDA').getRecordTypeId();
         id recordTypeIdREMSService = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Pre_Dispense_Authorization').getRecordTypeId();

        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
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
        Test.StopTest();

    }
	  public static testMethod void affiliatedWithCertifiedPharmacy_Test() {

  id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
  id recordTypeIdPharmacyParticipant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
  id casePatientPregnancRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Patient_Pregnancy_Test').getRecordTypeId();
  id recordTypeIdPharmacy = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
  id patientCounselingChecklistCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Counseling_Checklist').getRecordTypeId();

 US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
 Account patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
 Account pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy);
 Account pharmCParticipanAccount = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,recordTypeIdPharmacyParticipant);

 US_WSREMS__Affiliation__c createAffiliation = SYN_TestDataUtility.createAffiliation(programObj.Id,pharmCParticipanAccount.Id,pharmCAccount.Id);
  Test.StartTest();
 Case PatientPregnancyCase=SYN_TestDataUtility.createCasePatientPregnancyTest(casePatientPregnancRecordTypeId,programObj.Id,patientAccount.Id,pharmCParticipanAccount.Id);
 Case createPatientCounselingChecklistTest=SYN_TestDataUtility.createPatientCounselingChecklistTest(patientCounselingChecklistCaseRecordTypeId,programObj.Id,patientAccount.Id,pharmCParticipanAccount.Id,pharmCAccount.Id);
 Test.StopTest();



}
@isTest
static void remsupdate(){
    Test.startTest();
    list<case> newcase = new list<case>();
    US_WSREMS__REMS_Program__c remsprog = [select id from US_WSREMS__REMS_Program__c where Name = 'Sodium Oxybate REMS' LIMIT 1];
    Account acc = SYN_TestDataUtility.createPrescriberPersonAccount(remsprog.Id);

    id serviceRiskManagementRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
    US_WSREMS__REMS_Service_Summary__c remsService = new US_WSREMS__REMS_Service_Summary__c();
    remsService.US_WSREMS__REMSProgram__c = remsprog.Id;
    remsService.RecordTypeId =serviceRiskManagementRecordTypeId;
    remsService.US_WSREMS__Requestor_Type__c = 'Prescriber';
    remsService.US_WSREMS__Participant__c = acc.id;
    insert remsService;



    id caseRiskManagementRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
    Case remsstatus = new Case();
    remsstatus.RecordTypeId = caseRiskManagementRecordTypeId;
    remsstatus.US_WSREMS__REMS_Service_Summary__c = remsService.Id;
    remsstatus.US_WSREMS__Program_Picklist__c = 'Sodium Oxybate REMS';
    remsstatus.SYN_Date__c = system.today();
    remsstatus.SYN_Addendum__c ='No';
    remsstatus.SYN_Type_of_Reporter__c = 'Prescriber';
    remsstatus.SYN_Name_of_Reporter__c = acc.Id;
    remsstatus.SYN_Street_Address__c = 'test';
    remsstatus.US_WSREMS__State__c = 'AZ';
    remsstatus.US_WSREMS__City__c = 'test';
    remsstatus.SYN_Zip_Code__c = '12345';
    remsstatus.SYN_Nature_of_Report__c='Misuse';
    remsstatus.SYN_Prescriber__c = acc.Id;
    remsstatus.SYN_RMR_Event_Start_Date__c = system.today();
    remsstatus.SYN_RMR_Event_Details__c = 'test';
    remsstatus.SYN_Alerts_and_RMR_history_reviewed__c = 'No';
    remsstatus.SYN_Early_Refill_Requested__c ='No';
    remsstatus.SYN_Prescriber_Contacted__c = 'No';
    remsstatus.SYN_If_no_what_is_the_reason__c = 'test';
    remsstatus.SYN_Was_early_refill_approved__c = 'No';
    remsstatus.SYN_Early_refill_status_reason__c = 'test';
    remsstatus.PAE_associated_with_report__c = 'Yes';
    remsstatus.SYN_Summary_of_Investigation__c = 'test';
    remsstatus.SYN_Attachments__c = 'Shipping Service Report';
    remsstatus.SYN_Should_patient_be_monitored__c = 'No';
    remsstatus.SYN_Requesting_disenrollment__c = 'Yes';
    remsstatus.SYN_For_the_patient__c = 'No';
    remsstatus.SYN_For_the_prescriber__c = 'No';
    remsstatus.SYN_Pharmacist__c = acc.Id;
    remsstatus.US_WSREMS__Signature__c = 'Yes';
    //remsstatus.Status = 'Complete';
    //remsstatus.US_WSREMS__Outcome__c = 'Complete';
    insert remsstatus;

    Test.stopTest();

}
/* commenting out for deployment need to fix after sit to uat
Error: Methods defined as TestMethod do not support Web service callouts
Stack Trace: null*/
   @isTest
    static void PatientEnrollmentCompleteCaseTest(){
        Test.startTest();
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        US_WSREMS__Program_Users__c programUser = SYN_TestDataUtility.createProgramUser(UserInfo.getUserId(),programObj.id);
        Id accountPatientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        id recordTypeIdPharmacy = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        Account prescriberacc =  SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
        Account patientAccount=SYN_TestDataUtility.createPatientAccount(programObj.id,accountPatientRecordTypeId);
        Id remsRTId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId();
        Account pharmCAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeIdPharmacy);
           pharmCAccount.US_WSREMS__Status__c='Initiated';
           update pharmCAccount;
         US_WSREMS__REMS_Service_Summary__c remsServiceObject = SYN_TestDataUtility.createRemsServiceSummary_PatientRecord(pharmCAccount.Id, programObj.Id, patientAccount.Id,'Pharmacy',remsRTId);
        Id enrollmentCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();

        prescriberacc.US_WSREMS__Status__c='Certified';
        Update prescriberacc;
        Case createaPatientEnrollmentPatientCase=SYN_TestDataUtility.createaPatientEnrollmentPatientCase(enrollmentCaseRecTypeId,programObj.Id,'F1', 'L1',remsServiceObject.Id,patientAccount.Id);
         createaPatientEnrollmentPatientCase.SYN_Prescriber_Last_Name__c='sls';
         createaPatientEnrollmentPatientCase.US_WSREMS__State__c='Al';
         createaPatientEnrollmentPatientCase.US_WSREMS__Shipping_Street__c='test';
         createaPatientEnrollmentPatientCase.SYN_Prescriber_Phone__c='1234567890';
         createaPatientEnrollmentPatientCase.US_WSREMS__City__c='test city';
         createaPatientEnrollmentPatientCase.SYN_Prescriber_Signature__c='Yes';
         createaPatientEnrollmentPatientCase.SYN_Shipping_State__c='Al';
         createaPatientEnrollmentPatientCase.US_WSREMS__Signature__c='Yes';
         createaPatientEnrollmentPatientCase.SYN_Street_Address__c='address1';
         createaPatientEnrollmentPatientCase.US_WSREMS__Shipping_City__c='scity';
         createaPatientEnrollmentPatientCase.SYN_Prescriber_Signature_Date__c=system.today();
         createaPatientEnrollmentPatientCase.SYN_Zip_Code__c='12345';
         createaPatientEnrollmentPatientCase.US_WSREMS__Date__c=system.today();
         createaPatientEnrollmentPatientCase.US_WSREMS__Shipping_Zip_Postal_Code__c='12345';
         createaPatientEnrollmentPatientCase.SYN_Prescriber__c=prescriberacc.Id;
         createaPatientEnrollmentPatientCase.US_WSREMS__NPI__c='1234567899';
         createaPatientEnrollmentPatientCase.SYN_Prescriber_First_Name__c='Pfirst';
        createaPatientEnrollmentPatientCase.US_WSREMS__Patient_Risk_Category__c='Female of Reproductive Potential (FRP)';
        createaPatientEnrollmentPatientCase.Negative_Pregnancy_Test_Completed__c='Yes';

        createaPatientEnrollmentPatientCase.status='Complete';
        createaPatientEnrollmentPatientCase.US_WSREMS__Outcome__c='Complete';
        update createaPatientEnrollmentPatientCase;

       // update createaPatientEnrollmentPatientCase;
        task objtask = new task ();
        objtask.WhatID = createaPatientEnrollmentPatientCase.Id;
        objtask.Subject='Donni';
        objtask.Status='In Progress';
        objtask.Priority='Normal';
        insert objtask;

        set<Id> caseIds = new set<id>();
        caseIds.add(createaPatientEnrollmentPatientCase.Id);
        SYN_CaseTriggerHanlder.setTaskToComplete(caseIds);
        Test.stopTest();
    }

   

    public static testMethod void updateChannelonAccountFromCaseTest() {

       List<Account> accListData = New List<Account>();
       List<Case> caseListData = new List<Case>();

        id recordTypeIdPatient =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
        id recordTypeIdPrescriber =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        id PrecRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        id caseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('case', 'Patient_Enrollement');

        Test.startTest();
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');

        // Account Creation
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        accListData.add(createPatientAccount);

        Account prescAcc1 = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        accListData.add(prescAcc1);

        //Rems Service Creation
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummaryopen(createPatientAccount.Id,programObj.Id);

        //Enrollment Service creation
        Case createPatientEnrollmentCase1= SYN_TestDataUtility.createaPatientEnrollmentPatientCasewithFaxasprefcontactcomplete(caseRecordTypeId, programObj.Id,'Test FirstName','Test LastName',objService.id,createPatientAccount.Id,prescAcc1.id);
        caseListData.add(createPatientEnrollmentCase1);

       
        // Updating Case Record 
        for (Case caselst2 : caseListData) {
            caselst2.US_WSREMS__Channel__c = 'Migration';
            caselst2.US_WSREMS__Outcome__c = 'Complete';
            caselst2.Status = 'Complete';
            caselst2.US_WSREMS__NPI__c='8989800000';
         }
        update caseListData;

       Test.stopTest();

       // Query the account to check if the channel was updated
        Account updatedAccount = [SELECT Id, US_WSREMS__Channel__c FROM Account WHERE Id = :accListData[0].Id LIMIT 1];

       // Assert the channel was updated
        System.assertEquals('Migration', updatedAccount.US_WSREMS__Channel__c);
   }
   public static testMethod void updateChannelonAccountFromCaseTest2() {

    List<Account> accListData = New List<Account>();
    List<Case> caseListData = new List<Case>();

     id recordTypeIdPatient =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
     id recordTypeIdPrescriber =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
     id PrecRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
     id caseRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('case', 'Patient_Enrollement');

     Test.startTest();
     US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');

     // Account Creation
     Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
     accListData.add(createPatientAccount);

     Account prescAcc1 = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
     accListData.add(prescAcc1);

     //Rems Service Creation
     US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummaryopen(createPatientAccount.Id,programObj.Id);

     //Enrollment Service creation
     
     Case createPrescriberEnrollmentCase1= SYN_TestDataUtility.createaPrescriberEnrollmentCase(PrecRecordTypeId,'Test FirstName','Test LastName','Complete', programObj.Id,prescAcc1);
     caseListData.add(createPrescriberEnrollmentCase1);

     // Updating Case Record 
     for (Case caselst2 : caseListData) {
         caselst2.US_WSREMS__Channel__c = 'Migration';
         caselst2.US_WSREMS__Outcome__c = 'Complete';
         caselst2.Status = 'Complete';
         caselst2.US_WSREMS__NPI__c='8989800000';
      }
     update caseListData;

    Test.stopTest();

    // Query the account to check if the channel was updated
     Account updatedAccount = [SELECT Id, US_WSREMS__Channel__c FROM Account WHERE Id = :accListData[0].Id LIMIT 1];

    // Assert the channel was updated
     System.assertEquals('Fax', updatedAccount.US_WSREMS__Channel__c);
}

    public static testMethod void updateChannelonAccountFromCaseDistTest() {

       List<Account> accDisListData = New List<Account>();
       List<Case> caseDisListData = new List<Case>();

       id recordTypeIdDist =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'REMS_Distributor_Account');
       id distRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('SYN_Distributor_Enrollment').getRecordTypeId();

        Test.startTest();
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');

        // Account Creation
        Account createDistributorAccount = SYN_TestDataUtility.createDistributorAccount(programObj.Id,recordTypeIdDist);
        accDisListData.add(createDistributorAccount);

        // Rems Service Creation
        US_WSREMS__REMS_Service_Summary__c objService1 = SYN_TestDataUtility.createRemsServiceSummaryDistropen(createDistributorAccount.Id,programObj.Id);

        // Enrollment creation
        //Case createDistributorEnrollmentCase = SYN_TestDataUtility.createaDistributorEnrollmentCase(distRecordTypeId,'Test FirstName','Complete', programObj.Id,createDistributorAccount);
       // caseDisListData.add(createDistributorEnrollmentCase);

       // Updating Case Record
        for (Case caselst : caseDisListData) {
            caselst.US_WSREMS__Channel__c = 'Phone';
            caselst.US_WSREMS__Outcome__c = 'Complete';
            caselst.Status = 'Complete';
            caselst.US_WSREMS__NPI__c='8989800000';
         }
       update caseDisListData;

       Test.stopTest();

       // Query the account to check if the channel was updated
        Account updatedAccount = [SELECT Id, US_WSREMS__Channel__c FROM Account WHERE Id = :accDisListData[0].Id LIMIT 1];

      // Assert the channel was updated
        System.assertEquals('Fax', updatedAccount.US_WSREMS__Channel__c);
   }

    public static testMethod void updateChannelonAccountFromCasePharmOutpatientTest() {

       List<Account> accOutPatListData = New List<Account>();
       List<Case> caseOutPatListData = new List<Case>();

        id recordTypeIdPharm = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Pharmacy');
        id outpatientRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('SYN_Outpatient_Pharmacy').getRecordTypeId();


        Test.startTest();
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');

        // Account Creation
        Account createPharOutpatientAccount= SYN_TestDataUtility.createPharmacyOutpatientAccountTest(programObj.Id,recordTypeIdPharm);
        accOutPatListData.add(createPharOutpatientAccount);

       // Rems Service Creation
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummaryPharmropen(createPharOutpatientAccount.Id,programObj.Id);

        // Enrollment creation
        Case createPharmOutEnrollmentCase1= SYN_TestDataUtility.createPharmacyEnrollmentCase(outpatientRecordTypeId,'Complete', programObj.Id,createPharOutpatientAccount);
        caseOutPatListData.add(createPharmOutEnrollmentCase1);

        // Updating the Case Record
        for (Case caselist : caseOutPatListData) {
            caselist.US_WSREMS__Channel__c = 'Migration';
            caselist.US_WSREMS__Outcome__c = 'Complete';
            caselist.Status = 'Complete';
            caselist.US_WSREMS__NPI__c='8989800000';
         }
        update caseOutPatListData;

       Test.stopTest();

       // Query the account to check if the channel was updated
        Account updatedAccount = [SELECT Id, US_WSREMS__Channel__c FROM Account WHERE Id = :accOutPatListData[0].Id LIMIT 1];

       // Assert the channel was updated
        System.assertEquals('Migration', updatedAccount.US_WSREMS__Channel__c);
   }

    public static testMethod void updateChannelonAccountFromCasePharmInpatientTest() {

       List<Account> accInpListData = New List<Account>();
       List<Case> caseInpListData = new List<Case>();

        id recordTypeIdPharm = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Pharmacy');
        id inpatientEnrollmentCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('SYN_Inpatient_Pharmacy').getRecordTypeId();

        Test.startTest();
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');

        // Account Creation
        Account createPharInpatientAccount= SYN_TestDataUtility.createPharmacyInpatientAccountTest(programObj.Id,recordTypeIdPharm);
        accInpListData.add(createPharInpatientAccount);

        // Rems Service Creation
        US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummaryPharmropen(createPharInpatientAccount.Id,programObj.Id);

        // Enrollment creation
        Case createPharmInpatientEnrollmentCase1= SYN_TestDataUtility.createPharmacyEnrollmentCase(inpatientEnrollmentCaseRecordTypeId,'Complete', programObj.Id,createPharInpatientAccount);
        caseInpListData.add(createPharmInpatientEnrollmentCase1);

        // Updating Case Record
        for (Case cselst : caseInpListData) {
            cselst.US_WSREMS__Channel__c = 'Migration';
            cselst.US_WSREMS__Outcome__c = 'Complete';
            cselst.Status = 'Complete';
            cselst.US_WSREMS__NPI__c='8989800000';
         }
        update caseInpListData;

       Test.stopTest();

       // Query the account to check if the channel was updated
        Account updatedAccount = [SELECT Id, US_WSREMS__Channel__c FROM Account WHERE Id = :accInpListData[0].Id LIMIT 1];

       // Assert the channel was updated
        System.assertEquals('Migration', updatedAccount.US_WSREMS__Channel__c);
   }
   @isTest
    public static void CommunicationForPAEPC_Test1() {
        id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PAE').getRecordTypeId();
        id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Id patientEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Patient_Enrollement');
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('PiaSky REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        Account prescAcc = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        
        US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
            US_WSREMS__Participant__c=createPatientAccount.Id,
            US_WSREMS__REMSProgram__c = programObj.Id,
            US_WSREMS__Service_Outcome__c='Successful',
            US_WSREMS__Status__c ='Closed', 
            RecordTypeId=SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'PAE_PC_MI'),
            US_WSREMS__Requestor_Type__c='Patient'
        );
        Insert objService;
        
        
        Case cs = New Case(RecordTypeid=caseRecordTypeId, US_WSREMS__REMS_Program__c=programObj.Id,US_WSREMS__Program_Picklist__c='piaSky REMS',
                           US_WSREMS__Channel__c='Phone',US_WSREMS__Type_of_Report__c='Potential Adverse Event (PAE)',SYN_Sponsor_Responsible__c='Genentech Inc.',
                           US_WSREMS__Phone__c='9878887777',SYN_Reporter__c=createPatientAccount.Id,Date_Voicemail_or_Fax_received__c=Date.Today(),
                           SYN_Prescriber__c=prescAcc.ID,US_WSREMS__Patient__c=createPatientAccount.Id,Program_Record_Type_Control__c='Macitentan REMS-PAE_PC_MI',
                           SYN_Event_Description__c='test',status='Complete',US_WSREMS__Outcome__c='Acknowledgment Pending',US_WSREMS__Participant__c=createPatientAccount.Id,US_WSREMS__REMS_Service_Summary__c = objService.Id,
                           SYN_Reporter_First_Name__c='Test', SYN_Reporter_Last_Name__c='testt',US_WSREMS__First_Name__c='test',US_WSREMS__Last_Name__c='testt');
        
        
        insert cs;
        List<Case>clist = new List<case>();
        clist.add(cs);
        
        Test.StartTest();  
        SYN_CaseTriggerHanlder.populateSponserDate(clist);
        Test.stopTest();
    }

    @isTest
    public static void updateIncompleteReasonForIdentifier(){
        Id accRectypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId(); 
        Id serviceRectypeId =  Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId(); 
        Id caseRectypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId(); 
        List<US_WSREMS__REMS_Program__c> progObjList = SYN_TestDataFactory.createProgram(1,true,'XIAFLEX','001');
        Insert progObjList;
        Account accOBj = SYN_TestDataFactory.createAccountTestRecord(progObjList[0].Id,accRectypeId);
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__Participant__c  = accOBj.Id;
        serviceObj.US_WSREMS__REMSProgram__c = progObjList[0].Id;
        serviceObj.US_WSREMS__Requestor_Type__c ='Health Care Setting';
        serviceObj.US_WSREMS__StageName__c='Intake';
        serviceObj.RecordtypeId = serviceRectypeId;
        insert serviceObj;
        Test.StartTest();
        Case caseObj = SYN_TestDataFactory.CreateCase(false, serviceObj.Id);
        caseObj.recordTypeId = caseRectypeId;
        caseObj.US_WSREMS__NPI__c = '1234567890';
        caseObj.US_WSREMS__HIN__c = 'HN12345';
        caseObj.US_WSREMS__DEA__c = 'DE1234567';
        caseObj.US_WSREMS__DEA_Status__c = 'Invalid';
        caseObj.US_WSREMS__NCPDP__c = '1234567';
        caseObj.US_WSREMS__HIN_Status__c = 'Invalid';
        caseObj.US_WSREMS__REMS_Program__c = progObjList[0].Id;
        caseObj.US_WSREMS__Incomplete_Reasons__c = '';
        update caseObj;
        Case caseRec  = [SELECT US_WSREMS__Incomplete_Reasons__c FROM Case WHERE Id=:caseObj.Id LIMIT 1];
        system.assertEquals(true, caseRec.US_WSREMS__Incomplete_Reasons__c!=null);
        Test.StopTest();
    }


}