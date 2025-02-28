({
    doInit : function(cmp, event, helper) {
        
        cmp.set('v.callListHeaders', [
            {label: 'Task Type', fieldName: 'TaskType', type: 'text', initialWidth:100, sortable:true },
             {label: 'Type of Outbound call', fieldName: 'TypeOfOutboundCall', type: 'text', initialWidth:100, sortable:true },
            {label: 'Status', fieldName: 'status', type: 'text', initialWidth:100, sortable:true },
            {label: 'Task ID', fieldName: 'TaskLink', type: 'url', initialWidth:100, sortable:true,typeAttributes: {label: { fieldName: 'TaskRecId' }, target: '_parent'} },
           
            {label: 'Associated Account Name', fieldName: 'ContactLink', type: 'url', initialWidth:160, sortable:true,typeAttributes: {label: { fieldName: 'RelatedAccount' }, target: '_blank'} },
            {label: 'Program Name', fieldName: 'ProgramName', type: 'text', initialWidth:150, sortable:true },
            {label: 'Task Due Date', fieldName: 'TaskDueDate', type: 'text', initialWidth:135, sortable:true },
           // {label: 'CallScheduledDate', fieldName: 'callScheduledDate', type: 'text', initialWidth:135, sortable:true },
            {label: 'Task Scheduled Time', fieldName: 'callscheduleTime', type: 'text', initialWidth:135, sortable:true },
            {label: 'State', fieldName: 'state', type: 'text', initialWidth:75, sortable:true },
            {label: 'Timezone', fieldName: 'Timezone', type: 'text', initialWidth:100, sortable:true },
            {label: 'Assigned To', fieldName: 'assignedTo', type: 'text', initialWidth:115, sortable:true },
            {label: 'Service', fieldName: 'ServiceLink', type: 'url', initialWidth:100, sortable:true,typeAttributes: {label: { fieldName: 'RelatedServiceName' }, target: '_blank'} },
            {label: 'Associated Service', fieldName: 'RelatedService', type: 'text', initialWidth:100, sortable:true }
            
            
            
        ]);
    },
    
    showCallListResult: function(cmp, event, helper) {
        cmp.set("v.selectedUser",'');
        var params = event.getParam('arguments');
        if (params) {
            cmp.set("v.showAssignToMe",JSON.parse(params.callListFilterwrapper).showAssignToMe);
            cmp.set("v.callListFilterWrapper",JSON.parse(params.callListFilterwrapper));
            cmp.set("v.selectedProject",params.selectedProject);
            cmp.set("v.IsSuperUser",JSON.parse(params.callListFilterwrapper).isSupervisor);
            cmp.set("v.selectedProject",cmp.get("v.callListFilterWrapper").filterWrapperList[0].selectedValue);
            var arr=cmp.get("v.callListFilterWrapper").filterWrapperList[8].filterValues;
            arr.splice(0, 1);
            cmp.set("v.assignUserList",arr);
            
            if(params.isResetValues || params.selectedProject=='None') {
                cmp.set('v.callList', []);
                cmp.set("v.showAssignToMe",false);
                cmp.set("v.selectedProject",'None');
            } else {
                cmp.set("v.loadingContent","Fetching filtered pending Tasks. Please wait..");
                helper.fetchCallList(cmp, event, helper, null, null);
            }
        }
    },
    handlePagination: function(cmp, event, helper) {
        var currentPageValue = event.getParam("currentPageValue");
        helper.buildData(cmp, currentPageValue);
    },
    updateSelectedRows: function(cmp, event, helper) {
        
        var selectedRows = event.getParam("selectedRows");
        var selectedRowIds = [];
        var newSelectedRows = [];
        var infoFlag = false;
        var superUser =cmp.get("v.IsSuperUser");
        if(!superUser){
            for(var x in selectedRows) {
               
                if(((selectedRows[x].ownerId).startsWith("00G") )) {
                    selectedRowIds.push(selectedRows[x].TaskId);
                    newSelectedRows.push(selectedRows[x]);
                } else {
                    infoFlag = true;
                }
                
                cmp.set("v.selectedRowIds",selectedRowIds);
                
                if(newSelectedRows.length >0) {
                    cmp.set("v.disableAssignTo",false);
                } else {
                    cmp.set("v.disableAssignTo",true);
                }
            }
        }else{
            for(var x in selectedRows) {
                selectedRowIds.push(selectedRows[x].TaskId);
                newSelectedRows.push(selectedRows[x]);
            }
            var assigneelist = cmp.get("v.assignUserList");
            
            cmp.set("v.selectedRowIds",selectedRowIds);
            if(newSelectedRows.length > 0 && assigneelist.length > 0) {
                cmp.set("v.disableAssignTo",false);
            } else {
                cmp.set("v.disableAssignTo",true);
            }
        }
        
        cmp.set("v.callsSelected",newSelectedRows);
        if(infoFlag) {
            helper.showToast(cmp, "info", "Only unassigned calls can be selected.",null,"dismissable");
        }
    },
    handleSelectedUsers: function(cmp, event, helper) {
        if(event.getSource().get("v.value") != ''){
            
            cmp.set("v.selectedUser",event.getSource().get("v.value"));
            }
    },
    assignCallsHandler: function(cmp, event, helper) {
        var user=cmp.get("v.selectedUser");
         var superuser = cmp.get("v.IsSuperUser");
        if(superuser){
        if(user == '' ){
            	
                helper.showToast(cmp, "info", "Please select Assignee",null,"dismissable");
        }else{
            if( cmp.get("v.callsSelected").length > 0){
              helper.assignCallsHelper(cmp, event, helper);
            }else{
                  helper.showToast(cmp, "info", "Please select Task",null,"dismissable");
            }
          
        }
        }else{
             if( cmp.get("v.callsSelected").length > 0){
              helper.assignCallsHelper(cmp, event, helper);
              }else{
                  helper.showToast(cmp, "info", "Please select Task",null,"dismissable");
            }
        }
    },
     handleSort : function(component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.loadingContent","Sorting calls. Please wait..");
        helper.fetchCallList(component, event, helper, fieldName, sortDirection);
    },
    
    
})