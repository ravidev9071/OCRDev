({
	getCurrentUserType : function (component, event, helpler) {
		 var action = component.get("c.getCurrentUserType");
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                
                component.set('v.currentUser', resultData);
                if(resultData.Account.US_WSREMS__Status__c == 'Certified' && resultData.Account.SYN_Signature__c == 'Yes'){
                    component.set('v.showManagePatient', true);
                }
                if(resultData.Account.US_WSREMS__Status__c == 'Active' ){
                    component.set('v.showManageOfficeContact', true);
                }

                if(resultData.Account.US_WSREMS__Status__c == 'Active' && resultData.Account.SYN_Signature__c == 'Yes'){
                    component.set('v.showInpatientManageOffice', true);
					this.getCurrentPharmacyInfo(component, event);
                }

                if(resultData.Account.US_WSREMS__Status__c == 'Active'){
                    component.set('v.showManageOffice', true);
					this.getCurrentPharmacyInfo(component, event);
                }  
            }
        });
        $A.enqueueAction(action);
	},
	
	getCurrentPharmacyInfo : function(component,event){
        debugger;
        var action = component.get("c.getUserDefaultPharmacyInfo");
        var cuserId = $A.get("$SObjectType.CurrentUser.Id");
        action.setParams({
            UserId :cuserId
               
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
             
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                
                component.set('v.Pharmacyacc', resultData.US_WSREMS__Pharmacy__c);
                 
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
    
    
})