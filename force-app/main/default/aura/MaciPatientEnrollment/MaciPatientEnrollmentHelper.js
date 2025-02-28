({
	 handleNextButton: function(component,event){
         var evt = component.getEvent("ShowPatientInformationScreens");
         evt.setParams({
             "screenName": "ShowPatientInformation"
         });
         evt.fire(); 
    },
    handlePrescriberNextButton: function(component,event){
        var evt = component.getEvent("ShowPatientEnrollmentScreens");
        evt.setParams({
            "screenName": "ShowPatientInformationScreen"
        });
        evt.fire(); 
   },

    handlePreviousButton: function(component,event){
        var evt = component.getEvent("ShowOCPatientEnrollmentScreens");
        evt.setParams({
            "screenName": "ShowSelectPrescriberScreen"
        });
        evt.fire(); 
   },
})