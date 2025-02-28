public with sharing class TryvioQueueable  implements Queueable,Database.AllowsCallouts {
    Set<Id> setPAECaseIds = new Set<Id>();
    public TryvioQueueable(Set<Id> setPAECaseIds) {
        this.setPAECaseIds = setPAECaseIds;
    }

    public void execute(QueueableContext context) {
        SendEmailNotifications.sendEmailForPAEPCReportableFormEventTRYVIO(setPAECaseIds);
    }

}