({
	handleNextButton: function(component,event){
        if(component.get("v.isOfficeContact") == true){
            var evt = component.getEvent("ShowNextpotientForAlternateScreens");
            evt.setParams({
                "screenName": "ShowPotentialStatusInformation",
                "lCase":component.get("v.lCase"),
                "alternateContactObj":component.get("v.alternateContactObj"),
                "isPatientMinor" : component.get("v.isPatientMinor"),
            });
            evt.fire();
        }
        else{
        var evt = component.getEvent("ShowPatientEnrollmentScreens");
        evt.setParams({
            "screenName": "ShowPotentialStatusInformationScreen",
            "lCase":component.get("v.lCase"),
            "alternateContactObj":component.get("v.alternateContactObj"),
            "isPatientMinor" : component.get("v.isPatientMinor"),
        });
        evt.fire();
        }
    },
    
    handleRefresh: function(component,event){
        var evt = component.getEvent("ShowrefreshAlternateScreens2");
        evt.setParams({
            "screenName": "refreshShowAlternateContactInformationScreen2",
        });
        evt.fire();
    },
     handlePrescriberRefresh: function(component,event){
        var evt = component.getEvent("ShowPatientEnrollmentScreens");
        evt.setParams({
            "screenName": "refreshShowAlternateContactInformationScreen2",
        });
        evt.fire();
    },
    
    fireEvent: function(component,event,screenName){
        var evt = component.getEvent("ShowPreviousAlternateScreens");
        evt.setParams({
            "screenName": screenName
        }).fire();
    },
     firePrescriberEvent: function(component,event,screenName){
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