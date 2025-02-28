({
	doInit : function(component,event,helper){ 
        helper.fetchResources(component,event);
    },
    
    navigateToPharmacyLocatorPage : function(component, event, helper) {
        var isMaciProgramLive= $A.get("$Label.c.Is_Maci_Program_Live");
        if(isMaciProgramLive != 'No'){ 
            //Navigate to navigateToPharmacyLocator Page
            var nav = component.find("navigation");
            var pageReference = {
                type: "comm__namedPage",
                attributes: {
                    pageName: 'pharmacy-locator'
                }
            };
            nav.navigate( pageReference ); 
        }
	},
    
    navigateToPharmacyCertifyPage : function(component, event, helper) {
        var isMaciProgramLive= $A.get("$Label.c.Is_Maci_Program_Live");
        if(isMaciProgramLive != 'No'){
           //Navigate to navigateToPharmacyCertify Page
            var nav = component.find("navigation");
            var pageReference = {
                type: "comm__namedPage",
                attributes: {
                    pageName: 'pharmacy-type-selection'
                }
            };
            nav.navigate( pageReference ); 
        }
	},
})