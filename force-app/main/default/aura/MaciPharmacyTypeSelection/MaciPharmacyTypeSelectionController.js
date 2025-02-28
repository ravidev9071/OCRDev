({
    showContractScreen : function(component, event, helper) {
        component.set("v.showPharmacySelectionScreen", false);
        component.set("v.showContractingScreen", true);
    },

    navigateToFailureScreen : function(component, event, helper) {
        component.set("v.showContractingScreen", false);
        component.set("v.showFailureScreen", true);
    },

    navigateToHomeScreen : function(component, event, helper) {
       
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'home'
            }
        };
        nav.navigate( pageReference ); 
    },

	 navigateToOutPatientPharmacyPage : function(component, event, helper) {
        
       //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'outpatient-pharmacy-enrollment'
            }
        };
        nav.navigate( pageReference ); 
	},
    
    navigateToInPatientPharmacyPage : function(component, event, helper) {
        
        //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'inpatient-pharmacy-enrollment'
            }
        };
        nav.navigate( pageReference ); 
    },
})