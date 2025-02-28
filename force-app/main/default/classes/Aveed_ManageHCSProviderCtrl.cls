public without sharing class Aveed_ManageHCSProviderCtrl {
    
    public class HealthCareProviderData {
        @AuraEnabled
        public Account provider;
        @AuraEnabled
        public List<AssociatedHCSData> hcsSettings;
    }
    
    public class AssociatedHCSData {
        @AuraEnabled
        public String hcSettingName;
        @AuraEnabled
        public Id hcsAccountId;
        
        public AssociatedHCSData(Id accountId, String name) {
            this.hcsAccountId = accountId;
            this.hcSettingName = name;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isCertifiedAR() {
        List<User> currentUser = SYN_CommonUtility.getCurrentUser();
        if (currentUser == null || currentUser.isEmpty()) {
            return false;
        }
        List<String> includedStatus = new List<String>{'Certified'};
     
        List<US_WSREMS__Affiliation__c> affiliations = [SELECT Id, US_WSREMS__Authorized_Representative__c, US_WSREMS__Prescriber__c, US_WSREMS__isActive__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Start_Date__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c 
                                                      FROM US_WSREMS__Affiliation__c 
                                                      WHERE US_WSREMS__Authorized_Representative__c = :currentUser.get(0).AccountId
                                                      AND US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c IN :includedStatus
                                                      AND US_WSREMS__isActive__c = TRUE
                                                      AND US_WSREMS__Start_Date__c != NULL];
        if (affiliations != null && !affiliations.isEmpty()) {
            return true;
        }
        return false;
    }
    
    @AuraEnabled
    public static Map<Id, String> getRelatedHealthcareSettings() {
        List<User> currentUser =  SYN_CommonUtility.getCurrentUser();
        if (currentUser == null || currentUser.isEmpty()) {
            return null;
        }
        Map<Id, String> healthcaresettingsMap = new Map<Id, String>();
        for (US_WSREMS__Affiliation__c affiliation : [SELECT Id, US_WSREMS__Authorized_Representative__c, US_WSREMS__Prescriber__c, US_WSREMS__isActive__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Start_Date__c, US_WSREMS__Health_Care_Setting__r.Name, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c 
                                                      FROM US_WSREMS__Affiliation__c 
                                                      WHERE US_WSREMS__Authorized_Representative__c = :currentUser.get(0).AccountId
                                                      AND US_WSREMS__isActive__c = TRUE
                                                      AND US_WSREMS__Start_Date__c != NULL
                                                      AND US_WSREMS__Health_Care_Setting__c != NULL])
        {
            healthcaresettingsMap.put(affiliation.US_WSREMS__Health_Care_Setting__c, affiliation.US_WSREMS__Health_Care_Setting__r.Name);
        }
        return healthcaresettingsMap;
    }
    
    @AuraEnabled
    public static List<HealthCareProviderData> getRelatedHCProviderForAR() {
        List<User> currentUser = SYN_CommonUtility.getCurrentUser();
        if (currentUser == null || currentUser.isEmpty()) {
            return null;
        }
        Set<Id> hcsIds = new Set<Id>();
        for (US_WSREMS__Affiliation__c affiliation : [SELECT Id, US_WSREMS__Authorized_Representative__c, US_WSREMS__Prescriber__c, US_WSREMS__isActive__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Start_Date__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c 
                                                      FROM US_WSREMS__Affiliation__c 
                                                      WHERE US_WSREMS__Authorized_Representative__c = :currentUser.get(0).AccountId
                                                      AND US_WSREMS__isActive__c = TRUE
                                                      AND US_WSREMS__Start_Date__c != NULL
                                                      AND US_WSREMS__Health_Care_Setting__c != NULL])
        {
            hcsIds.add(affiliation.US_WSREMS__Health_Care_Setting__c);
        }
        
      
        Map<Id, List<AssociatedHCSData>> providerIdToHCSSettingData = new Map<Id, List<AssociatedHCSData>>();
        List<US_WSREMS__Affiliation__c> providerAffiliations = new List<US_WSREMS__Affiliation__c>();
        if (hcsIds != null && !hcsIds.isEmpty()) {
            for (US_WSREMS__Affiliation__c affiliation : [SELECT Id, US_WSREMS__Authorized_Representative__c, US_WSREMS__Prescriber__c, US_WSREMS__isActive__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Health_Care_Setting__r.Name, US_WSREMS__Start_Date__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c, 
                                                        US_WSREMS__Prescriber__r.Name, US_WSREMS__Prescriber__r.US_WSREMS__Address_Line_1__c, US_WSREMS__Prescriber__r.US_WSREMS__Address_Line_2__c, US_WSREMS__Prescriber__r.US_WSREMS__City__c, US_WSREMS__Prescriber__r.US_WSREMS__State__c, US_WSREMS__Prescriber__r.US_WSREMS__Zip__c, 
                                                        US_WSREMS__Prescriber__r.US_WSREMS__DEA__c, US_WSREMS__Prescriber__r.US_WSREMS__REMS_ID__c, US_WSREMS__Prescriber__r.US_WSREMS__NPI__c, US_WSREMS__Prescriber__r.US_WSREMS__Healthcare_Setting_Type__c, US_WSREMS__Prescriber__r.US_WSREMS__Status__c
                                                        FROM US_WSREMS__Affiliation__c 
                                                        WHERE US_WSREMS__Health_Care_Setting__c IN :hcsIds
                                                        AND US_WSREMS__isActive__c = TRUE
                                                        AND US_WSREMS__Start_Date__c != NULL
                                                        AND US_WSREMS__Prescriber__c != NULL])
            {
                if (!providerIdToHCSSettingData.containsKey(affiliation.US_WSREMS__Prescriber__c)) {
                    providerIdToHCSSettingData.put(affiliation.US_WSREMS__Prescriber__c, new List<AssociatedHCSData>());
                }
                providerIdToHCSSettingData.get(affiliation.US_WSREMS__Prescriber__c).add(new AssociatedHCSData(affiliation.US_WSREMS__Health_Care_Setting__c, affiliation.US_WSREMS__Health_Care_Setting__r.Name));
            }
        }
        
        if (providerIdToHCSSettingData == null || providerIdToHCSSettingData.isEmpty()) {
            return null;
        }
        List<HealthCareProviderData> hcSettings = new List<HealthCareProviderData>();
        if (hcsIds != null && !hcsIds.isEmpty()) {
            for (Account obj : [SELECT Id, Name, US_WSREMS__Address_Line_1__c, US_WSREMS__Address_Line_2__c, US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Zip__c, US_WSREMS__DEA__c, US_WSREMS__REMS_ID__c, US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Healthcare_Setting_Type__c, US_WSREMS__Status__c, US_WSREMS__Date_Enrolled__c,
                                (SELECT Id, US_WSREMS__Health_Care_Setting__r.Name, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c
								FROM US_WSREMS__Prescriber_PrescribingInstitution__r WHERE US_WSREMS__isActive__c = TRUE AND US_WSREMS__Start_Date__c != NULL ORDER BY US_WSREMS__Start_Date__c ASC LIMIT 1)
								FROM Account 
                                WHERE Id IN :providerIdToHCSSettingData.keySet()])
            {
                HealthCareProviderData data = new HealthCareProviderData();
                data.provider = obj;
                if (providerIdToHCSSettingData.containskey(obj.Id)) {
                	data.hcsSettings = providerIdToHCSSettingData.get(obj.Id);
                }
                hcSettings.add(data);
            }
        }
        return hcSettings;
    }
    
    @AuraEnabled
    public static Boolean disassociateHCSFromAR(Id hcsSettingId, Id hcsProviderId) {
        if (String.isBlank(hcsSettingId) || String.isBlank(hcsProviderId)) {
            return false;
        }
        List<US_WSREMS__Affiliation__c> affiliationToUpdate = new List<US_WSREMS__Affiliation__c>();
        for (US_WSREMS__Affiliation__c affiliation : [SELECT Id, US_WSREMS__Authorized_Representative__c, US_WSREMS__Prescriber__c, US_WSREMS__isActive__c, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Start_Date__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c 
                                                      FROM US_WSREMS__Affiliation__c 
                                                      WHERE US_WSREMS__Prescriber__c = :hcsProviderId
                                                      AND US_WSREMS__Health_Care_Setting__c = :hcsSettingId
                                                      AND US_WSREMS__isActive__c = TRUE
                                                      AND US_WSREMS__Start_Date__c != NULL])
        {
            affiliation.US_WSREMS__isActive__c = false;
            affiliation.US_WSREMS__End_Date__c = Date.today();
            affiliationToUpdate.add(affiliation);
        }
        
        if (!affiliationToUpdate.isEmpty()) {
            update affiliationToUpdate;
        }
        return true;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> searchHCProvidersRecordsByRemsId(String searchString) {
        if (String.isBlank(searchString)) {
            return null;
        }
        // Perform SOQL query based on search criteria
        Id recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        Map<String, Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        List<String> includedStatus = new List<String>{'Certified'};
        String queryString = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE RecordTypeId = :recordtypeId AND US_WSREMS__Program_Picklist__c = :programName';
        searchString = String.escapeSingleQuotes(searchString);
        queryString += ' AND US_WSREMS__REMS_ID__c LIKE \'%' + searchString + '%\'';
        return Database.query(queryString);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> searchHCProvidersRecordsByName(String firstName, String lastName, String state) {
        if (String.isBlank(lastName) || String.isBlank(state)) {
            return null;
        }
        // Perform SOQL query based on search criteria
        Id recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        Map<String, Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        List<String> includedStatus = new List<String>{'Certified'};
        String queryString = 'SELECT ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE RecordTypeId = :recordtypeId AND US_WSREMS__Program_Picklist__c = :programName';
        if (String.isNotBlank(firstName)) {
            firstName = String.escapeSingleQuotes(firstName);
        	queryString += ' AND FirstName LIKE \'%' + firstName + '%\'';
        }
        lastName = String.escapeSingleQuotes(lastName);
        queryString += ' AND LastName LIKE \'%' + lastName + '%\'';
        state = String.escapeSingleQuotes(state);
        queryString += ' AND US_WSREMS__State__c LIKE \'%' + state + '%\'';
        return Database.query(queryString);
    }

}