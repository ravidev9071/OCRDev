public without sharing class SYN_CertifiedPharmacyParticipantCtrl {
    @AuraEnabled
    public static List<Account> getCertifiedAccounts(String FirstName,String LastName,String DEA, String  Phone){
        String FirstNameSearchKey = '';
        String LastNameSearchKey = '';
        String DEASearchKey = '';
        String PhoneSearchKey = '';
        List<Account> account_list;
        string queryString = '';
        String programName='Sodium Oxybate REMS';
        string status='Certified';
        Id PrescriberRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        string queryFilter='';
        if(FirstName != null && FirstName != ''){
            FirstNameSearchKey = '\'%'+FirstName+'%\'';
            queryFilter = ' FirstName LIKE '+FirstNameSearchKey;
        }
        
        if(LastName != null && LastName != ''){
            if(queryFilter != ''){
                LastNameSearchKey = '\'%'+LastName+'%\'';
                queryFilter = queryFilter + ' AND '+ ' LastName LIKE '+LastNameSearchKey; 
            }else{
                LastNameSearchKey = '\'%'+LastName+'%\'';
                queryFilter = ' LastName LIKE '+LastNameSearchKey; 
            }
        }
        
        if(DEA != null && DEA != ''){
            if(queryFilter != ''){
                DEASearchKey = '\'%'+DEA+'%\'';
                queryFilter = queryFilter + ' AND '+ ' US_WSREMS__DEA__c LIKE '+DEASearchKey; 
            }else{
                DEASearchKey = '\'%'+DEA+'%\'';
                queryFilter = ' US_WSREMS__DEA__c LIKE '+DEASearchKey; 
            }
        }
        if(Phone != null && Phone != ''){
            if(queryFilter != ''){
                PhoneSearchKey = '\'%'+Phone+'%\'';
                queryFilter = queryFilter + ' AND '+ ' Phone LIKE '+PhoneSearchKey; 
            }else{
                PhoneSearchKey = '\'%'+Phone+'%\'';
                queryFilter = ' Phone LIKE '+PhoneSearchKey; 
            }
        }
        if(queryFilter != null && queryFilter != ''  ){
            queryString ='Select id,Name,FirstName,LastName,SYN_First_Name__c,SYN_Last_Name__c,ShippingStreet,ShippingCity,US_WSREMS__DEA__c,US_WSREMS__Status__c,US_WSREMS__NPI__c,ShippingState,ShippingCountry ,ShippingPostalCode,Phone,Fax from Account where US_WSREMS__REMS_Program__r.Name =:programName and RecordTypeId=:PrescriberRecordTypeId and '+queryFilter + ' order By LastName ASC LIMIT 10000';
        }else{
            queryString = 'Select id,Name,FirstName,LastName,SYN_First_Name__c,SYN_Last_Name__c,ShippingStreet,ShippingCity,US_WSREMS__DEA__c,US_WSREMS__Status__c,US_WSREMS__NPI__c,ShippingState,ShippingCountry ,ShippingPostalCode,Phone,Fax from Account where US_WSREMS__REMS_Program__r.Name =:programName and RecordTypeId=:PrescriberRecordTypeId  order By LastName ASC LIMIT 10000';
            
        }
        account_list = Database.query(queryString);
        return account_list;
    }
    
     @AuraEnabled
    public static SYN_MetadataVariablesService.portalButtonDatawrapper getPermissionsBasedonAccountStatus(String buttonName){
        return SYN_MetadataVariablesService.retrievePortalButtonConfigurationData(buttonName);
    }
    
}