public without sharing class  SYN_XiaflexPharmacyLookupSearchCls {

    @AuraEnabled(cacheable=true)
    public static List<Account> searchRecords(String inputValue,String participantType, string searchType, String programType) {
        List<Id> recordtypeIdList = new List<Id>();
        String programName = Label.Xiaflex_REMS_Program_Name;
        Id hcsRecTypeId = SObjectType.Account.getRecordTypeInfosByName().get('Health Care Setting').getRecordTypeId();
        List<Account> hcsAccountList = new List<Account>();
        String inputString = '\'%'+inputValue+'%\'';
        Set<Id> prescriberIdSet = new Set<Id>();
        if (!String.isEmpty(participantType)) {   
                recordtypeIdList.add(hcsRecTypeId);
        }
        String statusCertified = 'Certified';
        String queryString = 'Select Id,Name,Recordtype.name,FirstName, LastName,'+ 
           'SYN_Ref_Id__c,ShippingStreet,US_WSREMS__Address_Line_1__c,US_WSREMS__Address_Line_2__c,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Zip__c,'+
            'ShippingCountry,US_WSREMS__NPI__c,Phone,Fax,Type,US_WSREMS__National_Provider_Identifier__c,US_WSREMS__REMS_ID__c '+
            'FROM Account WHERE RecordTypeId IN : recordtypeIdList AND Program_Name__c=:programName AND US_WSREMS__Program_Type__c =: programType AND US_WSREMS__Status__c =: statusCertified AND (';
            if(!prescriberIdSet.isEmpty()){
                queryString += '(Id IN : prescriberIdSet) OR (';
            }

            
            List<String> conditions = new List<String>();
        if (!String.isEmpty(inputValue)) {
            if(searchType.equals('Lookup')) {
                conditions.add(' Name LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__National_Provider_Identifier__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__Address_Line_1__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__Address_Line_2__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__State__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__City__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__Zip__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' FirstName LIKE \'%' + inputValue + '%\'');
                conditions.add(' LastName LIKE \'%' + inputValue + '%\'');
            }
        }
        if (conditions.size()>0) {
            for (Integer i = 0; i < conditions.size(); i++) {
                if(i == conditions.size() - 1){
                queryString += ' OR ' + conditions[i] + ')'; 
            	}
                else if(i==0){
                	queryString +=  conditions[i];
                }
                else{
                    queryString += ' OR ' + conditions[i];
                }
			}
		}
        if(!prescriberIdSet.isEmpty()){
            queryString += ')';
		}
		return Database.query(queryString);
	}

    @AuraEnabled(cacheable=true)
    public static List<US_WSREMS__Affiliation__c> searchHCPRecords(String searchKeyWord, String programName, String programType) {
        // Perform SOQL query based on search criteria
        Id prescriberRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        String statusString = 'Certified';
        String queryString = 'SELECT Id, US_WSREMS__Prescriber__c, US_WSREMS__Prescriber__r.Phone, US_WSREMS__Prescriber__r.US_WSREMS__REMS_ID__c, US_WSREMS__Prescriber__r.Name, US_WSREMS__Prescriber__r.FirstName, US_WSREMS__Prescriber__r.LastName, US_WSREMS__Prescriber__r.US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Health_Care_Setting__r.Name, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Prescriber__c != NULL AND US_WSREMS__isActive__c = TRUE';
        queryString += ' AND US_WSREMS__Prescriber__r.RecordTypeId = :prescriberRecordtypeId AND US_WSREMS__Prescriber__r.US_WSREMS__Program_Picklist__c = :programName AND US_WSREMS__Prescriber__r.US_WSREMS__Program_Type__c =: programType AND US_WSREMS__Prescriber__r.US_WSREMS__Status__c = :statusString';
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

    @AuraEnabled(cacheable=true)
    public static List<SObject> searchRecordsForLocator(String inputValue,String participantType, String programType) {
        if(String.isBlank(inputValue) || String.isBlank(participantType)){
            return null;
        }
        if(participantType=='Prescribing'){
            Id prescriberRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
            String programName = Label.Xiaflex_REMS_Program_Name;
            String statusString = 'Certified';
            String queryString = 'SELECT Id, US_WSREMS__Prescriber__c, US_WSREMS__Prescriber__r.Phone, US_WSREMS__Prescriber__r.US_WSREMS__REMS_ID__c, US_WSREMS__Prescriber__r.Name, US_WSREMS__Prescriber__r.FirstName, US_WSREMS__Prescriber__r.LastName, US_WSREMS__Prescriber__r.US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Health_Care_Setting__r.Name, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Prescriber__c != NULL AND US_WSREMS__isActive__c = TRUE';
            queryString += ' AND US_WSREMS__Prescriber__r.RecordTypeId = :prescriberRecordtypeId AND US_WSREMS__Prescriber__r.US_WSREMS__Program_Picklist__c = :programName  AND US_WSREMS__Prescriber__r.US_WSREMS__Program_Type__c =: programType AND US_WSREMS__Prescriber__r.US_WSREMS__Status__c = :statusString';
            List<String> conditions = new List<String>();
            if (!String.isEmpty(inputValue)) {
                inputValue = inputValue.trim();
                conditions.add(' US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c LIKE \'%' + inputValue + '%\'');
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
            return (List<SObject>)hcpToAffiliation.values();
        }
        else{
            Id pharmacyRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Health Care Setting').getRecordTypeId();
            String programName = Label.Xiaflex_REMS_Program_Name;
            String statusCertified = 'Certified';
            String queryString = 'Select Id,Name,Recordtype.name,FirstName, LastName,'+ 
            'SYN_Ref_Id__c,US_WSREMS__REMS_ID__c,ShippingStreet,US_WSREMS__Address_Line_1__c,US_WSREMS__Address_Line_2__c,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Zip__c,'+
                'ShippingCountry,US_WSREMS__NPI__c,Phone,Fax,Type,US_WSREMS__National_Provider_Identifier__c '+
                'FROM Account WHERE RecordTypeId = : pharmacyRecordtypeId AND US_WSREMS__Program_Picklist__c=:programName AND US_WSREMS__Program_Type__c =: programType AND US_WSREMS__Status__c =: statusCertified AND (';
            List<String> conditions = new List<String>();
            if (!String.isEmpty(inputValue)) {
                conditions.add(' US_WSREMS__Address_Line_1__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__Address_Line_2__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__City__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__State__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__Zip__c LIKE \'%' + inputValue + '%\'');
            }
            if (conditions.size()>0) {
                for (Integer i = 0; i < conditions.size(); i++) {
                    if(i == conditions.size() - 1){
                    queryString += ' OR ' + conditions[i] + ')'; 
                    }
                    else if(i==0){
                        queryString +=  conditions[i];
                    }
                    else{
                        queryString += ' OR ' + conditions[i];
                    }
                }
            }
            return (List<SObject>)Database.query(queryString);
        }
	}
}