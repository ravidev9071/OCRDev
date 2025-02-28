({
	handleRecordChanged: function(component, event, helper) {
        component.set("v.ShowSpinner", true); 
        var eventParams = event.getParams();
        if(eventParams.changeType == "LOADED"){
            if(component.get("v.accountRecord.US_WSREMS__Status__c") != 'Certified'){
                component.set("v.ShowSpinner", false); 
              helper.showToast(component,event,'Prescriber is not certified','Error');
              $A.get("e.force:closeQuickAction").fire();
            }else if(component.get("v.accountRecord.IsCustomerPortal") == true){
                helper.showToast(component,event,'Current Prescriber is already enrolled to this program','info');
                $A.get("e.force:closeQuickAction").fire();
            }else{
                var action = component.get("c.sendPrescriberInvitation");
                action.setParams({
                    recordId : component.get("v.accountRecord.PersonContactId"),
                    email : component.get("v.accountRecord.Email_address__c"),
                    accountId : component.get("v.recordId")
                });
                action.setCallback(this, function(result) {
                    var state = result.getState();
                    if (component.isValid() && state === "SUCCESS"){
                        var result = result.getReturnValue();
                        
                        if(result == ''){
                            helper.showToast(component,event,'Invitation sent successfully.','success');  
                             $A.get("e.force:closeQuickAction").fire();
                        }else{
                            component.set("v.ShowSpinner",false);
                        	helper.showToast(component,event,'Something went wrong, please contact system admin.','Warning');
                             $A.get("e.force:closeQuickAction").fire();
                        }
                    }else{
                        helper.showToast(component,event,'Something went wrong, please contact system admin.','Warning');
                         $A.get("e.force:closeQuickAction").fire();
                    }
                });
                $A.enqueueAction(action);                
            }
        } 
    },
})