/**************************************************************************
    * Name :   PharmacyLocatorController 
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  08/11/2022             Initial Version
    *********************************************************************************/
public without sharing class SYN_PharmacyLocatorController {
    
    
    /************************************************************************
    MethodName : getPharmacyList
    Description : retiurn list of certified pharmacy record based on program.
    *************************************************************************/
    @AuraEnabled
    public static List<Account> getPharmacyList(String programId){
        List<String> pharmacyName = System.Label.Maci_Ignore_Pharmacies.Split(';');
            return [SELECT Id,Name,Pharmacy_Type__c,Phone,FAX,US_WSREMS__NPI__c,Address_1_Secondary_Office__c,City_Secondary_Office__c,Zip_Secondary_Office__c FROM Account WHERE Recordtype.DeveloperName ='Pharmacy' AND US_WSREMS__REMS_Program__c != null AND  US_WSREMS__REMS_Program__c =: programId AND Name NOT IN : pharmacyName AND US_WSREMS__Status__c = 'Certified' Order By Name ASC LIMIT 49999];
    }
    
   
}