@isTest(isParallel = true)
private class AVEEDAutomationCommunicationUtilityTests {
    @testSetup
    public static void dataSetup(){
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'AVEED REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;

        Account participantAccount = SYN_TestDataUtility.createAccount(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId(), 'test', 'prescriber');
        participantAccount.US_WSREMS__Status__c = 'Pending';
        participantAccount.Fax = '734727777';
        participantAccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        update participantAccount;

        Account hcsAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId());
        hcsAccount.US_WSREMS__Status__c = 'Pending';
        update hcsAccount;

        US_WSREMS__Affiliation__c affiliation = new US_WSREMS__Affiliation__c();
        affiliation.US_WSREMS__Health_Care_Setting__c = hcsAccount.Id;
        affiliation.US_WSREMS__Health_Care_Setting__r = hcsAccount;
        affiliation.US_WSREMS__REMSProgram__c = programObj.Id;
        affiliation.US_WSREMS__REMSProgram__r = programObj;
        affiliation.RecordTypeId = Schema.sObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Authorized_Representative_Affiliation').getRecordTypeId();
        affiliation.US_WSREMS__Authorized_Representative__r = participantAccount;
        affiliation.US_WSREMS__Authorized_Representative__c = participantAccount.Id;
        insert affiliation;

        List<Case> caseList = new List<Case>();

        case KAcaseRec = new case();
        KAcaseRec.Program_Record_Type_Control__c = 'AVEED REMS-Knowledge_Assessment';
        KAcaseRec.US_WSREMS__REMS_Program__c = programObj.Id;
        KAcaseRec.US_WSREMS__REMS_Program__r = programObj;
        KAcaseRec.Status = 'Draft';
        KAcaseRec.US_WSREMS__First_Name__c = 'test KA';
        KAcaseRec.US_WSREMS__Last_Name__c = 'test';
        KAcaseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        KAcaseRec.US_WSREMS__Program_Picklist__c = programObj.Name;
        KAcaseRec.US_WSREMS__Participant__r = participantAccount;
        KAcaseRec.US_WSREMS__Participant__c = participantAccount.Id;
        KAcaseRec.US_WSREMS__Healthcare_Setting__r = hcsAccount;
        KAcaseRec.US_WSREMS__Healthcare_Setting__c = hcsAccount.Id;
        KAcaseRec.US_WSREMS__Email__c = 'test@test.com';
        KAcaseRec.US_WSREMS__Fax__c = '7653216217';
        KAcaseRec.US_WSREMS__Channel__c = 'Fax';
        caseList.add(KAcaseRec);

        case caseRec = new case();
        caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Prescriber_enrollment';
        caseRec.US_WSREMS__REMS_Program__c = programObj.Id;
        caseRec.US_WSREMS__REMS_Program__r = programObj;
        caseRec.Status = 'Draft';
        caseRec.US_WSREMS__First_Name__c = 'test';
        caseRec.US_WSREMS__Last_Name__c = 'test';
        caseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        caseRec.US_WSREMS__Program_Picklist__c = programObj.Name;
        caseRec.US_WSREMS__Participant__r = participantAccount;
        caseRec.US_WSREMS__Participant__c = participantAccount.Id;
        caseRec.US_WSREMS__Healthcare_Setting__r = hcsAccount;
        caseRec.US_WSREMS__Healthcare_Setting__c = hcsAccount.Id;
        caseRec.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        caseRec.US_WSREMS__Email__c = 'test@test.com';
        caseRec.US_WSREMS__Fax__c = '7653216217';
        caseList.add(caseRec);
        
        case pfcCaseRec = new case();
        pfcCaseRec.Program_Record_Type_Control__c = 'AVEED REMS-Prescriber_enrollment';
        pfcCaseRec.US_WSREMS__REMS_Program__c = programObj.Id;
        pfcCaseRec.US_WSREMS__REMS_Program__r = programObj;
        pfcCaseRec.Status = 'Draft';
        pfcCaseRec.US_WSREMS__First_Name__c = 'test pfc';
        pfcCaseRec.US_WSREMS__Last_Name__c = 'test';
        pfcCaseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        pfcCaseRec.US_WSREMS__Program_Picklist__c = programObj.Name;
        pfcCaseRec.US_WSREMS__Participant__r = participantAccount;
        pfcCaseRec.US_WSREMS__Participant__c = participantAccount.Id;
        pfcCaseRec.US_WSREMS__Healthcare_Setting__r = hcsAccount;
        pfcCaseRec.US_WSREMS__Healthcare_Setting__c = hcsAccount.Id;
        pfcCaseRec.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        pfcCaseRec.US_WSREMS__Fax__c = '7653216217';
        pfcCaseRec.US_WSREMS__Email__c = '';
        caseList.add(pfcCaseRec);

        case pfcHcsCaseRec = new case();
        pfcHcsCaseRec.Program_Record_Type_Control__c = 'AVEED REMS-HCS_Enrollment';
        pfcHcsCaseRec.US_WSREMS__REMS_Program__c = programObj.Id;
        pfcHcsCaseRec.US_WSREMS__REMS_Program__r = programObj;
        pfcHcsCaseRec.Status = 'Draft';
        pfcHcsCaseRec.US_WSREMS__First_Name__c = 'test pfc';
        pfcHcsCaseRec.US_WSREMS__Last_Name__c = 'test';
        pfcHcsCaseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        pfcHcsCaseRec.US_WSREMS__Program_Picklist__c = programObj.Name;
        pfcHcsCaseRec.US_WSREMS__Participant__r = participantAccount;
        pfcHcsCaseRec.US_WSREMS__Participant__c = participantAccount.Id;
        pfcHcsCaseRec.US_WSREMS__Healthcare_Setting__r = hcsAccount;
        pfcHcsCaseRec.US_WSREMS__Healthcare_Setting__c = hcsAccount.Id;
        pfcHcsCaseRec.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        pfcHcsCaseRec.US_WSREMS__Email__c = 'testone@test.com';
        pfcHcsCaseRec.US_WSREMS__Participant_Fax__c = '7653216217';
        caseList.add(pfcHcsCaseRec);

        case pfcHcsReEnrollCaseRec = new case();
        pfcHcsReEnrollCaseRec.Program_Record_Type_Control__c = 'AVEED REMS-HCS_Reenrollment';
        pfcHcsReEnrollCaseRec.US_WSREMS__REMS_Program__c = programObj.Id;
        pfcHcsReEnrollCaseRec.US_WSREMS__REMS_Program__r = programObj;
        pfcHcsReEnrollCaseRec.Status = 'Draft';
        pfcHcsReEnrollCaseRec.US_WSREMS__First_Name__c = 'test pfc';
        pfcHcsReEnrollCaseRec.US_WSREMS__Last_Name__c = 'test';
        pfcHcsReEnrollCaseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Reenrollment').getRecordTypeId();
        pfcHcsReEnrollCaseRec.US_WSREMS__Program_Picklist__c = programObj.Name;
        pfcHcsReEnrollCaseRec.US_WSREMS__Participant__r = participantAccount;
        pfcHcsReEnrollCaseRec.US_WSREMS__Participant__c = participantAccount.Id;
        pfcHcsReEnrollCaseRec.US_WSREMS__Healthcare_Setting__r = hcsAccount;
        pfcHcsReEnrollCaseRec.US_WSREMS__Healthcare_Setting__c = hcsAccount.Id;
        pfcHcsReEnrollCaseRec.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        pfcHcsReEnrollCaseRec.US_WSREMS__Email__c = 'testone@test.com';
        pfcHcsReEnrollCaseRec.US_WSREMS__Participant_Fax__c = '7653216217';
        caseList.add(pfcHcsReEnrollCaseRec);

        case hcsCaseRec = new case();
        hcsCaseRec.Program_Record_Type_Control__c = 'AVEED REMS-HCS_Enrollment';
        hcsCaseRec.US_WSREMS__REMS_Program__c = programObj.Id;
        hcsCaseRec.US_WSREMS__REMS_Program__r = programObj;
        hcsCaseRec.Status = 'Draft';
        hcsCaseRec.US_WSREMS__First_Name__c = 'test';
        hcsCaseRec.US_WSREMS__Last_Name__c = 'test';
        hcsCaseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        hcsCaseRec.US_WSREMS__Program_Picklist__c = programObj.Name;
        hcsCaseRec.US_WSREMS__Participant__r = hcsAccount;
        hcsCaseRec.US_WSREMS__Participant__c = hcsAccount.Id;
        hcsCaseRec.US_WSREMS__Prescriber__r = participantAccount;
        hcsCaseRec.US_WSREMS__Prescriber__c = participantAccount.Id;
        hcsCaseRec.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        hcsCaseRec.US_WSREMS__Email_ar__c = 'test@test.com';
        hcsCaseRec.US_WSREMS__Email__c = 'testone@test.com';
        hcsCaseRec.US_WSREMS__Participant_Fax__c = '7653216217';
        caseList.add(hcsCaseRec);
        
        case nonComplainceRec = new case();
        nonComplainceRec.Program_Record_Type_Control__c = 'AVEED REMS-Non_Compliance';
        nonComplainceRec.US_WSREMS__REMS_Program__c = programObj.Id;
        nonComplainceRec.US_WSREMS__REMS_Program__r = programObj;
        nonComplainceRec.Status = 'Draft';
        nonComplainceRec.US_WSREMS__First_Name__c = 'test';
        nonComplainceRec.US_WSREMS__Last_Name__c = 'test';
        nonComplainceRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();
        nonComplainceRec.US_WSREMS__Program_Picklist__c = programObj.Name;
        nonComplainceRec.US_WSREMS__X1_Participant__r = participantAccount;
        nonComplainceRec.US_WSREMS__X1_Participant__c = participantAccount.Id;
        nonComplainceRec.US_WSREMS__Healthcare_Setting__r = hcsAccount;
        nonComplainceRec.US_WSREMS__Healthcare_Setting__c = hcsAccount.Id;
        caseList.add(nonComplainceRec);

        case nonComplainceRec1 = new case();
        nonComplainceRec1.Program_Record_Type_Control__c = 'AVEED REMS-Non_Compliance';
        nonComplainceRec1.US_WSREMS__REMS_Program__c = programObj.Id;
        nonComplainceRec1.US_WSREMS__REMS_Program__r = programObj;
        nonComplainceRec1.Status = 'Draft';
        nonComplainceRec1.US_WSREMS__First_Name__c = 'test';
        nonComplainceRec1.US_WSREMS__Last_Name__c = 'test';
        nonComplainceRec1.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();
        nonComplainceRec1.US_WSREMS__Program_Picklist__c = programObj.Name;
        nonComplainceRec1.US_WSREMS__X1_Participant__r = hcsAccount;
        nonComplainceRec1.US_WSREMS__X1_Participant__c = hcsAccount.Id;
        caseList.add(nonComplainceRec1);

        insert caseList;
    }
    @isTest
    private static void checkEmailOrFaxWhenEmailIsNullTest(){

        String Result;
        Test.startTest();
            Result = AVEEDAutomationCommunicationUtility.checkEmailOrFax('Email', null, '8726372777');
        Test.stopTest();

        system.assertEquals('sendfax', Result, 'result is Send Fax');
    }

    @isTest
    private static void checkEmailOrFaxwhenFaxIsNullTest(){

        String Result;
        Test.startTest();
            Result = AVEEDAutomationCommunicationUtility.checkEmailOrFax('Email', 'test@test.com', null);
        Test.stopTest();

        system.assertEquals('sendemail', Result, 'result is Send Email');
    }

    @isTest
    private static void checkEmailOrFaxWhenContactIsFaxTest(){

        String Result;
        Test.startTest();
            Result = AVEEDAutomationCommunicationUtility.checkEmailOrFax('Fax', 'test@test.com', null);
        Test.stopTest();

        system.assertEquals('sendemail', Result, 'result is Send Email');
    }

    @isTest
    private static void checkEmailOrFaxWhenContactIsFaxAndEmailNullTest(){

        String Result;
        Test.startTest();
            Result = AVEEDAutomationCommunicationUtility.checkEmailOrFax('Fax', null , '876427327');
        Test.stopTest();

        system.assertEquals('sendfax', Result, 'result is Send Fax');
    }

    @isTest
    private static void checkEmailOrFaxWhenContactIsNullTest(){

        String Result;
        Test.startTest();
            Result = AVEEDAutomationCommunicationUtility.checkEmailOrFax(null, 'test@test.com', '876427327');
        Test.stopTest();

        system.assertEquals('sendemail', Result, 'result is Send Email');
    }

    @isTest
    private static void createREMSCommunicationForHcpEnrollTest(){
        Case caseRecord = new Case();
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        caseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecord.RecordTypeId = prescriberEnrollCaseRecTypeId;

        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Test.startTest();
        communicationRecList = AVEEDAutomationCommunicationUtility.createREMSCommunicationForHCSorHcpEnroll(caseRecord);
        Test.stopTest();

        system.assert(communicationRecList != null, 'Outbound Communication is not null');
    }

    @isTest
    private static void createREMSCommunicationForHcsEnrollTest(){
        Case caseRecord = new Case();
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
        caseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecord.RecordTypeId = prescriberEnrollCaseRecTypeId;

        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Test.startTest();
        communicationRecList = AVEEDAutomationCommunicationUtility.createREMSCommunicationForHCSorHcpEnroll(caseRecord);
        Test.stopTest();

        system.assert(communicationRecList != null, 'Outbound Communication is not null');
    }

    @isTest
    private static void createREMSCommunicationForHcsReEnrollTest(){
        Case caseRecord = new Case();
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Reenrollment');
        caseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecord.RecordTypeId = prescriberEnrollCaseRecTypeId;

        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Test.startTest();
        communicationRecList = AVEEDAutomationCommunicationUtility.createREMSCommunicationForHCSorHcpEnroll(caseRecord);
        Test.stopTest();

        system.assert(communicationRecList != null, 'Outbound Communication is not null');
    }

    @isTest
    private static void sendCommunicationFromHCSCaseWhileUpdateTest(){
        Id HCSRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();

        Test.startTest();
            Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:HCSRecTypeId AND US_WSREMS__First_Name__c = 'test' LIMIT 1]);
            for(Case caseRec:oldCaseMap.values()){
                Case newCase = new Case();
                newCase.Id = caseRec.Id;
                newCase.status = 'Complete';
                newCaseMap.put(newCase.Id, newCase);
            }
            update newCaseMap.values();
            AVEEDAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(true,newCaseMap,oldCaseMap);
            Case caseRec = [SELECT Id,status FROM Case LIMIT 1];
            system.assertEquals('Draft', caseRec.status);
        Test.stopTest();
    }
    
     @isTest
    private static void sendCommunicationFromHCPCaseWhileUpdate(){
        Id prescriberRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();

        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:prescriberRecTypeId AND US_WSREMS__First_Name__c = 'test' LIMIT 1]);
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.status = 'Complete';
            newCase.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();
        
        AVEEDAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(true,newCaseMap,oldCaseMap);
        Case caseRec = [SELECT Id,status FROM Case LIMIT 1];
        system.assertEquals('Draft', caseRec.status);
        Test.stopTest();
    }
    
     @isTest
    private static void sendCommunicationFromNonComplainceCaseWhileUpdateOrInsert(){
        Id nonComplianceTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();

        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId =:nonComplianceTypeId LIMIT 1]);
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.status = 'Complete';
            newCase.US_WSREMS__Outcome__c = 'Suspected Non-compliance activity';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();

        AVEEDAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(true,newCaseMap,oldCaseMap);
        Case caseRec = [SELECT Id,status FROM Case LIMIT 1];
        system.assertEquals('Draft', caseRec.status);
        Test.stopTest();
    }
    
    @isTest
    private static void sendCommunicationFromCaseWhileInsert(){
        US_WSREMS__Program_Fields_Configuration__c pfc = new US_WSREMS__Program_Fields_Configuration__c();
        pfc.US_WSREMS__Soft_Required__c = true;
        pfc.US_WSREMS__Target_Object__c = 'Case';
        pfc.US_WSREMS__Target_Object_Field__c = 'US_WSREMS__Email__c';
        pfc.US_WSREMS__Target_Object_Record_Type__c = 'Prescriber_enrollment';
        pfc.US_WSREMS__Target_Object_Field_Label__c = 'Email';

        Id nonComplianceTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();

        Test.startTest();
            US_WSREMS__REMS_Program__c programObj = [Select Id,Name from US_WSREMS__REMS_Program__c limit 1];
            pfc.US_WSREMS__REMS_Program__c = programObj.Id;
            pfc.US_WSREMS__REMS_Program__r = programObj;
            insert pfc;

            Map<Id,case> newCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c,US_WSREMS__Email__c FROM Case WHERE RecordTypeId =:nonComplianceTypeId AND US_WSREMS__First_Name__c = 'test pfc' LIMIT 1]);
            
            AVEEDAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(false,newCaseMap,null);
            US_WSREMS__Program_Fields_Configuration__c pfcrec = [SELECT Id,US_WSREMS__Target_Object_Field__c FROM US_WSREMS__Program_Fields_Configuration__c LIMIT 1];
            system.assertEquals('US_WSREMS__Email__c', pfcrec.US_WSREMS__Target_Object_Field__c);
        Test.stopTest();
    }

    @isTest
    private static void sendFaxForKAResponsesTest(){
        Map<Id,US_WSREMS__Assessment_Submission__c> newKAMap = new Map<Id,US_WSREMS__Assessment_Submission__c>();
        US_WSREMS__REMS_Program__c programObj = [Select Id,Name from US_WSREMS__REMS_Program__c limit 1];
        Map<Id,US_WSREMS__Assessment_Submission__c> oldKAMap = new Map<Id,US_WSREMS__Assessment_Submission__c>();
        Case KAcaseRec = [SELECT Id,US_WSREMS__Participant__r.PersonEmail,US_WSREMS__Participant__c, US_WSREMS__Channel__c FROM Case WHERE US_WSREMS__First_Name__c = 'test KA' LIMIT 1];
      
        US_WSREMS__Assessment__c  assessment = new US_WSREMS__Assessment__c();
        assessment.US_WSREMS__REMS_Program__r = programObj;
        assessment.US_WSREMS__REMS_Program__c = programObj.Id;
        assessment.US_WSREMS__Participant_Type__c='Prescriber';
        assessment.US_WSREMS__Pass_Percentage__c=100;
        assessment.US_WSREMS__Show_Wrong_Answers_Only__c=true;
        assessment.name='Knowledge Assessment';
        insert assessment;

        Test.startTest();
            US_WSREMS__Assessment_Submission__c KA = new US_WSREMS__Assessment_Submission__c();
            KA.US_WSREMS__Case__r = KAcaseRec;
            KA.US_WSREMS__Case__c = KAcaseRec.Id;
            KA.US_WSREMS__Assessment_Result__c = 'Failed';
            KA.US_WSREMS__Total_Number_of_Attempts__c = 2;
            KA.US_WSREMS__Assessment__c= assessment.Id;
            insert KA;
            oldKAMap.put(KA.Id, KA);
            
            for(US_WSREMS__Assessment_Submission__c KARec:oldKAMap.values()){
                US_WSREMS__Assessment_Submission__c newKARec = new US_WSREMS__Assessment_Submission__c();
                newKARec.Id = KARec.Id;
                newKARec.US_WSREMS__Assessment_Result__c = 'Passed';
                newKAMap.put(newKARec.Id, newKARec);
            }
            update newKAMap.values();
            AVEEDAutomationCommunicationUtility.sendFaxForKAResponses(newKAMap, oldKAMap);
            REMS_Outbound_Communication__c outboundCommunicationRec = [SELECT Id FROM REMS_Outbound_Communication__c LIMIT 1];
            system.assert(outboundCommunicationRec != null);
        Test.stopTest();
    }

    @isTest
    private static void sendFaxCommunicationFromAccountWhileUpdateTest(){
        Map<Id,Account> newAccountMap = new Map<Id,Account>();
        Id prescriberRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        Id hcsRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');

        Test.startTest();
            Map<Id,Account> oldAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c,RecordTypeId,US_WSREMS__Sub_Status__c,US_WSREMS__Preferred_Contact_Method__c FROM Account WHERE recordTypeId =: prescriberRecordType]);
            for(Account accRec:oldAccountMap.values()){
                Account newAcc = new Account();
                newAcc.Id = accRec.Id;
                newAcc.recordTypeId = accRec.recordTypeId;
                newAcc.US_WSREMS__Status__c = 'Decertified';
                newAcc.US_WSREMS__Sub_Status__c = 'Program Noncompliant';
                newAcc.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
                newAcc.Fax = '6423266666';
                newAccountMap.put(newAcc.Id, newAcc);
            }
        update newAccountMap.values();
        AVEEDAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(newAccountMap, oldAccountMap);
        REMS_Outbound_Communication__c outboundCommunicationRec = [SELECT Id FROM REMS_Outbound_Communication__c LIMIT 1];
        system.assert(outboundCommunicationRec != null);
        Test.stopTest();
    }

    @isTest
    private static void sendFaxCommunicationFromAccountWhileUpdateTest1(){
        Map<Id,Account> newAccountMap = new Map<Id,Account>();
        Id prescriberRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        Id hcsRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');

        Test.startTest();
            Map<Id,Account> oldAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c,RecordTypeId,US_WSREMS__Sub_Status__c,US_WSREMS__Preferred_Contact_Method__c FROM Account]);
            for(Account accRec:oldAccountMap.values()){
                Account newAcc = new Account();
                newAcc.Id = accRec.Id;
                newAcc.recordTypeId = accRec.recordTypeId;
                if(newAcc.recordTypeId == prescriberRecordType){
                    newAcc.US_WSREMS__Status__c = 'Deactivated';
                    newAcc.US_WSREMS__Sub_Status__c = 'Opt-Out';
                    newAcc.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
                    newAcc.Fax = '6423266666';
                    newAccountMap.put(newAcc.Id, newAcc);
                } else if(newAcc.recordTypeId == hcsRecordType){
                    newAcc.US_WSREMS__Status__c = 'Decertified';
                    newAcc.US_WSREMS__Sub_Status__c = 'AR Not Confirmed';
                    newAcc.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
                    newAcc.Fax = '6423266666';
                    newAccountMap.put(newAcc.Id, newAcc);
                }
            }
        update newAccountMap.values();
        AVEEDAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(newAccountMap, oldAccountMap);
        REMS_Outbound_Communication__c outboundCommunicationRec = [SELECT Id FROM REMS_Outbound_Communication__c LIMIT 1];
        system.assert(outboundCommunicationRec != null);
        Test.stopTest();
    }

    @isTest
    private static void sendFaxCommunicationFromAccountWhileUpdateTest2(){
        Map<Id,Account> newAccountMap = new Map<Id,Account>();
        Id prescriberRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
        Id hcsRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');

        Test.startTest();
            Map<Id,Account> oldAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c,RecordTypeId,US_WSREMS__Sub_Status__c,US_WSREMS__Preferred_Contact_Method__c FROM Account WHERE recordTypeId =: hcsRecordType]);
            for(Account accRec:oldAccountMap.values()){
                Account newAcc = new Account();
                newAcc.Id = accRec.Id;
                newAcc.recordTypeId = accRec.recordTypeId;
                newAcc.US_WSREMS__Status__c = 'Decertified';
                newAcc.US_WSREMS__Sub_Status__c = 'Program Noncompliant';
                newAcc.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
                newAcc.Fax = '6423266666';
                newAccountMap.put(newAcc.Id, newAcc);
            }
        update newAccountMap.values();
        AVEEDAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(newAccountMap, oldAccountMap);
        REMS_Outbound_Communication__c outboundCommunicationRec = [SELECT Id FROM REMS_Outbound_Communication__c LIMIT 1];
        system.assert(outboundCommunicationRec != null);
        Test.stopTest();
    }

    @isTest
    private static void sendFaxCommunicationFromHCSAccountWhileUpdateTest(){
        Map<Id,Account> newAccountMap = new Map<Id,Account>();
        Id hcsRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');

        Test.startTest();
            Map<Id,Account> oldAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c,RecordTypeId,US_WSREMS__Sub_Status__c,US_WSREMS__Preferred_Contact_Method__c FROM Account WHERE recordTypeId =:hcsRecordType]);
            for(Account accRec:oldAccountMap.values()){
                Account newAcc = new Account();
                newAcc.Id = accRec.Id;
                newAcc.recordTypeId = accRec.recordTypeId;
                newAcc.US_WSREMS__Status__c = 'Deactivated';
                newAcc.US_WSREMS__Sub_Status__c = 'Opt-Out';
                newAcc.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
                newAcc.Fax = '6423266666';
                newAccountMap.put(newAcc.Id, newAcc);
            }
        update newAccountMap.values();
        AVEEDAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(newAccountMap, oldAccountMap);
        REMS_Outbound_Communication__c outboundCommunicationRec = [SELECT Id FROM REMS_Outbound_Communication__c LIMIT 1];
        system.assert(outboundCommunicationRec != null);
        Test.stopTest();
    }

    @isTest
    private static void sendFaxCommunicationFromHCSAccountWhileUpdateTest1(){
        Map<Id,Account> newAccountMap = new Map<Id,Account>();
        Id hcsRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');

        Test.startTest();
            Map<Id,Account> oldAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c,RecordTypeId,US_WSREMS__Sub_Status__c,US_WSREMS__Preferred_Contact_Method__c FROM Account WHERE recordTypeId =:hcsRecordType]);
            for(Account accRec:oldAccountMap.values()){
                Account newAcc = new Account();
                newAcc.Id = accRec.Id;
                newAcc.recordTypeId = accRec.recordTypeId;
                newAcc.US_WSREMS__Status__c = 'Decertified';
                newAcc.US_WSREMS__Sub_Status__c = 'Failure to recertify';
                newAcc.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
                newAcc.Fax = '6423266666';
                newAccountMap.put(newAcc.Id, newAcc);
            }
        update newAccountMap.values();
        AVEEDAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(newAccountMap, oldAccountMap);
        REMS_Outbound_Communication__c outboundCommunicationRec = [SELECT Id FROM REMS_Outbound_Communication__c LIMIT 1];
        system.assert(outboundCommunicationRec != null);
        Test.stopTest();
    }

    @isTest
    private static void createREMSCommunicationRecordsTest(){
        Account accountRec = new Account();
        accountRec.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        REMS_Outbound_Communication__c outboundCommunicationRec;
        Test.startTest();
            outboundCommunicationRec = AVEEDAutomationCommunicationUtility.createREMSCommunicationRecords(accountRec,'Fax', 'HCS Opt out confirmation');
        Test.stopTest();
        system.assert(outboundCommunicationRec != null, 'outbound communication is not null');
    }
    @isTest
    private static void sendemailnotificatiofromnonComplainceTest(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        prescriberaccount.PersonEmail = 'test@test.com';

        Account hcsaccount = new Account();
        hcsaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsaccount.US_WSREMS__Status__c = 'Pending';
        hcsaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        hcsaccount.Fax = '734727777';
        hcsaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';

        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.US_WSREMS__X1_Participant__c = hcsaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = hcsaccount;
        caseRecordHcs.Status = 'Compliance Investigation';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Suspected Non-compliance activity';

        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);

        Test.startTest();
            sObject ObjectName = AVEEDAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();
        system.assert(ObjectName != null);
    }

    @isTest
    private static void sendemailnotificatiofromnonComplainceTest1(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        prescriberaccount.PersonEmail = 'test@test.com';

        Account hcsaccount = new Account();
        hcsaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsaccount.US_WSREMS__Status__c = 'Pending';
        hcsaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        hcsaccount.Fax = '734727777';
        hcsaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';

        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.US_WSREMS__X1_Participant__c = hcsaccount.id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = hcsaccount;
        caseRecordHcs.Status = 'Complete';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';

        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);

        Test.startTest();
            sObject ObjectName = AVEEDAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();
        system.assert(ObjectName != null);
    }

    @isTest
    private static void sendemailnotificatiofromnonComplainceTest2(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        prescriberaccount.PersonEmail = 'test@test.com';

        Account hcsaccount = new Account();
        hcsaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsaccount.US_WSREMS__Status__c = 'Pending';
        hcsaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        hcsaccount.Fax = '734727777';
        hcsaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';

        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.US_WSREMS__X1_Participant__c = hcsaccount.id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = hcsaccount;
        caseRecordHcs.Status = 'Compliance Investigation';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';

        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);

        Test.startTest();
            sObject objname = AVEEDAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();
        system.assert(objname != null);
    }

    @isTest
    private static void sendemailnotificatiofromnonComplainceTest3(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        prescriberaccount.PersonEmail = 'test@test.com';

        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.US_WSREMS__X1_Participant__c = prescriberaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = prescriberaccount;
        caseRecordHcs.Status = 'Compliance Investigation';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';

        Test.startTest();
            sObject objname = AVEEDAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, null);
        Test.stopTest();
        system.assert(objname != null);
    }

    @isTest
    private static void sendemailnotificatiofromnonComplainceTest4(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        prescriberaccount.PersonEmail = 'test@test.com';

        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.US_WSREMS__X1_Participant__c = prescriberaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = prescriberaccount;
        caseRecordHcs.Status = 'Complete';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';

        Test.startTest();
            sObject ObjectName = AVEEDAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, null);
        Test.stopTest();
        system.assert(ObjectName != null);
    }

    @isTest
    private static void sendemailnotificatiofromnonComplainceTest5(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        prescriberaccount.PersonEmail = 'test@test.com';

        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.US_WSREMS__X1_Participant__c = prescriberaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = prescriberaccount;
        caseRecordHcs.Status = 'Compliance Investigation';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Suspected Non-compliance activity';

        Test.startTest();
            sObject ObjectName = AVEEDAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, null);
        Test.stopTest();
        system.assert(ObjectName != null);
    }
}