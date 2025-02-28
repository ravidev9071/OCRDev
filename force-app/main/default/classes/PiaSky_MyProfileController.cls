public Without Sharing class PiaSky_MyProfileController {

    @AuraEnabled(cacheable=true)
    public static List<User> getLoggedInUserAccountDetails() {
        String userId = UserInfo.getUserId();
        List<User> userList = [
            SELECT Id, Name, Account.Name, Account.Id,
                Account.US_WSREMS__Email__c, Account.US_WSREMS__Preferred_Contact_Method__c,Account.US_WSREMS__Participant_Title__c,
                Account.US_WSREMS__Status__c, Account.FirstName, Account.LastName, Account.US_WSREMS__Title__c,
                Account.US_WSREMS__Other__c, Account.Program_Name__c, Account.Phone, Account.MiddleName,
                Account.US_WSREMS__Address_Line_1__c, Account.US_WSREMS__City__c, Account.US_WSREMS__State__c,
                Account.US_WSREMS__Zip__c, Account.US_WSREMS__National_Provider_Identifier__c, Account.US_WSREMS__Fax_Number__c
            FROM User
            WHERE Id =: userId
            LIMIT 1
        ];
        return userList;
    }

    @AuraEnabled
    public static string updateAccountDetails(Map<String, object> accountObject){
        Account accountRecord = (Account) JSON.deserialize(JSON.serialize(accountObject), Account.class);
        try{
            update accountRecord;
            return 'Success';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static String createCaseAndServiceSummary(Map<String,String> inputRecords, Id personAccount, String programName ){
        String recordDetails = inputRecords.get('recordDetails');
        PiaSky_NPISearchControllerPortal.RecordDataWrapper recordData = (PiaSky_NPISearchControllerPortal.RecordDataWrapper)System.JSON.deserialize(recordDetails, PiaSky_NPISearchControllerPortal.RecordDataWrapper.class);
        id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(REMSAppLiterals.CHANGE_OF_INFORMATION).getRecordTypeId();
        List<Account> accList = [SELECT Id, PersonContactId, US_WSREMS__User_Type__c, US_WSREMS__REMS_ID__c FROM Account WHERE Id = :personAccount];
        List<US_WSREMS__REMS_Program__c>  program = [SELECT Id,Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =:programName];

        try{
            US_WSREMS__REMS_Service_Summary__c serviceSummary = PiaSky_NPISearchControllerPortal.insertServiceSummary(accList[0], program, REMSAppLiterals.SERVICE_PARTICIPANT_AR, REMSAppLiterals.CHANGE_OF_INFORMATION);
            Case caseRec;
            US_WSREMS__REMS_Service_Summary__c serviceSummaryRec;
            if(serviceSummary != null){
                caseRec = PiaSky_NPISearchControllerPortal.insertCase(recordData, accList[0], serviceSummary, program, REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT,null ,REMSAppLiterals.REQUESTORTYPE_PHARMACY_HCS_PARTICIPANT, caseRecordTypeId);
            }        
            if(caseRec != null){
                serviceSummaryRec = PiaSky_NPISearchControllerPortal.updateServiceSummary(serviceSummary);
            }
            return 'Success';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }
}