({
    doInit : function(component, event, helper) {
        var url_string = document.location.href;
        var url = new URL(url_string);         
        var patientURLId = url.searchParams.get("PatientID");
        component.set("v.patientID",patientURLId);       
        helper.handleInit(component, event);
        component.set('v.isLoading', true);        
    },
    
    handleComplete : function(component, event, helper) {
        helper.handleCompleteCreation(component, event);
    },
    
    monthlyPregancyTest : function(component, event, helper) {
        let checkBoxState = event.getSource().get('v.value');       
        component.find("disableenable").set("v.disabled", !checkBoxState);
    },
})