/**
* @File Name          : TryvioLookupSearchCls.cls
* @Description        : This class search accounts .
* @TestClass          : TryvioLookupSearchCls_Test
* @Author             : Himgiree Sharma
* @Date               : 11-06-2024
**/
public without sharing class TryvioLookupSearchCls {

    // This method is used to fetch the account based on participant type and input search value
    @AuraEnabled(cacheable=true)
    public static List<Account> searchRecords(String inputValue,String participantType, string searchType) {
        List<Id> recordtypeIdList = new List<Id>();
        String programName = Label.Tryvio_REMS_Program_Name;
        if (!String.isEmpty(participantType)) {
            if(participantType=='Prescribers'){
                recordtypeIdList.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId());
            }
            else{
                recordtypeIdList.add(SObjectType.Account.getRecordTypeInfosByName().get('Outpatient Pharmacy').getRecordTypeId());
                recordtypeIdList.add(SObjectType.Account.getRecordTypeInfosByName().get('Inpatient Pharmacy').getRecordTypeId());
            }
        }
        String statusCertified = 'Certified';
        String queryString = 'Select Id,Name,Recordtype.name,FirstName, LastName,'+ 
           'SYN_Ref_Id__c,ShippingStreet,US_WSREMS__Address_Line_1__c,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Zip__c,'+
            'ShippingCountry,US_WSREMS__NPI__c,Phone,Fax,Type,US_WSREMS__National_Provider_Identifier__c '+
            'FROM Account WHERE RecordTypeId IN : recordtypeIdList AND Program_Name__c=:programName AND US_WSREMS__Status__c =: statusCertified AND(';
        List<String> conditions = new List<String>();
        if (!String.isEmpty(inputValue)) {
            if(searchType.equals('Lookup')) {
                conditions.add(' Name LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__National_Provider_Identifier__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__NPI__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__State__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__Zip__c LIKE \'%' + inputValue + '%\'');
            } else if(searchType.equals('Locator')) {
                conditions.add(' US_WSREMS__Address_Line_1__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__City__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__State__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__Zip__c LIKE \'%' + inputValue + '%\'');
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
		return Database.query(queryString);
	}
}