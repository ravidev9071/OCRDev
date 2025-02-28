({
	doInit: function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.getCurrentPharmacistInfo(component,event);
		
	},
	
    VerifyPrescriberPatientInfo: function(component, event, helper) { 
        var npi = component.get("v.PrescriberNPI");
        var numberpattern = /^(\s*\d\s*){10}$/;
         var fname = component.get("v.PatientFN");
        var mname = component.get("v.PatientMN");
        var lname = component.get("v.PatientLN");
        var dob = component.get("v.PatientDOB");
      
        if(npi == '' || npi == undefined || fname == '' || fname == undefined || lname == '' || lname == undefined || dob == '' || dob == undefined){
            helper.showToast(component,event,'All fields except M.I. are required to continue.','Warning');
        }else if(npi != '' && npi != undefined && npi.length <10){
            helper.showToast(component,event,'Prescriber NPI should be 10 digits.','Warning');
        }else if(npi != '' && npi != undefined && !npi.match(numberpattern)){
            helper.showToast(component,event,'Prescriber NPI should contain 10 digits.','Warning');
        }else{
            component.set('v.isverifydata',false);
            component.set('v.ShowSpinner', true);
            component.set('v.isPrescriberandPatientData', false);
            component.set('v.isPrescriberData', false);
            component.set('v.isPatientData', false);
            helper.validatePrescriberData(component,event);
            helper.validatePatientData(component,event);
        }
    },
    
     navigateToDashboard : function(component, event) {
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'inpatient-manage-pharmacy'
        }
        };
        nav.navigate( pageReference );
    
    },
    refreshCurrentPage: function(component, event, helper) {  
        $A.get('e.force:refreshView').fire();
    },
})