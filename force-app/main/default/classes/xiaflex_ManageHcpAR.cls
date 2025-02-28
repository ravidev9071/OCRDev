/**
* @File Name : xiaflex_ManageHcpAR.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : September 13, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 13, 2024 |   | Initial Version
**/
public without sharing class xiaflex_ManageHcpAR {
	@AuraEnabled
	Public static List<US_WSREMS__Affiliation__c> getRelatedHCPToAR(String userId, String programType){
		        User loginUser = [Select Id, Contact.Name, Contact.AccountId from User where Id =: userId Limit 1];
				List<Id> allHCSaffiliatedWithAR = new List<Id>();
								List<id> checklist = new List<id>();
			Map<id,US_WSREMS__Affiliation__c> filteredMap = new Map<id,US_WSREMS__Affiliation__c>();
				 List<US_WSREMS__Affiliation__c> getHCSaffiliations = [Select US_WSREMS__Health_Care_Setting__c from US_WSREMS__Affiliation__c where US_WSREMS__Authorized_Representative__c =: loginUser.Contact.AccountId and US_WSREMS__isActive__c = true And RecordType.name = 'Authorized Representative Affiliation' AND  US_WSREMS__Health_Care_Setting__c != null/* AND US_WSREMS__Health_Care_Setting__r.US_WSREMS__Program_Type__c =: programType*/];
				if(getHCSaffiliations.size() == 0 || getHCSaffiliations.isEmpty()){
					return null;
				}
				for(US_WSREMS__Affiliation__c af: getHCSaffiliations){
					allHCSaffiliatedWithAR.add(af.US_WSREMS__Health_Care_Setting__c);
				}
				List<US_WSREMS__Affiliation__c> getHCPaffiliations = [Select Id,US_WSREMS__Prescriber__c,US_WSREMS__Prescriber__r.US_WSREMS__Role__c,US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c,US_WSREMS__Prescriber__r.US_WSREMS__REMS_ID__c,US_WSREMS__Prescriber__r.Name, US_WSREMS__Prescriber__r.US_WSREMS__Status__c, US_WSREMS__Health_Care_Setting__c,US_WSREMS__Health_Care_Setting__r.name , US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c , US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c,US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c from  US_WSREMS__Affiliation__c 
																	where  US_WSREMS__Health_Care_Setting__c IN: allHCSaffiliatedWithAR and US_WSREMS__isActive__c = true And RecordType.name = 'Prescriber Affiliation' Order by createddate ];
				if(getHCPaffiliations.size() == 0 || getHCPaffiliations.isEmpty()){
					return null;
				}
				for(US_WSREMS__Affiliation__c af : getHCPaffiliations){
					if(!checklist.contains(af.US_WSREMS__Prescriber__c)){
					filteredMap.put(af.US_WSREMS__Prescriber__c,af);
					}
				}
				return getHCPaffiliations;
	}
}