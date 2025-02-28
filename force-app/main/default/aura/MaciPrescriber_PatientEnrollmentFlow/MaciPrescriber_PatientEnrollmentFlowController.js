({ 
    doInit : function(component, event, helper) {
        helper.handleInit(component, event);
        helper.getstatePicklist(component, event);    
    },
  
	handleShowScreen: function(component,event,helper){
        helper.showNextScreen(component,event);
    },
})