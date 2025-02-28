({
	 handleNextButton: function(component,event){
         var evt = component.getEvent("ShowOutPatinetScreens");
         evt.setParams({
             "screenName": "AuthorizedRepresentativeInfo"
         });
         evt.fire(); 
    },
})