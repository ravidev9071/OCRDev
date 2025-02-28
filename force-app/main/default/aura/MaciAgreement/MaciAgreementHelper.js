({
	 handleInit : function(component, event) {
        
        var canvas = component.find('signature-pad').getElement();
        var ratio = Math.max(window.devicePixelRatio || 1, 1);
        canvas.width = canvas.offsetWidth * ratio;
        canvas.height = canvas.offsetHeight * ratio;
        canvas.getContext("2d").scale(ratio, ratio);
        var signaturePad = new SignaturePad(canvas, {
            minWidth: 0.85,
            maxWidth: 2
        });
        component.set("v.signaturePad", signaturePad);
    },
    
    
    checkPrescriberStatus : function(component, event) {
       var action = component.get("c.getCurrentUserAccountInfo");
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.cAccount', resultData);
				if(resultData.SYN_Signature__c == 'Yes'){
                    var nav = component.find("navigation");
                    var pageReference = {
                        type: "comm__namedPage",
                        attributes: {
                            pageName: 'prescriberhome'
                        }
                    };
                    nav.navigate( pageReference );
				}
            }
        });
        $A.enqueueAction(action);
    },
    
    
    clearCanvas : function(component, event) {
        var sig = component.get("v.signaturePad");
        sig.clear();
    },
    
    handleSaveSignature : function(component, event,helper) {
        
        var sig = component.get("v.signaturePad");
        if(!sig._isEmpty){
            var action = component.get("c.prescriberEnrollment");
             action.setParams({
                "act": component.get("v.cAccount"),
                "agreementStatus":'Signed',
                "b64SignData": sig.toDataURL().replace(/^data:image\/(png|jpg);base64,/, "")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.ShowSpinner",false);
                if (component.isValid() && state === "SUCCESS") {
                    
                    var errorReturned = response.getReturnValue();
                    component.set("v.SignatureStatus",'Signed');
                    if(errorReturned == ''){
                        component.set("v.DisableSignatureStatus",false);
                        this.showToast(component,event,'Saved Signature','success');
                        
                    } else {
                        this.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
                    }
                }else{
                   this.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    navigatetoCompletePage : function(component, event,helper) { 
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'prescriberhome'
            }
        };
        nav.navigate( pageReference );
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