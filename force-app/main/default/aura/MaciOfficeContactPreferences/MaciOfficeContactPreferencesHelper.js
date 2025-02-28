({
	 handleInit : function(component, event) {
       
        var action = component.get("c.getOfficeContactAccountInfo");
        action.setCallback(this, function(result) {
             component.set('v.ShowSpinner', false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
               
                var resultData = result.getReturnValue();
                
                component.set('v.pCase', resultData);
                component.set('v.originalValue2FA', resultData.Two_Factor_Authentication_Selection__c);
                component.set('v.value2FA', resultData.Two_Factor_Authentication_Selection__c);
                if(component.get("v.value2FA") == 'Opt-Out'){
                    component.set("v.show2FAOptOut",true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    saveOfficeContactInfo : function(component, event) {
    
        var pCase = component.get("v.pCase");      
        var action = component.get("c.saveOfficeContactAccountCaseInfo");
        var programId = component.get("v.programId");
        pCase.Two_Factor_Authentication_Selection__c = component.get("v.value2FA");
        component.set('v.originalValue2FA', pCase.Two_Factor_Authentication_Selection__c);
        action.setParams({
            newCase : pCase,
            programId : programId, 
            programName : 'Macitentan REMS',
            channel : 'Portal'
         });
        action.setCallback(this, function(result) {
            component.set('v.ShowSpinner', false);
            var state = result.getState();
           
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
        
                if(resultData == ''){
                     component.set('v.isView', true);
                    this.showToast(component,event,'The change of information is updated successfully.','success'); 
                }else{
                	this.showToast(component,event,'Something went wrong, please contact system admin.','Error');
                }
            }else if (state === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : titleType,
            message: errMsg,
            duration:' 5000',
            key: 'info_alt',
            type: titleType,
            mode: 'pester'
        });
        toastEvent.fire();
    },
})