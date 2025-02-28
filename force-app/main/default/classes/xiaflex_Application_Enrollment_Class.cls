public without sharing class xiaflex_Application_Enrollment_Class {

    @AuraEnabled
    public static Account getDuplicate(String arRecords,String programType){
        // for AR
        String programName = Label.Xiaflex_REMS_Program_Name;
        String query = 'Select Id, Salutation, Name, Phone, Fax, US_WSREMS__Role__c, US_WSREMS__Other__c, US_WSREMS__Preferred_Contact_Method__c From Account where  RecordType.Name  = \'Pharmacy/HCS Participant\' AND Program_Name__c=:programName AND US_WSREMS__Program_Type__c =: programType';
        Map<String,object> arMap = (Map<String,object>)JSON.deserializeUntyped(arRecords);
        Map<String,String> queryMap = new Map<String,String>();
            for(String key: arMap.KeySet() ){
            queryMap.put(key,String.valueOf(arMap.get(key)));
        }
        for(String key: queryMap.keySet()){
            if(key == 'email'){
                query = query + ' AND ' + 'PersonEmail' + ' = \'' + queryMap.get(key) + '\'';
            } else if(key == 'firstName'){
                String escapedAccountName = String.escapeSingleQuotes(queryMap.get(key));
            	query = query + ' AND ' + key + ' Like \'%' + escapedAccountName + '%\'';
            }else{
                query = query + ' AND ' + key + ' = \'' + queryMap.get(key) + '\'';
            }
        }
        query = query + ' Limit 1';
        Account[] acc = Database.query(query);
        if(acc != null && acc.size() > 0)
            return acc[0];
        else {
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Account getLoggedInUserAccount(String userId){
        User logUser = SYN_CommonUtility.getCurrentUserContactDetails(userId);
        return [Select Id, FirstName, LastName, US_WSREMS__Legal_Guardian_Relationship__c, US_WSREMS__Legal_Guardian_Name__c, US_WSREMS__Phone_Type__c, US_WSREMS__Healthcare_Setting_Type__c, MiddleName, PersonEmail, Phone, Fax, US_WSREMS__Professional_Designation__c, US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Specialty__c, US_WSREMS__Other_Credentials__c, US_WSREMS__SLN__c, US_WSREMS__SLN_State__c From Account where Id =: logUser.Contact.AccountId Limit 1];      
    }

    @AuraEnabled
    public static list<Account> getAccountRecordForSearch(String inputValue,String participantType, String programType){
        String programName = Label.Xiaflex_REMS_Program_Name;
        List<String> accountStatusList = new List<String>{'', 'Pending','Initiated', 'Certified','Disenrolled', 'Deactivated','Cancelled'};
        if (!String.isEmpty(participantType)) {
                Id pharmacyRecordtypeId    = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Health Care Setting').getRecordTypeId();
        }
        String queryString = 'Select Id,'+(participantType == 'Healthcare'? 'Name,' : 'FirstName, LastName,')+' US_WSREMS__Address_Line_1__c, US_WSREMS__REMS_ID__c, US_WSREMS__Status__c, US_WSREMS__City__c, US_WSREMS__National_Provider_Identifier__c,  US_WSREMS__State__c, US_WSREMS__SLN_State__c, US_WSREMS__Zip__c, Phone, SYN_Ref_Id__c'+ 
            ' FROM Account WHERE RecordTypeId =:pharmacyRecordtypeId AND Program_Name__c=:programName AND US_WSREMS__Program_Type__c =: programType';
            queryString += participantType=='Healthcare' ? ' AND (US_WSREMS__Status__c IN :accountStatusList  OR (US_WSREMS__Status__c = \'Decertified\' AND US_WSREMS__Sub_Status__c = \'Enrollment Expired\')) ' : '';
            queryString += '  AND (';
            List<String> conditions = new List<String>();
            if (!String.isEmpty(inputValue)) {
                conditions.add(' Name LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__State__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__Zip__c LIKE \'%' + inputValue + '%\'');
                conditions.add(' US_WSREMS__REMS_ID__c LIKE \'%' + inputValue + '%\'');                
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

    @AuraEnabled(cacheable=true)
    public static list<US_WSREMS__Affiliation__c> getHCPRecordForSearch(String inputValue, String programType){
        String programName = Label.Xiaflex_REMS_Program_Name;
        Id prescriberRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        String queryString = 'SELECT Id, US_WSREMS__Prescriber__c, US_WSREMS__Prescriber__r.Phone, US_WSREMS__Prescriber__r.US_WSREMS__REMS_ID__c, US_WSREMS__Prescriber__r.Name, US_WSREMS__Prescriber__r.US_WSREMS__Status__c, US_WSREMS__Prescriber__r.FirstName, US_WSREMS__Prescriber__r.LastName, US_WSREMS__Prescriber__r.US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Health_Care_Setting__r.Name, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c, US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Prescriber__c != NULL AND US_WSREMS__isActive__c = TRUE';
        queryString += ' AND US_WSREMS__Prescriber__r.RecordTypeId = :prescriberRecordtypeId AND US_WSREMS__Prescriber__r.US_WSREMS__Program_Picklist__c = :programName AND US_WSREMS__Prescriber__r.US_WSREMS__Program_Type__c =: programType ';
        List<String> conditions = new List<String>();
        if (!String.isEmpty(inputValue)) {
            inputValue = inputValue.trim();
            conditions.add(' US_WSREMS__Prescriber__r.Name LIKE \'%' + inputValue + '%\'');
            conditions.add(' US_WSREMS__Prescriber__r.FirstName LIKE \'%' + inputValue + '%\'');
            conditions.add(' US_WSREMS__Prescriber__r.LastName LIKE \'%' + inputValue + '%\'');
            conditions.add(' US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c LIKE \'%' + inputValue + '%\'');
            conditions.add(' US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c LIKE \'%' + inputValue + '%\'');
            conditions.add(' US_WSREMS__Prescriber__r.US_WSREMS__REMS_ID__c LIKE \'%' + inputValue + '%\'');
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
    
     @AuraEnabled
    public static Map<String,Map<String,String>> getPicklistFieldValues(){
        Map<String,Map<String,String>> mapToReturn = new Map<String,Map<String,String>>();
        String objectName = 'Account';
        
        List<String> fieldNameList = new List<String>();
        fieldNameList.add('US_WSREMS__State__c');
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        for(String fieldName: fieldNameList){
            
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            Map<String,String> picklistMap = new Map<String,String>();
            for( Schema.PicklistEntry pickListVal : ple){
                picklistMap.put(pickListVal.getLabel(), pickListVal.getValue());
            }
            mapToReturn.put(fieldName,picklistMap);
        }
        return mapToReturn;
    }
    
    @AuraEnabled
    public static String insertHCPData(Map<String,String> inputRecords){
           Savepoint sp = Database.setSavepoint();
        try{
            String prescriberRecord = inputRecords.get('prescriberRecord');
            String hcsRecord = inputRecords.get('hcsRecord');
            String programType = inputRecords.get('programType');
            String programName = inputRecords.get('programName');
            String base64Content = inputRecords.get('signatureData');
            Boolean statusCertified = false;
            List<US_WSREMS__REMS_Service_Summary__c> serviceToUpdate = new List<US_WSREMS__REMS_Service_Summary__c>();
            Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
			Map<String,Id> caseRecordTypeNameMap = REMSUtility.retrieveRecTypeNameId('Case');

            List<US_WSREMS__REMS_Program__c>  program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =:programName];
            xiaflex_ManagePharmacies.RecordDataWrapper prescriberObj = (xiaflex_ManagePharmacies.RecordDataWrapper)System.JSON.deserialize(prescriberRecord ,xiaflex_ManagePharmacies.RecordDataWrapper.class);
            xiaflex_ManagePharmacies.RecordDataWrapper hcsObj = (xiaflex_ManagePharmacies.RecordDataWrapper)System.JSON.deserialize(hcsRecord ,xiaflex_ManagePharmacies.RecordDataWrapper.class);       
            // if existing prescriber is selected for prescriber enrollment this block is inserting prescriber enrollment case and service for MDP and in case of REMS updating existing account
            // and creating prescriber enrollment
            if(prescriberObj != null){
                Account prescriberAcc = new Account();
                if(programType == 'MDP'){
                    if(String.isEmpty(prescriberObj.Id)) {
                        prescriberAcc = xiaflex_ManagePharmacies.insertAccount(prescriberObj, program, true, REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER);
                        prescriberAcc.US_WSREMS__Program_Type__c = 'MDP';
                        prescriberAcc.US_WSREMS__National_Provider_Identifier__c = prescriberObj.npi;
                        prescriberAcc.US_WSREMS__NCPDP__c = prescriberObj.NCPDP;
                        prescriberAcc.US_WSREMS__HIN__c = prescriberObj.HIN;
                        prescriberAcc.US_WSREMS__DEA__c=prescriberObj.DEA;
                        Insert prescriberAcc;
                        US_WSREMS__REMS_Service_Summary__c serviceCreation = xiaflex_ManagePharmacies.insertServiceSummary(prescriberAcc,program,'Prescriber','Participant_Enrollment');
                        insert serviceCreation;
                        serviceToUpdate.add(serviceCreation);
                        Case caseCreation = xiaflex_ManagePharmacies.insertCase( prescriberObj, prescriberAcc, serviceCreation, program,'Prescriber',REMSAppLiterals.REQUESTORTYPE_PRESCRIBER, caseRecordTypeNameMap.get('Prescriber Person Account'), false);      
                        caseCreation.US_WSREMS__Program_Type__c = 'MDP';
                        caseCreation.Status = 'Complete';
                        caseCreation.US_WSREMS__Outcome__c = 'Complete';
                        insert caseCreation;
                    }
                    String prescriberId = String.isNotEmpty(prescriberObj.Id) ? prescriberObj.Id : prescriberAcc.Id;
                    prescriberAcc = [SELECT Id, US_WSREMS__Status__c, US_WSREMS__Date_Enrolled__c,US_WSREMS__Healthcare_Setting_Type__c, PersonEmail, US_WSREMS__REMS_ID__c FROM Account WHERE Id = :prescriberId];
                } else{
                    prescriberAcc = xiaflex_ManagePharmacies.updateAccount(prescriberObj, program, true, REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER);
                    prescriberAcc.Id = prescriberObj.Id;
                    List<Case> pacCase = [Select Id from case where US_WSREMS__Participant__c =: prescriberAcc.Id AND RecordType.Name = 'Prescriber Person Account' Limit 1];
                   Case caseCreation = xiaflex_ManagePharmacies.insertCase( prescriberObj, prescriberAcc, null, program,'Prescriber',REMSAppLiterals.REQUESTORTYPE_PRESCRIBER, SYN_CommonUtility.getPPARecordType('Prescriber Person Account'), false);      
                    Update prescriberAcc;
                    caseCreation.Id = pacCase[0].Id;
                   Update caseCreation;
                }
                if(Test.isRunningTest())
                    Test.startTest();
                // If existing HCS is selected assign it to the prescriber selected above
                // check if it is certified or not and update the cases and account accordingly
                // if new HCS is getting inserted , check duplicate and assign to prescriber
                // for new HCS create participant account creation case and service
                // if enrollment success send email to create a new user for MDP Portal
                if(hcsObj != null){
                    List<Account> hcsAccountList = new List<Account>();
                    US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
                    if(hcsObj.Id == null){
                        Account hcsAccount = xiaflex_ManagePharmacies.insertAccount(hcsObj, program, false, REMSAppLiterals.ACCOUNT_RECORDTYPE_HEALTHCARESETTING);
                        Boolean dupCheck = xiaflex_ManagePharmacies.checkDuplicate(hcsAccount, programType == 'MDP' ? 'MDP' : 'REMS' );
                        if(dupCheck){
                            return 'dupFound';
                        }
                        if(programType == 'MDP'){
                            hcsAccount.US_WSREMS__Program_Type__c = 'MDP';
                        }
                        insert hcsAccount;
                        hcsAccountList = [SELECT Id, Name, US_WSREMS__Address_Line_1__c, US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Zip__c, US_WSREMS__Healthcare_Setting_Type__c, US_WSREMS__REMS_ID__c from Account WHERE Id =: hcsAccount.Id LIMIT 1];
                        US_WSREMS__REMS_Service_Summary__c serviceCreation = xiaflex_ManagePharmacies.insertServiceSummary(hcsAccountList[0],program,'Health Care Setting','Participant_Enrollment');
                        insert serviceCreation;
                        serviceToUpdate.add(serviceCreation);
                        Case caseRec2 = xiaflex_ManagePharmacies.insertCase( hcsObj, hcsAccountList[0], serviceCreation,program,'Health_Care_Setting',REMSAppLiterals.REQUESTORTYPE_HCS, caseRecordTypeMap.get('Health_Care_Setting'), false);
                      	caseRec2.Status = 'Complete';
                    	caseRec2.US_WSREMS__Outcome__c = 'Complete';
                        if(programType == 'MDP'){
                             caseRec2.US_WSREMS__Program_Type__c = 'MDP';     
                        }
                        Insert caseRec2;
                       affiliationRec = xiaflex_ManagePharmacies.insertAffiliation(prescriberAcc.Id, program, hcsAccount.Id, 'Prescriber Affiliation');
                    } else{
                        hcsAccountList = [SELECT Id, Name, US_WSREMS__Status__c, US_WSREMS__Address_Line_1__c, US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Zip__c, US_WSREMS__Healthcare_Setting_Type__c, US_WSREMS__REMS_ID__c from Account WHERE Id =: hcsObj.Id LIMIT 1];
                        affiliationRec = xiaflex_ManagePharmacies.insertAffiliation(prescriberAcc.Id, program, hcsObj.Id, 'Prescriber Affiliation');
                        if(hcsAccountList[0].US_WSREMS__Status__c == 'Certified'){
                            statusCertified = true;
                        }
                    }
                    US_WSREMS__REMS_Service_Summary__c serviceEnrollment = xiaflex_ManagePharmacies.insertServiceSummary(prescriberAcc,program,'Prescriber','Enrollment');
                    insert serviceEnrollment;
                    Case caseRec = xiaflex_ManagePharmacies.insertCase( prescriberObj, prescriberAcc, serviceEnrollment,program,'Prescriber',REMSAppLiterals.REQUESTORTYPE_PRESCRIBER, caseRecordTypeMap.get('Prescriber_enrollment'), true);      
                    caseRec.US_WSREMS__Signature_Date_Pharmacist__c = Date.today();
                    if(statusCertified){
                        caseRec.Status = 'Complete';
                        caseRec.US_WSREMS__Outcome__c = 'Complete';
                        prescriberAcc.US_WSREMS__Status__c = 'Certified';
                        prescriberAcc.US_WSREMS__Date_Enrolled__c = system.today();
                    } else{
                        caseRec.HCSnotCertified__c = true;
                        caseRec.US_WSREMS__Incomplete_Reasons__c = SYN_Utilitycls.HCS_NOT_CEERTIFIED;
                    }
                    	caseRec.US_WSREMS__Healthcare_Setting__c = hcsAccountList[0].Id;
                        caseRec.US_WSREMS__Name__c =  hcsAccountList[0].Name;
                        caseRec.US_WSREMS__City__c = hcsAccountList[0].US_WSREMS__City__c;
                        caseRec.US_WSREMS__State__c =  hcsAccountList[0].US_WSREMS__State__c;
                        caseRec.US_WSREMS__Address_Line_1__c =  hcsAccountList[0].US_WSREMS__Address_Line_1__c;
                        caseRec.US_WSREMS__Zip__c =  hcsAccountList[0].US_WSREMS__Zip__c; 
                        //no longer used the setting type in MDP portal.
                        if(programType=='REMS') 
                        {
                            caseRec.US_WSREMS__Healthcare_Setting_Type__c =  prescriberAcc.US_WSREMS__Healthcare_Setting_Type__c;
                        }                        
                    if(programType == 'MDP'){    
                    	caseRec.US_WSREMS__Program_Type__c = 'MDP';
                    }
                    insert caseRec;
                    for(US_WSREMS__REMS_Service_Summary__c service: serviceToUpdate){
                       service.US_WSREMS__Path_Stage_Name__c = REMSAppLiterals.SERVICE_STATUS;
                       service.US_WSREMS__StageName__c = REMSAppLiterals.SERVICE_STATUS;
                    }
                    if(statusCertified){
                     update prescriberAcc;
                         serviceEnrollment.US_WSREMS__Path_Stage_Name__c = REMSAppLiterals.SERVICE_STATUS;
                         serviceEnrollment.US_WSREMS__StageName__c = REMSAppLiterals.SERVICE_STATUS;
						 serviceToUpdate.add(serviceEnrollment);
                    }else if(prescriberAcc.US_WSREMS__Status__c == 'Initiated' ||prescriberAcc.US_WSREMS__Status__c ==  null){
                        prescriberAcc.US_WSREMS__Status__c = 'Pending';
                        update prescriberAcc;
                        serviceEnrollment.US_WSREMS__Path_Stage_Name__c = 'Intake';
                        serviceEnrollment.US_WSREMS__StageName__c = 'Intake';
                        serviceEnrollment.US_WSREMS__Status__c = 'Open';
                        serviceEnrollment.US_WSREMS__Service_Outcome__c='';
                        serviceToUpdate.add(serviceEnrollment);

                    }
                   update serviceToUpdate;
                    affiliationRec.US_WSREMS__REMS_Service__c = serviceEnrollment.Id;
                    if(!statusCertified){
                        affiliationRec.US_WSREMS__isActive__c = false;
                        affiliationRec.US_WSREMS__Start_Date__c = null;
                    }
                    insert affiliationRec;
                    if(programType == 'MDP'){
                        sendEnrollmentMail(prescriberAcc);
                    }
                    SavePrescriberSignature(caseRec.Id,null,base64Content);
                }
            }
            return 'Success';
        }catch (Exception ex) {
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        } 
    }
    
    public static String SavePrescriberSignature(String accountId, String agreementStatus, String b64SignData){
        try {
            //Create Attachment
            Attachment n = new Attachment(ParentId = accountId,Name = 'Signature_'+String.valueOf(Date.today()).substring(0,10),
                                         Body =  EncodingUtil.base64Decode(b64SignData),contentType = 'image/jpeg');
            insert n;
            return '';
        }
        catch (Exception e)
        {
            String errorMessage = e.getMessage();          
            return errorMessage;
        }
    } 
    
    public static void sendEnrollmentMail(Account personAccount){
        string supportEmail = Label.XIAFLEXMDPSupportEmail;
        OrgWideEmailAddress[] owea = SYN_CommonUtility.getOrgWideEmailAddress(supportEmail);
        if(!Test.isRunningTest()  && personAccount.Id != null) {
            //Create parameter
            Map<String, Object> Params = new Map<String, Object>();
            MACIAutomationCommunicationUtility.Requests  rst = new MACIAutomationCommunicationUtility.Requests();
            rst.accountId = personAccount.id;
            rst.BccAddress = owea[0].address;
            rst.toAddress = personAccount.PersonEmail;
            rst.fromAddress = owea[0].address;
            rst.templateName = System.label.Xiaflex_Prescriber_invitation_MDP_Template;  
            List<MACIAutomationCommunicationUtility.Requests> sendmaillist = new List<MACIAutomationCommunicationUtility.Requests>();
            sendmaillist.add(rst);
            MACIAutomationCommunicationUtility.sendNotificationFromFlow(sendmaillist);
        }        
    }
    
    
    public static String createChangeOfInfoCaseAndService(xiaflex_ManagePharmacies.RecordDataWrapper recordData, Account acc, List<US_WSREMS__REMS_Program__c>  program, String recordType, String participantType, String programType){
        List<US_WSREMS__REMS_Service_Summary__c> serviceToUpdate = new List<US_WSREMS__REMS_Service_Summary__c>();
         Savepoint sp = Database.setSavepoint();
        try{
            US_WSREMS__REMS_Service_Summary__c serviceSummary = xiaflex_ManagePharmacies.insertServiceSummary(acc, program, participantType, REMSAppLiterals.CHANGE_OF_INFORMATION);
            insert serviceSummary;
            serviceToUpdate.add(serviceSummary);
            Case caseRec;
           if(serviceSummary != null){
               Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get(REMSAppLiterals.CHANGE_OF_INFORMATION);
               caseRec = xiaflex_ManagePharmacies.insertCase(recordData, acc, serviceSummary, program, recordType, participantType, caseRecordTypeId, false);
               caseRec.US_WSREMS__Program_Type__c = programType;
               caseRec.Status = 'Complete';
               caseRec.US_WSREMS__Outcome__c = 'Complete';
               insert caseRec;
            }        
            if(caseRec != null){
                xiaflex_ManagePharmacies.updateService(serviceToUpdate);
            }
            return 'Success';
        } catch (Exception ex){
            Database.rollback(sp);
            return ex.getMessage();
        }
    }

}