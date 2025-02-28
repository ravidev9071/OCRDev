({
	doInit : function(component, event, helper) {
         var action = component.get("c.updatePPActiveStatus");
         action.setParams({
             recordId : component.get("v.recordId")
         });
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                helper.showToast(component,event,'Status updated successfully.','success'); 
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
})