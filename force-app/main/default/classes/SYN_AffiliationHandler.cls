public with sharing class SYN_AffiliationHandler { 
     
    public static US_WSREMS__Affiliation__c  setNewAffiValues(US_WSREMS__Affiliation__c affiRecord, Id programId, Id serviceId, Id recordTypeId){
        
        affiRecord.US_WSREMS__REMSProgram__c = programId;
        affiRecord.US_WSREMS__Start_Date__c = System.Today();
        affiRecord.US_WSREMS__isActive__c = TRUE;
        affiRecord.US_WSREMS__REMS_Service__c = serviceId;
        affiRecord.RecordTypeId = recordTypeId;
        return affiRecord;
    } 
    
    public static US_WSREMS__Affiliation__c createPatientAndPresAffil(Id patientId, Id prescriberId, Id programId, Id serviceId){
        
        Id prescAffiRecTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Patient_Affiliation').getRecordTypeId();
        
        US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c(            
            US_WSREMS__Patient__c = patientId,
            US_WSREMS__Prescriber__c = prescriberId
        );
        return setNewAffiValues(affiliationRecord, programId, serviceId, prescAffiRecTypeId);
    }
    
    public static US_WSREMS__Affiliation__c createPrescriberAndPresInstiAffi(Id prescriberId, Id presInstId, Id programId, Id serviceId){
        
        Id prescAffiRecTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Prescriber_Affiliation').getRecordTypeId();
        
        US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c(            
            US_WSREMS__Prescriber__c = prescriberId,
            US_WSREMS__Prescribing_Institution__c = presInstId                     
        );
        return setNewAffiValues(affiliationRecord, programId, serviceId, prescAffiRecTypeId);
    }
    
     public static US_WSREMS__Affiliation__c createPharmacyAndPharmacyParti(Id pharmacyId, Id pharmacistId, Id programId, Id serviceId){
        
        Id prescAffiRecTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        
        US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c(            
            US_WSREMS__Pharmacy__c = pharmacyId,
            US_WSREMS__Pharmacy_User__c = pharmacistId
        );
        return setNewAffiValues(affiliationRecord, programId, serviceId, prescAffiRecTypeId);
    }
       
}