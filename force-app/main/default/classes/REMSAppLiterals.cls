/*
Author : Balaji M
Date: 01-09-2021
Description : This class helps to Add/Update participant to the Case
*/
public with sharing class REMSAppLiterals {  
    public static final string CASE_REFERENCEField = 'Outcome__c';
    public static final String COMPLIANCE_OBJECT ='US_WSREMS__CaseProgram__c';
    
    public static final string CASE_RECORDTYPE_DISTRIBUTOR_ENROLLMENT = 'Distributor_Enrollment';
    public static final string CASE_RECORDTYPE_INPATIENT_PHARMACY_REENROLLMENT = 'Inpatient_Pharmacy_Reenrollment';
    
    public static final String CASE_RECTYPE_HCS_ENROLLMENT='HCS_Enrollment';
    public static final string CASE_RECORDTYPE_OUTPATIENT_PHARMACY_REENROLLMENT = 'Outpatient_Pharmacy_Reenrollment';
    
    public static final string CASE_RECORDTYPE_INPATIENT_PHARMACY_ENROLLMENT = 'Inpatient_Pharmacy_Enrollment';
    public static final string CASE_RECORDTYPE_HCS_REENROLLMENT = 'HCS_Reenrollment';
    public static final String CASE_RECTYPE_PRESCRIBER_ENROLLMENT = 'Prescriber_enrollment';
    public static final string CASE_RECORDTYPE_OUTPATIENT_PHARMACY_ENROLLMENT = 'Outpatient_Pharmacy_Enrollment';
    public static final set<String> CASE_ENROLL_REENROLL_RECTYPE_SET_Certification= new Set <String> {'Change_Authorized_Representative','ARVerification','HCS_Reenrollment','Inpatient_Pharmacy_Reenrollment','Outpatient_Pharmacy_Reenrollment','Prescriber_Reenrollment','ReCertification'};
        public static final String REMS_RECTYPE_RECERTIFICATION = 'ReCertification';
    public static final String AFFILIATION_OBJ = 'Affiliation__c';
    public static final string CHANNELFAX = 'Fax';
    public static final string CASE_RECORDTYPE_KNOWLEDGE_ASSESSMENT = 'Knowledge_Assessment';
    public static final String NAMESPACE_STRING = 'US_WSREMS__';
    public static final String AFFILIATION_SOBJECT = 'Affiliation__c';
    public static final String AFFILIATION_OBJECT = NAMESPACE_STRING+AFFILIATION_SOBJECT;
    public static final String SERVICE_SUMMARY_OBJECT = NAMESPACE_STRING+'REMS_Service_Summary__c';
    public static final String ACCOUNT_OBJECT = 'Account';
    public static final String PROGRAM_OBJECT = NAMESPACE_STRING+'REMS_Program__c';
    public static final String CASE_OBJECT = 'Case';
    public static final String PROGRAM_SHARE_OBJECT = NAMESPACE_STRING+'REMS_PRogram__Share';
    public static final String AFFILIATION_SHARE_OBJECT = NAMESPACE_STRING+'Affiliation__Share';
    public static final String DOCUMENTCHECKLISTITEM_SHARE_OBJECT = 'DocumentCheckListItemShare';
    public static final String RECEIVEDDOCUMENT_SHARE_OBJECT = 'ReceivedDocumentShare';
    public static final String REMS_SERVICE_SUMMARY_SHARE_OBJECT = NAMESPACE_STRING+'REMS_Service_Summary__Share';
    public static final String CASE_SHARE_OBJECT = 'caseShare';
    public static final String SHIPPING_AND_TRACKING = NAMESPACE_STRING+'Shipping_and_Tracking__Share';
    public static final String ACCOUNT_SHARE_OBJECT = 'accountShare';
    public static final String STAGEDETAIL_OBJECT= 'Stage_Detail__c';
    public static final String REQUESTORTYPE_PRESCRIBER = 'Prescriber';
    public static final String REQUESTORTYPE_PHARMACY_USER = 'Pharmacy User';
    public static final String REQUESTORTYPE_PATIENT = 'Patient';
    public static final String REQUESTORTYPE_PRESCRIBING_INSTITUTION = 'Prescribing Institution';
    public static final String REQUESTORTYPE_PHARMACY = 'Pharmacy';
    public static final String REQUESTORTYPE_AUTHORIZED_REPRESENTATIVE = 'Authorized Representative'; 
    public static final String REQUESTORTYPE_DELEGATE = 'Prescriber Delegate';
    public static final String MACITENTAN_PROGRAM_NAME = 'Macitentan REMS';
    public static final String POWER_CUSTOMER_USERTYPE = 'PowerCustomerSuccess';
    public static final String REMS_SERVICE_SUMMARY_STAGE_CLOSED = 'Closed';
    //Record Types
    public static final String AFFILIATION_RECTYPE_PHARMACY_USER_AFFILIATION = 'Pharmacy_User_Affiliation';
    public static final String SERVICE_RECTYPE_CHANGE_AUTHORIZED_REPRESENTATIVE = 'Change_Authorized_Representative';
    public static final String CHANGE_OF_INFORMATION = 'Change_of_Information'; 
    public static final String AFFILIATION_RECTYPE_PATIENT_AFFILIATION = 'Patient_Affiliation';
    public static final String AFFILIATION_RECTYPE_PRESCRIBER_AFFILIATION = 'Prescriber_Affiliation'; 
    //public static final String NAMESPACE_STRING = 'US_WSREMS__';
    public static final set<String> CASE_ENROLLMENT_RECTYPE_SET= new Set <String> {'Prescriber_enrollment','PharmacyUser_Enrollment','Patient_Enrollement','Pharmacy_Enrollment','PrescribingInstitution_Enrollment','Change_of_Information'};
        
        public static final String NPITYPE_ORGANISATION = 'Organization';
    /* Service Enrollment Literals */
    public static final String PENDING_STATUS = 'Pending';
    public static final String CANCELLED_STATUS = 'Cancelled';
    public static final String ENROLLED_STATUS = 'Enrolled';
    public static  final string FAILED_STATUS = 'Failed';
    public static final String PARTICIPANT_ACCOUNT_CREATION = 'Participant Account Creation';
    public static final String PARTICIPANT_ACCOUNT = 'Participant Account Creation.';
    public static final string NPI_BOTHFOUND_MESSAGE = 'BothFound';
    public static final string ACCOUNT_RECORDTYPE_PRESCRIBER = 'Prescriber';
    public static final string ACCOUNT_RECORDTYPE_AR = 'Pharmacy_Participant';	
    public static final string SERVICE_PARTICIPANT_AR ='Pharmacy/HCS Participant';
    public static final String SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT = 'Participant_Enrollment';
    public static final String CASE_RECTYPE_PRESCRIBER_PERSON_ACCOUNT = 'Prescriber_Person_Account';
    public static final String PRESCRIBER_ROLE = 'Prescriber';
    public static final String REQUESTORTYPE_HCS = 'Health Care Setting';
    public static final String REQUESTORTYPE_AR='Pharmacy Participant';
    public static final string ACCOUNT_RECORDTYPE_HEALTHCARESETTING = 'Health_Care_Setting';
    public static final String HEALTH_CARE_SETTING_ROLE = 'Health Care Setting';
    public static final string CASE_RECORDTYPE_HEALTHCARESETTING = 'Health_Care_Setting';
    public static final String REQUESTORTYPE_OUTPATIENT = 'Outpatient Pharmacy';
    public static final String REQUESTORTYPE_INPATIENT = 'Inpatient Pharmacy';
    public static final string CASE_RECORDTYPE_PHARMACYPARTICIPANT = 'Pharmacy_Participant';
    public static final string ACCOUNT_RECORDTYPE_PHARMACYPARTICIPANT = 'Pharmacy_Participant';
    public static final String REQUESTORTYPE_PHARMACY_HCS_PARTICIPANT = 'Pharmacy/HCS Participant';
    public static final string ACCOUNT_RECORDTYPE_OUTPATIENTPHARMACY = 'Outpatient_Pharmacy_Account'; 
    public static final string CASE_RECORDTYPE_OUTPATIENTPHARMACY = 'Outpatient_Pharmacy';
    public static final string ACCOUNT_RECORDTYPE_INPATIENTPHARMACY = 'Inpatient_Pharmacy_Account'; 
    public static  final string CASE_CHANNEL_PORTAL = 'Portal';
    public static final string PRIMARY_AR_ROLE = 'Primary AR';
    public static final string CASE_STATUS_COMPLETED = 'Complete';
    public static final string TASK_STATUS_COMPLETED = 'Completed';
    public static final string CREDENTIALS_OTHER = 'Other';
    public static final string CREDENTIALS_OTHERS = 'Others';
    public static final string SERVICE_STATUS = 'Closed';
    public static final string SERVICE_OUTCOME = 'Successful';
    public static final boolean PATH_COMPLETE = true;
    public static final string PATH_STAGE_NAME = 'Closed';
    public static final string CASE_OUTCOME = 'Complete';
    public static final string Suspected_Non_compliance_activity = 'Suspected Non-compliance activity';
    public static final string Compliance_Investigation = 'Compliance Investigation';
    public static final string Confirmed_Non_compliance_activity = 'Confirmed Non-compliance activity';
    public static final set<String> CASE_ENROLLMENT_RECTYPE_SET_TASK = new Set <String> {'Inpatient_Pharmacy_Enrollment','Patient_Enrollement','Distributor_Enrollment','HCS_Enrollment','Outpatient_Pharmacy_Enrollment','Prescriber_enrollment'};
        
        
        //KA realated changes AVEED
        Public static final String PASSED='Passed';
    Public static final String FAILED='Failed';
    Public static final String COMPLETE='Complete';
    public static final set<String> CASE_ENROLL_REENROLL_RECTYPE_SET= new Set <String> {'Prescriber_enrollment','HCS_Enrollment','Outpatient_Pharmacy_Enrollment','Inpatient_Pharmacy_Enrollment','HCS_Reenrollment','Inpatient_Pharmacy_Reenrollment','Outpatient_Pharmacy_Reenrollment','Prescriber_Reenrollment','Distributor_Enrollment'};
        public static final String SERVICE_SUMMARY_OBJ = 'REMS_Service_Summary__c';  
    public static final String HEALTHCARE_SETTING_PENDING_STATUS = 'Pending';
    public static final String OUTPATIENT_PHARMACY_PENDING_STATUS = 'Pending';
    public static final string INCOMPLETE_REASON_KA = 'Knowledge Assessment';
    //public static final String SERVICE_SUMMARY_OBJECT = NAMESPACE_STRING+'REMS_Service_Summary__c';
    
    public static final String XIAFLEX_PROGRAM = 'XIAFLEX';
    public static final String XIAFLEX_MDP_PRO_TYPE='MDP';
    
    public REMSAppLiterals(){
        
        
    }
    }