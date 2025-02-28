({
	
     handleNextButton: function(component,event){
        var action = component.get("c.validatePortalUser");
        var pEmail = component.get("v.oPharmyInfo.US_WSREMS__Email__c");
        var programId = component.get("v.programId");
        var userRole = component.get("v.userrole");
         action.setParams({
             email : pEmail,
             npi : null, 
             role : userRole,
             program : 'Macitentan REMS'
         });
        action.setCallback(this, function(result) {
            component.set("v.ShowSpinner",false);
            var state = result.getState();
            component.set("v.ShowSpinner",false);
            if (component.isValid() && state === "SUCCESS"){
                var duplicateFlag = result.getReturnValue();
                if(duplicateFlag == true){
                    this.showToast(component,event,'Duplicate record found.','Warning');
                }else{
                    
                    var evt = component.getEvent("ShowInPatinetScreens");
                    evt.setParams({
                        "screenName": "Password",
                        "oPharmyInfo" : component.get("v.oPharmyInfo")
                    });
                    evt.fire();
                }
            }else{
                this.showToast(component,event,'Something went wrong, please contact system admin.','Warning');
            }
        });
        $A.enqueueAction(action);       
    },
    
    fireEvent: function(component,event,screenName){
        var evt = component.getEvent("ShowInPatinetScreens");
        evt.setParams({
            "screenName": screenName
        }).fire();
    },
    
    handleRefresh: function(component,event){
        var evt = component.getEvent("ShowInPatinetScreens");
        evt.setParams({
            "screenName": "RefreshAuthorizedRepresentativeInfo"
        });
        evt.fire();
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
})