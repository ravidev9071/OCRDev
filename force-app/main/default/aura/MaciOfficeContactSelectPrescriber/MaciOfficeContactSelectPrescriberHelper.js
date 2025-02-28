({
    handleNext: function(component, event, helper) {
        var evt = component.getEvent("ShowOCPatientEnrollmentScreens");
         evt.setParams({
             "screenName": "ShowInstructionScreen"
         });
         evt.fire();
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
   
    getPrescriberList: function(component, event, helper) {
        debugger;
        var action = component.get("c.getOCAssociatedPrescriberList");
        action.setParams({
            "officeContact": component.get("v.cAccount")
        });
        action.setCallback(this, function(result) {
           var state = result.getState();
           if (component.isValid() && state === "SUCCESS"){
               let resultData = result.getReturnValue();
               var options = [];
               Object.entries(resultData).forEach(function(element) {
                    options.push({ value: element[0], label: element[1] });
                });

               component.set('v.prescribers', options);

               evt.fire();  
           }
       });
       $A.enqueueAction(action);
   
    }
})