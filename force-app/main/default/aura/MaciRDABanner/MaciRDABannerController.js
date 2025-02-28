({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        
        
        var action = component.get("c.getCurrentRDARecord");
        action.setParams({ CurrentRDAcaseId : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                component.set("v.remsRecord",response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    recordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
            
            var recordId = component.get("v.recordId");
            var action = component.get("c.getCurrentRDARecord");
            action.setParams({ CurrentRDAcaseId : recordId });
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    
                    component.set("v.remsRecord",response.getReturnValue());
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    
                }
                
            });
            
            $A.enqueueAction(action);           
        }
    }
})