({   
    getpharmacistInfo : function (component, event, helpler) {
		 var action = component.get("c.getPharmacistInfo");
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.pharmacistInfo', resultData);
                component.set("v.authorizedRepTile",component.get("v.pharmacistInfo.Title__c"));
        		component.set("v.authorizedRepTileOther",component.get("v.pharmacistInfo.Other_Title__c"));
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
    
    getTitlePicklistValues: function(component, event) {        
        var action = component.get("c.getPharmacyTitle");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var titleMap = [];
                for(var key in result){
                    titleMap.push({key: key, value: result[key]});
                } 
                component.set("v.titleMap", titleMap);
            }
        });
        $A.enqueueAction(action);
	},
    getInpatientPharmacyTypePicklistValues: function(component, event) {        
        var action = component.get("c.getInpatientPharmacyTypePicklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var pharmacyTypeMap = [];
                for(var key in result){
                    pharmacyTypeMap.push({key: key, value: result[key]});
                } 
                component.set("v.pharmacyType", pharmacyTypeMap);
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
        
    }
})