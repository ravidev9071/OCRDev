public class SendHCSRecertificationFaxReminderJob implements Database.Batchable<sObject>, Schedulable{
    public Static Id hcsAccountRecordType = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Health_Care_Setting');
    public Database.QueryLocator start(Database.BatchableContext bc){
        String participantStatus ='Certified';
        String programName = SYN_Utilitycls.AVEED_PROGRAM_NAME;
        String xiaflex = SYN_Utilitycls.XIAFLEX_PROGRAM_NAME;
        List<string> programList = new List<string>();
        programList.add(programName);
        programList.add(xiaflex);
        Date currentDate = System.today();
        return Database.getQueryLocator([SELECT Id, US_WSREMS__Program_Picklist__c, US_WSREMS__Preferred_Contact_Method__c, US_WSREMS__ReCertification_Reminder_Date__c, US_WSREMS__ReCertification_Agent_Task_Date__c, US_WSREMS__VerificationReminderDate__c, US_WSREMS__VerificationAgentTaskDate__c,
            US_WSREMS__Authorized_Representative__r.Fax, US_WSREMS__Authorized_Representative__r.US_WSREMS__Email__c, US_WSREMS__Program_Type__c
            FROM Account 
            WHERE US_WSREMS__Program_Picklist__c IN: programList
            AND US_WSREMS__Status__c =:participantStatus
            AND RecordTypeId =:hcsAccountRecordType
            AND (DAY_ONLY(US_WSREMS__ReCertification_Reminder_Date__c) =: currentDate
                OR DAY_ONLY(US_WSREMS__ReCertification_Agent_Task_Date__c) =: currentDate
                OR DAY_ONLY(US_WSREMS__VerificationReminderDate__c) =: currentDate
                OR DAY_ONLY(US_WSREMS__VerificationAgentTaskDate__c) =: currentDate
            )
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Account> accountList){
        CreateHCSRecertyFaxCommunication.createHCSRecertificationFaxCommunicationRec(accountList);
    }

    public void execute(SchedulableContext sc){
        Database.executeBatch(new SendHCSRecertificationFaxReminderJob());
    }

    public void finish(Database.BatchableContext bc){
    }
}