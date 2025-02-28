/**************************************************************************
    Name :   AddOfficeContactController 

    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Surya                6/6/2024             Initial Version
*********************************************************************************/
public with sharing class AddOfficeContactController {

    /********************************************************************************************************************************************************
    Method Name     : searchForAccounts()
    Parameters      :firstName: First Name of Office Contact
                     lastName: Last Name of Office Contact
                     email: Office Contact's Email Address
    Return          : ResponseWrapper: Wrapper for status and account
    Description     :This method is used to Search the Office Contacts records based on First Name, Last Name and Email Address.
    ***********************************************************************************************************************************************************/
    @AuraEnabled
    public static ResponseWrapper searchForAccounts(String firstName, String lastName, String email) {
       
          Map<String,Id> accountRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account');
          Id ocRcTypeID = accountRecordTypeMap.get('Office_Contact');
        Account prescriber = SYN_PortalEnrollmentController.getCurrentUserAccountInfo();
        ResponseWrapper oResponse = new ResponseWrapper();
        List<Account> accounts = [SELECT Id,FirstName, LastName, US_WSREMS__Email__c,Phone,Two_Factor_Authentication_Selection__c FROM Account WHERE LastName = :lastName AND US_WSREMS__Email__c = :email AND recordTypeId = :ocRcTypeID AND US_WSREMS__REMS_Program__c = :prescriber.US_WSREMS__REMS_Program__c ];
        if (accounts.size() > 1) {
            oResponse.status = 'Multiple Accounts with this email address and last name found, please use a unique email address or contact the REMS Coordinating Center at 1-888-572-2934';
            //throw new AuraHandledException('Multiple Accounts with this email address and last name found, please use a unique email address or contact the REMS Coordinating Center at 1-888-572-2934');
        } else if (accounts.size() == 1) {
            oResponse.status = 'Success';
            oResponse.account = accounts[0];
            //return accounts[0];
        } else {
            List<Account> emailAccounts = [SELECT Id,FirstName, LastName, US_WSREMS__Email__c,Phone,Two_Factor_Authentication_Selection__c FROM Account WHERE US_WSREMS__Email__c = :email];
            if (!emailAccounts.isEmpty()) {
                //throw new AuraHandledException('Account email address already exists for another account, please use a unique email address or contact the REMS Coordinating Center at 1-888-572-2934');
                oResponse.status = 'Account email address already exists for another account, please use a unique email address or contact the REMS Coordinating Center at 1-888-572-2934';
            } else {
                //throw new AuraHandledException('No results match your search criteria. Add new Office Contact information in blank fields below');
                oResponse.status = 'No results match your search criteria. Add new Office Contact information in blank fields below';
            }
        }
        
        return oResponse;
    }
    
    /********************************************************************************************************************************************************
    Method Name     : createOfficeContact()
    Parameters      :firstName: First Name of Office Contact
                     lastName: Last Name of Office Contact
                     email: Office Contact's Email Address
                     phone: Office Contact's Phone number
    Return          : ''
    Description     :This method is used to create the Office Contacts records based on First Name, Last Name, Email Address and Phone Number
    Date:09/15/2024 changes added to resolve Duplicate record type issue from line 65 to 70 by DILEEP G
    **********************************************************************************************************************************************************/
    @AuraEnabled
    public static void createOfficeContact(String firstName, String lastName, String email,String phone) {

        try {

        Account prescriber = SYN_PortalEnrollmentController.getCurrentUserAccountInfo();
        Map<String,Id> recordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account');
        Map<String,Id> caserecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        Map<String,Id> remsServrecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c');
        Id oCaseRecTypeID = caserecordTypeMap.get('Office_Contact');
        Id oServiceRecTypeID =remsServrecordTypeMap.get('Participant_Account_Creation');
        Id ocRcTypeID = recordTypeMap.get('Office_Contact');

        Id programId = null;
            if(Test.isRunningTest()) {
                US_WSREMS__REMS_Program__c [] programList = [SELECT Id from US_WSREMS__REMS_Program__c];
                programId = programList[0].Id;
                
            } else {
                programId = prescriber.US_WSREMS__REMS_Program__c;
            }
            Account associatedAccount = new Account(LastName = lastName,
                                       FirstName = firstName,
                                       US_WSREMS__Email__c = email,
                                       recordtypeId = ocRcTypeID,
phone = phone,
                                       US_WSREMS__Channel__c = 'Portal',        
                                           US_WSREMS__REMS_Program__c = programId,
                                           Two_Factor_Authentication_Selection__c = 'Opt-In',
                                           US_WSREMS__Role__c = 'Office Contact',
                                           SYN_User_Type__c  = 'Office Contact'
                                           );
        insert associatedAccount;
        
        
        
        US_WSREMS__REMS_Service_Summary__c servicerecord = new US_WSREMS__REMS_Service_Summary__c(
            								US_WSREMS__REMSProgram__c = programId,
            								RecordTypeId = oServiceRecTypeID,
            								US_WSREMS__Requestor_Type__c = 'Office Contact',
            								US_WSREMS__Participant__c = associatedAccount.Id,
                                                US_WSREMS__Status__c = 'Closed',
                                                US_WSREMS__Service_Outcome__c = 'Successful'
        								);
        insert servicerecord;
        
        Case oCase = new Case(
            recordTypeId = oCaseRecTypeID,
            status = 'Complete',
            US_WSREMS__Outcome__c ='Complete',
            US_WSREMS__Email__c = email,
            US_WSREMS__First_Name__c = firstName,
            US_WSREMS__Last_Name__c = lastName ,
            Phone_Secondary_Office__c = phone,
            US_WSREMS__Program_Picklist__c = 'Macitentan REMS',
            US_WSREMS__REMS_Program__c = programId,
            US_WSREMS__Participant__c = associatedAccount.Id,
            US_WSREMS__REMS_Service_Summary__c = servicerecord.Id,
            US_WSREMS__Channel__c = 'Portal',
            US_WSREMS__Role__c = 'Office Contact',
            US_WSREMS__UserType__c = 'Office Contact'
                
        );
        insert oCase;
        
        createAffiliation(associatedAccount,false);
        } catch(Exception expObj) {
            throw new AuraHandledException(expObj.getMessage());
        }
    }

    /********************************************************************************************************************************************************
    Method Name     : createAffiliation()
    Parameters      : Office Contact Account
    Return          : 
    Description     :This method is used to affiliate found Office Contact with logged in prescriber
    Date:09/15/2024 changes added to resolev Duplicate record type issue form line 143,144 by DILEEP G
 
    **********************************************************************************************************************************************************/
    @AuraEnabled
    public static void createAffiliation(Account oAccount,Boolean isAccountUpdate) {

        try {
        Account prescriber = SYN_PortalEnrollmentController.getCurrentUserAccountInfo();
        Map<String,Id> affrecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Affiliation__c'); 
        Id recordTypeIdOfficeContact =affrecordTypeMap.get('Office_Contact_Affiliation');
Id programId = null;
            
            if(Test.isRunningTest()) {
                US_WSREMS__REMS_Program__c [] programList = [SELECT Id from US_WSREMS__REMS_Program__c];
                programId = programList[0].Id;

} else {
                programId = prescriber.US_WSREMS__REMS_Program__c;
            }
        US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c(
            US_WSREMS__REMSProgram__c = programId,
            RecordTypeId = recordTypeIdOfficeContact,
            Office_Contact__c = oAccount.Id,
            US_WSREMS__Start_Date__c = System.today(),//Added BY Dileep Gurram(Wilco) to populate start date on affiliation
            US_WSREMS__Prescriber__c = prescriber.Id,
            US_WSREMS__isActive__c = true);

if(isAccountUpdate) {
                update oAccount;
            }
            
       insert affiliationRecord;
        

        } catch (Exception expObj) {
            throw new AuraHandledException(expObj.getMessage());
        }
    }
    
    
    public class ResponseWrapper {
        @AuraEnabled public string status {get; set;}
        @AuraEnabled public Account account {get; set;}
    }
}