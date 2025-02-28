/**************************************************************************
    * Name :   SYN_InpatientPharmacyFormController
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  09/02/2022             Initial Version
    *********************************************************************************/
public without sharing class SYN_InpatientPharmacyFormController{
    
    private final Case ac;
    public SYN_InpatientPharmacyFormController() {
    Id recordid = ApexPages.currentPage().getParameters().get('Id'); 
        
                 ac = [SELECT Id,SYN_Pharmacy__c,SYN_Pharmacy__r.Name,SYN_Authorized_Rep__c,SYN_Authorized_Rep__r.Name,SYN_Street_Address__c,US_WSREMS__City__c,US_WSREMS__Fax__c,US_WSREMS__NPI__c,US_WSREMS__Phone_Pharmacyaddress__c,Inpatient_Pharmacy_Type__c,US_WSREMS__State__c,SYN_Zip_Code__c,US_WSREMS__Shipping_Street__c,US_WSREMS__Shipping_City__c,Shipping_Fax__c,Phone_Secondary_Office__c,
                		US_WSREMS__Shipping_Zip_Postal_Code__c,US_WSREMS__REMS_Shipping_State__c ,Title__c,US_WSREMS__Email__c,US_WSREMS__Phone__c,Other_Title__c,Fax_Secondary_Office__c,
                		US_WSREMS__Name__c,US_WSREMS__Signature__c,US_WSREMS__Date__c FROM Case WHERE RecordType.DeveloperName = 'SYN_Inpatient_Pharmacy' AND SYN_Pharmacy__c != null AND SYN_Pharmacy__c =: recordid LIMIT 1];          
           
    }    
    public Case getac() {
        return ac;
    }
    
    

    /************************************************************************
    MethodName : getPharmacyInfo
    Description : 
    *************************************************************************/
  @AuraEnabled
    public static Account getPharmacyInfo(Account acc, String ProgramName) {
        List<US_WSREMS__Affiliation__c> pAffiliations = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__r.Pharmacy_Type__c,US_WSREMS__isActive__c 
                                                                                                                             FROM US_WSREMS__Affiliation__c 
                                                                                                                             WHERE US_WSREMS__Pharmacy__c != null AND US_WSREMS__isActive__c = true AND Default__c = true
                                                                                                                             AND US_WSREMS__Pharmacy_User__c != null AND US_WSREMS__Pharmacy_User__c =: acc.Id LIMIT 1];
       Account pharmacyAcc;
       if(!pAffiliations.isEmpty() && pAffiliations[0].US_WSREMS__Pharmacy__c != null){
      
          pharmacyAcc= [SELECT Id,Name, US_WSREMS__NPI__c,US_WSREMS__Status__c,SYN_Ref_Id__c, Phone, Fax, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,SYN_Signature_Date__c,Address_1_Secondary_Office__c,City_Secondary_Office__c,
                          State_Secondary_Office__c,Zip_Secondary_Office__c,US_WSREMS__REMS_Program__c,Program_Name__c FROM Account WHERE Id =: pAffiliations[0].US_WSREMS__Pharmacy__c LIMIT 1];         
           
       }

       return pharmacyAcc;
    }
 
    
     /************************************************************************
    MethodName : getPharmacyList
    Description : retiurn list of certified pharmacy record based on program.
    *************************************************************************/
    
    @AuraEnabled
    public static Case getAuthorizedReps(Account pharmacyAcc, String programId,Account authrepAccount){
      
        return [SELECT Id,SYN_Pharmacy__c,SYN_Street_Address__c,US_WSREMS__City__c,US_WSREMS__Fax__c,US_WSREMS__NPI__c,US_WSREMS__Phone_Pharmacyaddress__c,Inpatient_Pharmacy_Type__c,US_WSREMS__State__c,SYN_Zip_Code__c,US_WSREMS__Shipping_Street__c,US_WSREMS__Shipping_City__c,Shipping_Fax__c,Phone_Secondary_Office__c,
                US_WSREMS__Shipping_Zip_Postal_Code__c,US_WSREMS__REMS_Shipping_State__c ,Title__c,US_WSREMS__Email__c,US_WSREMS__Phone__c,Other_Title__c,Fax_Secondary_Office__c,
                US_WSREMS__Name__c FROM Case WHERE RecordType.DeveloperName='SYN_Inpatient_Pharmacy' AND  SYN_Pharmacy__c  != null AND SYN_Pharmacy__c  =:  pharmacyAcc.id AND SYN_Authorized_Rep__c  != null AND SYN_Authorized_Rep__c =: authrepAccount.Id LIMIT 1];                                                                                                      
        
    }
}