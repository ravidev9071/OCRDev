public without sharing class xiaflexCustomPortalController {
    // Constants for hardcoded values
    private static final String EXPIRED_ERROR_MESSAGE = 'Link expired, please contact administration.';
    private static final String NO_USER_MESSAGE = 'No user';
    private static final String NO_PERSON_ACCOUNT_MESSAGE = 'No contact found';
    private static final String PIASKY_PORTAL_PROFILE = 'PiaSky Portal Profile';
    private static final String XIAFLEX_LOGIN_START_PATH_PR = '/s/review-material';
    private static final String XIAFLEX_LOGIN_START_PATH_AR = '/s/manage-hcs';
    private static final String XIAFLEXMDP_LOGIN_START_PATH_PR = '/s/hcp-managehcs';
    private static final String XIAFLEXMDP_LOGIN_START_PATH_AR = '/s/manage-hcs';
    private static final String TIME_ZONE_SID_KEY = 'America/Mexico_City';
    private static final String LOCALE_SID_KEY = 'en_US';
    private static final String EMAIL_ENCODING_KEY = 'UTF-8';
    private static final String STRING_READ = 'Read';
    private static final String STRING_EDIT = 'Edit';
    private static final String STRING_MANUAL = 'Manual';
    private static final String programName = label.Xiaflex_REMS_Program_Name;
    private static final String remsPermissionSet = 'Xiaflex_Portal_REMS_PermissionSet';
    private static final String mdpPermissionSet = 'Xiaflex_Portal_MDP_PermissionSet';
    /**
     * Retrieves the active user by email.
     * @param email The email address to search for.
     * @return A message indicating the status of the user search.
     */
    @AuraEnabled(cacheable=true)
    public static String getActiveUserByEmail(String email,string persona) {
        try {
            // Query to find person account by email
            List<Account> personAccountList = [
                SELECT Id, Name, PersonEmail
                FROM Account
                WHERE IsPersonAccount = true AND (PersonEmail = :email OR US_WSREMS__Email__c = :email) AND Program_Name__c =: programName
            ];

            // If no person account is found, return the corresponding message
            if (personAccountList.isEmpty()) {
                return NO_PERSON_ACCOUNT_MESSAGE;
            } else {
                // Query to find active user by email
                List<User> existingUser = [
                    SELECT Id, Name, Email,username, IsActive
                    FROM User
                    WHERE Email = :email AND IsActive = true AND Program__c =: Label.Xiaflex_REMS_Program_Name
                    LIMIT 1
                ];
                // If an active user is found, return the corresponding message
                if (!existingUser.isEmpty() && existingUser[0].username.endsWithIgnoreCase(persona)) {
                    return EXPIRED_ERROR_MESSAGE;
                } else {
                    return NO_USER_MESSAGE;
                }
            }
        } catch (Exception e) {
            // Handle exception and throw AuraHandledException with the error message
            System.debug('An Exception Occured ::'+e.getMessage());
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
    public static String createCommunityUser(String contactEmail, String pwd,String persona,String programType,String profileName) { 
            List<User> communityuserlist = new List<User>();
            Id userId = null;
            User communityuser = new User();
            String ProfileIdx;
            ID ProfileId = [SELECT Id, Name, UserType FROM Profile WHERE Name =: profileName LIMIT 1].Id;
            String Recordtypevalue = '';
            if(persona == 'PR' || persona == 'PRMDP'){
                Recordtypevalue = 'Prescriber';
            }else if(persona == 'AR' || persona == 'ARMDP'){
                        Recordtypevalue = 'Pharmacy_Participant';
            }
            Account Acc = [SELECT Id, FirstName,ownerid,PersonContactId, LastName, PersonEmail, US_WSREMS__REMS_Program__c, US_WSREMS__REMS_Program__r.Name,US_WSREMS__Recordtype_Label__c, US_WSREMS__REMS_Program__r.REMS_Project_Code__c 
                           FROM account 
                           WHERE PersonEmail = :contactEmail   AND Program_Name__c =: 'Xiaflex' AND US_WSREMS__Program_Type__c =:programType and recordtype.developername =: Recordtypevalue LIMIT 1];
            String email;
            if (Acc.PersonEmail != null) {
                email = Acc.PersonEmail;
            }
            String customalias;
            if (Acc.LastName.length() < 9) {
                customalias = Acc.LastName;   
            } else {
                customalias = Acc.LastName.left(7);
            }
            String nickname;
            if (Acc.LastName.length() < 40) {
                nickname = Acc.LastName;   
            } else {
                nickname = Acc.LastName.left(39);
            }
            string role = Acc.US_WSREMS__Recordtype_Label__c;
            // Set community user properties
            communityuser.UserName = contactEmail+'.'+Acc.US_WSREMS__REMS_Program__r.REMS_Project_Code__c+'.'+persona;
            communityuser.FirstName = Acc.FirstName;
            communityuser.LastName = Acc.LastName;                    
            communityuser.alias = customalias;
            communityuser.Email = email;
            communityuser.CommunityNickname = nickname + System.now().millisecond();
            communityuser.ProfileId = ProfileId;
            communityuser.TimeZoneSidKey = TIME_ZONE_SID_KEY; 
            communityuser.LocaleSidKey = LOCALE_SID_KEY;
            communityuser.EmailEncodingKey = EMAIL_ENCODING_KEY; 
            communityuser.LanguageLocaleKey = LOCALE_SID_KEY;
            communityuser.IsActive = true;
            communityuser.ContactId = Acc.PersonContactId;
            communityuser.Program__c = Acc.US_WSREMS__REMS_Program__r.Name;
            communityuser.US_WSREMS__REMS_Program__c = Acc.US_WSREMS__REMS_Program__r.Name;
            if(!Test.isRunningTest()) { 
                Site.validatePassword(communityuser, pwd.trim(), pwd.trim());
            }
            userId = Site.createExternalUser(communityuser, Acc.id, pwd.trim());
            if (userId != null) {
                ManagerProgramSharingPermission(userId, Acc.US_WSREMS__REMS_Program__c);
                assignPermissionSetToUser(userId,programType);
                if(persona == 'PR'){
                ApexPages.PageReference lgn = Site.login(communityuser.UserName, pwd.trim(), Site.getBaseUrl() + XIAFLEX_LOGIN_START_PATH_PR);
                                return (lgn != null) ? lgn.getUrl() : null;

                }else if(persona == 'AR'){
                ApexPages.PageReference lgn = Site.login(communityuser.UserName, pwd.trim(), Site.getBaseUrl() + XIAFLEX_LOGIN_START_PATH_AR);
                                return (lgn != null) ? lgn.getUrl() : null;

                }
                if(persona == 'PRMDP'){
                ApexPages.PageReference lgn = Site.login(communityuser.UserName, pwd.trim(), Site.getBaseUrl() + XIAFLEXMDP_LOGIN_START_PATH_PR);
                                return (lgn != null) ? lgn.getUrl() : null;

                }else if(persona == 'ARMDP'){
                ApexPages.PageReference lgn = Site.login(communityuser.UserName, pwd.trim(), Site.getBaseUrl() + XIAFLEXMDP_LOGIN_START_PATH_AR);
                                return (lgn != null) ? lgn.getUrl() : null;

                }
            }
            return userId;
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
        insert provAcctShare;
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
        insert progShare;
    }

    /**
     * Assigns a specified permission set to a user.
     *
     * @param userId The Id of the user to whom the permission set will be assigned.
     * @param permissionSetApiName The API name of the permission set to be assigned.
     */
    @future
    public static void assignPermissionSetToUser(Id userId, String programType) {
        try {
            // Query the Permission Set Id using the API name
            string permissionsetName = '';
            if(programType == 'REMS'){
                permissionsetName =  remsPermissionSet;
            }else{
                permissionsetName =  mdpPermissionSet;
            }
            PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = :permissionsetName LIMIT 1];
            if (permSet == null) {
                return;
            }
            Id permissionSetId = permSet.Id;
            // Create the PermissionSetAssignment object
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = userId;
            psa.PermissionSetId = permissionSetId;
            insert psa;
        } catch (Exception e) {
            System.debug('An Exception Occured ::'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }  
}