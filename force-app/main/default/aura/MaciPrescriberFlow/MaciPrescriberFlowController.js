({
    doInit: function(component, event, helper) {     
        helper.getstatePicklist(component, event);    
        helper.getProfessionalDesignationPicklist(component, event); 
    },
    
	handleShowScreen: function(component,event,helper){
        helper.showNextScreen(component,event);
    },
})