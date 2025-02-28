({
	doInit : function(component, event, helper) {
        helper.handleInit(component, event);
        helper.checkPrescriberStatus(component, event);
    },
    
    clearSignatureOnClick : function(component, event, helper){
        helper.clearCanvas(component, event);
    },
    saveSignatureOnClick : function(component, event, helper){
        var sig = component.get("v.signaturePad");
        
        var termsCondition  = component.get("v.termsFlag");
        if(termsCondition == false){
            helper.showToast(component,event,'Please accept the terms & conditions','Warning'); 
        }else if(sig._isEmpty){
            helper.showToast(component,event,'Without signature, you cannot save it.','Warning'); 
        }else{
            component.set("v.ShowSpinner",true);
        	helper.handleSaveSignature(component, event,helper);
        }
    },
    handleTerms :function(component, event, helper){
        
    },
    handleNext : function(component, event, helper){
        var signatureStatus  = component.get("v.SignatureStatus");
        var termsCondition  = component.get("v.termsFlag");
        if(termsCondition == false){
            helper.showToast(component,event,'Please accept the terms & conditions','Warning'); 
        }else if(signatureStatus != 'Signed'){
            helper.showToast(component,event,'Signature is required','Warning'); 
        }else{
            var nav = component.find("navigation");
            var pageReference = {
                type: "comm__namedPage",
                attributes: {
                    pageName: 'prescriberhome'
                }
            };
            nav.navigate( pageReference );
            helper.navigatetoCompletePage(component, event,helper);
        }
    },
    
})