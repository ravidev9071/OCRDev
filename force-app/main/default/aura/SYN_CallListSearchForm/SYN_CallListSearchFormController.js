({
    doInit : function(cmp, event, helper) {

        var action = cmp.get('c.getFilters');
        helper.startSpinner(cmp, true, "callListSpinner");
        action.setCallback(this, function(response) {
            helper.stopSpinner(cmp, true, "callListSpinner");
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                console.log("Filters Response -->>",res);
                cmp.set("v.callListFilterWrapper",res);
                cmp.set("v.selectedProject","ALL");
                cmp.set("v.IsSuperUser",res.isSupervisor);
                helper.fetchInitialFilterValues(cmp, event, helper);
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
    handlePicklistChange: function(cmp, event, helper) {
        cmp.set("v.loadingContent","Applying Filters...");
        if(event.getSource().get("v.label") == "REMS Program") {
            cmp.set("v.selectedProject",event.getSource().get("v.value"));
            helper.onProjectChange(cmp, event, helper,'',cmp.get("v.selectedProject"),false);
        }else if(event.getSource().get("v.label") == "Task Type"){
           
           
            cmp.set("v.selectedtasktype",event.getSource().get("v.value"));
            helper.onProjectChange(cmp, event, helper,event.getSource().get("v.value"),cmp.get("v.selectedProject"),true);
             
        }else if(event.getSource().get("v.label") == "Assigned To"){
            helper.showCallList(cmp, event, helper, false);
        } else {
           helper.onProjectChange(cmp, event, helper,cmp.get("v.selectedtasktype"),cmp.get("v.selectedProject"),true);
        }
    },
    clearButtonClick: function(cmp, event, helper) {
        cmp.set("v.selectedProject","All");
        helper.onResetFilters(cmp, event, helper);
    }
    
})