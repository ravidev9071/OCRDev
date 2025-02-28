({
    
     getCurrentAuthRepInfo : function(component,event){
        var url_string = document.location.href;         
        var url = new URL(url_string);         
        var recordId = url.searchParams.get("id");
        var action = component.get("c.checkPrescriberAccountStatus");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
            let result = response.getReturnValue();
            component.set('v.pAccount', result);
            component.set("v.recordType",component.get("v.pAccount.RecordType.DeveloperName"));
           
            if(component.get('v.pAccount.IsCustomerPortal') == true){
               component.set('v.OldUserFlag', true);
            }else{
               component.set('v.newUserFlag', true);
            }
        });
        $A.enqueueAction(action);    
    },
    
	handleNextButton: function(component,event){
        var programId = component.get("v.programId");
        var pharmacyType = component.get("v.pharmacyType");
        var profileId = component.get("v.profileId");
        var role =component.get("v.userrole");
        var pwd = component.get("v.password");
        
        var url_string = document.location.href;         
        var url = new URL(url_string);         
        var accId = url.searchParams.get("id");   
        var twoFASelection = component.get("v.value2FA");
        
       
        var action = component.get("c.createPrescriberPortalUser");
        action.setParams({
            accountId : accId,
            prescriberObj : null,
            profileId : profileId,
            role : role,
            password :pwd,
            twoFASelection : twoFASelection  
        });
        
        action.setCallback(this, function(result) {
            component.set("v.ShowSpinner",false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                
               var userId = result.getReturnValue();
                
                if(userId != null){
                    component.set("v.portalUserId",userId);
                    component.set('v.OldUserFlag', false); 
                    component.set('v.newUserFlag', false); 
                    component.set('v.confirmScreenFlag', true); 
                }else {
                    helper.showToast(component,event,'Something went wrong, please contact to system admin','error'); 
                }
            }else {
                helper.showToast(component,event,'Something went wrong, please contact to system admin','error'); 
            }
        });
        $A.enqueueAction(action);
    },
    
    
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