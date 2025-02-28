/*
    Author : Balaji M
    Date: 01-09-2021
    Description : This class helps to Add/Update participant to the Case
*/
public with sharing class SYN_AppLiterals {  
    public static final String AFFILIATION_OBJECT = 'Affiliation__c';
    public static final String SERVICE_SUMMARY_OBJECT = 'REMS_Service_Summary__c';
    public static final String ACCOUNT_OBJECT = 'Account';
    public static final String CASE_OBJECT = 'Case';
    public static final String STAGEDETAIL_OBJECT= 'Stage_Detail__c';
    public static final String REQUESTORTYPE_PRESCRIBER = 'Prescriber';
    public static final String REQUESTORTYPE_PHARMACY_USER = 'Pharmacy User';
    public static final String REQUESTORTYPE_PATIENT = 'Patient';
    public static final String REQUESTORTYPE_PRESCRIBING_INSTITUTION = 'Prescribing Institution';
    public static final String REQUESTORTYPE_PHARMACY = 'Pharmacy';
    public static final String NAMESPACE_STRING = 'US_WSREMS__';
    public static final set<String> CASE_ENROLLMENT_RECTYPE_SET= new Set <String> {'Prescriber_enrollment','PharmacyUser_Enrollment','Patient_Enrollement','Pharmacy_Enrollment','PrescribingInstitution_Enrollment','Change_of_Information'};
    public static final String AFFILIATION_RECTYPE_PHARMACY_USER_AFFILIATION = 'Pharmacy_User_Affiliation';
    public static final String SERVICE_RECTYPE_CHANGE_AUTHORIZED_REPRESENTATIVE = 'Change_Authorized_Representative';
    public SYN_AppLiterals(){
        
    }
    
}