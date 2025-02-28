public class SYN_BatchToDeleteDupReceivedDoc implements Database.Batchable<sObject>,Database.Stateful {
    
    List<ReceivedDocument> deletedList = new List<ReceivedDocument>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String query ='SELECT Id,Name,Status,Source,SLA_Status__c,CreatedById, CreatedBy.Name, CreatedDate, Fax_Number__c,US_WSREMS__REMS_Service__c,REMS_Program__c,Related_File_Id__c,Program_Name__c,Program_Fax_Number__c, DocumentNumber, Processing_Status__c,Priority,Owner_Name__c,First_Assigned_Date__c,US_WSREMS__Document_Category__c,Assigned_Processing_Time_in_Mins__c,Assigned_Processing_Time__c, (select id from DocumentChecklistItemRD) From ReceivedDocument where (REMS_Program__c = null AND Program_Fax_Number__c = null AND  Fax_Number__c = null AND DocumentNumber = null)';   
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Map<Id,ReceivedDocument> deleteMap = new Map<Id,ReceivedDocument>();
        List<SObject> list_delete = new List<SObject>();
        for(SObject s:scope){
            
            ReceivedDocument rd = (ReceivedDocument) s;
            if(rd.DocumentChecklistItemRD.Size() == 0){
                
                list_delete.add(rd);
                deleteMap.put(rd.Id, rd);
                
            }
        }
        
        if(!list_delete.isEmpty()){
            
            try{  
                
                Database.DeleteResult[] drList = Database.delete(list_delete, false);
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
                        deletedList.add(deleteMap.get(dr.getId()));
                        
                    } else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : dr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            
                        }
                    }
                }
            }Catch(Exception e){
                
            }
        }
        
    }
    public void finish(Database.BatchableContext BC){
        
        if(!deletedList.isEmpty()){
            
            // Creating the CSV file for Duplicate Received document           
            String finalstr = 'Created By, Created Date, Id, Fax Number, Program Fax Number, Owner Name, REMS Program, Program Name, DocumentNumber \n';
            String attName = 'DeletedReceivedDocument' + system.now().format('YYYYMMDDhhmm') + '.csv';
            for(ReceivedDocument rd  : deletedList ){
                
                string recordString = '"'+rd.CreatedBy.Name+'","'+rd.CreatedDate+'","'+rd.id+'","'+rd.Fax_Number__c+'","'+rd.Program_Fax_Number__c+'","'+rd.Owner_Name__c+'","'+rd.REMS_Program__c+'","'+rd.Program_Name__c+'","'+rd.DocumentNumber+'"\n';
                finalstr = finalstr +recordString;
            }
            
           List<Folder> folderList = [SELECT Id, Name From Folder WHERE Name = 'DeletedReceivedDocuments'];
           String docFolderId = folderList[0].Id; //Get Folder Id
           String fileName = attName; //Timestamp for unique file name
           Document doc = new Document();
           doc.Name = fileName;
           doc.Body = Blob.valueOf(finalstr);
           doc.ContentType = 'text/csv';
           doc.Type = 'csv';
           doc.FolderId = docFolderId;
           doc.IsPublic = true;
           Insert doc;
        }       
        
    }
    
}