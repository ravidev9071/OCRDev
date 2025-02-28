public class SYN_Makeacall 
{
    @Auraenabled
    public static makeaCallwrapper  makeacall(String recordId,String sObjectName)
    {
        String phoneno;
        String ProgramTollFreeno;
        String ContactId;
        Set<String> serviceRTset = new Set<String>{'Enrollment','Reenrollment','Knowledge_Assessment','Change_of_Information','Change_Authorized_Representative'};
        makeaCallwrapper wrapper=new makeaCallwrapper(false,'');
        if(!string.isBlank(sObjectName) && sObjectName==SYN_IncontactUtility.TASK && !string.isBlank(recordId))
        {
            Task taskobj =[SELECT Id, whatId,whoId FROM task where id=:recordId  Limit 1];
            if(taskobj!=null && taskobj.whoId !=null)
            {
                Contact acc=[Select id,name,Phone,Account.US_WSREMS__REMS_Program__r.Toll_Free_Number_1__c From Contact where id=:taskobj.whoId  Limit 1];
                US_WSREMS__REMS_Service_Summary__c remsServiceObj = [Select Id,Name,US_WSREMS__REMSProgram__c,US_WSREMS__Participant__c,US_WSREMS__Requestor_Type__c,RecordType.DeveloperName,US_WSREMS__REMSProgram__r.Toll_Free_Number_1__c from US_WSREMS__REMS_Service_Summary__c where Id = :taskobj.WhatId ];
                List<Case> caselist = [Select Id,US_WSREMS__Phone__c,SYN_Prescriber_Phone__c,US_WSREMS__REMS_Program__r.Toll_Free_Number_1__c from Case Where US_WSREMS__REMS_Service_Summary__c = :remsServiceObj.Id];
                if(serviceRTset.Contains(remsServiceObj.RecordType.DeveloperName))
                {
                   if(caselist.size()>0)
                  {
                   //if-else logic to update phone nubmer. 
                   for(Case cs : caselist)
                   {
 					if(remsServiceObj.US_WSREMS__Requestor_Type__c != 'Patient' || 
                      (remsServiceObj.US_WSREMS__Requestor_Type__c == 'Patient'  && remsServiceObj.RecordType.DeveloperName =='Change_of_Information' ))
                    { 
                 			 if(String.isNotBlank(cs.US_WSREMS__Phone__c) ){
                     		   phoneno =cs.US_WSREMS__Phone__c;
                                break; 
                			}else{
                                
                      		wrapper.status_message=System.Label.SYN_Case_Phone_No_Error; 
                            wrapper.status=false;
                                continue;
                					}
                //if-else logic to update Prescriber phone to patient.
                    }
 					if(remsServiceObj.US_WSREMS__Requestor_Type__c == 'Patient' && remsServiceObj.RecordType.DeveloperName !='Change_of_Information')
                    {
 				    if(String.isNotBlank(cs.SYN_Prescriber_Phone__c) ){
                         phoneno =cs.SYN_Prescriber_Phone__c;
                        break;
                    }else{
                      wrapper.status_message=System.Label.SYN_Prescriber_Phone_no_error; 
                            wrapper.status=false;
                        	continue;
                			}
                    }
                  
               } //end of for-each loop
                      //if-else logic to update Toll Free Number.
                   if(String.isNotBlank(remsServiceObj.US_WSREMS__REMSProgram__r.Toll_Free_Number_1__c)){
                      ProgramTollFreeno = remsServiceObj.US_WSREMS__REMSProgram__r.Toll_Free_Number_1__c;
                    }else{
						 wrapper.status_message=System.Label.SYN_Program_no_Toll_err; 
                        wrapper.status=false;                        
                    }
               }else{
                   			wrapper.status_message=System.Label.SYN_No_Case_Found; 
                            wrapper.status=false; 
                	  }      
                }else{
                     if(String.isNotBlank(acc.Phone) ){
                     phoneno =acc.Phone;
                    if(String.isNotBlank(acc.Account.US_WSREMS__REMS_Program__r.Toll_Free_Number_1__c)){
                         ProgramTollFreeno = acc.Account.US_WSREMS__REMS_Program__r.Toll_Free_Number_1__c;
                              
                    }else{
						 wrapper.status_message=System.Label.SYN_Program_no_Toll_err; 
                        wrapper.status=false;                        
                          }
                   }else{
                      wrapper.status_message=System.Label.SYN_Phone_no_error; 
                            wrapper.status=false;
                       }
                }
                
            }else{
                 wrapper.status_message='Participant is not associated to the Task'; 
                wrapper.status=false; 
            }
        }
        else if(sObjectName==SYN_IncontactUtility.REMS_Service)
        {
            US_WSREMS__REMS_Service_Summary__c remsobj = [select id,name,US_WSREMS__Participant__c,US_WSREMS__Participant__r.phone,US_WSREMS__REMSProgram__r.Toll_Free_Number_1__c from 
                                                          US_WSREMS__REMS_Service_Summary__c where id=:recordId Limit 1];
            if(remsobj.US_WSREMS__Participant__c !=null){
                if(!string.isBlank(string.valueOf(remsobj.US_WSREMS__Participant__r.phone)))
                {
                    phoneno = remsobj.US_WSREMS__Participant__r.phone;
                     if(!string.isBlank(remsobj.US_WSREMS__REMSProgram__r.Toll_Free_Number_1__c)){
                                ProgramTollFreeno=remsobj.US_WSREMS__REMSProgram__r.Toll_Free_Number_1__c;
                            }else{
                            wrapper.status_message=System.Label.SYN_Program_no_Toll_err; 
                            wrapper.status=false;
                            }
                }
                else
                {
                    wrapper.status_message=System.Label.SYN_Phone_no_error; 
                    wrapper.status=false;
                } 
            }else{
                wrapper.status_message=System.Label.SYN_Service_without_Participant_err; 
                wrapper.status=false;
            }
            
        }
        else if(sObjectName==SYN_IncontactUtility.Account)
        {
            Account actobj =[Select id,name,phone,US_WSREMS__REMS_Program__r.Toll_Free_Number_1__c from account where id=:recordId Limit 1];
            if(!string.isBlank(actobj.phone))
            {
                phoneno = actobj.phone;
                if(!string.isBlank(actObj.US_WSREMS__REMS_Program__r.Toll_Free_Number_1__c)){
                                ProgramTollFreeno=actObj.US_WSREMS__REMS_Program__r.Toll_Free_Number_1__c;
                            }else{
                            wrapper.status_message=System.Label.SYN_Program_no_Toll_err; 
                            wrapper.status=false;
                            }
            }
            else
            {
                //Please add custom lablel message to display error
                wrapper.status_message=System.Label.SYN_Phone_no_error; 
                wrapper.status=false;
            }
        } 
        if(phoneno !=null && ProgramTollFreeno !=null)
        {
            User u=[SELECT id,InContact_Agent_Id__c,InContact_ProjectSkillno__c from user where id=:UserInfo.getUserId() Limit 1];
            if(String.isNotBlank(u.InContact_Agent_Id__c)  && String.isNotBlank(u.InContact_ProjectSkillno__c) )
            {
                
                String url=SYN_InContactAPIUtility.makeACallURL( phoneno,ProgramTollFreeno);
                Map<String,String> status_map = SYN_InContactAPIUtility.makeFinalCallAPI(url);
                if(status_map.get('StatusCode') == '200')
                {
                    wrapper.status=true;
                    wrapper.ContactId=status_map.get('ContactId');
                    wrapper.Phoneno=phoneno;  
                }
                else
                {
                    //Please add custom lablel message to display error
                    wrapper.status_message='Something went wrong..'+status_map.get('ErrorMessage'); 
                    wrapper.status=false;
                }
                
            }
            else
            {
                wrapper.status_message=System.Label.SYN_AgentId_or_SkillId_err; 
                wrapper.status=false;
            }
            
        }
        else
        {
            if(wrapper.status_message == null || wrapper.status_message == '' )
            {
                wrapper.status_message=System.Label.SYN_Phone_no_error; 
            }
            wrapper.status=false;
        }
        
        
        return wrapper;
        
    }
    
    
    @Auraenabled
    public static SYN_InboundUtility.servicecasewrapper  callServiceCreation(String recordId,String sObjectName,String Contact_Id)
    {
        Id relatedService; // For 654 Story it will contain Parent REMS Service ID
        SYN_InboundUtility.servicecasewrapper wrapper ;
        if(sObjectName==SYN_IncontactUtility.Account)
        {
            wrapper=  SYN_InboundUtility.createREMS_Service(recordId,SYN_IncontactUtility.Outbound_Communication,null,SYN_IncontactUtility.Account,Contact_Id,null);
            
        }
        else 
            if(sObjectName==SYN_IncontactUtility.REMS_Service)
        {
            US_WSREMS__REMS_Service_Summary__c remsobj = [select id,US_WSREMS__Participant__c from 
                                                          US_WSREMS__REMS_Service_Summary__c where id=:recordId Limit 1]; 
            if(remsobj!=null)
            {
                wrapper=  SYN_InboundUtility.createREMS_Service(remsobj.US_WSREMS__Participant__c,SYN_IncontactUtility.Outbound_Communication,recordId,SYN_IncontactUtility.REMS_Service,Contact_Id,remsobj.Id);
            }
            
        }
        else 
            if(sObjectName==SYN_IncontactUtility.TASK)
        {
            Task taskobj =[SELECT Id, whatId,WhoId,AccountId FROM task where id=:recordId  Limit 1];
			
			//Added for 654 Story Parent Service update Added by AshishY wilco
			
			List<Case> remserservice = [Select Id,US_WSREMS__REMS_Service_Summary__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Related_REMS_Services__c from Case where id=:taskobj.whatId Limit 1];
            if(remserservice !=null && remserservice.size()>0){
			If(remserservice[0].US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Related_REMS_Services__c !=NULL){
                
                relatedService = remserservice[0].US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Related_REMS_Services__c;
            }else{
                
                relatedService = remserservice[0].US_WSREMS__REMS_Service_Summary__c;
            }
            }
			//End for 654
			
            if(taskobj!=null)
            {
				// Extra parameter relatedService is added for 654 story
                wrapper=  SYN_InboundUtility.createREMS_Service(taskobj.AccountId,SYN_IncontactUtility.Outbound_Communication,recordId,SYN_IncontactUtility.TASK,Contact_Id,relatedService);
            }
           
        }
        return wrapper;
    }
    
    @Auraenabled
    public static makeaCallwrapper getTaskStatus(String recordId,String sObjectName)
    {
        //makeaCallwrapper wrapper;
        if(sObjectName ==SYN_IncontactUtility.TASK)
        {
            
            Task taskobj =[SELECT Id, whatId,WhoId,US_WSREMS__Outbound_REMS_Service__c FROM task where id=:recordId  Limit 1];
            if(taskobj!=null && taskobj.US_WSREMS__Outbound_REMS_Service__c !=null)
            {
                Case caseObj=[SELECT Id,US_WSREMS__REMS_Service_Summary__c from case where US_WSREMS__REMS_Service_Summary__c=:taskobj.US_WSREMS__Outbound_REMS_Service__c ];
                if(caseObj !=null)
                {
                    return new makeaCallwrapper(false,taskobj.US_WSREMS__Outbound_REMS_Service__c);
                }
                
            }
            
        }
        else if(sObjectName ==SYN_IncontactUtility.REMS_Service)
        {
            US_WSREMS__REMS_Service_Summary__c serviceObj=[SELECT id,Outbound_REMS_Service__c from US_WSREMS__REMS_Service_Summary__c where id=:recordId];
            if(serviceObj!=null && serviceObj.Outbound_REMS_Service__c !=null)
            {
                Case caseObj=[SELECT Id,US_WSREMS__REMS_Service_Summary__c from case where US_WSREMS__REMS_Service_Summary__c=:serviceObj.Outbound_REMS_Service__c ];
                if(caseObj !=null)
                {
                    return new makeaCallwrapper(false,serviceObj.Outbound_REMS_Service__c);
                } 
            }
            
        }
        return new makeaCallwrapper(true,null);  
    }
    
    public class makeaCallwrapper{
        @AuraEnabled public boolean status;
        @AuraEnabled public String record_Id;
        @AuraEnabled public String ContactId;
        @AuraEnabled public String Phoneno;
        @AuraEnabled public string status_message;
        
        public makeaCallwrapper(boolean status, String record_Id){
            this.status = status;
            this.record_Id = record_Id;
            
        }
    }
}