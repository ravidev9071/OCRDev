public without sharing class xiaflex_MyProfileController {

    @AuraEnabled
    public static List<User> getLoggedInUserAccountDetails() {
        String userId = UserInfo.getUserId();        
        List<User> userList = [
            SELECT Id, Name, Account.Name, Account.Id,
                Account.SYN_Ref_Id__c,Account.US_WSREMS__Status__c,Account.US_WSREMS__Hold_Account__c, Account.US_WSREMS__Legal_Guardian_Relationship__c, Account.US_WSREMS__National_Provider_Identifier__c,Account.PersonEmail,
                Account.Phone, Account.FirstName, Account.LastName, Account.US_WSREMS__Phone_Type__c,
                Account.Fax, Account.US_WSREMS__Preferred_Contact_Method__c, Account.MiddleName,Account.Salutation,
                Account.Medical_Specialty__c, Account.US_WSREMS__SLN__c,Account.US_WSREMS__Other_Credentials__c, Account.US_WSREMS__SLN_State__c,  Account.US_WSREMS__REMS_ID__c,
                Account.US_WSREMS__Professional_Designation__c,Account.US_WSREMS__Role__c,Account.US_WSREMS__Other__c,Account.US_WSREMS__Legal_Guardian_Name__c  
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
            createCOICase(accountRecord);
            return 'Success';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static Map<String,Map<String,String>> getPicklistFieldValues(){
        Map<String,Map<String,String>> mapToReturn = new Map<String,Map<String,String>>();
        String objectName = 'Account';
        List<String> fieldNameList = new List<String>();
        fieldNameList.add('US_WSREMS__SLN_State__c');
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        for(String fieldName: fieldNameList){
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            Map<String,String> picklistMap = new Map<String,String>();
            for( Schema.PicklistEntry pickListVal : ple){
                picklistMap.put(pickListVal.getLabel(), pickListVal.getValue());
                
            }
            mapToReturn.put(fieldName,picklistMap);
        }
        return mapToReturn;
    }
    
    public static void createCOICase(Account acc){
        List<US_WSREMS__REMS_Program__c>  program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'XIAFLEX'];
        List<Account> accList = [Select Id, Name, middleName, FirstName, US_WSREMS__National_Provider_Identifier__c, LastName, PersonEmail, Phone, US_WSREMS__Phone_Type__c, Fax, US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__Professional_Designation__c,US_WSREMS__Hold_Account__c, Medical_Specialty__c, US_WSREMS__SLN__c, US_WSREMS__SLN_State__c, US_WSREMS__Other_Credentials__c, Salutation, US_WSREMS__Role__c, US_WSREMS__REMS_ID__c, US_WSREMS__Program_Type__c, US_WSREMS__Recordtype_Label__c, US_WSREMS__Record_Type_Name__c From Account Where Id =: acc.Id Limit 1];
        xiaflex_ManagePharmacies.RecordDataWrapper recordData= new xiaflex_ManagePharmacies.RecordDataWrapper();
        recordData.Id = accList[0].Id;
        recordData.name = accList[0].name;
        recordData.middleName = accList[0].middleName;
        recordData.firstName = accList[0].FirstName;
        recordData.lastName = accList[0].LastName;
        recordData.email = accList[0].PersonEmail;
        recordData.phone = accList[0].Phone;
        recordData.phoneType = accList[0].US_WSREMS__Phone_Type__c;
        recordData.fax = accList[0].Fax;
        recordData.preferredContactMethod = accList[0].US_WSREMS__Preferred_Contact_Method__c;
        recordData.degree = accList[0].US_WSREMS__Professional_Designation__c;
        recordData.speciality = accList[0].Medical_Specialty__c;
        recordData.license = accList[0].US_WSREMS__SLN__c;
        recordData.licenseState = accList[0].US_WSREMS__SLN_State__c;
        recordData.other = accList[0].US_WSREMS__Other_Credentials__c;
        recordData.salutation = accList[0].Salutation;
        recordData.role = accList[0].US_WSREMS__Role__c;
        recordData.onhold = accList[0].US_WSREMS__Hold_Account__c;
        recordData.npi = accList[0].US_WSREMS__National_Provider_Identifier__c;
        String result = xiaflex_Application_Enrollment_Class.createChangeOfInfoCaseAndService(recordData, accList[0], program, accList[0].US_WSREMS__Record_Type_Name__c, accList[0].US_WSREMS__Recordtype_Label__c, accList[0].US_WSREMS__Program_Type__c);
    }

}