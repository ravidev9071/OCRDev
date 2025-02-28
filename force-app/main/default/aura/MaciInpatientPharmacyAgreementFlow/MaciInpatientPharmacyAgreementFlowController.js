({
	doInit: function(component, event, helper) {   
        helper.getpharmacistInfo(component, event);  
        helper.getstatePicklist(component, event);  
        helper.getTitlePicklistValues(component, event); 
        helper.getInpatientPharmacyTypePicklistValues(component, event); 
    },
    handleShowScreen: function(component,event,helper){
        helper.showNextScreen(component,event);
    },
})