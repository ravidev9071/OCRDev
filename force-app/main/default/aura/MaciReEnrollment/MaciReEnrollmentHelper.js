({
	handleInit : function(component, event) {
        var action = component.get("c.getCurrentUserAccountInfo");
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.cAccount', resultData);
                this.getCurrentPrescriberPatientInfo(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCurrentPrescriberPatientInfo : function(component, event) {
        
        var action = component.get("c.getSelectedPatientInfo");
        var patientAccount= component.get("v.patientID");
       
        action.setParams({
            program : 'Macitentan REMS',
            patientId : patientAccount,
            prescriberAccount : component.get('v.cAccount')
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.isLoading', false);
                var resultData = result.getReturnValue();
                //Patient Information 
                component.set('v.reCase.US_WSREMS__First_Name__c', resultData.US_WSREMS__First_Name__c);
                component.set('v.reCase.US_WSREMS__Last_Name__c', resultData.US_WSREMS__Last_Name__c);
                component.set('v.reCase.US_WSREMS__Middle_Name__c', resultData.US_WSREMS__Middle_Name__c);
                component.set('v.reCase.US_WSREMS__DOB__c', resultData.US_WSREMS__DOB__c);
                
               
                component.set('v.newCase', resultData);
                component.set('v.rCase', resultData);
                
                
                if(resultData.Best_time_to_call__c == 'Morning'){
                    component.set("v.morning",true);
                }else if(resultData.Best_time_to_call__c == 'Afternoon'){  
                    component.set("v.afternoon",true);
                }else if(resultData.Best_time_to_call__c == 'Evening'){   
                    component.set("v.evening",true);
                }
                
                if(resultData.Emergency_Contact_Name__c != null && resultData.Emergency_Contact_Name__c.length != 1){
                    //var emergencetContactName = resultData.Emergency_Contact_Name__c;
                    //var eContactName [] = emergencetContactName.split(" ");
                    
                    var emergencetContactName = resultData.Emergency_Contact_Name__c;
                    emergencetContactName = emergencetContactName.split(" ");
                    var emergencetContactNameArray = new Array();
                    for(var i =0; i < emergencetContactName.length; i++){
                        emergencetContactNameArray.push(emergencetContactName[i]);
                    }
                    component.set("v.alternateContactObj.emergencyContactFirstName",emergencetContactNameArray[0]);
                    if(emergencetContactNameArray.length > 1){
                    component.set("v.alternateContactObj.emergencyContactLastName",emergencetContactNameArray[1]); 
                    }
                }
                
                if(resultData.Emergency_Contact_Relationship__c.length != 1){
                	component.set("v.alternateContactObj.emergencyContactRelationship",resultData.Emergency_Contact_Relationship__c);
                }
                if(resultData.Emergency_Contact_Phone__c.length != 1){
                   component.set("v.alternateContactObj.emergencyContactPhoneNum",resultData.Emergency_Contact_Phone__c);
                }
                
                // Legal Guardian Info 
                if(resultData.Legal_Guardian_Name__c != null && resultData.Legal_Guardian_Name__c.length != 1){
                    var legalGuardianName = resultData.Legal_Guardian_Name__c;
                    legalGuardianName = legalGuardianName.split(" ");
                    var legalGuardianNameArray = new Array();
                    for(var i =0; i < legalGuardianName.length; i++){
                        legalGuardianNameArray.push(legalGuardianName[i]);
                    }
                    component.set("v.alternateContactObj.lgfirstName",legalGuardianNameArray[0]);
                    if(legalGuardianNameArray.length > 1){
                        component.set("v.alternateContactObj.lglastName",legalGuardianNameArray[1]); 
                    }
                }
                
                if(resultData.US_WSREMS__Email__c != null && resultData.US_WSREMS__Email__c.length != 1){
                    component.set('v.confirmEmail', resultData.US_WSREMS__Email__c);
                }
                
                
                if(resultData.Legal_Guardian_Relationship__c != null && resultData.Legal_Guardian_Relationship__c.length != 1){
                    component.set('v.lCase.Legal_Guardian_Relationship__c', resultData.Legal_Guardian_Relationship__c); 
                }
                
                
                if(resultData.Legal_Guardian_Email__c != null && resultData.Legal_Guardian_Email__c.length != 1){
                    component.set('v.lCase.Legal_Guardian_Email__c', resultData.Legal_Guardian_Email__c); 
                    component.set('v.alternateContactObj.lgconfirmEmail', resultData.Legal_Guardian_Email__c);
                }
                
                if(resultData.Legal_Guardian_Phone__c != null && resultData.Legal_Guardian_Phone__c.length != 1){
                    component.set('v.lCase.Legal_Guardian_Phone__c', resultData.Legal_Guardian_Phone__c); 
                } 
                
            }
        });
        $A.enqueueAction(action);
    },
    
     getPatientReEnrollmentInfo : function(component, event) {
        
        var action = component.get("c.getPatientPregnancyInfo");
        var patientAccount= component.get("v.patientID");
        
        action.setParams({
            patientAcc : component.get('v.pAccount'),
            prescriberAcc :  component.get('v.cAccount')
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.isLoading', false);
                var resultData = result.getReturnValue();
                component.set('v.rCase', resultData);
                this.createPatientReEnrollment(component, event);
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
    
    createPatientReEnrollment : function(component, event) {
        
        var action = component.get("c.createPatientReEnrollment");
        action.setParams({
            patientAcc : component.get('v.pAccount'),
            prescriberAcc :  component.get('v.cAccount'),
            reEnrollCase : component.get('v.rCase')
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
                             component.set('v.isLoading', false);
            
            if (component.isValid() && state === "SUCCESS"){

                 helper.showToast(component,event,'Patient reEnrolled Successfuly.','Success')
            }
        });
        $A.enqueueAction(action);
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

        if(event.getParam("screenName") == 'ShowAlternateContactInformationScreen2'){
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
            component.set("v.alternateContactObj",{'lgfirstName':component.get("v.alternateContactObj.lgfirstName"), 'lglastName':component.get("v.alternateContactObj.lglastName"), 'lgconfirmEmail':component.get("v.alternateContactObj.lgconfirmEmail"), 'emergencyContactFirstName':'','emergencyContactLastName':'','emergencyContactRelationship':'','emergencyContactPhoneNum':''});

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