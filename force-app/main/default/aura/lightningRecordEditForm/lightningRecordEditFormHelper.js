({
	getLayoutSections : function(component) {
		var ob= component.get("v.objectName");
        var ly= component.get("v.layoutName");
        
        var action = component.get("c.getPageLayoutFields");
        action.setParams({ str : ly });
		action.setCallback(this, function(response) {
        	var state = response.getState();
			if (state === "SUCCESS") {
                component.set("v.layoutSections", response.getReturnValue() );
				
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
				console.log( errors );
            }
        });
        
        $A.enqueueAction(action);
	},
    getRecordtypes :  function(component,event,helper) {
        var action = component.get("c.getAllRecordTypeDetails");
        action.setParams({
            "objName":'Case' 
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS') {
               
                var enrollMentType = component.get("v.enrollmentType");
                var resp = response.getReturnValue();
                var rectypeId ='';
                if(enrollMentType === 'HCFEnrollment')  {
                    
                    
                    component.set("v.recordtypeId",resp['Pharmacy_Enrollment']);
                } else if(enrollMentType === 'HCPEnrollment') {
                    
                    
                     component.set("v.recordtypeId",resp['Pharmacy_Enrollment']);
                }
             
            }
        })
        $A.enqueueAction(action);
    },
    getPrepopulationFields : function (component, event, helper , recId){
        
        
        var targetObj = component.get("v.objectName");
        var targetRCtyId = component.get("v.recordtypeId");
        
        var action = component.get("c.getPrepopFields");
        
        action.setParams({ recordId : recId , TargetObj : targetObj ,  RecordTypeId : targetRCtyId });
        action.setCallback(this,function(res){
            var state = res.getState();
            
            if (state === "SUCCESS") {
                
                var TargetFieldValues = res.getReturnValue();
                for (var index in component.find("InputField")) { 
                    var fieldName = component.find("InputField")[index].get("v.fieldName");
                    if (fieldName){ 
                        
                        if (TargetFieldValues[fieldName]){
                            
                            component.find("InputField")[index].set("v.value",TargetFieldValues[fieldName]);
                        }
                        
                    }
                    
                }
                
                
            }
            else if (state === "INCOMPLETE") {
                component.set("v.showSpinner", false);
            }
                else if (state === "ERROR") {
                    component.set("v.showSpinner", false);
                    var errors = response.getError();
                    console.log( errors );
                }
            
        });
        $A.enqueueAction(action);
    }
})