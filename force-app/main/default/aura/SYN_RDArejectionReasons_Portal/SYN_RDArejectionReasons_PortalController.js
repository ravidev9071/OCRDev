({
    doInit : function(component, event, helper) {
        var CaseStatusReason = component.get("v.remsRecord");
        var recordId = component.get("v.recordId");

        
        var action = component.get("c.RDArejectionReasons");
        action.setParams({ CurrentRDAcaseId : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.RRRList",response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log('errror', errors );
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    recordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
            //debugger;
            var recordId = component.get("v.recordId");
            var action = component.get("c.RDArejectionReasons");
            action.setParams({ CurrentRDAcaseId : recordId });
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    component.set("v.RRRList",response.getReturnValue());
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log('errror', errors );
                }
                
            });
            
            $A.enqueueAction(action);           
        }
    }
})