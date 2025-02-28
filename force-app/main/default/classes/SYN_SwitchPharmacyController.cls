/**************************************************************************
    * Name :   SYN_SwitchPharmacyController
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  09/02/2022             Initial Version
    *********************************************************************************/
    public without sharing class SYN_SwitchPharmacyController {
    
    @AuraEnabled 
    public static Map<String, String> getPharmacyList(String programId, String pharmacyType){
        Map<String, String> pharmacyMap = new Map<String, String>();
        Account acc = MaciPortalCustomController.getPharmacistInfo();
        if(acc.US_WSREMS__Status__c == 'Active'){
             List<US_WSREMS__Affiliation__c> pharmacyAffiliations = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,Default__c,AR_Category__c,US_WSREMS__Pharmacy__r.Name
                                                                                                     FROM US_WSREMS__Affiliation__c 
                                                                                                     WHERE US_WSREMS__Pharmacy__c != null AND US_WSREMS__Pharmacy__r.Pharmacy_Type__c =: pharmacyType
                                                                                                     AND US_WSREMS__isActive__c = true AND US_WSREMS__REMSProgram__c =: programId AND Status__c = 'Active'
                                                                                                     AND US_WSREMS__Pharmacy_User__c != null AND US_WSREMS__Pharmacy_User__c =: acc.Id];
             
             if(!pharmacyAffiliations.isEmpty()){
                 for(US_WSREMS__Affiliation__c aff: pharmacyAffiliations){
                     pharmacyMap.put(aff.US_WSREMS__Pharmacy__r.Name,aff.Id);
                 
                 }
             }
        }
        
        return pharmacyMap;        
    }
    
    @AuraEnabled 
    public static string updateDefaultPharmacy(String recordId){
    
        US_WSREMS__Affiliation__c affilcation = [SELECT id,US_WSREMS__Pharmacy_User__c FROM US_WSREMS__Affiliation__c WHERE Id =: recordId LIMIT 1];
        
        string pharmacyUserId = affilcation.US_WSREMS__Pharmacy_User__c;
        
        List<US_WSREMS__Affiliation__c> defaultAffilcation = [SELECT id,US_WSREMS__Pharmacy_User__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Pharmacy_User__c =: pharmacyUserId  AND Default__c = true LIMIT 1];

        if(!defaultAffilcation.isEmpty()){
            defaultAffilcation[0].Default__c = false;
            update defaultAffilcation;
        }
        
        US_WSREMS__Affiliation__c aff= new US_WSREMS__Affiliation__c(id=recordId);
        aff.Default__c = true;
        try{
            update aff;
            return '';    
        }catch(exception e){
            return e.getMessage();
        }
   
            
    }
    
    
    /********************************************************************************************************************************************************
    Method Name     : getUserDefaultPharmacyInfo()
    Description     : Get the current login user pharmacy details
                      return: Account data of the logged in portal user.
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    public static US_WSREMS__Affiliation__c getUserDefaultPharmacyInfo(String UserId) {
        User u = [SELECT Id, Name,Email, UserType, Role__c, ContactId, AccountId, Program__c FROM User WHERE Id =: UserId LIMIT 1];         
        List<US_WSREMS__Affiliation__c>  aff;
        List<US_WSREMS__Affiliation__c>  pharmacyAffiliations = new List<US_WSREMS__Affiliation__c>();
        String recordTypeName;
        if(u != null && u.Role__c != null){
            if(u.Role__c == 'Outpatient Pharmacy' ){
                recordTypeName = 'SYN_Outpatient_Pharmacy';
            }else if(u.Role__c == 'Inpatient Pharmacy'){
                recordTypeName = 'SYN_Inpatient_Pharmacy';
            }
        }
         
        if(u.AccountId != null){
             pharmacyAffiliations = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,Default__c,AR_Category__c,US_WSREMS__Pharmacy__r.Name,US_WSREMS__Pharmacy__r.Pharmacy_Type__c
                                                                                                     FROM US_WSREMS__Affiliation__c 
                                                                                                     WHERE US_WSREMS__Pharmacy__c != null 
                                                                                                     AND US_WSREMS__isActive__c = true AND US_WSREMS__REMSProgram__c != null AND US_WSREMS__REMSProgram__r.Name ='Macitentan REMS' AND Status__c = 'Active'
                                                                                                     AND US_WSREMS__Pharmacy_User__c != null AND US_WSREMS__Pharmacy_User__c =: u.AccountId AND Default__c = true LIMIT 1];
        }
        
        if(!pharmacyAffiliations.isEmpty()){
             attachEnrollmentFormonAccount(pharmacyAffiliations[0].US_WSREMS__Pharmacy__r.Name,pharmacyAffiliations[0].US_WSREMS__Pharmacy__c,pharmacyAffiliations[0].US_WSREMS__Pharmacy__r.Pharmacy_Type__c);
             return pharmacyAffiliations[0];
        }
        
        return null;
    }
    
    
     /********************************************************************************************************************************************************
    Method Name     : attachInpatientEnrollmentFormonAccount()
    Description     : attach Macitentan REMS Inpatient Enrollment Form
    ********************************************************************************************************************************************************** */  
    
    public static void attachEnrollmentFormonAccount(string PharmcyName, string PharmcyId, String pharmcyType) {
        String enrollmentName = PharmcyName+' '+'enrollment form.pdf';
        List<Attachment> attchmentList = [SELECT Id,Name FROM Attachment WHERE ParentId =: PharmcyId AND Name =: enrollmentName LIMIT 1];
        if(attchmentList.isEmpty()){
            PageReference PDf ;
            if(pharmcyType == 'Inpatient'){
                PDf =  Page.Maci_Inpatient_enrollment;//Replace attachmentPDf with the page you have rendered as PDF
            }else if(pharmcyType == 'Outpatient'){
                PDf =  Page.Maci_Outpatient_enrollment;//Replace attachmentPDf with the page you have rendered as PDF
            }
            PDf.getParameters().put('Id',PharmcyId);
            PDf.setRedirect(true);
            Attachment attach = new Attachment();
            Blob b ;
            if(Test.isRunningTest()) { 
                b = blob.valueOf('Some.Test');
            } else {
                b = PDf.getContent();
            }
            attach.Body = b;
            attach.Name = PharmcyName+' '+'enrollment form.pdf';
            attach.IsPrivate = false;
            attach.ParentId = PharmcyId;
            try{
               insert attach;
            }catch(exception e){
              system.debug('Error--------------'+e.getMessage());
               
            }
        }
     }  
    
    }