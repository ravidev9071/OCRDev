public with sharing class SYN_PatientSearchController {
    @AuraEnabled
    public static List<Account> searchAccounts( Boolean myPatientBool, Boolean searchTermBool, String firstName, String LastName, String DOB, String Phone, String ZipCode,String SortingField,String SortingDirection ) {
        
        List<Account> accounts = new List<Account>();
        List<US_WSREMS__Affiliation__c> affiliationList = new List<US_WSREMS__Affiliation__c>();
        List<sObject> sobjList = New List<SObject>();
        Account loggedInUserAccount = New Account();
        User loggedInUserDetail = New User();
        Set<Id> patientIds = New Set<Id>();
        Set<Id> allpatientIds = New Set<Id>();
        Id patientAffiliationRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Patient_Affiliation').getRecordTypeId();
        Id patientAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        String FirstNameSearchKey = '';
        String LastNameSearchKey = '';
        String DOBSearchKey = '';
        String PhoneSearchKey = '';
        String ZipCodeSearchKey = '';
        string queryFilter='';
        
        if(firstName != null && firstName != ''){
            FirstNameSearchKey = '\'%'+firstName+'%\'';
            queryFilter = ' FirstName LIKE '+FirstNameSearchKey;
        }
        if(LastName != null && LastName != ''){
            if(queryFilter != ''){
                LastNameSearchKey = '\'%'+LastName+'%\'';
                queryFilter = queryFilter + ' AND '+ 'LastName LIKE '+LastNameSearchKey; 
            }else{
                LastNameSearchKey = '\'%'+LastName+'%\'';
                queryFilter = 'LastName LIKE '+LastNameSearchKey; 
            }
        }
        if(DOB != null && DOB != ''){
            if(queryFilter != ''){
                DOBSearchKey = DOB;//'\'%'+DOB+'%\'';
                queryFilter = queryFilter + ' AND '+ 'US_WSREMS__DOB__c = '+DOBSearchKey; 
            }else{
                DOBSearchKey = DOB;
                queryFilter = 'US_WSREMS__DOB__c= '+DOBSearchKey; 
            }
        }
        if(Phone != null && Phone != ''){
            if(queryFilter != ''){
                PhoneSearchKey = '\'%'+Phone+'%\'';
                queryFilter = queryFilter + ' AND '+ 'Phone_Formula__c LIKE '+PhoneSearchKey; 
            }else{
                PhoneSearchKey = '\'%'+Phone+'%\'';
                queryFilter = 'Phone_Formula__c LIKE '+PhoneSearchKey; 
            }
        }
        if(ZipCode != null && ZipCode != ''){
            if(queryFilter != ''){
                ZipCodeSearchKey = '\'%'+ZipCode+'%\'';
                queryFilter = queryFilter + ' AND '+ 'ShippingPostalCode LIKE '+ZipCodeSearchKey; 
            }else{
                ZipCodeSearchKey = '\'%'+ZipCode+'%\'';
                queryFilter = 'ShippingPostalCode LIKE '+ZipCodeSearchKey; 
            }
        }
      
        
        //Get the current user's contact Id to get the AccountId
      
        String programId = [SELECT Id,Name FROM US_WSREMS__REMS_Program__c WHERE Name = 'Sodium Oxybate REMS' limit 1].Id;
        List<User> user_list=[SELECT Id,contact.AccountId from User where id=:userInfo.getUserId()];
        affiliationList = [SELECT Id,US_WSREMS__Patient__c,US_WSREMS__Prescriber__c FROM US_WSREMS__Affiliation__c WHERE RecordTypeId =: patientAffiliationRecordTypeId and US_WSREMS__Patient__c != null and US_WSREMS__Prescriber__c =:user_list[0].contact.AccountId  and US_WSREMS__REMSProgram__c =: programId];
        
        if(affiliationList.size()>0){
            for(US_WSREMS__Affiliation__c aff:affiliationList){
                patientIds.add(aff.US_WSREMS__Patient__c);
            }
        }
        
        
        string queryString = '';
       
        if(myPatientBool == true && searchTermBool == false){
            queryString = 'SELECT Id, FirstName, LastName, Phone, ShippingPostalCode,US_WSREMS__DOB__c,US_WSREMS__Status__c  FROM Account WHERE Id IN: patientIds AND RecordTypeId =:patientAccountRecordTypeId AND US_WSREMS__REMS_Program__c =: programId ORDER BY '+SortingField+' ' +SortingDirection+ ' LIMIT 1000';
        }else if(myPatientBool == true && searchTermBool == true){
            queryString = 'SELECT Id, FirstName, LastName, Phone, ShippingPostalCode,US_WSREMS__DOB__c,US_WSREMS__Status__c  FROM Account WHERE Id IN: patientIds AND US_WSREMS__REMS_Program__c =: programId AND RecordTypeId =:patientAccountRecordTypeId AND  '+queryFilter+ ' ORDER BY '+SortingField+' ' +SortingDirection+ ' LIMIT 1000';// REMS_Program__r.Name =: loggedInUserAccount.US_WSREMS__REMS_Program__c AND '+queryFilter+ 'ORDER BY LastName DESC LIMIT 1000';
        }else if(myPatientBool == false && searchTermBool == true){
            queryString = 'SELECT Id, FirstName, LastName, Phone, ShippingPostalCode,US_WSREMS__DOB__c,US_WSREMS__Status__c  FROM Account WHERE US_WSREMS__REMS_Program__c =: programId AND RecordTypeId =:patientAccountRecordTypeId AND '+queryFilter+ ' ORDER BY '+SortingField+' ' +SortingDirection+ ' LIMIT 1000';// AND REMS_Program__r.Name =: loggedInUserAccount.US_WSREMS__REMS_Program__c AND '+queryFilter+ 'ORDER BY LastName DESC LIMIT 1000';
        } 
        
        sobjList = Database.query(queryString);
        return sobjList;
        
    }
        
        @AuraEnabled
        public static List<Case> displayCaseRecs(String recordId,String sortedBy, String sortedDirection,String PatientorPharmacy){
            string queryString = '';
            List<Case> caselist = new List<Case>();
            List<REMSServiceRecordTypeFilter__mdt> mcs = REMSServiceRecordTypeFilter__mdt.getAll().values();
            
            Set<String> recTypeLabels = New Set<String>();
           
            if(mcs.size()>0){
                
                for(REMSServiceRecordTypeFilter__mdt rs:mcs){
                    if(rs.Patient__c && PatientorPharmacy==' Patient' ) {
                        recTypeLabels.add(rs.Name__c);
                    }
                    else if(rs.Pharmacy__c && PatientorPharmacy ==' Pharmacy') {
                         recTypeLabels.add(rs.Name__c);
                    }
                }
            }        
          
            if(sortedBy !=null && sortedBy !='' && sortedDirection !=null && sortedDirection!=''){
                queryString = 'SELECT Id,Case_Record_Type_Name__c,US_WSREMS__Status__c,Status,Createddate,US_WSREMS__Outcome__c,SYN_Should_patient_be_monitored__c  FROM Case WHERE US_WSREMS__Patient__c =: recordId AND Case_Record_Type_Name__c IN:recTypeLabels ORDER BY '+sortedBy+' '+sortedDirection;
            }else{
                queryString = 'SELECT Id,Case_Record_Type_Name__c,US_WSREMS__Status__c,Status,Createddate,US_WSREMS__Outcome__c,SYN_Should_patient_be_monitored__c  FROM Case WHERE US_WSREMS__Patient__c =: recordId AND Case_Record_Type_Name__c IN:recTypeLabels ORDER BY Createddate DESC';
            }
            
            caselist = Database.query(queryString);
           //added as part of task BT6825-1062
           if(caselist.size()>0)
           {
            for(Case cs:caselist)
            {
               if(cs.Case_Record_Type_Name__c != 'REMS Dispense Authorization')
                   cs.US_WSREMS__Outcome__c ='';
            }
           } 
           return caselist;
        }

    @AuraEnabled
    public static Account accountDataForCompactLayout(String recordId){
        return [SELECT Id,Name,US_WSREMS__DOB__c,US_WSREMS__Status__c,Phone FROM Account WHERE Id=: recordId];
    }

    @AuraEnabled
    public static SYN_MetadataVariablesService.portalButtonDatawrapper getPermissionsBasedonAccountStatus(String buttonName){
        return SYN_MetadataVariablesService.retrievePortalButtonConfigurationData(buttonName);
    }
   
}