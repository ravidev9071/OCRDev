/**************************************************************************
    * Name :   SYN_MaciPatientEnrollmentViewFormCtr
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  16/03/2023             Initial Version
    *********************************************************************************/

    public without sharing class SYN_MaciPatientEnrollmentViewFormCtr{

    private final Case cs;
    
    private final List<Attachment> atchmnt;
    
    Private string attachmentId {get;set;}
        
    public List<Id> attachmentIds;
    private List<Id> attachments;


    private string patientId;
    
    public SYN_MaciPatientEnrollmentViewFormCtr() {
        Id recordid = ApexPages.currentPage().getParameters().get('Id');
        
        
        cs = [SELECT Id,US_WSREMS__First_Name__c,US_WSREMS__Middle_Name__c,US_WSREMS__Last_Name__c,US_WSREMS__DOB__c,Primary_Language__c,US_WSREMS__Email__c,
               US_WSREMS__Phone__c,SYN_Alternate_Phone__c,Best_time_to_call__c,SYN_Street_Address__c,US_WSREMS__City__c,US_WSREMS__State__c,
               SYN_Zip_Code__c,Legal_Guardian_Name__c,Legal_Guardian_Relationship__c,Legal_Guardian_Email__c,Legal_Guardian_Phone__c,
               Emergency_Contact_Name__c,Emergency_Contact_Relationship__c,Emergency_Contact_Phone__c,
               SYN_Prescriber__c,Prescriber_Status__c,SYN_Prescriber_First_Name__c,SYN_Prescriber_Middle_Name__c,SYN_Prescriber_Last_Name__c,
               US_WSREMS__Shipping_Street__c,US_WSREMS__Shipping_City__c,SYN_Shipping_State__c,US_WSREMS__Shipping_Zip_Postal_Code__c,
               SYN_Prescriber_Phone__c,US_WSREMS__NPI__c,SYN_Prescriber_Fax__c,Office_contact_name_Primary_Office__c,Email_address__c,
               SYN_Prescriber_Signature__c,SYN_Prescriber_Signature_Date__c,US_WSREMS__Patient_Risk_Category__c,Negative_Pregnancy_Test_Completed__c,
               US_WSREMS__Signature__c,US_WSREMS__Date__c,US_WSREMS__Patient__c,US_WSREMS__Patient__r.name FROM CASE WHERE US_WSREMS__Patient__c != null AND US_WSREMS__Patient__c =: recordid  LIMIT 1];

        
         atchmnt = [SELECT Id FROM Attachment WHERE ParentId =: cs.US_WSREMS__Patient__c AND Name = 'PatientSignature' LIMIT 1];
         attachmentIds = new List<Id>();
         if(!atchmnt.isEmpty()){
             attachmentIds.add(atchmnt[0].Id);
         }
        
         
    
    }
   
    /********************************************************************************************************************************************************
    Method Name     : getCs
    Description     : get the current patient info and disply in vf page
    ********************************************************************************************************************************************************** */
    public Case getCs() {
            return cs;
    }
    
    /********************************************************************************************************************************************************
    Method Name     : getAttachments
    Description     : get the patient signature and display it on vf page
    ********************************************************************************************************************************************************** */
     public List<Id> getAttachments(){
         return attachmentIds;
     }
  }