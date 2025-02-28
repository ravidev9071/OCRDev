({
	doInit : function(component, event, helper) {
         var action = component.get("c.updatePPAffilationActiveStatus");
         action.setParams({
             recordId : component.get("v.recordId")
         });
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var duplicateFlag = result.getReturnValue();
                if(duplicateFlag == true){
                    helper.showToast(component,event,'Primary/Secondary AR is affiliated currently with this pharmacy.  Please create a change AR service to replace the respective AR.','Error'); 
                }else{
                    helper.showToast(component,event,'Status updated successfully.','success'); 
                }
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
})