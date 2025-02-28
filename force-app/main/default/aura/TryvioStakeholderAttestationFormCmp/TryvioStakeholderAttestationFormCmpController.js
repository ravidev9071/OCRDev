({
	doInit : function(component,event,helper){ 
        
        helper.getCurrentPatientInfo(component,event);
        var url_string = document.location.href;         
        var url = new URL(url_string);         
        var idlead = url.searchParams.get("id");         
        helper.handleInit(component, event);

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
            setTimeout(function() {
                window.close();
            },13000);
        }
    },
})