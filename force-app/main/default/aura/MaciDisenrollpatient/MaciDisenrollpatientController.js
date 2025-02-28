({
	doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        var url_string = document.location.href;
        var url = new URL(url_string);         
        var recordId = url.searchParams.get("id");
        component.set("v.patientID",recordId);
        helper.handleInit(component, event);
        helper.getDissEnrollmentReasonPicklist(component, event);
        
        debugger;
        var url_string = document.location.href;
        var url = new URL(url_string);         
        var patientRiskCategory = url.searchParams.get("PatientRiskCategory");
     
	},
    
    termsConidtionSelect : function(component, event, helper) {
        var tflag = $("#flexCheckDefault").is(':checked');
        component.set("v.termsFlag",tflag);
    },
    
    DiscontinuedTherapySelect : function(component, event, helper) {
        component.set("v.dCase.US_WSREMS__Deactivation_Reason__c",'Discontinued Therapy');
    },
    
    PatientDecisionSelect : function(component, event, helper) {
        component.set("v.dCase.US_WSREMS__Deactivation_Reason__c",'Patient Decision');
    },
    
    PrescriberDecisionSelect : function(component, event, helper) {
        component.set("v.dCase.US_WSREMS__Deactivation_Reason__c",'Prescriber Decision');
    },
    
    PatientDeathSelect : function(component, event, helper) {
        component.set("v.dCase.US_WSREMS__Deactivation_Reason__c",'Patient Death');
    },
    
    DuplicateSelect : function(component, event, helper) {
        component.set("v.dCase.US_WSREMS__Deactivation_Reason__c",'Duplicate');
    },
    
    disenrollPatient : function(component, event, helper) {
      var tcflag =   component.get("v.termsFlag");
      var deactivereason = component.get("v.dCase.US_WSREMS__Deactivation_Reason__c");
        if(tcflag == false){
            helper.showToast(component,event,'Please select terms and conditions.','Warning');
        }else if (deactivereason == '' || deactivereason == null || deactivereason == undefined || deactivereason == '--None--'){
            helper.showToast(component,event,'Please select disenroll reason.','Warning');
        }else{
            component.set('v.isLoading', true);
            helper.handleNextButton(component,event);
        }
      
	},
    
    handleDeactiveReasonChange : function(component, event, helper) {
        var profdesg =$("#pd").val();
        component.set("v.dCase.US_WSREMS__Deactivation_Reason__c",profdesg);
    },
})