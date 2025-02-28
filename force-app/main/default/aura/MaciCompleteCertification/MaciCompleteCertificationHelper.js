({
	handleInit : function(component, event) {
       var action = component.get("c.getCurrentUserAccountInfo");
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.cAccount', resultData);
            }
        });
        $A.enqueueAction(action);
    },
	showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : titleType,
                message: errMsg,
                duration:' 5000',
                key: 'info_alt',
                type: titleType,
                mode: 'pester'
            });
            toastEvent.fire();
	},
	addAttachment : function(component, event,helper) {
        var action = component.get("c.attachPrescriberEnrollmentFormonAccount");
        action.setParams({
            "accobj": component.get("v.cAccount"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //fetch the response state
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                
            }
            
        });
        $A.enqueueAction(action); 
    }

})