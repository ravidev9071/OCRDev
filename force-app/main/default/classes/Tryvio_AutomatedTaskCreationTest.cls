@isTest
public class Tryvio_AutomatedTaskCreationTest {
    @testsetup
    public static void Tryvio_AutomatedTaskCreationSetupdata() { 
        US_WSREMS__REMS_Program__c remsProgram = new US_WSREMS__REMS_Program__c(Name = 'TRYVIO REMS',US_WSREMS__Status__c ='Active',REMS_Project_Code__c = 'BT4324'); 
        insert  remsProgram;
        Id prescriberAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Account prescriberAccObj = SYN_TestDataUtility.createAccount(remsProgram.id, prescriberAccRecTypeId, 'FirstName', 'LastName');
        prescriberAccObj.US_WSREMS__Email__c='test@test.com';
        prescriberAccObj.PersonEmail='test@test.com';
        update prescriberAccObj;
        Account prescriberAccObjNew = SYN_TestDataUtility.createAccount(remsProgram.id, prescriberAccRecTypeId, 'FirstName', 'LastName');
        prescriberAccObjNew.US_WSREMS__Email__c='abc@test.com';
        prescriberAccObjNew.PersonEmail='abc@test.com';
        update prescriberAccObjNew;
        Id nonComplianceRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();
        Id paeRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PAE').getRecordTypeId();
        Case caseRec = new Case();
        caseRec.RecordTypeId=nonComplianceRTId;   
        caseRec.US_WSREMS__Program_Picklist__c ='TRYVIO REMS';
        caseRec.US_WSREMS__REMS_Program__c = remsProgram.id;
        caseRec.US_WSREMS__Call_Notes__c = 'test';
        caseRec.Us_WSREMS__Participant__c=prescriberAccObjNew.id;
        caseRec.AccountId=prescriberAccObj.Id;
        caseRec.US_WSREMS__REMS_Authorized_Rep__c=prescriberAccObjNew.id;
        caseRec.Status='Draft';
        caseRec.Program_Record_Type_Control__c='TRYVIO REMS-Non_Compliance';
        caseRec.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
        insert caseRec;
        Contact con=new Contact();            
        con.LastName='TestLName';
        insert con;
    }
    @isTest
    public static void createCommplianceTest(){
        Case caseNewRec=[Select Id,US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__Email__c,Status,US_WSREMS__Pharmacy__c,US_WSREMS__Pharmacy_Type__c,US_WSREMS__REMS_Authorized_Rep__c,US_WSREMS__Status__c,Us_WSREMS__Participant__r.US_WSREMS__Email__c,US_WSREMS__REMS_Authorized_Rep__r.FirstName,US_WSREMS__REMS_Authorized_Rep__r.LastName,US_WSREMS__Program_Name__c From case Where Us_WSREMS__Participant__r.US_WSREMS__Email__c='abc@test.com' limit 1];
        List<case>caseLst=new List<case>();
        caseLst.add(caseNewRec);
        Map<Id, Case> caseNewMap=new Map<Id, Case>();
        caseNewMap.put(caseNewRec.id,caseNewRec);     
        Id ownId=UserInfo.getUserId();
        Date dueDate=Date.newInstance(2016, 12, 9);
        Tryvio_AutomatedTaskCreation.createNoncomplainceTask(caseLst,caseNewMap,false,'test');
        
        
    }
    
}