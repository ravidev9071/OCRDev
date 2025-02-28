({
	doInit: function(component, event, helper) {  
        
        var action = component.get("c.getRDACaseData"); 
        action.setParams({
            createdRDACaseRecordId : component.get("v.createdRDACaseRecordId")
        });
        action.setCallback(this, function(response) {
           let result = response.getReturnValue();
            var state = response.getState();
            
           
			if(state === "SUCCESS" && result != null){
                component.set("v.newCase",result);
                
            }else{
                helper.showToast(component,event,'Something went wrong. Please check with System Admin!.','Warning');
            }
        });
        $A.enqueueAction(action); 
	},
    navigateToDashboard : function(component, event, helper) {
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
    copyCode : function(component, event, helper) {
        //var holdtxt = component.get("v.newCase.RDA_Authorization_Code__c");
        var authCOde = document.getElementById('RDAInput');
        authCOde.select();
        document.queryCommandSupported('copy')
        document.execCommand('copy');
        authCOde.blur();
	}
})