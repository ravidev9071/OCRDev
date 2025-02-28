({
	doInit : function(component,event,helper){ 
        helper.fetchResources(component,event);
    },
    
    navigateToPrescriberPage : function(component, event, helper) {
        var isMaciProgramLive= $A.get("$Label.c.Is_Maci_Program_Live");
        if(isMaciProgramLive != 'No'){   
            //Navigate to Prescriber Page
            var nav = component.find("navigation");
            var pageReference = {
                type: "comm__namedPage",
                attributes: {
                    pageName: 'prescriber-certification'
                }
            };
            nav.navigate( pageReference ); 
        }
	},
    
    navigateToPharmacyLocatorPage : function(component, event, helper) {
        
      var isMaciProgramLive= $A.get("$Label.c.Is_Maci_Program_Live");
        if(isMaciProgramLive != 'No'){     
            //Navigate to Prescriber Page
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
    
    
})