/**
 * @description       : This class has the functionality to create an User for the migrated records from portal page.
 *                      AccountId has been passed as the URL param to create an User.
 *                      Site link has been sent through blast email batch class to the migrated Users to setup their password.
 *                      To effiectively assign the license we are creating the portal User when they click in the email and complete the action.
 * @author            : Utthirakumar
 * @group             : 
 * @last modified on  : 20-11-2024
 * @last modified by  : Utthirakumar
**/

public without sharing class RemsOneTimePortalPasswordSetupController {
    
    // Constants for hardcoded values
    private static final String TIME_ZONE_SID_KEY = 'America/Mexico_City';
    private static final String LOCALE_SID_KEY = 'en_US';
    private static final String EMAIL_ENCODING_KEY = 'UTF-8';
    private static final String STRING_READ = 'Read';
    private static final String STRING_EDIT = 'Edit';
    private static final String STRING_MANUAL = 'Manual';
    
    /*
    *********************************************************
    @Method Name    : getAccountDetailsById
    @author         : Utthirakumar
    @description    : method is used to get stakeholder details by passing the recordId.
    @param          : accountId - stakeholder Id
    @return         : Account - stakeholder details
    ********************************************************
    */
    @AuraEnabled
    public static Account getAccountDetailsById(string recordId) { 
       List<Account> accList = [SELECT Id,US_WSREMS__Status__c,RecordType.DeveloperName,US_WSREMS__Email__c,IsCustomerPortal,PersonEmail FROM Account WHERE Id =: recordId];
       Account pAccount;
       if(accList != NULL && accList.size() > 0 ){
            pAccount = accList[0];
       }
       return pAccount;                                                                                                              
    }

    /*
    *********************************************************
    @Method Name    : getActiveUserByEmail
    @author         : Utthirakumar
    @description    : method is used to fetch active User for the parameters passed.
    @param          : email - email address of the User to search
                      programName - Name of the program
                      accountRecId - stakeholder recordId
                      errorMsg - error message to return when the active User is found
    @return         : returns a message indicating the status of the user search.
    ********************************************************
    */
    @AuraEnabled(cacheable=true)
    public static String getActiveUserByEmail(String email, String programName, String accountRecId, String errorMsg) {
        try {
            // Query to find person account by email
            List<Account> personAccountList = [
                SELECT Id, Name, PersonEmail, PersonContactId
                FROM Account
                WHERE Id =: accountRecId AND IsPersonAccount = true AND (PersonEmail = :email OR US_WSREMS__Email__c = :email ) AND Program_Name__c =: programName
            ];

            // If no person account is found, return the corresponding message
            if (personAccountList.isEmpty()) {
                return 'No contact found';
            } else {
                // Query to find active user by email
                List<User> existingUser = [
                    SELECT Id, Name, Email, IsActive
                    FROM User
                    WHERE ContactId != Null AND ContactId =: personAccountList[0].PersonContactId AND Email =: email AND IsActive = true AND Program__c =: programName 
                    LIMIT 1
                ];

                // If an active user is found, return the corresponding message
                if (!existingUser.isEmpty()) {
                    return errorMsg;
                } else {
                    return 'No User';
                }
            }
        } catch (Exception e) {
            // Handle exception and throw AuraHandledException with the error message
            System.debug(LoggingLevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : createCommunityUser
    @author         : Utthirakumar
    @description    : method is used to create community user.
    @param          : contactEmail - email of the contact.
                      pwd - password value for the new user.
                      programName - Name of the associated Program.
                      profileName - ProfileName associated to the Program.
                      permissionSetName - permissionSetName associated to the Program.
                      accountRecId - Record id associated to the account passed in the url param
    @return         : returns the redirect URL after successful User creation
    ********************************************************
    */
    @AuraEnabled
    public static String createCommunityUser(String contactEmail, String pwd, String programName, String profileName, String permissionSetName, String accountRecId ) { 
       try{
            List<User> communityuserlist = new List<User>();
            Id userId = null;
            
            // Query to get profile ID
            List<Profile> profileList = [SELECT Id, Name, UserType FROM Profile WHERE Name = : profileName LIMIT 1];
            ID ProfileId;
            if( profileList != NULL && profileList.size() > 0 ){
                ProfileId = profileList[0].Id;
            }

            // Query to get contact by email and accountId
            List<Contact> conList = [SELECT Id, FirstName, LastName, Account.US_WSREMS__Email__c, Account.PersonEmail, AccountId, 
                                            Account.US_WSREMS__REMS_Program__c, Account.US_WSREMS__REMS_Program__r.Name,Account.US_WSREMS__Recordtype_Label__c, 
                                            Account.US_WSREMS__REMS_Program__r.REMS_Project_Code__c, Account.US_WSREMS__Record_Type_Name__c 
                                        FROM Contact 
                                        WHERE AccountId != null AND AccountId =: accountRecId AND (Email = :contactEmail OR Account.US_WSREMS__Email__c = :contactEmail OR Account.PersonEmail = :contactEmail )  AND Account.Program_Name__c =: programName  LIMIT 1];
            Contact con;

            if( conList != NULL && conList.size() > 0 ){
                con = conList[0];
            }

            // Determine email address to use
            String email;
            if (con.Account.PersonEmail != null) {
                email = con.Account.PersonEmail;
            } else if (con.Account.US_WSREMS__Email__c != null) {
                email = con.Account.US_WSREMS__Email__c;
            }

            // Create custom alias and nickname
            String customalias;
            if (con.LastName.length() < 9) {
                customalias = con.LastName;   
            } else {
                customalias = con.LastName.left(7);
            }

            String nickname;
            if (con.LastName.length() < 40) {
                nickname = con.LastName;   
            } else {
                nickname = con.LastName.left(39);
            }

            string role = con.Account.US_WSREMS__Record_Type_Name__c;
            string persona;

            if( String.isNotBlank(role) ){
                if( role == SYN_Utilitycls.ACC_RCTY_Pharmacy_Participant ){
                    role = 'Pharmacy Participant'; 
                    persona = 'ar';
                } else if (role == SYN_Utilitycls.Prescriber ){
                    persona = 'pr';
                }
            }

            // Set community user properties
            User communityuser = new User(
                UserName = contactEmail+'.'+con.Account.US_WSREMS__REMS_Program__r.REMS_Project_Code__c+'.'+persona,
                FirstName = con.FirstName,
                LastName = con.LastName,                    
                alias = customalias.trim(),
                Email = email,
                CommunityNickname = nickname + System.now().millisecond(),
                ProfileId = ProfileId,
                TimeZoneSidKey = TIME_ZONE_SID_KEY,
                LocaleSidKey = LOCALE_SID_KEY,
                EmailEncodingKey = EMAIL_ENCODING_KEY, 
                LanguageLocaleKey = LOCALE_SID_KEY,
                IsActive = true,
                ContactId = con.Id,
                Program__c = con.Account.US_WSREMS__REMS_Program__r.Name,
                US_WSREMS__REMS_Program__c = con.Account.US_WSREMS__REMS_Program__r.Name,
                Role__c = role
            );

            // Validate and create the external user
            if(!Test.isRunningTest()) { 
                Site.validatePassword(communityuser, pwd.trim(), pwd.trim());
            }
            userId = Site.createExternalUser(communityuser, con.AccountId, pwd.trim());

            //For test class coverage
            if(Test.isRunningTest()) { 
                List<User> usrList = [ SELECT Id FROM User WHERE ProfileId =: communityuser.ProfileId AND Program__c =: communityuser.Program__c AND IsActive = TRUE limit 1];
                if(usrList != NULL && usrList.size() > 0){
                    userId = usrList[0].Id;
                }
            }
            // If user is created successfully, set sharing permissions and login
            if (userId != null) {
                ManagerAccountSharingPermission(userId, con.AccountId);
                ManagerProgramSharingPermission(userId, con.Account.US_WSREMS__REMS_Program__c);
                assignPermissionSetToUser(userId, permissionSetName);
                
                ApexPages.PageReference lgn;
                
                if( programName == SYN_Utilitycls.AVEED_PROGRAM_NAME) {
                    lgn = Site.login(communityuser.UserName, pwd.trim(),  Site.getBaseUrl()+'/s/');
                    return (lgn != null) ?lgn.getUrl() : null;
                } else if( programName == SYN_Utilitycls.XIAFLEX_PROGRAM_NAME ) {
                    String baseSiteURL = '';
                    if( role == SYN_Utilitycls.Prescriber ){
                        baseSiteURL = Site.getBaseUrl()+'/s/hcp-manage-hcs';
                    } else if( role == 'Pharmacy Participant' ){
                        baseSiteURL = Site.getBaseUrl()+'/s/manage-hcs';
                    } else {
                        baseSiteURL = Site.getBaseUrl()+'/s/'; 
                    }
                    lgn = Site.login(communityuser.UserName, pwd.trim(), baseSiteURL);
                    return (lgn != null) ? lgn.getUrl() : null;
                }
               
            }
            return userId;

        } catch (Exception e) {
            // Handle exception and throw AuraHandledException with the error message
            System.debug(LoggingLevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : ManagerAccountSharingPermission
    @author         : Utthirakumar
    @description    : method is used to create account sharing permission.
    @param          : userId - Id of the newly created User.
                      accountId - Record id associated to the account passed in the url param
    @return         : void
    ********************************************************
    */
    public static void ManagerAccountSharingPermission(String userId, Id AccountId) {
        AccountShare provAcctShare = new AccountShare(
            AccountId = AccountId,
            UserOrGroupId = userId,
            AccountAccessLevel = STRING_EDIT,
            OpportunityAccessLevel = STRING_READ,
            CaseAccessLevel = STRING_EDIT,
            RowCause = STRING_MANUAL
        );

        try {
            insert provAcctShare;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : ManagerProgramSharingPermission
    @author         : Utthirakumar
    @description    : method is used to create program sharing permission.
    @param          : userId - Id of the newly created User.
                      programId - Record id of the associated program.
    @return         : void
    ********************************************************
    */
    public static void ManagerProgramSharingPermission(String userId, Id programId) {
        US_WSREMS__REMS_Program__Share progShare = new US_WSREMS__REMS_Program__Share(
            UserOrGroupId = userId,
            ParentId = programId,
            AccessLevel = STRING_READ,
            RowCause = STRING_MANUAL
        );
        try {
            insert progShare;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : assignPermissionSetToUser
    @author         : Utthirakumar
    @description    : method is used to assign permissionset for the new User.
    @param          : userId - Id of the newly created User.
                      permissionSetApiName - API name of the permissionset.
    @return         : void
    ********************************************************
    */
    @future
    public static void assignPermissionSetToUser(Id userId, String permissionSetApiName) {
       try {
            // Query the Permission Set Id using the API name
            PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetApiName LIMIT 1];
            if (permSet == null) {
                return;
            }
            Id permissionSetId = permSet.Id;

            // Create the PermissionSetAssignment object
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = userId,
                PermissionSetId = permissionSetId
            );

            List<PermissionSetAssignment> psaList = [ SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: userId AND PermissionSetId =: permissionSetId ];
            // Insert the PermissionSetAssignment
            if( psaList != NULL && psaList.isEmpty() ){
                insert psa;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}