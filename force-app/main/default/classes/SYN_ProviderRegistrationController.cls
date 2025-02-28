public without sharing class SYN_ProviderRegistrationController {
    public static Boolean isPortal = false;  
       @AuraEnabled(cacheable=true)
       public static RCtypPrgmIdWrapper getRCTYPId(string rctypename){
           Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
       .get(rctypename).getRecordTypeId();
           String RcId = String.valueOf(recordTypeId);
           List<US_WSREMS__REMS_Program__c> SOXProgram = [SELECT Id, Name FROM US_WSREMS__REMS_Program__c WHERE Name = :SYN_Utilitycls.SOX_PROGRAM_NAME LIMIT 1];
           RCtypPrgmIdWrapper rctypPgm = new RCtypPrgmIdWrapper(RcId, SOXProgram[0].id);
           return rctypPgm;
       }
       @AuraEnabled(cacheable=true)
       public static DecisionWrapper checkAccountDuplicates(Id recordTypeId , String fields){
        isPortal = true;
        Boolean createRecord;
        string Notes;
        String NPI;
        String AccId;
        Boolean UserFound;
        Boolean DEAvalidation = false; 
        Boolean NPIvalidation = false;
        Boolean SLNvalidation = false;
        Boolean Sche3Validation = false;
        //1173:Boolean isDEAAddressValidated = FALSE;
        Map<String,Object > fieldMappingMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        SYN_AccountsDuplicateCheck.duplicateWrapper accDuplicateDetails = SYN_AccountsDuplicateCheck.checkDuplicate(recordTypeId , fields);
        
        List<Account> DupAccList = accDuplicateDetails.Accountlst;
   
   
        Map<Id, Boolean> userMap = new Map<Id, Boolean>();
    
        if(DupAccList != Null && !DupAccList.isEmpty()){
            Set<Id> dupAccIdSet = new Set<Id>();
            for(Account A : DupAccList){
               dupAccIdSet.add(A.Id);
            }
            List<User> userRecList = [SELECT Username, ContactId, Contact.Name, Contact.AccountId, Contact.Account.Name 
                                      FROM User WHERE Contact.AccountId = :dupAccIdSet ];
            if(userRecList != Null || !userRecList.isEmpty()){
                UserFound = false;
                for(user u :userRecList){
                    userMap.put(u.Contact.AccountId, true);
                }
            }
            
            for(Account Acc : [SELECT Id, Name, US_WSREMS__Status__c, US_WSREMS__NPI__c FROM ACCOUNT WHERE ID IN :dupAccIdSet]){
                
                if(((Acc.US_WSREMS__Status__c == 'Initiated') || (Acc.US_WSREMS__Status__c == 'Canceled')) && userMap.get(Acc.id) != true){
                    createRecord = true;
                    NPI = String.valueOf(Acc.US_WSREMS__NPI__c);
                    AccId = String.valueOf(Acc.Id);
                }else if(Acc.US_WSREMS__Status__c == 'Pending' && userMap.get(Acc.id) != true){
                    createRecord = false;
                    Notes = 'An Account with this information already exists. Please click on Forgot Password to reset Your password or Contact theSodium Oxybate REMS at 1-833-769-7367 for assistance.';
                }else if(((Acc.US_WSREMS__Status__c == 'Certified')||(Acc.US_WSREMS__Status__c == 'Disenrolled'))  && userMap.get(Acc.id) == true){
                    Notes = 'An Account with this information already exists. Please click on Forgot Password to reset Your password or Contact theSodium Oxybate REMS at 1-833-769-7367 for assistance.';
                    createRecord = false;
                }else{
                    createRecord = false;
                }
            }
        }
        else{
            createRecord = true;
        }
        if (createRecord){
            DEAvalidation = DEAValidationBeforeParticipantCreation( recordTypeId , fields);
            //1173:isDEAAddressValidated = (SYN_VeevaAPI_Search.PresInfo != NULL && String.valueOf(fieldMappingMap.get('SYN_Street_Address__c')) == SYN_VeevaAPI_Search.PresInfo.StreetAddress && String.valueOf(fieldMappingMap.get('SYN_Zip_Code__c')) == SYN_VeevaAPI_Search.PresInfo.postalCode && String.valueOf(fieldMappingMap.get('US_WSREMS__State__c')) == SYN_VeevaAPI_Search.PresInfo.State && String.valueOf(fieldMappingMap.get('US_WSREMS__City__c')) == SYN_VeevaAPI_Search.PresInfo.city) ? TRUE : FALSE;
            Sche3Validation = DEASche3ValBeforeParticipantCreation( recordTypeId , fields);
            if(DEAvalidation){
               NPIvalidation = NPIValidationBeforeParticipantCreation(recordTypeId, fields); 
                if(NPIvalidation){
                    SLNvalidation =SLNValidationBeforeParticipantCreation(recordTypeId, fields); 
                }
            }else
            {
                //Sche3Validation = DEASche3ValBeforeParticipantCreation( recordTypeId , fields);
            }
           
           
        }
       String facilityName ='%'+String.valueOf(fieldMappingMap.get('SYN_Facility__c'))+'%';
        String facilityId;
        List<Account> facilityAccounts=[Select id,Name from Account where name Like :facilityName and US_WSREMS__REMS_Program__r.Name='Sodium Oxybate REMS' and recordtype.developerName='Prescribing_Institution'];
           if(!facilityAccounts.isEmpty()){
               facilityId = facilityAccounts[0].id;
           }
   
        DecisionWrapper DW = new DecisionWrapper();
        DW.AccountExists = accDuplicateDetails.dupFound;
        DW.createAccount = createRecord;
        DW.DisplayNotes = Notes;
        DW.NPINumber = NPI;
        DW.AccountId = AccId;
        DW.HasUser = UserFound;
        DW.DEAvalidation = DEAvalidation;
        //1173:DW.DEAAddressValidation = isDEAAddressValidated;
        DW.NPIvalidation =NPIvalidation;
        DW.SLNvalidation=SLNvalidation;
        DW.Sche3Validation=Sche3Validation;
        DW.FacilityId=facilityId;
        return DW;
    }
       
       @AuraEnabled
       public static boolean DEAValidationBeforeParticipantCreation(Id recordTypeId , String fields){
            Map<String,Object > fieldMappingMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
            
            if (fieldMappingMap.Keyset() == null ){
                return false;
            }
            SYN_VeevaAPI_Search.caseParameterWrap CPW = new SYN_VeevaAPI_Search.caseParameterWrap(null , String.valueOf(fieldMappingMap.get('US_WSREMS__DEA__c')) , String.valueOf(fieldMappingMap.get('US_WSREMS__Last_Name__c')), String.valueOf(fieldMappingMap.get('RecordTypeId')) );
            return SYN_VeevaAPI_Search.searchResult(CPW);
       }
    @AuraEnabled
       public static boolean DEASche3ValBeforeParticipantCreation(Id recordTypeId , String fields){
            Map<String,Object > fieldMappingMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
            
            if (fieldMappingMap.Keyset() == null ){
                return false;
            }
            SYN_VeevaAPI_Search.caseParameterWrap CPW = new SYN_VeevaAPI_Search.caseParameterWrap(null , String.valueOf(fieldMappingMap.get('US_WSREMS__DEA__c')) , String.valueOf(fieldMappingMap.get('US_WSREMS__Last_Name__c')), String.valueOf(fieldMappingMap.get('RecordTypeId')) );
            CPW.Sche3Validation = true;
            return SYN_VeevaAPI_Search.searchResult(CPW);
       }
    
     @AuraEnabled
       public static boolean NPIValidationBeforeParticipantCreation(Id recordTypeId , String fields){
            Map<String,Object > fieldMappingMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
            
            if (fieldMappingMap.Keyset() == null ){
                return false;
            }
            SYN_VeevaAPI_Search.caseParameterWrap CPW = new SYN_VeevaAPI_Search.caseParameterWrap(null , String.valueOf(fieldMappingMap.get('US_WSREMS__NPI__c')) , String.valueOf(fieldMappingMap.get('US_WSREMS__Last_Name__c')), String.valueOf(fieldMappingMap.get('RecordTypeId')) );
            CPW.NPIvalidation=true;
            return SYN_VeevaAPI_Search.searchResult(CPW);
       }
      @AuraEnabled
       public static boolean SLNValidationBeforeParticipantCreation(Id recordTypeId , String fields){
            Map<String,Object > fieldMappingMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
            
            if (fieldMappingMap.Keyset() == null ){
                return false;
            }
            SYN_VeevaAPI_Search.caseParameterWrap CPW = new SYN_VeevaAPI_Search.caseParameterWrap(null , String.valueOf(fieldMappingMap.get('US_WSREMS__SLN__c')) , String.valueOf(fieldMappingMap.get('US_WSREMS__Last_Name__c')), String.valueOf(fieldMappingMap.get('RecordTypeId')) );
            CPW.SLNvalidation=true;
            return SYN_VeevaAPI_Search.searchResult(CPW);
       }
       
       @AuraEnabled
       public static RemsPagelayoutComponent.AccountCreationDetails createPortalAcctOnCaseCreation(Id caseId) {
           return RemsPageLayoutComponent.createAccountOnCaseCreation(caseId);
       }
       @AuraEnabled
       public static RemsPagelayoutComponent.AccountCreationDetails updateAccountOnCaseCreation(Id caseId, Id AccountId) {
           return RemsPageLayoutComponent.updateAccountOnCaseCreation(caseId, AccountId);
       }
       public class RCtypPrgmIdWrapper{
           @AuraEnabled
           public String CaseRectypeId;
           @AuraEnabled
           public Id ProgramId;
           Public RCtypPrgmIdWrapper(String recTypId, Id ProgramId){
               this.CaseRectypeId = recTypId;
               this.ProgramId = ProgramId;
           }
               
       }
       public class DecisionWrapper{
           @AuraEnabled
           public Boolean AccountExists;
           @AuraEnabled
           public Boolean createAccount;
           @AuraEnabled
           public string DisplayNotes;
           @AuraEnabled
           public string NPINumber;
           @AuraEnabled
           public string AccountId;
           @AuraEnabled
           public Boolean HasUser;
           @AuraEnabled
           public string FacilityId;
           @AuraEnabled
           public boolean DEAvalidation = false;
           //1173:@AuraEnabled
           //1173:public boolean DEAAddressValidation = false;
           @AuraEnabled
           public boolean NPIvalidation = false;
           @AuraEnabled
           public boolean SLNvalidation = false;
           @AuraEnabled
           public boolean Sche3Validation = false;
           public DecisionWrapper(){
   
           }
       }
   }