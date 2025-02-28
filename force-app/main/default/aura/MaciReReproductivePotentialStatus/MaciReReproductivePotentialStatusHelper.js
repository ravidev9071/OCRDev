({
	handleNextButton: function(component,event){
        var programId = component.get("v.programId");
        component.set("v.pCase.US_WSREMS__REMS_Program__c",programId);
        component.set("v.pCase.US_WSREMS__Program_Picklist__c",'Macitentan REMS');
        component.set("v.pCase.US_WSREMS__Channel__c",'Portal');
        if(component.get("v.rCase.US_WSREMS__Patient_Risk_Category__c") != "Female of Reproductive Potential (FRP)"){
            component.set("v.rCase.Negative_Pregnancy_Test_Completed__c",'');
        }
        var prescriberInfo = component.get("v.cAccount");
        var patientInfo = component.get("v.newCase");
        
        var pcase = component.get("v.pCase");
        var lcase = component.get("v.lCase");
        var alternateContactInfoInfo = Object.assign(pcase, lcase);
        var reproductivePotentialInfo = component.get("v.rCase");
        var patientData = Object.assign(patientInfo, alternateContactInfoInfo);
        var patientEnrollData = Object.assign(patientInfo,alternateContactInfoInfo, reproductivePotentialInfo);
        
		
        
        var action = component.get("c.createPatientReEnrollment");
        action.setParams({
            reEnrollCase : patientEnrollData,
            programId : programId
        });
        
        action.setCallback(this, function(result) {
            component.set("v.ShowSpinner",false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                
                var patientId = result.getReturnValue();
                
                if(patientId != null){
                    var evt = component.getEvent("ShowPatientEnrollmentScreens");
                    evt.setParams({
                        "screenName": "ShowPatientAgreementInformationScreen"
                    });
                    evt.fire();
                    
                }else {
                    console.log('--Error----');
                }
            }
        });
        $A.enqueueAction(action);
        

    },
    
    handleRefresh: function(component,event){
        component.set("v.FemalesofReproductivePotentialValue",false);
        component.set("v.PrepubertalFemaleValue",false);
        component.set("v.PostmenopausalFemaleValue",false);
        component.set("v.OtherMedicalValue",false);
        component.set("v.PregnancyYes",false);
        component.set("v.PregnancyNo",false);
        component.set("v.isCertify",false);
        var evt = component.getEvent("ShowPatientEnrollmentScreens");
        evt.setParams({
            "screenName": "refreshShowPotentialStatusInformationScreen",
        });
        evt.fire();
    },
    
     fireEvent: function(component,event,screenName){
        var evt = component.getEvent("ShowPatientEnrollmentScreens");
        evt.setParams({
            "screenName": screenName,
            "isPatientMinor":component.get("v.isPatientMinor")
        }).fire();
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