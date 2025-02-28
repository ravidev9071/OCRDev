({
    doInit: function( component, event, helper ) {
        var recordId = component.get("v.recordId");
        var isFlow = component.get("v.isFlow");
        var requestorType = component.get("v.requestorType"); 
        var REMSServiceId = component.get("v.REMSServiceId"); 
        if(recordId){
            component.set("v.objectRecordId", recordId);
        }
		
		var action = component.get("c.getPageLayoutforRequestorType");
        action.setParams({ caseRecordId : recordId , isFlow : isFlow, requestorType : requestorType, RemsServiceId : REMSServiceId });
		action.setCallback(this, function(response) {
        	var state = response.getState();
			if (state === "SUCCESS") {
                var returnedValue = response.getReturnValue();
                
                component.set("v.layoutName", returnedValue.pageLayoutName );
                if(!isFlow){
                    component.set("v.selectedId", returnedValue.caseRecord.US_WSREMS__Primary_Facility__c);
                }
                
                
                helper.getLayoutSections(component);
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
				console.log( errors );
            }
        });
        
        $A.enqueueAction(action);
        helper.getRecordtypes(component,event,helper);

    },
    
    
	handleSuccess : function(component, event, helper) {
        var isFlow = component.get("v.isFlow");
        if(isFlow){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Case record is created.",
                "type": "success"
            });
            toastEvent.fire();
        
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Case record is saved.",
                "type": "success"
            });
            toastEvent.fire();
        }
        
    },
    handleLoad : function(component, event, helper) {
    	component.set("v.showSpinner", false);   
    },
    handleSubmit : function(component, event, helper) {
        var isFlow = component.get("v.isFlow");
        var REMSId = component.get("v.REMSServiceId");
        console.log("value of the boolean is flow is==>", isFlow);
        console.log("value of teh REMS Id is==>>", REMSId);
        var selectedId = component.get("v.selectedId");
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        eventFields.Primary_Facility__c = selectedId;
        if(isFlow){
            eventFields.US_WSREMS__REMS_Service_Summary__c = REMSId;
        }
        component.find('myform').submit(eventFields);
    },
    
    handleFieldChange : function(component, event, helper){
        let fieldName = event.getSource().get("v.fieldName") ; 
        let newValue =  event.getSource().get("v.value") ;
        if (newValue){
            helper.getPrepopulationFields(component, event, helper , newValue);
        }
    }
})