/**
 * @description       : Send fax notifications 
 * @author            : Aneesha
 * @group             : 
 * @last modified on  : 20-11-2024
 * @last modified by  : Utthirakumar
**/
global class REMSOutboundCommunicationsBatch implements Database.Batchable<sObject>,  Schedulable {
    private String query;
   // private String status;
    global REMSOutboundCommunicationsBatch(){
       
        
    }

    /*
    *********************************************************
    @Method Name    : start
    @author         : Aneesha
    @description    : method used to fetch pending outbound communication to process
    @param          : 
    @return         : QueryLocator
    ********************************************************
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        String status='Pending';
        query = 'SELECT Id,Case__c,OBCom_Type__c,Recipient__c,REMS_Service__c,Status__c,Template__c,Recipient__r.RecordType.DeveloperName, Recipient__r.US_WSREMS__REMS_Program__r.Name FROM REMS_Outbound_Communication__c WHERE Status__c = :status ';
        return Database.getQueryLocator(query);
        
    }
    
    /*
    *********************************************************
    @Method Name    : execute
    @author         : Aneesha
    @description    : method used to process pending outbound communication to send
    @param          : scope - pending outbound communication records
    @return         : void
    ********************************************************
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if(scope !=null && (!scope.isEmpty())){
        SYN_SOXCorrespondenceHandler.getCaseDetailstoSendEmail(scope);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    /*
    *********************************************************
    @Method Name    : execute
    @author         : Aneesha
    @description    : method used to schedule the batch process
    @param          : context - schedulablecontext
    @return         : void
    ********************************************************
    */
    global void execute( SchedulableContext context ) {
        Database.executeBatch(new REMSOutboundCommunicationsBatch() , 1);
        
    }
    
}