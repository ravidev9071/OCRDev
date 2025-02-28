/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class xiaflex_ManagePharmacies {
    
    @AuraEnabled
    public static List<account> getPharmaAccount(String userId){
        User loginUser = SYN_CommonUtility.getCurrentUserContactDetails(userId);
        if(loginUser != null){            
            List<Account> pharmaAcc = new List<Account>();
            pharmaAcc = [ SELECT Id, name, Fax, US_WSREMS__Healthcare_Setting_Type__c,US_WSREMS__Status__c,SYN_Ref_Id__c,US_WSREMS__REMS_ID__c,US_WSREMS__DEA__c,US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c, US_WSREMS__Zip__c, US_WSREMS__City__c, US_WSREMS__State__c 
                        FROM Account WHERE Id in 
                            (SELECT US_WSREMS__Health_Care_Setting__c 
                            FROM US_WSREMS__Affiliation__c 
                            WHERE US_WSREMS__Prescriber__c =: loginUser.Contact.AccountId 
                            AND US_WSREMS__isActive__c = true
                            )
                        ];
                return pharmaAcc; 
        }else 
            return null;

    }
    
    @AuraEnabled
    public static List<account> getARPharmaAccount(String userId, String programType){
        User loginUser = SYN_CommonUtility.getCurrentUserContactDetails(userId);
        if(loginUser != null){
            List<Account> pharmaAcc = new List<Account>();       
             pharmaAcc = [ SELECT Id, name, Fax, US_WSREMS__Healthcare_Setting_Type__c,US_WSREMS__Role__c,US_WSREMS__Status__c,US_WSREMS__REMS_ID__c,US_WSREMS__DEA__c,US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c, US_WSREMS__Zip__c, US_WSREMS__City__c, US_WSREMS__State__c,
             (SELECT Id, RecordType.DeveloperName, CreatedDate FROM US_WSREMS__Cases8__r WHERE RecordType.DeveloperName = 'HCS_Reenrollment' ORDER BY CreatedDate DESC)  FROM Account WHERE Id in (SELECT US_WSREMS__Health_Care_Setting__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Authorized_Representative__c =: loginUser.Contact.AccountId AND US_WSREMS__isActive__c = true AND RecordType.name = 'Authorized Representative Affiliation' ) ];
                        return pharmaAcc; 

        }
        else return null;
    }
    
    @AuraEnabled
    public static Map<String,List<Account>> getPharmaAccountDetails(String accId){
        List<Account> pharmaAcc = new List<Account>();
        Map<String,List<Account>> mapToReturn = new Map<String,List<Account>>();
        pharmaAcc = [SELECT Id, name, Phone, Fax, US_WSREMS__Role__c, US_WSREMS__HIN__c, US_WSREMS__NCPDP__c, US_WSREMS__Healthcare_Setting_Type__c, US_WSREMS__Status__c, US_WSREMS__REMS_ID__c, US_WSREMS__DEA__c,US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c, US_WSREMS__Zip__c, US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Recertification_Due_Date__c FROM Account WHERE Id =: accId];
        mapToReturn.put('pharma', pharmaAcc);
        List<Account> prescriberAcc = [SELECT Id, US_WSREMS__Role__c, US_WSREMS__REMS_ID__c, Name, US_WSREMS__Status__c, US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c, US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Zip__c, US_WSREMS__Recertification_Due_Date__c FROM Account WHERE Id In (SELECT US_WSREMS__Prescriber__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Health_Care_Setting__c  =: pharmaAcc[0].Id AND US_WSREMS__isActive__c = true AND RecordType.name = 'Prescriber Affiliation')];
        mapToReturn.put('prescriber', prescriberAcc);
        return mapToReturn;
    }
    
    @AuraEnabled
    public static Account getARrecord(String userId, String programName){
        User loginUser = SYN_CommonUtility.getCurrentUserContactDetails(userId);
        List<Account> arAcc = [SELECT Id, Salutation, FirstName, LastName, PersonEmail, Name, Phone, Fax, US_WSREMS__Role__c, US_WSREMS__Other__c, US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__Legal_Guardian_Name__c, MiddleName, US_WSREMS__Phone_Type__c FROM Account WHERE  RecordType.Name  = 'Pharmacy/HCS Participant' AND Program_Name__c = :programName And Id =: loginUser.Contact.AccountId];
        
        return arAcc[0];
    }
    
    @AuraEnabled
    public static String removeAffiliation(Map<String,String> inputRecords){
        List<US_WSREMS__Affiliation__c> affList = new List<US_WSREMS__Affiliation__c>(); 
        Savepoint sp = Database.setSavepoint(); 
        try{
            String programName = inputRecords.get('programName');
            String accId = inputRecords.get('Id'); 
            string currentuserID = inputRecords.get('CurrentuserID');
            User loginUser = SYN_CommonUtility.getCurrentUserContactDetails(currentuserID);
            boolean onlyaffliation = false;
            List<US_WSREMS__REMS_Program__c>  program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =:programName];
            Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
            List<US_WSREMS__Affiliation__c> affiliationlist = [SELECT Id,US_WSREMS__Health_Care_Setting__c, US_WSREMS__isActive__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Prescriber__c =: loginUser.Contact.AccountId AND US_WSREMS__isActive__c = true];
            
            if(affiliationlist != null){
                for(US_WSREMS__Affiliation__c aff: affiliationlist){
                    if(aff.US_WSREMS__Health_Care_Setting__c == accId)
                    aff.US_WSREMS__isActive__c = false;
                    affList.add(aff);
                }
                if(affiliationlist.size() == 1){
                    List<US_WSREMS__REMS_Service_Summary__c> serviceToUpdate = new list<US_WSREMS__REMS_Service_Summary__c>();
                    onlyaffliation = true;
                    deactivateUser(loginUser.Id);
                    Account accDeactivated = updateAccount(loginUser.Contact.AccountId);
                    US_WSREMS__REMS_Service_Summary__c serviceEnrollmentpolo = insertServiceSummary(accDeactivated,program,'Prescriber','Deactivation');
                    insert serviceEnrollmentpolo;
                    Case caseRec = insertCase(null, accDeactivated, serviceEnrollmentpolo, program, 'Deactivation', REMSAppLiterals.REQUESTORTYPE_PRESCRIBER, caseRecordTypeMap.get('Deactivation'), false);
                    insert caseRec;
                    serviceToUpdate.add(serviceEnrollmentpolo);
                    updateService(serviceToUpdate);
                }
                update affList;
            }

        if(!onlyaffliation){
        return 'Success';
        }
        return 'logout';
        } catch (Exception ex) {
             Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
     
    public static Account updateAccount(Id updateAccount){
        Account deactivateAcc = [Select id, FirstName, LastName, US_WSREMS__Status__c, US_WSREMS__REMS_ID__c from account where id = : updateAccount];
        deactivateAcc.US_WSREMS__Status__c = 'Decertified';
        deactivateAcc.US_WSREMS__Sub_Status__c = 'Enrollment Expired';
        update deactivateAcc;
        return deactivateAcc;
    } 
    @future
        public static void deactivateUser(Id loginuserId){
            User oUserInactive = new User(Id=loginuserId,isActive=false);
            update oUserInactive; 
        }
    
    @AuraEnabled
    public static List<Account> getPrescriberList(String enrollId, String firstName, String lastName, String programType){
        List<Account> accounts;
        String programName = 'Xiaflex';
        if(String.isEmpty(enrollId) && String.isEmpty(firstName) && String.isEmpty(lastName)) return null;
        if(!String.isEmpty(enrollId)){
            accounts = [SELECT Id, Name, US_WSREMS__Status__c, US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c, US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Zip__c, US_WSREMS__REMS_ID__c   FROM Account WHERE US_WSREMS__REMS_ID__c != null AND US_WSREMS__REMS_ID__c = : enrollId AND US_WSREMS__REMS_Program__r.Name =: programName AND US_WSREMS__Record_Type_Name__c = 'Prescriber' AND US_WSREMS__Program_Type__c =: programType LIMIT 1];
        } else{
            String firstNameQuery = '%' + firstName + '%';
            String lastNameQuery = '%' + lastName + '%';              
            accounts = [SELECT Id, Name, US_WSREMS__Status__c, US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c, US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Zip__c, US_WSREMS__REMS_ID__c FROM Account
                        WHERE  ((LastName LIKE :lastNameQuery )
                                OR (FirstName LIKE :firstNameQuery AND  LastName LIKE :lastNameQuery) )
                        AND US_WSREMS__REMS_Program__r.Name =: programName AND US_WSREMS__Record_Type_Name__c = 'Prescriber' AND US_WSREMS__Program_Type__c =: programType LIMIT 4999];
        
        }   
                return accounts;   

    }
    
    @AuraEnabled
    public static String insertprescriberPharmaAffiliation(Map<String,String> inputRecords){
        Savepoint sp = Database.setSavepoint(); 
        try{
        String prescriberId  = inputRecords.get('prescriberId');
        String pharmaId  = inputRecords.get('pharmaId');
        String programName  = inputRecords.get('programName');
        List<US_WSREMS__REMS_Program__c>  program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =:programName];
        US_WSREMS__Affiliation__c affiliationRec = insertAffiliation(prescriberId, program, pharmaId, 'Prescriber Affiliation');
        insert affiliationRec;
        
        return 'Success';
    }catch (Exception ex) {
             Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String insertHCPSubmit(Map<String,String> inputRecords, String userId, boolean hcsEntry){
        Savepoint sp = Database.setSavepoint();
        try{  
        String programName = inputRecords.get('programName');
        String recordDetails = inputRecords.get('recordDetails');
        String accId = inputRecords.get('Id');
        String programType = inputRecords.get('programType');
        
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        List<US_WSREMS__REMS_Program__c>  program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =:programName];
        RecordDataWrapper recordData = (RecordDataWrapper)System.JSON.deserialize(recordDetails,RecordDataWrapper.class);
        User loginUser = SYN_CommonUtility.getCurrentUserContactDetails(userId);
        boolean PrescriberCertified  = getAccountStatusCertified(loginUser.Contact.AccountId);
        if(hcsEntry){
            Account pharmaAccount = insertAccount(recordData,program, false, REMSAppLiterals.ACCOUNT_RECORDTYPE_HEALTHCARESETTING);
            if(programType == 'MDP'){
                pharmaAccount.US_WSREMS__Program_Type__c = 'MDP';
            }
            Boolean dupCheck = checkDuplicate(pharmaAccount, programType == 'MDP' ? 'MDP' : 'REMS' );
                if(dupCheck){
                    return 'dupFound';
                }
            if(recordData.Channel != null && recordData.Channel == 'fax'){
                pharmaAccount.US_WSREMS__Channel__c = 'fax';
            }
            insert pharmaAccount;
            List<Account> pharmacyAccount = [SELECT Id,US_WSREMS__REMS_ID__c, Name from Account WHERE Id =: pharmaAccount.Id LIMIT 1];
            US_WSREMS__REMS_Service_Summary__c serviceEnrollment = insertServiceSummary(pharmacyAccount[0],program,'Health Care Setting','Enrollment');
            insert serviceEnrollment;
            Case caseRec = insertCase( recordData, pharmacyAccount[0], serviceEnrollment,program,'Health_Care_Setting', REMSAppLiterals.REQUESTORTYPE_HCS, caseRecordTypeMap.get('Health_Care_Setting'), false);
            insert caseRec;
            US_WSREMS__Affiliation__c affiliationRec  = insertAffiliation(loginUser.Contact.AccountId , program, pharmaAccount.id, 'Prescriber Affiliation');
            if(PrescriberCertified != true){
                affiliationRec.US_WSREMS__isActive__c = false;
                affiliationRec.US_WSREMS__Start_Date__c = null;
            }
            insert  affiliationRec;
        } else{
            boolean checkDuplicateAff = checkAffOnPres(loginUser.Contact.AccountId, accId, 'Prescriber Affiliation');
            if(checkDuplicateAff){
                return 'dupFound';
            }
            US_WSREMS__Affiliation__c affiliationRec  =  insertAffiliation(loginUser.Contact.AccountId , program, accId, 'Prescriber Affiliation');
            if(PrescriberCertified != true){
                affiliationRec.US_WSREMS__isActive__c = false;
                affiliationRec.US_WSREMS__Start_Date__c = null;
            }
            insert  affiliationRec;
        }
        return 'Success';
              }catch (Exception ex) {
                     Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        } 
    }
    
    public static Boolean getAccountStatusCertified(Id accountId){
        boolean returnValue;
        List<Account>  accList = [SELECT id,US_WSREMS__Status__c  FROM account WHERE Id =: accountId];              
        if(!accList.isEmpty() &&  accList[0].US_WSREMS__Status__c == 'Certified'){
        returnValue =  true;
        }else{returnValue =  false;}
        return  returnValue;
    }
    @AuraEnabled
    public static Void createNewAffiliation(US_WSREMS__Affiliation__c  affiliationRec,Id prescriberID, Id hcsId){
        affiliationRec.US_WSREMS__Prescriber__c = prescriberID;
            affiliationRec.US_WSREMS__Health_Care_Setting__c = hcsId;
            affiliationRec.US_WSREMS__isActive__c = true;
            affiliationRec.US_WSREMS__Start_Date__c = system.today();
            insert affiliationRec;
    }
    @AuraEnabled
    public static String insertHcsEnrollment(Map<String,String> inputRecords, String hcpRecord){
        Savepoint sp = Database.setSavepoint();
        try{
            String arObj = inputRecords.get('arRecord');
            String hcsObj = inputRecords.get('hcsRecord');
            String existingARRecordId = inputRecords.get('existingARRecordId');
            String programType = inputRecords.get('programType');
            String programName = inputRecords.get('programName');
            String base64Content = inputRecords.get('signatureData');
            Id pharmaId;
            Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
            List<US_WSREMS__REMS_Service_Summary__c> serviceToUpdate = new List<US_WSREMS__REMS_Service_Summary__c>();
            List<US_WSREMS__REMS_Service_Summary__c> serviceList = new List<US_WSREMS__REMS_Service_Summary__c>();
            List<Case> caseList = new List<Case>();
            List<US_WSREMS__REMS_Program__c>  program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =:programName];            
            String accountId;  
            Account arAccount;
            RecordDataWrapper arWrapRecord = (RecordDataWrapper)System.JSON.deserialize(arObj, RecordDataWrapper.class);
            if(String.isEmpty(existingARRecordId)) {
                arAccount = insertARonHCSEnrollment(arObj, program, programType, caseRecordTypeMap);
                accountId = arAccount.Id;
            } 
            accountId = String.isNotBlank(existingARRecordId) ? existingARRecordId : accountId;
            Account arAcc = [SELECT Id, PersonEmail,Fax, US_WSREMS__City__c, US_WSREMS__Legal_Guardian_Name__c, MiddleName, US_WSREMS__Other__c, US_WSREMS__Role__c, US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__Email__c, US_WSREMS__Fax_Number__c, Phone, LastName, FirstName FROM Account WHERE Id =: accountId LIMIT 1];
            RecordDataWrapper hcsRecord = (RecordDataWrapper)System.JSON.deserialize(hcsObj, RecordDataWrapper.class);
            Account hcsAccount = new Account();
            if(hcsRecord.Id == null){
                hcsAccount = insertAccount(hcsRecord, program, false, REMSAppLiterals.ACCOUNT_RECORDTYPE_HEALTHCARESETTING);
                hcsAccount.US_WSREMS__Program_Type__c = programType == 'MDP' ? programType : hcsAccount.US_WSREMS__Program_Type__c;
                Boolean dupCheck = checkDuplicate(hcsAccount, programType == 'MDP' ? 'MDP' : 'REMS' );
                if(dupCheck){
                    return 'dupFound';
                }                                    
                insert hcsAccount;
            } else{
                List<Account> hcsAccountList = [ SELECT Id, US_WSREMS__REMS_ID__c, US_WSREMS__Other__c, Name, US_WSREMS__Address_Line_1__c, RecordType.Name, US_WSREMS__DEA__c, Phone, US_WSREMS__Email__c, US_WSREMS__Zip__c, US_WSREMS__State__c, Fax, US_WSREMS__City__c, US_WSREMS__HIN__c, US_WSREMS__NCPDP__c, US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Healthcare_Setting_Type__c,US_WSREMS__Status__c FROM Account WHERE Id =: hcsRecord.Id LIMIT 1];
                hcsAccount = hcsAccountList[0];
            }
            Map<string, Account> hcpAccountMap = insertHCPonHCSENrollment(hcpRecord, hcsAccount, program, programType, caseRecordTypeMap);
            String statusCertified='false';
        if(hcpAccountMap.keySet().iterator().hasnext()){
            statusCertified = hcpAccountMap.keySet().iterator().next();
        }
        
            if(hcsRecord.Id == null) {
                List<Account> hcsAccountList = [SELECT Id, US_WSREMS__REMS_ID__c, US_WSREMS__Other__c, Name, US_WSREMS__Address_Line_1__c, RecordType.Name, US_WSREMS__DEA__c, Phone, US_WSREMS__Email__c, US_WSREMS__Zip__c, US_WSREMS__State__c, Fax, US_WSREMS__City__c, US_WSREMS__HIN__c, US_WSREMS__NCPDP__c, US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Healthcare_Setting_Type__c FROM Account WHERE Id =: hcsAccount.Id LIMIT 1];
                US_WSREMS__REMS_Service_Summary__c serviceEnrollment = insertServiceSummary(hcsAccountList[0],program,'Health Care Setting','Enrollment');
                US_WSREMS__REMS_Service_Summary__c serviceCreation = insertServiceSummary(hcsAccountList[0],program,'Health Care Setting','Participant_Enrollment');
                serviceList.add(serviceEnrollment);
                serviceList.add(serviceCreation);
                insert serviceList;
                serviceList[1].US_WSREMS__Path_Stage_Name__c = REMSAppLiterals.SERVICE_STATUS;
                serviceList[1].US_WSREMS__StageName__c = REMSAppLiterals.SERVICE_STATUS;
                serviceToUpdate.addAll(serviceList);
                Case caseRec = insertCase( hcsRecord, hcsAccountList[0], serviceEnrollment,program,'Health_Care_Setting',REMSAppLiterals.REQUESTORTYPE_HCS, caseRecordTypeMap.get('HCS_Enrollment'), true);
                caseRec = caseRequiredFields(caseRec, hcsAccountList[0], arAcc, 'Pharmacy Enrollment');
                if(String.isNotEmpty(existingARRecordId)) {
                    caseRec = populateNewARFields(caseRec, arWrapRecord);
                }
                Case caseRec2 = insertCase( hcsRecord, hcsAccountList[0], serviceCreation,program,'Health_Care_Setting',REMSAppLiterals.REQUESTORTYPE_HCS, caseRecordTypeMap.get('Health_Care_Setting'), false);
                 caseRec2.Status = 'Complete';
                 caseRec2.US_WSREMS__Outcome__c = 'Complete';
                if(programType == 'MDP'){
                    caseRec.US_WSREMS__Program_Type__c = 'MDP';
                    caseRec2.US_WSREMS__Program_Type__c = 'MDP';
                }
                if(statusCertified != null && hcpAccountMap!=null && hcpAccountMap.get(statusCertified)!=null){
                caseRec.US_WSREMS__Prescriber__c = hcpAccountMap.get(statusCertified).Id;
                caseRec.US_WSREMS__Prescriber_First_Name__c = hcpAccountMap.get(statusCertified).FirstName;
                caseRec.US_WSREMS__Prescriber_Last_Name__c = hcpAccountMap.get(statusCertified).LastName;
                }
                US_WSREMS__Affiliation__c affiliationRec = insertAffiliation(arAcc.Id, program, hcsAccountList[0].Id, 'Authorized Representative Affiliation');
                if(statusCertified == 'true' && (hcsRecord.npi != null || hcsRecord.dea != null || hcsRecord.hin != null || hcsRecord.ncpdp != null)){
                    caseRec.Status = 'Complete';
                    caseRec.US_WSREMS__Outcome__c = 'Complete';
                    hcsAccount.US_WSREMS__Status__c = 'Certified';
                    Update hcsAccount;
                    if(serviceToUpdate!=null && serviceToUpdate.size()>0){
                        serviceToUpdate[0].US_WSREMS__StageName__c = REMSAppLiterals.SERVICE_STATUS;
                        serviceToUpdate[0].US_WSREMS__Path_Stage_Name__c = REMSAppLiterals.SERVICE_STATUS;
                        }
                } else if(statusCertified == 'false'){
                    caseRec.HCPnotCertified__c = true;
                    caseRec.US_WSREMS__Incomplete_Reasons__c = 'HCP not Certified;';
                    caseRec.Status = 'Draft';
                    hcsAccount.US_WSREMS__Status__c = 'Pending';
                    Update hcsAccount;
                    if(serviceToUpdate!=null && serviceToUpdate.size()>0){
                       serviceToUpdate[0].US_WSREMS__Path_Stage_Name__c = 'Intake';
                        serviceToUpdate[0].US_WSREMS__StageName__c = 'Intake';
                        serviceToUpdate[0].US_WSREMS__Status__c = 'Open';
                        serviceToUpdate[0].US_WSREMS__Service_Outcome__c='';
                        }
                    affiliationRec.US_WSREMS__isActive__c=false;
                    affiliationRec.US_WSREMS__Start_Date__c=null;
                }    
                caseList.add(caseRec);
                caseList.add(caseRec2);
                Insert caseList;
                SavePrescriberSignature(caseRec.US_WSREMS__Participant__c,null,base64Content);
                insert affiliationRec;
            } else{
                pharmaId = hcsRecord.Id;
                US_WSREMS__REMS_Service_Summary__c serviceEnrollment;
                Case caseRec;
                if(hcsRecord.hcsstatus == 'Decertified' || hcsRecord.hcsstatus == 'Deactivated') {
                    serviceEnrollment = insertServiceSummary(hcsAccount,program, hcsAccount.RecordType.Name,'Re_enrollment');
                    insert serviceEnrollment;

                    caseRec = insertCase( hcsRecord, hcsAccount, serviceEnrollment,program,'Health_Care_Setting',REMSAppLiterals.REQUESTORTYPE_HCS, caseRecordTypeMap.get('HCS_Reenrollment'), true);
                    caseRec = caseRequiredFields(caseRec, hcsAccount, arAcc, 'Pharmacy Enrollment');
                    if(String.isNotEmpty(existingARRecordId)) {
                        caseRec = populateNewARFields(caseRec, arWrapRecord);
                    }
                } else if(hcsRecord.hcsstatus == 'Certified'){
                    Account existARAcc;
                    serviceEnrollment = insertServiceSummary(hcsAccount,program, hcsAccount.RecordType.Name,'Change_Authorized_Representative');
                    insert serviceEnrollment;
                    serviceToUpdate.add(serviceEnrollment);
                    caseRec = insertCase( hcsRecord, hcsAccount, serviceEnrollment,program,'Health_Care_Setting',REMSAppLiterals.REQUESTORTYPE_HCS, caseRecordTypeMap.get('Change_Authorized_Representative'), true);
                    List<US_WSREMS__Affiliation__c> affList = new List<US_WSREMS__Affiliation__c>();
                    affList = [SELECT Id, US_WSREMS__Authorized_Representative__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Health_Care_Setting__c=:hcsRecord.ID AND US_WSREMS__isActive__c=True AND US_WSREMS__Authorized_Representative__c!=null AND US_WSREMS__REMSProgram__c = :program[0].Id ORDER BY LASTMODIFIEDDATE DESC];
                    if(!affList.isEmpty()){
                        inactivateAffiliations(affList);
                        if(affList[0].US_WSREMS__Authorized_Representative__c != null)
                            existARAcc = [SELECT Id, US_WSREMS__REMS_ID__c, US_WSREMS__Other__c, Name,FirstName,LastName,US_WSREMS__User_Type__c,PersonEmail, US_WSREMS__Address_Line_1__c, RecordType.Name, US_WSREMS__DEA__c, Phone, US_WSREMS__Email__c, US_WSREMS__Zip__c, US_WSREMS__State__c, Fax, US_WSREMS__City__c, US_WSREMS__HIN__c, US_WSREMS__NCPDP__c, US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Healthcare_Setting_Type__c FROM Account WHERE Id =: affList[0].US_WSREMS__Authorized_Representative__c LIMIT 1];
                    }
                    caseRec.Status = 'Complete';
                    caseRec.US_WSREMS__Outcome__c = 'Complete';
                    caseChangeARFields(caseRec, hcsAccount, arAcc, existARAcc);
                }else {
                    serviceEnrollment = insertServiceSummary(hcsAccount,program, hcsAccount.RecordType.Name,'Enrollment');
                    insert serviceEnrollment;
                    serviceToUpdate.add(serviceEnrollment);
                    caseRec = insertCase( hcsRecord, hcsAccount, serviceEnrollment,program,'Health_Care_Setting',REMSAppLiterals.REQUESTORTYPE_HCS, caseRecordTypeMap.get('HCS_Enrollment'), true);
                    caseRec = caseRequiredFields(caseRec, hcsAccount, arAcc, 'Pharmacy Enrollment');
                    if(String.isNotEmpty(existingARRecordId)) {
                        caseRec = populateNewARFields(caseRec, arWrapRecord);
                    }
                }
                    if(programType == 'MDP'){
                        caseRec.US_WSREMS__Program_Type__c = 'MDP';
                    }
                    if(statusCertified != null && hcpAccountMap!=null && hcpAccountMap.get(statusCertified)!=null){
                    caseRec.US_WSREMS__Prescriber__c = hcpAccountMap.get(statusCertified).Id;
                    caseRec.US_WSREMS__Prescriber_First_Name__c = hcpAccountMap.get(statusCertified).FirstName;
                    caseRec.US_WSREMS__Prescriber_Last_Name__c = hcpAccountMap.get(statusCertified).LastName;
                    }
                    US_WSREMS__Affiliation__c affiliationRec = insertAffiliation(arAcc.Id, program, hcsAccount.Id, 'Authorized Representative Affiliation');
                    if(statusCertified == 'true' && (hcsAccount.US_WSREMS__National_Provider_Identifier__c != null || hcsAccount.US_WSREMS__DEA__c != null || hcsAccount.US_WSREMS__HIN__c != null || hcsAccount.US_WSREMS__NCPDP__c != null)){
                        caseRec.Status = 'Complete';
                        caseRec.US_WSREMS__Outcome__c = 'Complete';
                            if(hcsRecord.hcsstatus != 'Certified'){
                                 hcsAccount.US_WSREMS__Status__c = 'Certified';
                   				 Update hcsAccount;
                            }
                            if(serviceToUpdate!=null && serviceToUpdate.size()>0){
                            serviceToUpdate[0].US_WSREMS__Path_Stage_Name__c = REMSAppLiterals.SERVICE_STATUS;
                            serviceToUpdate[0].US_WSREMS__StageName__c = REMSAppLiterals.SERVICE_STATUS;
                           }
                    } else if(statusCertified == 'false' && hcsRecord.hcsstatus != 'Certified'){
                        caseRec.HCPnotCertified__c = true;
                        caseRec.US_WSREMS__Incomplete_Reasons__c = 'HCP not Certified;';
                        caseRec.Status = 'Draft';
                         if(hcsRecord.hcsstatus != 'Pending'){
                                 hcsAccount.US_WSREMS__Status__c = 'Pending';
                   				 Update hcsAccount;
                            }
                            //first record is always service entrollment
                            if(serviceToUpdate!=null && serviceToUpdate.size()>0){
                                serviceToUpdate[0].US_WSREMS__Path_Stage_Name__c = 'Intake';
								serviceToUpdate[0].US_WSREMS__StageName__c='Intake';
                                serviceToUpdate[0].US_WSREMS__Status__c = 'Open';
                                serviceToUpdate[0].US_WSREMS__Service_Outcome__c='';
                                }
                         affiliationRec.US_WSREMS__isActive__c=false;
                         affiliationRec.US_WSREMS__Start_Date__c=null;
                    }
                    insert caseRec;
                    SavePrescriberSignature(caseRec.US_WSREMS__Participant__c,null,base64Content);
                    insert affiliationRec;               
            }     
            if(String.isNotEmpty(existingARRecordId)) {
                Account accRec = new Account(
                    Id = existingARRecordId,
                    Salutation = arWrapRecord.salutation,
                    Phone = arWrapRecord.phone,
                    Fax = arWrapRecord.fax,
                    US_WSREMS__Preferred_Contact_Method__c=arWrapRecord.preferredContactMethod,
                    US_WSREMS__Role__c = arWrapRecord.role
                );
                update accRec;
            }
            update serviceToUpdate;
            if(programType == 'MDP'){
                sendAREmail(arAcc, 'MDP');
            } else{
                sendAREmail(arAcc, 'REMS');
            }
            return 'Success';
        }catch (Exception ex) {
                     Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        } 
    }

    public static Case populateNewARFields(Case caseRec, RecordDataWrapper arRecord) {
        
        caseRec.US_WSREMS__Phone_ar__c = arRecord.Phone;
        caseRec.US_WSREMS__Participant_Fax__c = arRecord.fax;
        caseRec.US_WSREMS__Email__c = arRecord.email;
        caseRec.US_WSREMS__Email_ar__c = arRecord.email;
        caseRec.US_WSREMS__Preferred_Contact_Method__c = arRecord.preferredContactMethod;
        caseRec.US_WSREMS__Role__c = arRecord.role;
        caseRec.Other__c = arRecord.other;
        caseRec.US_WSREMS__Legal_Guardian_Name__c = arRecord.suffix;
        return caseRec;
    }
    
    public static Account insertARonHCSEnrollment(String arObj, List<US_WSREMS__REMS_Program__c> program, String programType, Map<String,Id> caseRecordTypeMap){
        List<US_WSREMS__REMS_Service_Summary__c> serviceToUpdate = new List<US_WSREMS__REMS_Service_Summary__c>();
        RecordDataWrapper arRecord = (RecordDataWrapper)System.JSON.deserialize(arObj,RecordDataWrapper.class);
        Account arAccount = new Account();
        if(arRecord.Id == null ){
                arAccount = insertAccount(arRecord, program, true, 'Pharmacy_Participant');
                if(programType == 'MDP')
                    arAccount.US_WSREMS__Program_Type__c = programType;
                
                insert arAccount;
                US_WSREMS__REMS_Service_Summary__c serviceCreation = insertServiceSummary(arAccount,program,'Pharmacy/HCS Participant','Participant_Enrollment');
                insert serviceCreation;
                serviceToUpdate.add(serviceCreation);
                Case caseRec = insertCase( arRecord, arAccount, serviceCreation,program,'Pharmacy_Participant','Pharmacy/HCS Participant', caseRecordTypeMap.get('Pharmacy_Participant'), false);
                caseRec.Status = 'Complete';
                caseRec.US_WSREMS__Outcome__c = 'Complete';
                    if(programType == 'MDP'){
                    caseRec.US_WSREMS__Program_Type__c = 'MDP';
               }
                Insert caseRec;
            } else {
                arAccount = updateAccount(arRecord, program, true, 'Pharmacy_Participant');
                arAccount.Id = arRecord.Id;
                update arAccount;
            }
        if(!serviceToUpdate.isEmpty()){
            updateService(serviceToUpdate);
        }
        return arAccount;
    }
    
    public static Map<String,Account> insertHCPonHCSENrollment(String hcpRecord, Account hcsAccount, List<US_WSREMS__REMS_Program__c> program, String programType, Map<String,Id> caseRecordTypeMap){
       List<US_WSREMS__Affiliation__c> affToInsert = new List<US_WSREMS__Affiliation__c>();
        Map<String,Account> hcpToPopulateMap = new Map<String,Account>();
        Map<Id, US_WSREMS__REMS_Service_Summary__c> serviceAccountMap = new Map<Id, US_WSREMS__REMS_Service_Summary__c>();
        List<RecordDataWrapper> hcpAccList = new List<RecordDataWrapper>();
        List<US_WSREMS__REMS_Service_Summary__c> serviceToUpdate = new List<US_WSREMS__REMS_Service_Summary__c>();
        String statusCertified = 'false';
        Id hcpId ;
        if(hcpRecord != null){
            List<Object> hcpObjList = (List<Object>)JSON.deserializeUntyped(hcpRecord);
            for(Object hcp: hcpObjList){
                RecordDataWrapper hcpMap = (RecordDataWrapper) JSON.deserialize((hcp.toString()), RecordDataWrapper.class);
                hcpAccList.add(hcpMap);
            }
        }
        if(hcpAccList != null){
            List<account> hcpAccToInsert = new List<Account>();            
            Integer i = 0;
            for(RecordDataWrapper hcprec: hcpAccList){
                if(hcprec.Id != null){
                    if(i == 0){
                        hcpId = hcprec.Id;
                    }
                    US_WSREMS__Affiliation__c affiliationRec = insertAffiliation(hcprec.Id, program, hcsAccount.Id, 'Prescriber Affiliation');
                    affToInsert.add(affiliationRec);
                } else{
                    Account hcpAccount = insertAccount(hcprec, program, true, REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER);
                    if(programType == 'MDP')
                        hcpAccount.US_WSREMS__Program_Type__c = programType;
                    hcpAccToInsert.add(hcpAccount);
                }
                i++;
            }
            if(!hcpAccToInsert.isEmpty()){
                insert hcpAccToInsert; 
                i=0 ;
                for(Account hcpAcc: hcpAccToInsert){
                    if(i == 0){
                        hcpToPopulateMap.put(statusCertified, hcpAcc);
                    }
                    US_WSREMS__REMS_Service_Summary__c serviceCreation = insertServiceSummary(hcpAcc,program,'Prescriber','Participant_Enrollment');
                    serviceAccountMap.put(hcpAcc.Id, serviceCreation);
                    i++;
                }
            if(serviceAccountMap != null){
                insert serviceAccountMap.values();
                List<Case> caseList = new List<Case>();
                List<US_WSREMS__Affiliation__c> affiliationInsert = new List<US_WSREMS__Affiliation__c> ();
                for(Account hcpAcc: hcpAccToInsert){
                    serviceToUpdate.add(serviceAccountMap.get(hcpAcc.Id));
                    RecordDataWrapper hcprec = new RecordDataWrapper();
                    hcprec.firstName = hcpAcc.FirstName;
                    hcprec.lastName = hcpAcc.LastName;
                    Case caseRec = insertCase( hcprec, hcpAcc, serviceAccountMap.get(hcpAcc.Id),program,'Prescriber','Prescriber', SYN_CommonUtility.getPPARecordType('Prescriber Person Account'), false);
                    caseRec.Status = 'Complete';
                 	caseRec.US_WSREMS__Outcome__c = 'Complete';
                    if(programType == 'MDP'){
                        caseRec.US_WSREMS__Program_Type__c = 'MDP';
                    }
                    caseList.add(caseRec);
                    US_WSREMS__Affiliation__c affiliationRec = insertAffiliation(hcpAcc.Id, program, hcsAccount.Id, 'Prescriber Affiliation');
                    affToInsert.add(affiliationRec);
                }
                if(!caseList.isEmpty())
                    insert caseList;
           }
        }
    }
        if(hcpId != null){
            List<Account> hcpAcc = [SELECT Id, FirstName, LastName, US_WSREMS__Status__c from Account WHERE Id =: hcpId LIMIT 1];
            if(hcpAcc[0].US_WSREMS__Status__c == 'Certified'){
                statusCertified = 'true';
            }
            hcpToPopulateMap = new Map<String,Account>();
            hcpToPopulateMap.put(statusCertified, hcpAcc[0]);
        }
     		if(affToInsert.size()> 0 ){
                if(statusCertified != 'true'){
                    for(US_WSREMS__Affiliation__c  affiliation:affToInsert){
                        affiliation.US_WSREMS__isActive__c=false;
                        affiliation.US_WSREMS__Start_Date__c=null;
                        }
                    }
                    insert affToInsert; 
            }
        if(!serviceToUpdate.isEmpty() && serviceToUpdate != null && serviceToUpdate.size() > 0){
            updateService(serviceToUpdate);
        }
        return hcpToPopulateMap;
    }
    
    @AuraEnabled
    public static string insertArEditEnroll(Map<String,String> inputRecords){
         Savepoint sp = Database.setSavepoint();
        try{
            String arRecord = inputRecords.get('arRecord');
            String hcsRecord = inputRecords.get('hcsRecord');
            String reenroll = inputRecords.get('reenroll');
            String programName = inputRecords.get('programName');
            String programType = inputRecords.get('programType');
            List<US_WSREMS__REMS_Program__c>  program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =:programName];
            if(reenroll == 'false'){
                if(programType != 'MDP'){
                    RecordDataWrapper arObj = (RecordDataWrapper)System.JSON.deserialize(arRecord,RecordDataWrapper.class);
                    if(arObj != null && arObj.Id != null){
                        Account arAccount = updateAccount(arObj, program, true, 'Pharmacy_Participant');
                        arAccount.Id = arObj.Id;
                        update arAccount;
                        String result = xiaflex_Application_Enrollment_Class.createChangeOfInfoCaseAndService(arObj, arAccount, program, 'Pharmacy_Participant', 'Pharmacy/HCS Participant', programType == 'MDP' ? 'MDP' : 'REMS');
                    }
                }
                RecordDataWrapper hcsObj = (RecordDataWrapper)System.JSON.deserialize(hcsRecord,RecordDataWrapper.class);
                if(hcsObj != null && hcsObj.Id != null){
                    Account hcsAccount = updateAccount(hcsObj, program, false, 'Health_Care_Setting');
                    hcsAccount.Id = hcsObj.Id;
                    update hcsAccount;
                    String result = xiaflex_Application_Enrollment_Class.createChangeOfInfoCaseAndService(hcsObj, hcsAccount, program, 'Health_Care_Setting', 'Health Care Setting', programType == 'MDP' ? 'MDP' : 'REMS');
                }
            } else{
                String base64Content = inputRecords.get('signatureData');
                Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
                RecordDataWrapper arObj;
                if(arRecord!=null){
                    arObj = (RecordDataWrapper)System.JSON.deserialize(arRecord,RecordDataWrapper.class);
                }
                RecordDataWrapper hcsObj;
                if(hcsRecord!=null){
                    hcsObj = (RecordDataWrapper)System.JSON.deserialize(hcsRecord,RecordDataWrapper.class);
                }
                Account arAccount = new Account();
                List<Account> accUpdateList = new List<Account>();
                if(arObj != null && arObj.Id != null){
                    arAccount = updateAccount(arObj, program, true, 'Pharmacy_Participant');
                    arAccount.Id = arObj.Id;
                    accUpdateList.add(arAccount);
                    Account hcsAccRec = new Account();
                    hcsAccRec.Id = hcsObj.Id;
                    hcsAccRec.US_WSREMS__Recertification_Due_Date__c = Date.today().addyears(2);
                    accUpdateList.add(hcsAccRec);
                    update accUpdateList;
                }
                List <Account> hcsAccountList = [SELECT Id, Name, US_WSREMS__Address_Line_1__c, US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Zip__c, US_WSREMS__Healthcare_Setting_Type__c, US_WSREMS__REMS_ID__c from Account WHERE Id =: hcsObj.Id LIMIT 1];
                List<US_WSREMS__REMS_Service_Summary__c> serviceInsertList = new List<US_WSREMS__REMS_Service_Summary__c>();
                US_WSREMS__REMS_Service_Summary__c serviceCreation = xiaflex_ManagePharmacies.insertServiceSummary(hcsAccountList[0],program,'Health Care Setting','Re_enrollment');
                US_WSREMS__REMS_Service_Summary__c reCertserviceCreation = xiaflex_ManagePharmacies.insertServiceSummary(hcsAccountList[0],program,'Health Care Setting','ReCertification');
                serviceInsertList.add(serviceCreation);
                serviceInsertList.add(reCertserviceCreation);
                insert serviceInsertList;
                List<Case> insertCaseList = new List<Case>();
                Case caseRec = xiaflex_ManagePharmacies.insertCase( hcsObj, hcsAccountList[0], serviceCreation,program,'Health_Care_Setting',REMSAppLiterals.REQUESTORTYPE_HCS, caseRecordTypeMap.get('HCS_Reenrollment'), true);
                caseRec.US_WSREMS__Phone__c = hcsObj.phone;
                caseRec.US_WSREMS__Fax__c = hcsObj.fax;
                caseRec.US_WSREMS__Healthcare_Setting__c = hcsAccountList[0].Id;
                caseRec.US_WSREMS__REMS_Authorized_Rep__c = arAccount.Id;
                caseRec.US_WSREMS__First_Name_ar__c = arObj.firstName;
                caseRec.US_WSREMS__Last_Name_ar__c = arObj.lastName;
                caseRec.US_WSREMS__Legal_Guardian_Name__c = arObj.suffix;
                caseRec.US_WSREMS__Middle_Name__c = arObj.middleName;
                caseRec.US_WSREMS__Phone_ar__c = arObj.phone;
                caseRec.US_WSREMS__Participant_Fax__c = arObj.fax;
                caseRec.US_WSREMS__Phone_Type__c = 'Main';
                caseRec.US_WSREMS__Email__c = arObj.email;
                caseRec.US_WSREMS__Preferred_Contact_Method__c = arObj.preferredContactMethod;
                caseRec.US_WSREMS__Role__c = arObj.role;
                caseRec.Other__c = arObj.other;
                insertCaseList.add(caseRec);
               Case recertCaseRec = xiaflex_ManagePharmacies.insertCase( hcsObj, hcsAccountList[0], reCertserviceCreation,program,'Health_Care_Setting',REMSAppLiterals.REQUESTORTYPE_HCS, caseRecordTypeMap.get('ReCertification'), true);
               recertCaseRec.US_WSREMS__Phone__c = hcsObj.phone;
               recertCaseRec.US_WSREMS__Fax__c = hcsObj.fax;
               recertCaseRec.Status = 'Complete';
               recertCaseRec.US_WSREMS__Outcome__c = 'Complete';
               recertCaseRec = caseRecertFields(recertCaseRec, hcsAccountList[0], arAccount,arObj);
               insertCaseList.add(recertCaseRec);
               Insert insertCaseList;
               SavePrescriberSignature(caseRec.US_WSREMS__Participant__c,null,base64Content);                
            }
            return 'Success';
        }catch (Exception ex) {
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void removeArAffiliation(Map<String,String> inputRecords){
         Savepoint sp = Database.setSavepoint();
        try{
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        List<US_WSREMS__REMS_Service_Summary__c> serviceToUpdate = new list<US_WSREMS__REMS_Service_Summary__c>();
        String userId = inputRecords.get('userId');
        String pharmaId = inputRecords.get('pharmaId');
        String prescriberId = inputRecords.get('prescriberId');
        String recordType = inputRecords.get('recordType');
        List<US_WSREMS__REMS_Program__c>  program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Xiaflex'];
        String query = 'SELECT Id ,US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c ,US_WSREMS__isActive__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__isActive__c = true AND US_WSREMS__Health_Care_Setting__c = \''+ pharmaId +'\' AND ';
        if(recordType == 'Authorized Representative Affiliation'){
            User loginUser = SYN_CommonUtility.getCurrentUserContactDetails(userId);
            query = query + 'RecordType.Name = \'Authorized Representative Affiliation\' AND US_WSREMS__Authorized_Representative__c = \''+ loginUser.Contact.AccountId +'\' Limit 1 ';
        } else{
            query = query + 'RecordType.Name = \'Prescriber Affiliation\' AND US_WSREMS__Prescriber__c = \'' + prescriberId + '\' Limit 1 ';
        }
        if(recordType != null){
             US_WSREMS__Affiliation__c aff = Database.query(query);
            aff.US_WSREMS__isActive__c = false;
            Update aff;
            if(recordType == 'Authorized Representative Affiliation' && aff.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c == 'Certified'){
                account accDeactivated =  updateAccount(aff.US_WSREMS__Health_Care_Setting__c);
                US_WSREMS__REMS_Service_Summary__c serviceEnrollmentpolo = insertServiceSummary(accDeactivated,program,'Health Care Setting','Deactivation');
                insert serviceEnrollmentpolo;
                Case caseRec = insertCase(null, accDeactivated, serviceEnrollmentpolo, program, 'Deactivation', 'Health Care Setting', caseRecordTypeMap.get('Deactivation'), false);
                insert caseRec;
                serviceToUpdate.add(serviceEnrollmentpolo);
                updateService(serviceToUpdate);
                update serviceToUpdate;
            }
        }
        
        }catch (Exception ex) {
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        } 
    }
    
    public static void sendAREmail(Account accountDetail, string programType){
        try {
            List<user> countExistingAR = new List<user>();
            OrgWideEmailAddress[] owea;
            OrgWideEmailAddress[] bccowea;

            //Org-wide Email...
            if(programType == 'REMS'){
                string Addresslabel = System.Label.XIAFLEXRemsSupportEmail;
                owea =SYN_CommonUtility.getOrgWideEmailAddress(Addresslabel);
            }
             else if(programType == 'MDP'){
                string Addresslabel = System.Label.XIAFLEXMDPSupportEmail;
                owea = SYN_CommonUtility.getOrgWideEmailAddress(Addresslabel);

            }
            string bccAddresslabel = System.Label.XIAFLEXMDPSupportEmail;            
            List<user> arUser = SYN_CommonUtility.getUserByEmail(accountDetail.PersonEmail);
            if(arUser.size() > 0){
                for(user auser: arUser){
                    if(programType == 'REMS'){
                        if(auser.username.endsWithIgnoreCase('AR')){
                            countExistingAR.add(auser);
                        }else if(programType == 'MDP'){
                            if(auser.username.endsWithIgnoreCase('ARMDP')){
                                countExistingAR.add(auser);
                            }
                        }                        
                    }
                }
            }
           
            if(arUser.isEmpty() || countExistingAR.size() == 0 || arUser == null){
                Map<String, Object> Params = new Map<String, Object>();
                MACIAutomationCommunicationUtility.Requests  rst = new MACIAutomationCommunicationUtility.Requests();
                rst.accountId = accountDetail.id;
                rst.BccAddress = owea[0].address;
                rst.toAddress = accountDetail.PersonEmail;
                rst.fromAddress = owea[0].address;
                if(programType == 'MDP'){
                    rst.templateName = System.Label.XiaflexARMDPinvitationTemplate;
                }
                else{
                    rst.templateName =  System.Label.Xiaflex_AR_invitationTemplate;      
                }
                List<MACIAutomationCommunicationUtility.Requests> sendmaillist = new List<MACIAutomationCommunicationUtility.Requests>();
                sendmaillist.add(rst);
                MACIAutomationCommunicationUtility.sendNotificationFromFlow(sendmaillist);
            }
            
        }
        catch (Exception e)
        {
            String errorMessage = e.getMessage();          
        }
    } 
    public static String SavePrescriberSignature(String accountId, String agreementStatus, String b64SignData){
        try {
            //Create Attachment
            Attachment n = new Attachment(ParentId = accountId,Name = 'Signature_'+String.valueOf(Date.today()).substring(0,10),
                                          Body =  EncodingUtil.base64Decode(b64SignData),contentType = 'image/jpeg');
            insert n;
            return '';
        }
        catch (Exception e)
        {
            String errorMessage = e.getMessage();          
            return errorMessage;
        }
    } 
    
    public static Account insertAccount(RecordDataWrapper recordData,List<US_WSREMS__REMS_Program__c>  program,Boolean isPersonAccount, String recordType) {
        
        try {
            String defaultUser = System.Label.xiaflex_default_Portal_User;
            User accountOwner = SYN_CommonUtility.getDefaultportalUser(defaultUser);
            Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_product(REMSAppLiterals.ACCOUNT_OBJECT).get(recordType);
            Account newAccount = new Account();
            if (isPersonAccount) {
                newAccount.FirstName = recordData.firstName;
                if(recordType != 'Prescriber'){
                    newAccount.MiddleName = recordData.middleName;
                    newAccount.Salutation = recordData.salutation;
                }if(recordData.onhold != null){
                    newAccount.US_WSREMS__Hold_Account__c = recordData.onhold;   
                }
                
                newAccount.MiddleName = recordData.middleName;
                newAccount.US_WSREMS__Legal_Guardian_Name__c = recordData.suffix;
                newAccount.LastName = recordData.lastName;
                newAccount.PersonEmail = recordData.email;
                newAccount.Fax = recordData.fax;
                if(recordType == 'Prescriber'){
                    newAccount.US_WSREMS__Professional_Designation__c = recordData.degree;
                    newAccount.Medical_Specialty__c = recordData.speciality;
                    newAccount.ShippingCity = recordData.city;
                    newAccount.US_WSREMS__User_Type__c = 'Prescriber';
                    newAccount.US_WSREMS__SLN__c = recordData.license;
                    newAccount.US_WSREMS__SLN_State__c = recordData.licenseState;
                    newAccount.US_WSREMS__Phone_Type__c = recordData.phoneType;
                    newAccount.US_WSREMS__Status__c = 'Initiated';
                    if(recordData.speciality == 'other'){
                        newAccount.US_WSREMS__Other_Credentials__c = recordData.other;
                    }
                }
                else{
                    newAccount.US_WSREMS__City__c = recordData.city;
                    newAccount.US_WSREMS__Address_Line_1__c = recordData.address1;
                    newAccount.US_WSREMS__Address_Line_2__c = recordData.address2;
                    newAccount.US_WSREMS__Fax_Number__c = recordData.fax;
                    newAccount.US_WSREMS__User_Type__c = 'Authorized Representative';
                    newAccount.US_WSREMS__Phone_Type__c = recordData.phoneType;
                }
                newAccount.US_WSREMS__State__c = recordData.state;
                newAccount.US_WSREMS__Zip__c = recordData.zipCode;
                newAccount.US_WSREMS__Email__c = recordData.email;
                newAccount.Phone = recordData.phone;
                newAccount.US_WSREMS__DEA__c=recordData.DEA;
                newAccount.US_WSREMS__Preferred_Contact_Method__c=recordData.preferredContactMethod;
                newAccount.US_WSREMS__Role__c = recordData.role;
                if(recordData.role == 'Other'){
                    newAccount.US_WSREMS__Other__c = recordData.other;
                }
            } else {
                newAccount.Name = recordData.name;
                newAccount.US_WSREMS__Status__c = 'Initiated';
                newAccount.US_WSREMS__City__c = recordData.city;
                newAccount.US_WSREMS__Address_Line_1__c = recordData.address1;
                newAccount.US_WSREMS__Address_Line_2__c = recordData.address2;
                newAccount.US_WSREMS__State__c = recordData.state;
                newAccount.US_WSREMS__Zip__c = recordData.zipCode;
                newAccount.US_WSREMS__Healthcare_Setting_Type__c = recordData.hcsType;
                newAccount.Phone  = recordData.phone;
                newACcount.Fax = recordData.fax;
                if (recordType != REMSAppLiterals.ACCOUNT_RECORDTYPE_PHARMACYPARTICIPANT) {
                    newAccount.US_WSREMS__National_Provider_Identifier__c = recordData.npi;
                    newAccount.US_WSREMS__NCPDP__c = recordData.NCPDP;
                    newAccount.US_WSREMS__HIN__c = recordData.HIN;
                    newAccount.US_WSREMS__DEA__c=recordData.DEA;
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
            newAccount.US_WSREMS__Program_Type__c = 'REMS';
            newAccount.US_WSREMS__Is_Portal__c = true;
            newAccount.US_WSREMS__Channel__c = recordData.Channel != null ? recordData.Channel : REMSAppLiterals.CASE_CHANNEL_PORTAL;
            newAccount.US_WSREMS__REMS_Program__c = program.size() > 0 ? program[0].Id : null;
            newAccount.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            newAccount.OwnerId = accountOwner.Id;
            return  newAccount;
        }catch (Exception ex) {
           System.debug('Exception'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
       }  
    }
    
    public static Account updateAccount(RecordDataWrapper recordData,List<US_WSREMS__REMS_Program__c>  program,Boolean isPersonAccount, String recordType) {
        
        try {
            Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_product(REMSAppLiterals.ACCOUNT_OBJECT).get(recordType);
            Account newAccount = new Account();
            if (isPersonAccount) {
                if(recordType == 'Prescriber'){
                    newAccount.FirstName = recordData.firstName;
                    newAccount.MiddleName = recordData.middleName;
                    newAccount.US_WSREMS__Legal_Guardian_Name__c = recordData.suffix;
                    newAccount.LastName = recordData.lastName;
                    newAccount.PersonEmail = recordData.email;
                    newAccount.Phone = recordData.phone;
                    newAccount.Fax = recordData.fax;
                    newAccount.US_WSREMS__Preferred_Contact_Method__c = recordData.preferredContactMethod;
                    newAccount.US_WSREMS__Professional_Designation__c = recordData.degree;
                    newAccount.Medical_Specialty__c = recordData.speciality;
                    newAccount.US_WSREMS__Legal_Guardian_Relationship__c = recordData.me;
                    newAccount.US_WSREMS__Healthcare_Setting_Type__c = recordData.hcsOption;
                    newAccount.US_WSREMS__Other_Credentials__c = recordData.other;
                    newAccount.US_WSREMS__SLN__c = recordData.license;
                    newAccount.US_WSREMS__SLN_State__c = recordData.licenseState;
                    newAccount.US_WSREMS__Phone_Type__c = recordData.phoneType;
                }  if(recordType == 'Pharmacy_Participant'){
                    newAccount.Salutation = recordData.salutation;
                    newAccount.FirstName = recordData.firstName;
                    newAccount.MiddleName = recordData.middleName;
                    newAccount.US_WSREMS__Legal_Guardian_Name__c = recordData.suffix;
                    newAccount.LastName = recordData.lastName;
                    newAccount.US_WSREMS__Phone_Type__c = recordData.phoneType;
                    if(recordData.email != null){
                        newAccount.PersonEmail = recordData.email;
                    }
                    newAccount.Phone = recordData.phone;
                    if(recordData.fax != null){
                        newAccount.Fax = recordData.fax;
                    }
                    newAccount.US_WSREMS__Preferred_Contact_Method__c = recordData.preferredContactMethod;
                    newAccount.US_WSREMS__Role__c = recordData.role;
                    newAccount.US_WSREMS__Other__c = recordData.other;
                } 
            }else {
                if(recordType == 'Health_Care_Setting'){
                    newAccount.name = recordData.name;
                    newAccount.US_WSREMS__City__c = recordData.city;
                    if(recordData.phone != null)
                        newAccount.Phone = recordData.phone;
                    if(recordData.fax != null)
                        newAccount.Fax = recordData.fax;
                    newAccount.US_WSREMS__Address_Line_1__c = recordData.address1;
                    if(recordData.address2 != null)
                        newAccount.US_WSREMS__Address_Line_2__c = recordData.address2;
                    newAccount.US_WSREMS__State__c = recordData.state;
                    newAccount.US_WSREMS__Zip__c = recordData.zipCode;
                    newAccount.US_WSREMS__Healthcare_Setting_Type__c = recordData.hcsType;
                    if(recordData.npi != null)
                        newAccount.US_WSREMS__National_Provider_Identifier__c = recordData.npi;
                    if(recordData.NCPDP != null)
                        newAccount.US_WSREMS__NCPDP__c = recordData.NCPDP;
                    if(recordData.HIN != null)
                        newAccount.US_WSREMS__HIN__c = recordData.HIN;
                    if(recordData.DEA != null)
                        newAccount.US_WSREMS__DEA__c=recordData.DEA;
                }
            }
            return  newAccount;
        }catch (Exception ex) {
            System.debug('Exception'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }  
    }
    
    public static US_WSREMS__REMS_Service_Summary__c insertServiceSummary(Account personAccount,List<US_WSREMS__REMS_Program__c>  program,String participantType,String recordType) {
        
        try { 
            User serviceUser = SYN_CommonUtility.getDefaultportalUser(System.Label.xiaflex_default_Portal_User);
            Id idRTforREMSService;
            if(recordType == 'Enrollment' || recordType == 'Participant_Enrollment' || recordType == 'Re_enrollment' || recordType == 'Deactivation'){
            idRTforREMSService = [SELECT Id, name, DeveloperName, NamespacePrefix FROM recordtype WHERE  SobjectType = 'US_WSREMS__REMS_Service_Summary__c'  AND NamespacePrefix = 'US_WSREMS' AND DeveloperName = :recordType LIMIT 1].Id;
            }
            else{
            idRTforREMSService = Schema.sObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
    
            }
            US_WSREMS__REMS_Service_Summary__c service = new US_WSREMS__REMS_Service_Summary__c();
            service.recordTypeId = idRTforREMSService;
            service.US_WSREMS__REMSProgram__c = program.size() > 0 ? program[0].Id : null;
            service.RecordTypeId = idRTforREMSService;
            service.US_WSREMS__Status__c = REMSAppLiterals.SERVICE_STATUS;
            service.US_WSREMS__Service_Outcome__c = REMSAppLiterals.SERVICE_OUTCOME;

            service.US_WSREMS__Participant__c = personAccount.Id;
            service.US_WSREMS__Requestor_Type__c = participantType;
            service.OwnerId = serviceUser.Id;
            return service;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public static void updateService(List<US_WSREMS__REMS_Service_Summary__c> serviceList){
        List<US_WSREMS__REMS_Service_Summary__c> serviceToUpdate = new List<US_WSREMS__REMS_Service_Summary__c>();
        for(US_WSREMS__REMS_Service_Summary__c service: serviceList){
            service.US_WSREMS__Path_Stage_Name__c = REMSAppLiterals.SERVICE_STATUS;
            service.US_WSREMS__StageName__c = REMSAppLiterals.SERVICE_STATUS;
            serviceToUpdate.add(service);
        }
        
        Update serviceToUpdate;
    }
    
    public static Case insertCase(RecordDataWrapper recordData,Account accountRec,US_WSREMS__REMS_Service_Summary__c service,List<US_WSREMS__REMS_Program__c>  program,String recordType, String participantType, Id recordTypeId, Boolean isEnrollment) {
        
        try {
            User caseOwner = SYN_CommonUtility.getDefaultportalUser(System.Label.xiaflex_default_Portal_User);
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_product(REMSAppLiterals.CASE_OBJECT).get(recordType);
            Case caseRec = new Case();
            caseRec.recordTypeId = recordTypeId;  
            caseRec.US_WSREMS__Is_Portal__c = true;
            if(recordData != null){
                if (recordType != REMSAppLiterals.CASE_RECORDTYPE_HEALTHCARESETTING && recordType != REMSAppLiterals.CASE_RECORDTYPE_OUTPATIENTPHARMACY) {
                    caseRec.US_WSREMS__First_Name__c = recordData.firstName;
                    caseRec.US_WSREMS__Middle_Name__c = recordData.middleName;
                    caseRec.US_WSREMS__Legal_Guardian_Name__c = recordData.suffix;
                    caseRec.US_WSREMS__Last_Name__c = recordData.LastName;
                    caseRec.US_WSREMS__Fax__c = recordData.fax;
                    caseRec.US_WSREMS__Zip__c = recordData.zipCode;
                    caseRec.US_WSREMS__Participant_Fax__c = recordData.fax;
                    caseRec.US_WSREMS__REMS_Alternate_Phone__c = recordData.phone;
                    caseRec.US_WSREMS__Email__c = recordData.email;
                    caseRec.US_WSREMS__Email_ar__c = recordData.email;
                    caseRec.US_WSREMS__Phone__c = recordData.phone;
                    caseRec.US_WSREMS__Phone_Type__c = recordData.phoneType;
                    caseRec.US_WSREMS__Preferred_Contact_Method__c = recordData.preferredContactMethod;
                    caseRec.US_WSREMS__Role__c = recordData.role;
                    if(recordData.role == 'Other'){
                        caseRec.US_WSREMS__Other__c = recordData.other;
                    }
                    caseRec.US_WSREMS__NPI__c = (recordType == REMSAppLiterals.CASE_RECTYPE_PRESCRIBER_PERSON_ACCOUNT || recordType == 'Prescriber')? recordData.npi : null;
                    caseRec.SYN_Medical_specialty__c = recordData.speciality;
                    if(recordData.speciality == 'other'){
                        caseRec.US_WSREMS__Other_Speciality__c = recordData.other;
                    }
                } else if(recordType == REMSAppLiterals.CASE_RECORDTYPE_HEALTHCARESETTING) {
                    caseRec.US_WSREMS__Name__c = recordData.name;
                    caseRec.US_WSREMS__NPI__c = recordData.npi;
                    caseRec.US_WSREMS__DEA__c = recordData.DEA;
                    caseRec.US_WSREMS__HIN__c = recordData.HIN;
                    caseRec.US_WSREMS__NCPDP__c = recordData.NCPDP;
                    caseRec.US_WSREMS__Zip__c = recordData.zipCode;
                    caseRec.US_WSREMS__Address_Line_1__c = recordData.address1;
                    caseRec.US_WSREMS__Address_Line_2__c = recordData.address2;
                    caseRec.US_WSREMS__State__c = recordData.state;
                    caseRec.US_WSREMS__City__c = recordData.city;
                    caseRec.US_WSREMS__Healthcare_Setting_Type__c = recordData.hcsType;
                    caseRec.US_WSREMS__Phone__c  = recordData.phone;
                    caseRec.US_WSREMS__Fax__c = recordData.fax;
                } else{
                    caseRec.US_WSREMS__Name__c = recordData.name;
                    caseRec.US_WSREMS__NPI__c = recordData.npi;
                }
                if(isEnrollment){
                    if(recordType == 'Health_Care_Setting'){
                        caseRec.US_WSREMS__Prescriber_Signature__c = 'Yes';
                        caseRec.US_WSREMS__Signature_Date_Pharmacist__c = System.Today();
                        caseRec.US_WSREMS__Signature_Date__c = System.Today();
                    } else{
                        caseRec.NPI_Status__c = 'Valid';
                        caseRec.US_WSREMS__Signature_Date_Pharmacist__c = System.Today();
                        caseRec.US_WSREMS__Signature__c = 'Yes';
                        caseRec.US_WSREMS__Prescriber_Signature__c = 'Yes';
                        caseRec.US_WSREMS__Signature_Date__c = System.Today();
                    }
                    
                }
            }
            if(recordType == 'Deactivation'){
                caseRec.US_WSREMS__First_Name__c = accountRec.FirstName;
                caseRec.US_WSREMS__Last_Name__c = accountRec.LastName;
                caseRec.US_WSREMS__Deactivation_Reason__c = 'Enrollment Expired';
                caseRec.US_WSREMS__Deactivation_Date__c = System.Today();
                caseRec.Status = 'Complete';
                caseRec.US_WSREMS__Outcome__c = 'Complete';
            }
            if(recordType == 'Prescriber'){
                caseRec.US_WSREMS__Prescriber__c = accountRec.Id;
                caseRec.US_WSREMS__Professional_Designation__c = recordData.degree;
                caseRec.US_WSREMS__Preferred_Contact_Method__c = recordData.preferredContactMethod;
                caseRec.US_WSREMS__SLN__c = recordData.license;
                caseRec.US_WSREMS__SLN_Issued_State__c = recordData.licenseState;
                caseRec.US_WSREMS__Legal_Guardian_Relationship__c = recordData.me;
                caseRec.US_WSREMS__User_Type__c = 'Prescriber';
            } else if(recordType ==  'Pharmacy_Participant'){
                caseRec.US_WSREMS__User_Type__c = 'Authorized Representative';
            }
            caseRec.US_WSREMS__REMS_ID__c = accountRec.US_WSREMS__REMS_ID__c;
            caseRec.US_WSREMS__Requestor_Type__c = participantType;
            caseRec.US_WSREMS__Program_Type__c = 'REMS';
            caseRec.US_WSREMS__Participant__c = accountRec.Id;
            if(service != null)
                caseRec.US_WSREMS__REMS_Service_Summary__c = service.Id;
            caseRec.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL; 
            caseRec.OwnerId = caseOwner.Id;
            return  caseRec;
            
        }  catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
        
    }
    
    public static Case caseRequiredFields(Case caseRec, Account hcsAccountList, Account arAccount, String recordType){
        if(recordType == 'Pharmacy Enrollment'){
            caseRec.US_WSREMS__Healthcare_Setting__c = hcsAccountList.Id;
            caseRec.US_WSREMS__Name__c = hcsAccountList.Name;
            caseRec.US_WSREMS__City__c = hcsAccountList.US_WSREMS__City__c;
            caseRec.US_WSREMS__Address_Line_1__c = hcsAccountList.US_WSREMS__Address_Line_1__c;
            caseRec.US_WSREMS__State__c = hcsAccountList.US_WSREMS__State__c;
            caseRec.US_WSREMS__Fax__c = hcsAccountList.Fax;
            caseRec.US_WSREMS__Phone__c = hcsAccountList.Phone;
            caseRec.US_WSREMS__Zip__c = hcsAccountList.US_WSREMS__Zip__c;
            caseRec.US_WSREMS__NPI__c = hcsAccountList.US_WSREMS__National_Provider_Identifier__c;
            caseRec.US_WSREMS__NCPDP__c = hcsAccountList.US_WSREMS__NCPDP__c;
            caseRec.US_WSREMS__DEA__c = hcsAccountList.US_WSREMS__DEA__c;
            caseRec.US_WSREMS__Healthcare_Setting_Type__c = hcsAccountList.US_WSREMS__Healthcare_Setting_Type__c;
            caseRec.US_WSREMS__HIN__c = hcsAccountList.US_WSREMS__HIN__c;
            caseRec.US_WSREMS__Other__c = hcsAccountList.US_WSREMS__Other__c;
            caseRec.US_WSREMS__REMS_Authorized_Rep__c = arAccount.Id;
            caseRec.US_WSREMS__First_Name_ar__c = arAccount.FirstName;
            caseRec.US_WSREMS__Last_Name_ar__c = arAccount.LastName;
            caseRec.US_WSREMS__Phone_ar__c = arAccount.Phone;
            caseRec.US_WSREMS__Participant_Fax__c = arAccount.US_WSREMS__Fax_Number__c;
            caseRec.US_WSREMS__Phone_Type__c = 'Mobile';
            caseRec.US_WSREMS__Email__c = arAccount.US_WSREMS__Email__c;
            caseRec.US_WSREMS__Email_ar__c = arAccount.US_WSREMS__Email__c;
            caseRec.US_WSREMS__Preferred_Contact_Method__c = arAccount.US_WSREMS__Preferred_Contact_Method__c;
            caseRec.US_WSREMS__Role__c = arAccount.US_WSREMS__Role__c;
            caseRec.Other__c = arAccount.US_WSREMS__Other__c;
            caseRec.US_WSREMS__Middle_Name__c = arAccount.MiddleName;
            caseRec.US_WSREMS__Participant_Fax__c = arAccount.Fax;
            caseRec.US_WSREMS__Legal_Guardian_Name__c = arAccount.US_WSREMS__Legal_Guardian_Name__c;
        }
        return caseRec;
    }
    
    public static Case caseChangeARFields(Case caseRec, Account hcsAccountList, Account arAccount, Account existARAcc){
        caseRec.US_WSREMS__Address_Line_1__c = hcsAccountList.US_WSREMS__Address_Line_1__c;
        caseRec.US_WSREMS__State__c = hcsAccountList.US_WSREMS__State__c;
        caseRec.US_WSREMS__Zip__c = hcsAccountList.US_WSREMS__Zip__c;
        caseRec.US_WSREMS__City__c = hcsAccountList.US_WSREMS__City__c;
        caseRec.US_WSREMS__NPI__c = hcsAccountList.US_WSREMS__National_Provider_Identifier__c;
        caseRec.US_WSREMS__Healthcare_Setting__c = hcsAccountList.Id;
        if(existARAcc!=null){
        caseRec.US_WSREMS__First_Name__c = existARAcc.FirstName;
        caseRec.US_WSREMS__Last_Name__c = existARAcc.LastName;
        caseRec.US_WSREMS__UserType__c = existARAcc.US_WSREMS__User_Type__c;
        caseRec.US_WSREMS__Phone__c = existARAcc.Phone;
        caseRec.US_WSREMS__Email__c = existARAcc.PersonEmail;
        }
        caseRec.US_WSREMS__Other_Title_New_Primary_AR__c = arAccount.US_WSREMS__Role__c;
        caseRec.US_WSREMS__AR_Phone_New_Primary_AR__c = arAccount.Phone;
        caseRec.US_WSREMS__AR_Fax_New_Primary_AR__c = arAccount.Fax;
        caseRec.US_WSREMS__AR_Email_New_Primary_AR__c = arAccount.PersonEmail;
        caseRec.US_WSREMS__AR_Signature_Date_New_Primary_AR__c = Date.Today();
        caseRec.US_WSREMS__AR_Signature_New_Primary_AR__c = 'Yes';
        caseRec.US_WSREMS__Last_Name_New_Primary_AR__c = arAccount.LastName;
        caseRec.US_WSREMS__Authorized_Representative_New_Primary_AR__c = arAccount.Id;
        caseRec.US_WSREMS__AR_Phone_New_Primary_Ext__c = arAccount.US_WSREMS__Other__c;
        caseRec.US_WSREMS__First_Name_New_Primary_AR__c = arAccount.FirstName;
        caseRec.US_WSREMS__Participant__c = hcsAccountList.Id;
        return caseRec;
    }

    public static Case caseRecertFields(Case caseRec, Account hcsAccount, Account arAccount,RecordDataWrapper arObj){
        caseRec.US_WSREMS__Healthcare_Setting__c = hcsAccount.Id;
        caseRec.US_WSREMS__REMS_Authorized_Rep__c = arAccount.Id;
        caseRec.US_WSREMS__First_Name_ar__c = arObj.firstName;
        caseRec.US_WSREMS__Last_Name_ar__c = arObj.lastName;
        caseRec.US_WSREMS__Legal_Guardian_Name__c = arObj.suffix;
        caseRec.US_WSREMS__Middle_Name__c = arObj.middleName;
        caseRec.US_WSREMS__Phone_ar__c = arObj.phone;
        caseRec.US_WSREMS__Participant_Fax__c = arObj.fax;
        caseRec.US_WSREMS__Phone_Type__c = 'Main';
        caseRec.US_WSREMS__Email__c = arObj.email;
        caseRec.US_WSREMS__Preferred_Contact_Method__c = arObj.preferredContactMethod;
        caseRec.US_WSREMS__Role__c = arObj.role;
        caseRec.Other__c = arObj.other;
        return caseRec;
    }
    
    public static US_WSREMS__Affiliation__c insertAffiliation(Id prescriberAcc, List<US_WSREMS__REMS_Program__c> program, Id pharmacyAcc, String recordType) {
        
        try {
            String defaultUser = System.Label.xiaflex_default_Portal_User;
            User accountOwner = SYN_CommonUtility.getDefaultportalUser(defaultUser);      
            Id recordTypeId = Schema.sObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
            US_WSREMS__Affiliation__c affiliatedAcc = new US_WSREMS__Affiliation__c();
            affiliatedAcc.RecordTypeId = recordTypeId;
            affiliatedAcc.US_WSREMS__REMSProgram__c = program.size() > 0 ? program[0].Id : null;
            affiliatedAcc.US_WSREMS__isActive__c = true;
            affiliatedAcc.US_WSREMS__Start_Date__c = System.Today();
            if(recordType == 'Healthcare Setting Affiliation' || recordType == 'Prescriber Affiliation'){
                affiliatedAcc.US_WSREMS__Prescriber__c = prescriberAcc;
            } else if(recordType == 'Authorized Representative Affiliation'){
                affiliatedAcc.US_WSREMS__Authorized_Representative__c = prescriberAcc;
            }
            affiliatedAcc.US_WSREMS__Health_Care_Setting__c = pharmacyAcc;
            affiliatedAcc.OwnerId = accountOwner.Id;
            return affiliatedAcc;
            
        }  catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public static void inactivateAffiliations(List<US_WSREMS__Affiliation__c> affList){
        for(US_WSREMS__Affiliation__c affObj: affList){
            affObj.US_WSREMS__isActive__c = False;
            affObj.US_WSREMS__End_Date__c = Date.Today();
        }
        update affList;
    }

    public static boolean checkDuplicate(Account hcsAcc, String programType){
        List<Account> acc = [SELECT Id FROM Account WHERE Name =: hcsAcc.Name AND (US_WSREMS__National_Provider_Identifier__c =: hcsAcc.US_WSREMS__National_Provider_Identifier__c OR US_WSREMS__DEA__c =: hcsAcc.US_WSREMS__DEA__c OR US_WSREMS__NCPDP__c =: hcsAcc.US_WSREMS__NCPDP__c OR US_WSREMS__HIN__c =: hcsAcc.US_WSREMS__HIN__c) AND US_WSREMS__Program_Type__c =: programType ];
        return !acc.isEmpty();
    }

    public static boolean checkAffOnPres(Id presId, Id hcsId, String recordType){
        List<US_WSREMS__Affiliation__c> aff = [SELECT Id FROM US_WSREMS__Affiliation__c WHERE RecordType.Name =: recordType AND US_WSREMS__Health_Care_Setting__c =: hcsId AND US_WSREMS__Prescriber__c =: presId]; 
        return !aff.isEmpty();
    } 

    @AuraEnabled
    public static Account getExistingARAccount(String programType, String programName, String firstName, String lastName, String email){
        List<Account> accList = [SELECT Id, FirstName, LastName, US_WSREMS__Email__c, US_WSREMS__Status__c,
                            (SELECT Id FROM Users)  
                            FROM Account 
                            WHERE US_WSREMS__Program_Type__c =: programType 
                            AND US_WSREMS__REMS_Program__r.Name = :programName
                            AND FirstName = :firstName
                            AND LastName = :lastName
                            AND PersonEmail = :email];
        return (accList != NULL && !accList.isEmpty()) ? accList[0] : NULL;
    }
    
    public class RecordDataWrapper {
        public String Id;
        public String firstName;
        public String middleName;
        public String suffix;
        public String lastName;
        public String salutation;
        public String email;
        public String phone;
        public String phoneType;
        public String fax;
        public String participantType;
        public String npi;
        public String address1;
        public String address2;
        public String zipCode;
        public String city;
        public String state;
        public String name;
        public String DEA;
        public String preferredContactMethod;
        public String NCPDP;
        public String HIN;
        public String hcsType;
        public String Channel;
        public String role;
        public String other;
        public String degree;
        public String speciality;
        public String hcsOption;
        public String license;
        public String licenseState;
        public String SettingPhone; 
        public String SettingFax;
        public String me;
        public boolean onhold;
        public String hcsStatus;
    }
}