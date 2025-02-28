/**
 * DTO (Data Transfer Object) to hold OCR staging data, form fields, 
 * and any error messages in a single return object for the LWC.
 */
public with sharing class FormDataWrapper {
    @AuraEnabled public String jsonPayload;                   // The JSON from OCRStaging__c.Payload__c
    @AuraEnabled public String formName;                      // The name of the form
    @AuraEnabled public Id     formId;                        // The ID of the form
    @AuraEnabled public Id     ocrStagingId;                  // The ID of the OCR Staging record
    //@AuraEnabled public List<FormField__c> formFields;        // The related form fields
    @AuraEnabled public String errorMessage;                  // Any error messages
}