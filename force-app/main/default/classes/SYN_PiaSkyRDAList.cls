public without sharing class SYN_PiaSkyRDAList {
    @AuraEnabled
    public static List<Case> getCaseRDA(){
        List<Case> Case_list;
        string queryString = '';
        String programName=Label.PiaSky_REMS_Program_Name;
        String CaseStatus ='Complete';
        Id currentUserId = UserInfo.getUserId();
        Id RDARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RDA').getRecordTypeId();
        User portalUser = [SELECT Id, Contact.AccountId FROM User WHERE Id = :currentUserId];
        List<US_WSREMS__Affiliation__c> certifiedPharmacyAff = [
            SELECT Id, US_WSREMS__Pharmacy__c,
            US_WSREMS__Pharmacy__r.Name,US_WSREMS__Pharmacy__r.US_WSREMS__REMS_ID__c,
            US_WSREMS__Pharmacy__r.US_WSREMS__NPI__c,
            US_WSREMS__Authorized_Representative__c,US_WSREMS__isActive__c,
            US_WSREMS__Pharmacy__r.FirstName,US_WSREMS__Pharmacy__r.LastName
            FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Pharmacy_User__c =:portalUser.Contact.AccountId 
            AND US_WSREMS__Pharmacy__r.US_WSREMS__Status__c ='Certified' AND  US_WSREMS__isActive__c = true LIMIT 1];
        if(certifiedPharmacyAff.size()>0){ 
        String PharmacyId = certifiedPharmacyAff[0].US_WSREMS__Pharmacy__c;
        queryString ='Select id,rda_authorization_code__c, CaseNumber,US_WSREMS__REMS_Authorized_Rep__c,US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__Email__c,Prescriber_NPI__c,SYN_Prescriber__c,SYN_Prescriber__r.Name,SYN_Prescriber_First_Name__c,SYN_Prescriber_Last_Name__c,CreatedDate,CreatedBy.Name FROM Case WHERE US_WSREMS__Participant__c =:PharmacyId  AND  Status=:CaseStatus and RecordTypeId=:RDARecordTypeId order by createdDate desc';
        Case_list = Database.query(queryString);
        return Case_list;
        } else {
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String createCaseandService(Id prescriberId,String PrescriberFName,string PrescriberLName,String prescriberNPI, String remsId) {
        String programName=Label.PiaSky_REMS_Program_Name;
        Id RDARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RDA').getRecordTypeId();
        Id currentUserId = UserInfo.getUserId();
        List<US_WSREMS__REMS_Program__c> remsPrograms = [Select Id From US_WSREMS__REMS_Program__c WHERE Name=:programName LIMIt 1];
        User portalUser = [SELECT Id, Contact.AccountId,Contact.Account.FirstName,Contact.Account.LastName,Contact.Account.US_WSREMS__NPI__c,Contact.Account.US_WSREMS__REMS_ID__c FROM User WHERE Id = :currentUserId];
        List<US_WSREMS__Affiliation__c> certifiedPharmacyAff = [
            SELECT Id, US_WSREMS__Pharmacy__c,
            US_WSREMS__Pharmacy__r.Name,US_WSREMS__Pharmacy__r.US_WSREMS__REMS_ID__c,
            US_WSREMS__Pharmacy__r.US_WSREMS__NPI__c,
            US_WSREMS__Authorized_Representative__c,US_WSREMS__isActive__c,
            US_WSREMS__Pharmacy__r.FirstName,US_WSREMS__Pharmacy__r.LastName
            FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Pharmacy_User__c =:portalUser.Contact.AccountId 
            AND US_WSREMS__Pharmacy__r.US_WSREMS__Status__c ='Certified' AND  US_WSREMS__isActive__c = true LIMIT 1];
       
        Id PDARecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get('REMS Dispense Authorization').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c rs = new US_WSREMS__REMS_Service_Summary__c();
        rs.US_WSREMS__Status__c = 'Closed';
        rs.US_WSREMS__Service_Outcome__c ='Successful';
        rs.US_WSREMS__Participant__c =certifiedPharmacyAff[0].US_WSREMS__Pharmacy__c; 
        rs.US_WSREMS__Requestor_Type__c ='Outpatient Pharmacy';
        rs.RecordTypeId =PDARecordTypeId;
        rs.US_WSREMS__REMSProgram__c = remsPrograms[0].Id;
        insert rs;
        
        case cse = new case();
        cse.RecordTypeId = RDARecordTypeId;
        cse.SYN_Prescriber__c = prescriberId;
        cse.US_WSREMS__Outcome__c = 'Approved';
        cse.US_WSREMS__REMS_Authorized_Rep__c = portalUser.Contact.AccountId;
        cse.US_WSREMS__Channel__c = 'Portal';
        cse.Status = 'Complete';
        cse.US_WSREMS__Participant__c= certifiedPharmacyAff[0].US_WSREMS__Pharmacy__c;
        cse.US_WSREMS__Pharmacy__c =  certifiedPharmacyAff[0].US_WSREMS__Pharmacy__c;
        cse.US_WSREMS__REMS_Service_Summary__c = rs.Id;
        cse.US_WSREMS__Program_Picklist__c = 'PiaSky REMS';
        cse.US_WSREMS__Pharmacy_Name__c = certifiedPharmacyAff[0].US_WSREMS__Pharmacy__r.Name;
        cse.SYN_Pharmacy_Rems_Id_Number__c = certifiedPharmacyAff[0].US_WSREMS__Pharmacy__r.US_WSREMS__REMS_ID__c;
        cse.US_WSREMS__NPI__c = certifiedPharmacyAff[0].US_WSREMS__Pharmacy__r.US_WSREMS__NPI__c;
        cse.Participant_FirstName__c = portalUser.Contact.Account.FirstName; 
        cse.Participant_LastName__c = portalUser.Contact.Account.LastName;
        cse.US_WSREMS__Prescriber_Last_Name__c=PrescriberFName;
        cse.US_WSREMS__Prescriber_First_Name__c =PrescriberLName;
        cse.Prescriber_NPI__c = prescriberNPI;
        cse.Prescriber_REMS_ID_Number__c =remsId;       
        
        insert cse;
        rs.US_WSREMS__Path_Complete__c= true;
        update rs;
        return  'REMS Dispense Authorization Code \n' + [Select Id,RDA_Authorization_Code__c FROM case where Id=:cse.Id].RDA_Authorization_Code__c +'\n \n  Ok to Dispense';
        
    }
    
    @AuraEnabled
    public static Boolean checkLoggedinUserDetails() {
        Id currentUserId = UserInfo.getUserId();
        User portalUser = [SELECT Id, Contact.AccountId,Contact.Account.FirstName,Contact.Account.LastName,Contact.Account.US_WSREMS__National_Provider_Identifier__c,Contact.Account.US_WSREMS__REMS_ID__c FROM User WHERE Id = :currentUserId];

        Boolean showButton;
        List<US_WSREMS__Affiliation__c> certifiedPharmacyAff = [
            SELECT Id, US_WSREMS__Pharmacy__c,recordType.Name,US_WSREMS__Pharmacy__r.recordtype.name,
            US_WSREMS__Pharmacy__r.Name,US_WSREMS__Pharmacy__r.US_WSREMS__REMS_ID__c,
            US_WSREMS__Pharmacy__r.US_WSREMS__National_Provider_Identifier__c,
            US_WSREMS__Authorized_Representative__c,US_WSREMS__isActive__c,
            US_WSREMS__Pharmacy__r.FirstName,US_WSREMS__Pharmacy__r.LastName,US_WSREMS__Pharmacy_User__c
            FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Pharmacy_User__c =:portalUser.Contact.AccountId 
            AND US_WSREMS__Pharmacy__r.US_WSREMS__Status__c ='Certified' AND  US_WSREMS__isActive__c = true LIMIT 1];
        
        if(certifiedPharmacyAff.size() > 0 && certifiedPharmacyAff[0].US_WSREMS__Pharmacy__r.recordtype.name =='Inpatient Pharmacy') {
            showButton = false;
        } else {
            showButton = true;
        }
        return showButton;
    }
    @AuraEnabled
    public static loggedinUserWrapper loggedinUserDetails() {
        Id currentUserId = UserInfo.getUserId();
        loggedinUserWrapper wrapper = new loggedinUserWrapper();
        wrapper.userRecord = new User();
        for(User record : [SELECT Id,Name, Contact.AccountId,Contact.Account.FirstName,Contact.Account.LastName,Contact.Account.US_WSREMS__National_Provider_Identifier__c,Contact.Account.US_WSREMS__REMS_ID__c FROM User WHERE Id = :currentUserId]) {
            wrapper.userRecord = record;
            wrapper.userName = record.Name;
        }
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