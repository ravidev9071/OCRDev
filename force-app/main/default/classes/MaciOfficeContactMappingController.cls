/** 
* @description       : MaciOfficeContactMappingController is controller class to Map Office Contact Accounts with Prescriber.
* @author            : Abhay Gupta
* @group             :
* @last modified on  : 02/05/2024
 **/
public class MaciOfficeContactMappingController {

	/**
   * @Description  :   getPrescriberAccountList Method is Used to get Prescriber Accounts
   * @Parameter    :   String searchKey -> It is the term to search
   * @return       :   list<Account>
   **/
	@AuraEnabled
	public static List<Account> getPrescriberAccountList(String searchKey , String recordTypeName , String filterCriteria) {
		List<Account> accountList = new List<Account>();
		if (String.isNotBlank(searchKey) && String.isNotBlank(recordTypeName) && String.isNotBlank(filterCriteria) ) {
			String searchKeyword = '%' + searchKey + '%';
			String headQuery = 'SELECT Id, Name , PersonEmail , Phone ,US_WSREMS__Email__c, SYN_Ref_Id__c, US_WSREMS__NPI__c , US_WSREMS__REMS_Program__c, US_WSREMS__Status__c, ShippingState, ShippingCity, ShippingStreet FROM Account WHERE ';
			String whereCondition;
			String query;
			if(filterCriteria == 'Search By Email'){
				whereCondition = '(PersonEmail LIKE :searchKeyword OR US_WSREMS__Email__c LIKE : searchKeyword) AND RecordType.Name = : recordTypeName';
				query = headQuery + whereCondition;

			} else if(filterCriteria == 'Search By NPI' && recordTypeName == 'Prescriber') {
				whereCondition = 'US_WSREMS__NPI__c LIKE :searchKeyword AND RecordType.Name = : recordTypeName';
				query = headQuery + whereCondition;

			} else if(recordTypeName == 'Office Contact'){
				whereCondition = 'Name LIKE :searchKeyword AND RecordType.Name = : recordTypeName';
				query = headQuery + whereCondition;

			} else {
				whereCondition = 'Name LIKE :searchKeyword AND RecordType.Name = : recordTypeName AND US_WSREMS__Status__c = \'Certified\'';
				query = headQuery + whereCondition;
				
			}
			List<Account> accounts = Database.query(query);
			for (Account accRecord : accounts) {
				accountList.add(accRecord);
			}
		}
		return accountList;
	}

	/**
	 * @Description  :   fetchRecordTypeData Method is Used to get RecordType Name of Accounts
	 * @Parameter    :   String recordId -> Id of record
	 * @return       :   String
	 **/
	@AuraEnabled(cacheable=true)
	public static String fetchRecordTypeData(String recordId) {
		List<Account> accountList = new List<Account>();
		if (String.isNotBlank(recordId)) {
			accountList = [SELECT Id , Name , RecordType.Name FROM Account WHERE ID =: recordId];
		}
		if(accountList[0].RecordType.Name == 'Prescriber'){
			return 'Office Contact' ;
		} else {
			return 'Prescriber' ; 
		}
	}

	/**
	 * @Description  :   createPrescriberAffiliationRecords Method is Used to create Affiliations for Prescriber
	 * @Parameter    :   String searchKey -> It is the term to search
	 * @return       :   list<Account>
	 **/
	@AuraEnabled
	public static String createPrescriberAffiliationRecords(String recordId ,String recordTypeName, List<Map<String,String>> accountRecords, String notification, String phoneNumber) {
		List<US_WSREMS__Affiliation__c> affiliationList = new List<US_WSREMS__Affiliation__c>();
		String message = '';
		List<US_WSREMS__Affiliation__c> updatedAffiliationList;
		if (String.isNotBlank(recordId) && !accountRecords?.isEmpty() && String.isNotBlank(recordTypeName)) {
			String prescriberAffliationRTId = REMSUtility.retrieveRecTypeNameId('Affiliation__c').get('Prescriber Affiliation');
			String OCAffiliationRTId = REMSUtility.retrieveRecTypeNameId('Affiliation__c').get('Office Contact Affiliation');
			for (Map<String,String> account : accountRecords){
				if(recordTypeName == 'Office Contact'){
					updatedAffiliationList = buildAffiliationRecord(affiliationList, (Id) account.get('Id'), recordId, (Id) account.get('RemsProgram'), notification, phoneNumber, OCAffiliationRTId);
				} else {
					updatedAffiliationList = buildAffiliationRecord(affiliationList, recordId, (Id) account.get('Id') , (Id) account.get('RemsProgram'), notification, phoneNumber, prescriberAffliationRTId);
				}
			}
		}
		if(!updatedAffiliationList?.isEmpty()){
			try{
				insert updatedAffiliationList;  
				message = 'SUCCESS';
			} catch (Exception ex){
				message = ex.getDmlMessage(0);
			} 
		}
		return message ;
	}

	public static List<US_WSREMS__Affiliation__c> buildAffiliationRecord(List<US_WSREMS__Affiliation__c> affiliationList, Id ocID, Id prescriberid, Id remsProgramId, String notification, String phoneNumber, Id recordTypeId) {
		US_WSREMS__Affiliation__c affiliation = new US_WSREMS__Affiliation__c();
		affiliation.Office_Contact__c = ocID ;
		affiliation.US_WSREMS__Start_Date__c = System.today();
		affiliation.US_WSREMS__Prescriber__c = prescriberid;
		affiliation.US_WSREMS__isActive__c = true ;
		affiliation.US_WSREMS__REMSProgram__c = remsProgramId;	
		affiliation.Notifications__c = notification;
		affiliation.Phone__c = phoneNumber;
		affiliation.recordTypeId = recordTypeId;
		affiliationList.add(affiliation);
		return affiliationList;
	}

	@AuraEnabled
	public static Boolean validateAffiliationRecords(String officeContactAccountId , String prescriberId , String remsProgramId) {
		Boolean isDuplicate = false ;
		if (String.isNotBlank(officeContactAccountId) && String.isNotBlank(prescriberId) && String.isNotBlank(remsProgramId)) {
			List<US_WSREMS__Affiliation__c> affiliationList = [
																	SELECT 
																		Id,
																		Name,
																		US_WSREMS__End_Date__c
																	FROM 
																		US_WSREMS__Affiliation__c 
																	WHERE Office_Contact__c =:officeContactAccountId 
																	AND US_WSREMS__Prescriber__c =:prescriberId  
																	AND US_WSREMS__REMSProgram__c =:remsProgramId
																];
			
			if(!affiliationList?.isEmpty()){
				if(affiliationList[0].US_WSREMS__End_Date__c == null || (affiliationList[0].US_WSREMS__End_Date__c != null && affiliationList[0].US_WSREMS__End_Date__c > Date.today())) {
					isDuplicate = true;
				}
			} else {
				isDuplicate = false ;
			}
		}
		return isDuplicate ;
	}
}