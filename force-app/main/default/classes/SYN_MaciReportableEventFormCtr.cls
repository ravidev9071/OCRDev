/**************************************************************************
* Name :   SYN_MaciReportableEventFormCtr

Modification Log:
----------------------------------------------------------------------------------
Developer               Date                   Description
-----------------------------------------------------------------------------------
DG                      23/03/2023             Initial Version
*********************************************************************************/

public without sharing class SYN_MaciReportableEventFormCtr{
    
    private final Case cs;
    
    
    
    public SYN_MaciReportableEventFormCtr() {
        
      
         Id recordid = ApexPages.currentPage().getParameters().get('Id');
        
                cs= [SELECT id,SYN_Reporter__c,SYN_Reporter_First_Name__c,SYN_Reporter_Last_Name__c,X1_Participant_REMS_ID__c,US_WSREMS__Status__c,SYN_Street_Address__c,US_WSREMS__City__c,
                    US_WSREMS__State__c,SYN_Type_of_Report__c,SYN_Sponsor_Responsible__c,Received_via__c,Name__c,US_WSREMS__Phone__c,Relationship__c,
                    SYN_Zip_Code__c,SYN_Reporter_Phone__c,Shipping_Fax__c,SYN_Type_of_Reporter__c,If_Other_explain__c,Date_Voicemail_or_Fax_received__c,
                    SYN_Prescriber__c,SYN_Prescriber_First_Name__c,SYN_Prescriber_Last_Name__c,Prescriber_REMS_ID_Number__c,Prescriber_Status__c,US_WSREMS__Address_Line_1__c,
                    City_Secondary_Office__c,State_Secondary_Office__c,US_WSREMS__REMS_Zip_Code__c,US_WSREMS__Phone_ar__c,US_WSREMS__Fax__c,US_WSREMS__Email__c,
                    US_WSREMS__Patient__c,US_WSREMS__First_Name__c,US_WSREMS__Last_Name__c,SYN_Patient_REMS_ID_Number__c,Patient_Status__c,SYN_Gender__c,
                    SYN_Is_therapy_still_on_going__c,US_WSREMS__Treatment_Start_Date__c,US_WSREMS__Treatment_Stopped_Date__c,
                    US_WSREMS__Phone_Pharmacyaddress__c,SYN_Alternate_Phone__c,US_WSREMS__Email_ar__c,US_WSREMS__DOB__c,Age__c,
                    Sponsor_Responsible_1__c, NDC_Code__c,Lot_Number__c,Sponsor_Responsible_2__c,NDC_Code_2__c,Lot_Number_2__c,
                    US_WSREMS__Date_of_Event__c,SYN_Event_Description__c,SYN_Attachments__c,US_WSREMS__Patient_Risk_Category__c,Recent_Patient_Reproductive_Status_Date__c,Created_result_of_treatment_interruption__c,
                    US_WSREMS__First_Name_ar__c,Address_1_Secondary_Office__c,US_WSREMS__Shipping_City__c,SYN_Shipping_State__c,US_WSREMS__Shipping_Zip_Postal_Code__c,
                    Phone_Secondary_Office__c,Fax_Secondary_Office__c,US_WSREMS__Email_PharmacyAddress__c,US_WSREMS__Last_Name_ar__c,SYN_Case_Id__c,US_WSREMS__REMS_Case_Id__c,Date_of_Awareness__c,Date_of_Report__c,CaseNumber,CreatedBy.Name,
                    Date_and_Time_Voicemail_or_Fax_Received__c,Other__c,attachmentChecked__c, US_WSREMS__Reporter_First_Name__c, US_WSREMS__Reporter_Last_Name__c, US_WSREMS__Reporter__r.US_WSREMS__REMS_ID__c,
                    US_WSREMS__Reporter__r.US_WSREMS__Status__c, US_WSREMS__Prescriber_First_Name__c,US_WSREMS__Prescriber_Last_Name__c,US_WSREMS__Prescriber__r.US_WSREMS__Status__c,
                    US_WSREMS__Patient_DOB__c, US_WSREMS__Participant_FirstName__c,US_WSREMS__Participant_LastName__c, US_WSREMS__Prescriber_Email__c,US_WSREMS__REMS_Prescriber_Fax__c,US_WSREMS__Description__c,
                    US_WSREMS__Prescriber_Phone__c,US_WSREMS__Prescriber_Zip__c,US_WSREMS__Prescriber_State__c,  US_WSREMS__Prescriber_City__c,US_WSREMS__Prescriber_Address__c,US_WSREMS__Address__c,US_WSREMS__Type_s_of_Report__c,US_WSREMS__Pharmacist_Confirmation__c,Events_described_in_this_report__c,Type_of_PQC_Compliant__c,Outcome_of_event__c,US_WSREMS__Prescriber_Date__c,US_WSREMS__Prescription_Date__c,Other_Credential__c,US_WSREMS__Other_Title__c,US_WSREMS__Age__c,
                    US_WSREMS__Primary_Language__c, US_WSREMS__Type_of_Report__c,Createddate, SYN_Patient_Name_Unknown__c,US_WSREMS__Consent_to_contact_reporter__c,US_WSREMS__Participant_REMS_ID__c,US_WSREMS__Consent_to_contact_reporter_2__c, subject, US_WSREMS__Dosage_Form__c, US_WSREMS__Product_Type__c, 
                    Expiration_Date__c, Dosage__c, US_WSREMS__Is_therapy_still_on_going__c,US_WSREMS__Prescriber_Fax__c,US_WSREMS__Reporter_Email__c,US_WSREMS__Reporter_Phone__c,SYN_Prescriber_Contacted__c,US_WSREMS__Gender__c,US_WSREMS__Other__c,Date_reported_to_Sponsor__c,US_WSREMS__Patient_Phone__c,US_WSREMS__Zip__c,US_WSREMS__Program_Type__c,X1_Is_patient_taking_sedative_hypnotics__c,US_WSREMS__Reporter_Fax__c,
                    (SELECT Id, LinkedEntityId, ShareType, Visibility, ContentDocumentId FROM ContentDocumentLinks)
                    FROM Case where id =: recordId];
           
    }
    
    public Case getCs() {
        return cs;
    }
}