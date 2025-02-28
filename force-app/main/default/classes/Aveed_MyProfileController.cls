public without sharing class Aveed_MyProfileController {
    
    @AuraEnabled(cacheable=true)
    public static List<User> getLoggedInUserAccountDetails() {
        String userId = UserInfo.getUserId();
        List<User> userList = [
            SELECT Id, Name, Account.Name, Account.Id,Account.US_WSREMS__REMS_ID__c, Account.US_WSREMS__National_Provider_Identifier__c, Account.US_WSREMS__DEA__c,
                Account.US_WSREMS__Phone_Number__c, Account.Fax, Account.US_WSREMS__SLN__c, Account.US_WSREMS__SLN_State__c,
                Account.US_WSREMS__Email__c, Account.US_WSREMS__Preferred_Contact_Method__c,
                Account.US_WSREMS__Status__c, Account.FirstName, Account.LastName, Account.US_WSREMS__Title__c,
                Account.US_WSREMS__Other__c, Account.Program_Name__c, Account.Phone, Account.MiddleName,
                Account.PersonEmail, Account.US_WSREMS__Professional_Designation__c, Account.US_WSREMS__Other_Credentials__c,
                Account.Medical_Specialty__c, Account.RecordType.Name, Account.US_WSREMS__Specialty__c
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
        NPISearchControllerPortal.RecordDataWrapper recordData = (NPISearchControllerPortal.RecordDataWrapper)System.JSON.deserialize(recordDetails, NPISearchControllerPortal.RecordDataWrapper.class);
        List<Account> accList = [SELECT Id, PersonContactId, US_WSREMS__User_Type__c, US_WSREMS__REMS_ID__c,RecordType.Name FROM Account WHERE Id = :personAccount LIMIT 1];
        String recordTypeName = accList[0].RecordType.Name;
        List<US_WSREMS__REMS_Program__c>  program =SYN_CommonUtility.getProgram(programName);
        try{
            US_WSREMS__REMS_Service_Summary__c serviceSummary = NPISearchControllerPortal.insertServiceSummary(accList[0], program, recordTypeName, REMSAppLiterals.CHANGE_OF_INFORMATION);
            Case caseRec;
            US_WSREMS__REMS_Service_Summary__c serviceSummaryRec;
            if(serviceSummary != null){
                caseRec = NPISearchControllerPortal.insertCase(recordData, accList[0], serviceSummary, program, REMSAppLiterals.CHANGE_OF_INFORMATION, null, REMSAppLiterals.REQUESTORTYPE_PRESCRIBER);
            }        
            if(caseRec != null){
                serviceSummaryRec = NPISearchControllerPortal.updateServiceSummary(serviceSummary);
            }
            return 'Success';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }

     @AuraEnabled
    public static loggedinUserWrapper loggedinUserDetails() {
        Id currentUserId = UserInfo.getUserId();
        loggedinUserWrapper wrapper = new loggedinUserWrapper();
        wrapper.userRecord = new User();
        // RT 21-10-24 851-changes
        User record = [SELECT Id,Name,Account.FirstName, Account.LastName FROM User WHERE Id = :currentUserId];
        wrapper.userRecord = record;
        wrapper.userName = record.Account.FirstName + ' ' + record.Account.LastName;
        return wrapper;
    }
    public class loggedinUserWrapper {
        @AuraEnabled public User userRecord;
        @AuraEnabled public String userName;
    }
    @AuraEnabled
    public static String loggedOutUser() {
        Id currentUserId = UserInfo.getUserId();
        List<AuthSession> authRecord = new List<AuthSession>();
        for(AuthSession record : [SELECT Id ,LoginType,UsersId ,LoginHistoryId,LoginGeoId, IsCurrent,LogoutUrl,SessionType,UserType,SourceIp  FROM AuthSession WHERE UsersId = :currentUserId AND IsCurrent =true]) {
            authRecord.add(record);
        }
        try {
            delete authRecord;
        } catch(exception e ){
            system.debug('----Error ------'+e.getMessage());
        }
        return 'delete';
    }
}