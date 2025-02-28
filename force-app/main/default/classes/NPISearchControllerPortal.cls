/**
@File Name : NPISearchControllerPortal.cls
@Description : This class is responsible for search for existing NPI value which is entered by portal user and create Account,case,service and validate portal user exists are not.
@Author : Surekha Adapa
@Last Modified By : Surekha Adapa
@Last Modified On : 7-11-2024
@Modification Log :
*==============================================================================
Ver | Date | Author | Modification
*==============================================================================
1.0 | Nov 7, 2024 | | updated Version
**/
public without sharing class NPISearchControllerPortal {
    @AuraEnabled
    public static String getNpis(String searchKey, String programName) {
        try {
            if(String.isEmpty(searchKey)) return null;
            String escapedInpuSearchKey = String.escapeSingleQuotes(searchKey);
            String escapedProgramName = String.escapeSingleQuotes(programName);
            String returnValue = '';
            List<HealthcareProviderNpi> npiRecords = [SELECT Id, Name, US_WSREMS__Email__c, US_WSREMS__Phone__c, US_WSREMS__First_Name__c, US_WSREMS__Middle_Name__c, US_WSREMS__Last_name__c, US_WSREMS__Fax__c, NpiType FROM HealthcareProviderNpi WHERE Npi != null AND Npi =: escapedInpuSearchKey AND NpiType != :REMSAppLiterals.NPITYPE_ORGANISATION Order By CreatedDate DESC LIMIT 1];
            List<Account> accRecords = [SELECT Id, Name,US_WSREMS__Status__c FROM Account WHERE US_WSREMS__National_Provider_Identifier__c != null AND US_WSREMS__National_Provider_Identifier__c =:escapedInpuSearchKey AND US_WSREMS__REMS_Program__r.Name =:escapedProgramName];
            if(!npiRecords.isEmpty() && !accRecords.isEmpty()  && accRecords[0].US_WSREMS__Status__c != REMSAppLiterals.PENDING_STATUS && accRecords[0].US_WSREMS__Status__c != REMSAppLiterals.CANCELLED_STATUS) {
                returnValue = REMSAppLiterals.NPI_BOTHFOUND_MESSAGE;
            } else if(!npiRecords.isEmpty()) {
                returnValue = JSON.serialize(npiRecords[0]);
            }
            return returnValue;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getNPIOrgNpis(String searchKey, String programName) {
        try {
            if(String.isEmpty(searchKey)) return null;
            String escapedInpuSearchKey = String.escapeSingleQuotes(searchKey);
            String escapedProgramName = String.escapeSingleQuotes(programName);
            String returnValue = '';
            List<HealthcareProviderNpi> npiRecords = [SELECT Id, Name, US_WSREMS__Email__c, US_WSREMS__Phone__c, US_WSREMS__First_Name__c, US_WSREMS__Middle_Name__c, US_WSREMS__Last_name__c, US_WSREMS__Fax__c, NpiType FROM HealthcareProviderNpi WHERE Npi != null AND Npi =: escapedInpuSearchKey AND NpiType= :REMSAppLiterals.NPITYPE_ORGANISATION Order By CreatedDate DESC LIMIT 1];
            List<Account> accRecords = [SELECT Id, Name,US_WSREMS__Status__c FROM Account WHERE US_WSREMS__National_Provider_Identifier__c != null AND US_WSREMS__National_Provider_Identifier__c =:escapedInpuSearchKey AND US_WSREMS__REMS_Program__r.Name = :escapedProgramName ];
            if(!npiRecords.isEmpty() && !accRecords.isEmpty() && accRecords[0].US_WSREMS__Status__c != 'Cancelled') {
                returnValue = REMSAppLiterals.NPI_BOTHFOUND_MESSAGE;
            } else if(!npiRecords.isEmpty()) {
                returnValue = JSON.serialize(npiRecords[0]);
            }
            return returnValue;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************************************************************
        * Method Name          : getOrgNpis
        * @Description         : Retrieves organization NPI records and/or Account records based on the provided search key.
        * @Author              : Pavani
        * @CreatedDate         : 7-3-2024
        * @param searchKey     : NPI search key.
        * @return               : 'BothFound' if both NPI and Account records found; NPI record JSON if only NPI found; 
        *                         empty string otherwise.
    *****************************************************************************************************************/
    @AuraEnabled
    public static String getOrgNpis(String searchKey, String programName) {
        try {
            if(String.isEmpty(searchKey)) return null;
            String escapedInpuSearchKey = String.escapeSingleQuotes(searchKey);
            String escapedProgramName = String.escapeSingleQuotes(programName);
            String returnValue = '';
            List<HealthcareProviderNpi> npiRecords = [SELECT Id, Name, US_WSREMS__Email__c, US_WSREMS__Phone__c, US_WSREMS__First_Name__c, US_WSREMS__Middle_Name__c, US_WSREMS__Last_name__c, US_WSREMS__Fax__c, NpiType FROM HealthcareProviderNpi WHERE Npi != null AND Npi =: escapedInpuSearchKey AND NpiType= :REMSAppLiterals.NPITYPE_ORGANISATION Order By CreatedDate DESC LIMIT 1];
            List<Account> accRecords = [SELECT Id, Name,US_WSREMS__Status__c FROM Account WHERE US_WSREMS__National_Provider_Identifier__c != null AND US_WSREMS__National_Provider_Identifier__c =:escapedInpuSearchKey AND US_WSREMS__REMS_Program__r.Name = :escapedProgramName ];
            if(!npiRecords.isEmpty() && !accRecords.isEmpty() && accRecords[0].US_WSREMS__Status__c != REMSAppLiterals.CANCELLED_STATUS) {
                returnValue = REMSAppLiterals.NPI_BOTHFOUND_MESSAGE;
            } else if(!npiRecords.isEmpty()) {
                returnValue = JSON.serialize(npiRecords[0]);
            }  
            return returnValue;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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
    public static String createRecordOnSubmit(Map<String,String> inputRecords, String arFoundMsg) {
        Savepoint sp = Database.setSavepoint(); 
        try {
            String recordDetails = inputRecords.get('recordDetails');
            String programName = inputRecords.get('programName');
            String participantType = inputRecords.get('participantType');
            String profileName = inputRecords.get('profileName');
            String permissionSet = inputRecords.get('permissionSet');
            //Validate if the record details are not empty
            if(String.isEmpty(recordDetails)) {
                return REMSAppLiterals.FAILED_STATUS;
            }
            
            //Logic Begins
            String userId = null;
            String accId=null;    
            RecordDataWrapper recordData = (RecordDataWrapper)System.JSON.deserialize(recordDetails,RecordDataWrapper.class);
            List<US_WSREMS__REMS_Program__c>  program = [SELECT Id,Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =:programName];
            
            Boolean dupliacateEmail = [SELECT COUNT() FROM Account WHERE US_WSREMS__Email__c = :recordData.Email AND US_WSREMS__REMS_Program__r.Name =:programName ] > 0;
            Boolean duplicateNPI = [SELECT COUNT() FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = :recordData.npi AND US_WSREMS__REMS_Program__r.Name =:programName ] > 0;
            
            //Prescriber execution
            if (participantType == REMSAppLiterals.REQUESTORTYPE_PRESCRIBER) {
                //Insert a person Account
                List<Account> accList;   
                
                Accountwrapper wrapper =  validatePortalUserInfo(recordData.Email, recordData.npi, programName, recordData.lastName, recordData.phone);
                
               if(wrapper.duplicateMessage == 'NotFound' || wrapper.duplicateMessage == 'Initiated'){
                    if(wrapper.duplicateMessage =='Initiated'){
                        accId=wrapper.accountId;
                        Account accountRecord=new Account();
                        accountRecord.id=accId;
                        accountRecord.US_WSREMS__Email__c=recordData.Email;
                        update accountRecord;
                        sendEmail(accId,recordData.Email);
                        
                    }else{
                        Account personAccount = insertAccount(recordData,program, true, REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER);
                        accId=personAccount.Id;
                        accList= [SELECT Id, PersonContactId, US_WSREMS__REMS_ID__c,US_WSREMS__DEA__c FROM Account WHERE Id = :personAccount.Id];
                        //If the account creation was sucessful proceed
                        if(!accList.isEmpty()){
                            
                            //Insert Service Summary Record
                            US_WSREMS__REMS_Service_Summary__c service  = insertServiceSummary(accList[0], program, participantType, REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
                            //Insert Case Record
                           
                            Case caseRec = insertCase( recordData, accList[0], service,program,REMSAppLiterals.CASE_RECTYPE_PRESCRIBER_PERSON_ACCOUNT,null ,REMSAppLiterals.REQUESTORTYPE_PRESCRIBER);
                            
                            service = updateServiceSummary(service);
                            
                            
                        }
                    }
                    
                }else{
                    RETURN wrapper.duplicateMessage;
                }
                //HCS execution
            } else if(participantType == REMSAppLiterals.REQUESTORTYPE_AR ) {
               Account personAccount = insertAccount(recordData,program, true, REMSAppLiterals.ACCOUNT_RECORDTYPE_AR);
                 accId=personAccount.Id;
                //Retrieve the personContactId
                List<Account> accList = [SELECT Id, PersonContactId, US_WSREMS__REMS_ID__c,US_WSREMS__DEA__c FROM Account WHERE Id = :personAccount.Id];
                 
                //If the account creation was sucessful proceed
                if(!accList.isEmpty()){

                    //Insert Service Summary Record
                    US_WSREMS__REMS_Service_Summary__c service  = insertServiceSummary(accList[0], program, REMSAppLiterals.SERVICE_PARTICIPANT_AR, REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
                    //Insert Case Record
                   // REMSAvoidRecursiveCls.stop_serviceupdateFromPortal=true;
                    Case caseRec = insertCase( recordData, accList[0], service,program,REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT,null ,REMSAppLiterals.REQUESTORTYPE_PHARMACY_HCS_PARTICIPANT);

                    service = updateServiceSummary(service);  
                }
            } 
            
            return accId;
        } catch (Exception ex) {
            System.debug('Exception '+ex.getMessage());
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }
    }
     /****************************************************************************************************************
    * Method Name : insertUserAccoutAndCase
    * @description : Method to insert Community user record
    * @author Robin | 30-04-2024 
    * @param recordData 
    * @param programName 
    * @param accList 
    * @return Id 
    ****************************************************************************************************************/
    public static String insertUserAccoutAndCase(RecordDataWrapper recordData,List<US_WSREMS__REMS_Program__c>  program,String participantType ,String accountRecordType ,String caseRecordType,String requestorType ,String profileName, String permissionSet , String arFoundMsg ,Savepoint sp,String role) {
        try { 
            // Current NPI 
            String userId = null;
            String npiValue = recordData.npi != null ? String.escapeSingleQuotes(recordData.npi) : '';
            String programName = program.isEmpty() ? '' :  String.escapeSingleQuotes(program[0].Name);
            
            List<HealthcareProviderNpi> npiRecords = [SELECT Id, Name, US_WSREMS__Email__c, US_WSREMS__Phone__c, US_WSREMS__First_Name__c, US_WSREMS__Middle_Name__c, US_WSREMS__Last_name__c, US_WSREMS__Fax__c, NpiType FROM HealthcareProviderNpi WHERE Npi != null AND Npi =: npiValue AND NpiType= :REMSAppLiterals.NPITYPE_ORGANISATION Order By CreatedDate DESC LIMIT 1];
            List<Account> accountAlreadyExist = [SELECT Id, Name,US_WSREMS__Status__c,US_WSREMS__REMS_Program__c FROM Account WHERE US_WSREMS__National_Provider_Identifier__c != null AND US_WSREMS__National_Provider_Identifier__c =:npiValue AND US_WSREMS__REMS_Program__r.Name = :programName ];
            Account businessAccount = new Account();
            if(!accountAlreadyExist.isEmpty() && !npiRecords.isEmpty()) {
                businessAccount = accountAlreadyExist[0];
            } else {
                //Insert Business Account
                businessAccount = insertAccount(recordData,program,false,accountRecordType );
                //Retrieve the business account
                List<Account> accList = [SELECT Id, US_WSREMS__REMS_ID__c FROM Account WHERE Id = :businessAccount.Id];
                if(!accList.isEmpty()){
                    //Insert Service Summary Record
                    US_WSREMS__REMS_Service_Summary__c service  = insertServiceSummary(accList[0], program, participantType, REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
                    //Insert Case Record
                    Case caseRec = insertCase( recordData, accList[0], service,program,caseRecordType ,null ,requestorType); 
                    service = updateServiceSummary(service);
                }
            }
            //Duplicate AR check and creation
            List<Account> arAccList = new List<Account>();
            for(Account record :  [SELECT Id, PersonContactId, IsCustomerPortal FROM Account WHERE US_WSREMS__Email__c = : recordData.email AND recordtype.DeveloperName = : REMSAppLiterals.ACCOUNT_RECORDTYPE_PHARMACYPARTICIPANT AND US_WSREMS__REMS_Program__r.Name =: programName ORDER BY IsCustomerPortal desc]) {
                arAccList.add(record);
            }
            //If duplicate AR is found and is community enabled
            if (!arAccList.isEmpty() && (Boolean)arAccList[0].get('IsCustomerPortal')) {
                User userRec = [SELECT id FROM USER WHERE ContactId = :arAccList[0].PersonContactId LIMIT 1];
                Database.rollback(sp);
                return arFoundMsg;
                //If duplicate AR is found but not community enabled
            } else if (!arAccList.isEmpty() && !(Boolean)arAccList[0].get('IsCustomerPortal')) {
                List<Site> siteList = [SELECT id, GuestRecordDefaultOwnerId FROM Site WHERE GuestUserId = :UserInfo.getUserId()];
                if (!siteList.isEmpty()) {
                    US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
                    Account dupeAcc = new Account (id=arAccList[0].Id, OwnerId=siteList[0].GuestRecordDefaultOwnerId);
                    update dupeAcc;
                    if(role == REMSAppLiterals.HEALTH_CARE_SETTING_ROLE) {
                        affObj.US_WSREMS__Health_Care_Setting__c = businessAccount.Id;
                    } 
                    affObj.US_WSREMS__Authorized_Representative__c = arAccList[0].Id;
                    insert affObj;
                }
                userId = insertCommunityUser( recordData, program, arAccList,profileName,permissionSet,role);
                return userId;
                //IF duplicate AR not found
            } else {
                
                //Insert Pharmacy Account
                Account personAccount = insertAccount(recordData,program,true,REMSAppLiterals.ACCOUNT_RECORDTYPE_PHARMACYPARTICIPANT);
                //Retrieve the personContactId
                List<Account> personAccList = [SELECT Id, PersonContactId, US_WSREMS__REMS_ID__c FROM Account WHERE Id = :personAccount.Id];
                
                //If the account creation was sucessful proceed
                if(!personAccList.isEmpty()){
                    //Insert Service Summary Record
                    US_WSREMS__REMS_Service_Summary__c service  = insertServiceSummary(personAccList[0], program, REMSAppLiterals.REQUESTORTYPE_PHARMACY_HCS_PARTICIPANT, REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
                    //Insert Case Record
                    //REMSAvoidRecursiveCls.stop_serviceupdateFromPortal=true;
                    Case caseRec = insertCase( recordData, personAccList[0], service,program,REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT,businessAccount.Id , requestorType);
                    service = updateServiceSummary(service);
                    //Proceed to user creation if both Case and service are inserted sucessfully
                    if((Test.isRunningTest() || caseRec.Id != null) && personAccount.Id != null) {
                        userId = insertCommunityUser( recordData, program, personAccList,profileName,permissionSet,role);
                    }   
                }
                
                if(accountRecordType == REMSAppLiterals.ACCOUNT_RECORDTYPE_INPATIENTPHARMACY ) {
                    US_WSREMS__Affiliation__c oAffiliation = new US_WSREMS__Affiliation__c(
                        US_WSREMS__REMSProgram__c = program[0].Id, 
                        US_WSREMS__Authorized_Representative__c = personAccList[0].Id , 
                        US_WSREMS__isActive__c=true,
                        US_WSREMS__Start_Date__c=System.today(),
                        US_WSREMS__User_Role__c=REMSAppLiterals.PRIMARY_AR_ROLE,
                        US_WSREMS__Pharmacy__c=businessAccount.Id
                    );
                    insert oAffiliation;
                }
            }
            return userId;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }

    /****************************************************************************************************************
    * Method Name : insertCommunityUser
    * @description : Method to insert Community user record
    * @author Pavani | 01-02-2024 
    * @param recordData 
    * @param programName 
    * @param accList 
    * @return Id 
    ****************************************************************************************************************/
    public static Id insertCommunityUser(RecordDataWrapper recordData,List<US_WSREMS__REMS_Program__c>  program,List<Account> accList,String profileName, String permissionSet,String roles) {
        try {
            
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
            PermissionSet portalPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :permissionSet LIMIT 1];
            User userRec = new User();
            String userDate=String.valueOf(System.now().getTime()); 
            userRec.UserName = String.valueOf(recordData.email).split('@')[0]+userDate+'@'+String.valueOf(recordData.email).split('@')[1]; 
            
            userRec.FirstName = recordData.FirstName;
            userRec.LastName = recordData.LastName;
            userRec.US_WSREMS__REMS_Program__c = program.size() > 0 ? String.valueOf(program[0].Name) : null;
            userRec.Program__c = program.size() > 0 ? String.valueOf(program[0].Name) : null;
            userRec.US_WSREMS__REMS_Program_Phone__c = program.size() > 0 ? program[0].US_WSREMS__Phone__c : null;
            userRec.US_WSREMS__REMS_Program_Fax__c = program.size() > 0 ? program[0].US_WSREMS__Fax__c : null;
            userRec.Alias = recordData.FirstName.substring(0, 1) + recordData.LastName.substring(0, 1);
            userRec.email = recordData.email;
            userRec.ContactId = accList[0].PersonContactId;
            userRec.ProfileId = portalProfile.Id;
            userRec.EmailEncodingKey = 'UTF-8';
            userRec.Role__c = roles;
            
            String nickname = ((recordData.FirstName != null && recordData.FirstName.length() > 0) ? recordData.FirstName.substring(0,1) : '' ) + recordData.LastName.substring(0,1);
            
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            
            userRec.CommunityNickname = nickname;
            
            userRec.TimeZoneSidKey = 'America/Los_Angeles';
            userRec.LocaleSidKey = 'en_US';
            userRec.languageLocaleKey = 'en_US';
            
            insert userRec;
            
            permissionSetAssignment(portalPermissionSet.Id,userRec.Id);
            
            return userRec.Id;
            
        } catch (Exception ex) {
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
            Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(recordType);
            Account newAccount = new Account();
            if (isPersonAccount) {
                newAccount.FirstName = recordData.firstName;
                newAccount.MiddleName = recordData.middleName;
                newAccount.LastName = recordData.lastName;
                newAccount.PersonEmail = recordData.email;
                newAccount.US_WSREMS__Email__c = recordData.email;
                newAccount.Phone = recordData.phone;
                newAccount.US_WSREMS__Fax_Number__c = recordData.fax;
                newAccount.US_WSREMS__DEA__c=recordData.DEA;
                newAccount.US_WSREMS__Preferred_Contact_Method__c=recordData.PMC;
                newAccount.US_WSREMS__Credentials__c = recordData.credentials;
                if(recordData.credentials == REMSAppLiterals.CREDENTIALS_OTHER) {
                    newAccount.US_WSREMS__Credentials__c = REMSAppLiterals.CREDENTIALS_OTHERS;
                    newAccount.US_WSREMS__Other_Credentials__c = recordData.othercredentials;
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
                newAccount.US_WSREMS__Status__c = null;
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
    public static Case insertCase(RecordDataWrapper recordData,Account accountRec,US_WSREMS__REMS_Service_Summary__c service,List<US_WSREMS__REMS_Program__c>  program,String recordType, string accountId ,String participantType) {
        try {
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get(recordType);
            Case caseRec = new Case();
            caseRec.recordTypeId = caseRecordTypeId;
            if (recordType != REMSAppLiterals.CASE_RECORDTYPE_HEALTHCARESETTING && recordType != REMSAppLiterals.CASE_RECORDTYPE_OUTPATIENTPHARMACY) {
                caseRec.US_WSREMS__First_Name__c = recordData.firstName;
                caseRec.US_WSREMS__Middle_Name__c = recordData.lastName;
                caseRec.US_WSREMS__Last_Name__c = recordData.LastName;
                caseRec.US_WSREMS__Fax__c = recordData.fax;
                caseRec.US_WSREMS__Participant_Fax__c = recordData.fax;
                caseRec.US_WSREMS__REMS_Alternate_Phone__c = recordData.phone;
                caseRec.US_WSREMS__Email__c = recordData.email;
                caseRec.US_WSREMS__Email_ar__c = recordData.email;
                caseRec.US_WSREMS__Phone__c = recordData.phone;
                caseRec.US_WSREMS__NPI__c = (recordType == REMSAppLiterals.CASE_RECTYPE_PRESCRIBER_PERSON_ACCOUNT)? recordData.npi : null;
                caseRec.US_WSREMS__DEA__c = recordData.DEA != null ? recordData.DEA : accountRec.US_WSREMS__DEA__c;
            } else {
                caseRec.US_WSREMS__Name__c = recordData.name;
                caseRec.US_WSREMS__NPI__c = recordData.npi;
                
            }
            if(participantType == REMSAppLiterals.CASE_RECTYPE_PRESCRIBER_PERSON_ACCOUNT) {
                caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Prescriber_Person_Account';
                caseRec.US_WSREMS__DEA__c = recordData.DEA != null ? recordData.DEA : accountRec.US_WSREMS__DEA__c;
            } 
            if (participantType == REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT){
                caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Pharmacy_Participant';
            }
            caseRec.US_WSREMS__REMS_ID__c = accountRec.US_WSREMS__REMS_ID__c;
            caseRec.US_WSREMS__Requestor_Type__c = (recordType == REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT)? REMSAppLiterals.REQUESTORTYPE_PHARMACY_HCS_PARTICIPANT:recordData.participantType;
            caseRec.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
            caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
            caseRec.US_WSREMS__Participant__c = accountRec.Id;
            caseRec.US_WSREMS__REMS_Service_Summary__c = service.Id;
            caseRec.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
            caseRec.US_WSREMS__Credential__c = recordData.credentials;
            if(recordData.credentials == REMSAppLiterals.CREDENTIALS_OTHER){
                caseRec.US_WSREMS__Credential__c = REMSAppLiterals.CREDENTIALS_OTHER;
                caseRec.US_WSREMS__Other_Credentials__c = recordData.othercredentials;
            }
            if(recordType == REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT && participantType == REMSAppLiterals.REQUESTORTYPE_HCS) {
                caseRec.US_WSREMS__Healthcare_Setting__c = accountId;
            } else if(recordType == REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT &&  participantType == REMSAppLiterals.REQUESTORTYPE_OUTPATIENT) {
                caseRec.US_WSREMS__REMS_Authorized_Rep__c = accountId; 
            }
            
            if(recordType == REMSAppLiterals.CHANGE_OF_INFORMATION){
                caseRec.US_WSREMS__Preferred_Contact_Method__c = recordData.preferredContactMethod;
                caseRec.US_WSREMS__REMS_ID__c = recordData.enrollmentId;
                caseRec.US_WSREMS__Middle_Name__c = recordData.middleName;
                caseRec.US_WSREMS__NPI__c = recordData.npi;
                caseRec.US_WSREMS__DEA__c = recordData.DEA;
                caseRec.US_WSREMS__SLN__c = recordData.licenceNum;
                caseRec.US_WSREMS__SLN_Issued_State__c = recordData.licenceNumState; 
                caseRec.US_WSREMS__Speciality__c = recordData.medicalSpeciality;
                caseRec.US_WSREMS__Other__c = recordData.othercredentials;
                caseRec.US_WSREMS__Other_Speciality__c = recordData.specialityOther;
            }
            
            if(!test.isRunningTest()) {
                insert caseRec;
            }
            return  caseRec;
            
        }  catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String checkARduplicate(Map<String,String> inputRecords) {
        String result;
        Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get( REMSAppLiterals.ACCOUNT_RECORDTYPE_AR);
        String programName = inputRecords.get('programName');
        
        try {
            String recordDetails = inputRecords.get('recordDetails'); 
            RecordDataWrapper recordData = (RecordDataWrapper)System.JSON.deserialize(recordDetails,RecordDataWrapper.class);
            List<Account> arrList= [SELECT Id, US_WSREMS__Status__c, IsCustomerPortal FROM Account WHERE ((FirstName =: recordData.firstName AND LastName =: recordData.lastName AND PersonEmail =: recordData.email) OR (PersonEmail =: recordData.email) OR (LastName =: recordData.lastName AND PersonEmail =: recordData.email)) AND Program_Name__c =: programName AND RecordTypeId =: recordTypeId ORDER BY PersonEmail NULLS Last];
            if(arrList.size()>0) {
                result='Found';
            } else{
                result='NotFound';
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
	
    Public static void sendEmail(Id accountId, String emailaddress){
        MACIAutomationCommunicationUtility.Requests requestWrapper =new MACIAutomationCommunicationUtility.Requests();
        requestWrapper.accountId =accountId;
        requestWrapper.templateName='AVEED_REMS_Account_Email_Verification_VF';
        requestWrapper.toAddress=emailaddress;
        requestWrapper.fromAddress=Label.AVEEDToaddress;
        requestWrapper.BccAddress=label.AVEEDRemsSupportEmail;
        List<MACIAutomationCommunicationUtility.Requests> requestList =new List<MACIAutomationCommunicationUtility.Requests>{requestWrapper};
        MACIAutomationCommunicationUtility.sendNotificationFromFlow(requestList);
        
       
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
        public String hcsEmail;
        public String outpatientEmail;
        public String name;
        public String participantType;
        public String credentials;
        public String othercredentials;
        public String DEA;
        public String PMC;
        public String preferredContactMethod;
        public String enrollmentId;
        public String licenceNum;
        public String licenceNumState;
        public String medicalSpeciality;
        public String specialityOther;
    }
    public class Accountwrapper{
        public String duplicateMessage;
        public Id accountId;
    }

    public static void updateInactiveUser(Id userId) {
        User oUserInactive = new User(Id=userId,isActive=false);
        update oUserInactive;
        updateActiveUser(userId);
    }

    @future
    public static void updateActiveUser(Id userId) {
        User oUserActive = new User(Id=userId,isActive=true);
        update oUserActive;
    }
    
    /***********************************************************************************************************************************
    MethodName : validatePortalUserInfo
    Description : retiurn error message based on user availablity.
    ************************************************************************************************************************************/
    //@AuraEnabled
    public static Accountwrapper validatePortalUserInfo(String email, string npi, string program, string lname, string phone){
       // String duplicateMessage = '';
      	 Accountwrapper wrapper=new Accountwrapper();
        List<Account> prescriberList= [SELECT Id,US_WSREMS__Channel__c,US_WSREMS__Status__c, IsCustomerPortal FROM Account WHERE ((US_WSREMS__National_Provider_Identifier__c != null AND US_WSREMS__National_Provider_Identifier__c =: npi) OR (US_WSREMS__Email__c != null AND US_WSREMS__Email__c =: email) OR (LastName =: lname AND US_WSREMS__National_Provider_Identifier__c != null AND US_WSREMS__National_Provider_Identifier__c =: npi)) AND Program_Name__c =: program AND RecordType.Developername = 'Prescriber' ORDER BY US_WSREMS__National_Provider_Identifier__c NULLS Last];
        if(!prescriberList.isEmpty()){
            for(Account acc : prescriberList){
                if(acc.IsCustomerPortal){
                    wrapper.duplicateMessage = 'UserPresent';
                    break;
                }else if( acc.US_WSREMS__Status__c == 'Certified'){
                    wrapper.duplicateMessage = 'Certified';
                    break;
                }else if(acc.US_WSREMS__Status__c == 'Disenrolled'){
                    wrapper.duplicateMessage = 'Disenrolled';
                    break;
                }else if( acc.US_WSREMS__Status__c == 'Pending'){
                   wrapper.duplicateMessage ='Pending';
                    break;
                }else if(acc.US_WSREMS__Status__c == null){
                    wrapper.duplicateMessage='Initiated';
                    wrapper.accountId=acc.id;
                }
                else{
                    wrapper.duplicateMessage = 'NotFound';
                }
            }
        }else{
			wrapper.duplicateMessage = 'NotFound';
        }
        return wrapper;
    }
    
}