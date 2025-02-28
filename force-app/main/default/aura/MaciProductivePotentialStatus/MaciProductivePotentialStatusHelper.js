({
    handleInit : function(component, event) {
        var action = component.get("c.getCurrentUserAccountInfo");
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.prescriberAccount', resultData);
                this.getCurrentPrescriberPatientInfo(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCurrentPrescriberPatientInfo : function(component, event) {
       
        var action = component.get("c.getPatientPregnancyInfo");
        var patientAccount= component.get("v.patientID");
        
        action.setParams({
            program : 'Macitentan REMS',
            patientId : patientAccount
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.ShowSpinner', false);
                var resultData = result.getReturnValue();
                component.set('v.patientAccount', resultData);
                component.set("v.rCase.US_WSREMS__DOB__c",resultData.US_WSREMS__DOB__c);
                
               if(resultData.US_WSREMS__Patient_Risk_Category__c =='Female of Reproductive Potential (FRP)')  {
                    component.set("v.FemalesofReproductivePotentialValue",true);
                   $("[id$=AnnualVerify]").attr("disabled",true);
                } 
                
                if(resultData.US_WSREMS__Patient_Risk_Category__c =='FNRP (Patient is pre-pubertal)')  {
                    component.set("v.PrepubertalFemaleValue",true);
                }
                
                 if(resultData.US_WSREMS__Patient_Risk_Category__c =='FNRP (other medical reasons for permanent irreversible infertility)'){
                    component.set("v.OtherMedicalValue",true);
                     $("[id$=AnnualVerify]").attr("disabled",true);
                }
                 if(resultData.US_WSREMS__Patient_Risk_Category__c =='FNRP (Patient is post-menopausal)')  {
                    component.set("v.PostmenopausalFemaleValue",true);
                     $("[id$=AnnualVerify]").attr("disabled",true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    
        createChangeReproductiveStatusCase : function(component, event) {
        component.set('v.ShowSpinner', true);
        var programId = component.get("v.programId");
        var patientAccount= component.get("v.patientID");
        var prescriberAccount= component.get("v.prescriberAccount");
        var prescriberCase= component.get("v.rCase");     
        var action = component.get("c.createChangeReproductiveStatusRecord");
        action.setParams({
            program : programId,
            patientId : patientAccount,
            prescriber : prescriberAccount,
            programName : 'Macitentan REMS',
            channel : 'Portal',
            prescriberCase : prescriberCase
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                this.navigateToManagePatients(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    navigateToManagePatients : function(component, event) {
        component.set('v.ShowSpinner', false);
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'manage-patients'
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