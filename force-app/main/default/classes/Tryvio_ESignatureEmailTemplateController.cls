public with sharing class Tryvio_ESignatureEmailTemplateController {
    public Id caseId;
    public String caseFLName {get;set;}	
    Public Case currentCase {get;set;}
    public String enrollmentFormUrl {get;set;}
    public List<US_WSREMS__REMS_CorrespondenceSettings__mdt> metadataRecord {get;set;}
    
    /**
* Description: getCaseRecords Method is used to return Case Data for sending emails
* @Parameter: Id caseId -> It is the Id of the case
* @return: List<Case> Case List
**/
    public void setcaseId(String caseId) {
        this.caseId = caseId;
        currentCase = [SELECT Id,US_WSREMS__Name__c,Program_Record_Type_Control__c,US_WSREMS__First_Name__c,US_WSREMS__Last_Name__c,US_WSREMS__Program_Name__c,US_WSREMS__Program_Phone_Number__c,US_WSREMS__Program_Fax__c,US_WSREMS__Record_Type_Name__c,US_WSREMS__Participant_LastName__c,US_WSREMS__Participant_FirstName__c FROM Case WHERE Id=:caseId LIMIT 1];
        if(currentCase !=null){
            if(currentCase.Program_Record_Type_Control__c == 'TRYVIO REMS-Outpatient_Pharmacy_Enrollment'){
                caseFLName = currentCase.US_WSREMS__Participant_FirstName__c +' '+ currentCase.US_WSREMS__Participant_LastName__c;
            }else if(currentCase.Program_Record_Type_Control__c == 'TRYVIO REMS-Inpatient_Pharmacy_Enrollment'){
                caseFLName = currentCase.US_WSREMS__Participant_FirstName__c +' '+ currentCase.US_WSREMS__Participant_LastName__c;
            }else{
                caseFLName = currentCase.US_WSREMS__First_Name__c +' '+ currentCase.US_WSREMS__Last_Name__c;
            }
            
            List<US_WSREMS__REMS_CorrespondenceSettings__mdt> metadataRecord ;        
            metadataRecord = [SELECT DeveloperName,US_WSREMS__E_Sign_Url__c From US_WSREMS__REMS_CorrespondenceSettings__mdt Where US_WSREMS__Record_Type_Developer_Name__c=:currentCase.US_WSREMS__Record_Type_Name__c AND (US_WSREMS__Reference_Field__c='US_WSREMS__Signature__c' OR US_WSREMS__Reference_Field__c='US_WSREMS__Prescriber_Signature__c') AND US_WSREMS__Recipient_Email_Field__c='US_WSREMS__Email__c' AND US_WSREMS__Template_Name__c='Tryvio_ESignature'];
            if(!metadataRecord.isEmpty()){
                enrollmentFormUrl = metadataRecord[0].US_WSREMS__E_Sign_Url__c+currentCase.Id;
                
            }
            
        }
    }
    public string getcaseId(){
        return caseId;
    }
}