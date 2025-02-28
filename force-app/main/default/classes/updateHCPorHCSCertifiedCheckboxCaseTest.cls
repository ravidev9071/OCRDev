@isTest
private class updateHCPorHCSCertifiedCheckboxCaseTest {
    @isTest
    private static void updateIncompleteReasonOnInsert() {
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'AVEED REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;

        Account participantAccount = SYN_TestDataUtility.createAccount(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId(), 'test', 'prescriber');
        participantAccount.US_WSREMS__Status__c = 'Pending';
        update participantAccount;

        Account hcsAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId());
        hcsAccount.US_WSREMS__Status__c = 'Pending';
        update hcsAccount;

        List<Case> caseList = new List<Case>();
        case caseRec = new case();
        caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Knowledge_Assessment';
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
        caseList.add(caseRec);

        case hcsCaseRec = new case();
        hcsCaseRec.Program_Record_Type_Control__c = 'AVEED REMS-Knowledge_Assessment';
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
        caseList.add(hcsCaseRec);

        insert caseList;

        Test.startTest();
            updateHCPorHCSCertifiedCheckboxOnCase.updateIncompleteReasonOnInsertorUpdate(false, caseList, null);
            System.assert(true, hcsCaseRec.HCPnotCertified__c);
        Test.stopTest();
    }  
     
    
    @isTest
    private static void updateIncompleteReasonOnUpdateTest() {
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'AVEED REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;

        Account participantAccount = SYN_TestDataUtility.createAccount(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId(), 'test', 'prescriber');
        participantAccount.US_WSREMS__Status__c = 'Pending';
        update participantAccount;
        
        Account participantAccount1 = SYN_TestDataUtility.createAccount(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId(), 'update', 'prescriber');
        participantAccount1.US_WSREMS__Status__c = 'Pending';
        update participantAccount1;

        Account hcsAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId());
        hcsAccount.US_WSREMS__Status__c = 'Pending';
        update hcsAccount;
        
        List<Case> caseList = new List<Case>();
        case hcsCaseRec = new case();
        hcsCaseRec.Program_Record_Type_Control__c = 'AVEED REMS-Knowledge_Assessment';
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
        insert hcsCaseRec;
        
        Map<id,Case> oldCaseMap = new Map<Id,Case>();
        oldCaseMap.put(hcsCaseRec.Id, hcsCaseRec);
        
        Case newCaseRec = new Case();
        newCaseRec.Id = hcsCaseRec.Id;
        newCaseRec.US_WSREMS__Prescriber__r = participantAccount1;
        newCaseRec.US_WSREMS__Prescriber__c = participantAccount1.Id;
		update newCaseRec;      

        Test.startTest();
        updateHCPorHCSCertifiedCheckboxOnCase.updateIncompleteReasonOnInsertorUpdate(true, new List<Case> {newCaseRec}, oldCaseMap);
            System.assert(true, newCaseRec.HCPnotCertified__c);
        Test.stopTest();
    }  
}