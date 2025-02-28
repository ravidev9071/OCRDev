public without sharing class SYN_PortalHCSHCPLookupSearchCtrl {
    @AuraEnabled(cacheable=true)
    public static List<Account> searchRecords(String searchKeyWord) {
        // Perform SOQL query based on search criteria
        Id pharmacyRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        String statusString = 'Certified';
        String queryString = 'SELECT Id, Name, US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c, US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Zip__c, ShippingCountry, US_WSREMS__National_Provider_Identifier__c, Address_1_Secondary_Office__c, Phone, Fax, US_WSREMS__REMS_ID__c FROM Account WHERE RecordTypeId = :pharmacyRecordtypeId AND US_WSREMS__Program_Picklist__c = :programName AND US_WSREMS__Status__c = :statusString';
        List<String> conditions = new List<String>();
        if (!String.isEmpty(searchKeyWord)) {
            searchKeyWord = searchKeyWord.trim();
            conditions.add(' Name LIKE \'%' + searchKeyWord + '%\'');
            conditions.add(' US_WSREMS__State__c LIKE \'%' + searchKeyWord + '%\'');
            conditions.add(' US_WSREMS__Zip__c LIKE \'%' + searchKeyWord + '%\'');
            conditions.add(' US_WSREMS__DEA__c LIKE \'%' + searchKeyWord + '%\'');
        }
        if (conditions.size()>0) {
            queryString += ' AND ( ';
            for (Integer i = 0; i < conditions.size(); i++) {
                if( i == conditions.size()-1 ){
                    queryString += conditions[i] + ')';
                } else {
                    queryString += conditions[i]+ ' OR ';
                }
            }
        }
       
        return Database.query(queryString);
    }

    @AuraEnabled(cacheable=true)
    public static List<US_WSREMS__Affiliation__c> searchHCPRecords(String searchKeyWord) {
        // Perform SOQL query based on search criteria
        Id pharmacyRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        String statusString = 'Certified';
        String queryString = 'SELECT Id, US_WSREMS__Prescriber__c, US_WSREMS__Prescriber__r.Phone, US_WSREMS__Prescriber__r.US_WSREMS__REMS_ID__c, US_WSREMS__Prescriber__r.Name, US_WSREMS__Prescriber__r.FirstName, US_WSREMS__Prescriber__r.LastName, US_WSREMS__Prescriber__r.US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Health_Care_Setting__r.Name, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Prescriber__c != NULL AND US_WSREMS__isActive__c = TRUE';
        queryString += ' AND US_WSREMS__Prescriber__r.RecordTypeId = :pharmacyRecordtypeId AND US_WSREMS__Prescriber__r.US_WSREMS__Program_Picklist__c = :programName AND US_WSREMS__Prescriber__r.US_WSREMS__Status__c = :statusString';
        List<String> conditions = new List<String>();
        if (!String.isEmpty(searchKeyWord)) {
            searchKeyWord = searchKeyWord.trim();
            conditions.add(' US_WSREMS__Prescriber__r.Name LIKE \'%' + searchKeyWord + '%\'');
            conditions.add(' US_WSREMS__Prescriber__r.FirstName LIKE \'%' + searchKeyWord + '%\'');
            conditions.add(' US_WSREMS__Prescriber__r.LastName LIKE \'%' + searchKeyWord + '%\'');
            conditions.add(' US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c LIKE \'%' + searchKeyWord + '%\'');
            conditions.add(' US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c LIKE \'%' + searchKeyWord + '%\'');
            conditions.add(' US_WSREMS__Prescriber__r.US_WSREMS__National_Provider_Identifier__c LIKE \'%' + searchKeyWord + '%\'');
        }
        if (conditions.size()>0) {
            queryString += ' AND ( ';
            for (Integer i = 0; i < conditions.size(); i++) {
                if( i == conditions.size()-1 ){
                    queryString += conditions[i] + ')';
                } else {
                    queryString += conditions[i]+ ' OR ';
                }
            }
        }
        queryString += ' ORDER BY US_WSREMS__Start_Date__c ASC';
        Map<Id, US_WSREMS__Affiliation__c> hcpToAffiliation = new Map<Id, US_WSREMS__Affiliation__c>();
        for (US_WSREMS__Affiliation__c obj : (List<US_WSREMS__Affiliation__c>)Database.query(queryString)) {
            if (!hcpToAffiliation.containsKey(obj.US_WSREMS__Prescriber__c)) {
                hcpToAffiliation.put(obj.US_WSREMS__Prescriber__c, obj);
            }
        }
        return hcpToAffiliation.values();
    }
}