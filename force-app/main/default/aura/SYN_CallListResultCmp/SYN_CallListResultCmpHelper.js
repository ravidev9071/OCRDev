({
    fetchCallList: function(cmp, event, helper, sortingField, sortingDirection) {
        var action = cmp.get('c.fetchFilteredCallList');
        action.setParams({ callListFilterwrapper: cmp.get("v.callListFilterWrapper"),
                          sortingField: sortingField ,
                          sortingDirection: sortingDirection });
        helper.startSpinner(cmp, true, "callListSpinner");
        action.setCallback(this, function(response) {
            helper.stopSpinner(cmp, true, "callListSpinner");
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                cmp.set('v.callListToBeShown', []);
                if(res.length > 0) {
                    res.forEach(function(record){
                        
                        if(record.TaskRecId != '' && record.TaskRecId != null){
                            record.TaskLink = '/'+record.TaskId;
                        }
                        if(record.RelatedServiceId != '' && record.RelatedServiceId != null){
                            record.ServiceLink='/'+record.RelatedServiceId;
                        }
                        if(record.RelatedAccountId != '' && record.RelatedAccountId != null){
                            record.ContactLink='/'+record.RelatedAccountId;
                        }
                        
                        
                    });
                    cmp.set('v.callList', res);
                    cmp.set('v.noCallsFound',false);
                    helper.buildData(cmp, 1);
                    var paginationCmp = cmp.find("cPagination");
                    paginationCmp.RefreshPagination();
                    var dataTable = cmp.find("callListTable");	
                    dataTable.set("v.sortedBy", sortingField);	
                    dataTable.set("v.sortedDirection", sortingDirection);
                } else {
                    cmp.set('v.callList', []);
                    cmp.set('v.noCallsFound',true);
                }
            } else if (state === "ERROR") {
                helper.showToast(cmp, "error", "Server Error!!", "Something went wrong.",null,"dismissable");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    buildData:  function(cmp, pageNo) {
        var callList = cmp.get("v.callList");
        var noOfCalls = cmp.get("v.noOfCallsToBeShown");
        var callListToBeShown = [];
        for(var i=(pageNo-1)*noOfCalls; i<(pageNo*noOfCalls); i++) {
            if(callList[i]) {
                callListToBeShown.push(callList[i]);
            }
        }
        cmp.set('v.callListToBeShown', callListToBeShown);
    },
    assignCallsHelper: function(cmp, event, helper) {
        
        var action = cmp.get('c.assignCallsToMe');
        action.setParams({ selectedCallsList: cmp.get("v.callsSelected"),
                          callListFilterwrapper: cmp.get("v.callListFilterWrapper"),
                          userId: cmp.get("v.selectedUser") });
        
        cmp.set("v.loadingContent","Assigning selected calls and refreshing pending calls. Please wait..");
        helper.startSpinner(cmp, true, "callListSpinner");
        action.setCallback(this, function(response) {
            helper.stopSpinner(cmp, true, "callListSpinner");
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                var response_result= res.list;
                  if(response_result.length > 0) {
                    response_result.forEach(function(record){
                        
                        if(record.TaskRecId != '' && record.TaskRecId != null){
                            record.TaskLink = '/'+record.TaskId;
                        }
                        if(record.RelatedServiceId != '' && record.RelatedServiceId != null){
                            record.ServiceLink='/'+record.RelatedServiceId;
                        }
                        if(record.RelatedAccountId != '' && record.RelatedAccountId != null){
                            record.ContactLink='/'+record.RelatedAccountId;
                        }
                        
                        
                    });
                  }
                helper.showToast(cmp, res.messageType, res.messageTitle, res.message,null,"dismissable");
                cmp.set('v.callList', res.list);
                cmp.set("v.selectedRowIds",[]);
                cmp.set("v.callsSelected",[]);
                helper.buildData(cmp, 1);
                var paginationCmp = cmp.find("cPagination");
                paginationCmp.RefreshPagination();
            } else if (state === "ERROR") {
                helper.showToast(cmp, "error", "Server Error!!", "Something went wrong.",null,"dismissable");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
     sortColumns: function (component, event, helper) {
        var dataTable = component.find(event.getSource().getLocalId());
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);
        component.set("v.callList",
            helper.sortData(component.get("v.callList"), fieldName, sortDirection)
        );
        helper.buildData(component, 1);
        var paginationCmp = component.find("cPagination");
        paginationCmp.RefreshPagination();
    }
})