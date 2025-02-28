/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-19-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SYN_CongaUtility_Test 
{
    static HttpResponse response;
    Static String successData= 'Success';
    @TestSetup
    static void  testDataSetup(){
        US_WSREMS__REMS_Program__c remsProgram = SYN_TestDataUtility.createProgram('Sodium Oxybate Rems', 'Active');
        id patientAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        
        Account patientAccObj = SYN_TestDataUtility.createAccount(remsProgram.id, patientAccRecTypeId, 'FirstName', 'LastName');
        patientAccObj.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        update patientAccObj;
        
        id rmrCaseRecTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Risk Management Report').getRecordTypeId();
        
        id patientEnrollCaseRecTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Patient Enrollment').getRecordTypeId();
        
        Case patEnrollCaseObj = SYN_TestDataUtility.createaNewCase(patientEnrollCaseRecTypeId,'FirstName','LastName', 'Draft',remsProgram.id);
        
        REMS_Outbound_Communication__c recordObj=new REMS_Outbound_Communication__c();
        recordObj.Status__c='Sent';
        insert recordObj;
        
        APXTConga4__Conga_Template__c congaTemplate = new APXTConga4__Conga_Template__c();
        congaTemplate.APXTConga4__Name__c = 'Test Template';
        insert congaTemplate;

        APXTConga4__Conga_Merge_Query__c congaMergeQuery = new APXTConga4__Conga_Merge_Query__c();
        congaMergeQuery.APXTConga4__Name__c = 'HCS Enrollment Case Query';
        insert congaMergeQuery;
    }
    
    public class MockSuccess implements HttpcalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            response = new HttpResponse();
            response.setbody(successData);
            response.setstatuscode(200);
            return response;
        }
    }
    
    static testMethod void testCallout() {  
        
        REMS_Correspondence_Settings__mdt resCorresSettList = [SELECT Id, DeveloperName, MasterLabel, Active__c, Conga_Attachment_Template__c, From__c, Object_Name__c, Product__c, Program_Configuration__c, 
                                                               Program_Configuration__r.MasterLabel, Recipient_Email_Field__c, Recipient_Type__c, Template_Name__c, Type__c 
                                                               FROM REMS_Correspondence_Settings__mdt 
                                                               WHERE Active__c = TRUE AND MasterLabel = 'SOX-Stakeholder_Enrollment_Missing_Info'];
        
        APXTConga4__Conga_Template__c congaTemlate = [Select Id,APXTConga4__Name__c From APXTConga4__Conga_Template__c];
        resCorresSettList.Conga_Attachment_Template__c = congaTemlate.APXTConga4__Name__c;
        resCorresSettList.Template_Name__c = 'PAE_PC_MI';
        
        Account patientAccObj= [SELECT Id, FirstName,LastName,US_WSREMS__REMS_Program__c,Rating,Type,Industry,Ownership,Phone,AccountNumber,Sic,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,ShippingCountry,ShippingState,ShippingStreet,ShippingCity,ShippingPostalCode,SYN_Shipping_Address_2__c FROM Account LIMIT1];
        
        Case patEnrollCaseObj = [SELECT Id,US_WSREMS__First_Name__c,US_WSREMS__Last_Name__c,US_WSREMS__Phone__c,US_WSREMS__DOB__c,US_WSREMS__Fax__c,Status,US_WSREMS__REMS_Program__c FROM Case];
        
        REMS_Outbound_Communication__c commId = [SELECT Id FROM REMS_Outbound_Communication__c LIMIT 1];
        Map<string,string> fieldMapVal = new Map<string,string>();
        fieldMapVal.put('CommunicationId',commId.id);
        
        string corresType = patientAccObj.US_WSREMS__Preferred_Contact_Method__c;
        
        patEnrollCaseObj.US_WSREMS__Participant__c = patientAccObj.id;
        patEnrollCaseObj.Status = 'Complete';
        patEnrollCaseObj.Approval_Status__c = 'DEA Override Approved';
        patEnrollCaseObj.US_WSREMS__Patient__c = patientAccObj.id;
        patEnrollCaseObj.US_WSREMS__Outcome__c = 'Complete';
        string obj='case';
        Update patEnrollCaseObj;
        Test.setMock(HttpCalloutMock.class, new MockSuccess());
        
        test.startTest();
        SYN_CongaUtility genPDF = new SYN_CongaUtility();
        SYN_CongaUtility.GeneratePDFUsingConga genPDFConga = new SYN_CongaUtility.GeneratePDFUsingConga(patEnrollCaseObj.id,resCorresSettList,corresType,fieldMapVal,Obj);
        System.enqueueJob(genPDFConga);
        ID jobID = System.enqueueJob(genPDFConga);
        System.debug('jobId'+jobID);
        test.stopTest();
        System.assertEquals(jobID, jobID);
        
    }    
    }