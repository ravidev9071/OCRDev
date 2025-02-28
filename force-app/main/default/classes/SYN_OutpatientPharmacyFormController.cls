/**************************************************************************
    * Name :   SYN_InpatientPharmacyFormController
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Swetha S  02/05/2023             Initial Version
    *********************************************************************************/
public without sharing class SYN_OutpatientPharmacyFormController{
private final Case ac;
    
    
   
    public SYN_OutpatientPharmacyFormController() {
      Id recordid = ApexPages.currentPage().getParameters().get('Id');         
                 ac = [SELECT Id,SYN_Pharmacy__c,SYN_Pharmacy__r.Name,SYN_Authorized_Rep__c,SYN_Authorized_Rep__r.Name,SYN_Street_Address__c,US_WSREMS__City__c,US_WSREMS__Fax__c,US_WSREMS__NPI__c,US_WSREMS__Phone_Pharmacyaddress__c,Inpatient_Pharmacy_Type__c,US_WSREMS__State__c,SYN_Zip_Code__c,US_WSREMS__Shipping_Street__c,US_WSREMS__Shipping_City__c,Shipping_Fax__c,Phone_Secondary_Office__c,
                		US_WSREMS__Shipping_Zip_Postal_Code__c,US_WSREMS__REMS_Shipping_State__c ,Title__c,US_WSREMS__Email__c,US_WSREMS__Phone__c,Other_Title__c,Fax_Secondary_Office__c,
                		US_WSREMS__Name__c,Credentials__c,SYN_Job_Title__c,US_WSREMS__Signature__c,US_WSREMS__Date__c FROM Case WHERE RecordType.DeveloperName = 'SYN_Outpatient_Pharmacy' AND SYN_Pharmacy__c != null AND SYN_Pharmacy__c =:recordid LIMIT 1];          
           
    }
    
    
    public Case getac() {
        return ac;
    }
}