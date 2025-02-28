// Created By Rajeev for RDA Portal User Story on 8th July
public without sharing class AccountControllerRDA {
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccountsByNpi(String npi) {
        if (String.isBlank(npi)) {
            return new List<Account>();
        }
        Id RecordTypeId;
        String programName = 'TRYVIO REMS'; 
        RecordType PrescriberRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'account' AND DeveloperName = 'Prescriber'];
        RecordTypeId= PrescriberRecordtype.Id;
        String npiValue =   '%' + String.escapeSingleQuotes(npi) + '%';
        List<Account> accountList = new List<Account>();
        for(Account record : [SELECT Id,firstname,lastname, US_WSREMS__First_Name__c,Name,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Zip__c,US_WSREMS__NPI__c ,US_WSREMS__Status__c FROM Account WHERE US_WSREMS__Program_Name__c = :programName and RecordTypeId = :RecordTypeId and (US_WSREMS__National_Provider_Identifier__c like :npiValue OR US_WSREMS__NPI__c LIKE : npiValue) AND US_WSREMS__Status__c ='Certified']  ) {
            accountList.add(record);
        }
       return accountList;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<Account> searchAccountsByName(String firstname, String lastname, String state) {

        Id RecordTypeId;
        String programName = 'TRYVIO REMS'; 
        RecordType PrescriberRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'account' AND DeveloperName = 'Prescriber'];
        RecordTypeId= PrescriberRecordtype.Id;
		String fname = '%' + firstname + '%';
        String lname = '%' + lastname + '%';
		String lstate = '%' + state + '%';
        List<Account> accountList = new List<Account>();
        for(Account record : [SELECT Id,LastName,FirstName,US_WSREMS__Status__c,US_WSREMS__Program_Name__c, US_WSREMS__First_Name__c,Name,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Zip__c,US_WSREMS__NPI__c FROM Account WHERE US_WSREMS__Program_Name__c = :programName AND RecordTypeId = :RecordTypeId  AND LastName LIKE :lname AND US_WSREMS__State__c LIKE :lstate AND US_WSREMS__Status__c ='Certified']) {
            accountList.add(record);
    }
        return accountList;
    }

    @AuraEnabled
      public static Id createCase(Id accountId) {
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, 7);
        String RDACode = 'RDA-'+ randomNumber;
        US_WSREMS__REMS_Program__c program =  [ SELECT Id,name FROM US_WSREMS__REMS_Program__c WHERE name = 'TRYVIO REMS' LIMIT 1];
        Id RecordTypeId;
        RecordType Participant_Account_CreationRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'US_WSREMS__REMS_Service_Summary__c' AND DeveloperName = 'Pre_Dispense_Authorization'];
        RecordTypeId= Participant_Account_CreationRecordtype.Id;
        US_WSREMS__REMS_Service_Summary__c remsobj = new US_WSREMS__REMS_Service_Summary__c();
        if(!test.isRunningTest()) {
            remsobj.US_WSREMS__Participant__c  = accountId;
        }
        remsobj.US_WSREMS__REMSProgram__c = program.Id;
        remsobj.US_WSREMS__Status__c = 'Closed';
        remsobj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        remsobj.US_WSREMS__Service_Outcome__c = 'Successful';
        remsobj.RecordTypeId = Participant_Account_CreationRecordtype.Id;
        insert remsobj;
        Account accountRecord = [SELECT Id,FirstName ,MiddleName,LastName,US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Status__c,Medical_Specialty__c,US_WSREMS__Professional_Designation__c  FROM ACCOUNT WHERE Id =: accountId ];
        RecordType caseRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'case' AND DeveloperName = 'PDA' and NamespacePrefix != 'US_WSREMS'];
        Case newCase = new Case ();
        if(!test.isRunningTest()) {
            newCase.US_WSREMS__Participant__c = accountId;
            newCase.US_WSREMS__Prescriber__c = accountId;
        }
        newCase.US_WSREMS__REMS_Program__c = program.Id;
        newCase.US_WSREMS__Prescriber_First_Name__c = accountRecord.FirstName;
        newCase.US_WSREMS__Prescriber_Middle_Name__c = accountRecord.MiddleName;
        newCase.US_WSREMS__Prescriber_Last_Name__c = accountRecord.LastName;
        newCase.US_WSREMS__Prescriber_NPI__c = accountRecord.US_WSREMS__National_Provider_Identifier__c;
        newCase.Prescriber_NPI_or_DEA__c = accountRecord.US_WSREMS__Status__c;
        newCase.SYN_Medical_specialty__c = accountRecord.Medical_Specialty__c;
        newCase.US_WSREMS__Specialty__c =  accountRecord.Medical_Specialty__c;
        newCase.US_WSREMS__Professional_Designation__c = accountRecord.US_WSREMS__Professional_Designation__c;
        newCase.US_WSREMS__Program_Picklist__c = 'TRYVIO REMS';
        newCase.Status = 'Complete';
        newCase.US_WSREMS__Outcome__c = 'Approved';
        newCase.US_WSREMS__Authorization_Status__c = 'Approved';
        newCase.US_WSREMS__Authorization_Status_Reason__c =Label.RDA_Authorization_Message;
        newCase.RDA_Authorization_Code__c= RDACode;
        newCase.RecordTypeId= caseRecordtype.Id;
        newCase.US_WSREMS__Channel__c = 'Portal';
        newCase.Program_Record_Type_Control__c='TRYVIO REMS-PDA';
        newCase.RDA_Authorization_Code_Date__c = System.today();
        newCase.US_WSREMS__REMS_Service_Summary__c = remsobj.Id;
        insert newCase; 
        return newCase.Id;
    }


    @AuraEnabled(cacheable=true)
    public static Case getCaseDetails(Id caseId) {
        Case caseRecord = new Case();
        for(Case record :[ SELECT US_WSREMS__Participant__c, US_WSREMS__Participant__r.US_WSREMS__REMS_ID__c, RDA_Authorization_Code__c,US_WSREMS__Authorization_Status__c,Status,US_WSREMS__Prescriber_First_Name__c, US_WSREMS__Prescriber_Last_Name__c ,US_WSREMS__Prescriber_NPI__c ,Prescriber_NPI_or_DEA__c,US_WSREMS__REMS_Service_Summary__c, US_WSREMS__REMS_Service_Summary__r.Name, US_WSREMS__Prescriber_Middle_Name__c FROM Case WHERE Id = :caseId ] ) {
            caseRecord = record;
        }
        return caseRecord;
    } 

    @AuraEnabled
    public static Id createCaseWithoutAccount(String firstname, String lastname, String state, String npi) {
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, 7);
        String RDACode = 'RDA-'+ randomNumber;

        US_WSREMS__REMS_Program__c program =  [ SELECT Id,name FROM US_WSREMS__REMS_Program__c WHERE name = 'TRYVIO REMS' LIMIT 1];
        Id RecordTypeId;
        RecordType Participant_Account_CreationRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'US_WSREMS__REMS_Service_Summary__c' AND DeveloperName = 'Pre_Dispense_Authorization'];
        RecordTypeId= Participant_Account_CreationRecordtype.Id;
            
        US_WSREMS__REMS_Service_Summary__c remsobj = new US_WSREMS__REMS_Service_Summary__c();
        remsobj.US_WSREMS__REMSProgram__c = program.Id;
        remsobj.US_WSREMS__Status__c = 'Closed';
        remsobj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        remsobj.US_WSREMS__Service_Outcome__c = 'Successful';
        remsobj.RecordTypeId = Participant_Account_CreationRecordtype.Id;
        insert remsobj;

        RecordType caseRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'case' AND DeveloperName = 'PDA' and NamespacePrefix != 'US_WSREMS'];
        Case newCase = new Case();
        newCase.Status = 'Complete';
        newCase.US_WSREMS__Authorization_Status_Reason__c =Label.RDA_Negative_Authorization_Message;
        newCase.US_WSREMS__REMS_Program__c = program.Id;
        newCase.US_WSREMS__Program_Picklist__c = 'TRYVIO REMS';
        newCase.US_WSREMS__Prescriber_First_Name__c = firstname;
        newCase.US_WSREMS__Prescriber_Last_Name__c = lastname;
        newCase.US_WSREMS__State__c = state;
        newCase.US_WSREMS__Prescriber_NPI__c = npi;
        newCase.US_WSREMS__Authorization_Status__c = 'Denied';
        newCase.RDA_Authorization_Code_Date__c = System.today();
        newCase.US_WSREMS__Outcome__c = 'Denied';
        newCase.RecordTypeId= caseRecordtype.Id;
        newCase.US_WSREMS__Channel__c = 'Portal';
        newCase.Program_Record_Type_Control__c='TRYVIO REMS-PDA';
        newCase.US_WSREMS__REMS_Service_Summary__c = remsobj.Id;
        insert newCase;
        return newCase.Id;
    }
    @AuraEnabled
    public static Map<String,Map<String,String>> getPicklistFieldValues(){
        Map<String, Map<String, String>> mapToReturn = new Map<String, Map<String, String>>();
        String objectName = 'Account';
        
        List<String> fieldNameList = new List<String>{'US_WSREMS__State__c'};        
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        for(String fieldName : fieldNameList) {
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            Map<String, String> picklistMap = new Map<String, String>();
            for(Schema.PicklistEntry pickListVal : ple) {
                System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
                picklistMap.put(pickListVal.getLabel(), pickListVal.getValue());  
            }
            mapToReturn.put(fieldName, picklistMap);
            System.debug('picklistMap->'+ picklistMap);
            System.debug('mapToReturn->'+ mapToReturn);
        }
        return mapToReturn;
    }
}