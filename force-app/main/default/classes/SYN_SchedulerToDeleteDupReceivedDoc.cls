global class SYN_SchedulerToDeleteDupReceivedDoc implements Schedulable {

    global void execute(SchedulableContext SC) {
        
        Database.executeBatch(new SYN_BatchToDeleteDupReceivedDoc());
    }

}