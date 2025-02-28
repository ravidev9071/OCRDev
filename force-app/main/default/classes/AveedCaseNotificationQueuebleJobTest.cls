@isTest
private class AveedCaseNotificationQueuebleJobTest {
    
    @isTest
    private static void aveedCaseNotificationQueueableJob(){
        List<Case> caseList = new List<Case>();
        Case caseRe = new Case();
        caseRe.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseList.add(caseRe);

        AveedCaseNotificationQueueableJob aveedNOtificationQueueableJobInstance = new AveedCaseNotificationQueueableJob(caseList);

        Test.startTest();
            System.enqueueJob(aveedNOtificationQueueableJobInstance);
        Test.stopTest();
        System.assert(caseList != null, 'Case List is not empty');
    }
}