@isTest
private class AssessmentSubmissionTriggerTests {
    
    @IsTest
    private static void filterCasesByPrgmTest() {
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'AVEED REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;

        case caseRec = new case();
        caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Prescriber_enrollment';
        caseRec.US_WSREMS__REMS_Program__c = programObj.Id;
        caseRec.US_WSREMS__REMS_Program__r = programObj;
        caseRec.Status = 'Draft';
        caseRec.US_WSREMS__First_Name__c = 'test';
        caseRec.US_WSREMS__Last_Name__c = 'test';
        caseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        caseRec.US_WSREMS__Program_Picklist__c = programObj.Name;
        caseRec.US_WSREMS__Email__c = 'test@test.com';
        caseRec.US_WSREMS__Fax__c = '7653216217';
        insert caseRec;

        US_WSREMS__Assessment__c  assessment = new US_WSREMS__Assessment__c();
        assessment.US_WSREMS__REMS_Program__r = programObj;
        assessment.US_WSREMS__REMS_Program__c = programObj.Id;
        assessment.US_WSREMS__Participant_Type__c='Prescriber';
        assessment.US_WSREMS__Pass_Percentage__c=100;
        assessment.US_WSREMS__Show_Wrong_Answers_Only__c=true;
        assessment.name='Knowledge Assessment';
        insert assessment;

        Exception e;
        Test.startTest();
                US_WSREMS__Assessment_Submission__c KA = new US_WSREMS__Assessment_Submission__c();
                KA.US_WSREMS__Case__r = caseRec;
                KA.US_WSREMS__Case__c = caseRec.Id;
                KA.US_WSREMS__Assessment_Result__c = 'Failed';
                KA.US_WSREMS__Total_Number_of_Attempts__c = 2;
                KA.US_WSREMS__Assessment__c= assessment.Id;
                insert KA;

                US_WSREMS__Assessment_Submission__c newKA = new US_WSREMS__Assessment_Submission__c();
                newKA.Id = KA.Id;
                newKA.US_WSREMS__Assessment_Result__c = 'Passed';
                Update newKA;
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(0, invocations); 
    }
}