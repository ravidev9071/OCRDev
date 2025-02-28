public without sharing class SYN_PiaSkyPharmacyLookupSearchCls {
	@AuraEnabled(cacheable=true)
    public static List<Account> searchRecords(String name, String ShippingPostalCode,String ShippingCity,String ShippingState) {
        // Perform SOQL query based on search criteria
       Id pharmacyRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outpatient Pharmacy').getRecordTypeId();
        String programName = Label.PiaSky_REMS_Program_Name;
        String statusString = 'Certified';
        String queryString = 'SELECT Id, Name,ShippingStreet,US_WSREMS__State__c,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,US_WSREMS__National_Provider_Identifier__c,Address_1_Secondary_Office__c,Phone,Fax FROM Account WHERE RecordTypeId =:pharmacyRecordtypeId AND Program_Name__c=:programName AND US_WSREMS__Status__c=:statusString ' ;
        List<String> conditions = new List<String>();
        if (!String.isEmpty(name)) {
            conditions.add(' Name LIKE \'%' + name + '%\'');
        }
        if (!String.isEmpty(ShippingCity)) {
            conditions.add(' ShippingCity LIKE \'%' + ShippingCity + '%\'');
        }
         if (!String.isEmpty(ShippingState)) {
            conditions.add(' US_WSREMS__State__c LIKE \'%' + ShippingState + '%\'');
        }
         if (!String.isEmpty(ShippingPostalCode)) {
            conditions.add('  ShippingPostalCode LIKE \'%' + ShippingPostalCode + '%\'');
        }
        if (conditions.size()>0) {
            for (Integer i = 0; i < conditions.size(); i++) {
            queryString += ' AND ' + conditions[i];
            }
        }
       
        return Database.query(queryString);
    }
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues(String objectApiName, String fieldApiName) {
        List<Map<String, String>> picklistOptions = new List<Map<String, String>>();
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
        if (objectType != null) {
            Schema.DescribeFieldResult fieldDescribe = objectType.getDescribe().fields.getMap().get(fieldApiName).getDescribe();
            if (fieldDescribe != null && fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
                 Map<String, String> noneoption = new Map<String, String>();
                 noneoption.put('value', '');
                 noneoption.put('label', '--None--');
                 picklistOptions.add(noneoption);
                for (Schema.PicklistEntry entry : picklistValues) {
                    Map<String, String> option = new Map<String, String>();
                    option.put('value', entry.getValue());
                    option.put('label', entry.getLabel());
                    picklistOptions.add(option);
                }
            }
        }
        
        return picklistOptions;
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getCerifiedPharmacies(String sortedDirection) {
        // Perform SOQL query based on search criteria
       Id pharmacyRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outpatient Pharmacy').getRecordTypeId();
        String programName = Label.PiaSky_REMS_Program_Name;
        String statusString = 'Certified';
        String queryString = 'SELECT Id, Name,ShippingStreet,US_WSREMS__State__c,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,US_WSREMS__National_Provider_Identifier__c,Address_1_Secondary_Office__c,Phone,Fax FROM Account WHERE RecordTypeId =:pharmacyRecordtypeId AND Program_Name__c=:programName AND US_WSREMS__Status__c=:statusString ORDER BY Name '+sortedDirection;
        return Database.query(queryString);
    }
}