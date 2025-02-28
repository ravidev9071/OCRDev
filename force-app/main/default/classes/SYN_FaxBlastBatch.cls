/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-24-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class SYN_FaxBlastBatch implements Database.Batchable<sObject> {
    private  String queryString;
    private  String faxTemplate;
    private  static  final string  PENDING = 'Pending';
    private  static  final String  FAX = 'Fax';
    global SYN_FaxBlastBatch(String faxTemplateName){
        faxTemplate = faxTemplateName;
        this.queryString = System.label.Fax_Blast_Query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }
    global  void execute(Database.BatchableContext BC,List<Account>scope){  
        List<REMS_Outbound_Communication__c> communicationRecList = new List<REMS_Outbound_Communication__c>();
       List<Account> accPrescList = new List<Account>();
        
        for(Account acc :Scope){
            string tempSent=acc.SYN_Fax_Blast_Sent__c;
            tempSent=tempSent+';'+faxTemplate;
            acc.SYN_Fax_Blast_Sent__c = tempSent;
            accPrescList.add(acc);
            REMS_Outbound_Communication__c communicationRec = new REMS_Outbound_Communication__c();
            communicationRec.Template__c = faxTemplate;
            communicationRec.Status__c = PENDING;
            communicationRec.Recipient__c = acc.id;
            communicationRec.OBCom_Type__c = FAX;
            communicationRecList.add(communicationRec);
        }
        Database.SaveResult[] results;
        if(communicationRecList!=null && !communicationRecList.isEmpty()){
           results=Database.insert(communicationRecList,false);
        }
        Database.SaveResult[] accResults;
          if(!accPrescList.isEmpty() && results.size() > 0 ){
              for(Integer i=0;i< results.size();i++){
                  if(results[i].isSuccess()){
                  accResults =  Database.update (accPrescList,false);
              } 
              }
          }
    }
    global void finish(Database.BatchableContext BC){
        
    }
    
    
}