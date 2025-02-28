({
	doInit: function(component, event, helper) {     
        helper.getstatePicklist(component, event);    
    },
    handleShowScreen: function(component,event,helper){
        helper.showNextScreen(component,event);
    },
})