/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class SYN_AffiliationTriggerHandler {

    private static Map<Id,String> programMap = SYN_CommonUtility.getActivePrograms();
    
    
     public static void beforeUpdateMethod(List<US_WSREMS__Affiliation__c> newList , Map<Id,US_WSREMS__Affiliation__c> oldMap){
        Set<Id> affilicationIds = new Set<Id>();
        Map<String,Id> accountRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.AFFILIATION_SOBJECT);
        Id patRcTypeID = accountRecordTypeMap.get(REMSAppLiterals.AFFILIATION_RECTYPE_PATIENT_AFFILIATION);
        Id presRcTypeID = accountRecordTypeMap.get(REMSAppLiterals.AFFILIATION_RECTYPE_PRESCRIBER_AFFILIATION);
        Id pharmRcTypeID = accountRecordTypeMap.get(REMSAppLiterals.AFFILIATION_RECTYPE_PHARMACY_USER_AFFILIATION);
        for(US_WSREMS__Affiliation__c aff : newList ){
            // Inactive - Affilication Logic
             
            if(oldMap != null && aff.US_WSREMS__REMSProgram__c != null && 
            programMap.containsKey(aff.US_WSREMS__REMSProgram__c) 
               && programMap.get(aff.US_WSREMS__REMSProgram__c ) == REMSAppLiterals.MACITENTAN_PROGRAM_NAME && 
               UserInfo.getUserType() != REMSAppLiterals.POWER_CUSTOMER_USERTYPE && 
              
               (aff.recordtypeId != patRcTypeID && aff.recordtypeId != pharmRcTypeID )){
                   
                   if( (aff.US_WSREMS__End_Date__c ==  System.Today() ||  aff.US_WSREMS__End_Date__c < System.Today() ) 
                   && aff.US_WSREMS__End_Date__c != oldMap.get(aff.Id).US_WSREMS__End_Date__c ){
                        aff.Status__c = 'Inactive';
                        aff.US_WSREMS__isActive__c = false;
                   }
                   else if(aff.Status__c == 'Inactive'){
                       aff.US_WSREMS__End_Date__c =  System.Today();
                       aff.US_WSREMS__isActive__c = false;
                       
                   }
            }
        }
    }

    public static void afffilicationAfterMethod(List<US_WSREMS__Affiliation__c> newList , Map<Id,US_WSREMS__Affiliation__c> oldMap){
        Set<Id> affilicationIds = new Set<Id>();
        for(US_WSREMS__Affiliation__c aff : newList ){
            // Inactive - Affilication Logic 
            if(oldMap != null && aff.US_WSREMS__REMSProgram__c != null && programMap.containsKey(aff.US_WSREMS__REMSProgram__c) && programMap.get(aff.US_WSREMS__REMSProgram__c ) == 'Macitentan REMS' && aff.Status__c == 'Inactive' &&  aff.Status__c != oldMap.get(aff.Id).Status__c && UserInfo.getUserType() != 'PowerCustomerSuccess'){
                affilicationIds.add(aff.Id);
            }
        }
        
        if(!affilicationIds.isEmpty()){
            removePharmacyStaff(affilicationIds);
        }
    }
    
    
    public static void removePharmacyStaff(Set<Id> affilicationIds){
     Set<Id> arAccountIds = new Set<Id>();
     Map<Id,String> pharmacyAccountMap = new Map<Id,String>();
     List<US_WSREMS__Affiliation__c> updateAffiliationList = new List<US_WSREMS__Affiliation__c>();
     List<US_WSREMS__Affiliation__c> pAffiliations = new List<US_WSREMS__Affiliation__c>();
     Set<Id> activeArAccountIds = new Set<Id>();
    
     List<US_WSREMS__Affiliation__c> pharmacyAffiliations = [SELECT Id,Status__c,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__r.Pharmacy_Type__c,US_WSREMS__isActive__c,US_WSREMS__End_Date__c 
                                                                                                                     FROM US_WSREMS__Affiliation__c 
                                                                                                                     WHERE US_WSREMS__Pharmacy__c != null
                                                                                                                     AND Id=: affilicationIds];
          
        if(!pharmacyAffiliations.isEmpty()){                                                                                                                 
            for(US_WSREMS__Affiliation__c aff : pharmacyAffiliations){
                    aff.Status__c= 'Inactive';
                    aff.US_WSREMS__End_Date__c = date.today();
                    updateAffiliationList.add(aff);
                    pharmacyAccountMap.put(aff.US_WSREMS__Pharmacy_User__c,aff.US_WSREMS__Pharmacy__r.Pharmacy_Type__c);
                
            }
        }
        
        if(!updateAffiliationList.isEmpty()){
            try{
                update updateAffiliationList;
            }catch(exception e){
                system.debug('---Error--'+e.getMessage());
            }
        }
        
         if(!pharmacyAccountMap.isEmpty() && pharmacyAccountMap != null){
        
             pAffiliations = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__r.Pharmacy_Type__c,US_WSREMS__isActive__c 
                                                                                                                         FROM US_WSREMS__Affiliation__c 
                                                                                                                         WHERE US_WSREMS__Pharmacy__c != null 
                                                                                                                         AND Status__c != 'Inactive'
                                                                                                                         AND US_WSREMS__isActive__c = true 
                                                                                                                         AND US_WSREMS__Pharmacy_User__c != null 
                                                                                            AND US_WSREMS__Pharmacy_User__c =: pharmacyAccountMap.KeySet()];
        if(!pAffiliations.isEmpty()){
            for(US_WSREMS__Affiliation__c aff : pAffiliations){
                if(pharmacyAccountMap.containsKey(aff.US_WSREMS__Pharmacy_User__c) && aff.US_WSREMS__Pharmacy__r.Pharmacy_Type__c.contains(pharmacyAccountMap.get(aff.US_WSREMS__Pharmacy_User__c))){
                   activeArAccountIds.add(aff.US_WSREMS__Pharmacy_User__c);
                }
            }
        }
            
        }
        
        if(pAffiliations.isEmpty() || activeArAccountIds.isEmpty()){
            SYN_ManagePharamcyController.updateAccountStatustoInactive(pharmacyAccountMap.keySet());
            SYN_ManagePharamcyController.deactivatePortalUser(pharmacyAccountMap.keySet());
        }
        
        if(!activeArAccountIds.isEmpty()){
            arAccountIds.addAll(pharmacyAccountMap.keySet());
            arAccountIds.removeAll(activeArAccountIds);
        } 
        
        if(!arAccountIds.isEmpty()){
            SYN_ManagePharamcyController.updateAccountStatustoInactive(pharmacyAccountMap.keySet());
            SYN_ManagePharamcyController.deactivatePortalUser(pharmacyAccountMap.keySet());
        }
        
    }

    public static void checkUserRole(List<US_WSREMS__Affiliation__c> newList)
    {
        ID prescriberAffiliationRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.PRESCRIBER_AFFILIATION_RECORDTYPENAME).getRecordTypeId();
        for(US_WSREMS__Affiliation__c aff : newList ){
            if(aff.US_WSREMS__REMSProgram__c != null && programMap.containsKey(aff.US_WSREMS__REMSProgram__c) && programMap.get(aff.US_WSREMS__REMSProgram__c ) == SYN_Utilitycls.AVEED_PROGRAM_NAME && aff.RecordTypeId == prescriberAffiliationRecordTypeId && aff.US_WSREMS__User_Role__c == SYN_Utilitycls.AFFILIATION_USER_ROLE){
                aff.US_WSREMS__User_Role__c = null;
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : sendAffiliationNotifications
    @author         : Utthirakumar
    @description    : method is used to send affiliation notifications to stakeholders.
    @param          : newAffiliations - list of affiliation records from the affiliation trigger.
    @return         : void
    ********************************************************
    */
    public static void sendAffiliationNotifications(List<US_WSREMS__Affiliation__c> newList){
        List<US_WSREMS__Affiliation__c> xiaflexAffiliations = new List<US_WSREMS__Affiliation__c>();
        if( newList != NULL && newList.size() > 0 ){
            for(US_WSREMS__Affiliation__c aff : newList ){
                if( aff.US_WSREMS__REMSProgram__c != null && programMap.containsKey(aff.US_WSREMS__REMSProgram__c) && programMap.get(aff.US_WSREMS__REMSProgram__c ) == SYN_Utilitycls.XIAFLEX_PROGRAM_NAME && aff.US_WSREMS__End_Date__c == NULL){
                    xiaflexAffiliations.add(aff);
                }
            }
            if( xiaflexAffiliations != NULL && xiaflexAffiliations.size() > 0 ){
                AutomationCommunicationFromAffiliation.sendAffiliationNotifications(xiaflexAffiliations);
            }
        }
    }
}