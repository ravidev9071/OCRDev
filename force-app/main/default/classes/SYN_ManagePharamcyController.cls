/**************************************************************************
    * Name :   SYN_ManagePharamcyController 
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  09/02/2022             Initial Version
    *********************************************************************************/
public without sharing class SYN_ManagePharamcyController {
  
    
    /************************************************************************
    MethodName : getPharmacyList
    Description : retiurn list of certified pharmacy record based on program.
    *************************************************************************/
    @AuraEnabled
    public static List<Account> getPrescriberList(String programId){
            Set<String> validStaus = new Set<String>{'Pending','Certified'};
            List<Account> prescriberList = [SELECT Id,Name,US_WSREMS__NPI__c,US_WSREMS__Status__c,SYN_Ref_Id__c,SYN_Alternate_Phone__c,Phone,office_contact_phone_Primary_Office__c FROM Account WHERE Recordtype.DeveloperName ='Prescriber' AND US_WSREMS__REMS_Program__c != null AND US_WSREMS__REMS_Program__c =: programId AND US_WSREMS__Status__c IN : validStaus  Order By Name ASC LIMIT 49999];
            return prescriberList ;
    }
    
     /***********************************************************************************************************************************
    MethodName : getPharmacistInfo
    Description : return current user account info
    ************************************************************************************************************************************/
    @AuraEnabled
    public static Account getPharmacistInfo() {
       return MaciPortalCustomController.getPharmacistInfo();
    }
        
    /***********************************************************************************************************************************
    MethodName : getPharmacyInfo
    Description : return current user account info
    ************************************************************************************************************************************/
    @AuraEnabled
    public static Account getPharmacyInfo(Account acc, String ProgramName) {
        List<US_WSREMS__Affiliation__c> pAffiliations = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__r.Pharmacy_Type__c,US_WSREMS__isActive__c 
                                                                                                                             FROM US_WSREMS__Affiliation__c 
                                                                                                                             WHERE US_WSREMS__Pharmacy__c != null AND US_WSREMS__isActive__c = true AND Default__c = true
                                                                                                                             AND US_WSREMS__Pharmacy_User__c != null AND US_WSREMS__Pharmacy_User__c =: acc.Id LIMIT 1];
       Account pharmacyAcc;
       if(!pAffiliations.isEmpty() && pAffiliations[0].US_WSREMS__Pharmacy__c != null){
      
        pharmacyAcc= [SELECT Id,Name, US_WSREMS__NPI__c,US_WSREMS__Status__c,SYN_Ref_Id__c, Phone, Fax, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,SYN_Signature_Date__c,Address_1_Secondary_Office__c,City_Secondary_Office__c,
        State_Secondary_Office__c,Zip_Secondary_Office__c,US_WSREMS__REMS_Program__c,Program_Name__c,Date_Enrolled__c FROM Account WHERE Id =: pAffiliations[0].US_WSREMS__Pharmacy__c LIMIT 1];         
           
       }

       return pharmacyAcc;
    }
    
     /***********************************************************************************************************************************
    MethodName : getRelatedFilesByRecordId
    Description : Patient Enrollment(Portal Screen) - download prescriber related files
    ************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<ID, ContentDistribution> getRelatedFilesByRecordId(String recordTypeDevName,String programId,String portalRole) {
        return REMSfileDownloadController.getRelatedFilesByRecordId(recordTypeDevName,programId,portalRole);
    }
    
     /************************************************************************
    MethodName : getPharmacyList
    Description : retiurn list of certified pharmacy record based on program.
    *************************************************************************/
    
    @AuraEnabled
    public static List<US_WSREMS__Affiliation__c> getAuthorizedReps(Account pharmacyact, String programId,Account authrepAccount){
        updatePrimaryAffiliation(pharmacyact,programId,authrepAccount);
        List<US_WSREMS__Affiliation__c> pharmacyAffiliations = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy_User__r.Name,US_WSREMS__Pharmacy_User__r.US_WSREMS__Status__c,US_WSREMS__Pharmacy_User__r.IsCustomerPortal,         
        US_WSREMS__Pharmacy_User__r.Date_Enrolled__c,US_WSREMS__Pharmacy_User__r.SYN_User_Type__c,
        Status__c,US_WSREMS__UserType__c,US_WSREMS__Start_Date__c,AR_Category__c,Default__c
        FROM US_WSREMS__Affiliation__c 
        WHERE US_WSREMS__Pharmacy__c != null AND US_WSREMS__Pharmacy__c =: pharmacyact.id 
        AND US_WSREMS__isActive__c = true AND US_WSREMS__REMSProgram__c =: programId
        AND US_WSREMS__Pharmacy_User__c != null ORDER BY CreatedDate DESC];
        // RT25-09-24 2376 -Changes
        // Use a Map to keep track of the latest active record for each Pharmacy User
        Map<Id, US_WSREMS__Affiliation__c> latestAffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        for (US_WSREMS__Affiliation__c aff : pharmacyAffiliations) {
            // Check if the user type is 'Pharmacy Staff'
            if (aff.US_WSREMS__Pharmacy_User__r.SYN_User_Type__c == 'Pharmacy Staff') {
                // Only add the latest active record
                if (!latestAffiliationMap.containsKey(aff.US_WSREMS__Pharmacy_User__c)) {
                    latestAffiliationMap.put(aff.US_WSREMS__Pharmacy_User__c, aff);
                }
            } else {
                // Add all other records to the list
                latestAffiliationMap.put(aff.US_WSREMS__Pharmacy_User__c, aff);
            }
        }
        List<US_WSREMS__Affiliation__c> finalAffiliations = new List<US_WSREMS__Affiliation__c>();
        for(US_WSREMS__Affiliation__c aff : latestAffiliationMap.values()){
        finalAffiliations.add(aff);
            if(aff.US_WSREMS__Pharmacy_User__r.IsCustomerPortal == true && aff.Status__c == '' && aff.US_WSREMS__Pharmacy_User__r.SYN_User_Type__c == 'Authorized Representative'){
                aff.Status__c = 'Active';
                aff.US_WSREMS__UserType__c = 'Authorized Representative';
                aff.AR_Category__c= 'Primary';     
            }
                    
        }                                                             
        return finalAffiliations;                                                                                                                      
    }
    
    Public static void updatePrimaryAffiliation(Account pharmacyact, String programId,Account authrepAccount){
         List<US_WSREMS__Affiliation__c> updateAffiliationList = new List<US_WSREMS__Affiliation__c>();
         List<US_WSREMS__Affiliation__c> pharmacyAffiliations = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy_User__r.Name,US_WSREMS__Pharmacy_User__r.US_WSREMS__Status__c,US_WSREMS__Pharmacy_User__r.IsCustomerPortal,         
                                                                                                                         US_WSREMS__Pharmacy_User__r.Date_Enrolled__c,US_WSREMS__Pharmacy_User__r.SYN_User_Type__c,
                                                                                                                         Status__c,US_WSREMS__UserType__c,US_WSREMS__Start_Date__c,AR_Category__c
                                                                                                                         FROM US_WSREMS__Affiliation__c 
                                                                                                                         WHERE US_WSREMS__Pharmacy__c != null AND US_WSREMS__Pharmacy__c =: pharmacyact.id 
                                                                                                                         AND US_WSREMS__isActive__c = true AND US_WSREMS__REMSProgram__c =: programId
                                                                                                                         AND US_WSREMS__Pharmacy_User__c != null AND US_WSREMS__Pharmacy_User__c =: authrepAccount.Id
                                                                                                                         AND Status__c = ''];
          if(!pharmacyAffiliations.isEmpty()){
              for(US_WSREMS__Affiliation__c aff : pharmacyAffiliations){
                  if(aff.US_WSREMS__Pharmacy_User__r.IsCustomerPortal == true && aff.Status__c ==null && aff.US_WSREMS__Pharmacy_User__r.SYN_User_Type__c == 'Authorized Representative'){
                        aff.Status__c = 'Active';
                        aff.US_WSREMS__UserType__c = 'Authorized Representative';
                        aff.AR_Category__c= 'Primary'; 
                        updateAffiliationList.add(aff);    
                  }
              }  
          } 
          if(!updateAffiliationList.isEmpty()){
              try{
                  update updateAffiliationList;
              }catch(Exception e){
                  system.debug('---Error---'+e.getMessage());
              }
          }   
                        
    }
  
     /************************************************************************
    MethodName : getPharmacyUsers
    Description : retiurn list of pharmacy user under the Pharmacy.
    *************************************************************************/
    public static Map<Id,String> getPharmacyUsers(Account pharmacyact, String programId){
        Map<Id,String> accountMap= new Map<Id,String>();
        List<US_WSREMS__Affiliation__c> pharmacyAffiliations = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy_User__r.Name,US_WSREMS__Pharmacy_User__r.US_WSREMS__Status__c,US_WSREMS__UserType__c,         
                                                                                                                 US_WSREMS__Pharmacy_User__r.Date_Enrolled__c,US_WSREMS__Pharmacy_User__r.SYN_User_Type__c 
                                                                                                                 FROM US_WSREMS__Affiliation__c 
                                                                                                                 WHERE US_WSREMS__Pharmacy__c != null AND US_WSREMS__Pharmacy__c =: pharmacyact.id 
                                                                                                                 AND US_WSREMS__isActive__c = true AND US_WSREMS__REMSProgram__c =: programId
                                                                                                                 AND US_WSREMS__Pharmacy_User__c != null AND Default__c = true];
        if(!pharmacyAffiliations.isEmpty()){
            for(US_WSREMS__Affiliation__c paf : pharmacyAffiliations){
                accountMap.put(paf.US_WSREMS__Pharmacy_User__c,paf.US_WSREMS__UserType__c);
            }
        } 
        return accountMap;                                                                                                                
    }
    
    /************************************************************************
    MethodName : removePharmacyStaff
    Description : inactivate the selected affiliation record when portal user click remove pharmacy staff button.
    *************************************************************************/
    @AuraEnabled
    public static string removePharmacyStaff(String recordId, Account pharmacyAcct, String programId, String pharmacyType){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> pharmcyAccountIds = new Set<Id>();
        Set<Id> arAccountIds = new Set<Id>();
        Set<id> defaultAffiliationIds = new Set<Id>();
        String pendingAffiliationRecordId = '';
        List<US_WSREMS__Affiliation__c> updateAffiliationList = new List<US_WSREMS__Affiliation__c>();
        try{
            accountIds.add(recordId);
            List<US_WSREMS__Affiliation__c> pharmacyAffiliations = [SELECT Id,Status__c,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__r.Pharmacy_Type__c,US_WSREMS__isActive__c,Default__c,US_WSREMS__End_Date__c 
                                                                                                                         FROM US_WSREMS__Affiliation__c 
                                                                                                                         WHERE US_WSREMS__Pharmacy__c != null
                                                                                                                         AND Id=: recordId];

            for(US_WSREMS__Affiliation__c aff : pharmacyAffiliations){
                 arAccountIds.add(aff.US_WSREMS__Pharmacy_User__c);
                if(aff.US_WSREMS__Pharmacy__c == pharmacyAcct.id){
                    aff.Status__c= 'Inactive';
                    aff.US_WSREMS__End_Date__c = date.today();
                    updateAffiliationList.add(aff);
                    if(aff.Default__c == true){
                        aff.Default__c= false;
                        defaultAffiliationIds.add(aff.Id); 
                    }
                }
            }
            if(!updateAffiliationList.isEmpty()){
                try{
                    update updateAffiliationList;
                }catch(exception e){
                    system.debug('---Error--'+e.getMessage());
                }
            }
            if(!arAccountIds.isEmpty()){
            
                 List<US_WSREMS__Affiliation__c> pAffiliations = [SELECT Id,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__r.Pharmacy_Type__c,US_WSREMS__isActive__c,Status__c  
                                                                                                                             FROM US_WSREMS__Affiliation__c 
                                                                                                                             WHERE US_WSREMS__Pharmacy__c != null AND Status__c != 'Inactive'
                                                                                                                             AND US_WSREMS__isActive__c = true AND US_WSREMS__REMSProgram__c =: programId
                                                                                                                             AND US_WSREMS__Pharmacy_User__c != null AND US_WSREMS__Pharmacy_User__c =: arAccountIds];
                for(US_WSREMS__Affiliation__c aff : pAffiliations){
                    if(aff.US_WSREMS__Pharmacy__r.Pharmacy_Type__c.contains(pharmacyType) && aff.US_WSREMS__Pharmacy__c != pharmacyAcct.id){
                        pharmcyAccountIds.add(aff.US_WSREMS__Pharmacy__c);
                    }
                    
                    if(!defaultAffiliationIds.isEmpty() && aff.Status__c != 'Pending' ){
                        pendingAffiliationRecordId = aff.Id;
                    }
                }
                
            }
            if(!defaultAffiliationIds.isEmpty() && pendingAffiliationRecordId != ''){
                US_WSREMS__Affiliation__c defaultAffiliation = new US_WSREMS__Affiliation__c (Id=pendingAffiliationRecordId);
                defaultAffiliation.Default__c = true;
                update defaultAffiliation;
            }
            if(pharmcyAccountIds.isEmpty()){
                updateAccountStatustoInactive(arAccountIds);
                deactivatePortalUser(arAccountIds);
            }
            return '';  
        }catch(exception e){
            system.debug('---Error---'+e.getMessage());
            return e.getMessage();
        }
    }
    // RT25-09-24 2376 -Changes
    /************************************************************************
    MethodName : activatePharmacyUser
    Description : ReActivate the pharmacy user
    *************************************************************************/
    @AuraEnabled
    public static String activatePharmacyUser(Id recordId) {
        // RT 04Sep24 changes
        Set<Id> arAccountIds = new Set<Id>();
        try {
            US_WSREMS__Affiliation__c currentAffiliation = [SELECT Id,US_WSREMS__Pharmacy_User__c,RecordTypeId, US_WSREMS__Authorized_Representative__c,US_WSREMS__isActive__c,
            US_WSREMS__Pharmacy__c,US_WSREMS__UserType__c,US_WSREMS__REMSProgram__c,US_WSREMS__End_Date__c,US_WSREMS__Start_Date__c,Status__c,US_WSREMS__Authorized_Representative__r.US_WSREMS__REMS_Program__c
            FROM US_WSREMS__Affiliation__c WHERE Id = :recordId LIMIT 1];
            Account pharmacyParticipant = [SELECT Id, US_WSREMS__Status__c FROM Account WHERE Id = :currentAffiliation.US_WSREMS__Pharmacy_User__c LIMIT 1];
            US_WSREMS__Affiliation__c newAffiliation = new US_WSREMS__Affiliation__c(
                US_WSREMS__Authorized_Representative__c = currentAffiliation.US_WSREMS__Authorized_Representative__c,
                US_WSREMS__Pharmacy__c = currentAffiliation.US_WSREMS__Pharmacy__c,
                US_WSREMS__REMSProgram__c = currentAffiliation.US_WSREMS__REMSProgram__c,
                US_WSREMS__Pharmacy_User__c = currentAffiliation.US_WSREMS__Pharmacy_User__c,
                US_WSREMS__UserType__c = currentAffiliation.US_WSREMS__UserType__c,
                US_WSREMS__Start_Date__c = System.today(),
                RecordTypeId = currentAffiliation.RecordTypeId,
                US_WSREMS__End_Date__c = null,
                US_WSREMS__isActive__c = true,
                Default__c=true,
                Status__c = 'Active'
            );
            Database.insert(newAffiliation);
            // RT 04-10-24 changes - used seprate method
            reactivatePharmacyParticipant(pharmacyParticipant);
            arAccountIds.add(newAffiliation.US_WSREMS__Pharmacy_User__c);
            if(!arAccountIds.isEmpty()){
                reactivatePortalUser(arAccountIds);
            }

            return '';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // RT 04-10-24 changes - New method to reactivate the portal user account
    public static void reactivatePharmacyParticipant(Account pharmacyParticipant) {
        if (pharmacyParticipant != null && pharmacyParticipant.US_WSREMS__Status__c != 'Active') {
            pharmacyParticipant.US_WSREMS__Status__c = 'Active';
            Database.update(pharmacyParticipant);
        }
    }
    
    
     /************************************************************************
    MethodName : updateAccountStatustoInactive
    Description : inactive community user when removed from Inpatient Manage pharmcy table 
    *************************************************************************/
    @future
    public static void updateAccountStatustoInactive(Set<Id> recordIds){
        List<Account> updateAccountList = new List<Account>();
        List<Account> accList = [SELECT Id, US_WSREMS__Status__c FROM Account WHERE Id IN : recordIds];
        if(!accList.isEmpty()){
            for(Account acc : accList ){
                acc.US_WSREMS__Status__c = 'Inactive';
                updateAccountList.add(acc);
            }
        }
        try{
            if(!updateAccountList.isEmpty()){
                update updateAccountList;
            }
        }catch(exception e){
            system.debug('---Error---'+e.getMessage());
        }
    }
    
    /************************************************************************
    MethodName : deactivatePortalUser
    Description : inactive community user when removed from Inpatient Manage pharmcy table 
    *************************************************************************/
    @future
    public static void deactivatePortalUser(Set<Id> recordIds){
        List<User> updateUserList = new List<User>();
        List<User> usrList = [SELECT Id,userName, IsActive,IsPortalEnabled FROM USER WHERE AccountId != null AND AccountId IN : recordIds AND IsActive = true];
        if(!usrList.isEmpty()){
            for(User u : usrList){
                u.userName= u.userName+'.invalid';
                u.IsActive = false; 
                updateUserList.add(u);
            }
        }
        try{
            if(!updateUserList.isEmpty()){
                update updateUserList;
            }
        }catch(exception e){
            system.debug('---Error---'+e.getMessage());
        }
    }

    @future
    public static void reactivatePortalUser(Set<Id> recordIds){
        List<User> updateUserList = new List<User>();
        // RT 04-10-24 changes - get the current selected user with IsActive = false without using like query
        List<User> usrList = [SELECT Id, userName, IsActive, IsPortalEnabled FROM User WHERE AccountId != null AND AccountId IN :recordIds AND IsActive = false];
        
        if(!usrList.isEmpty()){
            for(User u : usrList){
                // Remove '.invalid' from the username
                u.userName = u.userName.replaceAll('.invalid', '');
                u.IsActive = true; // Reactivate the user
                updateUserList.add(u);
            }
        }
        
        try{
            if(!updateUserList.isEmpty()){
                update updateUserList;
            }
        } catch (Exception e) {
            System.debug('---Error---' + e.getMessage());
        }
    }

    
     /***********************************************************************************************************************************
    MethodName : getPharmacyCredentails
    Description : Pharmacy Enrollment - get Case Credentials Picklist Values
    ***********************************************************************************************************************************/
    @AuraEnabled 
    public static String sendInviteNotification(string recordId){
        US_WSREMS__Affiliation__c aff = new US_WSREMS__Affiliation__c (Id=recordId);
        aff.Send_Invite__c = true;
        try{
            update aff;
        }catch (exception e){
            system.debug('--Error---'+e.getMessage());
        }
        return aff.Id;
    }
     
    
    
    /***********************************************************************************************************************************
    MethodName : PharmacyEnterPatientInformation
    Description : get pharmacy patient details
    ************************************************************************************************************************************/
   @AuraEnabled
    public static Account pharmacyEnterPatientInformation(String fname, String lname, Date dob , String program) {

        Id PatientAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        return [SELECT Id,LastName,FirstName,Name,SYN_Ref_Id__c,Shipment_Date__c,Days_Supply__c,Patient_Reproductive_Status_Date__c,Monthly_Pregnancy_Test_Date__c,
               Counseling_Completion_Date__c,US_WSREMS__Patient_Risk_Category__c,US_WSREMS__DOB__c,Monthly_Pregnancy_Test_Recorded__c,Counseling_Recorded__c,US_WSREMS__Status__c
               FROM Account WHERE RecordType.DeveloperName = 'Patient' AND FirstName = :fname AND LastName = :lname AND US_WSREMS__DOB__c = :dob AND Program_Name__c =: program LIMIT 1];
    }
    
    /***********************************************************************************************************************************
    MethodName : getprescriberdetails
    Description : get prescriber Details for patient 
    ****************************************************************************************************************************/
    @AuraEnabled
    public static Case getPrescriberDetails(String patientId, String program){
          return [SELECT Id,SYN_Prescriber__c,SYN_Prescriber__r.FirstName,SYN_Prescriber__r.LastName
                     FROM Case WHERE US_WSREMS__Patient__c =: patientId AND Recordtype.DeveloperName ='Patient_Enrollement' AND US_WSREMS__Program_Picklist__c =: program LIMIT 1];
      }
    
    /************************************************************************
    MethodName : create Pharmacy PatientPregancy Records
    Description : Create Rems Service and case Records for patient pregnancy type
    *************************************************************************/
    @AuraEnabled
    public static String createPharmacyPatientTestRecord(String program, Id patientId,Account pharmacy,String programName,String channel,String pharmacyParticipant,String prescriber){
        Map<String,String> PatientInfoMap = new Map<String,String>();
        // Creating Rems service
        Map<String,Id> CaseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
       
        Id casePregnancyRecordTypeId = CaseRecordTypeMap.get('Patient_Pregnancy_Test');
        String remsServiceId = SYN_PortalEnrollmentController.createPatientPregnancyREMSService('Patient_Pregnancy_Test',pharmacy.Id,program,'Pharmacy',patientId);
        
        if(patientId != null){
            String sect = 'Pharmacy'+';'+'US_WSREMS__Patient__c'+';'+'Macitentan REMS';
            PatientInfoMap = SYN_ParticipantEnrollmentController.getPrepopFields(patientId,'Case',casePregnancyRecordTypeId ,sect);
        }
        // Creating Patient Pregnancy Case
        Case pCase= New Case(RecordTypeId = casePregnancyRecordTypeId, SYN_Pharmacy__c = pharmacy.Id, US_WSREMS__Program_Picklist__c = programName,US_WSREMS__Channel__c=channel,
                             US_WSREMS__REMS_Program__c = program,US_WSREMS__Patient__c=patientId,Monthly_Pregnancy_Test_Recorded__c =true,SYN_Prescriber__c=prescriber,
                             US_WSREMS__REMS_Service_Summary__c = remsServiceId,Date_of_Confirmation__c=System.today(),US_WSREMS__Outcome__c='Complete',
                             US_WSREMS__Patient_Risk_Category__c = 'Female of Reproductive Potential (FRP)',US_WSREMS__Participant__c=patientId,Pharmacy_Participant__c=pharmacyParticipant);
        
        if(!PatientInfoMap.isEmpty() && PatientInfoMap!= null){
            for(String fld : PatientInfoMap.keySet()){
                pCase.put(fld,PatientInfoMap.get(fld));
            }
        }
        
        try{
            insert pCase;
            return remsServiceId;
        }catch (exception e){
            return e.getMessage();
        }
    }
    
    
    /***********************************************************************************************************************************
    MethodName : get prescriber account
    Description : get prescriber Details 
    ****************************************************************************************************************************/
    @AuraEnabled
    public static Account getPrescriberAccount(String prescriberId, String program){
          return [SELECT Id,Name FROM Account WHERE Id =: prescriberId 
                  AND Recordtype.DeveloperName ='Prescriber' AND Program_Name__c =: program LIMIT 1];
    }
      
      
    /************************************************************************
    MethodName : create Pharmacy Patient Counseling Records
    Description : Create Rems Service and case Records for patient pregnancy type
    *************************************************************************/
    @AuraEnabled
    public static void createPharmacyPatientCounselingRecord(Account authRepAccount,Account pharmacyAccount,Account prescriberAccount,Account patientAccount,String channel){
        SYN_InvitePharamcyStaffController.createPatientCounselingChecklistCaseRecord(authRepAccount,pharmacyAccount,prescriberAccount,patientAccount,channel);
    }
    
    
     /***********************************************************************************************************************************
    MethodName : validatePrescriberData
    Description : verifying prescriber data is valid or not
    ***********************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Account validatePrescriberData(String npi, String programId) {
      return SYN_InvitePharamcyStaffController.validatePrescriberData(npi,programId);
       
    }
    
    /***********************************************************************************************************************************
    MethodName : validatePatientData
    Description : verifying patinet data is valid or not .
    ***********************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Account validatePatientData(String fname, String mname, String lname, date dob, String programId) {
      return SYN_InvitePharamcyStaffController.validatePatientData(fname,mname,lname,dob,programId);
      
    } 
}