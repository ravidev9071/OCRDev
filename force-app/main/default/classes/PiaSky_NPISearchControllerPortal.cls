public without sharing class PiaSky_NPISearchControllerPortal {

   
    @AuraEnabled
    public static String getNPIStatusVeeva(String searchKey,String programName){
        try{
            String returnValue = '';
            SYN_VeevaAPI_Search.prescriberInfoPrepopWrap PresInfo =  SYN_VeevaAPI_Search.NPIreturnValue(searchKey); 
            if(PresInfo.LastName != ''){
                 returnValue = JSON.serialize(PresInfo);
            }else{
                returnValue='Failed';
            }
            return returnValue;
        }catch(Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static boolean getDEAStatusVeeva(String DEA,String LastName,String programName){     
       	return SYN_VeevaAPI_Search.DEAreturnValue_Aveed(DEA,LastName);
    }

    
    /****************************************************************************************************************
    * Method Name : recordTypeId
    * @description : Method to fetch record type id's for various recordTypes
    * @author Pavani | 26-05-2024 
    * @return Map of recordType name and its Id 
    ****************************************************************************************************************/
    
    public static Map<String,Id> recordTypeId(){ 
        Map<String,Id> recordTypeMap = new Map<string,Id>();
        for(RecordType recType: [Select Name, SobjectType, Id from RecordType where Name In ('Pharmacy Participant', 'Pharmacy User Affiliation', 'Pharmacy Participant Account', 'Participant Account Creation')]){
            if((recType.name == 'Pharmacy Participant') && recType.SobjectType == 'Account'){
            	recordTypeMap.put(recType.Name, recType.Id);
            } else if((recType.name == 'Pharmacy Participant Account') && recType.SobjectType == 'Case'){
                recordTypeMap.put(recType.Name, recType.Id);
            } else if((recType.name == 'Participant Account Creation') && recType.SobjectType == 'US_WSREMS__REMS_Service_Summary__c'){
                recordTypeMap.put(recType.Name, recType.Id);
            } else if((recType.name == 'Pharmacy User Affiliation') && recType.SobjectType == 'US_WSREMS__Affiliation__c'){
                recordTypeMap.put(recType.Name, recType.Id);
            }
        }
        return recordTypeMap;
    }


/*****************************************************************************************************************
    * Method Name          : createRecordOnSubmit
    * @Description         : Creates various records (Account, Service Summary, Case, User) based on the submitted data.
    * @Author              : Pavani
    * @CreatedDate         : 21-12-2023
    * @param recordDetails : JSON string containing the details for creating records.
    * @param programName   : Name of the REMS Program.
    * @param participantType: Type of participant for the REMS Service.
    * @return               : Id of the created User record.
    *****************************************************************************************************************/    
     @AuraEnabled
    public static String createRecordOnSubmit(Map<String,String> inputRecords, String pharmaAcc, String arFoundMsg) {
        Savepoint sp = Database.setSavepoint(); 

        try {
            String recordDetails = inputRecords.get('recordDetails');
            String pharmacyId = inputRecords.get('pharmacyId');
            String programName = inputRecords.get('programName');
            String profileName = inputRecords.get('profileName');
            String permissionSet = inputRecords.get('permissionSet');
            String userType = inputRecords.get('userType');
            //Validate if the record details are not empty
            if(String.isEmpty(recordDetails)) {
                return REMSAppLiterals.FAILED_STATUS;
            }

            //Logic Begins
            String userId = null;
            String affiliationID = null;
            RecordDataWrapper recordData = (RecordDataWrapper)System.JSON.deserialize(recordDetails,RecordDataWrapper.class);
            List<US_WSREMS__REMS_Program__c>  program = [SELECT Id,Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =:programName];
        
            Map<String,Id> recordTypeMap = recordTypeId();
               Account personAccount = insertAccount(recordData,program, true, REMSAppLiterals.ACCOUNT_RECORDTYPE_AR);
               //personAccount.US_WSREMS__User_Type__c = 'Authorized Representative';
               //update personAccount;
                //Retrieve the personContactId
                List<Account> accList = [SELECT Id, PersonContactId, US_WSREMS__REMS_ID__c FROM Account WHERE Id = :personAccount.Id];
                //If the account creation was sucessful proceed
                if(!accList.isEmpty()){
					
                    //Insert Service Summary Record
                    US_WSREMS__REMS_Service_Summary__c service  = insertServiceSummary(accList[0], program, REMSAppLiterals.SERVICE_PARTICIPANT_AR, REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
                    //Insert Case Record
                   // REMSAvoidRecursiveCls.stop_serviceupdateFromPortal=true;
                    Case caseRec = insertCase( recordData, accList[0], service,program,REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT,null ,REMSAppLiterals.REQUESTORTYPE_PHARMACY_HCS_PARTICIPANT, recordTypeMap.get('Pharmacy Participant Account'));
                    service = updateServiceSummary(service);
                     US_WSREMS__Affiliation__c affiliatedAcc = insertAffiliation(accList[0], program, pharmaAcc, recordTypeMap.get('Pharmacy User Affiliation'), recordData);
                     affiliationID = affiliatedAcc.id;
                    
                }
            
            return affiliationID;
        } catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage());
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /****************************************************************************************************************
    * Method Name : permissionSetAssignment
    * @description : Method to insert person account
    * @author Pavani | 27-02-2024 
    * @param permissionSetId 
    * @param userId 
    * @return  
    ****************************************************************************************************************/
    @future 
    public static void permissionSetAssignment(String permissionSetId, String userId) {
        PermissionSetAssignment permissionAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = userId);
        insert permissionAssignment;
    }

    /****************************************************************************************************************
    * Method Name : insertAccount
    * @description : Method to insert person account
    * @author Pavani | 06-03-2024 
    * @param recordData 
    * @param program 
    * @return Account 
    ****************************************************************************************************************/

    public static Account insertAccount(RecordDataWrapper recordData,List<US_WSREMS__REMS_Program__c>  program,Boolean isPersonAccount, String recordType) {

        try {
            String userEmail = System.label.piasky_Portal_default_record_user;
            User[] adminUser = [Select Id, Name from User where Email =: userEmail AND Alias = 'pskyUsr'];
            Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(recordType);
            Account newAccount = new Account();
            newAccount.OwnerId = adminUser[0].Id;
            if (isPersonAccount) {
                newAccount.FirstName = recordData.firstName;
                 if(recordType != 'Prescriber'){
                newAccount.MiddleName = recordData.middleName;
                 }
                newAccount.LastName = recordData.lastName;
                newAccount.PersonEmail = recordData.email;
                if(recordType == 'Prescriber'){
                    newAccount.ShippingCity = recordData.city;
                    newAccount.Address_1_Secondary_Office__c = recordData.address1;
                    newAccount.Address_2_Secondary_Office__c = recordData.address2;
                    newAccount.Office_Practice_Clinic_Name__c = recordData.clinicName;
                    newAccount.Fax = recordData.fax;
                    newAccount.US_WSREMS__NPI_Status__c = 'Valid';
                }
                else{
                    newAccount.US_WSREMS__City__c = recordData.city;
                    newAccount.US_WSREMS__Address_Line_1__c = recordData.address1;
                    newAccount.US_WSREMS__Address_Line_2__c = recordData.address2;
                    newAccount.US_WSREMS__Clinic_Facility_Name__c = recordData.clinicName;
                    newAccount.US_WSREMS__Fax_Number__c = recordData.fax;
                }
                newAccount.US_WSREMS__State__c = recordData.state;
                newAccount.US_WSREMS__Zip__c = recordData.zipCode;
                newAccount.US_WSREMS__Email__c = recordData.email;
                newAccount.Medical_Specialty__c = recordData.specialty;
                newAccount.Phone = recordData.phone;
                newAccount.US_WSREMS__DEA__c=recordData.DEA;
                newAccount.US_WSREMS__Preferred_Contact_Method__c=recordData.PMC;
                newAccount.US_WSREMS__Credentials__c = recordData.credentials;
				if(recordData.credentials == REMSAppLiterals.CREDENTIALS_OTHER){
                    newAccount.US_WSREMS__Credentials__c = REMSAppLiterals.CREDENTIALS_OTHER;
				    newAccount.Other_Credential__c = recordData.othercredentials;
                }
                if(recordData.specialty == REMSAppLiterals.CREDENTIALS_OTHER){
                    newAccount.Medical_Specialty__c = REMSAppLiterals.CREDENTIALS_OTHER;
				    newAccount.US_WSREMS__Other__c = recordData.medSpecialityOther;
                }
            } else {
                newAccount.Name = recordData.name;
                // newAccount.Email__c = recordData.hcsEmail;
                if (recordType != REMSAppLiterals.ACCOUNT_RECORDTYPE_PHARMACYPARTICIPANT) {
                    newAccount.US_WSREMS__National_Provider_Identifier__c = recordData.npi;
                }
            }
            if(recordType == REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER) {
                newAccount.US_WSREMS__National_Provider_Identifier__c = recordData.npi;
                newAccount.fax = recordData.fax;
            }
            if(recordType != REMSAppLiterals.ACCOUNT_RECORDTYPE_HEALTHCARESETTING && recordType != REMSAppLiterals.ACCOUNT_RECORDTYPE_OUTPATIENTPHARMACY  ) {
                newAccount.US_WSREMS__Email__c = recordData.email;
                newAccount.Phone = recordData.phone;
                newAccount.US_WSREMS__Fax_Number__c = recordData.fax;
            } 
            
            newAccount.RecordTypeId = recordTypeId;
           
            newAccount.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
            newAccount.US_WSREMS__REMS_Program__c = program.size() > 0 ? program[0].Id : null;
            newAccount.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            insert newAccount;
            return  newAccount;
        }catch (Exception ex) {
            System.debug('Exception'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }  
    }

    /****************************************************************************************************************
     * Method Name : insertServiceSummary
    * @description : Method to insert Service summary record
    * @author Pavani | 01-02-2024 
    * @param personAccount 
    * @param program 
    * @param participantType 
    * @return REMS_Service_Summary__c 
    ****************************************************************************************************************/
    public static US_WSREMS__REMS_Service_Summary__c insertServiceSummary(Account personAccount,List<US_WSREMS__REMS_Program__c>  program,String participantType,String recordType) {

        try {
            Id idRTforREMSService = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c').get(recordType);
        US_WSREMS__REMS_Service_Summary__c service = new US_WSREMS__REMS_Service_Summary__c();
        service.recordTypeId = idRTforREMSService;
        service.US_WSREMS__REMSProgram__c = program.size() > 0 ? program[0].Id : null;
        service.RecordTypeId = idRTforREMSService;
        service.US_WSREMS__Status__c = REMSAppLiterals.SERVICE_STATUS;
        service.US_WSREMS__Service_Outcome__c = REMSAppLiterals.SERVICE_OUTCOME;
        service.US_WSREMS__Participant__c = personAccount.Id;
        service.US_WSREMS__Requestor_Type__c = participantType;
        insert service;
        return service;

        } catch (Exception ex) {
            System.debug('Exception'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    /****************************************************************************************************************
     * Method Name : UpdateServiceSummary
    * @description : Method to Update Service Path_Stage_Name__c and Path_Complete__c  
    * @author Robin Nirwal | 20-02-2024 
    * @param REMS_Service_Record 
    * @return REMS_Service_Summary__c 
    ****************************************************************************************************************/
    public static US_WSREMS__REMS_Service_Summary__c updateServiceSummary(US_WSREMS__REMS_Service_Summary__c REMS_Service_Record) {
        try {
            REMS_Service_Record.US_WSREMS__Path_Stage_Name__c = REMSAppLiterals.PATH_STAGE_NAME;
            REMS_Service_Record.US_WSREMS__Path_Complete__c = REMSAppLiterals.PATH_COMPLETE;
            update REMS_Service_Record;
            return REMS_Service_Record;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    /****************************************************************************************************************
    * Method Name : insertCase
    * @description : Method to insert Case Record
    * @author Pavani | 01-02-2024 
    * @param recordData 
    * @param personAccount 
    * @param service 
    * @return Case 
    ****************************************************************************************************************/
    public static Case insertCase(RecordDataWrapper recordData,Account accountRec,US_WSREMS__REMS_Service_Summary__c service,List<US_WSREMS__REMS_Program__c>  program,String recordType, string accountId ,String participantType, Id recordTypeId) {

        try {
            String recordTypeDevName = Schema.SObjectType.Case.getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.CASE_OBJECT).get(recordType);
            Case caseRec = new Case();
            caseRec.recordTypeId = recordTypeId;
            
            if(recordTypeDevName == REMSAppLiterals.CHANGE_OF_INFORMATION){
                caseRec.US_WSREMS__Title__c = recordData.title;
                caseRec.US_WSREMS__Preferred_Contact_Method__c = recordData.preferredContactMethod;
                caseRec.US_WSREMS__Other__c = recordData.otherContact;
            } // To be changed
            if (recordType != REMSAppLiterals.CASE_RECORDTYPE_HEALTHCARESETTING && recordType != REMSAppLiterals.CASE_RECORDTYPE_OUTPATIENTPHARMACY) {
                caseRec.US_WSREMS__First_Name__c = recordData.firstName;
                caseRec.US_WSREMS__Middle_Name__c = recordData.lastName;
                caseRec.US_WSREMS__Last_Name__c = recordData.LastName;
                caseRec.US_WSREMS__Fax__c = recordData.fax;
                caseRec.US_WSREMS__Zip__c = recordData.zipCode;
                caseRec.US_WSREMS__Participant_Fax__c = recordData.fax;
                caseRec.US_WSREMS__REMS_Alternate_Phone__c = recordData.phone;
                caseRec.US_WSREMS__Email__c = recordData.email;
                caseRec.US_WSREMS__Email_ar__c = recordData.email;
                caseRec.US_WSREMS__Phone__c = recordData.phone;
                caseRec.US_WSREMS__NPI__c = (recordType == REMSAppLiterals.CASE_RECTYPE_PRESCRIBER_PERSON_ACCOUNT || recordType == 'Prescriber')? recordData.npi : null;
            } else {
                caseRec.US_WSREMS__Name__c = recordData.name;
                caseRec.US_WSREMS__NPI__c = recordData.npi;
            }
            if(recordType == 'Prescriber'){
                caseRec.Office_Practice_Clinic_Name__c = recordData.clinicName;
                caseRec.Address_1_Secondary_Office__c = recordData.address1;
                caseRec.Address_2_Secondary_Office__c = recordData.address2;
                caseRec.US_WSREMS__City__c = recordData.city;
                caseRec.US_WSREMS__State__c = recordData.state;
                caseRec.SYN_Medical_specialty__c = recordData.specialty;
                caseRec.US_WSREMS__Prescriber_Signature__c = 'Yes';
                caseRec.US_WSREMS__Signature_Date_Pharmacist__c = system.today();

                if(recordData.specialty == REMSAppLiterals.CREDENTIALS_OTHER){
                    caseRec.SYN_Medical_specialty__c = REMSAppLiterals.CREDENTIALS_OTHER;
				    caseRec.US_WSREMS__Other__c = recordData.medSpecialityOther;
                }
            }
            caseRec.US_WSREMS__REMS_ID__c = accountRec.US_WSREMS__REMS_ID__c;
            caseRec.US_WSREMS__Requestor_Type__c = (recordType == REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT)? REMSAppLiterals.REQUESTORTYPE_PHARMACY_HCS_PARTICIPANT:recordData.participantType;
            caseRec.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
            caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
            caseRec.US_WSREMS__Participant__c = accountRec.Id;
            caseRec.US_WSREMS__REMS_Service_Summary__c = service.Id;
            caseRec.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL; 
            caseRec.US_WSREMS__NPI_Status__c = 'Valid';
            //caseRec.US_WSREMS__Channel__c = 'Email'; // To be changed
            caseRec.US_WSREMS__Credential__c = recordData.credentials;
            //caseRec.Program_Record_Type_Control__c = 'PiaSky REMS-Pharmacy_Participant_Account'; // To be changed
            if(recordData.credentials == REMSAppLiterals.CREDENTIALS_OTHER){
                caseRec.US_WSREMS__Credential__c = REMSAppLiterals.CREDENTIALS_OTHER;
                caseRec.Other_Credential__c = recordData.othercredentials;
            }
            if(recordType == REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT && participantType == REMSAppLiterals.REQUESTORTYPE_HCS) {
                caseRec.US_WSREMS__Healthcare_Setting__c = accountId;
            } else if(recordType == REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT &&  participantType == REMSAppLiterals.REQUESTORTYPE_OUTPATIENT) {
                caseRec.US_WSREMS__REMS_Authorized_Rep__c = accountId; 
            }
            if(!test.isRunningTest()) {
                insert caseRec;
            }
            return  caseRec;
            
        }  catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }

        
    }

    /****************************************************************************************************************
    * Method Name : insertAffiliation
    * @description : Method to insert Affiliation Record
    * @author Dilbag | 29-05-2024 
    * @param accountRec 
    * @param program 
    * @param pharmaAcc : Pharmacy Account 
    * @param recordTypeId
    * @return US_WSREMS__Affiliation__c 
    ****************************************************************************************************************/
    
    public static US_WSREMS__Affiliation__c insertAffiliation(Account accountRec, List<US_WSREMS__REMS_Program__c> program, String pharmaAcc, Id recordTypeId, RecordDataWrapper recordData) {
        
        try {
            US_WSREMS__Affiliation__c affiliatedAcc = new US_WSREMS__Affiliation__c();
            affiliatedAcc.RecordTypeId = recordTypeId;
            affiliatedAcc.US_WSREMS__Pharmacy_User__c = accountRec.Id;
            affiliatedAcc.US_WSREMS__Pharmacy__c = pharmaAcc;
            affiliatedAcc.US_WSREMS__REMSProgram__c = program.size() > 0 ? program[0].Id : null;
            affiliatedAcc.US_WSREMS__isActive__c = true;
            affiliatedAcc.US_WSREMS__Start_Date__c = System.Today();
            if(!String.isEmpty(recordData.userType)){
            affiliatedAcc.US_WSREMS__User_Role__c = recordData.userType;
            } else {
                affiliatedAcc.US_WSREMS__User_Role__c = 'Staff';
            }

            insert affiliatedAcc;
            return affiliatedAcc;
            
        }  catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }

        
    }


/*****************************************************************************************************************
    * Inner Class Name     : RecordDataWrapper
    * @Description         : Wrapper class to hold data for creating records.
    * @Author              : Pavani
    * @CreatedDate         : 21-12-2023
    *****************************************************************************************************************/    
    public class RecordDataWrapper {
        public String firstName;
        public String middleName;
        public String lastName;
        public String email;
        public String phone;
        public String fax;
        public String npi;
        public String address1;
		public String address2;
        public String zipCode;
        public String city;
        public String state;
        public String userType;
        public String hcsEmail;
        public String outpatientEmail;
        public String name;
        public String participantType;
        public String credentials;
		public String othercredentials;
        public String DEA;
        public String PMC;
        public String specialty;
        public String clinicName;
        public String title;
        public String preferredContactMethod;
        public String otherContact;
        public String medSpecialityOther;
        public Boolean isActive;

    }

     @AuraEnabled
    public static List<Account> getPharmacyByIdentifier(String searchKey) {
        String escapedProgramName = String.escapeSingleQuotes('PiaSky REMS');
        List<Account> accounts = [SELECT Id, Name, US_WSREMS__Status__c,External_Pharmacy_Id__c,Address_1_Secondary_Office__c,Address_2_Secondary_Office__c,ShippingCity,US_WSREMS__State__c,ShippingPostalCode FROM Account WHERE External_Pharmacy_Id__c = :searchKey AND US_WSREMS__REMS_Program__r.Name =:escapedProgramName AND US_WSREMS__Status__c ='Certified' LIMIT 1];
         
         if(!accounts.isEmpty()){
         return accounts;
         } else {
             return null;
         }
    }

     @AuraEnabled
    public static Boolean checkDuplicateEmail(String email) {
        String escapedProgramName = String.escapeSingleQuotes('PiaSky REMS');
        try {
            List<Account> duplicateEmailonPPAcc = [
                SELECT Id 
                FROM Account 
                WHERE US_WSREMS__Email__c = :email AND  
                US_WSREMS__REMS_Program__r.Name =:escapedProgramName AND
                US_WSREMS__Record_Type_Name__c =: REMSAppLiterals.ACCOUNT_RECORDTYPE_PHARMACYPARTICIPANT
                LIMIT 1
            ];

            return !duplicateEmailonPPAcc.isEmpty();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


}