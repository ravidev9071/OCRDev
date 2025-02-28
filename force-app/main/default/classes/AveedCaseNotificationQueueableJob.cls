public class AveedCaseNotificationQueueableJob implements Queueable{
    List<Case> caseList = new List<Case>();
    public AveedCaseNotificationQueueableJob(List<Case> caseList) {
        this.caseList = caseList;
    }

    public void execute(QueueableContext context) {
        SendEmailNotifications.sendAveedCaseNotificationAsync(caseList);
    }
}