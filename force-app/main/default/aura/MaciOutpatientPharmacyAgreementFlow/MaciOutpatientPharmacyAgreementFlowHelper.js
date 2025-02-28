({
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
    
    showNextScreen : function(component,event,helper) {
        if(event.getParam("screenName") == 'MailingAddressInfoScreen1'){
            component.set("v.ShowPharmacyNPIScreen",false);
            
            component.set("v.ShowMailingAddressInfoScreen",true); 
            component.set("v.ShowAgreementInfoScreen",false);
            component.set("v.ShowCompleteInfoScreen",false);
        }
        if(event.getParam("screenName") == 'PharmCNPIScreen'){
            component.set("v.ShowPharmacyNPIScreen",true);
            component.set("v.ShowMailingAddressInfoScreen",false); 
           
            component.set("v.ShowAgreementInfoScreen",false);
            component.set("v.ShowCompleteInfoScreen",false);
        }
       
        if(event.getParam("screenName") == 'PharmCMailingAddressScreen'){
            component.set("v.ShowPharmacyNPIScreen",false);
            component.set("v.ShowMailingAddressInfoScreen",true); 
           
            component.set("v.ShowAgreementInfoScreen",false);
            component.set("v.ShowCompleteInfoScreen",false);
            component.set("v.pharmcInfo",event.getParam("oPharmyInfo"));
        }
        if(event.getParam("screenName") == 'ShowAgreementInfoScreen'){
            component.set("v.ShowPharmacyNPIScreen",false);
            component.set("v.ShowMailingAddressInfoScreen",false); 
           
            component.set("v.ShowAgreementInfoScreen",true);
            component.set("v.ShowCompleteInfoScreen",false);
            component.set("v.pharmcInfo",event.getParam("oPharmyInfo"));
        }
        if(event.getParam("screenName") == 'CompleteScreen'){
            component.set("v.ShowPharmacyNPIScreen",false);
            component.set("v.ShowMailingAddressInfoScreen",false); 
            
            component.set("v.ShowAgreementInfoScreen",false);
            component.set("v.ShowCompleteInfoScreen",true); 
        } 
        if(event.getParam("screenName") == 'homeScreen'){
            window.location.replace("/secur/logout.jsp?retUrl=%2F/s");
        }
    },
   

})