({
	handleNextButton: function(component,event){
         var evt = component.getEvent("ShowInPatinetScreens");
         evt.setParams({
             "screenName": "AuthorizedRepresentativeInfo"
         });
         evt.fire(); 
    },
})