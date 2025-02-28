({
    fetchInitialFilterValues : function(cmp, event, helper) {
        var action = cmp.get('c.getInitialFilterValues');
        action.setParams({ callListFilterwrapper: cmp.get("v.callListFilterWrapper") });
        helper.startSpinner(cmp, true, "callListSpinner");
        action.setCallback(this, function(response) {
            helper.stopSpinner(cmp, true, "callListSpinner");
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                cmp.set("v.callListFilterWrapper",res);
                cmp.set("v.selectedProject",res.filterWrapperList[0].selectedValue);
                helper.showCallList(cmp, event, helper, false);
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
    
    showCallList: function(cmp, event, helper, isReset) {
        var compEvent = cmp.getEvent("CallListFilterEvent");
        compEvent.setParams({"callListFilterWrapper" : JSON.stringify(cmp.get("v.callListFilterWrapper")),
                             "selectedProject" : cmp.get("v.selectedProject"),
                             "IsSuperUser" : cmp.get("v.IsSuperUser"),
                             "resetValues": isReset });
        compEvent.fire();
    }, 
    onProjectChange: function(cmp, event, helper,taskstatus,projectName,otherfilterchange) {
        var action = cmp.get('c.handleProjectChange');
        action.setParams({ callListFilterwrapper: cmp.get("v.callListFilterWrapper") ,
                          projectchanged :projectName,
                          tasktype:taskstatus,
                          filterchange :otherfilterchange});
        helper.startSpinner(cmp, true, "callListSpinner");
        action.setCallback(this, function(response) {
            helper.stopSpinner(cmp, true, "callListSpinner");
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                cmp.set("v.callListFilterWrapper",res);
                helper.showCallList(cmp, event, helper, false);
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
    
    onResetFilters: function(cmp, event, helper) {
        var action = cmp.get('c.getFilters');
        helper.startSpinner(cmp, true, "callListSpinner");
        action.setCallback(this, function(response) {
            helper.stopSpinner(cmp, true, "callListSpinner");
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                cmp.set("v.callListFilterWrapper",res);
                cmp.set("v.selectedProject","All");
                this.fetchInitialFilterValues(cmp, event, helper);
                
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
})