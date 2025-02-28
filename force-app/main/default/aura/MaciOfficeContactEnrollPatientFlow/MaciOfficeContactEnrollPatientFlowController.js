({
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);   
        helper.getstatePicklist(component, event);    

    },

    handleNext : function(component, event, helper) {
        component.set('v.showInstructionScreen', true);
    },

    handleShowScreen : function(component, event, helper) {
        var i= component.get("v.count");
        
        if(i==0){
            helper.savePrescriberDetails(component, event,helper); 
        }
        i++;
        component.set('v.count', i);
        if(event.getParam("screenName") == 'ShowInstructionScreen'){
            component.set('v.showPrescriberSelectionScreen', false);
            component.set('v.showInstructionScreen', true);
            component.set('v.showPatientInformation',false);
            component.set('v.ShowAlternateContactInformation',false);
            component.set('v.ShowAlternateContactInformation2',false);
            component.set('v.ShowPotentialStatusInformation',false);
            component.set('v.ShowPatientAgreementInformation',false);
        } else if(event.getParam("screenName") == 'ShowSelectPrescriberScreen'){
            component.set('v.showPrescriberSelectionScreen', true);
            component.set('v.showInstructionScreen', false);          
            component.set('v.showPatientInformation',false);
            component.set('v.ShowAlternateContactInformation',false);
            component.set('v.ShowAlternateContactInformation2',false);
            component.set('v.ShowPotentialStatusInformation',false);
            component.set('v.ShowPatientAgreementInformation',false);
        } 
        else if(event.getParam("screenName") == 'ShowPatientInformation'){
            component.set('v.showPrescriberSelectionScreen', false); 
            component.set('v.showInstructionScreen', false);
            component.set('v.showPatientInformation',true);
            component.set('v.ShowAlternateContactInformation',false);
            component.set('v.ShowAlternateContactInformation2',false);
            component.set('v.ShowPotentialStatusInformation',false);
            component.set('v.ShowPatientAgreementInformation',false);
        }else if(event.getParam("screenName") == 'ShowAlternateContactInformationScreen'){
            component.set('v.isPatientMinor', event.getParam("isPatientMinor")); 
            component.set('v.showPrescriberSelectionScreen', false); 
            component.set('v.showInstructionScreen', false);
            component.set('v.showPatientInformation',false);
            component.set('v.ShowAlternateContactInformation',true);
            component.set('v.ShowAlternateContactInformation2',false);
            component.set('v.ShowPotentialStatusInformation',false);
            component.set('v.ShowPatientAgreementInformation',false);
        }else if(event.getParam("screenName") == 'ShowAlternateContactInformation2'){
            component.set('v.showPrescriberSelectionScreen', false); 
            component.set('v.showInstructionScreen', false);
            component.set('v.showPatientInformation',false);
            component.set('v.ShowAlternateContactInformation',false);
            component.set('v.ShowAlternateContactInformation2',true);
            component.set('v.ShowPotentialStatusInformation',false);
            component.set('v.ShowPatientAgreementInformation',false);
        }else if(event.getParam("screenName") == 'ShowPotentialStatusInformation'){
            component.set('v.showPrescriberSelectionScreen', false); 
            component.set('v.showInstructionScreen', false);
            component.set('v.showPatientInformation',false);
            component.set('v.ShowAlternateContactInformation',false);
            component.set('v.ShowAlternateContactInformation2',false);
            component.set('v.ShowPotentialStatusInformation',true);
            component.set('v.ShowPatientAgreementInformation',false);
        }else if(event.getParam("screenName") == 'ShowPatientAgreementInformationScreen'){
            component.set('v.showPrescriberSelectionScreen', false); 
            component.set('v.showInstructionScreen', false);
            component.set('v.showPatientInformation',false);
            component.set('v.ShowAlternateContactInformation',false);
            component.set('v.ShowAlternateContactInformation2',false);
            component.set('v.ShowPotentialStatusInformation',false);
            component.set('v.ShowPatientAgreementInformation',true);
        }
         
        // Refresh 
            else if(event.getParam("screenName") == 'refreshShowPatientInformationScreen'){
                debugger;
                component.set("v.ShowPatientAgmntInstructions",false);
                component.set("v.showPatientInformation",true);
                component.set("v.ShowAlternateContactInformation",false);
                component.set("v.ShowAlternateContactInformation2",false);
                component.set("v.ShowPotentialStatusInformation",false);
                component.set("v.ShowPatientAgreementInformation",false); 
                component.set("v.newCase",{"sobjectType":"Case"});
                component.set("v.confirmEmail","");
            }
        else if(event.getParam("screenName") == 'refreshShowAlternateContactInformation'){
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
         else if(event.getParam("screenName") == 'refreshShowAlternateContactInformationScreen2'){
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
        else if(event.getParam("screenName") == 'refreshShowPotentialStatusInformationScreen'){
            component.set("v.rCase",{"sobjectType":"Case"});
            component.set("v.ShowPatientAgmntInstructions",false);
            component.set("v.ShowPatientInformation",false);
            component.set("v.ShowAlternateContactInformation",false);
            component.set("v.ShowAlternateContactInformation2",false);
            component.set("v.ShowPotentialStatusInformation",false);
            component.set("v.ShowPotentialStatusInformation",true);
            component.set("v.ShowPatientAgreementInformation",false);
                 
       }
        
    },
})