@isTest
public class SYN_SOXAutomatedTaskUtilityTest {

    public static testMethod void SOXAutomatedTask() {
        US_WSREMS__REMS_Program__c remobj = new US_WSREMS__REMS_Program__c();
        remobj.Name ='Sodium Oxybate REMS';
        remobj.REMS_Project_Code__c = 'BT6825';
        remobj.US_WSREMS__Status__c ='Active';
        insert remobj; 
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType ='Account' and Name ='pharmacy'].Id;
        Account actobj = new Account();
        actobj.Name='test';  
        actobj.phone = '8888888888';
        actobj.RecordTypeId =strRecordTypeId;
        actobj.US_WSREMS__REMS_Program__c =remobj.id;
        insert actobj;
        
        contact con = new contact();
        con.lastName='GTest contact';
        insert con;
        
        id certificationRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Certification').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = remobj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = actobj.Id;
        serviceObj.RecordTypeId = certificationRecordTypeId;
        insert serviceObj;
        
        Case caseObj=new Case();
        //  caseObj.RecordTypeId=recordTypeIdcase;
        caseObj.US_WSREMS__Participant__c=actobj.Id;
        caseObj.US_WSREMS__REMS_Program__c=actobj.US_WSREMS__REMS_Program__c;
        caseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.inContact_Contact_ID__c=con.Id;
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS-SYN_Patient_Person_Account';
        insert caseObj;
         
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        
        QueueSobject mappingObject = new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Task');		// queue object
        System.runAs(new User(Id = UserInfo.getUserId()))		// Running as current User
        {insert mappingObject;}
        
        id bHoursId=Id.valueof(SYN_CommonUtility.getBusinessHoursId(System.Label.SOXBusinessHoursName));		// contains businessHoursId
        
        Task t=new Task();
        t.Type = 'Call';
        t.Subject = 'Obtain Missing Information';
        t.Program_Name__c = caseObj.US_WSREMS__REMS_Program__c;
        t.Status='Draft';
        t.ActivityDate = System.today();
        t.OwnerId = testGroup.Id;
        t.WhatId = caseObj.US_WSREMS__REMS_Service_Summary__c;
        Insert t;
       
        SYN_SOXAutomatedTaskUtility SAT = new SYN_SOXAutomatedTaskUtility();
        
       // SYN_SOXAutomatedTaskUtility.createFollowupTask(caseObj, mappingObject.id, strRecordTypeId, bHoursId);
        Test.startTest();
       // SYN_SOXAutomatedTaskUtility SAT = new SYN_SOXAutomatedTaskUtility();
        
        SYN_SOXAutomatedTaskUtility.createFollowupTask(caseObj, mappingObject.id, strRecordTypeId, bHoursId);
        Test.stopTest();
    }
    
    public static testMethod void DiligenceTask() {
        US_WSREMS__REMS_Program__c remobj = new US_WSREMS__REMS_Program__c();
        remobj.Name ='Sodium Oxybate REMS';
        remobj.REMS_Project_Code__c = 'BT6825';
        remobj.US_WSREMS__Status__c ='Active';
        insert remobj; 
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType ='Account' and Name ='pharmacy'].Id;
        Account actobj = new Account();
        actobj.Name='test';  
        actobj.phone = '8888888888';
        actobj.RecordTypeId =strRecordTypeId;
        actobj.US_WSREMS__REMS_Program__c =remobj.id;
        insert actobj;
        
        contact con = new contact();
        con.lastName='GTest contact';
        insert con;
        
        id certificationRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Certification').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = remobj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = actobj.Id;
        serviceObj.RecordTypeId = certificationRecordTypeId;
        insert serviceObj;
        
        Case caseObj=new Case();
        //  caseObj.RecordTypeId=recordTypeIdcase;
        caseObj.US_WSREMS__Participant__c=actobj.Id;
        caseObj.US_WSREMS__REMS_Program__c=actobj.US_WSREMS__REMS_Program__c;
        caseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.inContact_Contact_ID__c=con.Id;
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS-SYN_Patient_Person_Account';
        insert caseObj;
        
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        
        QueueSobject mappingObject = new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Task');		// queue object
        System.runAs(new User(Id = UserInfo.getUserId()))		// Running as current User
        {insert mappingObject;}
        
        id bHoursId=Id.valueof(SYN_CommonUtility.getBusinessHoursId(System.Label.SOXBusinessHoursName));		// contains businessHoursId
        
        Task t=new Task();
        t.Type = 'Call';
        t.Subject = 'Obtain Missing Information';
        t.Program_Name__c = caseObj.US_WSREMS__REMS_Program__c;
        t.Status='Draft';
        t.ActivityDate = System.today();
        t.OwnerId = testGroup.Id;
        t.WhatId = caseObj.US_WSREMS__REMS_Service_Summary__c;
        Insert t;
        
        SYN_SOXAutomatedTaskUtility SAT = new SYN_SOXAutomatedTaskUtility();
         
       // SYN_SOXAutomatedTaskUtility.createDueDiligenceTask(caseObj, mappingObject.id, strRecordTypeId, bHoursId);
        Test.startTest();
        //SYN_SOXAutomatedTaskUtility SAT = new SYN_SOXAutomatedTaskUtility();
         
        SYN_SOXAutomatedTaskUtility.createDueDiligenceTask(caseObj, mappingObject.id, strRecordTypeId, bHoursId);
        Test.stopTest();
    }
    
    public static testMethod void testSubtractDays() {
        Datetime startDate = Datetime.newInstance(2023, 4, 12, 12, 0, 0);
        Integer daysToSubtract = 5;
        id bHoursId=Id.valueof(SYN_CommonUtility.getBusinessHoursId(System.Label.SOXBusinessHoursName));
        SYN_SOXAutomatedTaskUtility SYN_SOXAutoTask = new SYN_SOXAutomatedTaskUtility();
        Datetime result = SYN_SOXAutoTask.SubtractDays(startDate,1,System.Label.SOXBusinessHoursName).date();   
    }
    public static testMethod void testGetCurrentDate() {
        // Set up test data
        Map<String, Time> soxStartHours = new Map<String, Time>();
        soxStartHours.put('Mon', Time.newInstance(9, 0, 0, 0));
        soxStartHours.put('Tue', Time.newInstance(9, 0, 0, 0));
        soxStartHours.put('Wed', Time.newInstance(9, 0, 0, 0));
        soxStartHours.put('Thu', Time.newInstance(9, 0, 0, 0));
        soxStartHours.put('Fri', Time.newInstance(9, 0, 0, 0));
        soxStartHours.put('Sat', Time.newInstance(0, 0, 0, 0));
        soxStartHours.put('Sun', Time.newInstance(0, 0, 0, 0));
        
        // Call the method being tested
        SYN_SOXAutomatedTaskUtility SYN_SOXAutoTask = new SYN_SOXAutomatedTaskUtility();
        Datetime result = SYN_SOXAutoTask.getCurrentDate(soxStartHours);
        
    }
}