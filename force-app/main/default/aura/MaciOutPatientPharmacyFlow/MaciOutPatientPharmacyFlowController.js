({
    doInit: function(component, event, helper) {     
        helper.getTitlePicklistValues(component, event); 
        helper.getCredentialsPicklistValues(component, event); 
    },
    
    handleShowScreen: function(component,event,helper){
        helper.showNextScreen(component,event);
    },
	
})