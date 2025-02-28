({
	getTitlePicklistValues: function(component, event) {        
        var action = component.get("c.getPharmacyTitle");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var titleMap = [];
                for(var key in result){
                    titleMap.push({key: key, value: result[key]});
                } 
                component.set("v.titleMap", titleMap);
            }
        });
        $A.enqueueAction(action);
	},
    getCredentialsPicklistValues: function(component, event) {        
        var action = component.get("c.getPharmacyCredentails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var credentailsMap = [];
                for(var key in result){
                    credentailsMap.push({key: key, value: result[key]});
                } 
                component.set("v.credentialsMap", credentailsMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleInit : function(component, event) {
        var action = component.get("c.getPharmacyARInfo");
        action.setCallback(this, function(result) {
             component.set('v.ShowSpinner', false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.pAccount', resultData);

                component.set('v.originalValue2FA', resultData.Two_Factor_Authentication_Selection__c);
                component.set('v.value2FA', resultData.Two_Factor_Authentication_Selection__c);
                if(component.get("v.value2FA") == 'Opt-Out'){
                    component.set("v.show2FAOptOut",true);
                }
            }
        });
        $A.enqueueAction(action);
    },

    savePharmacyTwoFA : function(component, event) {
        var pAccount = component.get("v.pAccount");
        var programId = component.get("v.programId");
        pAccount.Two_Factor_Authentication_Selection__c = component.get("v.value2FA");
        component.set('v.originalValue2FA', pAccount.Two_Factor_Authentication_Selection__c);

        var action = component.get("c.updatePharmacyPreference");
        
        action.setParams({
            newAccount : pAccount,
            programId : programId, 
            programName : 'Macitentan REMS',
            channel : 'Portal'
         });
        action.setCallback(this, function(result) {
            component.set('v.ShowSpinner', false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                if(resultData == ''){
                     
                    this.showToast(component,event,'The change of information is updated successfully.','success'); 
                }else{
                	this.showToast(component,event,'Something went wrong, please contact system admin.','Error');
                }
            }
        });
        $A.enqueueAction(action);
    },
})