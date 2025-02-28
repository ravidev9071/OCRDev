public without sharing class piasky_ManagePharmacies {
    
/*****************************************************************************************************************
* Method Name          : getPharmaAccount
* @Description         : Will get the pharmacy account of logged in user and its related affiliated records.
* @Author              : Dilbag
* @CreatedDate         : 24-5-2024
* @param userId        : Id of the Logged In User
* @return              : It will return Pharmacy account alsong with its related affiliation record
*****************************************************************************************************************/
    
    @AuraEnabled
    public static managePharmacy_Wrapper getPharmaAccount(String userId){
        User loginUser = [Select Id, Contact.Name, Contact.AccountId from User where Id =: userId Limit 1];
        List<Account> pharmaAcc = [Select Id, US_WSREMS__REMS_ID__c,US_WSREMS__Status__c, name, Address_1_Secondary_Office__c,
                                   Address_2_Secondary_Office__c, ShippingCity, US_WSREMS__State__c, ShippingPostalCode, Phone,
                                   Fax, (Select Id, US_WSREMS__User_Role__c, US_WSREMS__isActive__c, US_WSREMS__Pharmacy__r.Name, US_WSREMS__Pharmacy_User__r.US_WSREMS__Email__c, 
                                                              US_WSREMS__Pharmacy_User__r.Phone, US_WSREMS__Pharmacy__r.US_WSREMS__Status__c, 
                                                              US_WSREMS__Pharmacy_User__r.US_WSREMS__User_Type__c, US_WSREMS__Pharmacy_User__r.firstname,
                                                              US_WSREMS__Pharmacy_User__r.lastname, US_WSREMS__Pharmacy_User__r.US_WSREMS__Status__c
                                                              from US_WSREMS__Pharmacy_PreInstitutions__r where US_WSREMS__Pharmacy_User__c != null AND US_WSREMS__isActive__c = true) from Account where Id in
                                   (Select US_WSREMS__Pharmacy__c from US_WSREMS__Affiliation__c where 
                                    US_WSREMS__Pharmacy_User__c =: loginUser.Contact.AccountId) limit 1];
        
        if(pharmaAcc != null && pharmaAcc.size() > 0){
            managePharmacy_Wrapper recordWrapper = new managePharmacy_Wrapper(pharmaAcc[0], loginUser);
            return recordWrapper;            
        }
        else
            return null;
    }
    
/*****************************************************************************************************************
* Method Name          : getAffiliationRec
* @Description         : returns the affiliation record of the logged in user
* @Author              : Dilbag
* @CreatedDate         : 17-6-2024
* @param userId        : Id of the logged in user
* @return              : US_WSREMS__Affiliation__c record
*****************************************************************************************************************/
    
    @AuraEnabled
    public static US_WSREMS__Affiliation__c getAffiliationRec(String userId){
        User loginUser = [Select Id, Contact.Name, Contact.AccountId from User where Id =: userId Limit 1];
        List<US_WSREMS__Affiliation__c> affiliationRecList = [Select US_WSREMS__Pharmacy__c, US_WSREMS__User_Role__c from US_WSREMS__Affiliation__c where US_WSREMS__Pharmacy_User__c =: loginUser.Contact.AccountId];
        if(affiliationRecList != null && affiliationRecList.size() > 0){
            return affiliationRecList[0];
        }
        else
            return null;
    }
    
/*****************************************************************************************************************
* Method Name          : updateAffRec
* @Description         : from the id of the affiliated record, if the record is active make it inactive.
* @Author              : Dilbag
* @CreatedDate         : 24-5-2024
* @param affId         : Id of the affiliated record
* @return              : null
*****************************************************************************************************************/

    
    @AuraEnabled
    public static String updateAffRec(String affId){
        
		List<String> accountIds = new List<String>();
		List<US_WSREMS__Affiliation__c> affRecToUpdate = new List<US_WSREMS__Affiliation__c>();
        List<US_WSREMS__Affiliation__c> affRecList = [Select Id, name, US_WSREMS__Pharmacy_User__c, US_WSREMS__isActive__c from US_WSREMS__Affiliation__c where Id =: affId];
		for(US_WSREMS__Affiliation__c affRec: affRecList){
			if(affRec.US_WSREMS__isActive__c){
				affRec.US_WSREMS__isActive__c =  false;
				affRecToUpdate.add(affRec);
				accountIds.add(affRec.US_WSREMS__Pharmacy_User__c);
			}
		}
		if(!affRecToUpdate.IsEmpty()){
			updateUsers(accountIds);
			Update affRecToUpdate;
            return 'Success';
        }else{
            return 'null';
        }
    }
	
	@future(callout=true)
	public static void updateUsers(List<Id> accountIds){
        List<User> userToUpdate = new List<User>();
        List<User> portalUser = [Select Id, IsActive from User where Contact.AccountId In: accountIds];
        for(User usr: portalUser){
            if(usr.isActive){
                usr.isActive = false;
                userToUpdate.add(usr);
            }
        }
        if(!userToUpdate.isEmpty()){
            Update userToUpdate;
        }
        
	}
    
/*****************************************************************************************************************
* Method Name          : createRecordOnSubmit
* @Description         : If entered email of the input data already present in the org, an error will be thrown else, Creates various records (Account, Service Summary, Case, User) based on the submitted data.
* @Author              : Dilbag
* @CreatedDate         : 24-5-2024
* @param inputRecords  : JSON data containing the details for creating records.
* @param pharmaAcc     : Pharmacy account related to the logged in user
* @return              : If duplicate email from the input data found in the org, return failed else return Id of the created User record.
*****************************************************************************************************************/

    
    @auraEnabled   
    public static String createRecordOnSubmit(Map<String,String> inputRecords, String pharmaAcc, String arFoundMsg) {
        String recordDetails = inputRecords.get('recordDetails');
        String pharmacyId = inputRecords.get('pharmacyId');        
        String programName = inputRecords.get('programName');         
        PiaSky_NPISearchControllerPortal.RecordDataWrapper recordData = (PiaSky_NPISearchControllerPortal.RecordDataWrapper)System.JSON.deserialize(recordDetails,PiaSky_NPISearchControllerPortal.RecordDataWrapper.class);
        Boolean dupliacateEmail = [SELECT COUNT() FROM Account WHERE US_WSREMS__Email__c = :recordData.Email AND US_WSREMS__REMS_Program__r.Name =:programName ] > 0;
        if(dupliacateEmail){
            RETURN 'Failed';
        }
        else {
            RETURN PiaSky_NPISearchControllerPortal.createRecordOnSubmit(inputRecords,pharmaAcc,arFoundMsg);
        }   
        
    }
    
    public class managePharmacy_Wrapper{
        @AuraEnabled public Account acc{get;set;}
        @AuraEnabled public User portalUser{get;set;}
        public managePharmacy_Wrapper(Account accRecord, User portalUser){
            this.acc = accRecord;
            this.portalUser = portalUser;
        }
    }
}