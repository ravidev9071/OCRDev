({
	doInit : function(component, event, helper) {
        
        component.set('v.ShowPatientInformation', true);
        var url_string = document.location.href;
        var url = new URL(url_string);         
        var recordId = url.searchParams.get("id");
        component.set("v.patientID",recordId);
        helper.handleInit(component, event);
        helper.getstatePicklist(component, event);  
	},
    
	handleShowScreen: function(component,event,helper){
        helper.showNextScreen(component,event);
    },
})