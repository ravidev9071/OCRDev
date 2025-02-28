({
	doInit: function(component, event, helper) {  
        

        helper.getCurrentPharmacistInfo(component,event);
        helper.getManufacturerPicklistValues(component,event);
        helper.getNDCCodePicklistValues(component,event); 
        helper.getResonsForDaysSupplyPicklistValues(component,event);
        helper.getResonsForTreatmentInterrPicklistValues(component,event);
     
    },
    refreshCurrentPage: function(component, event, helper) {  
        $A.get('e.force:refreshView').fire();
    },
    VerifyPrescriberPatientInfo: function(component, event, helper) {  
        
        var npi = component.get("v.PrescriberNPI");
        var numberpattern = /^(\s*\d\s*){10}$/;
         var fname = component.get("v.PatientFN");
        var mname = component.get("v.PatientMN");
        var lname = component.get("v.PatientLN");
        var dob = component.get("v.PatientDOB");
        var errorMsg='';
        
        if(npi == undefined || npi == ''){
            errorMsg += ' Prescriber NPI Number,'
        }
        
        if(fname == undefined || fname == ''){
            errorMsg += ' Patient First Name,'
        }
        
        if(lname == undefined || lname == ''){
            errorMsg += ' Patient Last Name,'
        }
        
        if(dob == undefined || dob == ''){
            errorMsg += ' Patient Date of Birth,'
        }
        
        if(errorMsg){
            errorMsg = errorMsg.replace(/,*$/, '.');
            errorMsg = 'Please enter '+errorMsg;
            helper.showToast(component,event,errorMsg,'Warning');
        }else if(npi != '' && npi != undefined && npi.length <10){
            helper.showToast(component,event,'Prescriber NPI should be 10 digits.','Warning');
        }else if(npi != '' && npi != undefined && !npi.match(numberpattern)){
            helper.showToast(component,event,'Prescriber NPI should contain 10 digits.','Warning');
        }else{
            component.set('v.ShowSpinner', true);
            helper.validatePrescriberData(component,event);
            helper.validatePatientData(component,event);
        }
    },
    
    navigateToDashboard : function(component, event, helper) {
        //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'pharmacy-manage-home'
        }
        };
        nav.navigate( pageReference );
    
    },
    
    submitRDA: function(component, event, helper) {
        var programId = component.get("v.programId");
        
        var daysSupply = component.get("v.daysSupplyValue");
        var patientRiskCate = component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c");
        var reasonsForDaysSupply = component.get("v.newCase.Reason_for_Days_Supply_30__c");
        var reasonsFTreatementInterr = component.get("v.newCase.Reason_for_Treatment_Interruption__c");
        var counsellingRecCheckbox = $("#counsellingRecCheckbox").is(":checked");
        var monthlyPregTestCheckbox = $("#monthlyPregTestCheckbox").is(":checked");
        var prescRefilAuthcheckbox = $("#prescRefilAuthcheckbox").is(":checked");
        var manufacturer = component.get("v.newCase.Manufacturer__c");
        var ndcVal = component.get("v.newCase.NDC_Code__c");
        var errorMsg='';
        
        //Set the checkbox values to the case field...
        //Check for the checkbox value if prepopulated or manuaaly checked to Patient Counselling service & Case...
        
        if(counsellingRecCheckbox == true && component.get("v.patientCounselRecordedPrePop") == false && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
           component.set("v.createPatientCounselRecBool",true);
           component.set("v.newCase.Counseling_Recorded__c",true);
        }else if(counsellingRecCheckbox == true && component.get("v.patientCounselRecordedPrePop") == true && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
            component.set("v.createPatientCounselRecBool",false);
            component.set("v.newCase.Counseling_Recorded__c",true);
        }else{
            component.set("v.createPatientCounselRecBool",false);
            component.set("v.newCase.Counseling_Recorded__c",false);
        }
        //Check for the checkbox value if prepopulated or manuaaly checked to create Montly preg service & Case...
        if(monthlyPregTestCheckbox == true && component.get("v.patientMontlyPregTestPrePop") == false && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
             component.set("v.createMontlyPregTestBool",true);
             component.set("v.newCase.Monthly_Pregnancy_Test_Recorded__c",true);
        }else if(monthlyPregTestCheckbox == true && component.get("v.patientMontlyPregTestPrePop") == true && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
            component.set("v.createMontlyPregTestBool",false);
            component.set("v.newCase.Monthly_Pregnancy_Test_Recorded__c",true);
        }else{
            component.set("v.createMontlyPregTestBool",false);
            component.set("v.newCase.Monthly_Pregnancy_Test_Recorded__c",false);
        }
    
        
        if(prescRefilAuthcheckbox == true){
             component.set("v.newCase.Prescriber_Refill_Authorization_Recorded__c",true);
        }else{
            component.set("v.newCase.Prescriber_Refill_Authorization_Recorded__c",false);
        }
        
        //Validation for screen messages ....
        if(manufacturer == '' || manufacturer == undefined || manufacturer == '--None--'){
            component.set("v.manufacturerIsNull",true);
        }
        //Validation for screen messages ....
        if(ndcVal == '' || ndcVal == undefined || ndcVal == '--None--'){
            component.set("v.ndcIsNull",true);
        }
        
        //Show field message only if it is FRP...
        if(component.get("v.newCase.Days_of_Interruption__c") > 0 && component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c") == 'Female of Reproductive Potential (FRP)'){
            component.set("v.daysinterruptionFieldLevelMessage",true);
        }else{
             component.set("v.daysinterruptionFieldLevelMessage",false);
        }
        
        if(component.get("v.newCase.Days_of_Interruption__c") >= 5){
            component.set("v.daysOfInterrupBool",true);
        }else{
            component.set("v.daysOfInterrupBool",false);
        }
        
        //Validation for screen messages ....
        if(component.get("v.newCase.Days_of_Interruption__c") >= 5 &&
           (reasonsFTreatementInterr == '' || reasonsFTreatementInterr == undefined) 
           && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
           component.set("v.treatmentReasonsIsNull",true);
        }else{
            component.set("v.treatmentReasonsIsNull",false);
        }
        //Validation for screen messages ....
        if(counsellingRecCheckbox == false && patientRiskCate == 'Female of Reproductive Potential (FRP)'){ 
            component.set("v.counselingRecordedIsNull",true);
        }else{
            component.set("v.counselingRecordedIsNull",false);
        }
        if(monthlyPregTestCheckbox == false && prescRefilAuthcheckbox == false && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
             component.set("v.patientMonthlyORREfillAuthCheckboxIsNull",true);
        }else{
            component.set("v.patientMonthlyORREfillAuthCheckboxIsNull",false);
        }
        
        //Validation on form level...
        if(monthlyPregTestCheckbox == true && prescRefilAuthcheckbox == true && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
            helper.showToast(component,event,'Please confirm Monthly Pregnancy Test OR Prescriber Refill Authorization','Warning');
            component.set("v.patientMonthlyORREfillAuthCheckboxIsNull1",true);
        }else{
            component.set("v.patientMonthlyORREfillAuthCheckboxIsNull1",false);
        }
        //Days supply validation form level...
        if(daysSupply == '' || daysSupply == undefined || daysSupply < '1' || daysSupply > '90'){
            helper.showToast(component,event,'Days Supply value should be in between 1-90.','Warning');
            component.set("v.daysSupplyIsNull",true);
        }else if(daysSupply != '' && daysSupply != undefined && daysSupply > 0 && daysSupply <= 90){
            component.set("v.newCase.SYN_Days_Supply__c",daysSupply);
            component.set("v.daysSupplyIsNull",false);
        }
        
        if(daysSupply > 0 && daysSupply <= 30){
            component.set("v.daysSupplyValueBool",false);
        }else if(daysSupply > 30 && daysSupply <= 90){
            component.set("v.daysSupplyValueBool",true);
        }
                
        //Reasons For days supply validation if FRP only...SCreen error message...
        if((reasonsForDaysSupply == '' || reasonsForDaysSupply == undefined) && daysSupply > 30 && patientRiskCate == 'Female of Reproductive Potential (FRP)'){
            component.set("v.reasonsForDaysSupplyIsNull",true);
        }else{
            component.set("v.reasonsForDaysSupplyIsNull",false);
        }
        
        //Pharmacy validation...
        if(component.get('v.pharmacy.Name') == '' || component.get('v.pharmacy.Name') == undefined || component.get('v.pharmacy.US_WSREMS__NPI__c') == '' || component.get('v.pharmacy.US_WSREMS__NPI__c') == undefined ||
           component.get('v.pharmacy.US_WSREMS__Status__c') != 'Certified' || component.get('v.pharmacy.SYN_Ref_Id__c') == '' || component.get('v.pharmacy.SYN_Ref_Id__c') == undefined){
            component.set("v.pharmacyDataCheckBool",true);
            helper.showToast(component,event,'Pharmacy record is missing below required information: Name, REMS ID, Status, NPI','Warning');
        }else{
            component.set("v.pharmacyDataCheckBool",false);
        }
        
        //Pharmacy participant validation....
        if(component.get('v.authRepAccount.FirstName') == '' || component.get('v.authRepAccount.FirstName') == undefined ||
           component.get('v.authRepAccount.LastName') == '' || component.get('v.authRepAccount.LastName') == undefined ||
           component.get('v.authRepAccount.US_WSREMS__Status__c') != 'Active'){
            component.set("v.pharmacyParticipantDataCheckBool",true);
            helper.showToast(component,event,'Pharmacy Participant record is missing below required information: Name, Status','Warning');
        }else{
            component.set("v.pharmacyParticipantDataCheckBool",false);
        }
        
        //Patient validation....
        /*
        if(component.get("v.patientAccount.FirstName") == '' || component.get("v.patientAccount.FirstName") == undefined ||
           component.get("v.patientAccount.LastName") == '' || component.get("v.patientAccount.LastName") == undefined ||
           component.get("v.patientAccount.SYN_Ref_Id__c") == '' || component.get("v.patientAccount.SYN_Ref_Id__c") == undefined ||
           component.get("v.patientAccount.US_WSREMS__Status__c") != 'Enrolled' || 
           component.get("v.patientAccount.US_WSREMS__DOB__c") == '' || component.get("v.patientAccount.US_WSREMS__DOB__c") == undefined ||
           component.get("v.patientAccount.ShippingPostalCode") == '' || component.get("v.patientAccount.ShippingPostalCode") == undefined ||
           component.get("v.patientAccount.Patient_Reproductive_Status_Date__c") == '' || component.get("v.patientAccount.Patient_Reproductive_Status_Date__c") == undefined ||
           component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c") == '' || component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c") == undefined){
            component.set("v.patientDataCheckBool",true);
            helper.showToast(component,event,'Patient record is missing below required information: Name, REMS Id, Zip code, Patient Reproductive Status Date, Patient Risk Category.','Warning');
        }*/
        if(component.get("v.patientAccount.FirstName") == '' || component.get("v.patientAccount.FirstName") == undefined ){
            errorMsg += ' First Name,'
        }
        if(component.get("v.patientAccount.LastName") == '' || component.get("v.patientAccount.LastName") == undefined ){
            errorMsg += ' Last Name,'
        }
        if(component.get("v.patientAccount.SYN_Ref_Id__c") == '' || component.get("v.patientAccount.SYN_Ref_Id__c") == undefined ){
            errorMsg += ' REMS Id,'
        }
        
        if(component.get("v.patientAccount.US_WSREMS__Status__c") != 'Enrolled' ){
            errorMsg += ' Patient Not Enrolled,'
        }
        
        if(component.get("v.patientAccount.US_WSREMS__DOB__c") == '' || component.get("v.patientAccount.US_WSREMS__DOB__c") == undefined){
            errorMsg += ' DOB,'
        }
        /*
        if(component.get("v.patientAccount.ShippingPostalCode") == '' || component.get("v.patientAccount.ShippingPostalCode") == undefined ){
            errorMsg += ' ZIP Code,'
        }
        */
        
        if( component.get("v.patientAccount.Patient_Reproductive_Status_Date__c") == '' || component.get("v.patientAccount.Patient_Reproductive_Status_Date__c") == undefined ){
            errorMsg += ' Patient Reproductive Status Date,'
        }
        
        if( component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c") == '' || component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c") == undefined ){
            errorMsg += ' Patient Risk Category,'
        }
        if(errorMsg){
            errorMsg = errorMsg.replace(/,*$/, '.');
            errorMsg = 'Required information is missing on patient account:  '+errorMsg;
            component.set("v.patientDataCheckBool",true);
            helper.showToast(component,event,errorMsg,'Warning');
        } else{
            component.set("v.patientDataCheckBool",false);
        }
        
    
        //FNRP...
        if(
            (component.get("v.manufacturerIsNull") == false && component.get("v.ndcIsNull") == false
             && patientRiskCate != 'Female of Reproductive Potential (FRP)' && component.get("v.pharmacyDataCheckBool") == false &&
             component.get("v.pharmacyParticipantDataCheckBool") == false && component.get("v.patientDataCheckBool") == false) ||
            (patientRiskCate == 'Female of Reproductive Potential (FRP)' && component.get("v.counselingRecordedIsNull") == false &&
             component.get("v.patientMonthlyORREfillAuthCheckboxIsNull") == false && component.get("v.patientMonthlyORREfillAuthCheckboxIsNull1") == false && 
             ((component.get("v.daysSupplyIsNull") == false && component.get("v.daysSupplyValueBool") == true && component.get("v.reasonsForDaysSupplyIsNull") == false) || (component.get("v.daysSupplyIsNull") == false && component.get("v.daysSupplyValueBool") == false && component.get("v.reasonsForDaysSupplyIsNull") == false) ) && component.get("v.manufacturerIsNull") == false &&
             component.get("v.ndcIsNull") == false && ((component.get("v.daysOfInterrupBool") == true && component.get("v.treatmentReasonsIsNull") == false) || (component.get("v.daysOfInterrupBool") == false && component.get("v.treatmentReasonsIsNull") == false)) && component.get("v.pharmacyDataCheckBool") == false &&
             component.get("v.pharmacyParticipantDataCheckBool") == false && component.get("v.patientDataCheckBool") == false)
        ){
            
            component.set('v.ShowSpinner', true);
            component.set("v.newCase.US_WSREMS__REMS_Program__c",programId);
            component.set("v.newCase.US_WSREMS__Program_Picklist__c",'Macitentan REMS');
            component.set("v.newCase.US_WSREMS__Channel__c",'Portal');
            component.set("v.newCase.Recent_Patient_Reproductive_Status_Date__c",component.get("v.patientAccount.Patient_Reproductive_Status_Date__c"));
            component.set("v.newCase.US_WSREMS__DOB__c",component.get("v.patientAccount.US_WSREMS__DOB__c"));
            component.set("v.newCase.US_WSREMS__Pharmacy__c",component.get("v.pharmacy.Id"));
            helper.createRDACaseRecord(component, event);
            
            if(component.get("v.createMontlyPregTestBool") == true){
                helper.createMonthlyPregnCaseRecord(component, event);
            }
            if(component.get("v.createPatientCounselRecBool") == true){
                helper.createPatientCounsCaseRecord(component, event);
            }
            
        }
        
    },
    
    previousScreen : function(component, event, helper) {
        component.set('v.showfullRDAform', false)
    },
     handleManufacturerOnChange : function(component, event, helper) {
        var manufacturer =$("#manufacturer").val();
        component.set("v.newCase.Manufacturer__c",manufacturer);
         component.set("v.manufacturerIsNull",false);
    },
    handleNDCCodeOnChange: function(component, event, helper) {
        var ndcCode =$("#ndcCode").val();
        component.set("v.newCase.NDC_Code__c",ndcCode);
        component.set("v.ndcIsNull",false);
    },
    handleReasonsForDaysSupplyOnChange: function(component, event, helper) {
        var ndcCode =$("#reasonsForDaysSupply").val();
        component.set("v.newCase.Reason_for_Days_Supply_30__c",ndcCode);
        component.set("v.reasonsForDaysSupplyIsNull",false);
    },
    handleReasonsForTreatmentInterrOnChange: function(component, event, helper) {
        var ndcCode =$("#reasonsForTreatmentInterr").val();
        component.set("v.newCase.Reason_for_Treatment_Interruption__c",ndcCode);
        component.set("v.treatmentReasonsIsNull",false);
    },
    
    onChangeDaysSupply: function(component, event, helper) {
        const inputName = component.find("dsupply").get("v.value");
        var patientRiskCat = component.get("v.patientAccount.US_WSREMS__Patient_Risk_Category__c"); 
        if(inputName > 30 && patientRiskCat == 'Female of Reproductive Potential (FRP)'){
           component.set("v.showDaysSupplyReasonsValueSelection",true); 
        }else{
            component.set("v.showDaysSupplyReasonsValueSelection",false);
        }
      
    },
    
})