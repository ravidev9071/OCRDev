({
	handleRecordChanged: function(component, event, helper) {
        component.set("v.ShowSpinner", true); 
        var eventParams = event.getParams();
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var validateAff = $A.get("$Label.c.Affliation_Not_Found");
        var alertMessage = $A.get("$Label.c.Office_Contact_Alert_Message");
        var successMessage = $A.get("$Label.c.Success_Message");
        var failureAlertMessage = $A.get("$Label.c.Failure_Warning_Message");
        var ocCertWarningMsg = $A.get("$Label.c.Office_Contact_not_Certified");
        var validEmailMessage = $A.get("$Label.c.ValidEMail");
         var validStatus = $A.get("$Label.c.Status");
        if(eventParams.changeType == "LOADED"){
             if(component.get("v.accountRecord.IsCustomerPortal") == true){
                component.set("v.ShowSpinner", false); 
                helper.showToast(component,event,alertMessage,'info'); 
                $A.get("e.force:closeQuickAction").fire();
            }else if(component.get("v.accountRecord.US_WSREMS__Email__c") == '' || component.get("v.accountRecord.US_WSREMS__Email__c") == undefined ){
                component.set("v.ShowSpinner", false); 
                helper.showToast(component,event,validEmailMessage,'Warning');
                $A.get("e.force:closeQuickAction").fire(); 
         }else{
                var action = component.get("c.sendOfficeContactInvitation");
                action.setParams({
                    recordId : component.get("v.accountRecord.PersonContactId"),
                    email : component.get("v.accountRecord.US_WSREMS__Email__c"),
                    accountId : component.get("v.recordId")
                });
                action.setCallback(this, function(result) {
                    var state = result.getState();
                    if (component.isValid() && state === "SUCCESS"){
                        var result = result.getReturnValue();
                        
                        if(result == ''){
                            component.set("v.ShowSpinner", false); 
                            helper.showToast(component,event,successMessage,'success');  
                             $A.get("e.force:closeQuickAction").fire();

                        }else if(result == validateAff){
                            component.set("v.ShowSpinner",false);
                        	helper.showToast(component,event,validateAff,'Warning');
                             $A.get("e.force:closeQuickAction").fire();
                        }else{
                            component.set("v.ShowSpinner",false);
                        	helper.showToast(component,event,failureAlertMessage,'Warning');
                             $A.get("e.force:closeQuickAction").fire();
                        }
                    }else{
                        helper.showToast(component,event,failureAlertMessage,'Warning');
                         $A.get("e.force:closeQuickAction").fire();
                    }
                });
            
                $A.enqueueAction(action);                
            }
        } 
    },
})