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

    
    getProfessionalDesignationPicklist: function(component, event) {        
        var action = component.get("c.getProfessionalDesignation");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var profDesignationMap = [];
                for(var key in result){
                    profDesignationMap.push({key: key, value: result[key]});
                } 
                component.set("v.ProfessionalDesignationMap", profDesignationMap);
            }
        });
        $A.enqueueAction(action);
    },
    
	showNextScreen : function(component,event,helper) {
        
		
        if(event.getParam("screenName") == 'certficationScreen'){
            component.set("v.showPrescriberCertificationScreen",true);
            component.set("v.showPrescriberInfoScreen",false);
            component.set("v.showPrescriberPrimaryOfficeScreen",false);
            component.set("v.showPrescriberSecondaryOfficeScreen",false);
            component.set("v.showPrescriberPasswordScreen",false);
            component.set("v.showMaciConfirmEmailScreen",false); 
        }
        
        if(event.getParam("screenName") == 'PrescriberInformation'){
            component.set("v.showPrescriberCertificationScreen",false);
            component.set("v.showPrescriberInfoScreen",event.getParam("showScreen"));
            component.set("v.showPrescriberPrimaryOfficeScreen",false);
            component.set("v.showPrescriberSecondaryOfficeScreen",false);
            component.set("v.showPrescriberPasswordScreen",false);
            component.set("v.showMaciConfirmEmailScreen",false); 
        }
        if(event.getParam("screenName") == 'PrimaryOffice'){
            component.set("v.showPrescriberCertificationScreen",false);
            component.set("v.showPrescriberInfoScreen",false);
            component.set("v.showPrescriberPrimaryOfficeScreen",event.getParam("showScreen"));
            component.set("v.showPrescriberSecondaryOfficeScreen",false);
            component.set("v.showPrescriberPasswordScreen",false);
            component.set("v.showMaciConfirmEmailScreen",false);
            
        }
        
        if(event.getParam("screenName") == 'SecondaryOffice'){
            component.set("v.showPrescriberCertificationScreen",false);
            component.set("v.showPrescriberInfoScreen",false);
            component.set("v.showPrescriberPrimaryOfficeScreen",false);
            component.set("v.showPrescriberSecondaryOfficeScreen",event.getParam("showScreen"));
            component.set("v.showPrescriberPasswordScreen",false);
            component.set("v.showMaciConfirmEmailScreen",false);
            

        }
        if(event.getParam("screenName") == 'Password'){
            component.set("v.showPrescriberCertificationScreen",false);
            component.set("v.showPrescriberInfoScreen",false);
            component.set("v.showPrescriberPrimaryOfficeScreen",false);
            component.set("v.showPrescriberSecondaryOfficeScreen",false);
            component.set("v.showPrescriberPasswordScreen",event.getParam("showScreen"));
            component.set("v.showMaciConfirmEmailScreen",false);
            component.set("v.sCase",event.getParam("sCase"));
        }
        
         if(event.getParam("screenName") == 'maciEmail'){
            component.set("v.showPrescriberCertificationScreen",false);
            component.set("v.showPrescriberInfoScreen",false);
            component.set("v.showPrescriberPrimaryOfficeScreen",false);
            component.set("v.showPrescriberSecondaryOfficeScreen",false);
            component.set("v.showPrescriberPasswordScreen",false);
            component.set("v.showMaciConfirmEmailScreen",event.getParam("showScreen")); 
            component.set("v.portalUserId",event.getParam("portalUserId"));
        }
        
        if(event.getParam("screenName") == 'refreshPrescriberInformation'){
            component.set("v.showPrescriberCertificationScreen",false);
            component.set("v.showPrescriberInfoScreen",false);
            component.set("v.showPrescriberInfoScreen",event.getParam("showScreen"));
            component.set("v.showPrescriberPrimaryOfficeScreen",false);
            component.set("v.showPrescriberSecondaryOfficeScreen",false);
            component.set("v.showPrescriberPasswordScreen",false);
            component.set("v.showMaciConfirmEmailScreen",false);
            component.set("v.prescriberInfo",{"sobjectType":"Case"});
            component.set("v.prescriberNPIObj",{'firstName':'', 'middleName':'', 'lastName':'',
                                                'addressLine1':'', 'city':'','state':'','zipCode':'','confirmEmail':''});
            
            component.set("v.ShowNPIInfo",false);
              
        }

        if(event.getParam("screenName") == 'refreshPrimaryOffice'){
            component.set("v.showPrescriberCertificationScreen",false);
            component.set("v.showPrescriberInfoScreen",false);
            component.set("v.showPrescriberPrimaryOfficeScreen",false);
            component.set("v.showPrescriberPrimaryOfficeScreen",event.getParam("showScreen"));
            component.set("v.showPrescriberSecondaryOfficeScreen",false);
            component.set("v.showPrescriberPasswordScreen",false);
            component.set("v.showMaciConfirmEmailScreen",false);
            component.set("v.pCase",{"sobjectType":"Case"});
            component.set("v.primaryOtherInfoObj",{ 'firstName':'', 'lastName':'', 'confirmEmail':''});
            
        }
        
         if(event.getParam("screenName") == 'refreshSecondaryOffice'){
            component.set("v.showPrescriberCertificationScreen",false);
            component.set("v.showPrescriberInfoScreen",false);
            component.set("v.showPrescriberPrimaryOfficeScreen",false);
            component.set("v.showPrescriberSecondaryOfficeScreen",false);
            component.set("v.showMaciConfirmEmailScreen",false);
            component.set("v.showPrescriberSecondaryOfficeScreen",event.getParam("showScreen"));
            component.set("v.showPrescriberPasswordScreen",false);
            component.set("v.showMaciConfirmEmailScreen",false);
            component.set("v.sCase",{"sobjectType":"Case"});
            component.set("v.secondaryOtherInfoObj",{ 'firstName':'', 'lastName':'', 'confirmEmail':''});
        }
       
        
	}
})