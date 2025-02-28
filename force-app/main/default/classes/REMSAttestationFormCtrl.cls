/**************************************************************************
* Name :   REMSAttestationFormCtrl

Modification Log:
----------------------------------------------------------------------------------
Developer               Date                   Description
-----------------------------------------------------------------------------------
Tarun Earle           12/07/2024              Initial Version
*********************************************************************************/

public without sharing class REMSAttestationFormCtrl {
 @AuraEnabled(cacheable=true)
    public static Case getCurrentPatientInfo(String caseId) {
      
       return [SELECT Id,US_WSREMS__First_Name__c,US_WSREMS__Middle_Name__c,US_WSREMS__Last_Name__c,US_WSREMS__Name__c,US_WSREMS__DOB__c,Primary_Language__c,US_WSREMS__Email__c,US_WSREMS__Zip__c,
               US_WSREMS__Phone__c,US_WSREMS__Office_Phone__c,US_WSREMS__Address_Line_1__c,SYN_Alternate_Phone__c,Best_time_to_call__c,SYN_Street_Address__c,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Fax__c,
               US_WSREMS__MI__c,US_WSREMS__Speciality__c,US_WSREMS__Professional_Designation__c,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Address_Line_2__c,US_WSREMS__Ext__c,US_WSREMS__Comments__c,US_WSREMS__Prescriber_First_Name__c,
               US_WSREMS__Prescriber_Last_Name__c,US_WSREMS__Prescriber_Email__c,US_WSREMS__Office_Contact_phone__c,US_WSREMS__REMS_Prescriber_Ext__c,US_WSREMS__First_Name_Secondary_AR__c,US_WSREMS__Last_Name_Secondary_AR__c,
               US_WSREMS__Participant_Email__c,US_WSREMS__REMS_Office_Contact_Phone__c,US_WSREMS__REMS_Alternate_Phone_Ext__c,US_WSREMS__Knowledge_Assessment__c,
               US_WSREMS__Facility_Type__c,US_WSREMS__Shipping_Address_Line_1__c,US_WSREMS__Shipping_Address_Line_2__c,US_WSREMS__Participant_City__c,US_WSREMS__SLN_Issued_State__c,US_WSREMS__REMS_Zip_Code__c,Shipping_Fax__c,
               US_WSREMS__Participant_FirstName__c,US_WSREMS__Participant_LastName__c,US_WSREMS__Title__c,US_WSREMS__REMS_Prescriber_Fax__c,US_WSREMS__Participant_Phone__c,
               US_WSREMS__Type_of_Report__c,US_WSREMS__REMS_Job_Title__c,US_WSREMS__Credential__c,US_WSREMS__REMS_Ext__c,US_WSREMS__Participant_Fax__c,Office_Practice_Clinic_Name__c,
               SYN_Zip_Code__c,US_WSREMS__Shipping_Street__c,RecordType.DeveloperName,US_WSREMS__Shipping_City__c,US_WSREMS__Shipping_Zip_Postal_Code__c,Status, Lastmodifiedby.name,lastmodifiedby.FirstName, lastmodifiedby.LastName,
               US_WSREMS__NPI__c,Office_contact_name_Primary_Office__c,US_WSREMS__Patient_Risk_Category__c,Negative_Pregnancy_Test_Completed__c,US_WSREMS__Prescriber_State__c,
               US_WSREMS__Signature__c,US_WSREMS__Prescriber_Signature__c,US_WSREMS__Date__c,US_WSREMS__Patient__c,US_WSREMS__Patient__r.name,US_WSREMS__Participant__c,US_WSREMS__REMS_Service_Summary__c
               FROM CASE WHERE Id =: caseId LIMIT 1];          
           
     }
    
     /********************************************************************************************************************************************************
    Method Name     : saveSignature
    Description     : when user click on submit button on Macitentan REMS Patient Enrollment Form, Update case fields and Save the signauture the on patient account
    ********************************************************************************************************************************************************** */ 
    @AuraEnabled
    public static string saveSignature(Case caseObj,String agreementStatus, String b64SignData) {
            if(caseObj.RecordType.DeveloperName=='Prescriber_enrollment'){
              caseObj.US_WSREMS__Prescriber_Signature__c = 'Yes';
              caseObj.US_WSREMS__Signature_Date_Pharmacist__c = System.today();
            }else{

                caseObj.US_WSREMS__Signature__c='Yes';
                caseObj.US_WSREMS__Date__c= System.today();
            }

              try{
                  update caseObj;

                  System.debug('Case Status post e-sign '+caseObj.Status);
                  System.debug('Case username post e-sign '+caseObj.lastmodifiedby.name);
                  System.debug('Case username post e-sign '+caseObj.lastmodifiedby.FirstName);
                  System.debug('Case username post e-sign '+caseObj.lastmodifiedby.LastName);
                  

                  if(caseObj.US_WSREMS__REMS_Service_Summary__c != null){
                      //closeOpenTasks(caseObj);
                  }
                  return SavePrescriberSignature(caseObj.US_WSREMS__Participant__c, agreementStatus, b64SignData,'Signature'); 
                  
              }catch(exception e){
                  system.debug('Error--------------'+e.getMessage());
                   return e.getMessage();
              }
     }
     
     /********************************************************************************************************************************************************
    Method Name     : closeOpenTasks
    Description     : when patient signature the enrollment form, close all open tasks
    ********************************************************************************************************************************************************** 
    public static void closeOpenTasks(Case caseObj) {
              List<Task> updateTaskList = new List<Task>();
              List<Task> taksList = [SELECT Id,Status FROM Task WHERE Whatid =: caseObj.US_WSREMS__REMS_Service_Summary__c AND Status!= 'Completed'];
              if(taksList.isEmpty()){
                  for(Task t: taksList){
                      t.Status ='Completed';
                      updateTaskList.add(t);
                  }
              }
              try{
                 if(!updateTaskList.isEmpty()){
                     insert updateTaskList; 
                 }
              }catch(exception e){
                  system.debug('Error--------------'+e.getMessage());
              }
     }
     
     /********************************************************************************************************************************************************
    Method Name     : SavePrescriberSignature
    Description     :  Save the signauture the on patient account
    ********************************************************************************************************************************************************** */ 
     public static String SavePrescriberSignature(String accountId, String agreementStatus, String b64SignData,String fileName){
        try {
            //Create Attachment
            Attachment oAttach = new Attachment(ParentId = accountId,Name = fileName,
                                         Body =  EncodingUtil.base64Decode(b64SignData),contentType = 'image/jpeg');
                      
            insert oAttach;
            return '';
        }
        catch (Exception e)
        {
            String errorMessage = e.getMessage();
            Integer occurence;
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                occurence = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;
                errorMessage = errorMessage.mid(occurence, errorMessage.length());
                occurence = errorMessage.lastIndexOf(':');
                errorMessage = errorMessage.mid(0, occurence);
            }            
            return errorMessage;
        }
    }
    
     /********************************************************************************************************************************************************
    Method Name     : addPatientEnrollmentFormtoAccount
    Description     : attach Macitentan REMS Patient Enrollment Form with signature on patient account when user click on submit button on enrollment form
    ********************************************************************************************************************************************************** */ 
    @AuraEnabled
    public static string addPatientEnrollmentFormtoAccount(Case caseObj) {
        PageReference PDf =  Page.Maci_Patient_Enrollment_Form;//Replace attachmentPDf with the page you have rendered as PDF
        PDf.getParameters().put('Id',caseObj.US_WSREMS__Participant__c);
        PDf.setRedirect(true);
        Attachment attach = new Attachment();
        Blob oBlob ;
        if(Test.isRunningTest()) { 
            oBlob = blob.valueOf('Unit.Test');
        } else {
            oBlob = PDf.getContent();
        }
        attach.Body = oBlob;
        attach.Name = caseObj.US_WSREMS__Name__c+' '+ caseObj.US_WSREMS__First_Name__c+' '+caseObj.US_WSREMS__Last_Name__c+' enrollment form.pdf';
        attach.IsPrivate = false;
        attach.ParentId = caseObj.US_WSREMS__Participant__c;
        try{
           insert attach;
        }catch(exception e){
          system.debug('Error--------------'+e.getMessage());
           return e.getMessage();
        }
        return '';  
     }
}