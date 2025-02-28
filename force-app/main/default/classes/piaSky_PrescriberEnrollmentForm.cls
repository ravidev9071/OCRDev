public without sharing class piaSky_PrescriberEnrollmentForm {
 /****************************************************************************************************************
    * Method Name    : getPicklistFieldValues
    * @description   : Method to insert Community user record
    * @author Dilbag :  | 24-05-2024 
    * 
    * @return : picklist Values for state field 
    ****************************************************************************************************************/
     @AuraEnabled
    public static Map<String,Map<String,String>> getPicklistFieldValues(){
        Map<String,Map<String,String>> mapToReturn = new Map<String,Map<String,String>>();
        String objectName = 'Account';
        List<String> fieldNameList = new List<String>();
        fieldNameList.add('US_WSREMS__State__c');
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
         Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
         Map<String, String> MyStrings = new Map<String, String>{'AA' => 'AA','AE' => 'AE','AP' => 'AP'};

        for(String fieldName: fieldNameList){
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            Map<String,String> picklistMap = new Map<String,String>();
            for( Schema.PicklistEntry pickListVal : ple){
                 if((pickListVal.getValue()!=MyStrings.get('AA'))&&(pickListVal.getValue()!=MyStrings.get('AE'))&&(pickListVal.getValue()!=MyStrings.get('AP'))){
                     picklistMap.put(pickListVal.getLabel(), pickListVal.getValue());
                 }
            }
            mapToReturn.put(fieldName,picklistMap);
        }
        return mapToReturn;
    }
    
    /****************************************************************************************************************
    * Method Name    : insertDataOnHCPSubmit
    * @description   : Method to insert Community user record
    * @author Dilbag : 24-05-2024 
    * @param         :  Wrapper from Lightning component
    * @return : Return Success if account got inserted and related cases and services also.
    ****************************************************************************************************************/
    @AuraEnabled
    public static String insertDataOnHCPSubmit(Map<String,String> inputRecords){
        List<sObject> objToInsert = new List<sObject>();
        Map<String,Id> recordTypeMap = new Map<string,Id>();
        
        for(RecordType recType: [Select Name, SobjectType, Id from RecordType where Name In ('Prescriber Enrollment','Prescriber','Health Care Setting','Pharmacy/HCS Participant','HCS Enrollment', 'Prescriber Person Account')]){
            if((recType.name == 'Pharmacy/HCS Participant' || recType.name == 'Prescriber' || recType.name == 'Health Care Setting') && recType.SobjectType == 'Account'){
                recordTypeMap.put(recType.Name, recType.Id);
            } else if((recType.name == 'Prescriber Enrollment' || recType.name == 'Enrollment' || recType.name == 'Prescriber Person Account') && recType.SobjectType == 'Case'){
                recordTypeMap.put(recType.Name, recType.Id);
            }
        }
        
        String recordDetails = inputRecords.get('recordDetails');
        String pharmacyId = inputRecords.get('pharmacyId');
        String programName = inputRecords.get('programName');
        String profileName = inputRecords.get('profileName');
        String permissionSet = inputRecords.get('permissionSet');
        String base64Content = inputRecords.get('signatureData');
        
        List<US_WSREMS__REMS_Program__c>  program = [SELECT Id,Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =:programName];     
        PiaSky_NPISearchControllerPortal.RecordDataWrapper recordData = (PiaSky_NPISearchControllerPortal.RecordDataWrapper)System.JSON.deserialize(recordDetails,PiaSky_NPISearchControllerPortal.RecordDataWrapper.class);
        Boolean dupliacateEmail = [SELECT COUNT() FROM Account WHERE US_WSREMS__Email__c = :recordData.Email AND US_WSREMS__REMS_Program__r.Name =:programName ] > 0;
        Boolean duplicateNPI = fetchDuplicateNpi(recordData.npi, programName);
        if(dupliacateEmail){
            RETURN 'duplicateEmail';
        } 
        else if(duplicateNPI){
            Return 'duplicateNPI';
        }
        else {
            Account presAccount = PiaSky_NPISearchControllerPortal.insertAccount(recordData,program, true, REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER);
            List<Account> prescriberAccount = [SELECT Id,US_WSREMS__REMS_ID__c, Name from Account WHERE Id =: presAccount.Id LIMIT 1];
            US_WSREMS__REMS_Service_Summary__c serviceEnrollment = PiaSky_NPISearchControllerPortal.insertServiceSummary(prescriberAccount[0],program,'Prescriber','Enrollment');
            US_WSREMS__REMS_Service_Summary__c serviceCreation = PiaSky_NPISearchControllerPortal.insertServiceSummary(prescriberAccount[0],program,'Prescriber',REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
            Case caseRec = PiaSky_NPISearchControllerPortal.insertCase( recordData, prescriberAccount[0], serviceCreation,program,'Prescriber',null ,REMSAppLiterals.REQUESTORTYPE_PHARMACY_HCS_PARTICIPANT, recordTypeMap.get('Prescriber Person Account'));
            Case caseRec2 = PiaSky_NPISearchControllerPortal.insertCase( recordData, prescriberAccount[0], serviceEnrollment,program,'Prescriber',null ,REMSAppLiterals.REQUESTORTYPE_HCS, recordTypeMap.get('Prescriber Enrollment'));
            SavePrescriberSignature(caseRec2.Id,null,base64Content);

            presAccount.US_WSREMS__Status__c = 'Certified';
            update presAccount;
            return(String.valueOf(prescriberAccount[0].Id));
        }   
    }
    /****************************************************************************************************************
    * Method Name       : fetchDuplicateNpi
    * @description      : Method to insert Community user record
    * @author Dilbag    :  24-05-2024 
    * @param  npi       :  10 digit npi
    * @param proramname : program name
    * @return : Return Success if account got inserted and related cases and services also.
    ****************************************************************************************************************/
    public static boolean fetchDuplicateNpi(string npi, String programName){
		Boolean dupliacateNPI = [SELECT COUNT() FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = :npi AND US_WSREMS__REMS_Program__r.Name =:programName ] > 0;
        return dupliacateNPI;
    }

    /****************************************************************************************************************
    * Method Name       : SavePrescriberSignature
    * @description      : Method to save signature from presciber form
    * @author Marimuthu    :  24-05-2024 
    * @param  accountId       :  10 digit npi
    * @param agreementStatus : program name
    * @param b64SignData   :    attachment data
    * @return : Return Success if account got inserted and related cases and services also.
    ****************************************************************************************************************/
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
}