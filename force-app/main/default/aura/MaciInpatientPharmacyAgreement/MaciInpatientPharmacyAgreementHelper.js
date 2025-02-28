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
    clearCanvas : function(component, event) {
        var sig = component.get("v.signaturePad");
        sig.clear();
    },
    getloggedinUserAccount : function(component, event) {
       var action = component.get("c.getCurrentUserAccountInfo");
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.cAccount', resultData);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSaveSignature : function(component, event,helper) {
        var sig = component.get("v.signaturePad");
        if(!sig._isEmpty){
            var action = component.get("c.saveSignatureAttachment");
             action.setParams({
                "act": component.get("v.pharmacistInfo"),
                "agreementStatus":'Signed',
                "b64SignData": sig.toDataURL().replace(/^data:image\/(png|jpg);base64,/, ""),
                 "pharmacyactId" : component.get("v.accountId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    
                    var errorReturned = response.getReturnValue();
                    if(errorReturned == ''){
                       //this.insertPharmacyInfo(component, event,helper);
                       this.getPharmacyEnrollmentInfo(component, event);  
                    } else {
                        component.set("v.ShowSpinner",false);
                        this.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
                    }
                }else{
                  	component.set("v.ShowSpinner",false);
                   this.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    insertPharmacyInfo : function(component, event,helper) { 
        // Set pharmacy Type, Program, Channel values
        component.set("v.newCase.Pharmacy_Type__c",'Inpatient');
        component.set("v.newCase.US_WSREMS__Program_Picklist__c",'Macitentan REMS');
        component.set("v.newCase.US_WSREMS__Channel__c",'Portal');

        var sig = component.get("v.signaturePad");
        if(!sig._isEmpty){
            var action = component.get("c.insertPharmacyInfo");
             action.setParams({
                "enrollRecTypeDevName":'SYN_Inpatient_Pharmacy',
                "pharmcCase": component.get("v.newCase"),
                "act": component.get("v.pharmacistInfo"),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    
                    var accountId = response.getReturnValue();

                    if(accountId != ''){
                        component.set("v.accountId",accountId)
                        this.handleSaveSignature(component, event);
                        //this.getPharmacyEnrollmentInfo(component, event);  
                    }else {
                        component.set("v.ShowSpinner",false);
                        this.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
                    }
                }else{
                    component.set("v.ShowSpinner",false);
                   this.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getPharmacyEnrollmentInfo : function(component, event,helper) {

        var sig = component.get("v.signaturePad");
        if(!sig._isEmpty){
            var action = component.get("c.getPharmacyEnrollmentInfo");
             action.setParams({
                "enrollRecTypeDevName":'SYN_Inpatient_Pharmacy',
                "pharmcCase": component.get("v.newCase"),
                "act": component.get("v.pharmacistInfo"),
                "createdPharmacyAccountID" : component.get("v.accountId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    
                    var pCase = response.getReturnValue();
                   
                    if(pCase != ''){
                        component.set("v.pharmacyEnrollementCase",pCase);
                        this.insertPharmacyEnrollmentCase(component, event);  
                    }else {
                         component.set("v.ShowSpinner",false);
                        this.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
                    }
                }else{
                     component.set("v.ShowSpinner",false);
                   this.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    insertPharmacyEnrollmentCase : function(component, event,helper) {
        var sig = component.get("v.signaturePad");
        if(!sig._isEmpty){
            var action = component.get("c.insertPharmacyEnrollmentCase");
             action.setParams({
                "pharmacyEnrollmentCase": component.get("v.pharmacyEnrollementCase"),
                "pharmcCase": component.get("v.newCase"),
                "createdPharmacyAccountID" : component.get("v.accountId"),
                "agreementStatus":'Signed',
                "b64SignData": sig.toDataURL().replace(/^data:image\/(png|jpg);base64,/, "")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                 component.set("v.ShowSpinner",false);
                if (component.isValid() && state === "SUCCESS") {
                    
                    var result = response.getReturnValue();
                    
                    if(result == ''){   
                         
                        component.set("v.pharmacistInfo.SYN_Signature__c",'Signed');
                        component.set("v.SignatureStatus",'Signed');
                        component.set("v.DisableSignatureStatus",false);
                        this.showToast(component,event,'Saved Signature','success');
                        
                    }else {
                         component.set("v.ShowSpinner",false);
                        this.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
                    }
                }else{
                     component.set("v.ShowSpinner",false);
                   this.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    updatePharmacyParticipantAffiliation : function(component, event) {
       var action = component.get("c.updatePharmacyParticipantAffiliation");
         action.setCallback(this, function(result) {
             action.setParams({
                 "pharmacyArAccount": component.get("v.pharmacistInfo"),
                 "pharmacyAcctId": component.get("v.accountId")
             });
            var state = result.getState();
              component.set("v.ShowSpinner",false);
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                if(resultData == ''){
                    component.set("v.pharmacistInfo.SYN_Signature__c",'Signed');
                    component.set("v.SignatureStatus",'Signed');
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