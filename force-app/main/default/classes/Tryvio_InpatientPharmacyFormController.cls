public with sharing class Tryvio_InpatientPharmacyFormController {
    private final Case caseRec;
    
    public Tryvio_InpatientPharmacyFormController() {
        try{
            Id accountRecordId = ApexPages.currentPage().getParameters().get('Id');
            system.debug('#### accountRecordId :: '+accountRecordId);

            caseRec = [SELECT Id,US_WSREMS__City__c,US_WSREMS__First_Name__c,US_WSREMS__Other__c,US_WSREMS__Preferred_Contact_Method__c,
            US_WSREMS__NPI__c,US_WSREMS__NPI_Status__c,US_WSREMS__State__c,Program_Record_Type_Control__c,
            US_WSREMS__Phone__c,US_WSREMS__Name__c,US_WSREMS__Outcome__c,CaseNumber,US_WSREMS__Zip__c,
            US_WSREMS__Fax__c,US_WSREMS__Title__c,OwnerId,Status,CreatedById,US_WSREMS__Last_Name__c,
            US_WSREMS__REMS_Project_Code__c,US_WSREMS__Email__c,US_WSREMS__Incomplete_Reasons__c,
            US_WSREMS__Channel__c,US_WSREMS__REMS_Authorized_Rep__c,US_WSREMS__Hold_Account__c,Shipping_Fax__c,
            US_WSREMS__Participant_FirstName__c,US_WSREMS__Facility_Type__c,US_WSREMS__Participant_LastName__c,
            US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Zip_Code__c,US_WSREMS__Date__c,US_WSREMS__Comments__c,
            US_WSREMS__REMS_ID__c,US_WSREMS__Ext__c,US_WSREMS__Shipping_Address_Line_2__c,US_WSREMS__SLN_Issued_State__c,
            US_WSREMS__MI__c,US_WSREMS__NPI_Override_Comments__c,US_WSREMS__Middle_Name__c,US_WSREMS__REMS_Prescriber_Ext__c,
            US_WSREMS__REMS_Prescriber_Fax__c,LastModifiedDate,US_WSREMS__Shipping_Address_Line_1__c,US_WSREMS__Participant_City__c,
            US_WSREMS__Address_Line_2__c,LastModifiedById,Comments,US_WSREMS__Office_Contact_phone__c,US_WSREMS__Ship_to_Address_Same_as_Above__c,
            US_WSREMS__Other_Credentials__c,US_WSREMS__Office_Phone__c,US_WSREMS__Program_Picklist__c,US_WSREMS__Participant_Phone__c,
            US_WSREMS__Signature__c,CreatedDate,US_WSREMS__Address_Line_1__c,SYN_Ext__c,US_WSREMS__Signature_Date_Pharmacist__c,
            
            Credentials__c,US_WSREMS__REMS_Authorized_Rep__r.Name,US_WSREMS__Credential__c,US_WSREMS__Other_Title__c
            FROM Case 
            WHERE RecordType.DeveloperName = 'Inpatient_Pharmacy_Enrollment' AND US_WSREMS__Participant__c = :accountRecordId LIMIT 1];
            
            System.debug('#### caseRec :: '+caseRec);
        }
  
        catch (Exception ex)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(msg);
        }  
    }
    
    public Case getcaseRec() {
        return caseRec;
    }
}