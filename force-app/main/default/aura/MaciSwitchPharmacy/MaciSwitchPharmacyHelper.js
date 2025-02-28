({
	  getpharmacyList: function(component, event) {        
        var action = component.get("c.getPharmacyList");
          action.setParams({
            programId : component.get("v.programId"),
              pharmacyType : component.get("v.pharmacyType")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var pharmacyMap = [];
                for(var key in result){
                    pharmacyMap.push({key: key, value: result[key]});
                } 
                component.set("v.pharmacyMap", pharmacyMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    navigateToInPatientMangePharmacyPage : function(component, event, helper) {
        //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'inpatient-manage-pharmacy'
        }
        };
        nav.navigate( pageReference );
    
    },
    
    navigateToMangePharmacyPage : function(component, event, helper) {
        //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'pharmacy-manage-home'
        }
        };
        nav.navigate( pageReference );
    
    },
    
    showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : titleType,
                message: errMsg,
                duration:'10000',
                key: 'info_alt',
                type: titleType,
                mode: 'pester'
            });
            toastEvent.fire();
	},
    
    
})