/**
* @File Name          : SYN_TaskTriggerHandlerTest.cls
* @Description        : Test class is for Task updates.
*                       This Test class is associated with the SYN_TaskTriggerHandler.
* @Trigger            : SYN_TaskTrigger.
* @Trigger Handler    : SYN_TaskTriggerHandler.
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 2.0       16/01/2024      Dnyaneshwar Gothakade (Wilco)    handleAfterUpdate : Line no :- 37-94
                                                               This method is to verify that 'Second_Review__c' field on DocumentCheckListItem is 'Checked' or 'Unchecked'
*                                                              based on the status of the Task related to Clozapine REMS program.
*/

@isTest
public class SYN_TaskTriggerHandlerTest {

    @IsTest
    Public static void testHandleAfterUpdate() {

        List<DocumentChecklistItem> docCheckListData = new List<DocumentChecklistItem>();
        List<Task> taskList = New List<Task>();
        Test.startTest();
        DocumentChecklistItem item1 = SYN_TestDataFactory.createTestUserCPMG();
        String groupname = System.Label.PublicGroupClozapineRW;
        Date expectedDueDate = SYN_CaseTriggerHelper.getNextBusinessDate(DateTime.Now(), System.Label.ClozapineBusinessHoursName);
        List<Group> publicGroupId = [SELECT Id FROM Group WHERE DeveloperName = :groupname AND Type = 'Regular' LIMIT 1];
        List<GroupMember> gmlist = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroupId[0].Id];
        item1.OwnerId = gmlist[0].UserOrGroupId;
        docCheckListData.add(item1);

        // Create a Task
        for(DocumentChecklistItem dc : docCheckListData){
        Task task = new Task();
        task.US_WSREMS__Program_Name__c = 'Clozapine REMS';
        task.Status = 'In Progress';
        task.WhatId = dc.Id;
        taskList.add(task);
        }
        insert taskList;

        // Change the Task status to 'Completed'
        for (Task tsk1 : taskList) {
            tsk1.Status = 'Completed';
        }

        update taskList;

        // Create another set of tasks and update their status to 'In Progress'
        List<Task> taskLst = new List<Task>();
        for(DocumentChecklistItem dc : docCheckListData){
            Task Tsk = new Task();
            Tsk.US_WSREMS__Program_Name__c = 'Clozapine REMS';
            Tsk.Status = 'Completed';
            Tsk.WhatId = dc.Id;
            taskLst.add(Tsk);
        }
        insert taskLst;

        // Change the Task status to 'In Progress'
        for (Task tsk2 : taskLst) {
            tsk2.Status = 'In Progress';

        }

        update taskLst;

        Test.stopTest();

        // Retrieve the updated Document Checklist Item
        DocumentChecklistItem updatedDocChecklistItem = [SELECT Id, Second_Review__c FROM DocumentChecklistItem WHERE Id = :docCheckListData[0].Id LIMIT 1];

        // Verify that the Second_Review__c field is updated to false
        System.assertEquals(false, updatedDocChecklistItem.Second_Review__c, 'Checkbox should be Unchecked');
       }

}