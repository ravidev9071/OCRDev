({
	navigateToHomePage : function(component, event, helper) {
        var evt = component.getEvent("ShowOutPatinetScreens");
                    evt.setParams({
                        "screenName": "homeScreen"
                    });
            evt.fire();  
	},
})