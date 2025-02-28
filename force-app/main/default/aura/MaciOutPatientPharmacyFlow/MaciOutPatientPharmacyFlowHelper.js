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
	showNextScreen : function(component,event,helper) {
        
        if(event.getParam("screenName") == 'PharmacyEnrollment'){
            component.set("v.showOutPatientPharmacyEnrollmentScreen",true);
            component.set("v.ShowAuthorizedRepresentativeInformationScreen",false);
            component.set("v.ShowPasswordScreen",false);
            component.set("v.ShowPasswordConfirmScreen",false);
        }
            
        
        if(event.getParam("screenName") == 'AuthorizedRepresentativeInfo'){
            component.set("v.showOutPatientPharmacyEnrollmentScreen",false);
            component.set("v.ShowAuthorizedRepresentativeInformationScreen",true);
            component.set("v.ShowPasswordScreen",false);
            component.set("v.ShowPasswordConfirmScreen",false); 
        }
        if(event.getParam("screenName") == 'Password'){
         	component.set("v.showOutPatientPharmacyEnrollmentScreen",false);
            component.set("v.ShowAuthorizedRepresentativeInformationScreen",false);
            component.set("v.ShowPasswordScreen",true);
            component.set("v.ShowPasswordConfirmScreen",false);
        }
        
        if(event.getParam("screenName") == 'PasswordConfirm'){
           	component.set("v.showOutPatientPharmacyEnrollmentScreen",false);
            component.set("v.ShowAuthorizedRepresentativeInformationScreen",false);
            component.set("v.ShowPasswordScreen",false);
            component.set("v.ShowPasswordConfirmScreen",true);
            component.set("v.portalUserId",event.getParam("portalUserId"));

        }
        
        if(event.getParam("screenName") == 'RefreshAuthorizedRepresentativeInfo'){
            component.set("v.showOutPatientPharmacyEnrollmentScreen",false);
            component.set("v.ShowAuthorizedRepresentativeInformationScreen",false);
            component.set("v.ShowAuthorizedRepresentativeInformationScreen",true);
            component.set("v.ShowPasswordScreen",false);
            component.set("v.ShowPasswordConfirmScreen",false); 
            component.set("v.oPharmyInfo",{"sobjectType":"Case"});
        }
        
	}
})