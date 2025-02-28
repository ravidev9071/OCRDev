public class SYN_CaseRDACtrl {
@AuraEnabled
    public static List<Case> getCaseRDA(String AuthorizationNum,String PatientName,String PatientDOB,String PrescriberName, String  PrescriberDEA){
        String AuthNUMSearchKey = '';
        String PatientNameSearchKey = '';
        String PatientDOBSearchKey = '';
        String PrescriberNameSearchKey = '';
		String PrescriberDEASearchKey = '';
        List<Case> Case_list;
        string queryString = '';
        String programName='Sodium Oxybate REMS';
        String CaseStatus ='Complete';
        Id RDARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RDA').getRecordTypeId();
        Id currentUserId = UserInfo.getUserId();
        User portalUser = [SELECT Id, Contact.AccountId FROM User WHERE Id = :currentUserId];
        Account portalContactAccount = [SELECT Id,SYN_Pharmacy__c FROM Account WHERE Id = :portalUser.Contact.AccountId];
         string PharmacyId = portalContactAccount.SYN_Pharmacy__c;
        string queryFilter='';
        if(AuthorizationNum != null && AuthorizationNum != ''){
            AuthNUMSearchKey = '\'%'+AuthorizationNum+'%\'';
            queryFilter = 'RDA_Authorization_Code__c  LIKE '+AuthNUMSearchKey;
        }
        
        if(PatientName != null && PatientName != ''){
            if(queryFilter != ''){
                PatientNameSearchKey = '\'%'+PatientName+'%\'';
                queryFilter = queryFilter + ' AND '+  ' (US_WSREMS__Patient__r.Name  LIKE '+PatientNameSearchKey +' OR '+'US_WSREMS__Patient__r.FirstName  LIKE '+PatientNameSearchKey +' OR '+' US_WSREMS__Patient__r.MiddleName LIKE '+ PatientNameSearchKey+'OR '+' US_WSREMS__Patient__r.LastName LIKE '+ PatientNameSearchKey+' ) '; 
            }else{
                PatientNameSearchKey = '\'%'+PatientName+'%\'';
                queryFilter = ' (US_WSREMS__Patient__r.Name  LIKE '+PatientNameSearchKey +' OR '+'US_WSREMS__Patient__r.FirstName  LIKE '+PatientNameSearchKey +' OR '+' US_WSREMS__Patient__r.MiddleName LIKE '+ PatientNameSearchKey+'OR '+' US_WSREMS__Patient__r.LastName LIKE '+ PatientNameSearchKey+' ) '; 
            }
        }
        
         if(PatientDOB != null && PatientDOB != ''){
            if(queryFilter != ''){
                PatientDOBSearchKey = PatientDOB; ///'\'%'+PatientDOB+'%\'';
                queryFilter = queryFilter + ' AND '+ ' US_WSREMS__DOB__c = '+PatientDOBSearchKey; 
            }else{
                PatientDOBSearchKey = PatientDOB;//'\'%'+PatientDOB+'%\'';
                queryFilter = ' US_WSREMS__DOB__c = '+PatientDOBSearchKey; 
            }
        }
        if(PrescriberName != null && PrescriberName != ''){
            if(queryFilter != ''){
                PrescriberNameSearchKey = '\'%'+PrescriberName+'%\'';
                queryFilter = queryFilter + ' AND '+ ' (SYN_Prescriber__r.Name  LIKE '+PrescriberNameSearchKey +' OR '+'SYN_Prescriber__r.FirstName  LIKE '+PrescriberNameSearchKey +' OR '+' SYN_Prescriber__r.MiddleName LIKE '+ PrescriberNameSearchKey+'OR '+' SYN_Prescriber__r.LastName LIKE '+ PrescriberNameSearchKey+' ) ';
            }else{
                PrescriberNameSearchKey = '\'%'+PrescriberName+'%\'';
                queryFilter = ' ( SYN_Prescriber__r.Name  LIKE '+PrescriberNameSearchKey +' OR '+'SYN_Prescriber__r.FirstName LIKE '+PrescriberNameSearchKey +' OR '+' SYN_Prescriber__r.MiddleName LIKE '+ PrescriberNameSearchKey+'OR '+' SYN_Prescriber__r.LastName LIKE '+ PrescriberNameSearchKey+' ) ' ; 
            }
        }
		if(PrescriberDEA != null && PrescriberDEA != ''){
            if(queryFilter != ''){
                PrescriberDEASearchKey = '\'%'+PrescriberDEA+'%\'';
                queryFilter = queryFilter + ' AND '+ ' US_WSREMS__DEA__c LIKE '+PrescriberDEASearchKey; 
            }else{
                PrescriberDEASearchKey = '\'%'+PrescriberDEA+'%\'';
                queryFilter = ' US_WSREMS__DEA__c LIKE '+PrescriberDEASearchKey; 
            }
        }
        if(queryFilter != null && queryFilter != ''  ){
            queryString ='Select id,SYN_Prescriber__c,SYN_Prescriber__r.Name,SYN_Prescriber__r.FirstName,US_WSREMS__Outcome__c,SYN_Prescriber__r.LastName,SYN_Prescriber__r.MiddleName,US_WSREMS__Pharmacy__r.NAME,US_WSREMS__Patient__r.NAME,US_WSREMS__Patient__r.FirstName,US_WSREMS__Patient__r.MiddleName,US_WSREMS__Patient__r.LastName,US_WSREMS__Patient__r.SYN_First_Name__c,US_WSREMS__Patient__r.SYN_Last_Name__c,RDA_Authorization_Code__c,US_WSREMS__DEA__c,Status,US_WSREMS__DOB__c,US_WSREMS__NPI__c,date_of_Fill__c from Case where US_WSREMS__REMS_Program__r.Name =:programName and US_WSREMS__Pharmacy__c=:PharmacyId and Status=:CaseStatus and RecordTypeId=:RDARecordTypeId and '+queryFilter + ' order By date_of_Fill__c  DESC LIMIT 10000';
        }else{
            queryString = 'Select id,SYN_Prescriber__c,SYN_Prescriber__r.Name,SYN_Prescriber__r.FirstName,US_WSREMS__Outcome__c,SYN_Prescriber__r.LastName,SYN_Prescriber__r.MiddleName,US_WSREMS__Pharmacy__r.NAME,US_WSREMS__Patient__r.NAME,US_WSREMS__Patient__r.FirstName,US_WSREMS__Patient__r.MiddleName,US_WSREMS__Patient__r.LastName,US_WSREMS__Patient__r.SYN_First_Name__c,US_WSREMS__Patient__r.SYN_Last_Name__c,RDA_Authorization_Code__c,US_WSREMS__DEA__c,Status,US_WSREMS__DOB__c,US_WSREMS__NPI__c,date_of_Fill__c from Case where US_WSREMS__REMS_Program__r.Name =:programName and US_WSREMS__Pharmacy__c=:PharmacyId and Status=:CaseStatus and RecordTypeId=:RDARecordTypeId  order By date_of_Fill__c DESC LIMIT 10000';
            
        }
        Case_list = Database.query(queryString);
        return Case_list;
      
    }
      @AuraEnabled
    public static SYN_MetadataVariablesService.portalButtonDatawrapper getPermissionsBasedonAccountStatus(String buttonName){
        return SYN_MetadataVariablesService.retrievePortalButtonConfigurationData(buttonName);
    }
}