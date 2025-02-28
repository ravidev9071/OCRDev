({  
    getCurrentUserType : function (component, event, helpler) {
		 var action = component.get("c.verifyUserResetPasswrod");
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.currentUser', resultData);
                if(resultData.Is_Reset_Password_Req__c == true && resultData.Role__c == 'Outpatient Pharmacy' && resultData.Account.US_WSREMS__Status__c != 'Active'){
                    this.showToast(component,event,'Your password has been successfully changed','Success'); 
                    component.set("v.ShowSpinner",true);
                    this.navigateToHomePage(component, event, helpler);
                }else if(resultData.Is_Reset_Password_Req__c == true){
                    component.set("v.ShowSpinner",true);
                    this.getActivePage(component, event, helpler)
                }else{
                    component.set("v.ShowSpinner",false);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
	getActivePage: function (component, event, helpler) {
       
        var action = component.get("c.getActivePage");
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            component.set("v.ShowSpinner",false);
            if(result != ''){
                var nav = component.find("navigation");
                var pageReference = {
                    type: "comm__namedPage",
                    attributes: {
                        pageName: result
                    }
                };
                nav.navigate( pageReference ); 
                this.updateIsResetPassword(component, event, helpler);
            }
       });
        $A.enqueueAction(action);
    },
    
    updateIsResetPassword : function (component, event, helpler) {
		 var action = component.get("c.updateIsResetPassword");
         action.setParams({
            UserId : component.get('v.currentUser.Id')   
        });
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (state === "SUCCESS"){
              var resultData = result.getReturnValue();
                if(resultData == ''){
                    this.showToast(component,event,'Your password has been successfully changed','Success'); 
                }
            }else{
                
            }
        });
        $A.enqueueAction(action);
	},
    
    navigateToHomePage : function(component, event, helper) {
        window.location.replace("/secur/logout.jsp?retUrl=%2F/s");
        this.updateIsResetPassword(component, event, helpler);
	},
    
    showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : titleType,
            message: errMsg,
            duration:' 10000',
            key: 'info_alt',
            type: titleType,
            mode: 'pester'
        });
        toastEvent.fire();
    },
})