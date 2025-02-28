/**************************************************************************
    * Name :   MaciPrescriberEnrollmentFormController
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
      Swetha S			 03/03/2023             Initial Version
    *********************************************************************************/

public without sharing class MaciPrescriberEnrollmentFormController{
    
    private final Account ac;
    
    
    
    public MaciPrescriberEnrollmentFormController() {
        
        List<User> userList =[SELECT id, AccountId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        if(!userList.isEmpty()){
            
            
                ac= [SELECT id,Name,FirstName,MiddleName,LastName,Email_address__c,US_WSREMS__NPI__c,SYN_Professional_Designation__c,Alternate_Contact__c,Alternate_Contact_Name__c,SYN_Alternate_Phone__c,Affiliated_hospital__c,Specialty__c,US_WSREMS__Preferred_Contact_Method__c,Phone,Fax,
                     Primary_contact_name__c,US_WSREMS__Email__c,Office_Practice_Clinic_Name__c,Office_Practice_Clinic_Name1__c,office_contact_phone_Primary_Office__c,US_WSREMS__EXT__c,ShippingStreet,ShippingCity,ShippingPostalCode,ShippingState,Account_Name_Secondary_Office__c,Affiliated_hospital_Secondary_Offic__c,Specialty_Secondary_Office__c,Preferred_Contact_Method_Secondary_Offic__c,
                     Phone_Secondary_Office__c,Fax_Secondary_Office__c,Secondary_contact_name__c,Email_Secondary_Office__c,Secondary_contact_phone__c,Ext_Secondary_Office__c,Address_1_Secondary_Office__c,Address_2_Secondary_Office__c,
                     City_Secondary_Office__c,State_Secondary_Office__c,Zip_Secondary_Office__c,SYN_Signature__c,SYN_Signature_Date__c FROM Account WHERE Id =: userList[0].AccountId];
                
            
        }
    }
    
    public Account getAc() {
        return ac;
    }
}