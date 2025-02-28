public with sharing class Tryvio_PrescriberFormController {
    private final Case caseRec;
    public Id accountRecordId;
    public Tryvio_PrescriberFormController() {

        try{
            accountRecordId = ApexPages.currentPage().getParameters().get('Id');
            system.debug(LoggingLevel.DEBUG,'#### accountRecordId :: '+accountRecordId);

            caseRec = [SELECT Id,US_WSREMS__Knowledge_Assessment__c,US_WSREMS__Address_Line_1__c,US_WSREMS__Preferred_Contact_Method__c,
            US_WSREMS__Ext__c,US_WSREMS__Phone__c,US_WSREMS__Other_Credentials__c,US_WSREMS__Office_Contact__c,
            US_WSREMS__Speciality__c,US_WSREMS__Email__c,US_WSREMS__Comments__c,US_WSREMS__Office_Phone__c,
            US_WSREMS__Fax__c,Office_Practice_Clinic_Name__c,US_WSREMS__State__c,US_WSREMS__Address_Line_2__c,
            US_WSREMS__City__c,US_WSREMS__First_Name__c,US_WSREMS__Zip__c,US_WSREMS__NPI__c,US_WSREMS__Last_Name__c,
            US_WSREMS__REMS_Prescriber_Ext__c,US_WSREMS__Prescriber_Email__c,US_WSREMS__Prescriber_Last_Name__c,
            US_WSREMS__Office_Contact_phone__c,US_WSREMS__Prescriber_First_Name__c,US_WSREMS__Other__c,
            US_WSREMS__NPI_Status__c,US_WSREMS__NPI_Override_Comments__c,US_WSREMS__MI__c,US_WSREMS__Professional_Designation__c,
            US_WSREMS__Last_Name_Secondary_AR__c,US_WSREMS__Secondary_Office_Contact__c,US_WSREMS__First_Name_Secondary_AR__c,
            US_WSREMS__REMS_Alternate_Phone_Ext__c,US_WSREMS__Participant_Email__c,US_WSREMS__REMS_Office_Contact_Phone__c,
            US_WSREMS__Date__c,US_WSREMS__Signature__c,Verbal_Attestation__c,US_WSREMS__Prescriber_Signature__c,
            US_WSREMS__AR_Phone_Secondary_AR__c,US_WSREMS__Signature_Date_Pharmacist__c
            FROM Case 
            WHERE US_WSREMS__Participant__c = :accountRecordId AND RecordType.DeveloperName = 'Prescriber_enrollment' LIMIT 1];
            System.debug(LoggingLevel.DEBUG,'#### caseRec :: '+caseRec);
        }
        catch (Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(msg);
        }  
    }
    
    public Case getcaseRec() {
        return caseRec;
    }
}