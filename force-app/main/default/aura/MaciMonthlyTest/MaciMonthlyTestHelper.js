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
        
        var action = component.get("c.getPatientPregnancyInfo");
        var patientAccount= component.get("v.patientID");
     
        action.setParams({
            program : 'Macitentan REMS',
            patientId : patientAccount
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.isLoading', false);
                var resultData = result.getReturnValue();
                component.set('v.pAccount', resultData);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleCompleteCreation : function(component, event) {
        component.set('v.isLoading', true);
        var programId = component.get("v.programId");
        var patientAccount= component.get("v.patientID");
         if(!patientAccount.startsWith('001')) {
            patientAccount = component.get("v.pAccount.Id");
         }
        var prescriberAccount= component.get("v.cAccount");
        
        var action = component.get("c.createPatientPregancyRecords");
        action.setParams({
            program : programId,
            patientId : patientAccount,
            prescriber : prescriberAccount,
            programName : 'Macitentan REMS',
			channel : 'Portal'
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                this.navigateToManagePatients(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    navigateToManagePatients : function(component, event) {
        component.set('v.isLoading', false);
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'manage-patients'
            }
        };
        nav.navigate( pageReference ); 
    }
})