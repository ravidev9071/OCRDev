/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-18-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SYN_FaxHanlder_test {
    
    @testSetup
    public static void dataSetup(){
        US_WSREMS__REMS_Program__c remsProg1 = new US_WSREMS__REMS_Program__c();
        remsProg1.Name = 'Sodium Oxybate REMS';
        remsProg1.REMS_Project_Code__c = 'BT6825';
        remsProg1.US_WSREMS__Status__c ='Active';
        remsProg1.QueueName__c ='Syneos Test Call Queue';
        insert remsProg1;
        Id patientRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        Id providerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Account patientAccount = SYN_TestDataUtility.createAccount(remsProg1.Id,patientRecTypeId,'TestPatientFristName','TestPatientLastName');
        patientAccount.Fax = '1234568781';
        patientAccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        update patientAccount;
        
        Account providerAccount = SYN_TestDataUtility.createAccount(remsProg1.Id,providerRecTypeId,'TestProviderFristName','TestProviderLastName');
        providerAccount.Fax = '1234568780';
        providerAccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        Update providerAccount;
        
        
        Id enrollmentCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Patient Enrollment').getRecordTypeId();
        
        Case caseObj1 = SYN_TestDataUtility.createaNewCase(enrollmentCaseRecTypeId,'TestCaseFirstName','TestCaseLastName','Draft',remsProg1.Id);
        caseObj1.Medical_Conditions__c = 'COPD';
        caseObj1.US_WSREMS__Participant__c = patientAccount.Id;
        caseObj1.SYN_Prescriber_Fax__c = '1234567891';
        caseObj1.US_WSREMS__Patient__c = patientAccount.Id;
        caseObj1.US_WSREMS__Prescriber__c = providerAccount.Id;
        caseObj1.US_WSREMS__Phone__c = '9876543210';
        update caseObj1;
        //remsOutComm Object created by sarath R-21-02-2023.
        REMS_Outbound_Communication__c remsOutComm= new REMS_Outbound_Communication__c();
        remsOutComm.Case__c = caseObj1.Id;
        remsOutComm.OBCom_Type__c ='Fax';
        remsOutComm.Status__c = 'Pending';
        insert remsOutComm;
        
        
    }
    @isTest
    static void sendfaxTest()
    {   
        Test.startTest();
        case cs = [SELECT Id,SYN_Prescriber__r.US_WSREMS__Email__c,RecordTypeId,SYN_Authorized_Rep__r.personContactId,US_WSREMS__Participant__c,US_WSREMS__Participant__r.US_WSREMS__Email__c,US_WSREMS__Participant__r.Fax,
        Status,ownerId,US_WSREMS__Participant__r.personContactId,SYN_Prescriber__r.Fax,US_WSREMS__Program_Name__c,Medical_Conditions__c,
        US_WSREMS__Participant__r.US_WSREMS__Preferred_Contact_Method__c,SYN_Prescriber_Fax__c,US_WSREMS__Patient__r.Fax,US_WSREMS__Pharmacy_User__r.Fax,owner.email,owner.name,
        CaseNumber,Subject,X1_Pharmacy_Participant__c,SYN_Name_of_Reporter__c,SYN_Name_of_Reporter__r.Fax,SYN_Name_of_Reporter__r.personContactId,SYN_Pharmacist__r.personContactId,X1_Pharmacy_Participant__r.US_WSREMS__Email__c,US_WSREMS__Fax__c,SYN_Prescriber__r.firstName, SYN_Prescriber__r.LastName, US_WSREMS__Patient__r.firstName, US_WSREMS__Patient__r.LastName, 
        US_WSREMS__Pharmacy_User__r.firstName, US_WSREMS__Email__c,US_WSREMS__Pharmacy_User__r.LastName,US_WSREMS__Participant__r.firstName,US_WSREMS__Participant__r.LastName,US_WSREMS__Participant__r.Name,US_WSREMS__Distributor__r.US_WSREMS__Email__c  FROM Case WHERE US_WSREMS__Last_Name__c ='TestCaseLastName'];
        REMS_Outbound_Communication__c remscomObj = [Select Id, Case__c,OBCom_Type__c,Status__c from REMS_Outbound_Communication__c where Case__c =:cs.Id];
        string tempName = 'SOX Noncompliance Notification';
        string recipientType1 = 'Prescriber';
        string recipientType2= 'Patient';
        string recipientType3='Pharmacy User';
        string recipientType4='Test';
        string type='case';
        REMS_Correspondence_Settings__mdt CorresSett = [SELECT Id, From__c, Template_Name__c FROM REMS_Correspondence_Settings__mdt WHERE Active__c = TRUE LIMIT 1];
        
        Blob b = Blob.valueOf('Test Data');
        
        Attachment attachment = new Attachment();
        attachment.ParentId = cs.id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b; 
        insert attachment;                                            
        
        List<String> attclist= new List<String>(); 
        attclist.add(attachment.id);   
        Map<string,string> fieldValueMap = SYN_CommonUtility.getObjectFieldValues(cs); 
       
        fieldValueMap.put('CommunicationId',remscomObj.id);
        
        SYN_FaxHanlder.createeFaxPayLoad(cs, corresSett.Template_Name__c, recipientType1, attclist,fieldValueMap ,type);
        
        
        US_WSREMS__REMS_Program__c remobj = [Select id from US_WSREMS__REMS_Program__c WHERE Name= 'Sodium Oxybate REMS'];
        
        String strRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        Account actobj  = SYN_TestDataFactory.createAccountTestRecord(remobj.id,strRecordTypeId);
        id RemsRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Inbound_Communication').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c remsobj = SYN_TestDataFactory.createSummaryRecord(actobj.Id,remobj.id,RemsRecordTypeId);
        id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        case CaseObj  = SYN_TestDataFactory.createCaseRecord(remobj.id,actobj.Id,remsobj.id,CaseRecordTypeId);
        Map<string,string> fieldValueMap1 = SYN_CommonUtility.getObjectFieldValues(CaseObj); 
        fieldValueMap1.put('CommunicationId',remscomObj.id);
        fieldValueMap1.put('caseFax','9912334422');
        fieldValueMap1.put('NameOfReporterFax','9912334422');
        fieldValueMap1.put('authRepFax','9912334422');
        fieldValueMap1.put('prescriberFax','9912334422');
        Id pharmacyEnrollcaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Pharmacy_Enrollment');       
        
        
        SYN_FaxHanlder.createeFaxPayLoad(cs, corresSett.Template_Name__c, 'All', attclist,fieldValueMap1,type );
        
        SYN_FaxHanlder.createeFaxPayLoad(cs, corresSett.Template_Name__c, 'Pharmacist', attclist,fieldValueMap1,type );
        
        SYN_FaxHanlder.createeFaxPayLoad(cs, corresSett.Template_Name__c, 'Patient', attclist,fieldValueMap1,type );

        SYN_FaxHanlder.createeFaxPayLoad(cs, corresSett.Template_Name__c, 'Health Care Setting', attclist,fieldValueMap1,type );

        fieldValueMap1.put('RecordType',pharmacyEnrollcaseRecTypeId);
        SYN_FaxHanlder.createeFaxPayLoad(cs, corresSett.Template_Name__c, 'All', attclist,fieldValueMap1,type);
        
        fieldValueMap1.put('RecordType',pharmacyEnrollcaseRecTypeId);
        SYN_FaxHanlder.createeFaxPayLoad(cs, corresSett.Template_Name__c, 'All', attclist,fieldValueMap1,type);

        fieldValueMap1.put('USREMSPROGNAME','AVEED REMS');
        SYN_FaxHanlder.createeFaxPayLoad(cs, corresSett.Template_Name__c, 'Health Care Setting', attclist,fieldValueMap1,type);

        SYN_FaxHanlder.createeFaxPayLoad(cs, corresSett.Template_Name__c, 'Prescriber', attclist,fieldValueMap1,type);

        Test.stopTest();  
    }

    @isTest
    static void createContentDocumentLinkTest() {

        Id accountId = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());  

        Id contentVerId = SYN_TestDataUtility.getSobjectId(ContentVersion.getSObjectType());

        test.startTest();
            ContentDocumentLink contentDoc = SYN_FaxHanlder.createContentDocumentLink(contentVerId, accountId);
        test.stopTest();

        System.assertEquals(contentDoc.Visibility ,'InternalUsers');
    }  
    
}