/**
* @description       : OfficeContactMappingController is controller class to Map Office Contact Accounts with Prescriber.
* @author            : Satyam Pandey
* @group             :
* @last modified on  : 06-28-2024
**/
public class OfficeContactMappingController {
    public static final String EMAIL_SEARCH = 'Search By Email';
    public static final String NPI_SEARCH = 'Search By NPI';
    public static final String REMSID_SEARCH = 'Search By REMS ID';
    public static final String NO_RECORD_ERROR_MESSAGE = 'No Record Found..';
    public static final String PRESCRIBER = 'Prescriber';
    public static final String  Health_Care_Setting ='Health_Care_Setting';
    public static final String OFFICE_CONTACT = 'Office_Contact';
    public static final String INPATIENTPHARMACY = 'Inpatient_Pharmacy_Account';
    public static final String OUTPATIENTPHARMACY = 'Outpatient_Pharmacy_Account';
    public static final String AFFILIATION_OBJECT = 'US_WSREMS__Affiliation__c';
    public static final String PRESCRIBER_AFFILIATION = 'Prescriber_Affiliation';
    public static final String OFFICE_CONTACT_AFFILIATION = 'Office_Contact_Affiliation';
    public static final String HCS_AFFILIATION = 'Healthcare_Setting_Affiliation';
    public static final String PHARMACY_AFFILIATION = 'Pharmacy_User_Affiliation';
    public static final String HCS_AR_AFFILIATION = 'Authorized_Representative_Affiliation';
    public static final String PRES_DEL_AFFILIATION = 'Prescriber_Delegate_Affiliation';//2166
    public static final String REMS_ID = 'RemsId';
    public static final String ID = 'Id';
    public static final String SUCCESS = 'SUCCESS';
    public static final set<String> enrollmentRecSet = new Set <String> {'Prescriber_enrollment','HCS_Enrollment','Outpatient_Pharmacy_Enrollment','Inpatient_Pharmacy_Enrollment','HCS_Reenrollment','Inpatient_Pharmacy_Reenrollment','Outpatient_Pharmacy_Reenrollment','Prescriber_Reenrollment','Distributor_Enrollment'};
    public static final String ADD_AR_PHARMACY_STAFF = 'Add_AR_Pharmacy_staff';
    public static final String ADD_AR_PHARMACY = 'Add_AR_Pharmacy';
    public static final String ADD_PRESCRIBER_DEL = 'Add_Prescriber_Delegate';//2166
    public static final String ADD_AR_HCS = 'Add_AR_HCS';
    Public static final String CERTIFIED = 'Certified';//2166
    Public static final String PRESCRIBER_DEL= 'Prescriber_Delegate';//2166
    Public static final String DEACTIVATE_STATUS = 'Decertified;Discontinued;Disenrolled;Deactivated;Cancelled';
    /**
* @Description  :   getPrescriberAccountList Method is Used to get Prescriber Accounts
* @Parameter    :   String searchKey -> It is the term to search
* @return       :   list<Account>
**/
    @AuraEnabled
    public static List<Account> getPrescriberAccountList(
        String searchKey,
        String recordTypeName,
        String filterCriteria,
        String programId,
        String currentRecordTypeName //2166
    ) {
        List<Account> queryAccList = new List<Account>();
        List<Account> accountList = new List<Account>();
        List<String> recordTypeList = new List<String>();
        List<String> accountStatusList = new List<String>();
        if (String.isNotBlank(searchKey) && String.isNotBlank(recordTypeName) && String.isNotBlank(filterCriteria)) {
            recordTypeList = recordTypeName.split(';');
            accountStatusList = DEACTIVATE_STATUS.split(';');
            String searchKeyword = '%' + searchKey + '%';
            String query = 'SELECT Id, Name, US_WSREMS__Email__c, US_WSREMS__Phone_Number__c,US_WSREMS__REMS_ID__c,US_WSREMS__National_Provider_Identifier__c, US_WSREMS__REMS_Program__c, US_WSREMS__Record_Type_Name__c,Phone,'
            +'FirstName,LastName FROM Account WHERE RecordType.DeveloperName in :recordTypeList AND US_WSREMS__REMS_Program__c = :programId AND US_WSREMS__Status__c not in :accountStatusList AND ';
            if(currentRecordTypeName == PRESCRIBER_DEL){//2166
                query +='US_WSREMS__Status__c=:CERTIFIED AND '; 
            }
            if (filterCriteria == EMAIL_SEARCH) {
                query+= 'US_WSREMS__Email__c LIKE :searchKeyword';
            } else if (filterCriteria == NPI_SEARCH) {
                query+= 'US_WSREMS__National_Provider_Identifier__c LIKE :searchKeyword LIMIT 5';
            } else if(filterCriteria == REMSID_SEARCH){//2166
                query+= 'US_WSREMS__REMS_ID__c LIKE :searchKeyword';
            }
            else {
                string accountName = searchKey;
                Set<String> accountNameSet = new Set<String>(accountName.split(' '));
                query+= '(Name LIKE :searchKeyword OR FirstName IN :accountNameSet OR LastName IN :accountNameSet OR MiddleName IN :accountNameSet) ORDER BY Name';
            }
            queryAccList = Database.query(query);

        }
        if (queryAccList.size() == 0) {
            throw new AuraHandledException(NO_RECORD_ERROR_MESSAGE);
        }else{
            if(filterCriteria != EMAIL_SEARCH && filterCriteria != NPI_SEARCH && filterCriteria != REMSID_SEARCH){
                for (Account accRecord : queryAccList) {
                    String accountFirstLastName = accRecord.FirstName + ' ' + accRecord.LastName;
                    if (
                        accRecord.Name.toLowerCase().contains(searchKey.toLowerCase()) ||
                        accountFirstLastName.toLowerCase().contains(searchKey.toLowerCase())
                        ) {
                        accountList.add(accRecord);
                    }
                }
            }else{
                accountList.addAll(queryAccList);
            }
        }
        return accountList;
    }
    
    /**
* @Description  :   fetchRecordTypeData Method is Used to get RecordType Name of Accounts
* @Parameter    :   String recordId -> Id of record
* @return       :   String
**/
    @AuraEnabled(cacheable=true)
    public static AffliationWrapper fetchRecordTypeData(String recordId) {
        AffliationWrapper affiliationWrap = new AffliationWrapper();
        if (String.isNotBlank(recordId)) {
            Account accountRecord = [ SELECT Id,RecordType.DeveloperName,US_WSREMS__REMS_Program__r.Name,US_WSREMS__REMS_Program__c FROM Account WHERE ID = :recordId];
            affiliationWrap.programId = accountRecord.US_WSREMS__REMS_Program__c;
            affiliationWrap.programName = accountRecord.US_WSREMS__REMS_Program__r.Name;
            affiliationWrap.recordTypeName = accountRecord.RecordType.DeveloperName;
        }
        return affiliationWrap;
    }
    
    /**
* @Description  :   createAffiliationRecords Method is Used to create Affiliations for Prescriber
* @Parameter    :   String searchKey -> It is the term to search
* @return       :   list<Account>
**/
    @AuraEnabled
    public static String createAffiliationRecords (
        String recordId,
        String recordTypeName,
        String currentRecordTypeName,
        List<Map<String, String>> accountRecords,
        String quickActionName,
        String programName
    ) {
        List<US_WSREMS__Affiliation__c> affiliationList = new List<US_WSREMS__Affiliation__c>();
        String message = '';
        if (
            String.isNotBlank(recordId) &&
            !accountRecords?.isEmpty() &&
            String.isNotBlank(recordTypeName)
        ) {
            Id recordTypeId;
            if (recordTypeName == OFFICE_CONTACT) {
                recordTypeId = retrieveRecTypeDeveloperNameId(AFFILIATION_OBJECT).get(OFFICE_CONTACT_AFFILIATION);
            }else if(recordTypeName == Health_Care_Setting){
                recordTypeId = retrieveRecTypeDeveloperNameId(AFFILIATION_OBJECT).get(HCS_AFFILIATION);
            }
            else{
                recordTypeId = retrieveRecTypeDeveloperNameId(AFFILIATION_OBJECT).get(PRESCRIBER_AFFILIATION);
            }
            for (Map<String, String> account : accountRecords) {
                US_WSREMS__Affiliation__c affiliation = new US_WSREMS__Affiliation__c();
                affiliation.US_WSREMS__Start_Date__c = System.today();
                affiliation.US_WSREMS__isActive__c = true;
                affiliation.US_WSREMS__REMSProgram__c = programName;
                affiliation.recordTypeId = recordTypeId;
                if(currentRecordTypeName == OFFICE_CONTACT){
                    affiliation.US_WSREMS__Office_Contact__c = recordId;
                }else if(currentRecordTypeName == PRESCRIBER_DEL){//2166
                    affiliation.US_WSREMS__Prescriber_Delegate__c = recordId;
                }else if(currentRecordTypeName == PRESCRIBER){
                    affiliation.US_WSREMS__Prescriber__c = recordId;
                }
                else{
                    affiliation.US_WSREMS__Health_Care_Setting__c = recordId;
                }

                if(recordTypeName == OFFICE_CONTACT){
                    affiliation.US_WSREMS__Office_Contact__c = (Id) account.get(ID);
                }else if(recordTypeName == PRESCRIBER){
                    affiliation.US_WSREMS__Prescriber__c = (Id) account.get(ID);
                }else{
                    affiliation.US_WSREMS__Health_Care_Setting__c = (Id) account.get(ID);
                }

                if(quickActionName == Add_AR_HCS || (quickActionName == ADD_AR_PHARMACY_STAFF 
                    && currentRecordTypeName == Health_Care_Setting)){
                    recordTypeId = retrieveRecTypeDeveloperNameId(AFFILIATION_OBJECT).get(HCS_AR_AFFILIATION);
                    affiliation.US_WSREMS__Health_Care_Setting__c = (Id) account.get(ID);
                    affiliation.US_WSREMS__Authorized_Representative__c = recordId;
                    affiliation.recordTypeId=recordTypeId;
                    if(currentRecordTypeName == Health_Care_Setting){
                        affiliation.US_WSREMS__Health_Care_Setting__c = recordId;
                        affiliation.US_WSREMS__Authorized_Representative__c = (Id) account.get(ID);
                    }
                }
                if(quickActionName == ADD_AR_PHARMACY || (quickActionName == ADD_AR_PHARMACY_STAFF 
                && (currentRecordTypeName == INPATIENTPHARMACY || currentRecordTypeName == OUTPATIENTPHARMACY))){
                    recordTypeId = retrieveRecTypeDeveloperNameId(AFFILIATION_OBJECT).get(PHARMACY_AFFILIATION);
                    affiliation.US_WSREMS__Pharmacy__c = (Id) account.get(ID);
                    affiliation.US_WSREMS__Pharmacy_User__c = recordId;
                    affiliation.recordTypeId=recordTypeId;
                    if(currentRecordTypeName == INPATIENTPHARMACY || currentRecordTypeName == OUTPATIENTPHARMACY){
                        affiliation.US_WSREMS__Pharmacy__c = recordId;
                        affiliation.US_WSREMS__Pharmacy_User__c = (Id) account.get(ID);
                    }
                }
                //2166
                if(quickActionName == ADD_PRESCRIBER_DEL){
                    recordTypeId = retrieveRecTypeDeveloperNameId(AFFILIATION_OBJECT).get(PRES_DEL_AFFILIATION);
                    affiliation.US_WSREMS__Prescriber_Delegate__c = (Id) account.get(ID);
                    affiliation.US_WSREMS__Prescriber__c = recordId;
                    affiliation.recordTypeId=recordTypeId;
                }//2166
                system.debug('*****'+affiliation);
                affiliationList.add(affiliation);
            }
            
        }
        if (!affiliationList?.isEmpty()) {
            try {
                insert affiliationList;
                message = SUCCESS;
            } catch (Exception ex) {
                message = ex.getDmlMessage(0);
            }
        }
        return message;
    }
    
    /**
    * @Description  :   validateAffiliationRecords Method is Used to Validate Affiliations
    * @Parameter    :   String currentRecord,targetRecord,recordTypes for validating existing affiliations
    * @return       :   Boolean
    **/
    @AuraEnabled
    public static Boolean validateAffiliationRecords(
        String currentRecord,
        String targetRecord,
        String remsProgramId,
        String currentRecordTypeName,
        String targetRecordTypeName,
        String quickActionName
    ) {
        Boolean isDuplicate = false;
        if (
            String.isNotBlank(currentRecord) &&
            String.isNotBlank(targetRecord) &&
            String.isNotBlank(remsProgramId)
        ) {
            String query = 'SELECT Id, Name FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__REMSProgram__c = :remsProgramId ';
            if(currentRecordTypeName == OFFICE_CONTACT){
                query += 'AND US_WSREMS__Office_Contact__c = :currentRecord ';
            }else if(currentRecordTypeName == PRESCRIBER){
                query += 'AND US_WSREMS__Prescriber__c = :currentRecord ';
            }else{
                if(quickActionName == Add_AR_HCS){
                    query += 'AND US_WSREMS__Authorized_Representative__c = :currentRecord ';
                }
                else if(quickActionName == ADD_AR_PHARMACY){
                    query += 'AND US_WSREMS__Pharmacy_User__c = :currentRecord ';
                }
                else if(quickActionName == ADD_AR_PHARMACY_STAFF){
                    if(currentRecordTypeName == Health_Care_Setting){
                        query += 'AND US_WSREMS__Health_Care_Setting__c = :currentRecord ';
                    }
                    if(currentRecordTypeName == INPATIENTPHARMACY || currentRecordTypeName == OUTPATIENTPHARMACY){
                        query += 'AND US_WSREMS__Pharmacy__c = :currentRecord ';
                    }
            }else{
                query += 'AND US_WSREMS__Health_Care_Setting__c=:currentRecord ';
            }
            }

            

            if(targetRecordTypeName == OFFICE_CONTACT){
                query += 'AND US_WSREMS__Office_Contact__c = :targetRecord ';
            }else if(targetRecordTypeName == PRESCRIBER){
                query += 'AND US_WSREMS__Prescriber__c = :targetRecord ';
            }else{
                if(quickActionName == Add_AR_HCS){
                    query += 'AND US_WSREMS__Health_Care_Setting__c = :targetRecord ';
                }
                else if(quickActionName == ADD_AR_PHARMACY){
                    query += 'AND US_WSREMS__Pharmacy__c = :targetRecord ';
                }
                else if(quickActionName == ADD_AR_PHARMACY_STAFF){
                    if(currentRecordTypeName == Health_Care_Setting){
                        query += 'AND US_WSREMS__Authorized_Representative__c = :targetRecord ';
                    }
                    if(currentRecordTypeName == INPATIENTPHARMACY || currentRecordTypeName == OUTPATIENTPHARMACY){
                        query += 'AND US_WSREMS__Pharmacy_User__c = :targetRecord ';
                    }
            //2166
             else if(quickActionName == ADD_PRESCRIBER_DEL){
                     query += 'AND US_WSREMS__Prescriber_Delegate__c = :targetRecord ';
                    }
            //2166
            }else{
                query += 'AND US_WSREMS__Health_Care_Setting__c=:targetRecord ';
                }
            }

            List<US_WSREMS__Affiliation__c> affiliationList = Database.query(query);

            if (!affiliationList?.isEmpty()) {
                isDuplicate = true;
            } else {
                isDuplicate = false;
            }
        }
        return isDuplicate;
    }

     /**
* @Description  :   validateEnrollementCase Method is Used to get Enrollment Cases from Account
* @Parameter    :   String recordId -> Id of record
* @return       :   String
**/
@AuraEnabled(cacheable=true)
public static Boolean validateEnrollmentCase(String recordId,String quickActionName) {
    List<Case> caseList = new List<Case>();
    String Query = 'SELECT Id FROM Case WHERE RecordType.DeveloperName in :enrollmentRecSet AND US_WSREMS__Participant__c=:recordId';
    if(quickActionName == ADD_AR_PHARMACY_STAFF){
        Query = Query+' AND US_WSREMS__REMS_Authorized_Rep__c!=null';
    }
    caseList = Database.Query(Query);
    return !caseList.isEmpty();
    }
    
    public static Map<String,Id> retrieveRecTypeDeveloperNameId(String objectName){
        Map<String,Id> recordTypeDevNameIdMap = new Map<String,Id>();
        system.debug(objectName);
       // String updatedStringName = isCustomObject(objectName) ? REMSAppLiterals.NAMESPACE_STRING+objectName : objectName;
        Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = objectSchema.getRecordTypeInfosByName();
        for(String rectypeName:recordTypeInfoMap.keyset()){
            if(recordTypeInfoMap.get(rectypeName).getDeveloperName()!='Master' && !recordTypeInfoMap.get(rectypeName).isMaster())
                recordTypeDevNameIdMap.put(recordTypeInfoMap.get(rectypeName).getDeveloperName(),recordTypeInfoMap.get(rectypeName).getRecordTypeId());            
        }
        system.debug('******'+recordTypeDevNameIdMap);
        return recordTypeDevNameIdMap;

    }

    public class AffliationWrapper {
        @AuraEnabled
        public String programId;
        @AuraEnabled
        public String programName;
        @AuraEnabled
        public String recordTypeName;
    }
}