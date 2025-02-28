/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-28-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class SYN_FailedApexJobEmailBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    @TestVisible private String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Query AsyncApexJob to Find Failed Jobs

          query = System.label.SYN_FailedApexBatchJobQuery;
          if(test.isRunningTest()){
    			query += ' LIMIT 5';
			}
            return Database.getQueryLocator(query);
    }
    global  void execute(Database.BatchableContext BC,List<AsyncApexJob>scope){ 
         system.debug('size'+scope.size());
        string emailBody = 'the following Apex jobs have Failed:\n\n';
        @TestVisible List<US_WSREMS__Custom_Error_Log__c> apexJobErrors= new List<US_WSREMS__Custom_Error_Log__c>();
        for(AsyncApexJob job:scope){ 
            US_WSREMS__Custom_Error_Log__c customErrorLogs = new US_WSREMS__Custom_Error_Log__c();
            customErrorLogs.US_WSREMS__Exception_Type__c = job.Status;
            customErrorLogs.US_WSREMS_Apex_Class__c=job.ApexClass.Name;
            customErrorLogs.US_WSREMS_Job_Type__c=job.jobType;
            customErrorLogs.US_WSREMS__Exception_Message__c = job.ExtendedStatus;
            apexJobErrors.add(customErrorLogs);

            emailBody+='job ID: '+job.Id +'\n';
            emailBody+='job type: '+job.jobType +'\n';
            emailBody+='Apex Class: '+job.ApexClass.Name +'\n';
            emailBody+='Status: '+job.Status +'\n';
             emailBody+='createdDate: '+job.createdDate +'\n';
            emailBody+='ExtendedStatus: '+job.ExtendedStatus +'\n\n';
        }
       if(apexJobErrors!=null && !apexJobErrors.isEmpty()){
            insert apexJobErrors;
        } 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String>  toAddresses = label.FailedJobNotificationEmailList.Split(',');//replace with admins email address.
                mail.setToAddresses(toAddresses);
                mail.setSubject('alert:All jobs failed');
                mail.setPlaintextBody(emailBody);
            //send Email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        
    }
    global void finish(Database.BatchableContext BC){
        //
    }
}