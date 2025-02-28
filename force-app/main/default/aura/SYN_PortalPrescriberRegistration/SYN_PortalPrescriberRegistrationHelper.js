({
	navigateToRecord : function(component, event, helper){
        var payload = event.getParams().response;
        console.log('Case Id',payload.id);
        var action = component.get("c.createPortalAcctOnCaseCreation");
        action.setParams({ caseId : payload.id });
        action.setCallback(this,function(res){
            var state = res.getState();
            debugger;
            if (state === "SUCCESS") {
                let returnValue = res.getReturnValue();
                let isAccountCreated = returnValue['AccountCreate'];
                var title='';
                var type='';
                
            
				debugger;  
				if (isAccountCreated){ 
                    component.set("v.flag", false);    
                	component.set("v.AccountCreatedMsg", true);          
              /*  var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": title,
                    "message": returnValue['notificationMsg'] ,
                    "type": type 
                });
                component.set("v.showSpinner",false);
                toastEvent.fire(); */
				} 
                
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = res.getError();
                    console.log('Error Msg '+JSON.stringify(errors));
                    
                }
        });
        $A.enqueueAction(action);
        
    },

    updateAccountRecord : function(component, event, helper, Actid){
        debugger;
        console.log('Actid++++'+Actid);
        var payload = event.getParams().response;
        
        console.log('Case Id',payload.id);
        var action = component.get("c.updateAccountOnCaseCreation");
        action.setParams({ caseId : payload.id, AccountId : Actid});
        action.setCallback(this,function(res){
            var state = res.getState();
            debugger;
            if (state === "SUCCESS") {
                let returnValue = res.getReturnValue();
                let isAccountCreated = returnValue['AccountCreate'];
                var title='';
                var type='';
				debugger;  
				if (isAccountCreated){
               		component.set("v.flag", false);   
                	component.set("v.AccountCreatedMsg", true);  
				}
                
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = res.getError();
                    console.log('Error Msg '+JSON.stringify(errors));
                    
                }
        });
        $A.enqueueAction(action);
        
    },
})