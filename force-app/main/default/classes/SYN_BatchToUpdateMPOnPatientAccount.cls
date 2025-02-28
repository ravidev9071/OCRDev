/*
* @File Name          : SYN_BatchToUpdateMPOnPatientAccount.cls
* @Description        : This is a test class for the batch class(SYN_BatchToUpdateMPOnPatientAccount) that will collect all the monthly pregnancy test records data that exceeds 30 days or 
                        counseling records that are equals 31 days and updates them.
* @Author             : Thandavakrishna Dindu
*/


global class SYN_BatchToUpdateMPOnPatientAccount implements Database.Batchable<sObject>
{ 
    private String queryString;
    
    Public SYN_BatchToUpdateMPOnPatientAccount(){
     this.queryString  = 'SELECT Id, Counseling_Completion_Calc__c, Monthly_Pregnancy_Calc__c,Counseling_Recorded__c,Monthly_Pregnancy_Test_Recorded__c FROM Account WHERE ((Monthly_Pregnancy_Calc__c = true AND Monthly_Pregnancy_Test_Recorded__c= \'Yes\') OR (Counseling_Completion_Calc__c = true AND Counseling_Recorded__c = true)) AND Program_Name__c =  \'Macitentan REMS\'';
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {  
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        List<Account> accountListToUpdate = new List<Account>();
        for(Account acc: scope){
                //Counselling And Pregnancy Record Check
                if(acc.Counseling_Completion_Calc__c == true && acc.Monthly_Pregnancy_Calc__c == true){
                    acc.Counseling_Recorded__c = false;
                    acc.Monthly_Pregnancy_Test_Recorded__c = '';
                    accountListToUpdate.add(acc);
                }else if(acc.Counseling_Completion_Calc__c == true){
                    acc.Counseling_Recorded__c = false;
                    accountListToUpdate.add(acc);
                }else if(acc.Monthly_Pregnancy_Calc__c == true){
                    acc.Monthly_Pregnancy_Test_Recorded__c = '';
                    accountListToUpdate.add(acc);
                }    
        }
        if(!accountListToUpdate.isEmpty()){
            database.update(accountListToUpdate,false);
        }
    }    
    global void finish(Database.BatchableContext BC)
    {
    }
}