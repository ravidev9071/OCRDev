({
    
    doInit : function(component, event, helper) {
        var action = component.get("c.getCurrentUserAccountInfo");
        if(component.get('v.prescriberNPI') != undefined && component.get('v.prescriberNPI')!= '' && component.get('v.prescriberNPI')!= null) {
            component.set('v.selectedPrescriber', component.get('v.prescriberNPI')); 
        }
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.cAccount', resultData);
                helper.getPrescriberList(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleNext : function(component, event, helper) {
        var errorMsg='';
        if (component.get("v.selectedPrescriber") == undefined || component.get("v.selectedPrescriber") == ''){
            errorMsg += 'Prescriber'
        }
         if (errorMsg){
            errorMsg = 'Please select '+errorMsg;
            helper.showToast(component,event,errorMsg,'Warning');
         }else{
             helper.handleNext(component, event, helper);
         }        
    },
      savePrescriberDetails: function(component, event, helper) {
        component.set('v.prescriberName', event.getParam("prescriberName"));
        component.set('v.prescriberNPI', event.getParam("prescriberNPI"));
    },
    handleChange: function(component, event, helper) {
        debugger;
        var selectedValue = event.getSource().get("v.value");
        var prescribers = component.get("v.prescribers");
        var selectedPrescriber = prescribers.find(prescriber => prescriber.value === selectedValue);
          

        if (selectedPrescriber) {
            var evt = component.getEvent("PrescriberDetails");
            
            evt.setParams({
                "prescriberName": selectedPrescriber.label,
                "prescriberNPI": selectedPrescriber.value
            });
            evt.fire();
        }
    }

})