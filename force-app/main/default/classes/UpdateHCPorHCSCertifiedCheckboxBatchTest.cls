@isTest
private class UpdateHCPorHCSCertifiedCheckboxBatchTest {

    @isTest
    private static void Aveed_UpdateHcsOrHcpStatusCertifiedTests() {
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'AVEED REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;

        Account participantAccount = SYN_TestDataUtility.createAccount(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId(), 'test', 'prescriber');
        participantAccount.US_WSREMS__Status__c = 'Certified';
        update participantAccount;

        Account hcsAccount = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id, Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId());
        hcsAccount.US_WSREMS__Status__c = 'Certified';
        update hcsAccount;

        case caseRec = new case();
        caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Knowledge_Assessment';
        caseRec.US_WSREMS__REMS_Program__c = programObj.Id;
        caseRec.Status = 'Draft';
        caseRec.US_WSREMS__First_Name__c = 'test';
        caseRec.US_WSREMS__Last_Name__c = 'test';
        caseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        caseRec.US_WSREMS__Program_Picklist__c = programObj.Name;
        caseRec.US_WSREMS__Participant__r = participantAccount;
        caseRec.US_WSREMS__Participant__c = participantAccount.Id;
        caseRec.US_WSREMS__Healthcare_Setting__r = hcsAccount;
        caseRec.US_WSREMS__Healthcare_Setting__c = hcsAccount.Id;
        caseRec.HCSnotCertified__c = true;
        insert caseRec;

        Test.startTest();
            UpdateHCPorHCSCertifiedCheckbox_Batch batchJob = new UpdateHCPorHCSCertifiedCheckbox_Batch();
            DataBase.executeBatch(batchJob); 
        Test.stopTest();
        Case updatedCase = [SELECT HCSnotCertified__c FROM Case LIMIT 1];
        System.assertEquals(false, updatedCase.HCSnotCertified__c);
    }
}