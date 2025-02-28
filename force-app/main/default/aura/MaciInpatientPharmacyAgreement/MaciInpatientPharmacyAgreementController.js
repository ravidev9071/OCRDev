({
	doInit : function(component, event, helper) {
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
        	helper.insertPharmacyInfo(component, event,helper);
        }
    },
  
    handleNext : function(component, event, helper){
        var signatureStatus  = component.get("v.pharmacistInfo.SYN_Signature__c");
        var termsCondition  = component.get("v.termsFlag");
        if(termsCondition == false){
            helper.showToast(component,event,'Please accept the terms & conditions','Warning'); 
        }else if(signatureStatus != 'Signed'){
            helper.showToast(component,event,'Signature is required','Warning'); 
        }else if(signatureStatus == 'Signed'){
            
            //Navigate to Complete Page
            var nav = component.find("navigation");
            var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'complete-inpatient'
            }
            };
            nav.navigate( pageReference );
        }
    },
    saveSignatureOnClickSecond: function(component, event, helper){
        helper.showToast(component,event,'Request is already submitted!','Warning');
    },
    clearSignatureOnClickSecond: function(component, event, helper){
        helper.showToast(component,event,'Request is already submitted!','Warning');
    },
    
    termsConidtionSelect : function(component, event, helper) {
        var tflag = $("#flexCheckDefault").is(':checked');
        component.set("v.termsFlag",tflag);
    }
})