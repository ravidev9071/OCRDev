({
    getCurrentPharmacistInfo : function(component,event){
        var pname = component.get("v.ProgramName");
        var action = component.get("c.getPharmacistInfo"); 
        action.setCallback(this, function(response) {
            let result = response.getReturnValue();
            
            component.set('v.pharmacist', result);
            this.getCurrentPharmacyInfo(component,event);
        });
        $A.enqueueAction(action);    
    },
    
    getCurrentPharmacyInfo : function(component,event){
        var pname = component.get("v.ProgramName");
        var action = component.get("c.getPharmacyInfo"); 
        var userAccount = component.get("v.pharmacist");
        action.setParams({
            acc : userAccount,
            ProgramName : pname
        });
        action.setCallback(this, function(response) {
            let result = response.getReturnValue();
            
            component.set('v.isLoading', false);
            component.set('v.pharmacy', result);
        });
        $A.enqueueAction(action);    
    },
	
    validatePatientData : function(component, event, helper) {
        component.set("v.patientNA",false);
        var fname=component.get("v.newAccount.FirstName");
        var lname = component.get("v.newAccount.LastName");
        var dob = component.get("v.newAccount.US_WSREMS__DOB__c");
        var action = component.get("c.pharmacyEnterPatientInformation");
        action.setParams({
            fname: fname.trim(),
            lname: lname.trim(),
            dob: dob,
            program : 'Macitentan REMS'
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                var patientAcc = result.getReturnValue();
                
                if (patientAcc != null && patientAcc.US_WSREMS__Status__c == 'Enrolled') {
                    component.set("v.ShowPatientInfo", true);
                    component.set("v.cAccount",patientAcc);
                    component.set("v.patientId",patientAcc.Id);
                    component.set('v.isValidPatient', true);
                    component.set('v.isNotValidPatient', false);
                    this.getCurrentprescriberInfo(component,event);
                }else{
                component.set('v.isValidPatient', false);
                component.set('v.isNotValidPatient', true);
                
            }
                
                var patientRiskCate = component.get("v.cAccount.US_WSREMS__Patient_Risk_Category__c");
                //Pre-populate the checkboxes (Counseling rec & Monthly Preg Test) for FRP from patient record.....
                if(component.get("v.cAccount.Counseling_Recorded__c") == true && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
                    component.set("v.patientCounselRecordedPrePop",true);  
                }
                if(component.get("v.cAccount.Monthly_Pregnancy_Test_Recorded__c") == 'Yes' && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
                    component.set("v.patientMontlyPregTestPrePop",true);
                } 
                
                if(//component.get("v.cAccount.US_WSREMS__Patient_Risk_Category__c") == 'FRP (Female of Reproductive Potential)' ||
                   component.get("v.cAccount.US_WSREMS__Patient_Risk_Category__c") == 'FNRP (Patient is pre-pubertal)' ||
                   component.get("v.cAccount.US_WSREMS__Patient_Risk_Category__c") == 'FNRP (Patient is post-menopausal)' ||
                   component.get("v.cAccount.US_WSREMS__Patient_Risk_Category__c") == 'FNRP (other medical reasons for permanent irreversible infertility)'
                  )
                {
                    component.set("v.showFNRPInfo",true); 
                }
            }else{
                component.set("v.patientNA",true);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getCurrentprescriberInfo : function(component,event){
        var patientacc= component.get("v.patientId");
        var action = component.get("c.getPrescriberDetails");
        action.setParams({
            patientId : patientacc,
            program : 'Macitentan REMS'
        });
        action.setCallback(this, function(response) {
            let result = response.getReturnValue();
            
            component.set('v.provider', result);
			component.set('v.prescriberAcc', result.SYN_Prescriber__c);
			this.getPrescriberAccount(component,event);
        });
        $A.enqueueAction(action);    
    },
	
	getPrescriberAccount : function(component,event){
        var prescriberId= component.get("v.prescriberAcc");
        var action = component.get("c.getPrescriberAccount");
        action.setParams({
            prescriberId : prescriberId,
            program : 'Macitentan REMS'
        });
        action.setCallback(this, function(response) {
            let result = response.getReturnValue();
            
            component.set('v.prescriber', result);
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
    
    createMonthlyPregCaseRecord : function(component, event) {
        component.set('v.isLoading', true);
        var programId = component.get("v.programId");
        var patientAccount= component.get("v.patientId");
        var pharmacyAccount= component.get("v.pharmacy");
        var userAccount = component.get("v.pharmacist");
        var pharmacyParticipant=userAccount.Id;
		var prescriberAccount = component.get("v.prescriberAcc");
        
        var action = component.get("c.createPharmacyPatientTestRecord");
        
       
        action.setParams({
            program : programId,
            patientId : patientAccount,
            pharmacy : pharmacyAccount,
            programName : 'Macitentan REMS',
            channel : 'Portal',
            pharmacyParticipant : pharmacyParticipant,
			prescriber : prescriberAccount
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    createPatientCounsCaseRecord: function(component, event){
        
         component.set('v.isLoading', true);
        var action = component.get("c.createPharmacyPatientCounselingRecord"); 
        action.setParams({
            authRepAccount : component.get("v.pharmacist"),
            pharmacyAccount : component.get("v.pharmacy"),
            prescriberAccount : component.get("v.prescriber"),
            patientAccount : component.get("v.cAccount"),
            channel : 'Portal'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            let result = response.getReturnValue();
            
            
            if (state === "SUCCESS") {
                console.log('Patient Couns checklist Record created!!');
                 component.set('v.isLoading', false);
            }else{
                console.log('Error creating patient couns checklist record!!');
            }
        });
        $A.enqueueAction(action);
        
    },
    
    
    navigateToManagePharmacy : function(component, event) {
        component.set('v.isLoading', false);
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'pharmacy-manage-home'
            }
        };
        nav.navigate( pageReference ); 
    }
})