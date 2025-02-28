({
    doInit : function(component,event,helper){ 
        component.set('v.isLoading', true);
        helper.getCurrentPharmacistInfo(component,event);
    },
    
    searchpatient : function(component, event, helper) {
        var fname=component.get("v.newAccount.FirstName");
        var lname = component.get("v.newAccount.LastName");
        var dob = component.get("v.newAccount.US_WSREMS__DOB__c");
        var action = component.get("c.pharmacyEnterPatientInformation");
         if(fname == '' || fname == undefined || lname == '' || lname == undefined || dob == '' || dob == undefined){
            helper.showToast(component,event,'All fields except M.I. are required to continue.','Warning');
           }else{
            helper.validatePatientData(component,event);
        }
    },
    
    monthlyPregancyTest : function(component, event, helper) {
        let checkBoxState = event.getSource().get('v.value');
        
        component.find("disableenable").set("v.disabled", !checkBoxState);
    },
    
    handleComplete : function(component, event, helper) {
        component.set("v.patientMonthlyCheckboxIsNull",false);
        component.set("v.createMontlyPregTestErr",false);
		component.set("v.patientCounselingCheckboxIsNull",false);
        component.set("v.createPatientCounselingErr",false);
        var monthlyPregTestCheckbox = $("#monthlyPregTestCheckbox").is(":checked");
		var counsellingRecCheckbox = $("#counsellingRecCheckbox").is(":checked");
        var patientRiskCate = component.get("v.cAccount.US_WSREMS__Patient_Risk_Category__c");
        if(patientRiskCate != 'Female of Reproductive Potential (FRP)'){
            helper.navigateToManagePharmacy(component, event);
        }
        if(monthlyPregTestCheckbox == false && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
             component.set("v.patientMonthlyCheckboxIsNull",true);
        }
		
		if(counsellingRecCheckbox == false && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
             component.set("v.patientCounselingCheckboxIsNull",true);
        }
         //Check for the checkbox value if prepopulated or manuaaly checked to create Montly preg service & Case...
        if(monthlyPregTestCheckbox == true && component.get("v.patientMontlyPregTestPrePop") == false && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
             component.set("v.createMontlyPregTestRec",true);
            //helper.handleCompleteCreation(component, event);
        }else if(monthlyPregTestCheckbox == true && component.get("v.patientMontlyPregTestPrePop") == true && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
            component.set("v.createMontlyPregTestErr",true);
        }else{
            component.set("v.createMontlyPregTestRec",false);
        }
		
		
		//Check for the checkbox value if prepopulated or manuaaly checked to create Patient Counselling service & Case...
        if(counsellingRecCheckbox == true && component.get("v.patientCounselRecordedPrePop") == false && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
             component.set("v.createPatientCounselingRec",true);
            //helper.handleCompleteCreation(component, event);
        }else if(counsellingRecCheckbox == true && component.get("v.patientCounselRecordedPrePop") == true && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
            component.set("v.createPatientCounselingErr",true);
        }else{
            component.set("v.createPatientCounselingRec",false);
        }
        
        if(patientRiskCate == 'Female of Reproductive Potential (FRP)' && component.get("v.createMontlyPregTestRec") == true && component.get("v.createPatientCounselingRec") == true){
            helper.createMonthlyPregCaseRecord(component, event);
            helper.createPatientCounsCaseRecord(component, event);
            helper.navigateToManagePharmacy(component, event);
        }
        if(patientRiskCate == 'Female of Reproductive Potential (FRP)' && component.get("v.createMontlyPregTestRec") == true && component.get("v.createPatientCounselingRec") == false){
            helper.createMonthlyPregCaseRecord(component, event);
            helper.navigateToManagePharmacy(component, event);
        }
        if(patientRiskCate == 'Female of Reproductive Potential (FRP)' && component.get("v.createPatientCounselingRec") == true && component.get("v.createMontlyPregTestRec") == false){
            helper.createPatientCounsCaseRecord(component, event);
            helper.navigateToManagePharmacy(component, event);
        }
    },
	    
    refreshCurrentPage: function(component, event, helper) {  
        $A.get('e.force:refreshView').fire();
    },
    
    handleCancel : function(component, event, helper) {
        component.set('v.isLoading', true);
       helper.navigateToManagePharmacy(component, event);
    }
})