/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-28-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest(SeeAllData=true)
Private class SYN_FailedApexJobEmailBatch_Test implements Database.Batchable<SObject> {
    
      public Database.QueryLocator start(Database.BatchableContext BC){
            string query = 'select id,fax from account limit 1';
            return Database.getQueryLocator(query);
    }
    public  void execute(Database.BatchableContext BC,List<Account>scope){ 
        List<Account> accList= new List<Account>();
        for(Account acc:scope){
            if(acc.fax != null){
                acc.fax='4855829649';
                accList.add(acc);
                
            }
            
                    }
        if(accList!=null && !accList.isEmpty()){
            Update accList;
        }
        
        
    }
    public void finish(Database.BatchableContext BC){
        
    }
    @isTest
    static void testBatchExecution(){
        
         //SYN_FailedApexJobEmailBatch_Test batchJob1= new SYN_FailedApexJobEmailBatch_Test();
        //Database.executeBatch(batchJob1);
        Test.startTest();
         SYN_FailedApexJobEmailBatch batchJob= new SYN_FailedApexJobEmailBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();
    } 
    
    
     }