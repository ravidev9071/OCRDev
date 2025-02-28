@isTest
public class SYN_PatientEnrollmentMissingInfoTest {
    
    @TestSetup 
    static void dataSetup() {
         US_WSREMS__REMS_Program__c remsProgram = new US_WSREMS__REMS_Program__c(Name = 'Sodium Oxybate REMS',US_WSREMS__Status__c ='Active',REMS_Project_Code__c = 'BT6825'); 
         insert  remsProgram;
        Account participant = new Account(Name ='ABC', US_WSREMS__REMS_Program__c =remsProgram.Id,Phone='1234567789');
        insert participant;
        contact con= new contact();
        con.LastName='test';
        con.AccountId=participant.id;
        insert con;
                
        Case caseA = new Case();
        caseA.US_WSREMS__REMS_Program__c = remsProgram.id;
        caseA.US_WSREMS__Call_Notes__c = 'test';
        caseA.Us_WSREMS__Participant__c=participant.id;
        //caseA.US_WSREMS__REMS_Service_Summary__c =usRemsId.Id;
        caseA.Medical_Conditions__c='Asthma;COPD';
        caseA.Program_Record_Type_Control__c = 'Sodium Oxybate REMS'+'-Patient_Enrollement';
        //caseA.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Assessment A').getRecordTypeId();//Knowledge Assessment A- RecoredTyoeId-0123C000000a0cAQAQ
        insert caseA; 
    }
    
    @isTest
    public static void getPatientEnrollmentMissingFieldsTest(){
        Test.startTest();
        List<string> missingFieldList=new List<string>();
        case caseRec = [Select id,Us_WSREMS__Participant__r.personContactId,AccountId,Medical_Conditions__c,Us_WSREMS__Participant__c,US_WSREMS__Program_Name__c from case  where Medical_Conditions__c != null Limit 1 ];
        List<String> medicalConditionFieldList = caseRec.Medical_Conditions__c.split(';');
        SYN_PatientEnrollmentMissingInfo.emailCaseId = caseRec.Id;
        SYN_PatientEnrollmentMissingInfo.missingFieldsList = SYN_PatientEnrollmentMissingInfo.getPatientEnrollmentMissingFields();
        Test.stopTest();
        system.assertEquals(SYN_PatientEnrollmentMissingInfo.missingFieldsList, medicalConditionFieldList);
    }
    @isTest
    public static void getStakeholderEnrollmentMissingFieldsTest(){
        Test.startTest();
        List<string> missingFieldList=new List<string>();
        case caseRec = [Select id,Us_WSREMS__Participant__r.personContactId,AccountId,Medical_Conditions__c,Us_WSREMS__Participant__c,US_WSREMS__Program_Name__c from case  where Medical_Conditions__c != null Limit 1 ];
        List<String> medicalConditionFieldList = caseRec.Medical_Conditions__c.split(';');
        SYN_PatientEnrollmentMissingInfo.emailCaseId = caseRec.Id;
        SYN_PatientEnrollmentMissingInfo.missingFieldsList =SYN_PatientEnrollmentMissingInfo.getStakeholderEnrollmentMissingFields();
        Test.stopTest();
        system.assertEquals(SYN_PatientEnrollmentMissingInfo.missingFieldsList, medicalConditionFieldList);
    }
    @isTest
    public static void getRiskManagementReportMissingFieldsTest(){
        Test.startTest();
        List<string> missingFieldList=new List<string>();
        case caseRec = [Select id,Us_WSREMS__Participant__r.personContactId,AccountId,Medical_Conditions__c,Us_WSREMS__Participant__c,US_WSREMS__Program_Name__c from case  where Medical_Conditions__c != null Limit 1 ];
		List<String> medicalConditionFieldList = caseRec.Medical_Conditions__c.split(';');
        SYN_PatientEnrollmentMissingInfo.emailCaseId = caseRec.Id;
        SYN_PatientEnrollmentMissingInfo.missingFieldsList = SYN_PatientEnrollmentMissingInfo.getRiskManagementReportMissingFields();
        Test.stopTest();
        system.assertEquals(SYN_PatientEnrollmentMissingInfo.missingFieldsList, medicalConditionFieldList);
    }
    @isTest
    public static void getPatientCounselingChecklistMissingFieldsTest(){
        Test.startTest();
        case caseRec = [Select id,Us_WSREMS__Participant__r.personContactId,AccountId,Medical_Conditions__c,Us_WSREMS__Participant__c,US_WSREMS__Program_Name__c from case  where Medical_Conditions__c != null Limit 1 ];
        List<String> medicalConditionFieldList = caseRec.Medical_Conditions__c.split(';');
        SYN_PatientEnrollmentMissingInfo.emailCaseId = caseRec.Id;
        SYN_PatientEnrollmentMissingInfo.missingFieldsList = SYN_PatientEnrollmentMissingInfo.getPatientCounselingChecklistMissingFields();
        Test.stopTest();
        system.assertEquals(SYN_PatientEnrollmentMissingInfo.missingFieldsList, medicalConditionFieldList);
    }
    //getpatientNameWithInitials
	@isTest
    public static void getpatientNameWithInitialsTest(){
        Test.startTest();
        SYN_PatientEnrollmentMissingInfo.personFirstName = 'ABC';
        SYN_PatientEnrollmentMissingInfo.personMiddleName = 'XYZ';
        SYN_PatientEnrollmentMissingInfo.personLastName = 'PQR';
        String str = SYN_PatientEnrollmentMissingInfo.getpatientNameWithInitials();
        Test.stopTest();
        system.assertEquals(str, 'A X P');

    }
}