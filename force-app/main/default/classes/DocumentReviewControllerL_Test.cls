/**
* @Description        : Test Class for DocumentReviewControllerL Class.
* @Author 			    : 
* @Modification Log   : 
* Ver       Date            Developer      		        Modification
*                          	Wilco Source        		Initial Implementation.
**/
@isTest
public with sharing class DocumentReviewControllerL_Test {
    static TestMethod void  retrieveFilesOnDocumentDetailTest(){
        ReceivedDocument docObj = REMSTestDataFactoryL.createReceivedDocument();
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        programList = REMSTestDataFactoryL.createPrograms(1,true);
        DocumentChecklistItem docCheckObj = REMSTestDataFactoryL.createDocumentChecklistItem(docObj.Id,programList[0].Id);
        ContentVersion versionObj = REMSTestDataFactoryL.createContentVersion();
        ContentDocumentLink contentDocObj = REMSTestDataFactoryL.createContentDocument(docCheckObj.Id);
        DocumentReviewControllerL.retrieveFilesOnDocumentDetail(docCheckObj.Id);
        DocumentReviewControllerL.retrieveFileOnDocumentDetail(docCheckObj.Id);
    }

    static TestMethod void  retrieveAccountConfigFieldsTest(){
        List<Dynamic_Account_Search_Config__mdt> accConfgList = (List<Dynamic_Account_Search_Config__mdt>)Json.deserialize('[{"Id":"m0D8H00000006VQUAY", "DeveloperName":"Name", "US_WSREMS__DataType__c":"Text", "US_WSREMS__Field_Label__c":"Name", "US_WSREMS__Field_Name__c":"Name", "US_WSREMS__PlaceHolder__c":"Search by Name", "US_WSREMS__Order__c":"1", "US_WSREMS__Required__c":"false"},'+
        +'{"Id":"m0D8H00000006VVUAY", "DeveloperName":"Phone", "US_WSREMS__DataType__c":"Phone", "US_WSREMS__Field_Label__c":"Phone", "US_WSREMS__Field_Name__c":"Phone", "US_WSREMS__PlaceHold":"Search by Name", "US_WSREMS__Order__c":"2", "US_WSREMS__Required__c":"false"},'+
        +'{"Id":"m0D8H00000006VVUAY", "DeveloperName":"Phone", "US_WSREMS__DataType__c":"Phone", "US_WSREMS__Field_Label__c":"Phone", "US_WSREMS__Field_Name__c":"Phone", "US_WSREMS__PlaceHold":"Search by Name", "US_WSREMS__Order__c":"2", "US_WSREMS__Required__c":"false"},'+
        +'{"Id":"m0D8H00000006j5UAA", "DeveloperName":"Program", "US_WSREMS__DataType__c":"Combobox", "US_WSREMS__Field_Label__c":"Program", "US_WSREMS__Field_Name__c":"US_WSREMS__REMS_Program__c", "US_WSREMS__PlaceHolder__c":"Select Program","US_WSREMS__Order__c":"6", "US_WSREMS__Required__c":"true"},'+
        +'{"Id":"m0D8H00000006j5UAA", "DeveloperName":"Type", "US_WSREMS__DataType__c":"Combobox", "US_WSREMS__Field_Label__c":"Type", "US_WSREMS__Field_Name__c":"Type", "US_WSREMS__PlaceHolder__c":"Select Program","US_WSREMS__Order__c":"6", "US_WSREMS__Required__c":"true"},'+
        +'{"Id":"m0D8H00000006hEUAQ", "DeveloperName":"DOB", "US_WSREMS__DataType__c":"Date", "US_WSREMS__Field_Label__c":"Date Of Birth", "US_WSREMS__Field_Name__c":"DOB__c", "US_WSREMS__PlaceHolder__c":"Search by DOB", "US_WSREMS__Order__c":"4", "US_WSREMS__Required__c":"false"}]', List<Dynamic_Account_Search_Config__mdt>.class); 
        DocumentReviewControllerL.testAccConfigList = accConfgList;
        DocumentReviewControllerL.retrieveAccountConfigFields();
    }

    static TestMethod void  retriveExistingRemsServicesTest(){
        List<Dynamic_Account_Search_Config__mdt> accConfgList = (List<Dynamic_Account_Search_Config__mdt>)Json.deserialize('[{"Id":"m0D8H00000006VQUAY", "DeveloperName":"Name", "US_WSREMS__DataType__c":"Text", "US_WSREMS__Field_Label__c":"Name", "US_WSREMS__Field_Name__c":"Name", "US_WSREMS__PlaceHolder__c":"Search by Name", "US_WSREMS__Order__c":"1", "US_WSREMS__Required__c":"false"},'+
        +'{"Id":"m0D8H00000006VVUAY", "DeveloperName":"Phone", "US_WSREMS__DataType__c":"Phone", "US_WSREMS__Field_Label__c":"Phone", "US_WSREMS__Field_Name__c":"Phone", "US_WSREMS__PlaceHold":"Search by Name", "US_WSREMS__Order__c":"2", "US_WSREMS__Required__c":"false"},'+
        +'{"Id":"m0D8H00000006VVUAY", "DeveloperName":"Phone", "US_WSREMS__DataType__c":"Phone", "US_WSREMS__Field_Label__c":"Phone", "US_WSREMS__Field_Name__c":"Phone", "US_WSREMS__PlaceHold":"Search by Name", "US_WSREMS__Order__c":"2", "US_WSREMS__Required__c":"false"},'+
        +'{"Id":"m0D8H00000006j5UAA", "DeveloperName":"Program", "US_WSREMS__DataType__c":"Combobox", "US_WSREMS__Field_Label__c":"Program", "US_WSREMS__Field_Name__c":"US_WSREMS__REMS_Program__c", "US_WSREMS__PlaceHolder__c":"Select Program","US_WSREMS__Order__c":"6", "US_WSREMS__Required__c":"true"},'+
        +'{"Id":"m0D8H00000006j5UAA", "DeveloperName":"Type", "US_WSREMS__DataType__c":"Combobox", "US_WSREMS__Field_Label__c":"Type", "US_WSREMS__Field_Name__c":"Type", "US_WSREMS__PlaceHolder__c":"Select Program","US_WSREMS__Order__c":"6", "US_WSREMS__Required__c":"true"},'+
        +'{"Id":"m0D8H00000006hEUAQ", "DeveloperName":"DOB", "US_WSREMS__DataType__c":"Date", "US_WSREMS__Field_Label__c":"Date Of Birth", "US_WSREMS__Field_Name__c":"DOB__c", "US_WSREMS__PlaceHolder__c":"Search by DOB", "US_WSREMS__Order__c":"4", "US_WSREMS__Required__c":"false"}]', List<Dynamic_Account_Search_Config__mdt>.class); 
  
        List<ServiceTreeViewQueryConfig__mdt > treeConfgList = (List<ServiceTreeViewQueryConfig__mdt >)Json.deserialize('[{"Label":"REMSServiceQuery","US_WSREMS__Object_API_Name__c":"US_WSREMS__REMS_Service_Summary__c","US_WSREMS__Fields_to_Query__c":"Id,Name,RecordType.Name,REMSProgram__r.Name,Requestor_Type__c,US_WSREMS__Status__c,US_WSREMS__Participant__c","MasterLabel":"REMSServiceQuery","US_WSREMS__Column_Field_API_Map__c":"null","Language":"en_US"},'+
        +'{"Label":"CaseQuery","US_WSREMS__Object_API_Name__c":"Case","US_WSREMS__Fields_to_Query__c":"Id,CaseNumber,Status,US_WSREMS__REMS_Service_Summary__c","US_WSREMS__Parent_FieldAPI_Names__c":"US_WSREMS__REMS_Service_Summary__c","MasterLabel":"CaseQuery","US_WSREMS__Column_Field_API_Map__c":"null","Language":"en_US","QualifiedApiName":"US_WSREMS__Case_Query","Id":"m0G8H0000000R7A"},'+
        +'{"Label":"Account_Query","US_WSREMS__Object_API_Name__c":"Account","US_WSREMS__Fields_to_Query__c":"Id,Name","US_WSREMS__Parent_FieldAPI_Names__c":"null","MasterLabel":"Account_Query","US_WSREMS__Column_Field_API_Map__c":"null","Language":"en_US","QualifiedApiName":"US_WSREMS__Account_Query","Id":"m0G8H0000000R7F"}]', List<ServiceTreeViewQueryConfig__mdt >.class); 
        
        List<ServiceTreeViewConfig__mdt> treeViewConfigList = (List<ServiceTreeViewConfig__mdt>)Json.deserialize('[{"US_WSREMS__Field_Name__c":"US_WSREMS__Requestor_Type__c","US_WSREMS__Label__c":"Requester Type", "US_WSREMS__Order__c":3, "US_WSREMS__Type__c":"text", "US_WSREMS__Visible_on_UI__c":false}]', List<ServiceTreeViewConfig__mdt>.class); 
    
        DocumentReviewControllerL.testAccConfigList = accConfgList;
        DocumentReviewControllerL.testQueryConfigList = treeConfgList;
        DocumentReviewControllerL.testTreeViewList = treeViewConfigList;
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        List<case> caseList = new List<case> ();
        List<String> caseQueryFlds = new List<String>{'Status'};
        programList = REMSTestDataFactoryL.createPrograms(1,true);
        Account accObj = REMSTestDataFactoryL.createBusinessAccount('12345','99999999',False);
        accObj.US_WSREMS__REMS_Program__c=programList[0].Id;
        accObj.recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        Insert accObj;
        US_WSREMS__Stage_Detail__c objStageDetail = REMSTestDataFactoryL.createStageDetail('REMS_Service_Summary__c','Path_Stage_Name__c','Intake',true );
        Schema.DescribeSObjectResult resSchema = US_WSREMS__REMS_Service_Summary__c.sObjectType.getDescribe();       
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();        
        Id recordTypeId = recordTypeInfo.get('Enrollment').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceSummaryObj = REMSTestDataFactoryL.createService(false,programList[0].Id,recordTypeId);
        serviceSummaryObj.US_WSREMS__Participant__c = accObj.Id;
        serviceSummaryObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        insert serviceSummaryObj;
        Schema.DescribeSObjectResult caseSchema = Case.sObjectType.getDescribe(); 
        Map<String,Schema.RecordTypeInfo> caserecordTypeInfo = caseSchema.getRecordTypeInfosByName();
        Id caserecordTypeId = caserecordTypeInfo.get('Patient Enrollment').getRecordTypeId();
        Case caseObj = REMSTestDataFactoryL.createCase(caserecordTypeId, 'New', serviceSummaryObj.Id, true);
        caseList.add(caseObj);
        String accountValues = '{"Name":"Test Facility"}';
        DocumentReviewControllerL.retriveExistingRemsServices(accountValues);
        DocumentReviewControllerL.getPrograms();
        DocumentReviewControllerL.getComponentName('Sample REMS Program','Authorized Representative','Account Creation');
        DocumentReviewControllerL.getREMSServiceViewConfig('REMSServiceTable');
        DocumentReviewControllerL.retrieveRemsChildCases(serviceSummaryObj.Id,caseQueryFlds);
        DocumentReviewControllerL.updateCases(caseList);
    }

    static TestMethod void  getProgramServiceConfigRecordTypeListTest(){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        programList = REMSTestDataFactoryL.createPrograms(1,true);
        REMSTestDataFactoryL.createREMSServiceConfig(programList[0].Id,'0125Y000001OVY7QAO',true);
        DocumentReviewControllerL.getProgramServiceConfigRecordTypeList(programList[0].Id);
    }

    static TestMethod void  updateReceivedDetailsDocumentListTest(){
        List<US_WSREMS__Program_Configuration__mdt> progMap = (List<US_WSREMS__Program_Configuration__mdt>)Json.deserialize('[{"Id": "xoid914011599","DeveloperName": "Test_Program","US_WSREMS__Portal_Sharing_Account__c": true,"US_WSREMS__Prevent_Duplicate_Account__c" : true,"US_WSREMS__Prevent_Service_Closer__c" : true,"US_WSREMS__Sync_Case_Account__c" : true,"MasterLabel":"Test Program"}]', List<US_WSREMS__Program_Configuration__mdt>.class); 
        List<US_WSREMS__Pagelayout_Configuration__mdt> pgLayoutMap = (List<US_WSREMS__Pagelayout_Configuration__mdt>)Json.deserialize('[{"US_WSREMS__Object_Name__c": "Case","US_WSREMS__PageLayout_Name__c": "Case-US_WSREMS__Prescribing Institution Enrollment","US_WSREMS__Program_Name__c" : "xoid914011599","US_WSREMS__Program_Name__r.label" : "Test Program","US_WSREMS__RecordType_Name__c": "PrescribingInstitution_Enrollment","US_WSREMS__Rems_Service_RCtype__c" : "Participant_Enrollment","US_WSREMS__Requestor_Type__c": "Prescribing Institution","DeveloperName" : "Prescribing_Institution"}]', List<US_WSREMS__Pagelayout_Configuration__mdt>.class); 
        DocumentReviewControllerL.testPagelayoutList = pgLayoutMap;
        ReceivedDocument docObj = REMSTestDataFactoryL.createReceivedDocument();
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        programList = REMSTestDataFactoryL.createPrograms(1,true);
        Account accObj = REMSTestDataFactoryL.createBusinessAccount('12345','99999999',false);
        accObj.US_WSREMS__REMS_Program__c=programList[0].Id;
        accObj.recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        Insert accObj;
        DocumentChecklistItem docCheckObj = REMSTestDataFactoryL.createDocumentChecklistItem(docObj.Id,programList[0].Id);
        Schema.DescribeSObjectResult resSchema = US_WSREMS__REMS_Service_Summary__c.sObjectType.getDescribe();       
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();        
        Id recordTypeId = recordTypeInfo.get('Enrollment').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceSummaryObj = REMSTestDataFactoryL.createService(false,programList[0].Id,recordTypeId);
        serviceSummaryObj.US_WSREMS__Participant__c = accObj.Id;
        serviceSummaryObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        insert serviceSummaryObj;
        DocumentReviewControllerL.updateReceivedDetailsDocumentList(serviceSummaryObj.Id,docCheckObj.Id);
        DocumentReviewControllerL.retrieveDocumentDetails(docCheckObj.Id);
        Map<String,String> recTypeMap = DocumentReviewControllerL.getRecordTypes('REMS_Service_Summary__c');
        DocumentReviewControllerL.getProgramServicelayoutConfig(recTypeMap.values()[0]);
    }

    static TestMethod void  getProgramServicelayoutConfigBasedonProgramTest(){
        List<US_WSREMS__Program_Configuration__mdt> progMap = (List<US_WSREMS__Program_Configuration__mdt>)Json.deserialize('[{"Id": "xoid914011599","DeveloperName": "Test_Program","US_WSREMS__Portal_Sharing_Account__c": true,"US_WSREMS__Prevent_Duplicate_Account__c" : true,"US_WSREMS__Prevent_Service_Closer__c" : true,"US_WSREMS__Sync_Case_Account__c" : true,"MasterLabel":"Test Program"}]', List<US_WSREMS__Program_Configuration__mdt>.class); 
        List<US_WSREMS__Pagelayout_Configuration__mdt> pgLayoutMap = (List<US_WSREMS__Pagelayout_Configuration__mdt>)Json.deserialize('[{"US_WSREMS__Object_Name__c": "Case","US_WSREMS__PageLayout_Name__c": "Case-US_WSREMS__Prescribing Institution Enrollment","US_WSREMS__Program_Name__c" : "xoid914011599","US_WSREMS__Program_Name__r.label" : "Test Program","US_WSREMS__RecordType_Name__c": "PrescribingInstitution_Enrollment","US_WSREMS__Rems_Service_RCtype__c" : "Participant_Enrollment","US_WSREMS__Requestor_Type__c": "Prescribing Institution","DeveloperName" : "Prescribing_Institution"}]', List<US_WSREMS__Pagelayout_Configuration__mdt>.class); 
        DocumentReviewControllerL.testPagelayoutList = pgLayoutMap;
        ReceivedDocument docObj = REMSTestDataFactoryL.createReceivedDocument();
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        programList = REMSTestDataFactoryL.createPrograms(1,true);
        Account accObj = REMSTestDataFactoryL.createBusinessAccount('12345','99999999',false);
        accObj.US_WSREMS__REMS_Program__c=programList[0].Id;
        accObj.recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();
        Insert accObj;
        DocumentChecklistItem docCheckObj = REMSTestDataFactoryL.createDocumentChecklistItem(docObj.Id,programList[0].Id);
        Schema.DescribeSObjectResult resSchema = US_WSREMS__REMS_Service_Summary__c.sObjectType.getDescribe();       
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();        
        Id recordTypeId = recordTypeInfo.get('Enrollment').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceSummaryObj = REMSTestDataFactoryL.createService(false,programList[0].Id,recordTypeId);
        serviceSummaryObj.US_WSREMS__Participant__c = accObj.Id;
        serviceSummaryObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        insert serviceSummaryObj;
        DocumentReviewControllerL.updateReceivedDetailsDocumentList(serviceSummaryObj.Id,docCheckObj.Id);
        DocumentReviewControllerL.retrieveDocumentDetails(docCheckObj.Id);
        Map<String,String> recTypeMap = DocumentReviewControllerL.getRecordTypes('REMS_Service_Summary__c');
       // DocumentReviewControllerL.getProgramServicelayoutConfigBasedonProgram(recTypeMap.values()[0],programList[0].Id);
    }
}