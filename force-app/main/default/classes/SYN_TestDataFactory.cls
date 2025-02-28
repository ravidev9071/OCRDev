/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-10-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SYN_TestDataFactory {
    
    Public static final String CaseActionName = 'Test';
    
    public static US_WSREMS__REMS_Service_Summary__c createService(boolean isCreate,Id programId,Id recordTypeId){

        US_WSREMS__REMS_Program_Service_Config__c remsServiceConfigObj = new US_WSREMS__REMS_Program_Service_Config__c();
        remsServiceConfigObj.US_WSREMS__REMS_Program__c = programId;
        remsServiceConfigObj.US_WSREMS__Service_API_Name__c = recordTypeId;
        remsServiceConfigObj.US_WSREMS__Stage_Names__c = 'Intake;Verification';
        remsServiceConfigObj.US_WSREMS__Stages__c = 'Intake;Verification';
        insert remsServiceConfigObj;

        

        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programId;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = recordTypeId;
        serviceObj.US_WSREMS__Expiration_Date__c = system.today();
      //  serviceObj.US_WSREMS__Participant__c = PhamcyPartiAccount.Id;
        if(isCreate){
            insert serviceObj;
        }
        return serviceObj;

    } 

    public static US_WSREMS__REMS_Service_Summary__c createKAService(boolean isCreate,Id programId,Id recordTypeId){

        US_WSREMS__REMS_Program_Service_Config__c remsServiceConfigObj = new US_WSREMS__REMS_Program_Service_Config__c();
        remsServiceConfigObj.US_WSREMS__REMS_Program__c = programId;
        remsServiceConfigObj.US_WSREMS__Service_API_Name__c = recordTypeId;
        remsServiceConfigObj.US_WSREMS__Stage_Names__c = 'Intake;Verification;Assessment';
        remsServiceConfigObj.US_WSREMS__Stages__c = 'Intake;Verification;Assessment';
        insert remsServiceConfigObj;

        Account PhamcyPartiAccount = createPersonAccountforPharmacyParticipant(True,programId,null);

        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programId;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy/HCS Participant';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = recordTypeId;
        serviceObj.US_WSREMS__Expiration_Date__c = system.today();
        serviceObj.US_WSREMS__Participant__c = PhamcyPartiAccount.Id;
        if(isCreate){
            insert serviceObj;
        }
        return serviceObj;

    } 
    
    
    public static DocumentChecklistItem createDocumentChecklistItem(){
           US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Sodium Oxybate REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
         Account acc= new Account(); //createAccount();
         acc.Name='TestAccount';
       acc.Phone='8888888888';
        acc.Fax ='8888888888';
        acc.Phone='8888888888'; 
        acc.Fax ='8888888888';
        acc.US_WSREMS__REMS_Program__c = programObj.ID;
        insert acc;
        
        DocumentChecklistItem doc = new DocumentChecklistItem() ;
        doc.Name='TestDocumentChecklist';
        doc.ParentRecordId=acc.Id;
        doc.Status='Pending';
        insert doc;
        return doc;
    }
    
public static DocumentChecklistItem createDocumentChecklistItem(Id recDocId,Id programId){
        DocumentChecklistItem docCheckObj = new DocumentChecklistItem();
        docCheckObj.ReceivedDocumentId = recDocId;
        docCheckObj.ParentRecordId = programId;
        docCheckObj.Name = 'Test';
        Insert docCheckObj;
        return docCheckObj;
    }
    public static Account createAccount(){
       
        Account acc=new Account();
        acc.Name='TestAccount';
       acc.Phone='8888888888';
        acc.Fax ='8888888888';
         //acc.US_WSREMS__REMS_Program__c = programObj.ID;
        insert acc;
        return acc;
    }
    public static ContentVersion createContentVersion(){
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;    
        insert cv;
        return cv;
    }
    public static ContentDocumentLink createContentDocumentLink(Id contentDocId, Id linkdocId){
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=linkdocId;
        contentlink.ShareType= 'I';
        contentlink.ContentDocumentId=contentDocId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        return contentlink;
    }
    
    public static ReceivedDocument createReceivedDocument(){
        
        Program_Fax_Configuration__mdt[] prgfax = [SELECT MasterLabel, QualifiedApiName, REMS_Program__c ,Fax_Number__c FROM Program_Fax_Configuration__mdt where Active__c=true];
       // createREMSProgram(prgfax[0].REMS_Program__c);
        ReceivedDocument receiveddoc=new ReceivedDocument();
        receiveddoc.Name='TestReceivedDocument';
        receiveddoc.Status='Draft';
       // receiveddoc.ownerId = userInfo.getUserId();
        receiveddoc.First_Assigned_Date__c=System.today();
        receiveddoc.Program_Fax_Number__c=prgfax[0].Fax_Number__c;
        insert receiveddoc;
        return receiveddoc;
        
    }
    
    public static void createREMSProgram(String programname){
        
        US_WSREMS__REMS_Program__c rp=new US_WSREMS__REMS_Program__c();
        rp.name=programname;
        insert rp;
        
    }
    public static ContentDocumentLink createContentDocument(Id parentId){
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument limit 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = parentId;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        return cdl;
    }
    
    public static User createTestUser(){
        Profile p = [SELECT Id FROM Profile where name ='system administrator' limit 1]; 
        User usr = new User(Alias = 'standt', Email='standarduser_rems@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@remsorg.com');
        insert usr ;
        
        return usr;
    }
    
    public static j2g_fax__efax__c createefaxRecord(){
        RecordType rec = [select Id,Name from RecordType where sObjectType='j2g_fax__efax__c' and Name='Received Fax'];
        j2g_fax__efax__c efax=new j2g_fax__efax__c();
        efax.j2g_fax__To__c='123456';
        efax.RecordTypeId=rec.Id;
        insert efax;
        ContentVersion cv = createContentVersion();
        ContentVersion cv1 = createContentVersion();
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId   
            FROM ContentDocument
        ];
        
        ContentDocumentLink cdl=SYN_TestDataFactory.createContentDocumentLink(documents[0].id, efax.Id);  
        
        return efax;
        
        
    }
    
    public static DocumentChecklistItem createDocumentChecklistItemwithRecivedDoc(){
        //US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
         US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Sodium Oxybate REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        Account acc= new Account(); //createAccount();
        acc.Name='TestAccount';
        acc.Phone='8888888888';
        acc.Fax ='8888888888';
        acc.Phone='8888888888'; 
        acc.Fax ='8888888888';
        acc.US_WSREMS__REMS_Program__c = programObj.ID;
        insert acc;
        ReceivedDocument rc=createReceivedDocument();
        
        DocumentChecklistItem dcl=new DocumentChecklistItem();
        dcl.name='TestDocumentchecklist';
        dcl.ParentRecordId=acc.Id;
        dcl.ReceivedDocumentId=rc.Id;
        dcl.Status='Pending_Agent_Review';
        insert dcl;
        return dcl;
    }
    
    
    public static ReceivedDocument createDuplicateReceivedDocument(){
        
        ReceivedDocument receiveddoc=new ReceivedDocument();
        receiveddoc.Name='TestReceivedDocument';
        receiveddoc.Status='Draft';
        receiveddoc.First_Assigned_Date__c=System.today();
        insert receiveddoc;
        return receiveddoc;
        
    }
    
    public static US_WSREMS__REMS_Program__c createREMSProgramSurvey(){
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Sodium Oxybate REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        return programObj;
    }
    
    public static Program_Survey__c createProgramSurvey(Id ProgramId, Id SurveryId){
        
        Program_Survey__c program_survey=new Program_Survey__c();
        program_survey.REMS_Program__c=ProgramId;
        program_survey.Survey__c=SurveryId;
        program_survey.Is_Active__c=true;
        insert program_survey;
        return program_survey;
    }
    
    public static US_WSREMS__REMS_Service_Summary__c createInboundREMSService(Id ProgramId){
        Id recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get('Inbound Communication').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c =ProgramId;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = recordTypeId;
        
        insert serviceObj; 
        return serviceObj;
        
    }

    public static List<US_WSREMS__REMS_Program__c> createSOXPrograms(integer noOfRecords,boolean isCreate){

        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0;i<noOfRecords;i++){
            US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c ();
            programObj.Name = 'Sodium Oxybate REMS';
            programObj.US_WSREMS__Status__c  ='Active';
            programObj.REMS_Project_Code__c = 'BT6825';
            programObj.US_WSREMS__Program_State_Date__c  = System.today();
            programObj.US_WSREMS__Program_End_Date__c  = System.today().addDays(20);
            programList.add(programObj);
        }

        if(isCreate && programList.size()>0){
            insert programList;
        }
        return programList;  
    }
    public static List<US_WSREMS__REMS_Program__c> createMaciPrograms(integer noOfRecords,boolean isCreate){

        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0;i<noOfRecords;i++){
            US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c ();
            programObj.Name = 'Macitentan REMS';
            programObj.US_WSREMS__Status__c  ='Active';
            programObj.REMS_Project_Code__c = 'BT6825';
            programObj.US_WSREMS__Program_State_Date__c  = System.today();
            programObj.US_WSREMS__Program_End_Date__c  = System.today().addDays(20);
            programList.add(programObj);
        }

        if(isCreate && programList.size()>0){
            insert programList;
        }
        return programList;
    }
    
    public static List<US_WSREMS__REMS_Program__c> createSOXPrograms1(integer noOfRecords,boolean isCreate,String prgmName){

        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0; i<noOfRecords; i++){
            US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c ();
            programObj.Name = prgmName;
            programObj.US_WSREMS__Status__c  ='Active';
            programObj.REMS_Project_Code__c = 'BT6825';
            programObj.US_WSREMS__Program_State_Date__c  = System.today();
            programObj.US_WSREMS__Program_End_Date__c  = System.today().addDays(20);
            programList.add(programObj);
        }
        
        if(isCreate && !programList.isEmpty()){
            insert programList;
        }
        return programList;
    }
    public static List<US_WSREMS__REMS_Program__c> createPiaSkyProgram(integer noOfRecords,boolean isCreate,String prgmName){

        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0; i<noOfRecords; i++){
            US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c ();
            programObj.Name = prgmName;
            programObj.US_WSREMS__Status__c  ='Active';
            programObj.REMS_Project_Code__c = 'BT1005';
            programObj.US_WSREMS__Program_State_Date__c  = System.today();
            programObj.US_WSREMS__Program_End_Date__c  = System.today().addDays(20);
            programList.add(programObj);
        }
        return programList;        
    }
    
    public static void createProgramServiceConfig(boolean isCreate, ID ProgramID){
        List<US_WSREMS__REMS_Program_Service_Config__c> programServiceConfigList = new List<US_WSREMS__REMS_Program_Service_Config__c>();
        //Id recordTypeIdpartAccCreation = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get('Participant Account Creation').getRecordTypeId();
          Id ParticipantEnrollment_RCtyId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Participant_Account_Creation').getRecordTypeId() ;

        
            US_WSREMS__REMS_Program_Service_Config__c  pscObj = new US_WSREMS__REMS_Program_Service_Config__c ();
            pscObj.US_WSREMS__Service_Name__c = 'Participant Account Creation';
            pscObj.US_WSREMS__REMS_Program__c = ProgramID;
            pscObj.US_WSREMS__Service_API_Name__c = ParticipantEnrollment_RCtyId ;
            insert pscObj;
   
    } 
    
    
    
    /*This method helps to create test data for Person Account Object for Prescriber record type */
    public static Account createPersonAccountforPrescriber(String NPI,Integer SLN,String phn,Boolean isCreate){
        id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.FirstName= 'TestUser';
        accountObj.LastName = 'Program';
        accountObj.RecordTypeId = recordTypeId;
        accountObj.US_WSREMS__Channel__c  = 'fax';
        accountObj.US_WSREMS__SLN_State__c  ='';
        accountObj.Phone = phn;
        accountObj.US_WSREMS__NPI__c  = NPI;
        accountObj.US_WSREMS__National_Provider_Identifier__c = NPI;
        accountObj.US_WSREMS__Phone_Type__c  = 'mobile';
        accountObj.US_WSREMS__EXT__c  = '123';
        accountObj.Fax = phn;
        accountObj.US_WSREMS__Email__c  ='test@test.com';
        accountObj.US_WSREMS__Preferred_Contact_Method__c  = 'email';
        if(isCreate){
            insert accountObj;
        }
        return accountObj;
    } 
/*This method helps to create test data for Person Account Object for Pharmacy Participant record type */
    public static Account createPersonAccountforPharmacyParticipant(Boolean isCreate, ID ProgramID,Id pharmacyAccountId){
        system.debug('iscreate and ProgramID++'+isCreate+ProgramID);
        Id RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant').getRecordTypeId();
        system.debug('RecTypeId++'+RecTypeId);
        Account PhmcyPartiacctObj = new Account();
        PhmcyPartiacctObj.FirstName= 'TestUser';
        PhmcyPartiacctObj.LastName = 'Program';
        PhmcyPartiacctObj.Phone = '8527419635';
        PhmcyPartiacctObj.RecordTypeId = RecTypeId;
        PhmcyPartiacctObj.US_WSREMS__Channel__c  = 'fax';
        PhmcyPartiacctObj.US_WSREMS__SLN_State__c  ='';
       // PhmcyPartiacctObj.Phone = phn;
        PhmcyPartiacctObj.US_WSREMS__REMS_Program__c = ProgramID;
      //  accountObj.US_WSREMS__NPI__c  = NPI;
      PhmcyPartiacctObj.US_WSREMS__Phone_Type__c  = 'mobile';
      PhmcyPartiacctObj.US_WSREMS__EXT__c  = '123';
      PhmcyPartiacctObj.Fax = '8527419635';
      PhmcyPartiacctObj.US_WSREMS__Email__c  ='test@test.com';
      PhmcyPartiacctObj.US_WSREMS__Preferred_Contact_Method__c  = 'email';
      PhmcyPartiacctObj.US_WSREMS__Status__c ='Active';
       if (pharmacyAccountId != null) {
        PhmcyPartiacctObj.SYN_Pharmacy__c = pharmacyAccountId;
        }
        if(isCreate){
            insert PhmcyPartiacctObj;
        }
        return PhmcyPartiacctObj;
    } 
    // For SYN_ParticipantEnrollmentController_Test
    public static Account createPersonAccountforPrescriber(String NPI,Integer SLN,String phn,Boolean isCreate, ID ProgramID){
        id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.FirstName= 'TestUser';
        accountObj.LastName = 'Program';
        accountObj.RecordTypeId = recordTypeId;
        accountObj.US_WSREMS__Channel__c  = 'fax';
        accountObj.US_WSREMS__Program_Picklist__c = 'Macitentan REMS';
        accountObj.US_WSREMS__SLN_State__c  ='Alabama';
        accountObj.Phone = phn;
        accountObj.US_WSREMS__NPI__c  = NPI;
        accountObj.US_WSREMS__Phone_Type__c  = 'mobile';
        accountObj.US_WSREMS__EXT__c  = '123';
        accountObj.Fax = phn;
        accountObj.US_WSREMS__Email__c  ='test@test.com';
        accountObj.US_WSREMS__Preferred_Contact_Method__c  = 'email';
        accountObj.US_WSREMS__REMS_Program__c = ProgramID;
        if(isCreate){
            insert accountObj;
        }
        return accountObj;
    }
    public static Account createPersonAccountforPrescriberAveed(String NPI,Integer SLN,String phn,Boolean isCreate, ID ProgramID){
        id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.FirstName= 'TestUser';
        accountObj.LastName = 'Program';
        accountObj.RecordTypeId = recordTypeId;
        accountObj.US_WSREMS__Channel__c  = 'fax';
       
        accountObj.Phone = phn;
        accountObj.US_WSREMS__National_Provider_Identifier__c = NPI;
        accountObj.US_WSREMS__Phone_Type__c  = 'mobile';
        accountObj.US_WSREMS__EXT__c  = '123';
        accountObj.Fax = phn;
        accountObj.US_WSREMS__Email__c  ='test@test.com';
        accountObj.US_WSREMS__Preferred_Contact_Method__c  = 'email';
        accountObj.US_WSREMS__REMS_Program__c = ProgramID;
        if(isCreate){
            insert accountObj;
        }
        return accountObj;
    }
     // For SYN_ParticipantEnrollmentController_Test
    
    public static Account createPersonAccountforPatient(String NPI,Integer SLN,String phn,Boolean isCreate, ID ProgramID){
        id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.FirstName= 'Patient';
        accountObj.LastName = 'Account';
        accountObj.RecordTypeId = recordTypeId;
        accountObj.US_WSREMS__Channel__c  = 'fax';
        accountObj.US_WSREMS__SLN_State__c  ='';
        accountObj.Phone = phn;
        accountObj.US_WSREMS__NPI__c  = NPI;
        accountObj.US_WSREMS__National_Provider_Identifier__c = NPI;
        accountObj.US_WSREMS__Phone_Type__c  = 'mobile';
        accountObj.US_WSREMS__EXT__c  = '123';
        accountObj.Fax = phn;
        accountObj.US_WSREMS__Status__c = 'Enrolled';
        accountObj.US_WSREMS__Email__c  ='test@test.com';
        accountObj.US_WSREMS__Preferred_Contact_Method__c  = 'email';
        accountObj.US_WSREMS__REMS_Program__c = ProgramID;
        if(isCreate){
            insert accountObj;
        }
        return accountObj;
    }
   
      /*This method helps to create test data for Account Object for Business Account record type */
    public static Account createBusinessAccount(String accountNumber,String phn,Boolean isCreate,ID ProgramID ){
      //  List<US_WSREMS__REMS_Program__c> programList = SYN_TestDataFactory.createSOXPrograms(1, True);
        id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescribing Institution').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.Name = 'Test Facility';
        accountObj.US_WSREMS__Channel__c = 'fax';
        accountObj.Rating = 'Hot';
        accountObj.Type = 'Prospect';
        accountObj.Industry = 'Banking';
        accountObj.Ownership = 'Public';
        accountObj.Phone = phn;
        accountObj.AccountNumber = accountNumber;
        accountObj.Sic = 'Test Site';
        accountObj.RecordTypeId = recordTypeId;
        accountObj.ShippingCountry = 'United States';
        accountObj.ShippingState = '';
        accountObj.ShippingStreet = 'Test Street';
        accountObj.ShippingCity = 'Test City';
        accountObj.ShippingPostalCode = '12345';
        accountObj.US_WSREMS__REMS_Program__c = ProgramID;
        if(isCreate){
            insert accountObj;
        }
        return accountObj;
    }
    
   /* public static Account createBusinessAccount(String accountNumber,String phn,Boolean isCreate, ID ProgramID ){
        List<US_WSREMS__REMS_Program__c> programList = SYN_TestDataFactory.createSOXPrograms(1, True);
        id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescribing Institution').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.Name = 'Test Facility';
        accountObj.US_WSREMS__Channel__c = 'fax';
        accountObj.Rating = 'Hot';
        accountObj.Type = 'Prospect';
        accountObj.Industry = 'Banking';
        accountObj.Ownership = 'Public';
        accountObj.Phone = phn;
        accountObj.AccountNumber = accountNumber;
        accountObj.Sic = 'Test Site';
        accountObj.RecordTypeId = recordTypeId;
        accountObj.ShippingCountry = 'United States';
        accountObj.ShippingState = 'Alabama';
        accountObj.ShippingStreet = 'Test Street';
        accountObj.ShippingCity = 'Test City';
        accountObj.ShippingPostalCode = '12345';
        accountObj.US_WSREMS__REMS_Program__c = ProgramID;
        if(isCreate){
            insert accountObj;
        }
        return accountObj;
    }*/
    public static Account createPharmacyAccount(String accountNumber,String phn,Boolean isCreate, ID ProgramID ){
      //  List<US_WSREMS__REMS_Program__c> programList = SYN_TestDataFactory.createSOXPrograms(1, True);
        id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.Name = 'TestPharmact';
        accountObj.US_WSREMS__Channel__c = 'fax';
        accountObj.Rating = 'Hot';
        accountObj.Type = 'Prospect';
        accountObj.Industry = 'Banking';
        accountObj.Ownership = 'Public';
        accountObj.Phone = phn;
        accountObj.AccountNumber = accountNumber;
        accountObj.Sic = 'Test Site';
        accountObj.RecordTypeId = recordTypeId;
        accountObj.ShippingCountry = 'United States';
        accountObj.ShippingState = '';
        accountObj.ShippingStreet = 'Test Street';
        accountObj.ShippingCity = 'Test City';
        accountObj.ShippingPostalCode = '12345';
        accountObj.US_WSREMS__REMS_Program__c = ProgramID;
        if(isCreate){
            insert accountObj;
        }
        return accountObj;
    }
        
    public static Case CreateCase(boolean isCreate, ID ServiceId){
       Case caseObj=new Case();
        caseObj.US_WSREMS__REMS_Service_Summary__c=ServiceId;
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS-SYN_Patient_Person_Account';
        insert caseObj;
        return caseObj;
        
    } 
    public static Case CreateKACase(boolean isCreate, ID PgrmId){
        id caseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Knowledge_Assessment_A').getRecordTypeId();
        Account PhamcyPartiAccount = createPersonAccountforPharmacyParticipant(True,PgrmId,null);
        system.debug('PhamcyPartiAccount++'+PhamcyPartiAccount.id);
        Case KAcaseObj=new Case();
        KAcaseObj.Expiration_Date__c = system.today();
        KAcaseObj.US_WSREMS__Phone__c = '7896541230';
        KAcaseObj.Status = 'Complete';
        KAcaseObj.Origin = 'Email';

        KAcaseObj.US_WSREMS__Participant__c = PhamcyPartiAccount.id;
         insert KAcaseObj;
         return KAcaseObj;
         
     }
      // Create Prescriber Account
      public static Account createPrescriberAccountWithNPI(Id programObjId,Id recordTypeId){
        Account accountObj = new Account(FirstName='TestA', LastName='LastNameA',US_WSREMS__Preferred_Contact_Method__c = 'Email',
                                         US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',US_WSREMS__Email__c = 'test@gmail.com',
                                        Industry = 'Banking',Ownership = 'Public',Phone = '1234567899',AccountNumber = '4567',
                                        Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                        ShippingState = '',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                        ShippingPostalCode = '12300',SYN_Shipping_Address_2__c ='Test', US_WSREMS__National_Provider_Identifier__c='8989800000',US_WSREMS__Status__c='Certified');
        insert accountObj;
        return accountObj;
    }

// create Patient enrollment Case with status complete
public static Case createaPatientEnrollmentPatientCase(Id caseRecordTypeId,Id programObjId,String FirstName, String LastName,Id RemsServiceId , Id PatientAccountId, Id prescriberAccId){
    Case caseObj = new Case(RecordTypeId=caseRecordTypeId,US_WSREMS__REMS_Program__c =programObjId, US_WSREMS__First_Name__c = FirstName,
                           US_WSREMS__Last_Name__c =LastName,  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),
                           US_WSREMS__Fax__c = '8785968578',Status = 'Complete', US_WSREMS__Channel__c='Fax', US_WSREMS__Program_Picklist__c = 'Sodium Oxybate REMS',
                           US_WSREMS__REMS_Service_Summary__c = RemsServiceId,US_WSREMS__Patient__c=PatientAccountId,SYN_Prescriber__c = prescriberAccId,
                           US_WSREMS__State__c = 'AL', US_WSREMS__City__c = 'hyd',US_WSREMS__Signature__c = 'Yes',
                           US_WSREMS__Date__c =Date.newInstance(2001, 12, 9),US_WSREMS__Preferred_Contact_Method__c ='Email', SYN_Gender__c = 'Female',
                           SYN_Previously_Enrolled_for_Oxybate__c = 'yes', US_WSREMS__Shipping_Street__c = 'Hyd',Program_Record_Type_Control__c = 'Sodium Oxybate REMS-Patient_Enrollement',
                           SYN_Prescriber_Phone__c = '2342342342',SYN_Prescriber_Fax__c = '4564564564',SYN_Currently_Enrolled_for_Oxybate__c ='yes',
                           US_WSREMS__NPI__c ='3333322121',SYN_Zip_Code__c = '23456',SYN_Prescriber_Last_Name__c= 'Prescriber',SYN_Prescriber_First_Name__c = 'test James',US_WSREMS__DEA__c = 'Aw2343223',US_WSREMS__Shipping_City__c = 'Hyd',SYN_Shipping_State__c = 'AL',US_WSREMS__Shipping_Zip_Postal_Code__c = '34576',
                            US_WSREMS__Patient_Risk_Category__c = 'FNRP (Patient is pre-pubertal)',SYN_Street_Address__c = 'Hyd',SYN_Prescriber_Signature__c = 'yes',SYN_Prescriber_Signature_Date__c =Date.newInstance(2001, 12, 9),US_WSREMS__Outcome__c = 'Complete');
    insert caseObj;
    return caseObj;
     }
     public static US_WSREMS__Stage_Detail__c createStageDetail(String objectName, String fieldName, String fieldValue, Boolean isCreate){
        US_WSREMS__Stage_Detail__c stageDetail = new US_WSREMS__Stage_Detail__c(US_WSREMS__Object_API_Name__c = objectName, US_WSREMS__Field_API_Name__c = fieldName, US_WSREMS__Stage_Field_Value__c = fieldValue);
        if(isCreate){
            insert stageDetail;
        }
        return stageDetail;
    }
          public static Case createCase (Id caseRecordTypeId, String caseStatus, Id remsServiceId, Boolean isCreate){
        Case caseObj = new Case(RecordTypeId = caseRecordTypeId, Status = caseStatus, US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__DOB__c =(System.today()-365),Program_Record_Type_Control__c='Sodium Oxybate REMS-Patient_Enrollement');
        if(isCreate){
            insert caseObj;
        }
         return caseObj;

    }
       public static US_WSREMS__REMS_Program_Service_Config__c createREMSServiceConfig(Id programId, Id serviceApiName, Boolean isCreate){
        US_WSREMS__REMS_Program_Service_Config__c rpsc = new US_WSREMS__REMS_Program_Service_Config__c();
        rpsc.US_WSREMS__REMS_Program__c = programId;
        rpsc.US_WSREMS__Service_API_Name__c = serviceApiName;
        rpsc.US_WSREMS__Service_Name__c ='Certification';
        rpsc.US_WSREMS__Stage_Names__c ='Intake;Verification';
        rpsc.US_WSREMS__Stages__c ='Intake;Verification';
        if(isCreate){
            insert rpsc;
        }
        return rpsc;
    }
    public static Account createAccountTestRecord(String remsId,String strRecordTypeId) {
        Account actobj = new Account();
        actobj.Name='test';
        actobj.phone = '8888888888';
        actobj.RecordTypeId =strRecordTypeId;
        actobj.US_WSREMS__REMS_Program__c =remsId;
        insert actobj;
        return actobj;
    }

    public static US_WSREMS__REMS_Service_Summary__c createSummaryRecord(String actId,String remsObjId,String RemsRecordTypeId) {
        US_WSREMS__REMS_Service_Summary__c remsobj = new US_WSREMS__REMS_Service_Summary__c();
        remsobj.US_WSREMS__Participant__c  = actId;
        remsobj.US_WSREMS__REMSProgram__c = remsObjId;
        remsobj.US_WSREMS__Requestor_Type__c ='pharmacy';
        remsobj.US_WSREMS__StageName__c='Intake';
        remsObj.RecordtypeId = RemsRecordTypeId;
        insert remsobj;
        return remsobj;
    }

    public static case  createCaseRecord(String remsObjId,String actobjId,String remsobj,String CaseRecordTypeId) {

        case CaseObj = new Case();
        CaseObj.US_WSREMS__REMS_Service_Summary__c = remsobj;
        CaseObj.US_WSREMS__REMS_Program__c = remsObjId;
        CaseObj.US_WSREMS__Participant__c = actobjId;
        CaseObj.RecordTypeId = CaseRecordTypeId;
        CaseObj.US_WSREMS__Call_Notes__c = 'test';
        CaseObj.US_WSREMS__Call_Outcome__c = 'Call Back';
        CaseObj.US_WSREMS__Call_Outcome_Reason__c = 'Holiday';
        CaseObj.status = 'New';
        CaseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS-Prescriber_enrollment';
        CaseObj.US_WSREMS__Channel__c = 'Fax';
        insert CaseObj;
        return CaseObj;
    }

    public static case  createDisCaseRecord(String remsObjId,String actobjId,String remsobj,String CaseRecordTypeId) {

        case CaseObj = new Case();
        CaseObj.US_WSREMS__REMS_Service_Summary__c = remsobj;
        CaseObj.US_WSREMS__REMS_Program__c = remsObjId;
        CaseObj.US_WSREMS__Participant__c = actobjId;
        CaseObj.RecordTypeId = CaseRecordTypeId;
        CaseObj.US_WSREMS__Call_Notes__c = 'test';
        CaseObj.US_WSREMS__Call_Outcome__c = 'Call Back';
        CaseObj.US_WSREMS__Call_Outcome_Reason__c = 'Holiday';
        caseObj.US_WSREMS__Deactivation_Reason__c = 'Abuse, Misuse or Diversion';
        caseObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        caseObj.US_WSREMS__Deactivation_Date__c = System.today();
        caseObj.US_WSREMS__Program_Picklist__c = 'Sodium Oxybate REMS';
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS-Prescriber_enrollment';
        caseObj.US_WSREMS__Channel__c ='Fax';
        insert CaseObj;
        caseObj.Status = 'Complete';
        caseObj.US_WSREMS__Outcome__c = 'Complete';
        update CaseObj;
        return CaseObj;
    }
    public static Group createqueueRecord(){
        // Create a Queue
        Group testQueue = new Group(Type = 'Queue', DeveloperName = 'TestQueue', Name = 'Test Queue');
        insert testQueue;
        return testQueue;
    }
        public static Task createTaskRecord(string serviceObjId){
        Task newTask = new Task();
    		newTask.WhatId = serviceObjId;
    		newTask.ActivityDate = Date.today();
   			newTask.Status = 'Draft';
    		insert newTask; // Salesforce will automatically generate the Id
    		return newTask;
    }
    public static US_WSREMS__REMS_Service_Summary__c createSummaryRecordForPatient(String actId,String remsObjId,String RemsRecordTypeId) {
        US_WSREMS__REMS_Service_Summary__c remsobj = new US_WSREMS__REMS_Service_Summary__c();
        remsobj.US_WSREMS__Participant__c  = actId;
        remsobj.US_WSREMS__REMSProgram__c = remsObjId;
        remsobj.US_WSREMS__Requestor_Type__c ='Patient';
        remsobj.US_WSREMS__StageName__c='Intake';
        remsObj.RecordtypeId = RemsRecordTypeId;
        insert remsobj;
        return remsobj;
    }
    public static US_WSREMS__REMS_Service_Summary__c createRemsServiceSummary(Id PresAccountId,Id programObjId, Id RecordTypeId){
        US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
            US_WSREMS__Participant__c=PresAccountId,
            US_WSREMS__REMSProgram__c = programObjId,
            US_WSREMS__Status__c ='Open',
            RecordTypeId= RecordTypeId,
            US_WSREMS__Requestor_Type__c='Prescriber'
        );
        Insert objService;
        return objService;
    }
    public static Case createCase(Id PresAccountId,Id programObjId, Id RecordTypeId, Id ServiceId){
        Case cseobj = new Case(RecordTypeId = RecordTypeId,US_WSREMS__Channel__c = 'Portal',US_WSREMS__REMS_Service_Summary__c = ServiceId,
                               US_WSREMS__Program_Picklist__c = 'Sodium Oxybate REMS',SYN_Date__c = system.today(),SYN_Addendum__c ='No',
                               SYN_Type_of_Reporter__c = 'Prescribing Physician',SYN_Name_of_Reporter__c = PresAccountId,SYN_Street_Address__c = 'test',
                               US_WSREMS__State__c = 'AZ',US_WSREMS__City__c = 'test',SYN_Zip_Code__c = '12345',SYN_Nature_of_Report__c='Misuse',
                               SYN_Prescriber__c = PresAccountId,SYN_RMR_Event_Start_Date__c = system.today(),SYN_RMR_Event_Details__c = 'test',
                               SYN_Alerts_and_RMR_history_reviewed__c = 'No',SYN_Early_Refill_Requested__c ='No',SYN_Prescriber_Contacted__c = 'Prescriber is Reporter- Not Applicable',
                               SYN_Was_early_refill_approved__c = 'No',SYN_Early_refill_status_reason__c = 'test',PAE_associated_with_report__c = 'Yes',
                               SYN_Summary_of_Investigation__c = 'test',SYN_Attachments__c = 'Shipping Service Report',SYN_Should_patient_be_monitored__c = 'No',
                               SYN_Requesting_disenrollment__c = 'Yes',SYN_For_the_patient__c = 'No',SYN_For_the_prescriber__c = 'No',
                               US_WSREMS__Signature__c = 'Yes',Should_prescriber_be_monitored__c = 'Yes',US_WSREMS__Date__c = system.Today(), Status = 'Complete',US_WSREMS__Outcome__c = 'Complete');
        insert cseobj;
        return cseobj;
    }
    
    /* This method helps to create test data for DocumentChecklistItem with Received Document for System Admin profile(Program = Clozapine REMS)  
     * TimeZone : 'America/Los_Angeles'
     * User will be the owner of Document Detail record  
    */
    
    public static DocumentChecklistItem createDocumentChecklistItemRecord(){
    
    Profile p = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1]; 
    
    String timestamp = String.valueOf(System.now().getTime());
    String uniqueUsername = 'standarduser_' + timestamp + '@testorg.com';

    User usr = new User(
        Alias = 'standt',
        Email = 'standarduser_rems@testorg.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Testing',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = uniqueUsername
    );

    insert usr;
        
   // Create a unique program name based on a counter
    String programName = 'Clozapine REMS' + DateTime.now().getTime();
    
    US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
    programObj.Name = programName;
    programObj.US_WSREMS__Status__c ='Active';
    programObj.US_WSREMS__Program_State_Date__c = System.today();
    programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
    insert programObj;
        
        Account acc= new Account();
        acc.Name='TestAccount';
        acc.Phone='8888888888';
        acc.Fax ='8888888888';
        acc.Phone='8888888888'; 
        acc.Fax ='8888888888';
        acc.US_WSREMS__REMS_Program__c = programObj.ID;
        insert acc;
        
        ReceivedDocument rc=createReceivedDocument();
        
        DocumentChecklistItem doclist =new DocumentChecklistItem();
        doclist.name='TestDocumentchecklist';
        doclist.ParentRecordId=acc.Id;
        doclist.ReceivedDocumentId=rc.Id;
        doclist.Second_Review_Status__c ='Pending Review';
        doclist.OwnerId = usr.Id;
        insert doclist;
        return doclist;
        
    }
    
    /*This method helps to create test data for DocumentChecklistItem with Received Document for REMS Agent profile(Program = Clozapine REMS)  
    * TimeZone : 'America/New_York'
    * User will be the Second Reviewer of Document Detail record. 
    */
    
    public static DocumentChecklistItem createTestUserCPMG(){
        
    Profile p = [SELECT Id FROM Profile WHERE Name ='REMS Agent' LIMIT 1]; 
    
    String timestamp = String.valueOf(System.now().getTime());
    String uniqueUsername = 'standarduser_' + timestamp + '@testorg.com';

    User usr = new User(
        Alias = 'standt',
        Email = 'standarduser_rems@testorg.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Testing',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/New_York',
        UserName = uniqueUsername
    );

    insert usr;
        
    // Create a unique program name based on a counter
    String programName = 'Clozapine REMS' + DateTime.now().getTime();
    
    US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
    programObj.Name = programName;
    programObj.US_WSREMS__Status__c ='Active';
    programObj.US_WSREMS__Program_State_Date__c = System.today();
    programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
    insert programObj;
        
        Account acclist= new Account();
        acclist.Name='TestAccount';
        acclist.Phone='8888888888';
        acclist.Fax ='8888888888';
        acclist.Phone='8888888888'; 
        acclist.Fax ='8888888888';
        acclist.US_WSREMS__REMS_Program__c = programObj.ID;
        insert acclist;
        
        ReceivedDocument rc=createReceivedDocument();
        
        DocumentChecklistItem doculist =new DocumentChecklistItem();
        doculist.name = 'TestDocumentchecklist1';
        doculist.ParentRecordId = acclist.Id;
        doculist.ReceivedDocumentId = rc.Id;
        doculist.Second_Review_Status__c ='Pending Review';
        doculist.Second_Reviewer__c = usr.Id;
        insert doculist;
        return doculist;
    }
        public static Account createOtherREMSAccount(String accountNumber,String phn,Boolean isCreate,ID ProgramID ){
            id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Other REMS').getRecordTypeId();
            Account accountObj = new Account();
            accountObj.Name = 'Other REMS';
            accountObj.US_WSREMS__Channel__c = 'fax';
            accountObj.Rating = 'Hot';
            accountObj.Type = 'Prospect';
            accountObj.Industry = 'Banking';
            accountObj.Ownership = 'Public';
            accountObj.Phone = phn;
            accountObj.AccountNumber = accountNumber;
            accountObj.Sic = 'Test Site';
            accountObj.RecordTypeId = recordTypeId;
            accountObj.ShippingCountry = 'United States';
            accountObj.ShippingState = '';
            accountObj.ShippingStreet = 'Test Street';
            accountObj.ShippingCity = 'Test City';
            accountObj.ShippingPostalCode = '12345';
            accountObj.US_WSREMS__REMS_Program__c = ProgramID;
            if(isCreate){
                insert accountObj;
            }
            return accountObj;
        }
        public static List<US_WSREMS__REMS_Program__c> createProgram(integer noOfRecords,boolean isCreate,String prgmName,String projectCode){

            List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
            for(integer i=0; i<noOfRecords; i++){
                US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c ();
                programObj.Name = prgmName;
                programObj.US_WSREMS__Status__c  ='Active';
                programObj.REMS_Project_Code__c = projectCode;
                programObj.US_WSREMS__Program_State_Date__c  = System.today();
                programObj.US_WSREMS__Program_End_Date__c  = System.today().addDays(20);
                programList.add(programObj);
            }
            return programList;        
        }
        public static Account createPrescriberAccount(String accountNumber,String phn,Boolean isCreate, ID ProgramID ){
        
            id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
            Account accountObj = new Account();
            accountObj.FirstName = 'TestFirstName';
            accountObj.LastName = 'TestLastname';
            accountObj.US_WSREMS__Channel__c = 'fax';
            accountObj.Phone = phn;
            accountObj.AccountNumber = accountNumber;
            accountObj.Sic = 'Test Site';
            accountObj.RecordTypeId = recordTypeId;
            accountObj.ShippingCountry = 'United States';
            accountObj.ShippingState = '';
            accountObj.ShippingStreet = 'Test Street';
            accountObj.ShippingCity = 'Test City';
            accountObj.ShippingPostalCode = '12345';
            accountObj.US_WSREMS__REMS_Program__c = ProgramID;
            if(isCreate){
                insert accountObj;
            }
            return accountObj;
        }
     public static List<US_WSREMS__REMS_Program__c> createREMSPrograms(integer noOfRecords,boolean isCreate){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0;i<noOfRecords;i++){
            US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
            programObj.Name = 'AVEED Program';
            programObj.US_WSREMS__Status__c ='Active';
            programObj.US_WSREMS__Program_State_Date__c = System.today();
            programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
            programList.add(programObj);
        }

        if(isCreate && programList.size()>0){
            insert programList;
        }
        return programList;        
    } 
     public static  US_WSREMS__Assessment__c createAssessment (Id programId){
        US_WSREMS__Assessment__c testAssessment = new US_WSREMS__Assessment__c();
        testAssessment.Name='Test Assessment';
        testAssessment.US_WSREMS__REMS_Program__c = programId;
        testAssessment.US_WSREMS__Participant_Type__c = 'Prescriber';
        testAssessment.US_WSREMS__Pass_Percentage__c  = 20;
        testAssessment.US_WSREMS__Maximum_Attempts__c=3;
    
    insert testAssessment; 
     return testAssessment;
}
    public static US_WSREMS__Assessment__c createAssessments (Id programId ,String participantType){
    US_WSREMS__Assessment__c testAssessment = new US_WSREMS__Assessment__c();
    testAssessment.Name='Test Assessment';
    testAssessment.US_WSREMS__REMS_Program__c = programId;
    testAssessment.US_WSREMS__Participant_Type__c = participantType;
    testAssessment.US_WSREMS__Pass_Percentage__c  = 20;
    testAssessment.US_WSREMS__Maximum_Attempts__c=3;

    insert testAssessment; 
     return testAssessment;
    }
    public static US_WSREMS__Assessment_Submission__c createAssessmentSubmission(Id caseId,Id assessmentId ){
    US_WSREMS__Assessment_Submission__c submission = new US_WSREMS__Assessment_Submission__c();
    submission.US_WSREMS__Assessment__c = assessmentId;
    submission.US_WSREMS__Case__c= caseId;
    submission.US_WSREMS__Assessment_Result__c='Passed';
    
    insert submission;
    return submission;
    
}
 public static List<US_WSREMS__REMS_Program__c> createPrograms(integer noOfRecords,boolean isCreate){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0;i<noOfRecords;i++){
            US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
            programObj.Name = 'AVEED REMS';
            programObj.US_WSREMS__Status__c ='Active';
            programObj.US_WSREMS__Program_State_Date__c = System.today();
            programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
            programList.add(programObj);
        }

        if(isCreate && programList.size()>0){
            insert programList;
        }
        return programList;        
    } 
    
    
}