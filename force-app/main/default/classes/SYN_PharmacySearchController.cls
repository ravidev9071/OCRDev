public class SYN_PharmacySearchController {
     @AuraEnabled
    public static List<Account> searchAccounts( String firstName, String LastName, String DOB, String Phone, String ZipCode,String SortingField,String SortingDirection ) {
        List<Account> accounts = new List<Account>();
       
        List<sObject> sobjList = New List<SObject>();
        Account loggedInUserAccount = New Account();
        User loggedInUserDetail = New User();
        Set<Id> patientIds = New Set<Id>();
        Set<Id> allpatientIds = New Set<Id>();
        Id patientAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        String FirstNameSearchKey = '';
        String LastNameSearchKey = '';
        String DOBSearchKey = '';
        String PhoneSearchKey = '';
        String ZipCodeSearchKey = '';
        string queryFilter='';
        String programName='Sodium Oxybate REMS';
        
        if(firstName != null && firstName != ''){
            FirstNameSearchKey = '\'%'+firstName+'%\'';
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
        if(DOB != null && DOB != ''){
            if(queryFilter != ''){
                DOBSearchKey = DOB;//'\'%'+DOB+'%\'';
                queryFilter = queryFilter + ' AND '+ ' US_WSREMS__DOB__c = '+DOBSearchKey; 
            }else{
                DOBSearchKey = DOB;
                queryFilter = ' US_WSREMS__DOB__c= '+DOBSearchKey; 
            }
        }
        if(Phone != null && Phone != ''){
            if(queryFilter != ''){
                PhoneSearchKey = '\'%'+Phone+'%\'';
                queryFilter = queryFilter + ' AND '+ ' ( Phone LIKE '+PhoneSearchKey +' OR '+' SYN_Alternate_Phone__c LIKE '+ PhoneSearchKey+' ) '; 
            }else{
                PhoneSearchKey = '\'%'+Phone+'%\'';
                queryFilter = ' ( Phone LIKE '+PhoneSearchKey +' OR '+' SYN_Alternate_Phone__c LIKE '+ PhoneSearchKey+' ) '; 
            }
        }
        if(ZipCode != null && ZipCode != ''){
            if(queryFilter != ''){
                ZipCodeSearchKey = '\'%'+ZipCode+'%\'';
                queryFilter = queryFilter + ' AND '+ ' ShippingPostalCode LIKE '+ZipCodeSearchKey; 
            }else{
                ZipCodeSearchKey = '\'%'+ZipCode+'%\'';
                queryFilter = ' ShippingPostalCode LIKE '+ZipCodeSearchKey; 
            }
        }
        string queryString = '';
          if(queryFilter != null && queryFilter != ''  ){
              if(SortingField !=null && SortingField !='' && SortingDirection !=null && SortingDirection!=''){
                  queryString = 'SELECT Id, FirstName, LastName,Name,US_WSREMS__Status__c, Phone, ShippingPostalCode,US_WSREMS__DOB__c  FROM Account WHERE RecordTypeId =:patientAccountRecordTypeId AND US_WSREMS__REMS_Program__r.Name =:programName  AND'+queryFilter+ ' ORDER BY '+SortingField+' ' +SortingDirection+' LIMIT 1000';// AND REMS_Program__r.Name =: loggedInUserAccount.US_WSREMS__REMS_Program__c AND '+queryFilter+ 'ORDER BY LastName DESC LIMIT 1000';
              }else{
                  queryString = 'SELECT Id, FirstName, LastName,Name,US_WSREMS__Status__c, Phone, ShippingPostalCode,US_WSREMS__DOB__c  FROM Account WHERE RecordTypeId =:patientAccountRecordTypeId AND  US_WSREMS__REMS_Program__r.Name =:programName   AND'+queryFilter+ ' ORDER BY LastName DESC LIMIT 1000';// AND REMS_Program__r.Name =: loggedInUserAccount.US_WSREMS__REMS_Program__c AND '+queryFilter+ 'ORDER BY LastName DESC LIMIT 1000';
              } 
                      sobjList = Database.query(queryString);
            
          }
        return sobjList;
        
    }

}