public class XiaflexCaseNotificationQueueableJob implements Queueable {
    List<Case> caseList = new List<Case>();
    String incompleteReaonsString;
    public XiaflexCaseNotificationQueueableJob(List<Case> caseList) {
        this.caseList = caseList;
        this.incompleteReaonsString = incompleteReaonsString;
    }

    public void execute(QueueableContext context) {
        SendEmailNotifications.sendXiaflexCaseNotificationAsync(caseList);
    }

}