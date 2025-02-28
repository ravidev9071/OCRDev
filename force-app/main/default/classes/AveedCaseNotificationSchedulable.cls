public class AveedCaseNotificationSchedulable implements Schedulable {
    List<Case> caseList = new List<Case>();
    public AveedCaseNotificationSchedulable(List<Case> caseList) {
        this.caseList = caseList;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new AveedCaseNotificationQueueableJob(caseList));
        System.abortJob(sc.getTriggerId());
    }
}