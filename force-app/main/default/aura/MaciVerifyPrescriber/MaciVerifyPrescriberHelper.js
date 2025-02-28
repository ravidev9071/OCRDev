({
	getCurrentPharmacistInfo : function(component,event){
        var pname = component.get("v.ProgramName");
        var action = component.get("c.getPharmacistInfo"); 
        action.setCallback(this, function(response) {
           let result = response.getReturnValue();
           component.set('v.authRepAccount', result);
           this.getCurrentPharmacyInfo(component,event);
        });
        $A.enqueueAction(action);    
    },
    
       getCurrentPharmacyInfo : function(component,event){
        var pname = component.get("v.ProgramName");
        var action = component.get("c.getPharmacyInfo"); 
        var userAccount = component.get("v.authRepAccount");
        action.setParams({
            acc : userAccount,
            ProgramName : pname
        });
        action.setCallback(this, function(response) {
           let result = response.getReturnValue();
           component.set('v.pharmacy', result);
        });
        $A.enqueueAction(action);    
    },
    
    validatePrescriberData : function(component,event){
        var programId = component.get("v.programId");
        var npi = component.get("v.PrescriberNPI");
        var action = component.get("c.validatePrescriberData"); 
        action.setParams({
            npi: npi,
            programId : programId 
        });
        action.setCallback(this, function(response) {
           let result = response.getReturnValue();
            component.set('v.ShowSpinner', false);
            component.set('v.prescriberAccount', result);
            if(result == null){
                component.set('v.isPrescriberDataPresent', false);
                
            }else if(result.US_WSREMS__Status__c == 'Certified'){
                component.set('v.isValidPrescriber', true);
                component.set('v.isNotValidPrescriber', false);
                component.set('v.ShowNPI', false);
                component.set('v.isPrescriberDataPresent', true);
            }else{
                component.set('v.isNotValidPrescriber', true);
                component.set('v.isValidPrescriber', false);
                component.set('v.isPrescriberDataPresent', true);
				component.set('v.ShowNPI', false);

            }
        });
        $A.enqueueAction(action);    
    },
    
     validatePatientData : function(component,event){
        var programId = component.get("v.programId");
        var fname = component.get("v.PatientFN");
        var mname = component.get("v.PatientMN");
        var lname = component.get("v.PatientLN");
        var dob = component.get("v.PatientDOB");
        var action = component.get("c.validatePatientData"); 
        action.setParams({
            fname: fname,
            mname: mname,
            lname: lname,
            dob: dob,
            programId : programId 
        });
        action.setCallback(this, function(response) {
           let result = response.getReturnValue();
            component.set('v.patientAccount', result);
            if(result == null){
                component.set('v.isPatientDataPresent', false);
            }else if(result != null && result.US_WSREMS__Status__c == 'Enrolled'){
                component.set('v.isValidPatient', true);
                component.set('v.isNotValidPatient', false);
                component.set('v.isPatientDataPresent', true);
            }else{
                component.set('v.isValidPatient', false);
                component.set('v.isNotValidPatient', true);
                component.set('v.isPatientDataPresent', true);
            }
            
            if(component.get('v.isPrescriberDataPresent') == false){
                 component.set('v.isPrescriberData', true);
            }if(component.get('v.isPatientDataPresent') == false){
                 component.set('v.isPatientData', true);
            }
            
           if(component.get("v.patientAccount.FirstName") == '' || component.get("v.patientAccount.FirstName") == undefined ||
           component.get("v.patientAccount.LastName") == '' || component.get("v.patientAccount.LastName") == undefined ||
           component.get("v.patientAccount.SYN_Ref_Id__c") == '' || component.get("v.patientAccount.SYN_Ref_Id__c") == undefined ||
           component.get("v.patientAccount.US_WSREMS__Status__c") != 'Enrolled' || 
           component.get("v.patientAccount.US_WSREMS__DOB__c") == '' || component.get("v.patientAccount.US_WSREMS__DOB__c") == undefined ||
           component.get("v.patientAccount.ShippingPostalCode") == '' || component.get("v.patientAccount.ShippingPostalCode") == undefined ||
           component.get("v.patientAccount.Patient_Reproductive_Status_Date__c") == '' || component.get("v.patientAccount.Patient_Reproductive_Status_Date__c") == undefined ||
           component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c") == '' || component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c") == undefined){
           component.set("v.patientDataCheckBool",true);
           component.set('v.Showinformation', false);
            helper.showToast(component,event,'Patient record is missing below required information: Name, REMS Id, Zip code, Patient Reproductive Status Date, Patient Risk Category.','Warning');
        }else{
            component.set("v.patientDataCheckBool",false);
        }
             
            
        });
        $A.enqueueAction(action);    
    }, 
    
    showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : titleType,
            message: errMsg,
            duration:'10000',
            key: 'info_alt',
            type: titleType,
            mode: 'pester'
        });
        toastEvent.fire();
    },

})