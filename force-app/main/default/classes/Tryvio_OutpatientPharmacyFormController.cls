public class Tryvio_OutpatientPharmacyFormController {
    private final Case caseRec;
        
    public Tryvio_OutpatientPharmacyFormController() {
        try{
            Id accountRecordId = ApexPages.currentPage().getParameters().get('Id');
           
            caseRec = [SELECT Id,US_WSREMS__Participant__c,US_WSREMS__Participant__r.Name,US_WSREMS__REMS_Authorized_Rep__c,US_WSREMS__REMS_Authorized_Rep__r.Name,SYN_Street_Address__c,US_WSREMS__City__c,US_WSREMS__Fax__c,US_WSREMS__NPI__c,US_WSREMS__Phone_Pharmacyaddress__c,Inpatient_Pharmacy_Type__c,US_WSREMS__State__c,SYN_Zip_Code__c,US_WSREMS__Shipping_Street__c,US_WSREMS__Shipping_City__c,Shipping_Fax__c,Phone_Secondary_Office__c,
            US_WSREMS__Shipping_Zip_Postal_Code__c,US_WSREMS__REMS_Shipping_State__c ,US_WSREMS__Title__c,US_WSREMS__Credential__c,Title__c,US_WSREMS__Email__c,US_WSREMS__Phone__c,Other_Title__c,Fax_Secondary_Office__c,
            US_WSREMS__Name__c,Credentials__c,SYN_Job_Title__c,US_WSREMS__Signature__c,US_WSREMS__Date__c,US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c, US_WSREMS__Zip__c, US_WSREMS__Office_Phone__c, US_WSREMS__Ext__c, US_WSREMS__Participant_FirstName__c,
            US_WSREMS__Type_of_Report__c, US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Middle_Name__c,US_WSREMS__Participant_LastName__c,US_WSREMS__Participant_Phone__c, US_WSREMS__Office_Contact_phone__c, US_WSREMS__Participant_Fax__c,
            US_WSREMS__REMS_Prescriber_Ext__c,US_WSREMS__Other_Credentials__c,US_WSREMS__Other__c FROM Case 
            WHERE RecordType.DeveloperName = 'Outpatient_Pharmacy_Enrollment' AND US_WSREMS__Participant__c = :accountRecordId LIMIT 1];
            
        } catch (Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(msg);
        }  
    }
    
    public Case getcaseRec() {
        return caseRec;
    }
}