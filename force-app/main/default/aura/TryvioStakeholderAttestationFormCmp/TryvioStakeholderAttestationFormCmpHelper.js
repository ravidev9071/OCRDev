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
    
    getCurrentPatientInfo : function(component,event){
        var url_string = document.location.href;         
        var url = new URL(url_string);         
        var recordId = url.searchParams.get("id");         
        var action = component.get("c.getCurrentPatientInfo");
        action.setParams({
            caseId : recordId
        });
        action.setCallback(this, function(response) {
            let result = response.getReturnValue();
            
            component.set('v.patient', result);
            if(component.get('v.patient.US_WSREMS__Signature__c') == 'Yes'){
               component.set('v.isEnrolled', false); 
            }
            if(component.get('v.patient.US_WSREMS__Middle_Name__c') != '' && component.get('v.patient.US_WSREMS__Middle_Name__c') != undefined){
                component.set('v.patientName', component.get('v.patient.US_WSREMS__First_Name__c') +' '+component.get('v.patient.US_WSREMS__Middle_Name__c')+' '+component.get('v.patient.US_WSREMS__Last_Name__c')); 
            }else{
                component.set('v.patientName', component.get('v.patient.US_WSREMS__First_Name__c') +' '+component.get('v.patient.US_WSREMS__Last_Name__c')); 
            }
        });
        $A.enqueueAction(action);    
    },
    
    handleSaveSignature : function(component, event,helper) {
        var sig = component.get("v.signaturePad");
        if(!sig._isEmpty){
            var action = component.get("c.saveSignature");
             action.setParams({
                "caseObj": component.get("v.patient"),
                "agreementStatus":'Signed',
                "b64SignData": sig.toDataURL().replace(/^data:image\/(png|jpg);base64,/, "")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    //this.clearCanvas(component, event);
                    var errorReturned = response.getReturnValue();
                    component.set("v.SignatureStatus",'Signed');
                    if(errorReturned == ''){
                      // this.addAttachment(component, event,helper);
                    }else {
                        this.showToast(component,event,'Signature Submitted Successfully','Success'); 
                    }
                }else{
                    this.showToast(component,event,'Signature Submitted Successfully','Success'); 
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    addAttachment : function(component, event,helper) {
        var sig = component.get("v.signaturePad");
        if(!sig._isEmpty){
            var action = component.get("c.addPatientEnrollmentFormtoAccount");
             action.setParams({
                "caseObj": component.get("v.patient"),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.ShowSpinner",false);
                if (component.isValid() && state === "SUCCESS") {
                    
                    var errorReturned = response.getReturnValue();
                    console.log('response.getReturnValue()---'+response.getReturnValue());
                    component.set("v.SignatureStatus",'Signed');
                    if(errorReturned == ''){
                        component.set("v.DisableSignatureStatus",false);
                        component.set('v.isEnrolled', false); 
                    }else {
                        this.showToast(component,event,'Signature Submitted Successfully','Success'); 
                    }
                }else{
                    this.showToast(component,event,'Signature Submitted Successfully','Success'); 
                }
            });
            $A.enqueueAction(action);
        }
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