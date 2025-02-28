({
	handleInit : function(component, event) {
       var action = component.get("c.getCurrentUserPharmacyInfo");
       var cuserId = $A.get("$SObjectType.CurrentUser.Id");

        action.setParams({
            UserId : cuserId
        });
         action.setCallback(this, function(result) {
            var state = result.getState();
             
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                
                component.set('v.cCase', resultData);
				component.set('v.Pharmacyacc', resultData.SYN_Pharmacy__c);
                this.updateAuthorizedRepAccount(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateAuthorizedRepAccount : function(component, event) {
       var action = component.get("c.updateAuthorizedRepAccount");
        action.setParams({
            accountId : component.get('v.cCase.SYN_Authorized_Rep__c')
        });
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                
            }
        });
        $A.enqueueAction(action);
    },
	addAttachment : function(component, event,helper) {
        var action = component.get("c.attachOutpatientEnrollmentFormonAccount");
        action.setParams({
            "caseObj": component.get("v.cCase"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //fetch the response state
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue()
                }
            
        });
        $A.enqueueAction(action); 
    }
    
})