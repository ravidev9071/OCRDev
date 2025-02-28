public class SYN_InboundUtility {
    
    public static servicecasewrapper createREMS_Service(String accountRecordId,String Type,String TaskId,String ObjectType,String ContactId, Id serviceId){
         servicecasewrapper ser;
         String caseId=null;
       Id recordTypeIdService= Schema.Sobjecttype.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get(Type).getRecordTypeId();
         Account actobj =[Select id,name,phone,US_WSREMS__REMS_Program__c,RecordType.name,FirstName,LastName from account where id=:accountRecordId Limit 1];
        US_WSREMS__REMS_Service_Summary__c servicerecord=new US_WSREMS__REMS_Service_Summary__c();
        servicerecord.US_WSREMS__REMSProgram__c=actobj.US_WSREMS__REMS_Program__c;
        servicerecord.US_WSREMS__Requestor_Type__c=actobj.RecordType.name;
        servicerecord.RecordTypeId=recordTypeIdService;
        servicerecord.US_WSREMS__Participant__c=accountRecordId;
		servicerecord.US_WSREMS__Related_REMS_Services__c=serviceId; //added for 654 by AshishY Wilco
        Database.SaveResult[] saveResult=Database.insert(new List<US_WSREMS__REMS_Service_Summary__c>{servicerecord},false);
        
    if (saveResult[0].isSuccess()) 
    {
        // Operation was successful, so get the ID of the record that was processed
        if(TaskId !=null && ObjectType ==SYN_IncontactUtility.Task )
        {
            Task t=new Task();
            t.id=TaskId;
           t.US_WSREMS__Outbound_REMS_Service__c =saveResult[0].getId();
            update t;
        }
        else if(TaskId !=null && ObjectType ==SYN_IncontactUtility.REMS_Service)
        {
            US_WSREMS__REMS_Service_Summary__c service=new US_WSREMS__REMS_Service_Summary__c();
            service.id=TaskId;
            service.Outbound_REMS_Service__c=saveResult[0].getId();
            update service;
        }
        if(Type == SYN_IncontactUtility.Outbound_Communication)
        {
            caseId= createCaseRecord(saveResult[0].getId(),actobj.Id,'Outbound_Call',ContactId);
        }
        else
        {
           caseId= createCaseRecord(saveResult[0].getId(),actobj.Id,'Inbound_Call',ContactId);  
        }
        if(caseId.contains('Error'))
        {
            ser =new servicecasewrapper('','');
            ser.status=false;
             ser.status_message=caseId;
        }
        else
        {
            ser =new servicecasewrapper(saveResult[0].getId(),caseId);
            ser.status=true;
        }
         
    }
    else 
    {
        // Operation failed, so get all errors                
        for(Database.Error err : saveResult[0].getErrors()) 
        { 
             ser =new servicecasewrapper('','');
            ser.status=false;
            ser.status_message=err.getStatusCode() + ': ' + err.getMessage();
            System.debug('The following error has occurred.');                    
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Account fields that affected this error: ' + err.getFields());
        }
    }
        return ser;
    }
        
    
    public static String createCaseRecord(Id ServiceId,Id accountRec,String Type,String contact_Id)
    {
         Account actobj =[Select id,name,phone,US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Program__r.Name,RecordType.name,FirstName,LastName from account where id=:accountRec Limit 1];
         Id recordTypeIdcase= Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get(Type).getRecordTypeId();
        Case caseObj=new Case();
        caseObj.RecordTypeId=recordTypeIdcase;
        caseObj.US_WSREMS__Participant__c=actobj.Id;
        caseObj.US_WSREMS__REMS_Program__c=actobj.US_WSREMS__REMS_Program__c;
          if(picklistcontains(actobj.US_WSREMS__REMS_Program__r.Name)){
           caseObj.US_WSREMS__Program_Picklist__c =actobj.US_WSREMS__REMS_Program__r.Name;
        }
        caseObj.US_WSREMS__Same_as_Account__c=true;
        caseObj.US_WSREMS__REMS_Service_Summary__c=ServiceId;
        //caseObj.US_WSREMS__Call_Notes__c='InContact '+Type +'ContactId is '+contact_Id;
         caseObj.inContact_Contact_ID__c=contact_Id;
         Database.SaveResult[] saveResult=Database.insert(new List<Case>{caseObj},false);
          if (saveResult[0].isSuccess()) 
          {
               return caseObj.Id+'';
          }
          else
          {
              for(Database.Error err : saveResult[0].getErrors()) 
              { 
            
           // ser.status_message=err.getStatusCode() + ': ' + err.getMessage();
            System.debug('The following error has occurred.');                    
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Account fields that affected this error: ' + err.getFields());
                   return 'Error:'+err.getMessage();
                }
                return 'Error';     
          }
        
        
       
        
    }
    
      public static Boolean picklistcontains(String title)
	{
        Schema.DescribeFieldResult fieldResult = Case.US_WSREMS__Program_Picklist__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry t : ple)
    {
        if (t.getValue().equals(title))
        {
            return true;
        }
    }

    return false;
}
     public class servicecasewrapper{
          @AuraEnabled public boolean status;
        @AuraEnabled public String ServiceId;
        @AuraEnabled public String CaseId;
         @AuraEnabled public string status_message;
        public servicecasewrapper(String ServiceId, String CaseId){
            this.ServiceId = ServiceId;
            this.CaseId = CaseId;
            //this.programId = programId;
        }
    }
}