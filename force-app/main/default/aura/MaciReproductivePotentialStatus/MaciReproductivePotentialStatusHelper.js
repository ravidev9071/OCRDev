({
	handleNextButton: function(component,event){
        var programId = component.get("v.programId");
        component.set("v.pCase.US_WSREMS__REMS_Program__c",programId);
        component.set("v.pCase.US_WSREMS__Program_Picklist__c",'Macitentan REMS');
        component.set("v.pCase.US_WSREMS__Channel__c",'Portal');
        var prescriberInfo ;
        if(component.get("v.isOfficeContact") == true){
          prescriberInfo = component.get("v.prescriberNPI");
    }else{
         prescriberInfo = component.get("v.cAccount");
}
        var patientInfo = component.get("v.newCase");
        var pcase = component.get("v.pCase");
        var lcase = component.get("v.lCase");
        var caseDetails = component.get("v.caseDetail");
        var isFromOfficeContact = component.get("v.isFromOfficeContact");
        var alternateContactInfoInfo = Object.assign(pcase, lcase,caseDetails);
        var reproductivePotentialInfo = component.get("v.rCase");
        var patientData = Object.assign(patientInfo, alternateContactInfoInfo);
        var patientEnrollData = Object.assign(patientInfo,alternateContactInfoInfo, reproductivePotentialInfo);
        
		
      
        var action = component.get("c.patientEnrollment");
        if(component.get("v.isOfficeContact") == true){
        action.setParams({
            patientAccountInfo : patientData,
            patientEnrollmentInfo : patientEnrollData,
            prescNPI : prescriberInfo,
            prescriberAccount:null,
            officeContact:isFromOfficeContact
            
        });
    }else{
         if(component.get("v.isFromOfficeContact") == true){
         action.setParams({
            patientAccountInfo : patientData,
            patientEnrollmentInfo : patientEnrollData,
            prescriberAccount : prescriberInfo,
             prescNPI:null,
             officeContact:isFromOfficeContact
            
        });
         }else{
              action.setParams({
            patientAccountInfo : patientData,
            patientEnrollmentInfo : patientEnrollData,
            prescriberAccount : prescriberInfo,
             prescNPI:null,
            officeContact:isFromOfficeContact
            
        });
}
}
        
        
        action.setCallback(this, function(result) {
            component.set("v.ShowSpinner",false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var patientId = result.getReturnValue();
                if(patientId != null){
                 
                        var evt = component.getEvent("ShowPatientEnrollmentScreens");
                        evt.setParams({
                            "screenName": "ShowPatientAgreementInformationScreen",
                            
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
        if(component.get("v.isOfficeContact") == true){
        var evt = component.getEvent("ShowPatientEnrollmentScreens");
        evt.setParams({
            "screenName": "refreshShowPotentialStatusInformationScreen",
        });
        evt.fire();        
        }
        else{
        var evt = component.getEvent("ShowPatientEnrollmentScreens");
        evt.setParams({
            "screenName": "refreshShowPotentialStatusInformationScreen",
        });
        evt.fire();
        }
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