({
    getLayoutName : function(component, event, helper) {
        var params = event.getParam('arguments');
        
        if (params) {
            var PGName = params.pageLayoutName;
           
            component.set("v.objectName",params.objectName);
            component.set("v.recordtypeId",params.recordtypeId);
            helper.getLayoutSections(component,PGName);
        }
    },
    
    handleLoad : function(component, event, helper) {
        
        component.set("v.showSpinner", false);   
    },
    
    handleSubmit : function(component, event, helper) {
        
        var recordTypeId = component.get("v.recordtypeId");
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        eventFields.RecordTypeId = recordTypeId;
        component.find('myform').submit(eventFields);
        component.set("v.showSpinner",true);
        
    },
    handleSuccess : function(component, event, helper) {
       
         helper.navigateToRecord(component, event, helper);
        
    },
    handleError : function(component, event, helper) {
        
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            "title": "Error!",
            "message": event.getParam("detail"),
            "type": "error"
        });
        
        component.set("v.showSpinner",false);
        
    },
    handleFieldChange : function(component, event, helper){
        
        
        
        let fieldName = event.getSource().get("v.fieldName") ; 
        let newValue =  event.getSource().get("v.value") ;
        
        
        if (newValue){
             
            helper.getPrepopulationFields(component, event, helper , newValue);
        }
    },
    onclick: function(component, event, helper){
        
    },
    cancel: function(component, event, helper){
        helper.previousScreen(component, event, helper);
    }
})