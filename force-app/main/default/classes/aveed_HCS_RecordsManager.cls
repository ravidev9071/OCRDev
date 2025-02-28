public without sharing class aveed_HCS_RecordsManager {
    @AuraEnabled(cacheable=true)
    public static List<Account> getRelatedHCSList(String userId){
        
        List<User> u = SYN_CommonUtility.getCurrentUser();
        List<Account> hcsAccountList = new List<Account>();
        if(!u.isEmpty() && !String.isBlank(u[0].contact.accountId)){
            
            List<US_WSREMS__Affiliation__c> affList = [
                SELECT Id, US_WSREMS__Prescriber__c, US_WSREMS__Health_Care_Setting__c,US_WSREMS__Health_Care_Setting__r.US_WSREMS__Status__c 
                FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__isActive__c = TRUE AND
                US_WSREMS__Prescriber__c =: u[0].contact.accountId];
            
            
            Set<Id> hcsAccountIdSet = new Set<Id>();
            if(!affList.isEmpty()){
                for(US_WSREMS__Affiliation__c aff:affList){
                    hcsAccountIdSet.add(aff.US_WSREMS__Health_Care_Setting__c);
                }
            }
            
            if(!hcsAccountIdSet.isEmpty()){
                hcsAccountList = [SELECT Id,Name,US_WSREMS__Address_Line_1__c,US_WSREMS__Address_Line_2__c,US_WSREMS__City__c, US_WSREMS__State__c,US_WSREMS__Zip__c,US_WSREMS__DEA__c,US_WSREMS__Healthcare_Setting_Type__c,US_WSREMS__Status__c,US_WSREMS__Date_Enrolled__c,US_WSREMS__Recertification_Due_Date__c FROM Account WHERE Id in: hcsAccountIdSet];
            }
            return hcsAccountList;
        }
        return hcsAccountList;
    }
    
    @AuraEnabled
    public static Boolean disassociateHandler(Id accountId,Integer hcsCount){
        
        try{
            List<User> u = SYN_CommonUtility.getCurrentUser();
            
            List<US_WSREMS__Affiliation__c> affList = [
                SELECT Id, US_WSREMS__isActive__c, US_WSREMS__End_Date__c
                FROM US_WSREMS__Affiliation__c WHERE 
                US_WSREMS__Health_Care_Setting__c =: accountId and US_WSREMS__Prescriber__c =: u[0].contact.accountId
                and US_WSREMS__isActive__c= TRUE
            ];
            
            if(affList.size()<1){
                return false;
            }
            
            affList[0].US_WSREMS__isActive__c = false;
            affList[0].US_WSREMS__End_Date__c = Date.today();
            update affList;
            
            if(hcsCount ==1){
                return createCaseAndServiceSummaryUpdatePrescriber(u[0].contact.accountId,accountId);
            }
            return true;
        }catch (Exception ex) {
            System.debug('Exception'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @TestVisible
    private static Boolean createCaseAndServiceSummaryUpdatePrescriber(String accountId, String healthCareSettingId) {
        //try {
            if (String.isBlank(accountId) || String.isBlank(healthCareSettingId)) {
                return false;
            }
            String enrollmentServiceRecordType = 'Disenrollment';
            String casePrescriberEnrollmentRecordType = 'Deactivation';
            
            SObjectType accountType = Schema.getGlobalDescribe().get('Account');
            Map<String, Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            String query = 'SELECT RecordType.Name, ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE Id = :accountId';
            List<Account> prescriberAccount = Database.query(query);
          
            
            query = 'SELECT RecordType.Name, ' + String.join(new List<String>(mfields.Keyset()), ',') + ' FROM Account WHERE Id = :healthCareSettingId';
            List<Account> healthCareAccount = Database.query(query);
            List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Id = :prescriberAccount[0].US_WSREMS__REMS_Program__c];
            
            US_WSREMS__REMS_Service_Summary__c serviceSummary = NPISearchControllerPortal.insertServiceSummary(prescriberAccount.get(0), program, prescriberAccount.get(0).RecordType.Name, enrollmentServiceRecordType);
            
        	 prescriberAccount[0].US_WSREMS__Status__c = 'Disenrolled';
            prescriberAccount[0].US_WSREMS__Sub_Status__c = 'Opt-Out, no HCS';
            update prescriberAccount;
        	
        Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get(casePrescriberEnrollmentRecordType);
            Case caseRec = new Case();
            caseRec.US_WSREMS__First_Name__c = prescriberAccount.get(0).FirstName;
            caseRec.US_WSREMS__Middle_Name__c = prescriberAccount.get(0).MiddleName;
            caseRec.US_WSREMS__Last_Name__c = prescriberAccount.get(0).LastName;
            caseRec.US_WSREMS__Professional_Designation__c = prescriberAccount.get(0).US_WSREMS__Professional_Designation__c;
            caseRec.US_WSREMS__Fax__c = prescriberAccount.get(0).Fax;
            caseRec.US_WSREMS__Ext__c = prescriberAccount.get(0).US_WSREMS__Ext__c;
            caseRec.US_WSREMS__Phone__c = prescriberAccount.get(0).Phone;
            caseRec.US_WSREMS__DEA__c = prescriberAccount.get(0).US_WSREMS__DEA__c;
            caseRec.US_WSREMS__NPI__c = prescriberAccount.get(0).US_WSREMS__National_Provider_Identifier__c;
            caseRec.US_WSREMS__Prescriber_NPI__c = prescriberAccount.get(0).US_WSREMS__National_Provider_Identifier__c;
            caseRec.US_WSREMS__NPI_Status__c = prescriberAccount.get(0).US_WSREMS__NPI_Status__c;
            caseRec.US_WSREMS__Preferred_Contact_Method__c = prescriberAccount.get(0).US_WSREMS__Preferred_Contact_Method__c;
            caseRec.US_WSREMS__State__c = healthCareAccount.get(0).US_WSREMS__State__c;
            caseRec.US_WSREMS__City__c = healthCareAccount.get(0).US_WSREMS__City__c;
            caseRec.US_WSREMS__Zip__c = healthCareAccount.get(0).US_WSREMS__Zip__c;
            caseRec.US_WSREMS__Zipcode__c = healthCareAccount.get(0).US_WSREMS__Zip__c;
            caseRec.US_WSREMS__Address_Line_1__c = healthCareAccount.get(0).US_WSREMS__Address_Line_1__c;
            caseRec.US_WSREMS__Address_Line_2__c = healthCareAccount.get(0).US_WSREMS__Address_Line_2__c;
            caseRec.recordTypeId = caseRecordTypeId;
            caseRec.US_WSREMS__Name__c = prescriberAccount.get(0).Name;
            caseRec.US_WSREMS__REMS_ID__c = prescriberAccount.get(0).US_WSREMS__REMS_ID__c;
            caseRec.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
            caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
            caseRec.US_WSREMS__Participant__c = prescriberAccount.get(0).Id;
            caseRec.US_WSREMS__REMS_Service_Summary__c = serviceSummary.Id;
            caseRec.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
            caseRec.US_WSREMS__Credential__c = prescriberAccount.get(0).US_WSREMS__Credentials__c;
            if (prescriberAccount.get(0).US_WSREMS__Credentials__c == REMSAppLiterals.CREDENTIALS_OTHER){
                caseRec.US_WSREMS__Credential__c = REMSAppLiterals.CREDENTIALS_OTHER;
                caseRec.US_WSREMS__Other_Credentials__c = prescriberAccount.get(0).US_WSREMS__Other_Credentials__c;
            }
            caseRec.US_WSREMS__Participant__c = accountId;
            caseRec.US_WSREMS__Prescriber__c = accountId;
            caseRec.US_WSREMS__Requestor_Type__c = 'Prescriber';
            caseRec.US_WSREMS__Prescriber_Signature__c = 'Yes';
            caseRec.US_WSREMS__Signature__c = 'Yes';
            caseRec.US_WSREMS__Signature_Date__c = Date.Today();
            caseRec.US_WSREMS__Signature_Date_Pharmacist__c = Date.Today();
            caseRec.Email_address__c = prescriberAccount.get(0).PersonEmail;
            caseRec.US_WSREMS__Email__c = prescriberAccount.get(0).PersonEmail;
            caseRec.US_WSREMS__State_License_Number__c = prescriberAccount.get(0).US_WSREMS__SLN__c;
            caseRec.US_WSREMS__SLN__c = prescriberAccount.get(0).US_WSREMS__SLN__c;
            caseRec.US_WSREMS__SLN_Issued_State__c = prescriberAccount.get(0).US_WSREMS__SLN_State__c;
            caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Deactivation';
            insert caseRec;
            serviceSummary = NPISearchControllerPortal.updateServiceSummary(serviceSummary);
            return true;
    } 
}