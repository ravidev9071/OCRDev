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
        var action = component.get("c.validatePrescriberData"); 
        var npi = component.get("v.PrescriberNPI");
        
        action.setParams({
            npi: npi,
            programId : programId 
        });
        action.setCallback(this, function(response) {
           let result = response.getReturnValue();
            component.set('v.ShowSpinner', false);
           
            component.set('v.prescriberAccount', result);
            if(result != null && result.US_WSREMS__Status__c == 'Certified'){
                component.set('v.isValidPrescriber', true);
                component.set('v.isNotValidPrescriber', false);
                component.set('v.ShowNPI', false);
            }else{
                component.set('v.isNotValidPrescriber', true);
                component.set('v.isValidPrescriber', false);
            }
        });
        $A.enqueueAction(action);    
    },
    
     validatePatientData : function(component,event){
        var programId = component.get("v.programId");
        var action = component.get("c.validatePatientData"); 
        var fname = component.get("v.PatientFN");
        var mname = component.get("v.PatientMN");
        var lname = component.get("v.PatientLN");
        var dob = component.get("v.PatientDOB");
        
        action.setParams({
            fname: fname,
            mname: mname,
            lname: lname,
            dob: dob,
            programId : programId 
        });
        action.setCallback(this, function(response) {
           let result = response.getReturnValue();
            component.set('v.ShowSpinner', false);
            
            component.set('v.patientAccount', result);
			if(result != null && result.US_WSREMS__Status__c == 'Enrolled'){
                component.set('v.isValidPatient', true);
                component.set('v.isNotValidPatient', false);
            }else{
                component.set('v.isValidPatient', false);
                component.set('v.isNotValidPatient', true);
            }
            
            var patientRiskCate = component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c");
           
            if(component.get('v.isValidPatient') == true && component.get('v.isValidPrescriber') == true){
                component.set('v.showfullRDAform', true);
                //Disable checkboxes section for FNRP....
               
                if(patientRiskCate != 'Female of Reproductive Potential (FRP)'){
                    component.set("v.disableCheckboxesForFNRP",true);
                }else if(patientRiskCate == 'Female of Reproductive Potential (FRP)'){
                    component.set("v.disableCheckboxesForFNRP",false);
                }
                //Pre-populate the checkboxes (Counseling rec & Monthly Preg Test) for FRP from patient record.....
                if(component.get("v.patientAccount.Counseling_Recorded__c") == true && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
                    component.set("v.patientCounselRecordedPrePop",true);  
                }
                if(component.get("v.patientAccount.Monthly_Pregnancy_Test_Recorded__c") == 'Yes' && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
                    component.set("v.patientMontlyPregTestPrePop",true);
                } 
                                              
            }else{
                component.set('v.showfullRDAform', false);
            }
            //Pre-populate days of interruption from the recent RDA's shipment and tracking data...
                if(component.get('v.showfullRDAform') == true){
                    this.autopopANDvalidateDaysOfInterruption(component,event);
                }
        });
        $A.enqueueAction(action);    
    }, 
    
    autopopANDvalidateDaysOfInterruption : function(component,event){
        var patientId = component.get('v.patientAccount.Id');
        
        var action = component.get("c.getShipmentRelatedDataForMACIRDA"); 
        action.setParams({
            patientId : patientId
        });
        action.setCallback(this, function(response) {
           let result = response.getReturnValue();
            
           
			if(result != null){
                component.set("v.newCase.Days_of_Interruption__c",result);
               
                //Show field message only if it is FRP...
                if(result > 0 && component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c") == 'Female of Reproductive Potential (FRP)'){
                    component.set("v.daysinterruptionFieldLevelMessage",true);
                    component.set("v.showDaysOfInterruption",true);
                }else{
                    component.set("v.showDaysOfInterruption",false);
                }
                
                if(result >= 5 && component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c") == 'Female of Reproductive Potential (FRP)'){
                    component.set("v.showReasonsForTreatmentInterruption",true);
                }else{
                    component.set("v.showReasonsForTreatmentInterruption",false);
                }
                
            }
        });
        $A.enqueueAction(action); 
    },
    
    createRDACaseRecord: function(component,event){
        

        
        var action = component.get("c.createRDACaseRecord"); 
        action.setParams({
            newCase : component.get("v.newCase"),
            authRepAccount : component.get("v.authRepAccount"),
            pharmacyAccount : component.get("v.pharmacy"),
            prescriberAccount : component.get("v.prescriberAccount"),
            patientAccount : component.get("v.patientAccount")            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            let result = response.getReturnValue();
            component.set('v.ShowSpinner', false);
            
            if (state === "SUCCESS" && result != 'RDA creation error' && result != null && result != '') {
                this.showToast(component,event,'RDA got created successfully!','success');
                component.set("v.createdRDACaseRecordId",result);
                component.set("v.showRDASuccessScreen",true);
            }else if(result == 'RDA creation error' ){
                this.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error');
                component.set("v.showRDASuccessScreen",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    createMonthlyPregnCaseRecord: function(component, event){
		var userAccount = component.get("v.authRepAccount");
        var pharmacyParticipant=userAccount.Id;
        var action = component.get("c.createPharmacyPatientTestRecord"); 
        action.setParams({
            program : component.get("v.pharmacy.US_WSREMS__REMS_Program__c"),
            patientId : component.get("v.patientAccount.Id"),
            pharmacy : component.get("v.pharmacy"),
            programName : 'Macitentan REMS',
			channel : 'Portal',
            pharmacyParticipant : pharmacyParticipant,
			prescriber : component.get("v.prescriberAccount.Id")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            let result = response.getReturnValue();
            
            
            if (state === "SUCCESS") {
                console.log('Pregnancy Record created!!');
            }else{
                console.log('Error creating pregnancy record!!');
            }
        });
        $A.enqueueAction(action);
        
    },
    createPatientCounsCaseRecord: function(component, event){
       
        var action = component.get("c.createPatientCounselingChecklistCaseRecord"); 
        action.setParams({
            authRepAccount : component.get("v.authRepAccount"),
            pharmacyAccount : component.get("v.pharmacy"),
            prescriberAccount : component.get("v.prescriberAccount"),
            patientAccount : component.get("v.patientAccount"),
			channel : 'Portal'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            let result = response.getReturnValue();
            
            
            if (state === "SUCCESS") {
                console.log('Patient Couns checklist Record created!!');
            }else{
                console.log('Error creating patient couns checklist record!!');
            }
        });
        $A.enqueueAction(action);
        
    },
    
    dataValidations: function(component,event){
        var patientRiskCate = component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c");
        var manufacturer = component.get("v.newCase.Manufacturer__c");
        var ndcVal = component.get("v.newCase.NDC_Code__c");
        var reasonsFTreatementInterr = component.get("v.newCase.Reason_for_Treatment_Interruption__c");
        var counsellingRecCheckbox = $("#counsellingRecCheckbox").is(":checked");
        var monthlyPregTestCheckbox = $("#monthlyPregTestCheckbox").is(":checked");
        var prescRefilAuthcheckbox = $("#prescRefilAuthcheckbox").is(":checked");
        
        //Validations 
        if((counsellingRecCheckbox == false || counsellingRecCheckbox == undefined) && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
            component.set("v.counselingRecordedIsNull",true);
        }else{
            component.set("v.counselingRecordedIsNull",false);
        }
        if(monthlyPregTestCheckbox == false && prescRefilAuthcheckbox == false && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
             component.set("v.patientMonthlyORREfillAuthCheckboxIsNull",true);
        }else{
            component.set("v.patientMonthlyORREfillAuthCheckboxIsNull",false);
        }
        
        if(manufacturer == '' || manufacturer == undefined || manufacturer == '--None--'){
            component.set("v.manufacturerIsNull",true);
        }
        
        if(ndcVal == '' || ndcVal == undefined || ndcVal == '--None--'){
            component.set("v.ndcIsNull",true);
        }
        
        if(component.get("v.newCase.Days_of_Interruption__c") >= 5 && (reasonsFTreatementInterr == '' || reasonsFTreatementInterr == undefined)){
           component.set("v.treatmentReasonsIsNull",true);
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
    getManufacturerPicklistValues: function(component, event) {        
        var action = component.get("c.getRDAManufacturerValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var credentailsMap = [];
                for(var key in result){
                    credentailsMap.push({key: key, value: result[key]});
                } 
                component.set("v.manufacturerMap", credentailsMap);
            }
        });
        $A.enqueueAction(action);
    }, 
    getNDCCodePicklistValues: function(component, event) {        
        var action = component.get("c.getRDANDCCodeValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var credentailsMap = [];
                for(var key in result){
                   if(key.includes('66215-')){//Changes added as part of MACI NDC CODE Display issue for July 2024 PROD Release
                        credentailsMap.push({key: key, value: result[key]});
					}
                } 
                component.set("v.ndcCodeMap", credentailsMap);
               
               
            }
        });
        $A.enqueueAction(action);
    },
    getResonsForDaysSupplyPicklistValues: function(component, event) {        
        var action = component.get("c.getResonsForDaysSupplyValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var credentailsMap = [];
                for(var key in result){
                    credentailsMap.push({key: key, value: result[key]});
                } 
                component.set("v.reasonsForDaysSupplyMap", credentailsMap);
            }
        });
        $A.enqueueAction(action);
    },
    getResonsForTreatmentInterrPicklistValues: function(component, event) {        
        var action = component.get("c.getResonsForTreatmentInterrValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var credentailsMap = [];
                for(var key in result){
                    credentailsMap.push({key: key, value: result[key]});
                } 
                component.set("v.reasonsForTreatmentInterruptionMap", credentailsMap);
            }
        });
        $A.enqueueAction(action);
    },
    
})