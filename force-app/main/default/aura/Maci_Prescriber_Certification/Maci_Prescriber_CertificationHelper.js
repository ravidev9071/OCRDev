({
	 handleNextButton: function(component,event){
         var evt = component.getEvent("ShowPrescriberScreens");
         evt.setParams({
             "showScreen" : true,
             "screenName": "PrescriberInformation"
         });
         evt.fire(); 
    },
})