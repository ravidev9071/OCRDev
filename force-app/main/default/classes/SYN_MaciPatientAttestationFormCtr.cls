/**************************************************************************
    * Name :   SYN_MaciPatientAttestationFormCtr
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  16/03/2023             Initial Version
    *********************************************************************************/
public without sharing class SYN_MaciPatientAttestationFormCtr{
     
     /********************************************************************************************************************************************************
    Method Name     : getCurrentPatientInfo
    Description     : by using thie method, get the patient enrollment info and display on Macitentan REMS Patient Enrollment Form 
    ********************************************************************************************************************************************************** */
    @AuraEnabled(cacheable=true)
    public static Case getCurrentPatientInfo(String caseId) {
      
       return [SELECT Id,US_WSREMS__First_Name__c,US_WSREMS__Middle_Name__c,US_WSREMS__Last_Name__c,US_WSREMS__DOB__c,Primary_Language__c,US_WSREMS__Email__c,
               US_WSREMS__Phone__c,SYN_Alternate_Phone__c,Best_time_to_call__c,SYN_Street_Address__c,US_WSREMS__City__c,US_WSREMS__State__c,
               SYN_Zip_Code__c,Legal_Guardian_Name__c,Legal_Guardian_Relationship__c,Legal_Guardian_Email__c,Legal_Guardian_Phone__c,
               Emergency_Contact_Name__c,Emergency_Contact_Relationship__c,Emergency_Contact_Phone__c,
               SYN_Prescriber__c,Prescriber_Status__c,SYN_Prescriber_First_Name__c,SYN_Prescriber_Middle_Name__c,SYN_Prescriber_Last_Name__c,
               US_WSREMS__Shipping_Street__c,US_WSREMS__Shipping_City__c,SYN_Shipping_State__c,US_WSREMS__Shipping_Zip_Postal_Code__c,
               SYN_Prescriber_Phone__c,US_WSREMS__NPI__c,SYN_Prescriber_Fax__c,Office_contact_name_Primary_Office__c,Email_address__c,
               SYN_Prescriber_Signature__c,SYN_Prescriber_Signature_Date__c,US_WSREMS__Patient_Risk_Category__c,Negative_Pregnancy_Test_Completed__c,
               US_WSREMS__Signature__c,US_WSREMS__Date__c,US_WSREMS__Patient__c,US_WSREMS__Patient__r.name,US_WSREMS__REMS_Service_Summary__c
               FROM CASE WHERE Id =: caseId LIMIT 1];          
           
     }
    
     /********************************************************************************************************************************************************
    Method Name     : saveSignature
    Description     : when user click on submit button on Macitentan REMS Patient Enrollment Form, Update case fields and Save the signauture the on patient account
    ********************************************************************************************************************************************************** */ 
    @AuraEnabled
    public static string saveSignature(Case caseObj,String agreementStatus, String b64SignData) {
              caseObj.US_WSREMS__Signature__c='Yes';
              caseObj.US_WSREMS__Date__c= System.today();
              try{
                  update caseObj;
                  if(caseObj.US_WSREMS__REMS_Service_Summary__c != null){
                      closeOpenTasks(caseObj);
                  }
                  return SavePrescriberSignature(caseObj.US_WSREMS__Patient__c, agreementStatus, b64SignData,'PatientSignature'); 
                  
              }catch(exception e){
                  system.debug('Error--------------'+e.getMessage());
                   return e.getMessage();
              }
     }
     
     /********************************************************************************************************************************************************
    Method Name     : closeOpenTasks
    Description     : when patient signature the enrollment form, close all open tasks
    ********************************************************************************************************************************************************** */ 
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
            Attachment n = new Attachment(ParentId = accountId,Name = fileName,
                                         Body =  EncodingUtil.base64Decode(b64SignData),contentType = 'image/jpeg');
                                         
            insert n;
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
        PDf.getParameters().put('Id',caseObj.US_WSREMS__Patient__c);
        PDf.setRedirect(true);
        Attachment attach = new Attachment();
        Blob b ;
        if(Test.isRunningTest()) { 
            b = blob.valueOf('Unit.Test');
        } else {
            b = PDf.getContent();
        }
        attach.Body = b;
        attach.Name = caseObj.US_WSREMS__First_Name__c+' '+caseObj.US_WSREMS__Last_Name__c+' enrollment form.pdf';
        attach.IsPrivate = false;
        attach.ParentId = caseObj.US_WSREMS__Patient__c;
        try{
           insert attach;
        }catch(exception e){
          system.debug('Error--------------'+e.getMessage());
           return e.getMessage();
        }
        return '';  
     }

}