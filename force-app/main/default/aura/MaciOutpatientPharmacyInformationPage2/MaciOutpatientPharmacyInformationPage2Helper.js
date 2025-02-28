({
    handleNextButton: function(component,event){
        
      
        var evt = component.getEvent("ShowOutPatinetScreens");
        evt.setParams({
            "screenName": "ShowAgreementInfoScreen",
            "oPharmyInfo" : component.get("v.newCase")
            
        });
        evt.fire(); 
    },	
    fireEvent: function(component,event,screenName){
        var evt = component.getEvent("ShowOutPatinetScreens");
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
    getstatePicklist: function(component, event) {        
        var action = component.get("c.getStates");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var stateMap = [];
                for(var key in result){
                    stateMap.push({key: key, value: result[key]});
                } 
                component.set("v.stateMap", stateMap);
            }
        });
        $A.enqueueAction(action);
    },
})