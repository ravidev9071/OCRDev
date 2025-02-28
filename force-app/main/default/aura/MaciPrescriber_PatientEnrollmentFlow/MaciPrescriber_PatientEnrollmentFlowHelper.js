({ 
    handleInit : function(component, event) {
       var action = component.get("c.getCurrentUserAccountInfo");
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.cAccount', resultData);
				if(resultData.SYN_Signature__c != 'Yes'){
					component.set("v.ShowAgreementScreen",true);
				}else{
					component.set("v.ShowCompleteScreen",true);
				}
            }
        });
        $A.enqueueAction(action);
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
    
    
	showNextScreen : function(component,event,helper) {
        
        if(event.getParam("screenName") == 'ShowPatientAgmntInstructionsScreen'){
            component.set("v.ShowPatientAgmntInstructions",true);
            component.set("v.ShowPatientInformation",false);
            component.set("v.ShowAlternateContactInformation",false);
            component.set("v.ShowAlternateContactInformation2",false);
            component.set("v.ShowPotentialStatusInformation",false);
            component.set("v.ShowPatientAgreementInformation",false); 
        }
        
        if(event.getParam("screenName") == 'ShowPatientInformationScreen'){
            component.set("v.ShowPatientAgmntInstructions",false);
            component.set("v.ShowPatientInformation",true);
            component.set("v.ShowAlternateContactInformation",false);
            component.set("v.ShowAlternateContactInformation2",false);
            component.set("v.ShowPotentialStatusInformation",false);
            component.set("v.ShowPatientAgreementInformation",false); 
        }
        
        if(event.getParam("screenName") == 'ShowAlternateContactInformationScreen'){
           	component.set("v.ShowPatientAgmntInstructions",false);
            component.set("v.ShowPatientInformation",false);
            component.set("v.ShowAlternateContactInformation",true);
            component.set("v.ShowAlternateContactInformation2",false);
            component.set("v.ShowPotentialStatusInformation",false);
            component.set("v.ShowPatientAgreementInformation",false);
			component.set("v.isPatientMinor",event.getParam("isPatientMinor"));
        }

        if(event.getParam("screenName") == 'ShowAlternateContactInformationScr2'){
            component.set("v.ShowPatientAgmntInstructions",false);
            component.set("v.ShowPatientInformation",false);
            component.set("v.ShowAlternateContactInformation",false);
            component.set("v.ShowAlternateContactInformation2",true);
            component.set("v.ShowPotentialStatusInformation",false);
            component.set("v.ShowPatientAgreementInformation",false);
            component.set("v.isPatientMinor",event.getParam("isPatientMinor"));
        }
        if(event.getParam("screenName") == 'ShowPotentialStatusInformationScreen'){
            component.set("v.ShowPatientAgmntInstructions",false);
            component.set("v.ShowPatientInformation",false);
            component.set("v.ShowAlternateContactInformation",false);
            component.set("v.ShowAlternateContactInformation2",false);
            component.set("v.ShowPotentialStatusInformation",true);
            component.set("v.ShowPatientAgreementInformation",false);
        }
        
         if(event.getParam("screenName") == 'ShowPatientAgreementInformationScreen'){
            component.set("v.ShowPatientAgmntInstructions",false);
            component.set("v.ShowPatientInformation",false);
            component.set("v.ShowAlternateContactInformation",false);
            component.set("v.ShowAlternateContactInformation2",false);
            component.set("v.ShowPotentialStatusInformation",false);
            component.set("v.ShowPatientAgreementInformation",true);
        }
        
        // Refresh 
        if(event.getParam("screenName") == 'refreshShowPatientInformationScreen'){
            component.set("v.ShowPatientAgmntInstructions",false);
            component.set("v.ShowPatientInformation",false);
            component.set("v.ShowPatientInformation",true);
            component.set("v.ShowAlternateContactInformation",false);
            component.set("v.ShowAlternateContactInformation2",false);
            component.set("v.ShowPotentialStatusInformation",false);
            component.set("v.ShowPatientAgreementInformation",false); 
            component.set("v.newCase",{"sobjectType":"Case"});
            component.set("v.confirmEmail","");
        }
        
        if(event.getParam("screenName") == 'refreshShowAlternateContactInformationScreen'){
           	component.set("v.ShowPatientAgmntInstructions",false);
            component.set("v.ShowPatientInformation",false);
            component.set("v.ShowAlternateContactInformation",false);
            component.set("v.ShowAlternateContactInformation",true);
            component.set("v.ShowAlternateContactInformation2",false);
            component.set("v.ShowPotentialStatusInformation",false);
            component.set("v.ShowPatientAgreementInformation",false);
            component.set("v.pCase",{"sobjectType":"Case"});
            component.set("v.alternateContactObj",{'lgfirstName':component.get("v.alternateContactObj.lgfirstName"), 'lglastName':component.get("v.alternateContactObj.lglastName"), 'lgconfirmEmail':component.get("v.alternateContactObj.lgconfirmEmail"),'emergencyContactFirstName':'', 'emergencyContactLastName':'', 'emergencyContactRelationship':'', 'emergencyContactPhoneNum':''});

        }

        if(event.getParam("screenName") == 'refreshShowAlternateContactInformationScreen2'){
            component.set("v.ShowPatientAgmntInstructions",false);
            component.set("v.ShowPatientInformation",false);
            component.set("v.ShowAlternateContactInformation",false);
            component.set("v.ShowAlternateContactInformation2",false);
            component.set("v.ShowAlternateContactInformation2",true);
            component.set("v.ShowPotentialStatusInformation",false);
            component.set("v.ShowPatientAgreementInformation",false);
            component.set("v.lCase",{"sobjectType":"Case"});
            component.set("v.alternateContactObj",{'lgfirstName':'', 'lglastName':'', 'lgconfirmEmail':'', 'emergencyContactFirstName':'','emergencyContactLastName':'','emergencyContactRelationship':'','emergencyContactPhoneNum':''});
        }
        
        if(event.getParam("screenName") == 'refreshShowPotentialStatusInformationScreen'){
            component.set("v.rCase",{"sobjectType":"Case"});
            component.set("v.ShowPatientAgmntInstructions",false);
            component.set("v.ShowPatientInformation",false);
            component.set("v.ShowAlternateContactInformation",false);
            component.set("v.ShowAlternateContactInformation2",false);
            component.set("v.ShowPotentialStatusInformation",false);
            component.set("v.ShowPotentialStatusInformation",true);
            component.set("v.ShowPatientAgreementInformation",false);
           
        }
               
        
	}
})