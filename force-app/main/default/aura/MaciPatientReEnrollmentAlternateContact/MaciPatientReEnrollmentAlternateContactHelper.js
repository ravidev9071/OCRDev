({
	handleNextButton: function(component,event){
         var evt = component.getEvent("ShowPatientEnrollmentScreens");
                    evt.setParams({
                        "screenName": "ShowAlternateContactInformationScreen2",
                        "pCase":component.get("v.pCase"),
                        "alternateContactObj":component.get("v.alternateContactObj"),
                        "isPatientMinor" : component.get("v.isPatientMinor"),
                    });
                    evt.fire();
    },
    
    handleRefresh: function(component,event){
        var evt = component.getEvent("ShowPatientEnrollmentScreens");
        evt.setParams({
            "screenName": "refreshShowAlternateContactInformationScreen",
        });
        evt.fire();
    },
    
    fireEvent: function(component,event,screenName){
        var evt = component.getEvent("ShowPatientEnrollmentScreens");
        evt.setParams({
            "screenName": screenName
        }).fire();
    },
    showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : titleType,
                message: errMsg,
                duration:' 5000',
                key: 'info_alt',
                type: titleType,
                mode: 'pester'
            });
            toastEvent.fire();
	},
})