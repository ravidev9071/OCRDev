({
	navigate : function(component, event, helper) {
        var selectedTileMenu = event.currentTarget.id;
       //Navigate to Creation Page
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: selectedTileMenu
            }
        };
        nav.navigate( pageReference ); 
	},
    
    initialize : function( component, event, helper ) {
      
        helper.getCurrentUserType(component);
    },
   
})