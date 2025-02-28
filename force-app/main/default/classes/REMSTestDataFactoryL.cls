/*
Author : Wilcosource
Date: 09-06-2021
Description : This class holds utility mehtods for data setup

*/
public with sharing class REMSTestDataFactoryL {
    
    public static List<US_WSREMS__REMS_Program__c> createPrograms(integer noOfRecords,boolean isCreate){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0;i<noOfRecords;i++){
            US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
            programObj.Name = 'Test Program';
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
    
    public static US_WSREMS__REMS_Service_Summary__c createService(boolean isCreate,Id programId,Id recordTypeId){
        
        US_WSREMS__REMS_Program_Service_Config__c remsServiceConfigObj = new US_WSREMS__REMS_Program_Service_Config__c();
        remsServiceConfigObj.US_WSREMS__REMS_Program__c = programId;
        remsServiceConfigObj.US_WSREMS__Service_API_Name__c = recordTypeId;
        remsServiceConfigObj.US_WSREMS__Stage_Names__c = 'Intake;Verification;Assessment';
        remsServiceConfigObj.US_WSREMS__Stages__c = 'Intake';
        insert remsServiceConfigObj;
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programId;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.US_WSREMS__Status__c= 'Open';
        serviceObj.recordTypeId = recordTypeId;
        if(isCreate){
            insert serviceObj;
        }
        return serviceObj;
        
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
    
    public static Case createCase (Id caseRecordTypeId, String caseStatus, Id remsServiceId, Boolean isCreate){
        Case caseObj = new Case(RecordTypeId = caseRecordTypeId, Status = caseStatus, US_WSREMS__REMS_Service_Summary__c = remsServiceId);
        caseObj.US_WSREMS__DOB__c = Date.newInstance(1996, 12, 9);
        caseObj.Program_Record_Type_Control__c  = 'Macitentan REMS-Patient_Enrollement';
        caseObj.US_WSREMS__Channel__c = 'Fax';
        if(isCreate){
            insert caseObj;
        }
        return caseObj;   
        
    }
    
    
    public static US_WSREMS__Stage_Detail__c createStageDetail(String objectName, String fieldName, String fieldValue, Boolean isCreate){
        US_WSREMS__Stage_Detail__c stageDetail = new US_WSREMS__Stage_Detail__c(US_WSREMS__Object_API_Name__c = objectName, US_WSREMS__Field_API_Name__c = fieldName, US_WSREMS__Stage_Field_Value__c = fieldValue);
        if(isCreate){
            insert stageDetail;
        }
        return stageDetail;
    }
    
    
    /*This method helps to create test data for Account Object for Business Account record type */
    public static Account createBusinessAccount(String accountNumber,String phn,Boolean isCreate){
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
        accountObj.Phone = '9848022338';
        if(isCreate){
            insert accountObj;
        }
        return accountObj;
    } 
    
    public static ContentVersion createContentVersion(){
        ContentVersion contentVersionObj = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersionObj;
        
        return contentVersionObj;
    }
    
    public static ContentDocumentLink createContentDocument(Id parentId){
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = parentId;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        return cdl;
    }
    
    public static ReceivedDocument createReceivedDocument(){
        ReceivedDocument recDocObj = new ReceivedDocument();
        recDocObj.Name='test Doc';
        recDocObj.Status='Approved';
        Insert recDocObj;
        return recDocObj;
    }
    
    public static DocumentChecklistItem createDocumentChecklistItem(Id recDocId,Id programId){
        DocumentChecklistItem docCheckObj = new DocumentChecklistItem();
        docCheckObj.ReceivedDocumentId = recDocId;
        docCheckObj.ParentRecordId = programId;
        docCheckObj.Name = 'Test';
        Insert docCheckObj;
        return docCheckObj;
    }
    
}