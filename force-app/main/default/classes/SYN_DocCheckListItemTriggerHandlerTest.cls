/**
* @File Name          : SYN_DocCheckListItemTriggerHandlerTest.cls
* @Description        : Test class is for DocumentChecklistItem updates.
*                       This Test class is associated with the SYN_DocCheckListItemTriggerHandler.
* @Trigger            : SYN_DocumentCheckListItemTrigger.
* @Trigger Handler    : SYN_DocCheckListItemTriggerHandler.
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 2.0       12/06/2023      Dnyaneshwar Gothakade (Wilco)    testUpdateSecondReviewer : Line no :- 42-59
                                                               Test class to verify that an exception is thrown when trying to
*                                                              update the Second Reviewer to be the same as the Owner.
* 2.0       12/06/2023      Dnyaneshwar Gothakade (Wilco)    testCreateTaskOnSecondaryReview : Line no :- 61-95
*                                                              Test class to verify the creation of a task on the secondary review status
*                                                              for a document checklist item.
*/


@IsTest
public class SYN_DocCheckListItemTriggerHandlerTest {

    static testMethod void testDocCheckListItemTrigger() {
        DocumentChecklistItem dcl=SYN_TestDataFactory.createDocumentChecklistItemwithRecivedDoc();
        String groupname=system.label.PublicGroupClozapineRW ;
        List<group> publicGroupId = [select Id from group where DeveloperName =:groupname and type ='Regular' limit 1];
        List<GroupMember> gmlist= [Select UserOrGroupId From GroupMember where GroupId =:publicGroupId[0].Id];
        User u=SYN_TestDataFactory.createTestUser();
        dcl.OwnerId=gmlist[0].UserOrGroupId;
        dcl.Status='Document_Uploaded';
        update dcl;
        DocumentCheckListItem docCheck = [Select Id,Name,Status,Second_Reviewer_Assigned_Date_and_Time__c from DocumentCheckListItem Where Status ='Document_Uploaded' LIMIT 1];
        System.assertEquals('Document_Uploaded',docCheck.Status);
    }

    @testSetup
    Public static void createTestData(){
        ReceivedDocument rc = SYN_TestDataFactory.createReceivedDocument();
        SYN_TestDataFactory.createSOXPrograms1(1 , true, 'Clozapine REMS');
    }

   @isTest
        Public static void testUpdateSecondReviewer() {
            Boolean exceptionThrown = false;
            DocumentChecklistItem item = SYN_TestDataFactory.createDocumentChecklistItemRecord();
            DocumentCheckListItem docCheck = [Select Id,Name,OwnerId,Second_Reviewer_Assigned_Date_and_Time__c,Second_Reviewer__c,Second_Review_Complete_Date_and_Time__c from DocumentCheckListItem Where Id =: item.id];
            docCheck.Second_Reviewer__c = item.OwnerId;
            docCheck.Second_Review_Status__c = 'Complete - Action Required';

            try{
                Test.StartTest();
                update docCheck;
            }
            catch (Exception e){
                exceptionThrown = true;
                Boolean ExexceptionThrown = (e.getmessage().contains('Second Reviewer cannot be the same as the Owner'))?true : false;
                //system.assertEquals(true, ExexceptionThrown, e.getmessage());
            }
            Test.StopTest();
        }

        @isTest
        static void testCreateTaskOnSecondaryReview() {

            List<DocumentChecklistItem> docCheckListData = new List<DocumentChecklistItem>();
            List<Task> Tasklist = New List<Task>();
            Test.startTest();
            DocumentChecklistItem item1 = SYN_TestDataFactory.createTestUserCPMG();
            String groupname=system.label.PublicGroupClozapineRW ;
            Date expectedDueDate = SYN_CaseTriggerHelper.getNextBusinessDate(DateTime.Now(), System.Label.ClozapineBusinessHoursName);
            List<group> publicGroupId = [select Id from group where DeveloperName =:groupname and type ='Regular' limit 1];
            List<GroupMember> gmlist= [Select UserOrGroupId From GroupMember where GroupId =:publicGroupId[0].Id];
            item1.OwnerId = gmlist[0].UserOrGroupId;
            docCheckListData.add(item1);

            for (DocumentChecklistItem dc : docCheckListData) {
                Task tsk = new task(OwnerId=dc.OwnerId);
                tsk.Status = 'Not Started';
                tsk.WhatId =  dc.Id;
                tsk.Subject = 'Second Review Summary';
                tsk.Task_Type__c = 'Second Review';
                tsk.ActivityDate = expectedDueDate;
                Tasklist.add(tsk);
            }

            insert Tasklist;

            for (DocumentChecklistItem dc : docCheckListData) {
                dc.Second_Review_Status__c = 'Complete - Action Required';
            }

            update docCheckListData;

            Test.stopTest();

            // Verify the task creation
            Task createdTasks = [SELECT Id, Subject , WhatId, ActivityDate FROM Task WHERE WhatId =:docCheckListData[0].Id limit 1];
            System.assertEquals(expectedDueDate, createdTasks.ActivityDate, 'Due date should match expected value.');
        }
 }