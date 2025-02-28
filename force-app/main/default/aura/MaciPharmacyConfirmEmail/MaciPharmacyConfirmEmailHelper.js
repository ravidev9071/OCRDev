({
	sendConfirmationEmail : function(component, event, helper) {
         
        $( "#flexCheckDefault" ).prop( "checked", false );
        
        var poratlUserId = component.get("v.portalUserId");
		var action = component.get("c.reSendConfimarionEmail");
        action.setParams({
            userId : poratlUserId
        });
        
        action.setCallback(this, function(result) {
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                
               var result = result.getReturnValue();
               
                if(result == true){
                    helper.showToast(component,event,'Successfully, Email sent.','Success'); 
                }else {
                    helper.showToast(component,event,'We are unable to process your request, please contact the Macitentan REMS Coordinating Center at 1-888-572-2934 for assistance','error'); 
                }
            }else {
                helper.showToast(component,event,'Something went wrong, please contact to system admin','error'); 
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