public with sharing class REMSEnablePortalUserController {
    @AuraEnabled
    public static String portalUserCreation(String recordId){  
        Id prescriberRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
         Id PharmacyParticipantRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
            List<Account> accountList = [SELECT Id,US_WSREMS__Status__c,FirstName,LastName,US_WSREMS__Email__c,PersonContactId,
                        Owner.UserRole.Name,RecordTypeId    
                        FROM Account WHERE Id=:recordId];
            if(accountList!=null && accountList.size()>0){
                List<User> userList = [Select Id,ContactId FROM User WHERE ContactId =: accountList[0].PersonContactId];
                if(userList!=null && userList.size()>0){
                    return 'Warning#'+System.Label.Portal_User_Enabled;
                }
               if(accountList[0].Owner.UserRole.Name == null ||   accountList[0].Owner.UserRole.Name == ''){
                    return 'Error#'+System.Label.No_Account_Owner_Role;
                }
                if((accountList[0].RecordTypeId == PharmacyParticipantRecordtypeId  && accountList[0].US_WSREMS__Status__c != 'Active') || (accountList[0].RecordTypeId == prescriberRecordtypeId  && accountList[0].US_WSREMS__Status__c != 'Certified')){
                    return 'Error#'+System.Label.In_Active_Account;
                }
                Profile p =[Select Id from Profile where Name=: Label.SOX_Prescriber_Profile LIMIT 1];
                Profile p1 =[Select Id from Profile where Name=: Label.SOX_Pharmacist_Profile LIMIT 1];
                User userObj = New User(
                    UserName = accountList[0].US_WSREMS__Email__c,
                    FirstName = accountList[0].FirstName,
                    LastName = accountList[0].LastName,
                    ContactId = accountList[0].PersonContactId,
                    Alias = string.valueOf(math.random()).substring(0,6),
                    email = accountList[0].US_WSREMS__Email__c,
                    CommunityNickName = string.valueOf(math.random()).substring(0,6),
                    ProfileID = accountList[0].recordTypeId == prescriberRecordtypeId ?p.id:p1.Id,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    Program__c=Label.Sodium_Oxybate_REMS_Program_Name
                );
                try{
                    insert userObj;
                    List<PermissionSet> permList = [Select Id,Name from PermissionSet 
                                WHERE Name='SOX_Prescriber'  limit 1];
                    List<PermissionSet> soxPharmaList = [Select Id,Name from PermissionSet 
                                WHERE Name='SOX_Pharmacist'  limit 1];  
                    if(permList!=null && permList.size()>0){
                        PermissionSetAssignment psAssignmentObj = new PermissionSetAssignment
                        (PermissionSetId = userObj.ProfileId==p.Id?permList[0].Id:soxPharmaList[0].Id, AssigneeId = userObj.Id);
                        insert psAssignmentObj; 
                    }
                    return 'Success#'+System.Label.Portal_User_Created;
                    

                }
                                catch(Exception e){
                    System.debug('--->Exception::'+e.getMessage()+'--'+e.getLineNumber());
                    return 'Error#'+System.Label.ContactAdministrator;
                    
                }
            }              
       
        return null;
        
    }
   
}