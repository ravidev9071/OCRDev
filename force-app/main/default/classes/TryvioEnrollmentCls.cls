/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class TryvioEnrollmentCls {
    
    static String FORM_TYPE = '';

    @AuraEnabled(cacheable=true)
    public static String getNPISearch(String searchNPIKey, String programName, String caseRecordTypeDevName) {
        SYN_VeevaAPI_Search.programName = programName;
        return SYN_VeevaAPI_Search.getNPIStatusVeeva_tryvio(searchNPIKey, programName, caseRecordTypeDevName);
    }

    @AuraEnabled(cacheable=true)
    public static SYN_VeevaAPI_Search.pharmacyInfoPrepopWrap getAccFromNPI(String npiValue, String programName) {
        try {
            
            List<Account> accList = [
                SELECT Id, Name, MiddleName,US_WSREMS__Status__c,Type,US_WSREMS__Address_Line_1__c,US_WSREMS__City__c,
                PersonEmail,Phone,Fax,US_WSREMS__SLN__c,US_WSREMS__SLN_State__c,US_WSREMS__Address_Line_2__c,US_WSREMS__Authorized_Representative__c,
                US_WSREMS__Professional_Designation__c, US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__State__c,
                US_WSREMS__National_Provider_Identifier__c, US_WSREMS__Specialty__c, US_WSREMS__Other_Credentials__c,US_WSREMS__Zip__c,US_WSREMS__EXT__c,
                US_WSREMS__Authorized_Representative__r.FirstName,US_WSREMS__Authorized_Representative__r.LastName,US_WSREMS__Authorized_Representative__r.MiddleName,
                US_WSREMS__Authorized_Representative__r.US_WSREMS__Participant_Title__c,US_WSREMS__Authorized_Representative__r.US_WSREMS__Credentials__c,
                US_WSREMS__Authorized_Representative__r.Phone,US_WSREMS__Authorized_Representative__r.US_WSREMS__EXT__c,US_WSREMS__Authorized_Representative__r.Fax,
                US_WSREMS__Authorized_Representative__r.US_WSREMS__Email__c,US_WSREMS__Authorized_Representative__r.US_WSREMS__Preferred_Contact_Method__c,
                US_WSREMS__Authorized_Representative__r.US_WSREMS__Other__c,US_WSREMS__Facility_Type__c,FirstName,LastName
                FROM Account WHERE  US_WSREMS__National_Provider_Identifier__c  =: npiValue AND US_WSREMS__REMS_Program__r.Name = :programName Limit 1];
        System.debug(LoggingLevel.DEBUG,accList);
        SYN_VeevaAPI_Search.pharmacyInfoPrepopWrap PresInfo =  SYN_VeevaAPI_Search.PharmaNPIreturnValue(npiValue);
        return PresInfo;
        
    } catch (Exception e) {
        System.debug(LoggingLevel.DEBUG, 'Error: ' + e.getMessage());
        throw new AuraHandledException('Error retrieving Account: ' + e.getMessage());
    }
    }

    @AuraEnabled
    public static String insertDataOnSubmit(Map<String,String> inputRecords){
        try{
        System.debug(LoggingLevel.DEBUG,'inputRecords::::'+inputRecords);
        List<sObject> objToInsert = new List<sObject>();
        Map<String,Id> recordTypeMap = new Map<string,Id>();
        for(RecordType recType: [Select Name,developername, SobjectType, Id from RecordType where 
            Name In ('Prescriber Enrollment','Prescriber','Pharmacy/HCS Participant','HCS Enrollment', 'Prescriber Person Account', 'Enrollment' ,'Outpatient Pharmacy','Outpatient Pharmacy Enrollment','Knowledge Assessment','Prescriber enrollment', 'Inpatient Pharmacy', 'Inpatient Pharmacy Enrollment','Office Contact')]){

            // Included both IPP & OPP record types in below code
                if((recType.name == 'Pharmacy/HCS Participant' || recType.name == 'Prescriber' || recType.name == 'Office Contact') && recType.SobjectType == 'Account') {
                recordTypeMap.put(recType.Name, recType.Id);
            } else if((recType.developername == 'Outpatient_Pharmacy_Enrollment' || recType.developername == 'Outpatient_Pharmacy' || recType.developername == 'Prescriber_Person_Account' || recType.developername == 'Knowledge_Assessment' || recType.developername == 'Prescriber_enrollment' || recType.DeveloperName == 'Inpatient_Pharmacy_Enrollment' || recType.DeveloperName == 'Inpatient_Pharmacy') && recType.SobjectType == 'Case'){
                recordTypeMap.put(recType.developername, recType.Id);
            }
        }
        String recordDetails = inputRecords.get('recordDetails');
        String pharmacyId = inputRecords.get('pharmacyId');
        String programName = inputRecords.get('programName');
        String profileName = inputRecords.get('profileName');
        String permissionSet = inputRecords.get('permissionSet');
        String base64Content = inputRecords.get('signatureData');
        String participantType= inputRecords.get('participantType');
        String casecreation= inputRecords.get('casecreation');
        String Accountid= inputRecords.get('AccountId');
        String dispensebase64Content = inputRecords.get('dispenssignatureData');
        FORM_TYPE= inputRecords.get('formType');
        List<US_WSREMS__REMS_Program__c>  program = [SELECT Id,Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =:programName];     
        RecordDataWrapper recordData = (RecordDataWrapper)System.JSON.deserialize(recordDetails,RecordDataWrapper.class);
        
        if(participantType=='Prescriber'){
            if(casecreation=='prescribercase'){
                System.debug(LoggingLevel.DEBUG,'inside elseif: '+casecreation+' '+participantType);
               Account PresAccount = insertPrescriberAccount(recordData,program, recordTypeMap.get('Prescriber'),true,false,false);
                system.debug('created account --'+PresAccount);
                US_WSREMS__REMS_Service_Summary__c serviceCreation = insertServiceSummary(PresAccount,program,'Prescriber',REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
                Case caseRec = insertCase( recordData, PresAccount, serviceCreation,program,'Prescriber_Person_Account',null ,REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER, recordTypeMap.get('Prescriber_Person_Account'),null);
                return(String.valueOf(PresAccount.Id));
            }else if(casecreation=='kacase'){
                if(Accountid!=null){
                    List<case> cslst=[select id,RecordType.DeveloperName from case where US_WSREMS__Prescriber__c=:Accountid and RecordType.DeveloperName='Knowledge_Assessment' limit 1];
                    if(cslst.size()>0){
                        return cslst[0].id;
                    }else{
                        Account PresAccount= [SELECT id,name,US_WSREMS__Status__c from account where id=:Accountid];
                        US_WSREMS__REMS_Service_Summary__c serviceKnowledge = insertServiceSummary(PresAccount,program,'Prescriber','KnowledgeAssessment');
                        Case caseRec = insertprescriberCase( recordData, PresAccount, serviceKnowledge,program,'Knowledge_Assessment',null ,REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER, recordTypeMap.get('Knowledge_Assessment'),null,null,null);
                        PresAccount.US_WSREMS__Status__c = 'Pending';
                        update PresAccount;
                        return(String.valueOf(caseRec.Id));
                    }  
                }else{
                    
                    return null;
                }
            }else{
                if(Accountid!=null){
                    System.debug(LoggingLevel.INFO,'enterd in enrollment case creation');
                    Account PresAccount= [select id,SYN_Ref_Id__c from account where id=:Accountid];
                     Account officeacc = new Account();
                     Account officeacc1 = new Account();
                    if(recordData.pfirstname!=null && recordData.plastname!=null){
                         System.debug(LoggingLevel.INFO,'enterd in office contact1 creation');
                        List<Account> officeAccountList = [SELECT Id FROM Account WHERE FirstName =: recordData.pfirstname AND LastName =: recordData.plastname 
                                                           AND US_WSREMS__REMS_Program__r.Name =:programName AND recordtype.DeveloperName = 'Office_Contact' Limit 1];
                        
                        System.debug(officeAccountList);
                       
                        if(officeAccountList.isEmpty()){
                            officeacc = insertPrescriberAccount(recordData,program,recordTypeMap.get('Office Contact'),false,True,False);
                        } else{
                            officeacc = officeAccountList[0];
                        }
                    }
                    if(recordData.sfirstname!=null && recordData.sfirstname!=null){
                        System.debug(LoggingLevel.INFO,'enterd in office contact2 creation');
                        List<Account> officeAccountList1 = [SELECT Id FROM Account WHERE FirstName =: recordData.sfirstname AND LastName =: recordData.slastname 
                                                            AND US_WSREMS__REMS_Program__r.Name =:programName AND recordtype.DeveloperName = 'Office_Contact' Limit 1];
                        
                        System.debug(LoggingLevel.DEBUG,officeAccountList1);
                        
                        if(officeAccountList1.isEmpty()){
                            officeacc1 = insertPrescriberAccount(recordData,program,recordTypeMap.get('Office Contact'),false,false,true);
                        } else{
                            
                            officeacc1 = officeAccountList1[0];
                        }
                    }
                    System.debug(LoggingLevel.DEBUG,'officeacc222'+officeacc);
                    System.debug(LoggingLevel.DEBUG,'officeacc111'+officeacc);
                    US_WSREMS__REMS_Service_Summary__c serviceEnrollment = insertServiceSummary(PresAccount,program,'Prescriber','Enrollment');
                    Case caseRec = insertprescriberCase( recordData, PresAccount, serviceEnrollment,program,'Prescriber_enrollment',null ,REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER, recordTypeMap.get('Prescriber_enrollment'),null,officeacc,officeacc1);
                    insertPrescriberSignature(PresAccount.Id,null,base64Content);
                    if(recordData.dispensesign=='true' && dispensebase64Content!=null){
                       insertPrescriberSignature(PresAccount.Id,null,dispensebase64Content); 
                    }
                    PresAccount.US_WSREMS__Preferred_Contact_Method__c=recordData.preferredContactMethod;
                    PresAccount.US_WSREMS__Status__c = 'Certified';
                    PresAccount.Medical_Specialty__c = recordData.specialty;
                    PresAccount.US_WSREMS__Professional_Designation__c = recordData.proffDesig;
                    PresAccount.Office_Practice_Clinic_Name__c = recordData.officePractice;
                    PresAccount.US_WSREMS__Phone_Number__c = recordData.offPhone;
                    PresAccount.SYN_Alternate_Phone_Ext__c =recordData.ext;
                    PresAccount.Fax = recordData.fax;
                    PresAccount.FirstName = recordData.firstName;
                    PresAccount.MiddleName = recordData.middleName;
                    PresAccount.LastName = recordData.lastName;
                    PresAccount.PersonEmail = recordData.email;
                    PresAccount.US_WSREMS__Email__c = recordData.email;
                    PresAccount.Phone = recordData.phone;
                    PresAccount.Fax = recordData.fax;
                    PresAccount.US_WSREMS__Address_Line_1__c = recordData.address1;
                    PresAccount.US_WSREMS__Address_Line_2__c = recordData.address2;
                    PresAccount.US_WSREMS__City__c = recordData.city;
                    PresAccount.US_WSREMS__State__c = recordData.state;
                    PresAccount.US_WSREMS__Zip__c = recordData.zip;
                    PresAccount.Medical_Specialty__c = recordData.specialty;
                    PresAccount.US_WSREMS__Other__c = recordData.otherSpecialty;
                    PresAccount.US_WSREMS__EXT__c = recordData.ext;
                    update PresAccount;

                    try {
                        Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.CASE_OBJECT).get('Prescriber_Office_Contact');
                        US_WSREMS__REMS_Service_Summary__c serviceCreation = insertServiceSummary(officeacc,program, 'Office Contact',REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
                        Case caseRecOff = insertOfficeCase( recordData, officeacc, serviceCreation,program, 'Prescriber_Office_Contact');
                        US_WSREMS__REMS_Service_Summary__c serviceCreationSec = insertServiceSummary(officeacc1,program, 'Office Contact',REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
                        Case caseRecOffSec = insertOfficeCase( recordData, officeacc1, serviceCreationSec,program, 'Prescriber_Office_Contact');
                        Id pharmacyAffRecId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByName().get('Office Contact Affiliation').getRecordTypeId();
                    } catch (Exception ex) {
                        System.debug(LoggingLevel.ERROR,'Exception Office Contact '+ ex.getMessage()+ex.getLineNumber());
                        throw new AuraHandledException(ex.getMessage());
                    }
                    System.debug(LoggingLevel.INFO,'TEsting Value caseRec111' + caseRec.Id);
                    
                    return(String.valueOf(PresAccount.Id));
                    
                }else {
                    return null;
                }  
            }
          
        }else {
            List<Account> arAccountList = [SELECT Id FROM Account WHERE US_WSREMS__Email__c = :recordData.AR.email 
                    AND FirstName =: recordData.AR.firstName AND LastName =: recordData.AR.lastName 
                    AND US_WSREMS__REMS_Program__r.Name =:programName AND recordType.name = 'Pharmacy/HCS Participant'];
            System.debug(arAccountList);
            String requestForType = (FORM_TYPE == 'IPP')? REMSAppLiterals.REQUESTORTYPE_INPATIENT : REMSAppLiterals.REQUESTORTYPE_OUTPATIENT;
            Account ar = new Account();
            if(arAccountList.isEmpty()){
                ar = insertARAccount(recordData,program,recordTypeMap.get('Pharmacy/HCS Participant'), requestForType);
            } else{
                ar = arAccountList[0];
            }
            
            Account ppAccount;
            String recTypeForEnrollment = (FORM_TYPE == 'IPP')? REMSAppLiterals.ACCOUNT_RECORDTYPE_INPATIENTPHARMACY : REMSAppLiterals.ACCOUNT_RECORDTYPE_OUTPATIENTPHARMACY;

            String enrollParticipantType = (FORM_TYPE == 'IPP')? 'Inpatient Pharmacy' : 'Outpatient Pharmacy';
            String caseRecType = (FORM_TYPE == 'IPP')? 'Inpatient_Pharmacy' : 'Outpatient_Pharmacy';
            String caseEnrollmentRecType = (FORM_TYPE == 'IPP')? 'Inpatient_Pharmacy_Enrollment' : 'Outpatient_Pharmacy_Enrollment';

            ppAccount = insertAccount(recordData,program, false, recTypeForEnrollment);
            system.debug(LoggingLevel.DEBUG,'created account --'+ppAccount);
            insertPrescriberSignature(ppAccount.Id,null,base64Content);
            
            US_WSREMS__REMS_Service_Summary__c serviceCreation = insertServiceSummary(ppAccount,program, enrollParticipantType,REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
            US_WSREMS__REMS_Service_Summary__c serviceEnrollment = insertServiceSummary(ppAccount,program, enrollParticipantType,'Enrollment');
            Case caseRec = insertCase( recordData, ppAccount, serviceCreation,program, caseRecType,null , requestForType, recordTypeMap.get( caseRecType),null);
            Case caseRec2 = insertCase( recordData, ppAccount, serviceEnrollment,program,caseEnrollmentRecType,null , requestForType, recordTypeMap.get(caseEnrollmentRecType),ar.Id);
            Id pharmacyAffRecId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByName().get('Pharmacy User Affiliation').getRecordTypeId();
            US_WSREMS__Affiliation__c affRec = insertAffiliation(ar, program, ppAccount.Id, pharmacyAffRecId, recordData);
            ppAccount.US_WSREMS__Status__c = 'Certified - On Hold';
            update ppAccount;
            return(String.valueOf(ppAccount.Id));
        }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR,'Exception'+ex.getMessage()+ex.getLineNumber());
        }
        return null;
    }

    @AuraEnabled
    public static Map<String,Map<String,String>> getPicklistFieldValues(){
        Map<String, Map<String, String>> mapToReturn = new Map<String, Map<String, String>>();
        String objectName = 'Account';
        
        List<String> fieldNameList = new List<String>{'US_WSREMS__State__c','US_WSREMS__Participant_Title__c'};        
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        for(String fieldName : fieldNameList) {
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            Map<String, String> picklistMap = new Map<String, String>();
            for(Schema.PicklistEntry pickListVal : ple) {
                System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
                picklistMap.put(pickListVal.getLabel(), pickListVal.getValue());  
            }
            mapToReturn.put(fieldName, picklistMap);
            System.debug(LoggingLevel.DEBUG,'picklistMap->'+ picklistMap);
            System.debug(LoggingLevel.DEBUG,'mapToReturn->'+ mapToReturn);
        }
        return mapToReturn;
    }

    /*public static boolean fetchDuplicateNpi(String npi, String programName) {
        Boolean duplicateNPI = [SELECT COUNT() FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = :npi AND US_WSREMS__REMS_Program__r.Name =:programName] > 0;
        return duplicateNPI;
    }*/
 
    public static US_WSREMS__REMS_Service_Summary__c insertServiceSummary(Account acc,List<US_WSREMS__REMS_Program__c>  program,String participantType,String recordType) {
        try {
            Id idRTforREMSService = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c').get(recordType);
            US_WSREMS__REMS_Service_Summary__c service = new US_WSREMS__REMS_Service_Summary__c();
            service.RecordTypeId = idRTforREMSService;
            service.US_WSREMS__REMSProgram__c = program.size() > 0 ? program[0].Id : null;
            service.US_WSREMS__Status__c = REMSAppLiterals.SERVICE_STATUS;
            service.US_WSREMS__Service_Outcome__c = REMSAppLiterals.SERVICE_OUTCOME;
            service.US_WSREMS__Participant__c = acc.Id;
            service.US_WSREMS__Requestor_Type__c = participantType;
            insert service;
            return service;

        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR,'Exception'+ex.getMessage()+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
        
    }

    public static Account insertAccount(RecordDataWrapper recordData, List<US_WSREMS__REMS_Program__c> program, Boolean isPersonAccount, String recordType) {
        try {
            System.debug(LoggingLevel.DEBUG,recordType);
            User[] adminUser = [SELECT Id, Name FROM User WHERE UserName = :System.label.tryvio_Portal_default_record_username AND isActive = true AND Alias = 'tryvio'];
            Id recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get(recordType);
            Account newAccount = new Account();
            newAccount.OwnerId = adminUser[0].Id;
            newAccount.US_WSREMS__EXT__c = recordData.ext;
            if (!isPersonAccount) {
                newAccount.Name = recordData.name;
                
                newAccount.US_WSREMS__National_Provider_Identifier__c = recordData.npi;
                newAccount.US_WSREMS__Facility_Type__c = recordData.facilityTypes;
                newAccount.US_WSREMS__Address_Line_1__c = recordData.address1;
                newAccount.US_WSREMS__Address_Line_2__c = recordData.address2;
                newAccount.US_WSREMS__City__c = recordData.city;
                newAccount.US_WSREMS__State__c = recordData.state;
                newAccount.US_WSREMS__Zip__c = recordData.zip;
                newAccount.Phone = recordData.phone;
                newAccount.SYN_Alternate_Phone_Ext__c = recordData.ext;
                newAccount.Fax = recordData.fax;
                
                if(recordData.Sh != NULL) {
                    newAccount.US_WSREMS__Ship_to_Address_Same_as_Above__c = recordData.Sh.shipAsAbove;
                    newAccount.US_WSREMS__Shipping_Address_Line_1__c = recordData.Sh.shipAddress1;
                    newAccount.US_WSREMS__REMS_Shipping_Address_2__c  = recordData.Sh.shipAddress2;
                    newAccount.US_WSREMS__Participant_City__c = recordData.Sh.shipCity;
                    newAccount.US_WSREMS__SLN_State__c = recordData.Sh.shipState;
                    newAccount.US_WSREMS__Zip_Code__c = recordData.Sh.shipZip;
                    newAccount.US_WSREMS__Phone_Number__c = recordData.Sh.shipPhone;
                    newAccount.US_WSREMS__Fax_Number__c = recordData.Sh.shipFax;
                    newAccount.US_WSREMS__Ext_Alternate__c = recordData.Sh.shipExt;
                }                
                if (recordType != REMSAppLiterals.ACCOUNT_RECORDTYPE_PHARMACYPARTICIPANT) {
                    newAccount.US_WSREMS__National_Provider_Identifier__c = recordData.npi;
                }
            }
            if(recordType == REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER) {
                newAccount.US_WSREMS__National_Provider_Identifier__c = recordData.npi;
                newAccount.fax = recordData.fax;
            }
            if(recordType != REMSAppLiterals.ACCOUNT_RECORDTYPE_HEALTHCARESETTING && recordType != REMSAppLiterals.ACCOUNT_RECORDTYPE_OUTPATIENTPHARMACY && recordType != REMSAppLiterals.ACCOUNT_RECORDTYPE_INPATIENTPHARMACY) {
                newAccount.US_WSREMS__Email__c = recordData.email;
                newAccount.Phone = recordData.phone;
                newAccount.US_WSREMS__Fax_Number__c = recordData.fax;
            } 
            if(recordType != REMSAppLiterals.ACCOUNT_RECORDTYPE_OUTPATIENTPHARMACY && recordType != REMSAppLiterals.ACCOUNT_RECORDTYPE_INPATIENTPHARMACY){
                newAccount.US_WSREMS__Zip__c = recordData.zip;
                newAccount.phone = recordData.offPhone;
                newAccount.US_WSREMS__Address_Line_1__c = recordData.address1;
                newAccount.US_WSREMS__Address_Line_2__c = recordData.address2;
                newAccount.US_WSREMS__State__c = recordData.state;
                newAccount.US_WSREMS__EXT__c = recordData.ext;
                newAccount.fax = recordData.fax;
                newAccount.US_WSREMS__City__c = recordData.city;
                newAccount.type = recordData.type;
            } 
            newAccount.US_WSREMS__Other_Credentials__c = recordType == 'Inpatient_Pharmacy_Account' ? recordData.facilityOther : newAccount.US_WSREMS__Other_Credentials__c;
            newAccount.RecordTypeId = recordTypeId;
            newAccount.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
            newAccount.US_WSREMS__REMS_Program__c = program.size() > 0 ? program[0].Id : null;
            newAccount.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            if(recordType == REMSAppLiterals.ACCOUNT_RECORDTYPE_OUTPATIENTPHARMACY) {
                newAccount.Type = recordData.type;
            }
            insert newAccount;
            return newAccount;
        }catch (Exception ex) {
			System.debug(LoggingLevel.ERROR,'Exception'+ex.getMessage()+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }  
    }

    public static Case insertCase(RecordDataWrapper recordData,Account accountRec,US_WSREMS__REMS_Service_Summary__c service,List<US_WSREMS__REMS_Program__c>  program,String recordType, string accountId ,String participantType, Id recordTypeId, Id arId) {
        try {
            String recordTypeDevName = Schema.SObjectType.Case.getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.CASE_OBJECT).get(recordType);
            System.debug(LoggingLevel.DEBUG,'Insert Cassr ' + caseRecordTypeId);
            User[] adminUser = [SELECT Id, Name FROM User WHERE UserName = :System.label.tryvio_Portal_default_record_username AND isActive = true AND Alias = 'tryvio'];
            Case caseRec = new Case();
            caseRec.OwnerId = adminUser[0].Id;
            caseRec.RecordTypeId = recordTypeId;
            caseRec.US_WSREMS__NPI__c = recordData.npi;
            caseRec.US_WSREMS__Name__c = recordData.name;
            caseRec.US_WSREMS__Type_of_Report__c = recordData.type;
            caseRec.US_WSREMS__Other_Credentials__c = recordTypeDevName == 'Inpatient_Pharmacy_Enrollment' ? recordData.facilityOther : caseRec.US_WSREMS__Other_Credentials__c;
            caseRec.US_WSREMS__Other_Credentials__c = recordTypeDevName == 'Inpatient_Pharmacy' ? recordData.facilityOther : caseRec.US_WSREMS__Other_Credentials__c;
            caseRec.US_WSREMS__Zip__c=recordData.zip;
        
            if (recordType != REMSAppLiterals.CASE_RECORDTYPE_HEALTHCARESETTING) {
                caseRec.US_WSREMS__First_Name__c = recordData.firstName;
                caseRec.US_WSREMS__Middle_Name__c = recordData.lastName;
                caseRec.US_WSREMS__Last_Name__c = recordData.lastName;
                caseRec.US_WSREMS__Fax__c = recordData.fax;
                caseRec.US_WSREMS__Zip__c = recordData.zip;
                caseRec.US_WSREMS__Participant_Fax__c = recordData.fax;
                caseRec.US_WSREMS__REMS_Alternate_Phone__c = recordData.phone;
                caseRec.US_WSREMS__Email__c = recordData.email;
                caseRec.US_WSREMS__Email_ar__c = recordData.email;
                caseRec.US_WSREMS__Phone__c = recordData.phone;
                caseRec.US_WSREMS__NPI__c = recordData.npi;
            } else {
                caseRec.US_WSREMS__Name__c = recordData.name;
                caseRec.US_WSREMS__NPI__c = recordData.npi;
            }
            
            caseRec.US_WSREMS__REMS_ID__c = accountRec.SYN_Ref_Id__c;
            caseRec.US_WSREMS__Address_Line_1__c = recordData.address1;
            caseRec.US_WSREMS__Address_Line_2__c = recordData.address2;
            caseRec.Status = 'Draft';//REMSAppLiterals.CASE_STATUS_COMPLETED;
            caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
            caseRec.US_WSREMS__Participant__c = accountRec.Id;
            caseRec.US_WSREMS__City__c = recordData.city;
            caseRec.US_WSREMS__State__c = recordData.state;
            caseRec.US_WSREMS__Zip__c = recordData.zip;
            caseRec.US_WSREMS__Office_Phone__c = recordData.phone;
            caseRec.US_WSREMS__Ext__c = recordData.ext;
            caseRec.US_WSREMS__Fax__c = recordData.fax;
            caseRec.US_WSREMS__Facility_Type__c = recordData.facilityTypes;
            
            if(recordType!=REMSAppLiterals.CASE_RECTYPE_PRESCRIBER_PERSON_ACCOUNT && recordData.Sh != NULL){
                caseRec.US_WSREMS__Ship_to_Address_Same_as_Above__c= recordData.Sh.shipAsAbove;
                caseRec.US_WSREMS__First_Name__c = recordData.Sh.firstName;
                caseRec.US_WSREMS__MI__c = recordData.Sh.mi;
                caseRec.US_WSREMS__Last_Name__c = recordData.Sh.lastName;
                caseRec.US_WSREMS__Shipping_Address_Line_1__c = recordData.Sh.shipAddress1;
                caseRec.US_WSREMS__Shipping_Address_Line_2__c = recordData.Sh.shipAddress2;
                caseRec.US_WSREMS__Participant_City__c = recordData.Sh.shipCity;
                caseRec.US_WSREMS__SLN_Issued_State__c = recordData.Sh.shipState;
                caseRec.US_WSREMS__REMS_Zip_Code__c = recordData.Sh.shipZip;
                caseRec.US_WSREMS__Phone__c = recordData.Sh.shipPhone;
                caseRec.Shipping_Fax__c = recordData.Sh.shipFax;
                caseRec.SYN_Ext__c = recordData.Sh.shipExt;
            }
           
            
            if(arId!=null){
                 caseRec.US_WSREMS__REMS_Authorized_Rep__c = arId;
                 caseRec.US_WSREMS__Title__c = recordData.AR.title;
                 caseRec.US_WSREMS__REMS_Job_Title__c = recordData.AR.title;
                 caseRec.US_WSREMS__Other_Title__c = recordData.AR.othertitle;
                 caseRec.US_WSREMS__REMS_Ext__c = recordData.AR.ext;
                 caseRec.US_WSREMS__Participant_Fax__c = recordData.AR.fax;
                 caseRec.US_WSREMS__Office_Contact_phone__c = recordData.AR.offPhone;
                 caseRec.US_WSREMS__Credential__c = recordData.AR.credentials;
                 caseRec.US_WSREMS__Other__c = recordTypeDevName == 'Inpatient_Pharmacy_Enrollment' ?  recordData.AR.othertitle : caseRec.US_WSREMS__Other__c;
                 caseRec.US_WSREMS__Other__c = recordTypeDevName == 'Outpatient_Pharmacy_Enrollment' ?  recordData.AR.othercredentials : caseRec.US_WSREMS__Other__c;
                 caseRec.US_WSREMS__Email__c = recordData.AR.email;
                 caseRec.US_WSREMS__Preferred_Contact_Method__c = recordData.AR.preferredContactMethod;
                 caseRec.US_WSREMS__Participant_FirstName__c = recordData.AR.firstName;
                 caseRec.US_WSREMS__Participant_LastName__c = recordData.Ar.lastName;
                 caseRec.US_WSREMS__Middle_Name__c = recordData.AR.mi;
                 caseRec.US_WSREMS__Participant_Phone__c = recordData.AR.mPhone;
                 caseRec.US_WSREMS__Phone_ar__c = recordData.AR.offPhone;
                 caseRec.US_WSREMS__REMS_Prescriber_Ext__c = recordData.AR.ext;
                 caseRec.US_WSREMS__REMS_Prescriber_Fax__c = recordData.AR.fax;
                 caseRec.US_WSREMS__Participant_Fax__c = recordData.AR.fax;
            }
            caseRec.US_WSREMS__REMS_Service_Summary__c = service.Id;
            caseRec.US_WSREMS__REMS_Program__c = program[0].Id;
            caseRec.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL; //changed
            if(participantType == REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER){
                if(recordType==REMSAppLiterals.CASE_RECTYPE_PRESCRIBER_PERSON_ACCOUNT){
                    caseRec.Program_Record_Type_Control__c = 'TRYVIO REMS-Prescriber_Person_Account';
                    caseRec.US_WSREMS__Prescriber_State__c=recordData.state;
                }else if(recordType=='Prescriber_enrollment'){
                  caseRec.Program_Record_Type_Control__c='TRYVIO REMS-Prescriber_enrollment';  
                }
                
                
            }else{
                 caseRec.Program_Record_Type_Control__c = (FORM_TYPE == 'IPP') ? 'TRYVIO REMS-Inpatient_Pharmacy' : 'TRYVIO REMS-Outpatient_Pharmacy'; 
            }
            if(recordType == REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT && participantType == REMSAppLiterals.REQUESTORTYPE_HCS) {
                caseRec.US_WSREMS__Healthcare_Setting__c = accountId;
            } else if(recordType == REMSAppLiterals.CASE_RECORDTYPE_PHARMACYPARTICIPANT &&  (participantType == REMSAppLiterals.REQUESTORTYPE_OUTPATIENT || participantType == REMSAppLiterals.REQUESTORTYPE_INPATIENT)) {
                caseRec.US_WSREMS__REMS_Authorized_Rep__c = accountId; 
            }
            
            if(recordTypeDevName == 'Inpatient_Pharmacy_Enrollment' || recordTypeDevName == 'Outpatient_Pharmacy_Enrollment'){
                caseRec.US_WSREMS__NPI_Status__c = 'Valid';
                caseRec.US_WSREMS__Signature__c = 'Yes';
                caseRec.US_WSREMS__Date__c = System.today();
                caseRec.Status = 'On Hold';
                caseRec.US_WSREMS__Hold_Account__c = true;
                caseRec.US_WSREMS__Signature__c = 'Yes';
                caseRec.US_WSREMS__Date__c = System.today();
            }
                
            if(recordTypeDevName == 'Inpatient_Pharmacy' || recordTypeDevName == 'Outpatient_Pharmacy'){
                caseRec.Status = 'Complete';
                caseRec.US_WSREMS__Outcome__c= 'Complete';
            }
            
            system.debug(LoggingLevel.DEBUG,'caseRec@@@@@@'+caseRec);
            if(!test.isRunningTest()) {
                insert caseRec;
            }
            return  caseRec;
            
        }  catch (Exception ex) {
             System.debug(LoggingLevel.ERROR,'Exception'+ex.getMessage()+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    public static Case insertOfficeCase(RecordDataWrapper recordData,Account accountRec,US_WSREMS__REMS_Service_Summary__c service,List<US_WSREMS__REMS_Program__c>  program,String recordType ) {
        try {
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.CASE_OBJECT).get(recordType);
            Case caseRec = new Case();
            caseRec.RecordTypeId = caseRecordTypeId;
            caseRec.US_WSREMS__Prescriber_First_Name__c  = recordData.pfirstname;
            caseRec.US_WSREMS__Prescriber_Last_Name__c  = recordData.plastname;
            caseRec.US_WSREMS__Prescriber_Email__c = recordData.pemail;
            caseRec.US_WSREMS__Office_Contact_phone__c = recordData.pophone;
            caseRec.US_WSREMS__REMS_Prescriber_Ext__c =recordData.pext;
            caseRec.US_WSREMS__Office_Contact__c = accountRec.Id;
            caseRec.Status = 'Complete';
            caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
            caseRec.US_WSREMS__REMS_Service_Summary__c = service.Id;
            caseRec.US_WSREMS__REMS_Program__c = program[0].Id;
            caseRec.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL; //changed
            caseRec.Program_Record_Type_Control__c = 'TRYVIO REMS-Prescriber_Office_Contact';
            if(!test.isRunningTest()) {
                insert caseRec;
            }
            return  caseRec;
        }  catch (Exception ex) {
             System.debug(LoggingLevel.ERROR,'Exception'+ex.getMessage()+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static US_WSREMS__Affiliation__c insertAffiliation(Account accountRec, List<US_WSREMS__REMS_Program__c> program, String pharmaAcc, Id recordTypeId, RecordDataWrapper recordData) {
        try {
            US_WSREMS__Affiliation__c affiliatedAcc = new US_WSREMS__Affiliation__c();
            affiliatedAcc.RecordTypeId = recordTypeId;
            affiliatedAcc.US_WSREMS__Pharmacy_User__c = accountRec.Id;
            affiliatedAcc.US_WSREMS__Pharmacy__c = pharmaAcc;
            affiliatedAcc.US_WSREMS__REMSProgram__c = program.size() > 0 ? program[0].Id : null;
            affiliatedAcc.US_WSREMS__isActive__c = false;
            insert affiliatedAcc;
            return affiliatedAcc;
            
        } catch (Exception ex) {
             System.debug(LoggingLevel.ERROR,'Exception'+ex.getMessage()+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    public static Account insertARAccount(RecordDataWrapper recordData,List<US_WSREMS__REMS_Program__c> program, Id recordTypeId,String requestForType ){
        Account accAR = new Account();
        try{
            accAr.RecordTypeId = recordTypeId;
            accAr.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
            accAr.US_WSREMS__REMS_Program__c = program.size() > 0 ? program[0].Id : null;
            accAr.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            accAR.FirstName = recordData.AR.firstName;
            accAR.US_WSREMS__Preferred_Contact_Method__c = recordData.AR.preferredContactMethod;
            accAR.US_WSREMS__Phone_Number__c = recordData.AR.offPhone;
            accAR.US_WSREMS__EXT__c = recordData.AR.ext;
            accAR.Phone = recordData.AR.mPhone;
            accAr.MiddleName = recordData.AR.mi;
            accAR.Fax = recordData.AR.fax;
            accAR.US_WSREMS__Credentials__c = recordData.AR.credentials;
            accAR.US_WSREMS__Other__c = requestForType == 'Outpatient Pharmacy' ?  recordData.AR.othercredentials : accAR.US_WSREMS__Other__c;
            accAR.US_WSREMS__Other__c = requestForType == 'Inpatient Pharmacy' ?  recordData.AR.othertitle : accAR.US_WSREMS__Other__c;
            accAR.US_WSREMS__Other_Credentials__c = recordData.AR.other;
            accAR.US_WSREMS__Other_Credentials__c = requestForType == 'Outpatient Pharmacy' ?  recordData.AR.othercredentials : accAR.US_WSREMS__Other_Credentials__c;
            accAR.US_WSREMS__Other_Credentials__c = requestForType == 'Inpatient Pharmacy' ?  recordData.AR.othertitle : accAR.US_WSREMS__Other_Credentials__c;
            accAR.US_WSREMS__Title__c = requestForType == 'Outpatient Pharmacy' ?  recordData.AR.title : accAR.US_WSREMS__Title__c;
            accAR.US_WSREMS__Participant_Title__c = requestForType == 'Inpatient Pharmacy' ?  recordData.AR.title : accAR.US_WSREMS__Participant_Title__c;            
            accAR.US_WSREMS__Other_Title__c = recordData.AR.othertitle;
            accAR.LastName = recordData.Ar.lastName;
        	accAr.PersonEmail = recordData.AR.email;
            accAr.US_WSREMS__Email__c = recordData.AR.email;
            accAr.US_WSREMS__Email__c = recordData.AR.email;
            accAr.US_WSREMS__Pharmacy_Type__c = recordData.type;
        	insert accAR;

        US_WSREMS__REMS_Service_Summary__c serviceCreation = insertServiceSummary(accAR,program,REMSAppLiterals.SERVICE_PARTICIPANT_AR,REMSAppLiterals.SERVICE_RECTYPE_PARTICIPANT_ENROLLMENT);
        Id caseRecordType = REMSUtility.retrieveRecTypeDeveloperNameId_Product(REMSAppLiterals.CASE_OBJECT).get('Pharmacy_Participant_Account'); // Changed by Robin
        Case cs = new Case();
            cs.RecordTypeId = caseRecordType; // Changed by Robin
            cs.US_WSREMS__Credential__c = recordData.AR.credentials;
            cs.US_WSREMS__REMS_Program__c = program.size() > 0 ? program[0].Id : null;
            cs.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            cs.US_WSREMS__Channel__c = 'Portal';
            cs.US_WSREMS__First_Name__c = recordData.AR.firstName;
            cs.US_WSREMS__Participant_FirstName__c = recordData.AR.firstName;
            cs.Program_Record_Type_Control__c  = (FORM_TYPE == 'IPP') ? 'TRYVIO REMS-Inpatient_Pharmacy_Enrollment' : 'TRYVIO REMS-Outpatient_Pharmacy_Enrollment';
            cs.US_WSREMS__REMS_ID__c = accAR.SYN_Ref_Id__c;
            cs.US_WSREMS__Middle_Name__c = recordData.AR.mi;
            cs.US_WSREMS__First_Name__c = recordData.AR.firstName;
            cs.US_WSREMS__Last_Name__c = recordData.AR.lastName;
            cs.US_WSREMS__Participant_LastName__c = recordData.Ar.lastName;
            cs.US_WSREMS__REMS_Job_Title__c = recordData.AR.title;
            cs.US_WSREMS__Title__c = requestForType == 'Inpatient Pharmacy' ? recordData.AR.title : cs.US_WSREMS__Title__c;
            cs.US_WSREMS__Other_Title__c = recordData.AR.othertitle;
            cs.US_WSREMS__Office_Phone__c = recordData.AR.offPhone;
            cs.US_WSREMS__Office_Contact_phone__c = recordData.AR.offPhone;
            cs.US_WSREMS__REMS_Ext__c = recordData.AR.ext;
            cs.US_WSREMS__Fax__c = recordData.AR.fax;
            cs.US_WSREMS__Phone__c = recordData.AR.phone;
            cs.US_WSREMS__Email__c = recordData.AR.email;
            cs.US_WSREMS__Preferred_Contact_Method__c = recordData.AR.preferredContactMethod;
        	cs.US_WSREMS__Other_Credentials__c = recordData.AR.other;
            cs.US_WSREMS__Participant__c = accAR.Id;
            cs.US_WSREMS__REMS_Service_Summary__c = serviceCreation.Id;
            cs.Status = 'Complete';
            cs.US_WSREMS__Outcome__c= 'Complete';
            
            //Added by Nagur Basha
            if(recordData.Sh != NULL) {
                cs.US_WSREMS__Shipping_Address_Line_1__c = recordData.Sh.shipAddress1;
                cs.US_WSREMS__Shipping_Address_Line_2__c = recordData.Sh.shipAddress2;
                cs.US_WSREMS__Participant_City__c = recordData.Sh.shipCity;
                cs.US_WSREMS__REMS_Alternate_Phone_Ext__c = recordData.Sh.shipExt;
                cs.Shipping_Fax__c = recordData.Sh.shipFax;
                cs.US_WSREMS__Phone__c = recordData.Sh.shipPhone;
                cs.US_WSREMS__REMS_Zip_Code__c = recordData.Sh.shipZip;
            }
                //cs.US_WSREMS__State__c = recordData.Sh.shipState;
                System.debug(LoggingLevel.DEBUG,'NEw Caase Value' + cs);
                System.debug(LoggingLevel.DEBUG,'NEw Caase Value 2 ' + cs.US_WSREMS__Channel__c);
            insert cs;


            return accAR;
        }catch(Exception ex){
             System.debug(LoggingLevel.ERROR,'Exception'+ex.getMessage()+ex.getLineNumber());
        }
        return accAR;

    }
   
	

    public static String insertPrescriberSignature(String accountId, String agreementStatus, String b64SignData) {
        try {
            //Create Attachment
            Attachment n = new Attachment(ParentId = accountId, Name = 'Signature_' + String.valueOf(Date.today()).substring(0, 10),
                                         Body = EncodingUtil.base64Decode(b64SignData), ContentType = 'image/jpeg');
            insert n;
            return '';
        } catch (Exception e) {
            return e.getMessage();
        }
    } 
    //Added by Muralidhar.
    public static Case insertprescriberCase(RecordDataWrapper recordData,Account acc,US_WSREMS__REMS_Service_Summary__c service,List<US_WSREMS__REMS_Program__c>  program,String recordType, string accountId ,String participantType, Id recordTypeId, Id arId,Account OfficeAcc1,Account OfficeAcc2) {
        try {
            String recordTypeDevName = Schema.SObjectType.Case.getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
            Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.CASE_OBJECT).get(recordType);
            Case caseRec = new Case();
            caseRec.recordTypeId = recordTypeId;
            if(recordType=='Knowledge_Assessment' && participantType == REMSAppLiterals.ACCOUNT_RECORDTYPE_PRESCRIBER){
                caseRec.Program_Record_Type_Control__c = 'TRYVIO REMS-Knowledge_Assessment';
            caseRec.US_WSREMS__REMS_Program__c = program[0].Id;
            caseRec.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL; 
            caseRec.Status = 'Draft';
            caseRec.US_WSREMS__First_Name__c = recordData.firstName;
            caseRec.US_WSREMS__Last_Name__c = recordData.LastName;
            if(recordData.phone != null){
                   caseRec.US_WSREMS__Phone__c = recordData.phone;
            }else{
                     caseRec.US_WSREMS__Phone__c = recordData.officePhone;
            }
            caseRec.US_WSREMS__Email__c=recordData.email;
            caseRec.US_WSREMS__NPI__c = recordData.npi;
            caseRec.US_WSREMS__Zip__c=recordData.zip;
            caseRec.US_WSREMS__Prescriber__c=acc.id;
            caseRec.US_WSREMS__REMS_Service_Summary__c = service.Id;
            }else if(recordType=='Prescriber_enrollment'){
                
                caseRec.US_WSREMS__REMS_Program__c = program[0].Id;
                caseRec.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
                caseRec.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL; 
                caseRec.US_WSREMS__REMS_Service_Summary__c = service.Id;
                caseRec.US_WSREMS__NPI_Status__c = 'Valid';
                
                caseRec.US_WSREMS__Participant__c = acc.Id;
                caseRec.Program_Record_Type_Control__c='TRYVIO REMS-Prescriber_enrollment';
                caseRec.US_WSREMS__NPI__c = recordData.npi;
                caseRec.US_WSREMS__First_Name__c = recordData.firstName;
                caseRec.US_WSREMS__MI__c=recordData.middleName;
                caseRec.US_WSREMS__Last_Name__c = recordData.LastName;
                
                
                caseRec.US_WSREMS__Speciality__c=recordData.specialty;
                caseRec.US_WSREMS__Other__c=recordData.otherSpecialty;
                caseRec.US_WSREMS__Professional_Designation__c=recordData.proffDesig;
                caseRec.Office_Practice_Clinic_Name__c=recordData.officePractice;
                
                caseRec.US_WSREMS__Preferred_Contact_Method__c=recordData.preferredContactMethod;
                caseRec.US_WSREMS__Office_Phone__c=recordData.offPhone;
                caseRec.US_WSREMS__Phone__c = recordData.phone;
                caseRec.US_WSREMS__Email__c=recordData.email;
                caseRec.US_WSREMS__Fax__c=recordData.fax;
                caseRec.US_WSREMS__Ext__c=recordData.ext;
                caseRec.US_WSREMS__REMS_Ext__c=recordData.ext;
                
                caseRec.US_WSREMS__Address_Line_1__c=recordData.address1;
                caseRec.US_WSREMS__Address_Line_2__c=recordData.address2;
                caseRec.US_WSREMS__City__c=recordData.city;
                caseRec.US_WSREMS__Prescriber_State__c = recordData.state;
                caseRec.US_WSREMS__State__c=recordData.state;
                caseRec.US_WSREMS__Zip__c=recordData.zip;
                
                
                If(OfficeAcc1!=null){
                    caseRec.US_WSREMS__Office_Contact__c=OfficeAcc1.id;
                }
                caseRec.US_WSREMS__Prescriber_First_Name__c=recordData.pfirstname;
                caseRec.US_WSREMS__Prescriber_Last_Name__c=recordData.plastname;
                caseRec.US_WSREMS__Office_Contact_phone__c=recordData.pophone;
                caseRec.US_WSREMS__Prescriber_Email__c=recordData.pemail;
                caseRec.US_WSREMS__REMS_Prescriber_Ext__c=recordData.pext;
                
                 If(OfficeAcc2!=null){
                    caseRec.US_WSREMS__Secondary_Office_Contact__c=OfficeAcc2.id;
                }
          
                caseRec.US_WSREMS__First_Name_Secondary_AR__c=recordData.sfirstname;
                caseRec.US_WSREMS__Last_Name_Secondary_AR__c=recordData.slastname;
                caseRec.US_WSREMS__REMS_Office_Contact_Phone__c = recordData.sophone;
                caseRec.US_WSREMS__Participant_Email__c=recordData.semail;
                caseRec.US_WSREMS__REMS_Alternate_Phone_Ext__c=recordData.sext;
                caseRec.US_WSREMS__Knowledge_Assessment__c='Passed';
                
                if(recordData.dispensesign=='true'){
                    caseRec.Verbal_Attestation__c='Yes';
                    caseRec.US_WSREMS__Date__c=system.today();
                }
                
                
                caseRec.US_WSREMS__Prescriber_Signature__c='Yes';
                caseRec.US_WSREMS__Signature_Date_Pharmacist__c=system.today();
                
                caseRec.Status = 'Complete';
                caseRec.US_WSREMS__Outcome__c= 'Complete';
                    
            }
            if(!test.isRunningTest()) {
                insert caseRec;
            }
            return  caseRec;
            
        }  catch (Exception ex) {
             System.debug(LoggingLevel.ERROR,'Exception'+ex.getMessage()+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }//Added by muralidhar
     public static Account insertPrescriberAccount(RecordDataWrapper recordData, List<US_WSREMS__REMS_Program__c> program, String recid, Boolean IsPrescriberPerson, Boolean isPrimaryOffice, Boolean isSocndaryOffice) {
        try {
           
            User[] adminUser = [SELECT Id, Name FROM User WHERE UserName = :System.label.tryvio_Portal_default_record_username AND isActive = true AND Alias = 'tryvio'];
            
            Account newAccount = new Account();
            newAccount.OwnerId = adminUser[0].Id;
            
			Id recordTypeId = recid;
			system.debug(LoggingLevel.DEBUG,'recordTypeId'+recordTypeId);
		if(IsPrescriberPerson){
            newAccount.US_WSREMS__National_Provider_Identifier__c = recordData.npi;
			newAccount.FirstName = recordData.firstName;
            newAccount.MiddleName = recordData.middleName;
            newAccount.LastName = recordData.lastName;
            newAccount.US_WSREMS__Email__c = recordData.email;
            newAccount.PersonEmail = recordData.email;
            newAccount.Phone = recordData.phone;
            newAccount.Fax = recordData.fax;
            
            if(recordData.state!=null){
                newAccount.US_WSREMS__Address_Line_1__c = recordData.address1;
                newAccount.US_WSREMS__Address_Line_2__c = recordData.address2;
                newAccount.US_WSREMS__City__c = recordData.city;
                newAccount.US_WSREMS__State__c = recordData.state;
                newAccount.US_WSREMS__Zip__c = recordData.zip;
            }
            
            newAccount.Medical_Specialty__c = recordData.specialty;
            newAccount.US_WSREMS__Other__c = recordData.otherSpecialty;
            newAccount.US_WSREMS__National_Provider_Identifier__c = recordData.npi;
            newAccount.US_WSREMS__EXT__c = recordData.ext;
			
			}
		else if(isPrimaryOffice){
			newAccount.FirstName = recordData.pfirstname;
			newAccount.LastName = recordData.plastname;
            newAccount.US_WSREMS__Email__c = recordData.pemail;
			newAccount.PersonEmail = recordData.pemail;
			newAccount.phone=recordData.pophone;
            newAccount.US_WSREMS__EXT__c=recordData.pext;
			}else if(isSocndaryOffice){
			 newAccount.FirstName = recordData.sfirstname;
			newAccount.LastName = recordData.slastname;
            newAccount.US_WSREMS__Email__c = recordData.semail;
			newAccount.PersonEmail = recordData.semail;
			newAccount.phone=recordData.sophone;
            newAccount.US_WSREMS__EXT__c=recordData.sext;
			
			}
				
            
            
            newAccount.RecordTypeId = recordTypeId;
            newAccount.US_WSREMS__Channel__c = REMSAppLiterals.CASE_CHANNEL_PORTAL;
            newAccount.US_WSREMS__REMS_Program__c = program.size() > 0 ? program[0].Id : null;
            newAccount.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
            System.debug(LoggingLevel.DEBUG,'New Acount@@@'+newAccount);
            insert newAccount;
            return newAccount;
        }catch (Exception ex) {
			System.debug(LoggingLevel.DEBUG,'Exception'+ex.getMessage()+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }  
    }			
    @AuraEnabled(cacheable=false)
    public static List<Account> getExistingAccount(String programName, String npiKey, List<String> accRecTypeDevNameList) {
        return [SELECT Id, US_WSREMS__Status__c, RecordType.DeveloperName                                    
                FROM Account 
                WHERE US_WSREMS__REMS_Program__r.Name =: programName AND RecordType.DeveloperName IN :accRecTypeDevNameList AND US_WSREMS__National_Provider_Identifier__c = :npiKey                                 LIMIT 1
                ];
    }

    //Added by muralidhar
    @AuraEnabled(cacheable=false)
    Public static InfoPrepopWrap getaccount(String searchKey, String programName){
        system.debug(LoggingLevel.DEBUG,'npiValue'+searchKey);
        system.debug(LoggingLevel.DEBUG,'programName'+programName);
        InfoPrepopWrap wrap= new InfoPrepopWrap();
        Set<id> accid=new Set<id>();
        List<Account> accList = [
            SELECT id,Name,FirstName,LastName, MiddleName, US_WSREMS__NPI__c,US_WSREMS__Specialty__c,US_WSREMS__Professional_Designation__c, US_WSREMS__National_Provider_Identifier__c,
            Office_Practice_Clinic_Name__c,US_WSREMS__Address_Line_1__c,US_WSREMS__Address_Line_2__c,US_WSREMS__State__c,
            US_WSREMS__City__c,US_WSREMS__Zip__c,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Phone_Number__c,US_WSREMS__EXT__c, 
            fax,Phone,PersonEmail,US_WSREMS__Other__c,US_WSREMS__Status__c
            FROM Account 
            WHERE US_WSREMS__National_Provider_Identifier__c =: searchKey AND US_WSREMS__REMS_Program__r.Name =: programName and recordtype.name='Prescriber'
            LIMIT 1
        ];
        if(accList.size()>0){
            for(Account acc:accList){
                wrap.status=acc.US_WSREMS__Status__c;
                wrap.accountid=acc.id;
                wrap.name=acc.name;
                wrap.address1=acc.US_WSREMS__Address_Line_1__c;
                wrap.address2=acc.US_WSREMS__Address_Line_2__c;
                wrap.State=acc.US_WSREMS__State__c;
                wrap.city=acc.US_WSREMS__City__c;
                wrap.zip=acc.US_WSREMS__Zip__c;
                wrap.firstname=acc.FirstName;
                wrap.lastname=acc.LastName;
                wrap.middlename=acc.MiddleName;
                wrap.npi=acc.US_WSREMS__National_Provider_Identifier__c;
                wrap.specialty=acc.US_WSREMS__Specialty__c;
                wrap.other=acc.US_WSREMS__Other__c;
                wrap.officePhone=acc.US_WSREMS__Phone_Number__c;
                wrap.mobilePhone=acc.phone;
                wrap.fax=acc.fax;
                wrap.email=acc.PersonEmail;
                wrap.ext=acc.US_WSREMS__EXT__c;
                wrap.professionalDesignation=acc.US_WSREMS__Professional_Designation__c;
                wrap.preferredContactMethod=acc.US_WSREMS__Preferred_Contact_Method__c;
                wrap.otherPractice=acc.Office_Practice_Clinic_Name__c;
                accid.add(acc.id);
            }
            for(case cs:[select id,status,US_WSREMS__Knowledge_Assessment__c,US_WSREMS__Attempts_Made__c from case where US_WSREMS__Prescriber__c IN:accid and US_WSREMS__REMS_Program__r.name=:programName and recordtype.developername='Knowledge_Assessment' Limit 1]){
                if(cs!=null){
                    wrap.caseid=cs.id;
                    wrap.Kastatus=cs.status;
                    wrap.attempsmade=cs.US_WSREMS__Attempts_Made__c;
                }
            }
            if(wrap.caseid==''){
                wrap.casenotcreated=true;
            }
             return wrap;
        }else{
            return null;
        }
    }
    public class RecordDataWrapper {
        public String name; //Deepthi 1
        public String id;
        public String firstName;
        public String middleName;
        public String lastName;
        public String email;
        public String phone;    //(046) 767-5578
        public String address1; //fdtewgewf
        public String address2; //dftyegf
        public String city; //test city
        public String state;    //AL
        public String zip;  //24355
        public String ext;  //6768783446
        public String type; //Retail
        public String facilityTypes;
        public String fax;  //(234) 456-7789
        public String offPhone;
        public String officePhone; //(986) 789-6789
        public String npi;
        public String specialty;
        public String userType;
        public String participantType;
        public ARWrapper AR;
        //Addedy By Muralidhar
        public String officePractice;
        public String otherSpecialty;
        public String proffDesig;
        public String preferredContactMethod;
        public String pfirstname;
        public String plastname;
        public String pophone;
        public String pext;
        public String pemail;
        public String sfirstname;
        public String slastname;
        public String sophone;
        public String sext;
        public String semail;
        public String dispensesign;
        public String facilityOther;
        //Added by Nagur Basha
        public ShipDataWrapper Sh;
    }
    public class ARWrapper {
        public String firstName;    //pp
        public String lastName; //hcs
        public String mi;
        public String offPhone; //(986) 789-6789
        public String email;    //testobha@gmail.com
        public String mPhone;   //(986) 789-6789
        public String Id;   //0016u00000ktXj1AAE
        public String title;
        public String othertitle;
        public String phone;
        public String fax;
        public String other;
        public String ext;
        public String credentials;
        public String othercredentials;
        public String preferredContactMethod;
    }
    //Added by Nagur Basha 
    public class ShipDataWrapper {
        public String firstName;    //pp
        public String lastName; //hcs
        public String mi;
        public String shipAddress1;
        public String shipAddress2;
        public String shipCity;
        public String shipState;
        public String shipZip;
        public String shipPhone;
        public String shipExt;
        public String shipFax;
        public Boolean shipAsAbove;
    }
    //Added by Muralidhar for Prescriber enrollment 
     public class InfoPrepopWrap{
        @AuraEnabled
        Public string status='';
        @AuraEnabled
        Public string accountid='';
        @AuraEnabled
        Public string caseid='';
        @AuraEnabled
        Public string Kastatus='';
        @AuraEnabled
        Public string name='';
         @AuraEnabled
        Public string firstname='';
         @AuraEnabled
        Public string lastname='';
        @AuraEnabled
        Public string middlename='';
        @AuraEnabled
        Public string email='';
        @AuraEnabled
        Public string fax='';
        @AuraEnabled
        public String address1='';
         @AuraEnabled
        public String address2='';
        @AuraEnabled
        public string State='';
        @AuraEnabled
        public string city='';
        @AuraEnabled
        public string zip='';
        @AuraEnabled
        public string specialty='';
        @AuraEnabled
        public string other='';
        @AuraEnabled
        public string officePhone='';
        @AuraEnabled
        public string ext='';
        @AuraEnabled
        public string mobilePhone='';
        @AuraEnabled
        public string professionalDesignation='';
        @AuraEnabled
        public string preferredContactMethod='';
        @AuraEnabled
        public string npi='';
        @AuraEnabled
        public string otherPractice='';
        @AuraEnabled
        public decimal attempsmade=0;
        @AuraEnabled
        public boolean casenotcreated=false;
    }
}