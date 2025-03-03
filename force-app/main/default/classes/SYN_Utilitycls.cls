/*
Author : Wilcosource
 * @Modification Log   :
* Ver       Date            Developer                        Modification
* 2.0    09/24/2022        Praveen Vellanki (Wilco)       Changes made as listed below:
                                                          Line 36: New set variable added CASE_ENROLLMENT_RECTYPE_SET_VEEVA
                                                          Line 40: New variable for Active value  
                                                          Line 41: New variable for Inactive value
														  
* 3.0    27/01/2023       Swetha S(Wilco)				  Line 17: New variable for Program 
                                                          Line 70: New variable for Queue 										  
* 4.0    27/01/2023       Dileep G(Wilco)				  Line 90: New variable for Macitentan REMS Task Queue
                                                                                                                  
*/

public with sharing class SYN_Utilitycls {
    public static final String NonComplianceReporterRTNameField = 'X2_Account_Record_Type__c';
    public static final String NonComplianceInvestigatedRTNameField = 'Participant_Account_Record_Type__c';
    public static final String NonComplianceImpactedRTNameField = 'X1_Account_Record_Type__c';
    public static final String SOX_PROGRAM_NAME = 'Sodium Oxybate REMS';
    public static final String MACI_PROGRAM_NAME = 'Macitentan REMS';
    public static final String AVEED_PROGRAM_NAME ='AVEED REMS';
    public static final String HCS_NOT_CEERTIFIED ='Associated healthcare setting is not certified;';
    public static final String HCP_NOT_CERTIFIED ='Associated healthcare provider is not certified;';
    public static final String AVEED_PublicGroup='AVEED_REMS_Read_Edit';
    public static final string AVEED_QueueName='AVEED_REMS_Fax_Queue';
    public static final string AVEED_TaskQueueName='AVEED_Task_Queue';
    public static final string XIAFLEX_QueueName = 'XIAFLEX_Task_Queue';
    public static final string AVEED_Owner_Error_Msg='The user selected is not a AVEED REMS user. Please select a AVEED REMS user';
    public static final String XIAFLEX_PROGRAM_NAME ='XIAFLEX';
    public static final String XIAFLEX_PublicGroup ='XIAFLEX_Read_Edit';
    public static final String XIAFLEX_Super_User_ProfileName = 'REMS Super User New Program';
    public static final String Clozapine_PROGRAM_NAME = 'Clozapine REMS';
    public static final String PiaSky_PROGRAM_NAME ='PiaSky REMS';
    public static final String TRYVIO_PROGRAM_NAME ='TRYVIO REMS';
    public static final String Patient_Enrollment_RectypeDevName = 'Patient_Enrollement';
    public static final String CASE_INFORMATION = 'Case Information';
    public static final String CUSTOM_LINKS = 'Custom Links';
    public static final String PHARMACY_REGISTRATION_LAYOUT = 'Case-US_WSREMS__Pharmacy Registration';
    public static final String PHARMACY_REGISTRATION_ID = 'Pharmacy_Registration';
    public static final String ProductRCType = 'ProductRTName';
    public static final String AFFILIATION_OBJECT = 'Affiliation__c';
    public static final String PRESCRIBER_AFFILIATION_RECORDTYPENAME = 'Prescriber_Affiliation';
    public static final String AFFILIATION_USER_ROLE = 'Primary AR';
    public static final String SERVICE_SUMMARY_OBJECT = 'REMS_Service_Summary__c';
    public static final String ACCOUNT_OBJECT = 'Account';
    public static final String CASE_OBJECT = 'Case';
    public static final String STAGEDETAIL_OBJECT= 'Stage_Detail__c';
    public static final String REQUESTORTYPE_PRESCRIBER = 'Prescriber';
    public static final String REQUESTORTYPE_PHARMACY_USER = 'Pharmacy User';
    public static final String REQUESTORTYPE_PATIENT = 'Patient';
    public static final String REQUESTORTYPE_AUTHORIZED_REPRESENTATIVE = 'Authorized Representative';
    public static final String REQUESTORTYPE_PRESCRIBING_INSTITUTION = 'Prescribing Institution';
    public static final String REQUESTORTYPE_PHARMACY = 'Pharmacy';
    public static final String ACCOUNT_RECTYPE_ParticipantEnrollment  = 'Participant_Enrollment';
    public static final String pickListVal_close = 'Closed';
    public static final set<String> CASE_ENROLLMENT_RECTYPE_SET_VEEVA = new Set <String> {'Prescriber_enrollment','Prescriber_Reenrollment','Pharmacy_Enrollment','Pharmacy_Reenrollment','Prescriber_Person_Account','Pharmacy_Account','SYN_Outpatient_Pharmacy','SYN_Inpatient_Pharmacy'};
    public static final String pickListVal_Valid = 'Valid';
    public static final String pickListVal_Invalid = 'Invalid';
    public static final String Prescriber_enrollRCTypeDev = 'Prescriber_enrollment';
    public static final String Prescriber_Person_Account = 'Prescriber_Person_Account';
    public static final String pickListVal_Active = 'Active';
    public static final String pickListVal_InActive = 'InActive';
    public static final String Prescriber = 'Prescriber';
    public static final String OfficeContact = 'Office_Contact';
    public static final String Patient_Enrollement = 'Patient_Enrollement';
    public static final String Patient = 'Patient';
     public static final String Professional_Designation = 'SYN_Professional_Designation__c';
    public static final String Distributor_Enrollement = 'SYN_Distributor_Enrollment';
    public static final String Distributor_Account = 'REMS_Distributor_Account';
    public static final String Pharmacy_Enrollment = 'Pharmacy_Enrollment';
    public static final String Pharmacy_Account = 'Pharmacy';
    public static final String Prescriber_ReenrollRCTypeDev = 'Prescriber_Reenrollment';
    public static final String Distributor_Reenrollement = 'Distributor_Reenrollment';
    public static final String Patient_Reenrollement = 'Patient_Reenrollment';
    public static final String Pharmacy_Reenrollment = 'Pharmacy_Reenrollment';
    public static final String Knowlege_Assessment_A = 'SYN_Knowledge_Assessment_A';
    public static final String Knowlege_Assessment_B = 'SYN_Knowledge_Assessment_B';
    public static final String Knowlege_Assessment = 'Knowledge_Assessment';
    public static final String Pharmacy_Participant_account = 'Pharmacy_Participant';
     public static final String Change_Authorized_Representative = 'Change_Authorized_Representative';
    public static final String semicolon = ';';
    public static final String General_Contact = 'General_Contact';
    public static final String ACC_RCTY_Pharmacy_Participant  = 'Pharmacy_Participant';
    public static final String userType_Pharmacist = 'Pharmacist';
    public static final String userType_PharmacyStaff = 'Pharmacy Staff';
    public static final String RDA_errorMsg_DaysSupply = 'Days\' Supply must be greater than 0.';
    public static final String RDA_errorMsg_FuturePrescriptionDate = 'Date of Prescription cannot be in the future.';
   	public static final String RDA_errorMsg_FutureDateOfFill = 'Date of Fill cannot be in the future.';
    public static final String RDA_errorMsg_Quantity = 'Please enter a value between 0.01 and 9,999.99';
    public static final String RDA_errorMsg_NumberOfAttempts = 'Number of attempts must be greater than 0 and can only be 2 digits.';
    public static final String Escalation_queue_name='Escalation Queue';
	public static final String Maci_Escalation_queue_name='Macitentan Escalation Queue';
    public static final String Sox_queue_name='Sodium_Oxybate_Fax_Queue';
    public static final String Sox_Taskqueue_name='SOX_Task_Queue';
    public static final String PiaSky_queue_name='PiaSky_REMS_Fax_Queue';//116 PiaSky
    public static final String Legal_Guardian_ErrorMsg = 'Legal Guardian Name,Phone and Relationship  are required if the patient is under the age of 18.';
    public static final String PiaSky_REMS_Task_Queue = 'PiaSky_REMS_Task_Queue'; //BT1005-112
    public static final String Maci_REMS_Task_Queue='Macitentan REMS Task Queue';
    public static final String Maci_REMS_Fax_Queue_Name='Macitentan_REMS_Fax_Queue';

	public static final String SYN_Inpatient_Pharmacy = 'SYN_Inpatient_Pharmacy';
    public static final String SYN_Inpatient_Pharmacy_Reenrollment = 'SYN_Inpatient_Pharmacy_Reenrollment';
    public static final String SYN_Outpatient_Pharmacy = 'SYN_Outpatient_Pharmacy';
    public static final String SYN_Outpatient_Pharmacy_Reenrollment = 'SYN_Outpatient_Pharmacy_Reenrollment';
	public static final String PAERecordTypeName = 'PAE_PC_MI';
    public static final String NonCompRecordTypeName = 'SYN_Non_Compliance';
    
    public static final String PDARecordTypeName = 'PDA';
    public static final String RMRecordTypeName = 'Risk_Management_Report';
    public static final String PharmacyAccStatus ='Certified';
    
    public static final String MDP ='MDP';
    public static final String REMS  ='REMS';

    public static final Set<String> restrictCaseEditProfilesAfterClosure = new Set<String>{Label.Rems_Agent_Label};
    public static final Set<String> restrictCaseEditPortalProfiles = new Set<String>{'SOX Pharmacist','SOX Prescriber'};
    public static final String restrictCaseEditAfterClosure = 'The Case is complete or cancelled and cannot be edited';
    public static final String restrictCaseEditPortalUsers = 'Please call the Sodium Oxybate REMS at 1-833-769-7367 to update existing RMR information. If you are adding additional documentation to an existing RMR, please use the "Attachments" field.';
    public static final String SOXPersonContactIdAccName = 'SOXPersonContact ConfigurationRecord forDistributor';
    public static final set<String> CASE_ENROLLMENT_RECTYPE_SET= new Set <String> {'Prescriber_enrollment','PharmacyUser_Enrollment','Patient_Enrollement','Pharmacy_Enrollment','PrescribingInstitution_Enrollment','Change_of_Information'};
    public static Map<String,Id> retrieveRecTypeNameId(String objectName){
        Map<String,Id> recordTypeNameIdMap = new Map<String,Id>();
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(SYN_AppLiterals.NAMESPACE_STRING+objectName).getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = objectSchema.getRecordTypeInfosByName();
        for(String rectypeName:recordTypeInfoMap.keyset()){
            if(recordTypeInfoMap.get(rectypeName).isAvailable() && recordTypeInfoMap.get(rectypeName).getDeveloperName()!='Master' && !recordTypeInfoMap.get(rectypeName).isMaster())
                recordTypeNameIdMap.put(rectypeName,recordTypeInfoMap.get(rectypeName).getRecordTypeId());            
        }
        return recordTypeNameIdMap;
    }
    //This method is used to Bypass the trigger 
    public static boolean validateCustomPermission(String customPermissionName){
        return FeatureManagement.checkPermission(customPermissionName);
    }
    public static OrgWideEmailAddress getOrgWideEmailAddress(String maciOrgWideAddress){
        OrgWideEmailAddress owa = New OrgWideEmailAddress();
        owa = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address =: maciOrgWideAddress LIMIT 1];
        return owa;
    }
    public static EmailTemplate getEmailTemplate(String maciEmailTemplate){
        EmailTemplate temp=[SELECT Id,Name,DeveloperName,Subject,Description,HtmlValue,Body FROM EmailTemplate WHERE Name = :maciEmailTemplate ];
        return temp;
    }
    public static id getOCRecTypeID(){
        RecordType ocRecid=[select id ,DeveloperName,NamespacePrefix from RecordType  where SobjectType ='Account'  and DeveloperName ='Office_Contact' Limit 1];
        return ocRecid.id;
    }
}