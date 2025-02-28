public class XiaflexCaseNotificationSchedulable implements Schedulable {
    List<Case> caseList = new List<Case>();
    String incompleteReaonsString;
    public XiaflexCaseNotificationSchedulable(List<Case> caseList) {
        this.caseList = caseList;
        this.incompleteReaonsString = incompleteReaonsString;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new XiaflexCaseNotificationQueueableJob(caseList));
        System.abortJob(sc.getTriggerId());
    }

}