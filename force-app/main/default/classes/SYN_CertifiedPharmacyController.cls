public without sharing class  SYN_CertifiedPharmacyController {
    @AuraEnabled
    public static List<Account> getCertifiedAccounts(String PharmacyName, String DEA, String NPI){
        String NameSearchKey = '';
        String DEASearchKey = '';
        String NPISearchKey = '';
         List<Account> account_list;
         string queryString = '';
        String programName='Sodium Oxybate REMS';
        string status='Certified';
        Id pharmacyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        string queryFilter='';
         if(PharmacyName != null && PharmacyName != ''){
            NameSearchKey = '\'%'+PharmacyName+'%\'';
            queryFilter = ' Name LIKE '+NameSearchKey;
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
        if(NPI != null && NPI != ''){
            if(queryFilter != ''){
                NPISearchKey = '\'%'+NPI+'%\'';
                queryFilter = queryFilter + ' AND '+ ' US_WSREMS__NPI__c LIKE '+NPISearchKey; 
            }else{
                NPISearchKey = '\'%'+NPI+'%\'';
                queryFilter = ' US_WSREMS__NPI__c LIKE '+NPISearchKey; 
            }
        }
         if(queryFilter != null && queryFilter != ''  ){
            queryString ='Select id,Name,ShippingStreet,ShippingCity,US_WSREMS__DEA__c,US_WSREMS__NPI__c,ShippingState,ShippingCountry ,ShippingPostalCode,Phone,Fax from Account where US_WSREMS__REMS_Program__r.Name =:programName and RecordTypeId=:pharmacyRecordTypeId and US_WSREMS__Status__c=:status and '+queryFilter + ' order By Name ASC';
       
     
         }else{
            queryString = 'Select id,Name,ShippingStreet,ShippingCity,US_WSREMS__DEA__c,US_WSREMS__NPI__c,ShippingState,ShippingCountry ,ShippingPostalCode,Phone,Fax from Account where US_WSREMS__REMS_Program__r.Name =:programName and RecordTypeId=:pharmacyRecordTypeId and US_WSREMS__Status__c=:status order By Name ASC';
       
         }
          account_list = Database.query(queryString);
        return account_list;
    }
}