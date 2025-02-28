({
	navigateToManagePatientsPage : function(component, event, helper) {
        
       //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'manage-patients'
            }
        };
        nav.navigate( pageReference ); 
	},
    navigateToManagePatientsPageOC : function(component, event, helper) {
       //Navigate to Office Contact Page
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'officecontacthome'
            }
        };
        nav.navigate( pageReference ); 
	},
})