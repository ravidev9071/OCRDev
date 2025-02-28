/**
* @File Name          : SYN_AccountTriggerHandler.cls
* @Description        : This is used as a Hanlder for Account trigger.
* @Trigger            : SYN_AccountTrigger
* @TestClass          : SYN_AccountTriggerHandler_Test
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 1.0    02/22/2022        Chaitanya Nandamuri (Wilco)     createRemsService BT6825-147: creation of REMSservice for the Account
* 2.0    05/17/2022        Ismail Shaik (Wilco)            Validation Rule (BT6825-91: Validation Rule for Patient Enrollment form)
* 3.0    07/06/2022        Aneesha Shaik (Wilco)           updatedEnrolledDate(BT6825--379 Participant Date Enrolled)
* 4.0    02/01/2023        Ashish Y [Wilco]                updateMonitored(BT6825-750 Update field should be patient be monitored)
*5.0     07/03/2023        Akilandeswari [Wilco]            Create the portal user and activate the user based on conditions [[BT6825-878] ]
*6.0     09/13/2023        Dileep Gurram [Wilco]            Replaced Schema.Sobject syntax by using methods in REMSUtility apex class based on the scenario.
**/
public class SYN_AccountTriggerHandler {
    private
        static final  Map<String,Id> mapAccRecordTypesById = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account');
    private
        static final  Map<String,Id> mapCaseRecordTypesById = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');  
    private
        static final   Map<Id,String> mapRecordTypesById = REMSUtility.retrieveRecTypeIdDeveloperName_Product('Account');
    private
        static final Map<String, Schema.RecordTypeInfo> mapCaseRCtyByDeveloperName =
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    
    Public static string REMS_RECTYPE_ParticipantAccCreation = 'Participant_Account_Creation';
    Public static string REMS_RECTYPE_Pharmacy_Participant = 'Pharmacy_Participant';
    Public static string Account_RECTYPE = 'Office_Contact';
    public static Boolean Stop_Account_Service_triggerCreation;
    
    public static void setPortalAccount(List<Account> accountList){
        for(Account acc: accountList){
            if(acc.US_WSREMS__Channel__c == 'Portal'){
                acc.US_WSREMS__Status__c = 'Initiated';
                if(acc.US_WSREMS__NPI__c != null){
                    acc.SYN_NPI_Validation_Status__c = 'Active';
                }
            }
        }
    }
    //BT6825-832
    public static void emailDuplicateCheck(Map<id, Account> oldMap, List<Account> newAccList){
        if(SYN_CaseTriggerHanlder.stopAccUpdate == false){
        Id presAccountRecTypeId =  mapAccRecordTypesById.get('Prescriber');
        id pharmPartiAccRecTypeId = mapAccRecordTypesById.get('Pharmacy_Participant');
        Set<ID> acctRecordtypeIds = new Set<ID>{presAccountRecTypeId,pharmPartiAccRecTypeId};
            set<String> prescriberEmailSet = new set<String>();
            set<String> pharmPartiEmailSet = new set<String>();
            List<Account> AllEmailAccountsList = new List<Account>();
        List<Account>filteredAccList = new List<Account>();
        for(Account acc :newAccList){
            if((acc.RecordTypeId == presAccountRecTypeId || acc.RecordTypeId == pharmPartiAccRecTypeId) && ((oldMap != null && !String.isBlank(acc.US_WSREMS__Email__c) && oldMap.get(acc.Id).US_WSREMS__Email__c != acc.US_WSREMS__Email__c) ||( oldMap == null && acc.US_WSREMS__Email__c != null))){
                filteredAccList.add(acc);
            }

        }
        if(!filteredAccList.isEmpty()){
            AllEmailAccountsList = [select Id, RecordTypeId, US_WSREMS__Email__c, Program_Name__c FROM Account WHERE RecordTypeId IN:acctRecordtypeIds AND Program_Name__c = :Label.Sodium_Oxybate_REMS_Program_Name];
        }
        for(Account A :AllEmailAccountsList){
            if(A.RecordTypeId == presAccountRecTypeId){
               prescriberEmailSet.add(A.US_WSREMS__Email__c);
            }
            if(A.RecordTypeId == pharmPartiAccRecTypeId){
               pharmPartiEmailSet.add(A.US_WSREMS__Email__c);
            }
        }

        for(Account accRec :filteredAccList){
            if(accRec.RecordTypeId == presAccountRecTypeId &&  prescriberEmailSet.contains(accRec.US_WSREMS__Email__c)){
                accRec.addError('This account request cannot be processed because there is an existing account with the same email address.');
            }

            if(accRec.RecordTypeId == pharmPartiAccRecTypeId &&  pharmPartiEmailSet.contains(accRec.US_WSREMS__Email__c)){
                accRec.addError('This account request cannot be processed because there is an existing account with the same email address.');
            }
        }
        }


    }//BT6825-832

    //BT6825-465
    public static void updatePortalSharingAcctfield(List<Account> accountList){
        SYN_CommonUtility.portalSharingData portalSharingInformation = SYN_CommonUtility.portalSharingInfo();
        Map<string, Account> accountNameAndRecMap = portalSharingInformation.accNameAndRecordMap;
        Map<String, String> programNameAndAccountMap = portalSharingInformation.ProgramNameAndAccMap;
        if(!accountNameAndRecMap.isEmpty()){
            for(Account accRec : accountList){  
                if(String.isNotBlank(accRec.Program_Name__c)){     
                    String portAccName = '';
                    String accountId = '';
                    if(programNameAndAccountMap.containsKey(accRec.Program_Name__c)){
                        
                        portAccName = programNameAndAccountMap.get(accRec.Program_Name__c);
                        
                        if(accountNameAndRecMap.containsKey(portAccName)){
                            
                            accountId = accountNameAndRecMap.get(portAccName).Id;
                        }
                    }
                    
                    if(String.isNotBlank(accountId)){
                        accRec.Portal_Sharing_Account__c = accountId;
                    }
                    else{
                        accRec.Portal_Sharing_Account__c = Null;
                    }
                }
            }
        }
    }
    //BT6825-465
    
    
    
    //BT6825 - 108
    public static void createPortalUsers(List<Account> accountList){
        Set<Id> accIds = New Set<Id>();
        for(Account acc: accountList){
            if(acc.US_WSREMS__Channel__c == 'Portal' && acc.Program_Name__c != Label.Macitentan_REMS_Program_Name){
                accIds.add(acc.Id);  
            }
        }
        if(accIds.size()>0 && System.isFuture() == false){
            //create community user....
            createCommunityUser(accIds);
        }
        
    }
    //BT6825 - 108
    @future
    public static void createCommunityUser(Set<Id> accIds){
        
        List<User> communityuserlist = New List<User>();
        Map<String,Portal_Configuration__mdt> portalConfigMap =new Map<String,Portal_Configuration__mdt>();
        Map<String,PermissionSet> permissionSetMap =new Map<String,PermissionSet>();
        Map<Id,String> accountTypeMap =new Map<Id,String>();
        List<PermissionSetAssignment> permissionSetAssList =new List<PermissionSetAssignment>();
        List<Account> insertedAccountsList = [SELECT Id,PersonContactId,Name,FirstName,LastName,US_WSREMS__Email__c,Phone,US_WSREMS__REMS_Program__r.Name,RecordType.Name FROM Account Where ID IN:accIds ];
        List<Portal_Configuration__mdt> portalConfig = [SELECT Permission_Sets__c,Program_Configuration__r.Label,Program_Configuration__r.developerName,Username_Suffix__c,Portal_Type__c FROM Portal_Configuration__mdt  ]; 
        List<PermissionSet> permList = [Select Id,Name,Label from PermissionSet ];
        for(PermissionSet permSet:permList){
            permissionSetMap.put(permSet.Label,permSet);  
        }
        for(Portal_Configuration__mdt portalConfigmdt : portalConfig){
            String keystr=portalConfigmdt.Program_Configuration__r.Label+portalConfigmdt.Portal_Type__c;
            portalConfigMap.put(keystr,portalConfigmdt);
        }
        
        if(insertedAccountsList.size()>0){
            for(Account acc: insertedAccountsList){
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.EmailHeader.triggerUserEmail = true;
                String Key =acc.US_WSREMS__REMS_Program__r.Name+acc.RecordType.Name;
                String customalias;
                if(acc.Lastname.length()<9){
                    customalias= acc.Lastname;   
                }
                else{
                    customalias= acc.Lastname.left(7).substring(0, 7); 
                } 
                String nickname;
                
                if(acc.Lastname.length()<40){
                    nickname= acc.Lastname;   
                }else{
                    nickname= acc.Lastname.left(39).substring(0, 39); 
                }
                
                //Create Community User
                User communityuser = New User();
                communityuser.UserName = acc.US_WSREMS__Email__c +''+(portalConfigMap.get(Key) != null ? (portalConfigMap.get(Key)).Username_Suffix__c  : '.sox') ;
                communityuser.FirstName = acc.Firstname;
                communityuser.LastName = acc.Lastname;
                    communityuser.alias = customalias.trim();
                communityuser.email = acc.US_WSREMS__Email__c;
                communityuser.Phone= acc.Phone;
                communityuser.CommunityNickName = nickname+System.now().millisecond();
                communityuser.ProfileID = Label.PortalProfile;
                communityuser.TimeZoneSidKey = 'America/Mexico_City'; 
                communityuser.LocaleSidKey = 'en_US';
                communityuser.EmailEncodingKey = 'UTF-8'; 
                communityuser.LanguageLocaleKey = 'en_US';
                communityuser.isActive = true;
                communityuser.Program__c=Label.Sodium_Oxybate_REMS_Program_Name;
                communityuser.ContactId = acc.PersonContactId;
                if(portalConfigMap.get(Key)!=null){
                    accountTypeMap.put( acc.PersonContactId,(portalConfigMap.get(Key)).Permission_Sets__c);
                }
                //Add records to the list to insert into the database....
                communityuser.setOptions(dmo);
                communityuserlist.add(communityuser);
            }
            List<Id> userIds=new List<Id>();
            Database.SaveResult[] insertedUserRecList = Database.Insert(communityuserlist, false);
            for (Database.SaveResult cs : insertedUserRecList) {
                if (cs.isSuccess()) {
                    userIds.add(cs.getId());
                }else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : cs.getErrors()) {
                        system.debug('error+++');
                    }
                }
            } // end for loop
                if(userIds!=null && !userIds.isEmpty()){
                    List<User> user_list =[select id,ContactId from user where id IN :userIds];
                    for(User userObj :user_list){
                        if(accountTypeMap.get(userObj.ContactId) != null){
                        PermissionSetAssignment psAssignmentObj = new PermissionSetAssignment(PermissionSetId =  permissionSetMap.get(accountTypeMap.get(userObj.ContactId)).Id, AssigneeId =userObj.Id );
                        permissionSetAssList.add(psAssignmentObj);  
                        }
                        
                    }
                }
                if(permissionSetAssList!=null && !permissionSetAssList.isEmpty()){
                    insert permissionSetAssList; 
                }
                
            
        }
        
    }
    
    public static void createRemsService(List<Account> accountList){
        if(Test.isRunningTest()){
            Stop_Account_Service_triggerCreation=false;
        }
        
        List<US_WSREMS__REMS_Service_Summary__c > ParEnrollRemsLst = new List<US_WSREMS__REMS_Service_Summary__c >();
        set<string> accRectypeStr_mdt ;
        Map<Id,Id> ParticiIdTORemsIdMap = new map<Id,Id>();
        Map<String,SYN_ParticipantAccountCreation__mdt > RCtypeToReqStrMap = SYN_ParticipantAccountCreation__mdt.getall();
        Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.ACCOUNT_OBJECT);
        Map<String,Id> serviceRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c');
     
        Id ParticipantEnrollment_RCtyId = serviceRecordTypeMap.get(REMS_RECTYPE_ParticipantAccCreation);
        Id recordTypeIdOc  = caseRecordTypeMap.get('Office_Contact');

        accRectypeStr_mdt = SYN_ParticipantAccountCreation__mdt.getall().keyset();
        
        for(Account acc : accountList){
            if(acc.US_WSREMS__Channel__c == 'Portal' && acc.RecordTypeId == recordTypeIdOc){
                break;
            }
            string RCtyDevNameStr = mapRecordTypesById.get(acc.RecordTypeId);
            // Create RemsService for only account Recordtypes defined in the Custom Metadata. 
            if (!RCtypeToReqStrMap.keyset().contains(RCtyDevNameStr) || RCtyDevNameStr =='Pharmacy_User' ){
                continue;
            }
            
            US_WSREMS__REMS_Service_Summary__c rss = new US_WSREMS__REMS_Service_Summary__c();
            rss.RecordTypeId =  ParticipantEnrollment_RCtyId;
            rss.US_WSREMS__Participant__c  = acc.id;
            if(acc.US_WSREMS__Channel__c == 'Portal' && acc.Program_Name__c == 'Macitentan REMS'){
                rss.US_WSREMS__StageName__c = 'Closed';
                rss.US_WSREMS__Path_Stage_Name__c = 'Closed';
                rss.US_WSREMS__Status__c = 'closed';
                 rss.US_WSREMS__Service_Outcome__c ='Successful';//BT7433 - 1021
                rss.US_WSREMS__Path_Complete__c = true;
            }else{
            //BT7433 - 1021
                if(acc.Program_Name__c == 'Macitentan REMS')
                {
                 rss.US_WSREMS__Status__c = 'Open';
                 rss.US_WSREMS__Service_Outcome__c ='Successful';   
                }
                rss.US_WSREMS__StageName__c = SYN_Utilitycls.pickListVal_close;
                rss.US_WSREMS__Path_Stage_Name__c = SYN_Utilitycls.pickListVal_close;
                rss.US_WSREMS__Path_Complete__c = true;
            }
            rss.US_WSREMS__Requestor_Type__c = RCtypeToReqStrMap.get(RCtyDevNameStr).RequestorType__c; //String.valueOf(mapRecordTypesById.get(acc.RecordTypeId).getName());
            rss.US_WSREMS__REMSProgram__c   = acc.US_WSREMS__REMS_Program__c;
            ParEnrollRemsLst.add(rss);
            
        }

        try{
            Insert ParEnrollRemsLst;
        }catch(exception e){

        }
        
        if (!RemsPagelayoutComponent.caseStatusComplete){
            return;
        }
        for (US_WSREMS__REMS_Service_Summary__c rss: ParEnrollRemsLst){
            if(rss.US_WSREMS__Participant__r.US_WSREMS__Channel__c == 'Portal' && rss.US_WSREMS__Participant__r.Program_Name__c == 'Macitentan REMS'){
                rss.US_WSREMS__Path_Stage_Name__c  = 'Closed';
                rss.US_WSREMS__StageName__c='Closed';
                rss.US_WSREMS__Status__c = 'closed';
                rss.US_WSREMS__Service_Outcome__c ='Successful';
                rss.US_WSREMS__Path_Complete__c = true;
            }else{
                rss.US_WSREMS__Path_Stage_Name__c  = 'closed';
                rss.US_WSREMS__Status__c = 'closed';
                rss.US_WSREMS__Service_Outcome__c ='Successful';
                rss.US_WSREMS__Path_Complete__c = true;
            }
        }
        update ParEnrollRemsLst;
      
    }
    
    //BT6825--379 Participant Date Enrolled
    public static void updatedEnrolledDate(List<Account> accountsList) {

        Id patientRecordtypeId = mapAccRecordTypesById.get('Patient');
        Id prescriberRecordtypeId =  mapAccRecordTypesById.get('Prescriber');
        Id DistributorRecordtypeId = mapAccRecordTypesById.get('REMS_Distributor_Account');
        Id PharmacyParticipantRecordtypeId =mapAccRecordTypesById.get('Pharmacy Participant');
        Id PharmacyRecordtypeId =mapAccRecordTypesById.get('Pharmacy');
        Id outpatientPharmacyRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(REMSAppLiterals.ACCOUNT_RECORDTYPE_OUTPATIENTPHARMACY).getRecordTypeId();
        Id InpatientPharmacyRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(REMSAppLiterals.ACCOUNT_RECORDTYPE_INPATIENTPHARMACY).getRecordTypeId();
      
       
            for(Account acc : accountsList) {
                if(acc.RecordTypeId == patientRecordtypeId && acc.US_WSREMS__Status__c == 'Enrolled' && acc.Date_Enrolled__c == null) {
                    acc.Date_Enrolled__c = system.today();
                }
                if((acc.RecordTypeId == DistributorRecordtypeId  || acc.RecordTypeId == prescriberRecordtypeId || acc.RecordTypeId == PharmacyRecordtypeId || acc.RecordTypeId == outpatientPharmacyRecordtypeId || acc.RecordTypeId == InpatientPharmacyRecordtypeId  ) && (acc.Date_Enrolled__c == null && acc.US_WSREMS__Status__c == 'Certified')) {
                    acc.Date_Enrolled__c = System.today();
                }
                 
                if(acc.RecordTypeId == PharmacyParticipantRecordtypeId && acc.US_WSREMS__Status__c == 'Active'  && acc.Date_Enrolled__c == null)  {
                    acc.Date_Enrolled__c = system.today();
                }
                
                if(acc.Program__c == 'Macitentan REMS' && (acc.US_WSREMS__Status__c == 'Enrolled' || acc.US_WSREMS__Status__c == 'Certified' || acc.US_WSREMS__Status__c == 'Active') && acc.Sub_Status__c != null){
                    acc.Sub_Status__c = '';
                }
            }
        
        
    }
    
    
    
    public static void createAffiliation(List<Account> accountList){
    
    }
    
    /* BT6825-750 : This method will update field on account 
Created by : Ashish Y [Wilco]
*/
    
    public static void updateMonitored(List<Account> accDetails){
        
        Id patientRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        List<Account> updateAcc = new List<Account>();
        For(Account accRec: accDetails){
            
           if(accRec.Monitor_Participant__c == true && accRec.RecordTypeId == patientRecordtypeId){
                
                accRec.SYN_Should_patient_be_monitored__c = 'Yes';
            }else {
                
                accRec.SYN_Should_patient_be_monitored__c = 'No';
            }
            
        }//End of For Loop
        
    }//end of updateMonitored
    
    //827 Story UpdatePortalUser
    public static void updatePortalUser(List<Account> newAccList, Map<Id,Account> oldAccMap) {
        Id prescriberRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Id pharmacyParticipantRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        Set<Id> accIdsSet = new Set<Id>();
        for(Account acc : newAccList) {
            if((acc.US_WSREMS__Email__c != oldAccMap.get(acc.Id).US_WSREMS__Email__c || acc.Two_Factor_Authentication_Selection__c != oldAccMap.get(acc.Id).Two_Factor_Authentication_Selection__c) 
                    && (acc.RecordTypeId == prescriberRecordtypeId  || acc.recordTypeId == pharmacyParticipantRecordtypeId) ) {
                accIdsSet.add(acc.Id);
            }
        }
        if(accIdsSet.size() > 0) {
            updateuser(JSON.serialize(accIdsSet));
        }
    }
    
    @future
    public static void updateuser(String accIds) {
        Id prescriberRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Id pharmacyParticipantRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();

        Map<String,Portal_Configuration__mdt> portalConfigMap =new Map<String,Portal_Configuration__mdt>();
        Map<Id,User> portalUsersMap = new Map<Id,User>();
        Set<Id> accIdsSet = new Set<Id>();
        List<Account> insertedAccountsList;
        accIdsSet = (Set<Id>)JSON.deserialize(accIds, Set<Id>.class);
        List<Portal_Configuration__mdt> portalConfig = [SELECT Permission_Sets__c,Program_Configuration__r.Label,Program_Configuration__r.developerName,Username_Suffix__c,Portal_Type__c FROM Portal_Configuration__mdt ];
        for(Portal_Configuration__mdt portalConfigmdt : portalConfig){
            String keystr=portalConfigmdt.Program_Configuration__r.Label+portalConfigmdt.Portal_Type__c;
            portalConfigMap.put(keystr,portalConfigmdt);
        }
        
        if(!accIdsSet.isEmpty()) {
        
            for(User userRec :  [Select Id,UserName,Email,Contact.AccountId,isPortalEnabled,Two_Factor_Authentication_Selection__c FROM User WHERE Contact.AccountId IN: accIdsSet ] ) {
                
                portalUsersMap.put(userRec.Contact.AccountId, userRec);
            }
            insertedAccountsList= [SELECT Id,PersonContactId,Name,FirstName,LastName,US_WSREMS__Email__c,Email_address__c,Phone,US_WSREMS__REMS_Program__r.Name,RecordTypeId,RecordType.Name,Two_Factor_Authentication_Selection__c FROM Account Where ID IN:accIdsSet ];
        }
        List<User> portalUsersListtoUpdate = new List<User>();
        for(Account acc : insertedAccountsList) {
            
            if(portalUsersMap.containsKey(acc.Id)){
                user userRec = new user();
                userRec.Id = portalUsersMap.get(acc.Id).Id;
                if(acc.recordTypeId == pharmacyParticipantRecordtypeId && acc.US_WSREMS__Email__c != null && portalUsersMap.get(acc.Id).Email != acc.US_WSREMS__Email__c){
                    userRec.Email = acc.US_WSREMS__Email__c; 
                }else if(acc.recordTypeId == prescriberRecordtypeId && acc.Email_address__c != null && portalUsersMap.get(acc.Id).Email != acc.Email_address__c){
                    userRec.Email = acc.Email_address__c; 
                }
                if(portalUsersMap.get(acc.Id).Two_Factor_Authentication_Selection__c != acc.Two_Factor_Authentication_Selection__c){
                    userRec.Two_Factor_Authentication_Selection__c = acc.Two_Factor_Authentication_Selection__c; 
                }
                portalUsersListtoUpdate.add(userRec);
            }
        }
        
        if(!portalUsersListtoUpdate.isEmpty()) {
        
            update portalUsersListtoUpdate;
        }
    }
    
   //BT6825-849
    public static void portalUserCreation(List<Account> accountList) {
        
        Set<Id> accoundIdSet = new Set<Id>();
        Set<String> emailSet = new Set<String>();
        Id prescriberRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Id PharmacyParticipantRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        
        for(Account accountIns: accountList){
            if(accountIns.Program_Name__c == Label.Sodium_Oxybate_REMS_Program_Name && ((accountIns.US_WSREMS__Status__c == 'Certified' && accountIns.RecordTypeId == prescriberRecordtypeId)||(accountIns.RecordTypeId == PharmacyParticipantRecordtypeId && accountIns.US_WSREMS__Status__c == 'Active'))){
                accoundIdSet.add(accountIns.Id);
                if(accountIns.US_WSREMS__Email__c != NULL) {
                    emailSet.add(accountIns.US_WSREMS__Email__c);
                }
            }     
        }
        
        if(accoundIdSet.size()>0 && System.isFuture() == false && test.isrunningtest() == FALSE){
            createPoratlUserCreation(accoundIdSet,emailSet);
        } 
        
    }
    
    
    @future
    public static void createPoratlUserCreation(Set<Id> accoundIdSet, Set<String> emailSet){
        Map<Id, User> userAccountMap = new Map<Id, User>();
        Map<String, User> userEmailMap = new Map<String, User>();
        List<User> portalUserList = new List<User>();
        Id prescriberRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Id PharmacyParticipantRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
                
        for(User userRec :  [SELECT Id, UserName, Email, Contact.AccountId, isPortalEnabled, isActive 
                             FROM User 
                             WHERE Contact.AccountId IN: accoundIdSet OR Email IN: emailSet]) {
            userAccountMap.put(userRec.Contact.AccountId, userRec);
            userEmailMap.put(userRec.Email, userRec);
                                 
        } 
        List<Profile> profileList = [SELECT Id from Profile 
                                     WHERE Name='SOX Pharmacist' 
                                     OR Name='SOX Prescriber' ORDER BY Name ASC];
        
        for(Account acc:[SELECT Id, US_WSREMS__Status__c, FirstName, LastName, US_WSREMS__Email__c, 
                         PersonContactId,Owner.UserRole.Name, RecordTypeId
                         FROM Account 
                         WHERE Id=:accoundIdSet AND Id NOT IN : userAccountMap.keySet() AND US_WSREMS__Email__c NOT IN : userEmailMap.keySet()]) {  

                

                User userObj = new User(
                    UserName = acc.US_WSREMS__Email__c,
                    FirstName = acc.FirstName,
                    LastName = acc.LastName,
                    ContactId = acc.PersonContactId,
                    Alias = string.valueOf(math.random()).substring(0,6),
                    email = acc.US_WSREMS__Email__c,
                    CommunityNickName = string.valueOf(math.random()).substring(0,6),
                    ProfileID = acc.recordTypeId == prescriberRecordtypeId ?profileList[1].Id:profileList[0].Id,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    Program__c=Label.Sodium_Oxybate_REMS_Program_Name,
                    isActive = true
                );
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.EmailHeader.triggerUserEmail = true;
                userObj.setOptions(dmo);
                portalUserList.add(userObj);
                                 
        }
        if(portalUserList.size() > 0) {
            insert portalUserList;
            List<PermissionSet> permissionSetList = [Select Id,Name from PermissionSet 
                                            WHERE Name='SOX_Pharmacist' OR Name='SOX_Prescriber' ORDER BY Name ASC];
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            for(User userIns : portalUserList) {
                PermissionSetAssignment psAssignmentObj = new PermissionSetAssignment(
                    PermissionSetId = userIns.ProfileId==profileList[0].Id?permissionSetList[0].Id:permissionSetList[1].Id, 
                    AssigneeId = userIns.Id
                );
                permissionSetAssignmentList.add(psAssignmentObj);
            }
            if(permissionSetAssignmentList.size() > 0) {
                insert permissionSetAssignmentList;
            }
        }
    } 
    
    //BT6825-849
    public static void activatePortalUser(List<Account> newAccList, Map<Id,Account> oldAccMap) {
        Set<Id> accountIdSet = new Set<Id>();
        Id prescriberRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Id PharmacyParticipantRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
        
        for(Account accountIns : newAccList) {
            if(accountIns.US_WSREMS__Status__c != oldAccMap.get(accountIns.Id).US_WSREMS__Status__c &&(accountIns.US_WSREMS__Status__c == 'Certified' && oldAccMap.get(accountIns.Id).US_WSREMS__Status__c == 'Disenrolled' && accountIns.RecordTypeId == prescriberRecordtypeId ) || (accountIns.recordTypeId == PharmacyParticipantRecordtypeId && accountIns.US_WSREMS__Status__c == 'Active' && oldAccMap.get(accountIns.Id).US_WSREMS__Status__c == 'Inactive' ) ) {
                accountIdSet.add(accountIns.Id);
            }
        }
        
        if(accountIdSet.size() > 0) {
            activateUser(accountIdSet);
        }     
    }
    
    @future
    public static void activateUser(set<Id> accountIdSet) {
          List<User> portalUsersListToActivate= new List<User>();
        
           if(accountIdSet.size()>0) {
                for(User userRec :  [Select Id, UserName, Email, Contact.AccountId, isPortalEnabled, isActive 
                                     FROM User 
                                     WHERE Contact.AccountId IN: accountIdSet and isActive = FALSE]) { 
                                         
                    userRec.IsActive = TRUE;
                    portalUsersListToActivate.add(userRec);
                } 
           }
            
           if(portalUsersListToActivate.size()>0) {
                update portalUsersListToActivate;
           }
                   
      }
      
      
    /***********************************************************************************************************************************
    MethodName : updatePrescriberHolderAccounts
    Description : Update PrescriberPortal user details when his information is changed at account level
    ************************************************************************************************************************************/
    public static void updatePrescriberHolderAccounts(Map<Id, Account> newAccMap, Map<Id, Account> oldAccMap){
        Map<Id,Account> accountMap = new Map<Id,Account>();
        List<Account> accountList = new List<Account>();
        Id presriberAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Id pharmcyPaticipantAccountRecTypeId = mapAccRecordTypesById.get('Pharmacy_Participant');
        Set<Id> inactiveAccountIds = new Set<id>();
      
        for(Account accRec: newAccMap.values()){
            if(accRec.IsCustomerPortal == true && accRec.RecordTypeId == presriberAccountRecTypeId && accRec.Program_Name__c == Label.Macitentan_REMS_Program_Name && (accRec.FirstName != oldAccMap.get(accRec.Id).FirstName || accRec.MiddleName != oldAccMap.get(accRec.Id).MiddleName || accRec.LastName!= oldAccMap.get(accRec.Id).LastName || accRec.Email_address__c!= oldAccMap.get(accRec.Id).Email_address__c)){
               accountMap.put(accRec.PersonContactId,accRec); 
            }
            if(accRec.OwnerId != oldAccMap.get(accRec.Id).OwnerId){
                accountList.add(accRec);
            }
            
            if(accRec.IsCustomerPortal == true && accRec.RecordTypeId == presriberAccountRecTypeId && accRec.Program_Name__c == Label.Macitentan_REMS_Program_Name && accRec.US_WSREMS__Status__c == 'Disenrolled' && accRec.US_WSREMS__Status__c !=  oldAccMap.get(accRec.Id).US_WSREMS__Status__c ){
                inactiveAccountIds.add(accRec.Id);
            }
            
            if(accRec.IsCustomerPortal == true && accRec.RecordTypeId == pharmcyPaticipantAccountRecTypeId && accRec.Program_Name__c == Label.Macitentan_REMS_Program_Name && (accRec.FirstName != oldAccMap.get(accRec.Id).FirstName || accRec.MiddleName != oldAccMap.get(accRec.Id).MiddleName || accRec.LastName!= oldAccMap.get(accRec.Id).LastName || accRec.US_WSREMS__Email__c!= oldAccMap.get(accRec.Id).US_WSREMS__Email__c)){
               accountMap.put(accRec.PersonContactId,accRec); 
            }
            
        }
        if(accountMap != null ){
            updatePortalUserDetails(accountMap);
        }
        if(!accountList.isEmpty()){
            SYN_SharingUtility.createAccountSharingRecs(accountList);
        }
        
        if(!inactiveAccountIds.isEmpty()){
            SYN_ManagePharamcyController.deactivatePortalUser(inactiveAccountIds);
        }
    
    }
    
    /***********************************************************************************************************************************
    MethodName : updatePortalUserDetails
    Description : update active user details
    ************************************************************************************************************************************/
    public static void updatePortalUserDetails(Map<Id,Account> accountMap){
        List<User> userListToUpdate = new List<User>();
        List<User> userList = [SELECT Id,FirstName, LastName, MiddleName, Email, UserName, ContactId FROM User WHERE ContactId != Null AND IsActive = True AND ContactId IN : accountMap.keySet()];  
   
        if(!userList.isEmpty()){
         Id presriberAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Id pharmcyPaticipantAccountRecTypeId = mapAccRecordTypesById.get('Pharmacy_Participant');
            for(User usr : userList){
                usr.FirstName = accountMap.get(usr.ContactId).FirstName;
                usr.LastName= accountMap.get(usr.ContactId).LastName;
                usr.MiddleName= accountMap.get(usr.ContactId).MiddleName;
                if(accountMap.get(usr.ContactId).RecordTypeId == presriberAccountRecTypeId ){
                usr.Email= accountMap.get(usr.ContactId).Email_address__c;
                }
                if(accountMap.get(usr.ContactId).RecordTypeId == pharmcyPaticipantAccountRecTypeId ){
                    usr.Email= accountMap.get(usr.ContactId).US_WSREMS__Email__c;
                }
                
                userListToUpdate.add(usr);
            }
        }
        if(!userListToUpdate.isEmpty()){
            try{
                update userListToUpdate;
            }catch(exception e){
                System.debug('---Error--'+e.getMessage());
            }
        }
    
    }
    
    /***********************************************************************************************************************************
    MethodName : prepopulateProgram
    Description : prepopulate the program when account is created, by using this field we can create sharing rules based on program.
    ************************************************************************************************************************************/
    public static void prepopulateProgram(List<Account> newAccList){
        Map<Id,String> programMap = SYN_CommonUtility.getActivePrograms();      
        for(Account acc : newAccList){
            if(programMap.containsKey(acc.US_WSREMS__REMS_Program__c)){
                acc.Program__c = programMap.get(acc.US_WSREMS__REMS_Program__c); 
            }
        }
    }
    
     /***********************************************************************************************************************************
    MethodName : Filter Accounts based on Program
    Description : This method will categories all the accounts based on program.
    ************************************************************************************************************************************/
  public static Map<String, Map<Id, List<Account>>> filterAccountsByPrgm(List<Account> newList){

        Map<String, Map<Id, List<Account>>> prgmRTAndAccountMap = new Map<String, Map<Id, List<Account>>>();  
      
        string programName;

        for(Account accRec : newList){

            if(accRec.US_WSREMS__Program_Picklist__c != null){
                programName = accRec.US_WSREMS__Program_Picklist__c;
            }else if(String.isNotBlank(accRec.Program__c)){
                programName = accRec.Program__c;
            }else{
                programName = accRec.US_WSREMS__REMS_Program__r.Name;
            }

            if(!prgmRTAndAccountMap.containsKey(programName)){
                prgmRTAndAccountMap.put(programName, new Map<Id, List<Account>>());    
            }

            Map<Id, List<Account>> existingRTAndAccountMap = prgmRTAndAccountMap.get(programName);

            if(!existingRTAndAccountMap.containsKey(accRec.RecordTypeId)){

            existingRTAndAccountMap.put(accRec.RecordTypeId,new List<Account>{});
            }            
            existingRTAndAccountMap.get(accRec.RecordTypeId).add(accRec);
            prgmRTAndAccountMap.put(programName, existingRTAndAccountMap);
                 
        }           
        return prgmRTAndAccountMap; 
    }

    public static void updateEmailOnARAccount(List<Account> accountList){
        id authOrizedRepRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
        for(Account accountRec : accountList){
            if(accountRec.RecordtypeId == authOrizedRepRecordTypeId){
                accountRec.US_WSREMS__Email__c = accountRec.PersonEmail;
            }
        }
    }

    /***********************************************************************************************************************************
    MethodName : updateRelatedAccountANDCases
    Description : When Account status chnaged to certified then update pending affiliated Accounts and cases.
    ************************************************************************************************************************************/
    public static void updateRelatedAccountANDCases(List<Account> accList,Map<Id,Account> oldAccountMap){
        Set<Id> hcsAccountIdSet = new Set<Id>();
        Set<Id> hcpAccountIdSet = new Set<Id>();
        Set<Id> accountsToCertify = new Set<Id>();
        Id prescriberAccRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        Id hcsAccRecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');
        for(Account accObj: accList){
            if(accObj.US_WSREMS__Status__c != oldAccountMap.get(accObj.Id).US_WSREMS__Status__c 
               && accObj.US_WSREMS__Status__c == 'Certified'){
                   if(accObj.recordTypeId == prescriberAccRecTypeId){
                       hcpAccountIdSet.add(accObj.Id);
                   }else if(accObj.recordTypeId == hcsAccRecordTypeId){
                       hcsAccountIdSet.add(accObj.Id);
                   }
               }
        }
        
        if(!hcpAccountIdSet.isEmpty() || !hcsAccountIdSet.isEmpty()){
            accountsToCertify = getPendingAccounts(hcpAccountIdSet, hcsAccountIdSet);
        }
        
        if(!accountsToCertify.isEmpty()){
            updateRecords(accountsToCertify);
        }
        
    }
    
    /***********************************************************************************************************************************
    MethodName : getPendingAccounts
    Description : When Account status chnaged to certified get pending affiliated accounts
    ************************************************************************************************************************************/

    public static Set<Id> getPendingAccounts(Set<Id> prescriberIdSet, Set<Id> hcsAccountIdSet){
        Set<Id> accountToBeCertified = new Set<Id>();
        for(US_WSREMS__Affiliation__c affiliationObj:  [SELECT Id, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Prescriber__c,US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c, US_WSREMS__Prescriber__r.US_WSREMS__Status__c 
                                                        FROM US_WSREMS__Affiliation__c 
                                                        WHERE (US_WSREMS__Prescriber__c IN : prescriberIdSet Or US_WSREMS__Health_Care_Setting__c In :hcsAccountIdSet)
                                                        ]){
                                                            if(hcsAccountIdSet!=null && hcsAccountIdSet.contains(affiliationObj.US_WSREMS__Health_Care_Setting__c) && affiliationObj.US_WSREMS__Prescriber__r.US_WSREMS__Status__c == 'Pending'){
                                                                   accountToBeCertified.add(affiliationObj.US_WSREMS__Prescriber__c);
                                                             }
                                                            if(prescriberIdSet!=null && prescriberIdSet.contains(affiliationObj.US_WSREMS__Prescriber__c) && affiliationObj.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c == 'Pending'){
                                                                accountToBeCertified.add(affiliationObj.US_WSREMS__Health_Care_Setting__c);

                                                            }
         }
                                                                     return accountToBeCertified;
    }
   
    /***********************************************************************************************************************************
    MethodName : updateRecords
    Description : When Account status chnaged to certified update affiliated pending enrollment cases
    ************************************************************************************************************************************/

    public static void updateRecords(Set<Id> accountIdSet){
        List<case> updateCaseList = new List<Case>();
        for(Case casObj: [SELECT Id,US_WSREMS__Incomplete_Reasons__c,HCPnotCertified__c,HCSnotCertified__c,RecordType.DeveloperName FROM Case WHERE US_WSREMS__Participant__c!=null AND US_WSREMS__Participant__c IN :accountIdSet]){
            If(casObj.US_WSREMS__Incomplete_Reasons__c == Label.Prescriber_Incomplete_Reason 
               || casObj.US_WSREMS__Incomplete_Reasons__c == Label.Health_Care_Incomplete_Reason
               || (casObj.US_WSREMS__Incomplete_Reasons__c!=null && (casObj.US_WSREMS__Incomplete_Reasons__c.contains(Label.Prescriber_Incomplete_Reason)
               || casObj.US_WSREMS__Incomplete_Reasons__c.contains(Label.Health_Care_Incomplete_Reason)))){
                If(casObj.RecordType.DeveloperName == 'Prescriber_enrollment'){
                    casObj.HCSnotCertified__c = false;
                }
                If(casObj.RecordType.DeveloperName == 'HCS_Enrollment'){
                    casObj.HCPnotCertified__c = false;
                }
                If(casObj.US_WSREMS__Incomplete_Reasons__c == Label.Prescriber_Incomplete_Reason 
                   || casObj.US_WSREMS__Incomplete_Reasons__c == Label.Health_Care_Incomplete_Reason){
                    casObj.US_WSREMS__Incomplete_Reasons__c = '';
                    casObj.Status = 'Complete';
                    casObj.US_WSREMS__Outcome__c = 'Complete';
                }
                updateCaseList.add(casObj);
            }
        }
        try{
        	update updateCaseList;
        }catch(exception e){
                System.debug('---Error--'+e.getMessage());
        }
    }
    /***********************************************************************************************************************************
    MethodName : updatePrescriberStatus
    Description : Updates the status of Macitentan prescriber to initiated.
    Created By : Ashish Purwar
    Created On : 11-04-2024
    ************************************************************************************************************************************/
    public static void updatePrescriberStatus(List<Account> newAccList){
        for(Account acc : newAccList){
            if(acc.US_WSREMS__Program_Name__c=='Macitentan REMS' && String.isEmpty(acc.US_WSREMS__Status__c)){
                acc.US_WSREMS__Status__c = 'Initiated';
            }
        }
       
    }
     /****************************************************************************************************************
    * Method Name : updateStatusChangeDate
    * @description : Method to insert Enrolled Date
    * @author Saiteja | 18-11-2024 
    * @param accountList : Triggered Account List(Trigger.New)
    * @param accountMap : Triggered Account Map(Trigger.oldMap)
    * @return void 
    ****************************************************************************************************************/
    public static void updateStatusChangeDate(List<Account> accountList,Map<Id,Account>accountMap){
        Id prescriberRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
         Id hcsRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        for(Account accountRec : accountList){
            if((accountRec.RecordtypeId == prescriberRecTypId ||accountRec.RecordtypeId == prescriberRecTypId) && accountRec.US_WSREMS__Status__c != accountMap.get(accountRec.Id).US_WSREMS__Status__c && accountRec.US_WSREMS__Status__c != null && accountRec.US_WSREMS__Date_Enrolled__c != system.today()){
                accountRec.US_WSREMS__Date_Enrolled__c = system.today();
            }
        }
    }

  }