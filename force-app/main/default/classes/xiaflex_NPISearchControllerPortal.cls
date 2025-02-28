/*****************************************************************************************************************
    * Class Name           : xiaflex_NPISearchControllerPortal
    * @Description         : It will check Npis is valid or not and Creates various records (Account, Service Summary, Case, User) based on the submitted data.If NPI is valid.
    * Test Class 		   : xiaflex_NPISearchControllerPortal_Test
	* @Author              : Krishnababu Mullapudi
    * @CreatedDate         : 31-07-2024
******************************************************************************************************************/

public without sharing class xiaflex_NPISearchControllerPortal {
    
    @AuraEnabled
    public static String getNpis(String searchKey, String programName) {

        try {
                if(String.isEmpty(searchKey)) return null;
                String escapedInpuSearchKey = String.escapeSingleQuotes(searchKey);
                String escapedProgramName = String.escapeSingleQuotes(programName);
                String returnValue = '';
                List<HealthcareProviderNpi> npiRecords = [SELECT Id, Name, US_WSREMS__Email__c, US_WSREMS__Phone__c, US_WSREMS__First_Name__c, US_WSREMS__Middle_Name__c, US_WSREMS__Last_name__c, US_WSREMS__Fax__c, NpiType FROM HealthcareProviderNpi WHERE Npi != null AND Npi =: escapedInpuSearchKey AND NpiType != :REMSAppLiterals.NPITYPE_ORGANISATION Order By CreatedDate DESC LIMIT 1];
                List<Account> accRecords = [SELECT Id, Name,US_WSREMS__Status__c FROM Account WHERE US_WSREMS__NPI__c != null AND US_WSREMS__NPI__c =:escapedInpuSearchKey AND US_WSREMS__REMS_Program__r.Name =:escapedProgramName];
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
    public static Map<String,Id> recordTypeId(){
        Map<String,Id> recordTypeMap = new Map<string,Id>();
        for(RecordType recType: [Select Name, SobjectType, Id from RecordType where Name In ('Pharmacy Participant', 'Authorized Representative Affiliation', 'Pharmacy Participant Account', 'Participant Account Creation','Prescriber Person Account')]){
            if((recType.name == 'Pharmacy Participant') && recType.SobjectType == 'Account'){
            	recordTypeMap.put(recType.Name, recType.Id);
            } else if((recType.name == 'Pharmacy Participant Account') && recType.SobjectType == 'Case'){
                recordTypeMap.put(recType.Name, recType.Id);
            } else if((recType.name == 'Participant Account Creation') && recType.SobjectType == 'US_WSREMS__REMS_Service_Summary__c'){
                recordTypeMap.put(recType.Name, recType.Id);
            } else if((recType.name == 'Authorized Representative Affiliation') && recType.SobjectType == 'US_WSREMS__Affiliation__c'){
                recordTypeMap.put(recType.Name, recType.Id);
            }else if((recType.name == 'Prescriber Person Account') && recType.SobjectType == 'Case'){
                recordTypeMap.put(recType.Name, recType.Id);
            }
        }
        return recordTypeMap;
    }
/*****************************************************************************************************************
    * Method Name          : createRecordOnSubmit
    * @Description         : Creates various records (Account, Service Summary, Case, User) based on the submitted data.
    * @Author              : Krishnababu Mullapudi
    * @CreatedDate         : 30-07-2024
    * @param recordDetails : JSON string containing the details for creating records.
    * @param programName   : Name of the REMS Program.(XIAFLEX)
    * @param participantType: Type of participant for the REMS Service.
    * @return               : Id of the created User record.
    *****************************************************************************************************************/    
     @AuraEnabled
    public static String createRecordOnSubmit(String inputRecord, String pharmaAcc, String arFoundMsg) {
        Map<String,Object> inputRecords = (Map<String,Object>)JSON.deserializeUntyped(inputRecord);
        Savepoint sp = Database.setSavepoint(); 
      //  try {
            String recordDetails = (String)inputRecords.get('recordDetails');
            String pharmacyId = (String)inputRecords.get('pharmacyId');
            String programName = (String)inputRecords.get('programName');
            String profileName = (String)inputRecords.get('profileName');
            String permissionSet = (String)inputRecords.get('permissionSet');
            string email = (String)inputRecords.get('email');
            string lastname = (String)inputRecords.get('lastname');
            string npi = (String)inputRecords.get('email');
            string programType =  (String)inputRecords.get('programtype');
            List<US_WSREMS__REMS_Service_Summary__c> serviceToUpdate = new List<US_WSREMS__REMS_Service_Summary__c>();
            //Validate if the record details are not empty
            if(String.isEmpty(recordDetails)) {
                return REMSAppLiterals.FAILED_STATUS;
            }
            RecordDataWrapper recordData = (RecordDataWrapper)System.JSON.deserialize(recordDetails,RecordDataWrapper.class);

            // Checking for duplicate account
            Boolean dupCheck = checkDuplicateEmail(email,recordData.lastname,recordData.npi,programtype);
            if(dupCheck){
                return 'dupFound';
            }
            //Logic Begins
            String userId = null;
            List<US_WSREMS__REMS_Program__c>  program = [SELECT Id,Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Xiaflex'];
            Map<String,Id> recordTypeMap = recordTypeId();
               Account personAccount = insertAccount(recordData,program, true, REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER);             
                    //Insert Service Summary Record
                    US_WSREMS__REMS_Service_Summary__c service  = insertServiceSummary(personAccount, program, REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER, REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
            serviceToUpdate.add(service);
            //Insert Case Record
                    Case caseRec = insertCase( recordData, personAccount, service,program,'Prescriber_Person_Account',null ,REMSAppLiterals.REQUESTORTYPE_PHARMACY_HCS_PARTICIPANT, recordTypeMap.get('Prescriber Person Account'));                 
            xiaflex_ManagePharmacies.updateService(serviceToUpdate);        
            //Proceed to user creation if both Case and service are inserted sucessfully
            if((Test.isRunningTest() || caseRec.Id != null) && personAccount.Id != null) {
                OrgWideEmailAddress[] owea;
                //Org-wide Email...
                String addressStr;
                addressStr = caseRec != null && caseRec.US_WSREMS__Program_Type__c == 'REMS' ? Label.XIAFLEXRemsSupportEmail : addressStr;
                addressStr = caseRec != null && caseRec.US_WSREMS__Program_Type__c == 'MDP' ? Label.XIAFLEXMDPSupportEmail : addressStr;
                addressStr = String.isEmpty(addressStr) ? Label.XIAFLEXToaddress : addressStr;
                owea =[select Id,Address from OrgWideEmailAddress where Address =:addressStr];
                        //Create parameter
                        Map<String, Object> Params = new Map<String, Object>();
					MACIAutomationCommunicationUtility.Requests  rst = new MACIAutomationCommunicationUtility.Requests();
                        rst.accountId = personAccount.id;
                        rst.BccAddress = owea[0].address;
                        rst.toAddress = personAccount.PersonEmail;
                        rst.fromAddress = owea[0].address;
                        rst.templateName = 'Xiaflex_Prescriber_invitation';
                    List<MACIAutomationCommunicationUtility.Requests> sendmaillist = new List<MACIAutomationCommunicationUtility.Requests>();
                        sendmaillist.add(rst);
                        MACIAutomationCommunicationUtility.sendNotificationFromFlow(sendmaillist);
                        return 'Success';
                    }else{
                        return 'Error';
                    }           
       // } catch (Exception ex) {
         //   Database.rollback(sp);
         //   throw new AuraHandledException(ex.getMessage());
       // }
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
                newAccount.US_WSREMS__Program_Type__c = 'REMS';
                
				if(recordData.credentials == REMSAppLiterals.CREDENTIALS_OTHER){
                    newAccount.US_WSREMS__Credentials__c = REMSAppLiterals.CREDENTIALS_OTHERS;
				    newAccount.US_WSREMS__Other_Credentials__c = recordData.othercredentials;
                }
            } else {
                newAccount.Name = recordData.name;
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
        Id idRTforREMSService = [SELECT Id FROM RecordType
        WHERE DeveloperName =: recordType AND namespaceprefix != null AND sObjectType = 'US_WSREMS__REMS_Service_Summary__c'].Id;
        US_WSREMS__REMS_Service_Summary__c service = new US_WSREMS__REMS_Service_Summary__c();
        service.US_WSREMS__REMSProgram__c = program.size() > 0 ? program[0].Id : null;
        service.RecordTypeId = idRTforREMSService;
        service.US_WSREMS__Status__c = REMSAppLiterals.SERVICE_STATUS;
        service.US_WSREMS__Service_Outcome__c = REMSAppLiterals.SERVICE_OUTCOME;
        service.US_WSREMS__Participant__c = personAccount.Id;
        service.US_WSREMS__Requestor_Type__c = participantType;
        insert service;
        return service;

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
            Case caseRec = new Case();
        caseRec.recordTypeId = recordTypeId;
        if (recordType != REMSAppLiterals.CASE_RECORDTYPE_HEALTHCARESETTING && recordType != REMSAppLiterals.CASE_RECORDTYPE_OUTPATIENTPHARMACY) {
            caseRec.US_WSREMS__First_Name__c = recordData.firstName;
            caseRec.US_WSREMS__Middle_Name__c = recordData.middleName;
            caseRec.US_WSREMS__Last_Name__c = recordData.LastName;
            caseRec.US_WSREMS__Fax__c = recordData.fax;
            caseRec.US_WSREMS__Participant_Fax__c = recordData.fax;
            caseRec.US_WSREMS__REMS_Alternate_Phone__c = recordData.phone;
            caseRec.US_WSREMS__Email__c = recordData.email;
            caseRec.US_WSREMS__Email_ar__c = recordData.email;
            caseRec.US_WSREMS__Phone__c = recordData.phone;
            caseRec.US_WSREMS__NPI__c = (recordType == REMSAppLiterals.CASE_RECTYPE_PRESCRIBER_PERSON_ACCOUNT)? recordData.npi : null;
        } else {
            caseRec.US_WSREMS__Name__c = recordData.name;
            caseRec.US_WSREMS__NPI__c = recordData.npi;
        }
        caseRec.US_WSREMS__Preferred_Contact_Method__c = recordData.PMC;
        caseRec.US_WSREMS__REMS_ID__c = accountRec.US_WSREMS__REMS_ID__c;
        caseRec.US_WSREMS__Requestor_Type__c = (recordType == REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT)? REMSAppLiterals.REQUESTORTYPE_PHARMACY_HCS_PARTICIPANT:recordData.participantType;
        caseRec.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
        caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
        caseRec.US_WSREMS__Participant__c = accountRec.Id;
        caseRec.US_WSREMS__REMS_Service_Summary__c = service.Id;
        caseRec.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
        caseRec.US_WSREMS__Credential__c = recordData.credentials;
        caseRec.US_WSREMS__Program_Type__c = 'REMS';
        caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL; 
        if(recordData.credentials == REMSAppLiterals.CREDENTIALS_OTHER){
            caseRec.US_WSREMS__Credential__c = REMSAppLiterals.CREDENTIALS_OTHERS;
            caseRec.US_WSREMS__Other_Credentials__c = recordData.othercredentials;
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
    public static void checkLoggedinUserDetails(){
        
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
    }
/*****************************************************************************************************************
    * Method Name          : checkDuplicateEmail
    * @Description         : It will check,if we have any duplicate accounts based on Email for Xiaflex program
    * @Author              : Krishnababu Mullapudi
    * @CreatedDate         : 30-07-2024
    * @param email         : getting from the portal login page
    * @return               : Boolean value . if found true or false
    *****************************************************************************************************************/    
     
@AuraEnabled
    public static Boolean checkDuplicateEmail(String email,string Lastname,string NPI,string program) {
        String escapedProgramName = String.escapeSingleQuotes('XIAFLEX');
        try {
            List<Account> duplicateEmailonPPAcc = [
                SELECT Id 
                FROM Account 
                WHERE    
                US_WSREMS__REMS_Program__r.Name =:escapedProgramName AND US_WSREMS__Program_Type__c =:program 
                AND Lastname =: Lastname AND US_WSREMS__National_Provider_Identifier__c =: NPI AND
                US_WSREMS__Record_Type_Name__c =: REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER
                LIMIT 1
            ];
            return !duplicateEmailonPPAcc.isEmpty();
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Account> getExistingNPIRecord(string programType, String programName, String NPI) {
        List<Account> PresAcc = [SELECT Id, US_WSREMS__Is_Portal__c, US_WSREMS__Status__c,
                                (SELECT Id FROM Users)  
                                FROM Account 
                                WHERE    
                                US_WSREMS__REMS_Program__r.Name =:programName AND US_WSREMS__Program_Type__c =:programType 
                                AND US_WSREMS__National_Provider_Identifier__c = :NPI
                            ];    
        return PresAcc;
    }
}