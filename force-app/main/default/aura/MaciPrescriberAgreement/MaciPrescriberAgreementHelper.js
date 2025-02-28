({
	handleInit : function(component, event) {
       var action = component.get("c.getCurrentUserAccountInfo");
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.cAccount', resultData);
				if(resultData.SYN_Signature__c != 'Yes'){
					component.set("v.ShowAgreementScreen",true);
				}else{
					component.set("v.ShowCompleteScreen",true);
				}
            }
        });
        $A.enqueueAction(action);
    },
    
    showNextScreen : function(component,event,helper) {
        if(event.getParam("screenName") == 'CompleteScreen'){
            component.set("v.ShowAgreementScreen",false);
            component.set("v.ShowCompleteScreen",true);
        }
    }
})