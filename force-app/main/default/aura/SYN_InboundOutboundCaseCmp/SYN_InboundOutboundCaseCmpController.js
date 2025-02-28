({
	doInit: function( component, event, helper ) {
       
         var myPageRef = component.get("v.pageReference");
        var res=myPageRef.state.c__caserecordId;
        component.set("v.caserecordId",res);
        var recordId = component.get("v.caserecordId");
		var action = component.get("c.getPageLayoutforRequestorType");
        action.setParams({ remsCaseId : recordId});
		action.setCallback(this, function(response) {
        	var state = response.getState();
			if (state === "SUCCESS") {
                var returnedValue = response.getReturnValue();
                component.set("v.layoutName", returnedValue.pageLayoutName);
                component.set("v.caseRecordTypeId", returnedValue.caseRecordTypeId);
                component.set("v.requestorType", returnedValue.requestorType);
                helper.getLayoutSections(component);
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
				console.log( errors );
            }
        });
        
        $A.enqueueAction(action);

    },
    handleLoad : function(component, event, helper) {
    	component.set("v.showSpinner", false);   
    },
    handleSubmit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var recordTypeId = component.get("v.caseRecordTypeId");
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        eventFields.REMS_Service_Summary__c = recordId;
        eventFields.RecordTypeId = recordTypeId;
         
        component.find('myform').submit(eventFields);
    },
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Case record is Updated.",
            "type": "success"
        });
        toastEvent.fire();
       
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
        
    },
    handleError : function(component, event, helper) {
     
        var toastEvent = $A.get("e.force:showToast");
         
        toastEvent.setParams({
            "title": "Error!",
            "message": event.getParam("detail"),
            "type": "error"
        });
       
        toastEvent.fire();
        
     
        
    }
})