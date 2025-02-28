@isTest
public class SYN_RDArejectionReason_Test {
    @testSetup
    static void createTestData()
    {
        List<US_WSREMS__REMS_Program__c > remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);
        Account testAcc1 = SYN_TestDataFactory.createPersonAccountforPatient('5648603245',101,'8987654321',false,remsProgramList[0].Id );
        insert testAcc1;
        Account testAcc2 = SYN_TestDataFactory.createPersonAccountforPrescriberAveed('5648603246', 12345, '8987654321', false, remsProgramList[0].Id);
        insert testAcc2;
    }
    
    @isTest
    static void RDArejectionReasonsTest()
    {
        Account testAcc1 = [Select Id From Account Where US_WSREMS__National_Provider_Identifier__c =: '5648603245'];
        Account testAcc2 = [Select Id From Account Where US_WSREMS__National_Provider_Identifier__c =: '5648603246'];
        case testCase = new case( US_WSREMS__Patient__c = testAcc1.id,US_WSREMS__Prescriber__c = testAcc2.Id, X4_Received_dispense_of_oxybate_product__c = 'Yes',
                                 SYN_Days_Supply__c = 89,
                                 X2_Patient_currently_disenrolled__c = 'Yes', X3_Prescriber_currently_disenrolled__c = 'No',X4b_Days_supply_of_last_dispance__c = 25,
                                 US_WSREMS__Outcome__c = 'Rejected');
        test.startTest();
        SYN_RDArejectionReason.RDArejectionReasons(testCase.id);
        test.stopTest();
    }
}