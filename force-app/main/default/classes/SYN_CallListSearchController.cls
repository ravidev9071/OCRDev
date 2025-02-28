public  class SYN_CallListSearchController {
    
    public class CallListFilterWrapper {
        @AuraEnabled public Boolean showAssignToMe {get; set;} 
        @AuraEnabled public Boolean isSupervisor {get; set;} 
        @AuraEnabled public Boolean isVeevaNetworkEnabled {get; set;} 
        @AuraEnabled public List<SYN_Utility.FilterWrapper> filterWrapperList {get; set;}
    }
    
    @AuraEnabled 
    public static CallListFilterWrapper getFilters() {
        String profileId = UserInfo.getProfileId();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id =:profileId];
        
        CallListFilterWrapper wrapper = new CallListFilterWrapper();
        wrapper.filterWrapperList = SYN_Utility.getFilters();
        wrapper.showAssignToMe = false;
        if(profile.Name == 'REMS Super User' || profile.Name == 'System Administrator'){
            wrapper.isSupervisor = true;
        }else{
            wrapper.isSupervisor = false;
        }
        wrapper.isVeevaNetworkEnabled = false;
        return wrapper;
    }
    
    @AuraEnabled 
    public static CallListFilterWrapper getInitialFilterValues(CallListFilterWrapper callListFilterwrapper) {
        String userId = UserInfo.getUserId();
        String allowedProfile=System.Label.SYN_ProfileName;
        
        Map<String, String> varibleValues = new Map<String, String>();
        varibleValues.put(':userId','\''+userId+'\'');
        varibleValues.put(':selectedProjectName','\'\'');
        varibleValues.put(':selectedPofileName',allowedProfile);
        varibleValues.put(':timeZoneSet','(\'\')');
        varibleValues.put(':Escalation_queue_name','\''+SYN_Utilitycls.Escalation_queue_name+'\'');
        for(SYN_Utility.filterWrapper wrapper: callListFilterwrapper.filterWrapperList) {
            wrapper = SYN_Utility.getFilterValues(wrapper, varibleValues);
        }
        return getSlectedValuesFromUser(callListFilterwrapper);
    }
    private static CallListFilterWrapper getSlectedValuesFromUser(CallListFilterWrapper callListFilterwrapper) {
        String userId = UserInfo.getUserId();
        
        // Fetching values from user object to pre populate filter values
        for(SYN_Utility.filterWrapper wrapper: callListFilterwrapper.filterWrapperList) {
            if(wrapper.userObjectFieldName != null && wrapper.userObjectFieldName != '') {
                
                if(wrapper.filterName == 'REMS Program') {
                    callListFilterwrapper = handleProjectChange(callListFilterwrapper,'','',false);
                } 
            }
        }
        return callListFilterwrapper;
    }
    
    @AuraEnabled 
    public static CallListFilterWrapper handleProjectChange(CallListFilterWrapper callListFilterwrapper,String projectchanged,string tasktype,boolean filterchange) {
        List<String> displayFiltersOnConsole = SYN_Utility.getDefaultFilters('Call List');
        Map<String, String> varibleValues = new Map<String, String>();
        String selectedProjectName = '';
		List<User> escalation_queueMemebers=[SELECT Id,Name FROM User WHERE Id IN (SELECT UserorGroupId FROM GroupMember WHERE Group.Type = 'Queue' AND (Group.Name =:SYN_Utilitycls.Escalation_queue_name OR Group.Name =:SYN_Utilitycls.Maci_Escalation_queue_name))]; 
        for(SYN_Utility.filterWrapper wrapper: callListFilterwrapper.filterWrapperList) {
            if(!filterchange){
                if(wrapper.filterName == 'REMS Program') {
                    
                    selectedProjectName = wrapper.selectedValue!='All'?wrapper.selectedValue:'';
                    varibleValues.put(':selectedProjectName','\''+selectedProjectName+'\'');
                    if(selectedProjectName != '') {
                        wrapper = SYN_Utility.getFilterValues(wrapper, varibleValues);
                        wrapper.selectedValue = projectchanged;
                    } else {
                        callListFilterwrapper.showAssignToMe = false;
                        callListFilterwrapper.isVeevaNetworkEnabled = false;
                    }
                    
                } else if(wrapper.filterName == 'Time Zone') {
                    
                    wrapper = SYN_Utility.getFilterValues(wrapper, varibleValues);
                    wrapper.selectedValue = '';
                    
                } else if(wrapper.filterName == 'Task Due Date') {
                    
                    varibleValues.put(':userId','\''+UserInfo.getUserId()+'\'');
                    wrapper = SYN_Utility.getFilterValues(wrapper, varibleValues);
                    wrapper.selectedValue = '';
                    
                } else if(wrapper.filterName == 'Task Type') {
                    
                    wrapper = SYN_Utility.getFilterValues(wrapper, varibleValues);
                    wrapper.selectedValue = 'All';
                    
                } else if(wrapper.filterName == 'Include all Scheduled Calls till today'){
                    wrapper.selectedCheckboxValue = false;
                }else if(wrapper.filterName == 'Associated Service'){
                    
                    varibleValues.put(':selectedProjectName','\''+projectchanged+'\'');
                    if(selectedProjectName != '') {
                        wrapper = SYN_Utility.getFilterValues(wrapper, varibleValues);
                        wrapper.selectedValue = '';
                    }
                    
                    
                }else if(wrapper.filterName == 'Assigned To'){
                    
                    varibleValues.put(':selectedProjectName','\''+projectchanged+'\'');
                    
                    String allowedProfile=System.Label.SYN_ProfileName;
                    //List<String> profiles_list = allowedProfile.split(',');
                    varibleValues.put(':selectedPofileName',allowedProfile);
                    wrapper.labelValuePair='US_WSREMS__User__r.Name:US_WSREMS__User__c';
                    wrapper.filterValues.clear();
                    if(selectedProjectName != '') {
                        wrapper = SYN_Utility.getFilterValues(wrapper, varibleValues);
                        wrapper.selectedValue = '';
                    }
                   
                }
                else {
                    wrapper = SYN_Utility.getFilterValues(wrapper, varibleValues);
                    wrapper.selectedValue = '';
                }
                
                wrapper.isVisible = displayFiltersOnConsole.contains(wrapper.filterName);
            }else{
                
                if(wrapper.filterName == 'Assigned To'){
                    if(filterchange && tasktype != 'Escalation'){
                        
                        varibleValues.put(':selectedProjectName','\''+projectchanged+'\'');
                        
                        String allowedProfile=System.Label.SYN_ProfileName;
                        //List<String> profiles_list = allowedProfile.split(',');
                        varibleValues.put(':selectedPofileName',allowedProfile);
                        wrapper.labelValuePair='US_WSREMS__User__r.Name:US_WSREMS__User__c';
                        wrapper.filterValues.clear();
                       
                            wrapper = SYN_Utility.getFilterValues(wrapper, varibleValues);
                            wrapper.selectedValue = '';
                        
                    }else{
                        //List<User> escalation_queueMemebers=[SELECT Id,Name FROM User WHERE Id IN (SELECT UserorGroupId FROM GroupMember WHERE Group.Type = 'Queue' AND (Group.Name =:SYN_Utilitycls.Escalation_queue_name OR Group.Name =:SYN_Utilitycls.Maci_Escalation_queue_name))]; 
                        wrapper.labelValuePair='Name:Id';
                        wrapper.filterValues.clear();
                        wrapper = SYN_Utility.getEscalationQueueMemebers(wrapper,escalation_queueMemebers);
                        wrapper.selectedValue = '';
                    }
                }
            }
        }
        return callListFilterwrapper;
    }
    
    @AuraEnabled 
    public static List<CallListWrapper> fetchFilteredCallList(CallListFilterWrapper callListFilterwrapper, String sortingField, String sortingDirection) {   
        List<CallListWrapper> callListWrapper=new List<CallListWrapper>(); 
        if(sortingField != null && sortingDirection != null) {
            Map<String,String> fieldMap = new Map<String,String>{
                'TaskType' => 'Type',
                'TypeOfOutboundCall' => 'Type_of_Outbound_Call__c',
                'status' => 'status',
                'TaskLink' => 'Task_ID__c',
                'ContactLink' => 'Who.Name',
                'ProgramName' => 'Program_Name__r.Name',
                'TaskDueDate' => 'ActivityDate',
                'callscheduleTime' => 'Schedule_call_time__c',
                'state' => 'State__c',
                'Timezone' => 'Time_Zone__c',
                'assignedTo' => 'ownerName__c',
                'ServiceLink' => 'What.Name',
                'RelatedService' => 'What.RecordType.Name'
                };
                    String SortingFieldString;
            if(sortingField =='TaskDueDate' || sortingField =='callscheduleTime'){
                SortingFieldString ='ActivityDate '+sortingDirection+' , Schedule_call_time__c';
            }else{
                SortingFieldString = fieldMap.get(sortingField);
            }
            callListWrapper=fetchSortingFilteredCallList( callListFilterwrapper,SortingFieldString ,  sortingDirection);
        }else{
            
            boolean task_type=true;
          //  boolean queue_status=true;
            String call='Call';
            String queueName;
            Map<Id,US_WSREMS__REMS_Program__c> programList=new Map<Id,US_WSREMS__REMS_Program__c>([Select id,QueueName__c from US_WSREMS__REMS_Program__c where US_WSREMS__Status__c='Active']);
			String Query ='SELECT Id,Task_ID__c,Subject,Type_of_Outbound_Call__c,Schedule_call_time__c,Related_to_Account__c,Related_to_Account__r.Name,ownerName__c,ActivityDate,Program_Name__c,Program_Name__r.Name,Call_Scheduled_Time__c,State__c,Time_Zone__c,WhatId,OwnerId,Who.Name,WhoId,What.RecordType.Name,What.Name,Type,Status from Task where  Program_Name__c !=null  ';
            for(SYN_Utility.FilterWrapper filterWrapper :callListFilterWrapper.filterWrapperList) {
                
                
                if(filterWrapper.filterType == 'Picklist'){
                    if(filterWrapper.selectedValue != null && filterWrapper.selectedValue != '' && filterWrapper.selectedValue != 'All') {
                        
                        if(filterWrapper.fieldType == 'String') {
                            if(filterWrapper.query !=null){
                                if(filterWrapper.fieldName == 'Program_Name__c'){
                                    //List<US_WSREMS__REMS_Program__c> programList=[Select id,QueueName__c from US_WSREMS__REMS_Program__c where id=:filterWrapper.selectedValue];
                                    queueName=programList.get(filterWrapper.selectedValue).QueueName__c;
                                }
                                query+=' AND '+filterWrapper.fieldName+ ' = \'' + filterWrapper.selectedValue + '\'';
                                
                            } 
                            
                            else{
                                if(filterWrapper.fieldName !=null){
                                    if(filterWrapper.selectedValue =='None'){
                                        filterWrapper.selectedValue='';
                                    }
                                    if(filterWrapper.fieldName == 'Type_of_Outbound_Call__c' && filterWrapper.selectedValue == 'Escalation' ){
                                        task_type=false;
                                        
                                    }else{
                                        
                                        query += ' AND ' + filterWrapper.fieldName + ' = \'' + filterWrapper.selectedValue + '\'';
                                    }    
                                    
                                }else if(filterWrapper.fieldName =='' || filterWrapper.fieldName ==null){
                                    if( filterWrapper.selectedValue == 'UserInfo.getUserId()' ){
                                        String userId=UserInfo.getUserId();
                                        query+=' AND '+'ownerId ' + ' = \'' + userId + '\'';
                                        
                                    }else{
                                            String queue_Name='Queue';
                                            query+=' AND '+ ' Owner.Type = \''+queue_Name + '\''; 
                                    }
                                } 
                            }
                            
                        }  
                    }
                }else if(filterWrapper.fieldType == 'Date' ){
                    if(filterWrapper.selectedValue != null  && filterWrapper.selectedValue != '' ){
                        query+=' AND '+' ActivityDate '+ ' = ' + filterWrapper.selectedValue ;
                    }
                }
                
                
            }
            	if(task_type){
                query+=' AND Type =:'+call;
            	}else{
                string escalation_str='Escalation';
                query+=' AND Type '+ ' = \''+escalation_str+'\'';  
           	    }
           
            query+=' Order By ActivityDate ASC ,Schedule_call_time__c ASC';
            List<Task> task_list =Database.query(query);
            
            for(Task taskrec:task_list){
                CallListWrapper cw=new CallListWrapper();
                cw.TaskRecId=taskrec.Task_ID__c;
                cw.TaskId =taskrec.Id;
                cw.TaskType=taskrec.Type;
                cw.TypeOfOutboundCall=taskrec.Type_of_Outbound_Call__c;
                cw.RelatedAccount=taskrec.Who.Name;
                cw.RelatedAccountId=taskrec.WhoId;
                cw.RelatedServiceId=taskrec.WhatId;
                cw.RelatedServiceName =taskrec.What.Name;
                cw.ProgramName=taskrec.Program_Name__r.Name;
                cw.Timezone=taskrec.Time_Zone__c;
                if(taskrec.ActivityDate !=null){
                    Date dtDate =taskrec.ActivityDate;
                    Datetime dtTodayDateTime = datetime.newInstance(dtDate.year(), dtDate.month(),dtDate.day());
                    
                    cw.TaskDueDate = dtTodayDateTime.format('MM/dd/yyyy');
                }
                if(taskrec.Schedule_call_time__c !=null){
                    Time t=taskrec.Schedule_call_time__c;
                    Datetime myDateTime = Datetime.newInstance(Date.today(), t);
                    cw.callscheduleTime = myDateTime.format('h:mm a');
                }
                cw.status=taskrec.status;
                cw.assignedTo=taskrec.ownerName__c;
                cw.ownerId=taskrec.OwnerId;
                cw.RelatedService=taskrec.What.RecordType.Name;
                cw.state=taskrec.State__c;
                callListWrapper.add(cw);
            }
        }
        return callListWrapper;
    }
    
    @AuraEnabled 
    public static List<CallListWrapper> fetchSortingFilteredCallList(CallListFilterWrapper callListFilterwrapper, String sortingField, String sortingDirection) {
        boolean task_type=true;
        String call='Call';
        String queueName;
		Map<Id,US_WSREMS__REMS_Program__c> programList=new Map<Id,US_WSREMS__REMS_Program__c>([Select id,QueueName__c from US_WSREMS__REMS_Program__c where US_WSREMS__Status__c='Active']);
        String Query ='SELECT Id,Task_ID__c,Subject,Type_of_Outbound_Call__c,Schedule_call_time__c,Related_to_Account__c,Related_to_Account__r.Name,ownerName__c,ActivityDate,Program_Name__c,Program_Name__r.Name,Call_Scheduled_Time__c,State__c,Time_Zone__c,WhatId,OwnerId,Who.Name,WhoId,What.RecordType.Name,What.Name,Type,Status from Task where  Program_Name__c !=null  ';
        for(SYN_Utility.FilterWrapper filterWrapper :callListFilterWrapper.filterWrapperList) {
            if(filterWrapper.filterType == 'Picklist'){
                if(filterWrapper.selectedValue != null && filterWrapper.selectedValue != '' && filterWrapper.selectedValue != 'All') {
                    
                    if(filterWrapper.fieldType == 'String') {
                        if(filterWrapper.query !=null){
                            if(filterWrapper.fieldName == 'Program_Name__c'){
                                //List<US_WSREMS__REMS_Program__c> programList=[Select id,QueueName__c from US_WSREMS__REMS_Program__c where id=:filterWrapper.selectedValue];
                                queueName=programList.get(filterWrapper.selectedValue).QueueName__c;
                            }
                            query+=' AND '+filterWrapper.fieldName+ ' = \'' + filterWrapper.selectedValue + '\'';
                            
                        }else{
                            if(filterWrapper.fieldName !=null){
                                if(filterWrapper.selectedValue =='None'){
                                    filterWrapper.selectedValue='';
                                }
                                if(filterWrapper.fieldName == 'Type_of_Outbound_Call__c' && filterWrapper.selectedValue == 'Escalation' ){
                                    task_type=false;
                                    
                                }else{
                                    
                                    query += ' AND ' + filterWrapper.fieldName + ' = \'' + filterWrapper.selectedValue + '\'';
                                } 
                            }else if(filterWrapper.fieldName =='' || filterWrapper.fieldName ==null){
                                if( filterWrapper.selectedValue == 'UserInfo.getUserId()' ){
                                    String userId=UserInfo.getUserId();
                                    query+=' AND '+'ownerId ' + ' = \'' + userId + '\'';
                                    
                                }else{
                                   
                                        String queue_Name='Queue';
                                        query+=' AND '+ ' Owner.Type = \''+queue_Name + '\'';  
                                    
                                }
                            } 
                        }
                        
                    }  
                }
            }else if(filterWrapper.fieldType == 'Date' ){
                if(filterWrapper.selectedValue != null  && filterWrapper.selectedValue != '' ){
                    query+=' AND '+' ActivityDate '+ ' = ' + filterWrapper.selectedValue ;
                }
            }
            
            
        }
        if(task_type){
            query+=' AND Type =:'+call;
        }else{
            string escalation_str='Escalation';
            query+=' AND Type '+ ' = \''+escalation_str+'\'';  
        }
        query+=' Order By '+sortingField+' '+sortingDirection ;
        List<Task> task_list =Database.query(query);
        List<CallListWrapper> callListWrapper=new List<CallListWrapper>();
        
        for(Task taskrec:task_list){
            CallListWrapper cw=new CallListWrapper();
            cw.TaskRecId=taskrec.Task_ID__c;
            cw.TaskId =taskrec.Id;
            cw.TaskType=taskrec.Type;
            cw.TypeOfOutboundCall=taskrec.Type_of_Outbound_Call__c;
            cw.RelatedAccount=taskrec.Who.Name;
            cw.RelatedAccountId=taskrec.WhoId;
            cw.RelatedServiceId=taskrec.WhatId;
            cw.RelatedServiceName =taskrec.What.Name;
            cw.ProgramName=taskrec.Program_Name__r.Name;
            cw.Timezone=taskrec.Time_Zone__c;
            if(taskrec.ActivityDate !=null){
                Date dtDate =taskrec.ActivityDate;
                Datetime dtTodayDateTime = datetime.newInstance(dtDate.year(), dtDate.month(),dtDate.day());
                
                cw.TaskDueDate = dtTodayDateTime.format('MM/dd/yyyy');
            }
            if(taskrec.Schedule_call_time__c !=null){
                Time t=taskrec.Schedule_call_time__c;
                Datetime myDateTime = Datetime.newInstance(Date.today(), t);
                cw.callscheduleTime = myDateTime.format('h:mm a');
            }
            cw.status=taskrec.status;
            cw.assignedTo=taskrec.ownerName__c;
            cw.ownerId=taskrec.OwnerId;
            cw.RelatedService=taskrec.What.RecordType.Name;
            cw.state=taskrec.State__c;
            callListWrapper.add(cw);
        }
        return callListWrapper;
    }
    public static String formatDate(DateTime d) {
        
        return d.format('MM/dd/yyyy'); 
    }
    @AuraEnabled 
    public static Map<String, Object> assignCallsToMe(List<CallListWrapper> selectedCallsList,CallListFilterWrapper callListFilterwrapper ,String userId) {
        
        Map<String, Object> messageAndCallListMap = new Map<String, Object>();
        
        List<Task> listToUpdate = new List<Task>();
        Set<Id> callListIds = new Set<Id>();
        for(CallListWrapper wrapper: selectedCallsList) {
            callListIds.add(wrapper.TaskId);
        }
        for(Task record: [SELECT Id, ownerId FROM Task WHERE Id IN :callListIds]) {
            if(userId !=null && userId !=''){
                record.ownerId = userId;
            }else{
                record.ownerId = UserInfo.getUserId();
            }
            listToUpdate.add(record);
            
        }
        
        update listToUpdate;
        messageAndCallListMap.put('messageType', 'success');
        messageAndCallListMap.put('messageTitle', 'Success');
        messageAndCallListMap.put('message', 'Selected calls are successfully assigned.');
        messageAndCallListMap.put('list', fetchFilteredCallList(callListFilterwrapper, null, null));
        
        
        
        return messageAndCallListMap;
    }
    
    
    /* @AuraEnabled 
public static List<CallListWrapper> fetchUserforProgram(String ProgramName) {
}*/
    public class CallListWrapper {
        @AuraEnabled public String TaskRecId {get; set;}
        @AuraEnabled public String TaskId {get; set;}
        @AuraEnabled public String TypeOfOutboundCall {get; set;}
        @AuraEnabled public String TaskType {get; set;}
        @AuraEnabled public String TaskDueDate {get; set;}
        @AuraEnabled public String RelatedAccount {get; set;}
        @AuraEnabled public String RelatedAccountId {get; set;}
        @AuraEnabled public String ProgramName {get; set;}
        @AuraEnabled public String Timezone {get; set;}
        @AuraEnabled public String callScheduledDate {get; set;}
        @AuraEnabled public String callscheduleTime {get;set;}
        @AuraEnabled public String assignedTo {get; set;}
        @AuraEnabled public String ownerId {get; set;}
        @AuraEnabled public String RelatedService {get; set;}
        @AuraEnabled public String RelatedServiceName {get; set;}
        @AuraEnabled public String RelatedServiceId {get; set;}
        @AuraEnabled public String callAssignedTo {get; set;}
        @AuraEnabled public String state {get; set;}
        @AuraEnabled public String status {get; set;}   
        @AuraEnabled public String status_message {get; set;}  
        
    }
    
}