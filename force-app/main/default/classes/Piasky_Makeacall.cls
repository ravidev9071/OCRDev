public with sharing class Piasky_Makeacall {
    private static final String STRING_OUTBOUNDCALL = 'Outbound_Call';
    private static final String STRING_PHONE = 'Phone';

/**
 * Creates a REMS Service Summary record and associated Case record for a given Account.
 *
 * @param accountRecordId The ID of the Account for which the REMS Service Summary is being created.
 * @param phone The phone number associated with the Account (not used directly in this method).
 * @param programID The ID of the REMS Program (not used directly in this method).
 * @return The ID of the newly created Case record.
 * @throws AuraHandledException if an error occurs during the creation of the records.
 */
@AuraEnabled
public static String CreateREMSService(String accountRecordId,String phone,String programID) {
    try {
        String caseId = null;
		makeaCallwrapper wrapper = makeaCall(phone, programID);
        // Retrieve the RecordTypeId for the 'Outbound_Communication' Record Type on REMS_Service_Summary object
        Id recordTypeIdService = Schema.Sobjecttype.US_WSREMS__REMS_Service_Summary__c
            .getRecordTypeInfosByDeveloperName()
            .get(SYN_IncontactUtility.Outbound_Communication)
            .getRecordTypeId();
        List<Account> actobj = new List<Account>();
        // Query the Account record using the provided accountRecordId
        if(accountRecordId != null){
            actobj = [
                SELECT id, name,isPersonAccount, phone, US_WSREMS__REMS_Program__c, RecordType.name, FirstName, LastName 
                FROM Account 
                WHERE Id = :accountRecordId 
                LIMIT 1
            ];
        }else{
            actobj = [
                SELECT id, name,isPersonAccount, phone, US_WSREMS__REMS_Program__c, RecordType.name, FirstName, LastName 
                FROM Account 
                WHERE phone = :phone  AND US_WSREMS__REMS_Program__c =:programID
                LIMIT 1
            ];
        }


        // Create a new REMS_Service_Summary record
        US_WSREMS__REMS_Service_Summary__c servicerecord = new US_WSREMS__REMS_Service_Summary__c();
        servicerecord.US_WSREMS__REMSProgram__c = programID;
        if(!actobj.isEmpty()){
            servicerecord.US_WSREMS__Requestor_Type__c = actobj[0].RecordType.name;
            servicerecord.US_WSREMS__Participant__c = actobj[0].id;
        }
        servicerecord.RecordTypeId = recordTypeIdService;

        // Insert the REMS_Service_Summary record
        insert servicerecord;
		
        // Create an associated Case record and get its ID
        caseId = createCaseRecord(servicerecord.ID, actobj, STRING_OUTBOUNDCALL,programID,phone,wrapper.ContactId);
        
        return caseId;
    } catch (Exception e) {
        // Handle any exceptions by throwing an AuraHandledException with the error message
        throw new AuraHandledException(e.getMessage());
    }
}

       
   
   /**
 * Creates a Case record associated with a given REMS Service Summary and Account.
 *
 * @param ServiceId The ID of the REMS Service Summary.
 * @param accountRec The ID of the Account associated with the Case.
 * @param Type The developer name of the Case record type.
 * @return The ID of the newly created Case.
 */
public static String createCaseRecord(Id ServiceId, List<account> actobj, String Type,String programID,String phone,String contactId) {
    try {
        // Retrieve the RecordTypeId for the specified Case record type
        Id recordTypeIdcase = Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get(Type).getRecordTypeId();

        // Create a new Case record
        Case caseObj = new Case();
        caseObj.RecordTypeId = recordTypeIdcase;
        if(!actobj.isEmpty()){
            caseObj.US_WSREMS__Participant__c = actobj[0].id;
            if(actObj[0].isPersonAccount) {
                caseObj.US_WSREMS__First_Name__c = actobj[0].FirstName;
                caseObj.US_WSREMS__Last_Name__c = actobj[0].LastName;
            }
        }
        caseObj.US_WSREMS__REMS_Program__c = programID;
        caseObj.US_WSREMS__Program_Picklist__c = [Select ID,name from US_WSREMS__REMS_Program__c where id =:programID].Name;
        caseObj.US_WSREMS__Channel__c = STRING_PHONE;
        caseObj.US_WSREMS__Same_as_Account__c = true;
        caseObj.US_WSREMS__REMS_Service_Summary__c = ServiceId;
        caseObj.US_WSREMS__Phone__c = phone;
        caseObj.inContact_Contact_ID__c	= contactId;
        // Insert the Case record and capture the result
        insert caseObj;
        // Return the new Case ID
        return caseObj.Id;
    }  catch (Exception e) {
        // Handle any exceptions by throwing an AuraHandledException with the error message
        throw new AuraHandledException(e.getMessage());
    }
}

public static makeaCallwrapper makeaCall(String phoneno,string programID) {
    try {
    makeaCallwrapper wrapper=new makeaCallwrapper(false,'');
	String programTollFreeno=[select id,Name,Toll_Free_Number_1__c from US_WSREMS__REMS_Program__c where id=:programID].Toll_Free_Number_1__c;   
    User u=[SELECT id,InContact_Agent_Id__c,InContact_ProjectSkillno__c from user where id=:UserInfo.getUserId() Limit 1];
            if(String.isNotBlank(u.InContact_Agent_Id__c)  && String.isNotBlank(u.InContact_ProjectSkillno__c) )
            {
                
                String url=SYN_InContactAPIUtility.makeACallURL( phoneno,ProgramTollFreeno);
                Map<String,String> status_map = SYN_InContactAPIUtility.makeFinalCallAPI(url);
                if(status_map.get('StatusCode') == '200')
                {
                   wrapper.status=true;
                   wrapper.ContactId=status_map.get('ContactId');
                   // wrapper.Phoneno=phoneno;  
                }
                else
                {
                    //Please add custom lablel message to display error
                   wrapper.status_message='Something went wrong..'+status_map.get('ErrorMessage'); 
                    wrapper.status=false;
                }
                
            }
            else
            {
               wrapper.status_message=System.Label.SYN_AgentId_or_SkillId_err; 
               wrapper.status=false;
            }
        return wrapper;
    } catch (Exception e) {
        // Handle any exceptions by throwing an AuraHandledException with the error message
        throw new AuraHandledException(e.getMessage());
    }
    

}

     public class makeaCallwrapper{
        @AuraEnabled public boolean status;
        @AuraEnabled public String record_Id;
        @AuraEnabled public String ContactId;
        @AuraEnabled public String Phoneno;
        @AuraEnabled public string status_message;
        
        public makeaCallwrapper(boolean status, String record_Id){
            this.status = status;
            this.record_Id = record_Id;
            
        }
    }


}