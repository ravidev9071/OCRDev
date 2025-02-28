/**
* @File Name          : SYN_DocCheckListItemTriggerHandler.cls
* @Description        : Trigger handler for DocumentChecklistItem updates.
*                       This handler is associated with the SYN_DocumentCheckListItemTrigger trigger.
* @Trigger            : SYN_DocumentCheckListItemTrigger
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 2.0    11/17/2023        Dnyaneshwar Gothakade (Wilco)     handleBeforeUpdate.UpdateSecondReviewer: 
*                                                               Updates the Second Reviewer-related fields for DocumentChecklistItem records 
*                                                               with the program name 'Clozapine REMS'.
* 2.0    11/17/2023        Dnyaneshwar Gothakade (Wilco)     handleBeforeUpdate.calculateTotalSLA: 
*                                                               SLA is calculated based on the business hours 
*                                                               between Second_Reviewer_Assigned_Date_and_Time__c 
*                                                               and Second_Review_Complete_Date_and_Time__c.
* 2.0    11/17/2023        Dnyaneshwar Gothakade (Wilco)     handleAfterUpdate.createTaskOnSecondaryReview: 
*                                                               Creates a task for Second Review Feedback and is assigned 
*                                                               to the first record owner, set to be due on the next business date.
* 3.0    11/23/2023        Dnyaneshwar Gothakade (Wilco)     handleBeforeInsert.beforeInsertHandler: Line no : 46-56
*                                                               before inserting records of the DocumentChecklistItem object. It specifically checks and enforces certain
*                                                               conditions related to the Second Reviewer based on the CPMG program name.
*/


public class SYN_DocCheckListItemTriggerHandler {
    
    Private static final string ReviewStatus = 'Complete - Action Required';
    Private static final string ReviewStatusNIF = 'Complete - No Issues Found';
    Private static final string CPMGProgramName = 'Clozapine REMS';
    
    
    public static void beforeInsertHandler(List<DocumentCheckListItem> newDocCheckItemList){
        
        Set<Id> receivedDocumentIdSet = new Set<Id>();
        List<DocumentCheckListItem> docItemList = new List<DocumentCheckListItem>();
        for(DocumentCheckListItem docRec: newDocCheckItemList){
            
            if(!String.isBlank(docRec.Status) && docRec.ReceivedDocumentId != NULL){
                
                docRec.Last_Status_Change__c = System.Now();
                receivedDocumentIdSet.add(docRec.ReceivedDocumentId);
                docItemList.add(docRec);
            }
            
            if (docRec.Program_Name__c == CPMGProgramName) {
                
                // Check if the Second_Reviewer__c is not blank and is not equal to the Owner
                if (docRec.Second_Reviewer__c != null && docRec.OwnerId == docRec.Second_Reviewer__c) {
                    docRec.Second_Reviewer__c.addError('Second Reviewer cannot be the same as the Owner');
                }
                
                // Check if Second_Reviewer__c is not null and Second_Reviewer_Assigned_Date_and_Time__c is null
                if (docRec.Second_Reviewer__c != null && docRec.Second_Reviewer_Assigned_Date_and_Time__c == null) {
                    docRec.Second_Reviewer_Assigned_Date_and_Time__c = System.now();
                }
             }
          }   
        
        if(!docItemList.isEmpty()){
            
            calculateReviewProcessingTime(receivedDocumentIdSet, docItemList);
        }
    }
    
    public static void beforeUpdateHandler(Map<Id, DocumentCheckListItem> newMap, Map<Id, DocumentCheckListItem> oldMap){
        
        Set<Id> receivedDocumentIdSet = new Set<Id>();
        List<DocumentCheckListItem> docItemList = new List<DocumentCheckListItem>();
        List<Id> clozapineUser = SYN_CommonUtility.getUserFromPG(system.label.PublicGroupClozapineRW );
        String errorMsg = System.label.Clozapine_Owner_Error_Msg; 
        
        for(DocumentCheckListItem docRec: newMap.values()){
            
            DocumentCheckListItem oldRec = oldMap.get(docRec.Id);
            
            if(oldRec.OwnerId !=docRec.OwnerId ){
                if (!clozapineUser.contains(docRec.OwnerId)){
                    docRec.adderror(errorMsg);
                }
            }
            if(((!String.isBlank(docRec.Status) && (oldRec.Status != docRec.Status)) || ( !String.isBlank(docRec.Status) && (oldRec.Last_Status_Change__c != docRec.Last_Status_Change__c))) && docRec.ReceivedDocumentId != NULL){
                
                if((oldRec.Status != docRec.Status)){
                    if(docRec.Status=='Document_Uploaded' ){
                        docRec.Review_Completion_Date__c=System.Now();
                    }
                    docRec.Last_Status_Change__c = System.Now();
                }
                receivedDocumentIdSet.add(docRec.ReceivedDocumentId);
                docItemList.add(docRec);
            }
        }   
        
        if(!docItemList.isEmpty()){
            
            calculateReviewProcessingTime(receivedDocumentIdSet, docItemList);
        }
    }
    
    public static void calculateReviewProcessingTime(Set<Id> receivedDocIdSet, List<DocumentCheckListItem> docItemRecList){
        
        String businessHoursId = SYN_CommonUtility.getBusinessHoursId(System.Label.ClozapineBusinessHoursName);
        
        if(String.isNotBlank(businessHoursId)){
            
            Map<Id, ReceivedDocument> receivedDocumentMap = new Map<Id, ReceivedDocument>(
                [SELECT Id, CreatedDate FROM ReceivedDocument WHERE Id IN: receivedDocIdSet]
            ); 
            
            for(DocumentCheckListItem dciRec : docItemRecList){
                
                Map<String, Long> timeEleMap = SYN_CommonUtility.calculateBusinessHours(businessHoursId, receivedDocumentMap.get(dciRec.ReceivedDocumentId).CreatedDate, dciRec.Last_Status_Change__c);
                String totalTime = String.valueOf(timeEleMap.get('hours')) + ' hrs ' +  String.valueOf(timeEleMap.get('mins')) +' mins'; 
                dciRec.Review_Processing_Time_in_Mins__c=(Integer.valueOf(timeEleMap.get('hours')*60) +Integer.valueof(timeEleMap.get('mins')));
                dciRec.Review_Processing_Time__c = totalTime;
            }
        }
    }
    
    public static void updateShareRecord(Map<Id, DocumentCheckListItem> newMap, Map<Id, DocumentCheckListItem> oldMap){
        
        List<sObject> sObjectList = new List<sObject>();
        for(DocumentCheckListItem rdRec : newMap.values()){
            
            DocumentCheckListItem rdRecOldMap = oldMap.get(rdRec.Id);
            if(rdRecOldMap.OwnerId != rdRec.OwnerId){
                
                sObjectList.add(rdRec);
            }
            
        }
        
        if(!sObjectList.isEmpty()){
            
            SYN_SharingUtility.createShareRecordsList(sObjectList, 'DocumentChecklistItemShare','DocumentCheckListItem');
        }
    }
    public static void afterInsertHandler(Map<Id, DocumentCheckListItem> newDocCheckMap, Map<Id, DocumentCheckListItem> oldDocCheckMap){
        afterUpdateHandler(newDocCheckMap,oldDocCheckMap);
    } 
    
    public static void afterUpdateHandler(Map<Id, DocumentCheckListItem> newDocCheckMap, Map<Id, DocumentCheckListItem> oldDocCheckMap){
        
        Id MaciProgramId = SYN_CommonUtility.MACIprogramId();
        Set<Id> receivedDocumentIdSet = new Set<Id>();
        
        for(DocumentCheckListItem docRec: newDocCheckMap.values()){
            if( docRec.ParentRecordId == MaciProgramId && docRec.ReceivedDocumentId != NULL && (oldDocCheckMap == null || (oldDocCheckMap!= null && docRec.ReceivedDocumentId != oldDocCheckMap.get(docRec.id).ReceivedDocumentId) ) ){
                
                receivedDocumentIdSet.add(docRec.ReceivedDocumentId); 
            }
        }
        
        if (!receivedDocumentIdSet.IsEmpty()){
            setRDocumentOwner(receivedDocumentIdSet);
        }
    }
    
    public static void setRDocumentOwner(set<Id>receivedDocumentIdSet ){
        List<ReceivedDocument> RDocumentlst = new List<ReceivedDocument>();
        for( ReceivedDocument  RDocument : [select id , OwnerId, Processing_Status__c from ReceivedDocument  where Id In: receivedDocumentIdSet ]){
            if (!String.valueOf(RDocument.OwnerId).startsWith('005')){
                RDocument.OwnerId = UserInfo.getUserId();
                RDocument.Processing_Status__c = 'Assigned';     
                RDocumentlst.add(RDocument);
            }
        }
        
        update RDocumentlst;
    }
    
    public static void UpdateSecondReviewer(List<DocumentChecklistItem> records) {
        for (DocumentChecklistItem record : records) {
            if (record.Program_Name__c == CPMGProgramName) {
                
                // Check if the Second_Reviewer__c is not blank and is not equal to the Owner
                if (record.Second_Reviewer__c != null && record.OwnerId == record.Second_Reviewer__c) {
                    record.Second_Reviewer__c.addError('Second Reviewer cannot be the same as the Owner');
                }
                
                // Check if Second_Reviewer__c is not null and Second_Reviewer_Assigned_Date_and_Time__c is null
                if (record.Second_Reviewer__c != null && record.Second_Reviewer_Assigned_Date_and_Time__c == null) {
                    record.Second_Reviewer_Assigned_Date_and_Time__c = System.now();
                }
                
                // Check if Second_Review_Status__c is 'Complete - No Issues Found OR Complete - Action Required' and Second_Review_Complete_Date_and_Time__c is null
                if ((record.Second_Review_Status__c == ReviewStatusNIF || record.Second_Review_Status__c == ReviewStatus) && record.Second_Review_Complete_Date_and_Time__c == null) {
                    record.Second_Review_Complete_Date_and_Time__c = System.now();
                }
            }
        }
    }
    
    public static void calculateTotalSLA(List<DocumentCheckListItem> Docreclist) {
        
        String businessHoursId = SYN_CommonUtility.getBusinessHoursId(System.Label.ClozapineBusinessHoursName);
        
        if (String.isNotBlank(businessHoursId)) {
            for (DocumentCheckListItem doc1 : Docreclist) {
                if (doc1.Second_Reviewer_Assigned_Date_and_Time__c != null && doc1.Second_Review_Complete_Date_and_Time__c != null && doc1.Program_Name__c == CPMGProgramName) {
                    // Calculate the business hours difference between Complete and Assign date and time.
                    Map<String, Long> timeEleMap2 = SYN_CommonUtility.calculateBusinessHours(businessHoursId, doc1.Second_Reviewer_Assigned_Date_and_Time__c, doc1.Second_Review_Complete_Date_and_Time__c);
                    if (timeEleMap2.get('hours') > 0) {
                        doc1.Second_Review_Complete_SLA__c = String.valueOf(timeEleMap2.get('hours')) + ' hrs ' +  String.valueOf(timeEleMap2.get('mins')) +' mins'; 
                    } else {
                        doc1.Second_Review_Complete_SLA__c = String.valueOf(timeEleMap2.get('mins')) +' mins';
                    } 
                }
            }
        }
    }
    
    public static void createTaskOnSecondaryReview(List<DocumentChecklistItem> docCheckListData,Map<Id, DocumentCheckListItem> oldDocCheckMap) {
        List<Task> createTaskList = New List<Task>();
        Date dueDate = SYN_CaseTriggerHelper.getNextBusinessDate(DateTime.Now(),System.Label.ClozapineBusinessHoursName);
        for (DocumentChecklistItem dc : docCheckListData) {
            if(dc.Second_Review_Status__c == ReviewStatus && dc.Second_Reviewer__c != null && oldDocCheckMap != null && 
               oldDocCheckMap.get(dc.id).Second_Review_Status__c != ReviewStatus && dc.Program_Name__c == CPMGProgramName){
                   
                   Task t = New Task(OwnerId = dc.OwnerId,
                                     Subject = 'Second Review Summary',
                                     ActivityDate = dueDate,
                                     WhatId = dc.Id,
                                     Status = 'Not Started',
                                     REMS_Program__c = dc.Program_Name__c,
                                     Task_Type__c = 'Second Review',
                                     US_WSREMS__Program_Name__c = dc.Program_Name__c
                                    );
                   createTaskList.add(t);
               }
        }
        
        if(!createTaskList.isEmpty()){
            try{
                insert createTaskList;
            }catch(exception e){
                
            }
        }
    }
    
    
    
    
    
}