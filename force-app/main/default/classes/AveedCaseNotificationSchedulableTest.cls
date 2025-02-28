@isTest
private class AveedCaseNotificationSchedulableTest {
    
    @isTest
    private static void aveedCaseNotificationSchedulableTest(){
        List<Case> caseList = new List<Case>();
        Case caseRe = new Case();
        caseRe.Id = SYN_TestDataUtility.getSobjectId(Case.getSObjectType());
        caseList.add(caseRe);
        String cronExp = '0 0 12 1 1 ? *';

        AveedCaseNotificationSchedulable aveedCaseNotificationSchedulableInstance = new AveedCaseNotificationSchedulable(caseList);

        Test.startTest();
            String jobId = System.schedule('aveedCaseNotificationSchedulableTest', cronExp, aveedCaseNotificationSchedulableInstance);
            CronTrigger triggerCron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                        FROM CronTrigger
                                        WHERE Id = :jobId];
            System.assertEquals(cronExp, triggerCron.CronExpression, 'Cron Expressions are equal');
            System.assertEquals(0, triggerCron.TimesTriggered, 'Time triggered is 0');
        Test.stopTest();
    }
}