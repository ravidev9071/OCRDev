({
	doInit : function(component,event,helper){ 
        var isMaciProgramLive= $A.get("$Label.c.Is_Maci_Program_Live");
         if(isMaciProgramLive == 'No'){   
             component.set('v.showActions', false);
         }else{
            component.set('v.showActions', true);
         }
        helper.fetchResources(component,event);
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