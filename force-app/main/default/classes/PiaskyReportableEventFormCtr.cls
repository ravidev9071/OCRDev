/**************************************************************************
* Name :   PiaskyReportableEventFormCtr

Modification Log:
----------------------------------------------------------------------------------
Developer               Date                   Description
-----------------------------------------------------------------------------------
Utthirakumar		  12/09/2024             Initial Version
*********************************************************************************/
public without sharing class PiaskyReportableEventFormCtr {
    private final Case cs;

    public PiaskyReportableEventFormCtr() {
        Id recordid = ApexPages.currentPage().getParameters().get('Id');
        
        // Main Case query including fields from CaseProgram__c (child object)
        cs = [ 
            SELECT Id, US_WSREMS__City__c, SYN_Sponsor_Responsible__c, Received_via__c, US_WSREMS__State__c, US_WSREMS__Phone__c, SYN_Type_of_Reporter__c, 
                Prescriber_REMS_ID_Number__c, US_WSREMS__Address_Line_1__c, US_WSREMS__REMS_Zip_Code__c, US_WSREMS__Email__c, US_WSREMS__Fax__c, US_WSREMS__Treatment_Start_Date__c, 
                US_WSREMS__Treatment_Stopped_Date__c, SYN_Gender__c, NDC_Code__c, Lot_Number__c, CaseNumber, CreatedBy.Name, Date_of_Awareness__c, Other__c, 
                US_WSREMS__Reporter_First_Name__c, US_WSREMS__Reporter_Last_Name__c, Address_1_Secondary_Office__c, SYN_Event_Description__c, US_WSREMS__Prescriber_First_Name__c, 
                US_WSREMS__Prescriber_Last_Name__c, US_WSREMS__Patient_DOB__c, US_WSREMS__REMS_Prescriber_Fax__c, US_WSREMS__Prescriber_Email__c, US_WSREMS__Participant_FirstName__c, 
                US_WSREMS__Participant_LastName__c, US_WSREMS__Type_s_of_Report__c, US_WSREMS__Prescriber_City__c, US_WSREMS__Prescriber_State__c, US_WSREMS__Prescriber_Zip__c, 
                US_WSREMS__Prescriber_Phone__c, US_WSREMS__Participant_REMS_ID__c, Address_2_Secondary_Office__c, SYN_If_Other_Type_of_Reporter__c, US_WSREMS__Address_Line_2__c, 
                US_WSREMS__Complete_onboarding_training_conducted_b__c, SYN_Patient_Name_Unknown__c, Expiration_Date__c, US_WSREMS__Age__c, Dosage__c, 
                US_WSREMS__Product_Type__c, US_WSREMS__Is_therapy_still_on_going__c, LastModifiedBy.Name, Events_described_in_this_report__c, X5a_Counseled_Patient__c, 
                X8a_Counseled_Patient__c, X6a_Counseled_Patient__c, US_WSREMS__Signature_Pharmacist__c, X1a_Counseled_Patient__c, US_WSREMS__Other_Title_New_Secondary_AR__c, 
                US_WSREMS__Other_Title__c, X2a_Counseled_Patient__c, US_WSREMS__Other_Credentials__c, US_WSREMS__Other_Title_New_Primary_AR__c, X4a_Counseled_Patient__c, 
                X7a_Counseled_Patient__c,US_WSREMS__First_Name_ar__c,US_WSREMS__Last_Name_ar__c, US_WSREMS__Consent_to_contact_reporter__c, Date_reported_to_Sponsor__c, Other_Credential__c, 
                X1_Is_patient_taking_sedative_hypnotics__c, 
                (SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLinks), (SELECT Id, Casuality__c,Death__c,LifeThreatening__c,Hospitalization__c,
                                                                                           PersistentOrSignificantDisability__c,CongenitalAnomaly__c,OtherSerious__c,WasThePatientVaccinated__c,WasThePatientOnProphylactic__c,
                                                                                           WasTheRegimenCompleted__c,US_WSREMS__DateTimeVoicemailorFaxReceived__c,US_WSREMS__OtherPQCComplaint__c,WhatWereTheDates__c,WhatSerotypesBrands__c
                                                                                           FROM US_WSREMS__CasePrograms__r) 
            FROM Case WHERE Id = :recordId
        ];
    }

    public Case getCs() {
        return cs;
    }
}