/**
* @Author:       Wilco Source.
* @Description:  Batch class to update the KA expiration status.                 
* @Requirement:  09/27/2022 Story Number 
* @Created Date: 09/27/2022
******************************************************************************
* Modification Log
* 09/27/2022- 
***/
global class SYN_BatchToUpdateKAExpirationStatus implements Database.Batchable<sObject>,  Schedulable{

    private String query;
    private String programName; 
    /**
    * @Author:       Wilco Source.   
    * @Date:         09/27/2022  
    * @Description:  Constructor
    * @pram : Program Name
    * @Return: 
    * @Throws:    
    */
    global SYN_BatchToUpdateKAExpirationStatus(String prgName){
        
        programName = prgName;
        if(SYN_Utilitycls.SOX_PROGRAM_NAME == prgName){
        
            query = query = 'SELECT Id, US_WSREMS__REMS_Program__r.Name, US_WSREMS__Status__c, Sub_Status__c, RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName = \'Pharmacy_Participant\' AND Id IN (SELECT  US_WSREMS__Participant__c FROM US_WSREMS__REMS_Service_Summary__c WHERE  US_WSREMS__Expiration_Date__c = TODAY) AND US_WSREMS__REMS_Program__r.Name = :programName';
        
        }
    }
    
    /**
    * @Author:       Wilco Source.
    * @Date:         09/27/2022  
    * @Description:  Batch start method to query the eligible case to update the status 
    * @pram : BatchableContext
    * @Return:
    * @Throws:
    */
    global Database.QueryLocator start(Database.BatchableContext BC){

        return Database.getQueryLocator(query);

    }
    
    /**
    * @Author:       Wilco Source.
    * @Date:         09/27/2022  
    * @Description:  Execute method will process all the filtered cases and update the corresponding fields to update the account
    * @pram1 : BatchableContext
    * @pram2 : List of Account
    * @Return:
    * @Throws:
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<Account> accsToUpdate = new List<Account>();
        List<Account> accountList = (List<Account>)scope;
        if(SYN_Utilitycls.SOX_PROGRAM_NAME == programName){
        
            for(Account accRec: accountList) {
            
                accRec.US_WSREMS__Status__c = 'Inactive';
                accRec.Sub_Status__c = 'Expired Training';
                accsToUpdate.add(accRec);
            }
        }
        
        if(!accsToUpdate.isEmpty()){

            Database.SaveResult[] saveResultList = Database.update(accsToUpdate, true);
            SYN_Utility.handleDMLErrors('SYN_BatchToUpdateKAExpirationStatus', 'execute', 'Account', 'update', saveResultList);
        }

    }
    
    /**
    * @Author:       Wilco Source.   
    * @Date:         09/27/2022    
    * @Description:  Batch finish method. We don't have any final action for now
    * @pram : BatchableContext
    * @Return: 
    * @Throws:    
    */
    global void finish(Database.BatchableContext BC){

    }
    
    /**
    * @Author:       Wilco Source.   
    * @Date:         09/27/2022    
    * @Description:  Scheduler execute method will schedule the KA expiration status update
    * @pram : SchedulableContext
    * @Return: 
    * @Throws:    
    */
    global void execute( SchedulableContext context ) {

        SYN_BatchToUpdateKAExpirationStatus batchInstance = new SYN_BatchToUpdateKAExpirationStatus(programName);
        database.executeBatch(batchInstance);

    }
}