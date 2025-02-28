public without sharing class PiaSkyCustomPortalController {
    // Constants for hardcoded values
    private static final String EXPIRED_ERROR_MESSAGE = 'Link expired, please contact administration.';
    private static final String NO_USER_MESSAGE = 'No user';
    private static final String NO_PERSON_ACCOUNT_MESSAGE = 'No contact found';
    private static final String PIASKY_PORTAL_PROFILE = 'PiaSky Portal Profile';
    private static final String PIASKY_LOGIN_START_PATH = '/s/remsverification';
    private static final String TIME_ZONE_SID_KEY = 'America/Mexico_City';
    private static final String LOCALE_SID_KEY = 'en_US';
    private static final String EMAIL_ENCODING_KEY = 'UTF-8';
    private static final String STRING_READ = 'Read';
    private static final String STRING_EDIT = 'Edit';
    private static final String STRING_MANUAL = 'Manual';
    private static final String PIASKY_PERMISSIONSET = 'PIASKY_Portal_PermissionSet';

    /**
     * Retrieves the active user by email.
     * @param email The email address to search for.
     * @return A message indicating the status of the user search.
     */
    @AuraEnabled(cacheable=true)
    public static String getActiveUserByEmail(String email) {
        try {
            // Query to find person account by email
            List<Account> personAccountList = [
                SELECT Id, Name, PersonEmail
                FROM Account
                WHERE IsPersonAccount = true AND (PersonEmail = :email OR US_WSREMS__Email__c = :email) AND Program_Name__c =: Label.PiaSky_REMS_Program_Name
            ];

            // If no person account is found, return the corresponding message
            if (personAccountList.isEmpty()) {
                return NO_PERSON_ACCOUNT_MESSAGE;
            } else {
                // Query to find active user by email
                List<User> existingUser = [
                    SELECT Id, Name, Email, IsActive
                    FROM User
                    WHERE Email = :email AND IsActive = true AND Program__c =: Label.PiaSky_REMS_Program_Name
                    LIMIT 1
                ];
                // If an active user is found, return the corresponding message
                if (!existingUser.isEmpty()) {
                    return EXPIRED_ERROR_MESSAGE;
                } else {
                    return NO_USER_MESSAGE;
                }
            }
        } catch (Exception e) {
            // Handle exception and throw AuraHandledException with the error message
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Creates a community user.
     * @param contactEmail The email of the contact.
     * @param pwd The password for the new user.
     * @return The URL to redirect to or the userId.
     */
    @AuraEnabled
    public static String createCommunityUser(String contactEmail, String pwd) { 
        try {
            List<User> communityuserlist = new List<User>();
            Id userId = null;
            User communityuser = new User();

            // Query to get profile ID
            ID ProfileId = [SELECT Id, Name, UserType FROM Profile WHERE Name = :PIASKY_PORTAL_PROFILE LIMIT 1].Id;

            // Query to get contact by email
            Contact con = [SELECT Id, FirstName, LastName, Account.Email_address__c, Account.US_WSREMS__Email__c, AccountId, Account.US_WSREMS__REMS_Program__c, Account.US_WSREMS__REMS_Program__r.Name,Account.US_WSREMS__Recordtype_Label__c, Account.US_WSREMS__REMS_Program__r.REMS_Project_Code__c 
                           FROM Contact 
                           WHERE (Email = :contactEmail OR Account.US_WSREMS__Email__c = :contactEmail) AND Account.Program_Name__c =: Label.PiaSky_REMS_Program_Name LIMIT 1];

             //Query to get certified Pharmacy Stakeholder
             US_WSREMS__Affiliation__c affPharmacyInfo = [SELECT Id,US_WSREMS__Pharmacy__c, US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__r.US_WSREMS__Recordtype_Label__c 
                                                          FROM US_WSREMS__Affiliation__c 
                                                          WHERE US_WSREMS__Pharmacy_User__c = : con.AccountId LIMIT 1];              

            // Determine email address to use
            String email;
            if (con.Account.Email_address__c != null) {
                email = con.Account.Email_address__c;
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
            string role = affPharmacyInfo.US_WSREMS__Pharmacy__r.US_WSREMS__Recordtype_Label__c;

            // Set community user properties
            communityuser.UserName = contactEmail+'.'+con.Account.US_WSREMS__REMS_Program__r.REMS_Project_Code__c+role.substring(0,2);
            communityuser.FirstName = con.FirstName;
            communityuser.LastName = con.LastName;                    
            communityuser.alias = customalias.trim();
            communityuser.Email = email;
            communityuser.CommunityNickname = nickname + System.now().millisecond();
            communityuser.ProfileId = ProfileId;
            communityuser.TimeZoneSidKey = TIME_ZONE_SID_KEY; 
            communityuser.LocaleSidKey = LOCALE_SID_KEY;
            communityuser.EmailEncodingKey = EMAIL_ENCODING_KEY; 
            communityuser.LanguageLocaleKey = LOCALE_SID_KEY;
            communityuser.IsActive = true;
            communityuser.ContactId = con.Id;
            communityuser.Program__c = con.Account.US_WSREMS__REMS_Program__r.Name;
            communityuser.US_WSREMS__REMS_Program__c = con.Account.US_WSREMS__REMS_Program__r.Name;
            communityuser.Role__c = role;


            // Validate and create the external user
            if(!Test.isRunningTest()) { 
                Site.validatePassword(communityuser, pwd.trim(), pwd.trim());
            }
            userId = Site.createExternalUser(communityuser, con.AccountId, pwd.trim());

            // If user is created successfully, set sharing permissions and login
            if (userId != null) {
                ManagerAccountSharingPermission(userId, con.AccountId);
                ManagerProgramSharingPermission(userId, con.Account.US_WSREMS__REMS_Program__c);
                assignPermissionSetToUser(userId, PIASKY_PERMISSIONSET);
                ApexPages.PageReference lgn = Site.login(communityuser.UserName, pwd.trim(), Site.getBaseUrl() + PIASKY_LOGIN_START_PATH);
                return (lgn != null) ? lgn.getUrl() : null;
            }
            return userId;

        } catch (Exception e) {
            // Handle exception and throw AuraHandledException with the error message
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Manages sharing permission for the given account.
     * @param userId The user ID.
     * @param AccountId The account ID.
     */
    public static void ManagerAccountSharingPermission(String userId, Id AccountId) {
        AccountShare provAcctShare = new AccountShare();
        provAcctShare.AccountId = AccountId;
        provAcctShare.UserOrGroupId = userId;
        provAcctShare.AccountAccessLevel = STRING_EDIT;
        provAcctShare.OpportunityAccessLevel = STRING_READ;
        provAcctShare.CaseAccessLevel = STRING_EDIT;
        provAcctShare.RowCause = STRING_MANUAL;
        try {
            insert provAcctShare;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Manages sharing permission for the given program.
     * @param userId The user ID.
     * @param programId The program ID.
     */
    public static void ManagerProgramSharingPermission(String userId, Id programId) {
        US_WSREMS__REMS_Program__Share progShare = new US_WSREMS__REMS_Program__Share();
        progShare.UserOrGroupId = userId;
        progShare.ParentId = programId;
        progShare.AccessLevel = STRING_READ;
        progShare.RowCause = STRING_MANUAL;
        try {
            insert progShare;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Assigns a specified permission set to a user.
     *
     * @param userId The Id of the user to whom the permission set will be assigned.
     * @param permissionSetApiName The API name of the permission set to be assigned.
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
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = userId;
            psa.PermissionSetId = permissionSetId;

            // Insert the PermissionSetAssignment
            insert psa;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}