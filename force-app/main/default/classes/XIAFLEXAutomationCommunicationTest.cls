@isTest(isParallel = true)
private class XIAFLEXAutomationCommunicationTest {
    @testSetup
    public static void dataSetup(){
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'XIAFLEX';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        
        Account participantAccount = SYN_TestDataUtility.createAccount(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId(), 'test', 'prescriber');
        participantAccount.US_WSREMS__Status__c = 'Pending';
        participantAccount.Fax = '734727777';
        participantAccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        participantAccount.US_WSREMS__Sub_Status__c='No Longer Participating';
        update participantAccount;
        
        Account hcsAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId());
        hcsAccount.US_WSREMS__Status__c = 'Pending';
        update hcsAccount;
        
        List<Case> caseList = new List<Case>();
        case pfcHcsCaseRec = new case();
        pfcHcsCaseRec.Program_Record_Type_Control__c = 'XIAFLEX-HCS_Enrollment';
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
        pfcHcsCaseRec.US_WSREMS__Incomplete_Reasons__c='DEA';
        caseList.add(pfcHcsCaseRec);
        
        case casePresRec = new case();
        casePresRec.Program_Record_Type_Control__c = 'XIAFLEX-Prescriber_enrollment';
        casePresRec.US_WSREMS__REMS_Program__c = programObj.Id;
        casePresRec.US_WSREMS__REMS_Program__r = programObj;
        casePresRec.Status = 'Draft';
        casePresRec.US_WSREMS__First_Name__c = 'test';
        casePresRec.US_WSREMS__Last_Name__c = 'test';
        casePresRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        casePresRec.US_WSREMS__Program_Picklist__c = programObj.Name;
        casePresRec.US_WSREMS__Participant__r = participantAccount;
        casePresRec.US_WSREMS__Participant__c = participantAccount.Id;
        casePresRec.US_WSREMS__Healthcare_Setting__r = hcsAccount;
        casePresRec.US_WSREMS__Healthcare_Setting__c = hcsAccount.Id;
        casePresRec.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        casePresRec.US_WSREMS__Email__c = 'test@test.com';
        casePresRec.US_WSREMS__Fax__c = '7653216217';
        casePresRec.US_WSREMS__Incomplete_Reasons__c='DEA';
        caseList.add(casePresRec);
        
        case caseNonComRec = new case();
        caseNonComRec.Program_Record_Type_Control__c = 'XIAFLEX-Non_Compliance';
        caseNonComRec.US_WSREMS__REMS_Program__c = programObj.Id;
        caseNonComRec.US_WSREMS__REMS_Program__r = programObj;
        caseNonComRec.Status = 'Draft';
        caseNonComRec.US_WSREMS__First_Name__c = 'test';
        caseNonComRec.US_WSREMS__Last_Name__c = 'test';
        caseNonComRec.recordtypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseNonComRec.US_WSREMS__Program_Picklist__c = programObj.Name;
        caseNonComRec.US_WSREMS__Participant__r = participantAccount;
        caseNonComRec.US_WSREMS__Participant__c = participantAccount.Id;
        caseNonComRec.US_WSREMS__Healthcare_Setting__r = hcsAccount;
        caseNonComRec.US_WSREMS__Healthcare_Setting__c = hcsAccount.Id;
        //caseNonComRec.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        caseNonComRec.US_WSREMS__Email__c = 'test@test.com';
        caseNonComRec.US_WSREMS__Fax__c = '7653216217';
        caseNonComRec.US_WSREMS__Incomplete_Reasons__c='DEA';
        caseList.add(caseNonComRec);
        insert caseList;
        
    }
    @isTest
    private static void createREMSCommunicationForprescriberChangeTest(){
        Case caseRecord = new Case();
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Change_Authorized_Representative');
        caseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecord.RecordTypeId = prescriberEnrollCaseRecTypeId;
        caseRecord.US_WSREMS__Program_Type__c='REMS';
        
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Test.startTest();
        communicationRecList = XIAFLEXAutomationCommunicationUtility.createREMSCommunicationForHCSorHcpEnroll(caseRecord);
        Test.stopTest();
        
        system.assert(communicationRecList != null, 'Outbound Communication is not null');
    }
    
    @isTest
    private static void createREMSCommunicationForprescriberTest(){
        Case caseRecord = new Case();
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Change_Authorized_Representative');
        caseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecord.RecordTypeId = prescriberEnrollCaseRecTypeId;
        caseRecord.US_WSREMS__Program_Type__c='MDP';
        
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Test.startTest();
        communicationRecList = XIAFLEXAutomationCommunicationUtility.createREMSCommunicationForHCSorHcpEnroll(caseRecord);
        Test.stopTest();
        
        system.assert(communicationRecList != null, 'Outbound Communication is not null');
    }
    @isTest
    private static void createREMSCommunicationForHcpEnrollTestt(){
        Case caseRecord = new Case();
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        caseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecord.RecordTypeId = prescriberEnrollCaseRecTypeId;
        caseRecord.US_WSREMS__Program_Type__c='MDP';
        
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Test.startTest();
        communicationRecList = XIAFLEXAutomationCommunicationUtility.createREMSCommunicationForHCSorHcpEnroll(caseRecord);
        Test.stopTest();
        
        system.assert(communicationRecList != null, 'Outbound Communication is not null');
    }
    @isTest
    private static void createREMSCommunicationForHcpEnrollTest(){
        Case caseRecord = new Case();
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        caseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecord.RecordTypeId = prescriberEnrollCaseRecTypeId;
        caseRecord.US_WSREMS__Program_Type__c='REMS';
        
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Test.startTest();
        communicationRecList = XIAFLEXAutomationCommunicationUtility.createREMSCommunicationForHCSorHcpEnroll(caseRecord);
        Test.stopTest();
        
        system.assert(communicationRecList != null, 'Outbound Communication is not null');
    }
    
    @isTest
    private static void createREMSCommunicationForHcsEnrollTest(){
        Case caseRecord = new Case();
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
        caseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecord.RecordTypeId = prescriberEnrollCaseRecTypeId;
        caseRecord.US_WSREMS__Program_Type__c='REMS';
        
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Test.startTest();
        communicationRecList = XIAFLEXAutomationCommunicationUtility.createREMSCommunicationForHCSorHcpEnroll(caseRecord);
        Test.stopTest();
        
        system.assert(communicationRecList != null, 'Outbound Communication is not null');
    }
    @isTest
    private static void createREMSCommunicationForHcsEnrollTestMDP(){
        Case caseRecord = new Case();
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Enrollment');
        caseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecord.RecordTypeId = prescriberEnrollCaseRecTypeId;
        caseRecord.US_WSREMS__Program_Type__c='MDP';
        caseRecord.status = 'Draft';
        caseRecord.US_WSREMS__Preferred_Contact_Method__c='Fax';
        
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Test.startTest();
        communicationRecList = XIAFLEXAutomationCommunicationUtility.createREMSCommunicationForHCSorHcpEnroll(caseRecord);
        Test.stopTest();
        
        system.assert(communicationRecList != null, 'Outbound Communication is not null');
    }
    
    @isTest
    private static void createREMSCommunicationForHcsReEnrollTest(){
        Case caseRecord = new Case();
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'HCS_Reenrollment');
        caseRecord.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecord.RecordTypeId = prescriberEnrollCaseRecTypeId;
        caseRecord.US_WSREMS__Program_Type__c='REMS';
        caseRecord.status='Draft';
        caseRecord.US_WSREMS__Preferred_Contact_Method__c ='Fax';
        
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
        Test.startTest();
        communicationRecList = XIAFLEXAutomationCommunicationUtility.createREMSCommunicationForHCSorHcpEnroll(caseRecord);
        Test.stopTest();
        
        system.assert(communicationRecList != null, 'Outbound Communication is not null');
    }
    
    @isTest
    private static void sendCommunicationFromHCSCaseWhileUpdateTestFaxDraft(){
        Id HCSRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();
        
        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:HCSRecTypeId LIMIT 1]);
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.US_WSREMS__Program_Type__c='REMS';
            newCase.status = 'Draft';
            newCase.US_WSREMS__Preferred_Contact_Method__c='Fax';
            newCase.RecordTypeId=HCSRecTypeId;
            newcase.US_WSREMS__Incomplete_Reasons__c='DEA';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();
        XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(false,newCaseMap,oldCaseMap);
        Test.stopTest();
    } 
    @isTest
    private static void sendCommunicationFromHCSCaseWhileUpdateTestFax(){
        Id HCSRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();
        
        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:HCSRecTypeId LIMIT 1]);
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.status = 'Draft';
            newCase.US_WSREMS__Preferred_Contact_Method__c='Fax';
            newCase.RecordTypeId=HCSRecTypeId;
            newCase.US_WSREMS__Program_Type__c='MDP';
            newcase.US_WSREMS__Incomplete_Reasons__c='DEA';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();
        XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(false,newCaseMap,oldCaseMap);
        Test.stopTest();
    } 
    
    @isTest
    private static void sendCommunicationFromHCSCaseWhileUpdateTestFaxREMS(){
        Id HCSRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Reenrollment').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();
        
        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:HCSRecTypeId LIMIT 1]);
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.status = 'Draft';
            newCase.US_WSREMS__Preferred_Contact_Method__c='Fax';
            newCase.RecordTypeId=HCSRecTypeId;
            newCase.US_WSREMS__Program_Type__c='REMS';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();
        XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(false,newCaseMap,oldCaseMap);
        Test.stopTest();
    }
    @isTest
    private static void sendCommunicationFromHCSCaseWhileUpdateTestFaxMDPPres(){
        Id HCSRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();
        
        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:HCSRecTypeId LIMIT 1]);
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.status = 'Draft';
            newCase.US_WSREMS__Preferred_Contact_Method__c='Fax';
            newCase.RecordTypeId=HCSRecTypeId;
            newCase.US_WSREMS__Program_Type__c='MDP';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();
        XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(false,newCaseMap,oldCaseMap);
        Test.stopTest();
    }
    @isTest
    private static void sendCommunicationFromHCSCaseWhileUpdateTestFaxPres(){
        Id HCSRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();
        
        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:HCSRecTypeId LIMIT 1]);
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.status = 'Draft';
            newCase.US_WSREMS__Preferred_Contact_Method__c='Fax';
            newCase.RecordTypeId=HCSRecTypeId;
            newCase.US_WSREMS__Program_Type__c='REMS';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();
        XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(false,newCaseMap,oldCaseMap);
        Test.stopTest();
    } 
    
    
    @isTest
    private static void sendCommunicationFromHCSCaseWhileUpdateTest(){
        Id HCSRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();
        
        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:HCSRecTypeId LIMIT 1]);  
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.status = 'Complete';
            newCase.US_WSREMS__Preferred_Contact_Method__c='Email';
            newCase.US_WSREMS__Program_Type__c='MDP';
            newCase.US_WSREMS__Email_ar__c='test@test.com';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();
        XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(true,newCaseMap,oldCaseMap);
        Test.stopTest();
    }
    @isTest
    private static void sendCommunicationFromNonComCaseWhileUpdateTest(){
        Map<Id,case> newCaseMap = new Map<Id,Case>();
        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordType.name = 'Non_Compliance' LIMIT 1]);  
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            //newCase.status = 'Pending';
            newCase.US_WSREMS__Preferred_Contact_Method__c='Email';
            newCase.US_WSREMS__Program_Type__c='MDP';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();
        XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(true,newCaseMap,oldCaseMap);
        Test.stopTest();
    }
    @isTest
    private static void sendCommunicationFromHCSCaseWhileUpdateFaxTest(){
        Id HCSRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();
        US_WSREMS__Affiliation__c aff = new US_WSREMS__Affiliation__c();
        aff.RecordTypeId = Schema.sObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Authorized_Representative_Affiliation').getRecordTypeId();
        aff.US_WSREMS__REMSProgram__c = [SELECT Id,name from US_WSREMS__REMS_Program__c WHERE Name='XIAFLEX' LIMIT 1].Id; 
        aff.US_WSREMS__Health_Care_Setting__c = [SELECT Id FROM Account WHERE Recordtype.name='Health Care Setting' LIMIT 1].Id;
        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:HCSRecTypeId LIMIT 1]);
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.status = 'Complete';
            newCase.US_WSREMS__Preferred_Contact_Method__c='Fax';
            newCaseMap.put(newCase.Id, newCase);
            newCase.US_WSREMS__Program_Type__c='REMS';
        }
        update newCaseMap.values();
        XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(true,newCaseMap,oldCaseMap);
        Test.stopTest();
    }
    @isTest
    private static void sendCommunicationFromHCSCaseWhileUpdateFaxMethodTest1(){
        Id HCSRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();
        
        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:HCSRecTypeId LIMIT 1]);
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.status = 'Complete';
            newCase.US_WSREMS__Preferred_Contact_Method__c='Fax';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();
        XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(false,newCaseMap,oldCaseMap);
        Test.stopTest();
    }
    @isTest
    private static void sendCommunicationFromHCSCaseWhileUpdateFaxMethodTest(){
        Id HCSRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();
        
        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:HCSRecTypeId LIMIT 1]);
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.status = 'Complete';
            newCase.US_WSREMS__Preferred_Contact_Method__c='Fax';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();
        XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(false,newCaseMap,oldCaseMap);
        Test.stopTest();
    }
    
    @isTest
    private static void sendCommunicationFromHCSCaseWhileUpdateTestMethod(){
        Id HCSRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('HCS_Enrollment').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();
		
        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:HCSRecTypeId LIMIT 1]);
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.RecordTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();
            newCase.status = 'Complete';
            newCase.US_WSREMS__Preferred_Contact_Method__c='Email';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();
        XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(true,newCaseMap,oldCaseMap);
        Test.stopTest();
    }
    @isTest
    private static void sendCommunicationFromNonCaseWhileUpdateTestMethod(){
        Id HCSRecTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();
        Map<Id,case> newCaseMap = new Map<Id,Case>();
		
        Test.startTest();
        Map<Id,case> oldCaseMap = new Map<Id,Case>([SELECT Id,Status,RecordTypeId,US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Outcome__c FROM Case WHERE RecordTypeId=:HCSRecTypeId LIMIT 1]);
        for(Case caseRec:oldCaseMap.values()){
            Case newCase = new Case();
            newCase.Id = caseRec.Id;
            newCase.RecordTypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();
            newCase.status = 'Pending';
            //newCase.US_WSREMS__Preferred_Contact_Method__c='Email';
            newCaseMap.put(newCase.Id, newCase);
        }
        update newCaseMap.values();
        XIAFLEXAutomationCommunicationUtility.sendCommunicationFromCaseWhileUpdateOrInsert(true,newCaseMap,oldCaseMap);
        Test.stopTest();
    }
    @isTest
    private static void sendemailnotificatiofromnonComplainceTest(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        prescriberaccount.PersonEmail = 'test@test.com';
        
        Account hcsaccount = new Account();
        hcsaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsaccount.US_WSREMS__Status__c = 'Pending';
        hcsaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        hcsaccount.Fax = '734727777';
        hcsaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        
        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.US_WSREMS__X1_Participant__c = hcsaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = hcsaccount;
        caseRecordHcs.Status = 'Complete';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Suspected Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='REMS';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();
    }
    @isTest
    private static void sendemailnotificatiofromnonComplainceTestFax(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        prescriberaccount.PersonEmail = 'test@test.com';
        
        Account hcsaccount = new Account();
        hcsaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsaccount.US_WSREMS__Status__c = 'Pending';
        hcsaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        hcsaccount.Fax = '734727777';
        hcsaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        
        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.US_WSREMS__X1_Participant__c = prescriberaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = prescriberaccount;
        caseRecordHcs.Status = 'Complete';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Suspected Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='MDP';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();
    }
    @isTest
    private static void sendemailnotificatiofromnonComplainceTestFaxMDP(){
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
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.US_WSREMS__X1_Participant__c = prescriberaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = prescriberaccount;
        caseRecordHcs.Status = 'Complete';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Suspected Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='MDP';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();
    }
    @isTest
    private static void sendemailnotificatiofromnonComplainceTestFaxConfirmMDP(){
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
        caseRecordHcs.US_WSREMS__X1_Participant__c = prescriberaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = prescriberaccount;
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.Status = 'Complete';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='MDP';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();
    }
    @isTest
    private static void sendemailnotificatiofromnonComplainceTestFaxComplMDP(){
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
        caseRecordHcs.US_WSREMS__X1_Participant__c = prescriberaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = prescriberaccount;
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.Status = 'Compliance Investigation';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='MDP';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();
    }
    @isTest
    private static void sendemailnotificatiofromnonComplainceTestFaxComplREMS(){
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
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.US_WSREMS__X1_Participant__c = prescriberaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = prescriberaccount;
        caseRecordHcs.Status = 'Compliance Investigation';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='REMS';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();
    }
    @isTest
    private static void sendemailnotificatiofromnonComplainceTestFaxConfirmREMS(){
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
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.US_WSREMS__X1_Participant__c = prescriberaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = prescriberaccount;
        caseRecordHcs.Status = 'Complete';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='REMS';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();
    }
    @isTest
    private static void sendemailnotificatiofromnonComplainceTestFaxPreMDP(){
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
        caseRecordHcs.US_WSREMS__X1_Participant__c = prescriberaccount.Id;
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.US_WSREMS__X1_Participant__r = prescriberaccount;
        caseRecordHcs.Status = 'Complete';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Suspected Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='REMS';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();
    }
    @isTest
    private static void sendemailnotificatiofromnonComplainceTestFaxConfREMS(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
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
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.US_WSREMS__X1_Participant__r = hcsaccount;
        caseRecordHcs.Status = 'Complete';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='REMS';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();}
    @isTest
    private static void sendemailnotificatiofromnonComplainceTestFaxConfMDP(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        prescriberaccount.PersonEmail = 'test@test.com';
        
        Account hcsaccount = new Account();
        hcsaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsaccount.US_WSREMS__Status__c = 'Pending';
        hcsaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        hcsaccount.Fax = '734727777';
        hcsaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        
        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.US_WSREMS__X1_Participant__c = hcsaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = hcsaccount;
        caseRecordHcs.Status = 'Complete';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Suspected Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='MDP';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();}
    @isTest
    private static void sendemailnotificatiofromnonComplainceTestFaxConfCompMDP(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        prescriberaccount.PersonEmail = 'test@test.com';
        
        Account hcsaccount = new Account();
        hcsaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsaccount.US_WSREMS__Status__c = 'Pending';
        hcsaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        hcsaccount.Fax = '734727777';
        hcsaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        
        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.US_WSREMS__X1_Participant__c = hcsaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = hcsaccount;
        caseRecordHcs.Status = 'Compliance Investigation';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='REMS';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();}
    @isTest
    private static void sendemailnotificatiofromnonComplainceTestFaxCompConfMDP(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        prescriberaccount.PersonEmail = 'test@test.com';
        
        Account hcsaccount = new Account();
        hcsaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsaccount.US_WSREMS__Status__c = 'Pending';
        hcsaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        hcsaccount.Fax = '734727777';
        hcsaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        
        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.US_WSREMS__X1_Participant__c = hcsaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = hcsaccount;
        caseRecordHcs.Status = 'Compliance Investigation';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='MDP';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();}
    @isTest
    private static void sendemailnotificatiofromnonComplainceTestFaxConf(){
        Account prescriberaccount = new Account();
        prescriberaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        prescriberaccount.US_WSREMS__Status__c = 'Pending';
        prescriberaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        prescriberaccount.Fax = '734727777';
        prescriberaccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        prescriberaccount.PersonEmail = 'test@test.com';
        
        Account hcsaccount = new Account();
        hcsaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsaccount.US_WSREMS__Status__c = 'Pending';
        hcsaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        hcsaccount.Fax = '734727777';
        hcsaccount.US_WSREMS__Preferred_Contact_Method__c = 'Fax';
        
        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.US_WSREMS__X1_Participant__c = hcsaccount.Id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = hcsaccount;
        caseRecordHcs.Status = 'Complete';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
        caseRecordHcs.US_WSREMS__Program_Type__c='MDP';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Authorized_Representative__r = prescriberaccount;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();}
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
        hcsaccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        
        Case caseRecordHcs = new Case();
        caseRecordHcs.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseRecordHcs.RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        caseRecordHcs.US_WSREMS__X1_Participant__c = hcsaccount.id;
        caseRecordHcs.US_WSREMS__X1_Participant__r = hcsaccount;
        caseRecordHcs.Status = 'Complete';
        caseRecordHcs.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
        
        Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
        US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
        affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
        affiliationRec.US_WSREMS__Health_Care_Setting__c = hcsaccount.id;
        accountIdToaffiliationMap.put(hcsaccount.Id, affiliationRec);
        
        Test.startTest();
        sObject ObjectName = XIAFLEXAutomationCommunicationUtility.sendemailnotificatiofromnonComplaince(caseRecordHcs, accountIdToaffiliationMap);
        Test.stopTest();
    }   
    @isTest 
    private static void createREMSCommunicationRecordsTest(){
        Account hcsaccount = new Account();
        hcsaccount.Id = SYN_TestDataUtility.getSobjectId(Account.getSObjectType());
        hcsaccount.US_WSREMS__Status__c = 'Pending';
        hcsaccount.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        hcsaccount.Fax = '734727777';
        hcsaccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        REMS_Outbound_Communication__c communicationRec = XIAFLEXAutomationCommunicationUtility.createREMSCommunicationRecords(hcsaccount,'Fax','XIAFLEX_Conga_HCP_Non_Complaince_Notice');
    }
    
    @isTest
    private static void sendFaxCommunicationFromAccountWhileUpdateTest(){
      Map<Id,Account> newAccountMap = new Map<Id,Account>();
      Map<Id,Account> oldAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c,US_WSREMS__Sub_Status__c,RecordTypeId FROM Account WHERE US_WSREMS__Status__c = 'Pending' LIMIT 1]);
        for(Account accRec:oldAccountMap.values()){
            Account newAcc = new Account();
            newAcc.Id = accRec.Id;
            newAcc.recordtypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
            //newAcc.US_WSREMS__Status__c = 'Complete';
            newAcc.US_WSREMS__Sub_Status__c = 'Program Opt-Out';
            newAcc.US_WSREMS__Preferred_Contact_Method__c='Email';
            newAcc.PersonEmail = 'test@gmail.com';
            newAccountMap.put(newAcc.Id, newAcc);
        }
        update newAccountMap.values();
        XIAFLEXAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(newAccountMap,oldAccountMap);
    }
    @isTest
    private static void sendFaxCommunicationFromAccountWhileUpdateTest1(){
      Map<Id,Account> newAccountMap = new Map<Id,Account>();
      Map<Id,Account> oldAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c,US_WSREMS__Sub_Status__c,RecordTypeId FROM Account WHERE US_WSREMS__Status__c = 'Pending' LIMIT 1]);
        for(Account accRec:oldAccountMap.values()){
            Account newAcc = new Account();
            newAcc.Id = accRec.Id;
            newAcc.recordtypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
            newAcc.US_WSREMS__Status__c = 'Deactivated';
            newAcc.US_WSREMS__Sub_Status__c = 'Program Opt-Out';
            newAcc.US_WSREMS__Preferred_Contact_Method__c='Fax';
            newAcc.US_WSREMS__Program_Type__c ='REMS';
            newAcc.Fax = '232334467';
            
            newAccountMap.put(newAcc.Id, newAcc);
        }
        update newAccountMap.values();
        XIAFLEXAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(newAccountMap,oldAccountMap);
    }
    @isTest
    private static void sendFaxCommunicationFromAccountWhileUpdateTestMDP(){
      Map<Id,Account> newAccountMap = new Map<Id,Account>();
      Map<Id,Account> oldAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c,US_WSREMS__Sub_Status__c,RecordTypeId FROM Account WHERE US_WSREMS__Status__c = 'Pending' LIMIT 1]);
        for(Account accRec:oldAccountMap.values()){
            Account newAcc = new Account();
            newAcc.Id = accRec.Id;
            newAcc.recordtypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
            newAcc.US_WSREMS__Status__c = 'Deactivated';
            newAcc.US_WSREMS__Sub_Status__c = 'Program Opt-Out';
            newAcc.US_WSREMS__Preferred_Contact_Method__c='Email';
            newAcc.US_WSREMS__Program_Type__c ='MDP';
            newAcc.PersonEmail = 'test@gmail.com';
            
            newAccountMap.put(newAcc.Id, newAcc);
        }
        update newAccountMap.values();
        XIAFLEXAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(newAccountMap,oldAccountMap);
    }
    @isTest
    private static void sendFaxCommunicationFromAccountWhileUpdateTestMDPFax(){
      Map<Id,Account> newAccountMap = new Map<Id,Account>();
      Map<Id,Account> oldAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c,US_WSREMS__Sub_Status__c,RecordTypeId FROM Account WHERE US_WSREMS__Status__c = 'Pending' LIMIT 1]);
        for(Account accRec:oldAccountMap.values()){
            Account newAcc = new Account();
            newAcc.Id = accRec.Id;
            newAcc.recordtypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Prescriber');
            newAcc.US_WSREMS__Status__c = 'Deactivated';
            newAcc.US_WSREMS__Sub_Status__c = 'Program Opt-Out';
            newAcc.US_WSREMS__Preferred_Contact_Method__c='Fax';
            newAcc.US_WSREMS__Program_Type__c ='MDP';
            newAcc.Fax = '343344566';
            
            newAccountMap.put(newAcc.Id, newAcc);
        }
        update newAccountMap.values();
        XIAFLEXAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(newAccountMap,oldAccountMap);
    }
    @isTest
    private static void sendFaxCommunicationFromAccountWhileUpdateTest2(){
      Map<Id,Account> newAccountMap = new Map<Id,Account>();
      Map<Id,Account> oldAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c,US_WSREMS__Sub_Status__c,RecordTypeId FROM Account WHERE Recordtype.name = 'Health Care Setting' LIMIT 1]);
        for(Account accRec:oldAccountMap.values()){
            Account newAcc = new Account();
            newAcc.Id = accRec.Id;
            newAcc.recordtypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');
            newAcc.US_WSREMS__Status__c = 'Deactivated';
            newAcc.US_WSREMS__Sub_Status__c = 'Noncompliant';
            newAcc.US_WSREMS__Preferred_Contact_Method__c='Email';
            newAcc.Fax = '232334467';
           // newAcc.Email = 'test@gmail.com';
            newAccountMap.put(newAcc.Id, newAcc);
            Map<Id, US_WSREMS__Affiliation__c> accountIdToaffiliationMap = new Map<Id, US_WSREMS__Affiliation__c>();
            US_WSREMS__Affiliation__c affiliationRec = new US_WSREMS__Affiliation__c();
            affiliationRec.Id = SYN_TestDataUtility.getSobjectId(US_WSREMS__Affiliation__c.getSObjectType());
            affiliationRec.US_WSREMS__Health_Care_Setting__c = newAcc.id;
            accountIdToaffiliationMap.put(newAcc.Id, affiliationRec);
        }
        update newAccountMap.values();
        XIAFLEXAutomationCommunicationUtility.checkEmailOrFax('Email','test@gmail.com','2223333');
        XIAFLEXAutomationCommunicationUtility.checkEmailOrFax('Email',null,'2223333');
        XIAFLEXAutomationCommunicationUtility.checkEmailOrFax('Fax','test@gmail.com','2223333');
        XIAFLEXAutomationCommunicationUtility.checkEmailOrFax('Fax','test@gmail.com',null);
        XIAFLEXAutomationCommunicationUtility.checkEmailOrFax('Phone','test@gmail.com',null);
        XIAFLEXAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(newAccountMap,oldAccountMap);
    }
    @isTest
    private static void sendFaxCommunicationFromAccountWhileUpdateTest3(){
      Map<Id,Account> newAccountMap = new Map<Id,Account>();
      Map<Id,Account> oldAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c,US_WSREMS__Sub_Status__c,RecordTypeId FROM Account WHERE Recordtype.Name = 'Health Care Setting' LIMIT 1]);
        for(Account accRec:oldAccountMap.values()){
            Account newAcc = new Account();
            newAcc.Id = accRec.Id;
            newAcc.recordtypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');
            newAcc.US_WSREMS__Status__c = 'Deactivated';
            newAcc.US_WSREMS__Sub_Status__c = 'Program Opt-Out';
            newAcc.US_WSREMS__Preferred_Contact_Method__c='Email';
            newAcc.Fax = '232334467';
            newAccountMap.put(newAcc.Id, newAcc);
        }
        update newAccountMap.values();
        XIAFLEXAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(newAccountMap,oldAccountMap);
    }
    @isTest
    private static void sendFaxCommunicationFromAccountWhileUpdateTest4(){
      Map<Id,Account> newAccountMap = new Map<Id,Account>();
      Map<Id,Account> oldAccountMap = new Map<Id,Account>([SELECT Id,US_WSREMS__Status__c,US_WSREMS__Sub_Status__c,RecordTypeId FROM Account WHERE Recordtype.Name = 'Health Care Setting' LIMIT 1]);
        for(Account accRec:oldAccountMap.values()){
            Account newAcc = new Account();
            newAcc.Id = accRec.Id;
            newAcc.recordtypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');
            newAcc.US_WSREMS__Status__c = 'Decertified';
            newAcc.US_WSREMS__Sub_Status__c = 'Enrollment Expired';
            newAcc.US_WSREMS__Preferred_Contact_Method__c='Fax';
            newAcc.Fax = '232334467';
            newAccountMap.put(newAcc.Id, newAcc);
        }
        update newAccountMap.values();
        XIAFLEXAutomationCommunicationUtility.sendFaxCommunicationFromAccountWhileUpdate(newAccountMap,oldAccountMap);
    }
}