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
        var action = component.get("c.getPrescriberAndPatientPregnancyInfo");
        var patientAccount= component.get("v.patientID");
        action.setParams({
            program : component.get("v.programId"),
            PatientId : patientAccount
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
        var prescriberAccount= component.get("v.pAccount.SYN_Prescriber__c");
        var prepatid= patientAccount+'_'+prescriberAccount;
        var action = component.get("c.createPatientPregancyRecords");
        action.setParams({
            program : programId,
            patientId : prepatid,
            prescriber : null,
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
                pageName: 'officecontacthome'
            }
        };
        nav.navigate( pageReference ); 
    }
})