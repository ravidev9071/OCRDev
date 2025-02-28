({
	doInit: function( component, event, helper ) {
        var calledByFaxTransfo = component.get("v.calledByFaxTransfo");
        if (calledByFaxTransfo){
            try {
                helper.getPageLayoutforRequestorType(component, event, helper, component.get("v.ButtonName"));
           }
            catch(e){
                console.log('try catch '+e.message);
            }
           
        }else {

            var actionApi = component.find("quickActionAPI");
            actionApi.getSelectedActions().then(function(result){
            var actionNameValue = result.actions[0].actionName;
            //If my quick action api name is 'Custom_Edit', this returns the 
            //action name as CustomObject__c.Custom_Edit
            //To Split and get just the action api name, do the below.
            if(actionNameValue.includes('.')) {             
            var getActionName = actionNameValue.split('.')[1];
            //This returns value as 'Cutom_Edit'
            component.set("v.ActionName", getActionName);
            //  var isEmpty = $A.util.isEmpty(cmp.get("v.ActionName"));
            var recordId = component.get("v.recordId");
            var ActionName = component.get("v.ActionName");
        // moving the Page Layout Logic to Helper

            try {
                helper.getPageLayoutforRequestorType(component, event, helper, ActionName);
                }
            catch(e){
            console.log('catch Efax SYN_par new Impementation '+e.message);
            } 
         }
            

        }).catch(function(error){
            console.log('Errors - '+error.errors);
        }); 
    }

               
    },
    
    handleRecordChanged: function(component, event, helper) {
        switch(event.getParams().changeType) {
            case "ERROR":
                
                break;
            case "LOADED":
                var child = component.get("v.remsRecord");
                component.set("v.programNameStr" , child.US_WSREMS__REMSProgram__r.Name);
				component.set("v.participantId" , child.US_WSREMS__Participant__c);
                component.set("v.currREMServiceParticipantId" , child.US_WSREMS__Participant__c);
                component.set("v.facilityId" , child.US_WSREMS__Participant__r.SYN_Facility__c);
				component.set("v.PharmacyName" , child.US_WSREMS__Participant__r.Name);
                break;
        }
    },

    handleLoad : function(component, event, helper) {
    	component.set("v.showSpinner", false);   
    },
    handleSubmit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var recordId = component.get("v.recordId");
        var recordTypeId = component.get("v.caseRecordTypeId");
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        eventFields.US_WSREMS__REMS_Service_Summary__c = recordId;
        eventFields.RecordTypeId = recordTypeId;
       // eventFields.US_WSREMS__Program_Picklist__c = component.get("v.programNameStr");
        var layoutName = component.get("v.layoutName");
     
        var allValid = true;
        var futureDateValidationMsg = '';
        var futureDateValidation = false;
		//BT-7433 - 104 as per ticket, we have to populate the read fields values
		if(layoutName == "Case-MACI Non Compliance Case Layout" || layoutName == "Case-MACI RDA Layout" 
		   || layoutName == "Case-MACI PAE PC MI Case Layout" || layoutName == "Case-Maci Patient Counseling Checklist Layout"){
            var arr = component.get("v.layoutSections");
            for(var i=0;i<arr.length;i++){
                for(var j=0;j<arr[i].lstFields.length;j++){
                if(arr[i].lstFields[j].fieldValue === undefined){
                arr[i].lstFields[j].fieldValue = "";
                }  
                    if(arr[i].lstFields[j].fieldName !== undefined && arr[i].lstFields[j].isReadOnly !== undefined ){
                        if(arr[i].lstFields[j].isReadOnly === true ){
                            eventFields[arr[i].lstFields[j].fieldName] = arr[i].lstFields[j].fieldValue;
                        }
                    }
                }
            } 
        }
var ly= component.get("v.layoutName");
         var programName = component.get("v.programName");
        if(ly == 'Case-SYN_Pre_Dispense_Layout' && programName == 'Sodium Oxybate REMS'){
            
              const cmps_input = component.find("inputField");
                    for(var i=0;i<cmps_input.length;i++){
                        if(cmps_input[i].get("v.fieldName") == 'SYN_Quantity__c'){
                              debugger;
                            var quantityValue=parseFloat(cmps_input[i].get("v.value"));
                            var quantity_value=cmps_input[i].get("v.value");
                            
                           
                            var decimalPattern = /^\d{0,4}(\.\d{1,2})?$/;
                            if (quantity_value !=null && (quantityValue <= 0 || (!decimalPattern.test(quantityValue)))) {
                                debugger;
                                futureDateValidationMsg = 'Please enter Product Information - Quantity value between 0.01 and 9,999.99 ml';
                               futureDateValidation=true;
                            }
                            
                        }
                    }
        }
        
      
        const cmps = component.find("dateid");
        if(cmps){
            if(cmps.length){
                for(var i=0;i<cmps.length;i++){
                    eventFields[cmps[i].get("v.name")] = cmps[i].get("v.value");
                    if (cmps[i].get("v.name") == 'US_WSREMS__Prescription_Date__c' || cmps[i].get("v.name") == 'date_of_Fill__c' ){
                        debugger;
                        if (cmps[i].get("v.value") > $A.localizationService.formatDate(new Date(), "YYYY-MM-DD") ){
                           debugger;
                            if(cmps[i].get("v.name") == 'US_WSREMS__Prescription_Date__c'){
                                futureDateValidationMsg = 'Date of Prescription cannot be in the future.';
                            }else{
                                futureDateValidationMsg = cmps[i].get("v.label")+' cannot be in the future.'; 
                            }
                           
                            futureDateValidation = true;
                        }
                    }
                }
            }else {
                if (cmps.get("v.name") == 'US_WSREMS__Prescription_Date__c' || cmps.get("v.name") == 'date_of_Fill__c' ){
                    if (cmps.get("v.value") > $A.localizationService.formatDate(new Date(), "YYYY-MM-DD") ){
                        if(cmps[i].get("v.name") == 'US_WSREMS__Prescription_Date__c'){
                                futureDateValidationMsg = 'Date of prescription cannot be in the future.';
                            }else{
                                futureDateValidationMsg = cmps[i].get("v.label")+' cannot be in the future.'; 
                            }
                         futureDateValidation = true;
                    }
                }
                eventFields[cmps.get("v.name")] = cmps.get("v.value");
                
            }

            allValid =  [].concat(component.find('dateid')).reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if(!allValid){
                component.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Incorrect DOB value',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        }
        if(allValid && !futureDateValidation){
            debugger;
            component.set("v.showSpinner",false);
            var action = component.get("c.DEAValidation_enrollment");
            var eventFieldNew = eventFields;
            eventFieldNew.PharmacyName = component.get("v.PharmacyName");
            let FieldValuesStr = JSON.stringify(eventFieldNew);
            action.setParams({ recordTypeId : recordTypeId , fields :  FieldValuesStr }); 
            action.setCallback(this, function(response) {
                debugger;
                var state = response.getState();
                if (state === "SUCCESS") {
                    debugger;
                     component.set("v.validationResult", response.getReturnValue());
                    var todayDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                   // var deaValidation= deaValid;
                    
                    //component.set("v.validationResult", response.getReturnValue());
                       if (component.get("v.validationResult").DEAValidation){
                        eventFields.SYN_DEA_Validation__c = 'Valid';
                        eventFields.SYN_Validation_Date__c = todayDate;
                    }else{
                        eventFields.SYN_DEA_Validation__c = 'Invalid';
                        eventFields.SYN_Validation_Date__c = todayDate;
                    }
                    
                    if (component.get("v.validationResult").NPIValidation){
                        eventFields.NPI_Status__c = 'Valid';
                        var participantTypeBool = (component.get("v.requestorType") =='Prescriber' || component.get("v.requestorType") =='Pharmacy') ? true : false;
                        if (component.get("v.programNameStr") == 'Macitentan REMS' && eventFields.US_WSREMS__NPI__c && component.get("v.remsRecordTypeName") =='Enrollment' && participantTypeBool ){
                            eventFields.US_WSREMS__Status__c = 'Active'; 
                        }
                        
                    }else{
                        eventFields.NPI_Status__c = 'Invalid';
                        if (component.get("v.programNameStr") == 'Macitentan REMS' && eventFields.US_WSREMS__NPI__c && component.get("v.remsRecordTypeName") =='Enrollment' && participantTypeBool ){
                            eventFields.US_WSREMS__Status__c = 'Inactive'; 
                        }
                    }
                    if( component.get("v.caseId")){
                        eventFields.Id = component.get("v.caseId");
                    }
                 
                    
                    eventFields.US_WSREMS__Program_Picklist__c = component.get("v.programNameStr");       
             component.find('myform').submit(eventFields);
             component.set("v.showSpinner",true);
                    
                } else if (state === "ERROR") {
                    var errors = response.getError();
                  
                }
            });
            $A.enqueueAction(action);
            
        }
        if(futureDateValidation){
component.set("v.showSpinner",false);
            helper.futureDateValidationMsg(futureDateValidationMsg);
        }
        
    },
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Case record is created.",
            "type": "success"
        });
        toastEvent.fire();
        
        if (component.get("v.calledByFaxTransfo")){
            
            let  action = component.get("c.deleteDistLink");
            action.setParams({ distObjId : component.get("v.distributionlink")});
            action.setCallback(this, function(response) {
                
                 var parentId = component.get("v.docDetailIdVal");
                var dynamicAttribute = {
                    "DocDetailId": parentId,
                    "REMSServiceId": component.get("v.recordId"),
                    "Source":"NewCase"
                };
                component.find("REMSReviewDocumentChannel").publish(dynamicAttribute);
            });
            $A.enqueueAction(action);
            
        }
        if (!component.get("v.calledByFaxTransfo")){
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        }
        
    },
    handleError : function(component, event, helper) {
      
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": event.getParam("detail"),
            "type": "error"
        });
        toastEvent.fire();
        component.set("v.showSpinner",false);
       // $A.get("e.force:closeQuickAction").fire();
       // $A.get('e.force:refreshView').fire();
        
    },
    handleFieldChange : function(component, event, helper){

        let fieldName = event.getSource().get("v.fieldName") ; 
        let newValue =  event.getSource().get("v.value") ;
        var programName = component.get("v.programName");
        var requestorType = component.get("v.requestorType");
        var remsService = component.get("v.remsRecordTypeName");
        var caseRecordTypeId = component.get("v.caseRecordTypeId");
       	
        if ((newValue && fieldName == 'SYN_Prescriber__c') ||(newValue && fieldName == 'US_WSREMS__Facility__c')|| (newValue && fieldName == 'US_WSREMS__Patient__c' )|| (newValue && fieldName == 'US_WSREMS__Distributor__c') 
            || (newValue && fieldName == 'Pharmacy_Participant__c') || (newValue && fieldName == 'SYN_Pharmacy__c') || (newValue && fieldName == 'ProductId') || (newValue && fieldName == 'US_WSREMS__Pharmacy__c') 
            || (newValue && fieldName == 'X1_Pharmacy_Participant__c') ||(newValue && fieldName == 'SYN_Authorized_Rep__c') || (newValue && fieldName == 'US_WSREMS__Patient__c')
            ||(newValue && fieldName == 'SYN_Authorized_Rep__c') || (newValue && fieldName == 'Account_Name_Secondary_Office__c')||(newValue && fieldName == 'SYN_Name_of_Reporter__c') || (newValue && fieldName == 'X4_Name_of_Prescriber__c') || (newValue && fieldName == 'US_WSREMS__Secondary_Office_Contact__c') ||  (newValue && fieldName == 'US_WSREMS__Office_Contact__c')){
                 if(programName == 'Sodium Oxybate REMS' ){
                
                    if(fieldName == 'SYN_Prescriber__c' && remsService == 'Risk Management Report'){
                     sect = requestorType+';'+fieldName+';'+'SOX';
                     helper.getPrepopulationFields(component, event, helper , newValue,sect);
                    }else{
                       helper.getPrepopulationFields(component, event, helper ,newValue); 
                    }
           

            }else{
                var sect;
                //sect = remsService+':'+requestorType+';'+fieldName+';'+programName;
                sect = requestorType+';'+fieldName+';'+programName;
                helper.getPrepopulationFields(component, event, helper , newValue,sect);
            }
        }
        //BT6825-135
		// Added Logic for Maci program // feature/BT7433-63 
        if((newValue && fieldName == 'SYN_Reporter__c')|| (newValue && fieldName == 'X1_Participant__c')|| (newValue && fieldName == 'SYN_Impacted_Participant__c') || (newValue && fieldName == 'US_WSREMS__Participant__c' && programName != 'Sodium Oxybate REMS')){
            if(programName == 'Sodium Oxybate REMS'){
				var section;
				if(fieldName == 'SYN_Reporter__c'){
					section = 'Reporter';
				}
				if(fieldName == 'X1_Participant__c'){
					section = 'Investigated Participant';
				}
				if(fieldName == 'SYN_Impacted_Participant__c'){
					section = 'Impacted Participant';
				}
				helper.getPrepopulationFields(component, event, helper , newValue, section);
			}else{
				var sect;
                //sect = remsService+':'+requestorType+';'+fieldName+';'+programName;
                sect = requestorType+';'+fieldName+';'+programName;
                helper.getPrepopulationFields(component, event, helper , newValue,sect);
			}
        } //BT6825-135
        if(newValue && fieldName == 'US_WSREMS__Patient__c' ){
            const cmps = component.find("inputField");
            for(var i=0;i<cmps.length;i++){
                if(cmps[i].get("v.fieldName") == 'SYN_Patient_Name_Unknown__c'){
            cmps[i].set("v.value", false);
                }
            }
        }
        //BT6825-751
        if(newValue === '' && fieldName == 'US_WSREMS__Patient__c' && programName == 'Sodium Oxybate REMS' ){
            component.set("v.monitorParticipant", false);

        }
        if(newValue && fieldName == 'US_WSREMS__Patient__c' && programName == 'Sodium Oxybate REMS' ){
            var action = component.get("c.monitorParticipant");
            action.setParams({ recordId : newValue });
            action.setCallback(this,function(res){
            var state = res.getState();
            state === 'SUCCESS' && res && res.getReturnValue() && component.set("v.monitorParticipant", true);
        });
        $A.enqueueAction(action);
        } //BT6825-751

        if(newValue == true && fieldName == 'SYN_Patient_Name_Unknown__c'){
            const cmps = component.find("inputField");
                    for(var i=0;i<cmps.length;i++){
                        if(cmps[i].get("v.fieldName") == 'US_WSREMS__First_Name__c'){
                    cmps[i].set("v.value", 'Unknown');
                        }
                        if(cmps[i].get("v.fieldName") == 'US_WSREMS__Last_Name__c'){
                    cmps[i].set("v.value", 'Unknown');
                        }
                        if(cmps[i].get("v.fieldName") == 'US_WSREMS__Patient__c'){
                    cmps[i].set("v.value", '');
                        }
                        if(cmps[i].get("v.fieldName") == 'SYN_Gender__c'){
                            cmps[i].set("v.value", '');
                        }
                    }

        }

    },
	handleOptionChange : function(component, event, helper){
        let selectedValue = event.getParam("value");
        let showuploader = selectedValue == 'Yes' ? true:false;
        component.set("v.showUploader", showuploader);
		let attachmentChecked = selectedValue === 'Yes';
        component.set("v.attachmentChecked", attachmentChecked);
    
    },
    handleChangeInOption : function(component, event, helper){
        let selectedValue = event.getParam("value");
        let showuploader = selectedValue == 'Yes' ? true:false;
        component.set("v.showDiscrepanciesIdentified", showuploader);
		component.set("v.DiscrepanciesIdentified",selectedValue);
    
    },
    handleUploadFinished : function(component, event, helper){
        var uploadedFiles = event.getParam("files");
        //alert("Files uploaded : " + uploadedFiles.length);

        // Get the file name
        let uploadedfileNames = '';
        uploadedFiles.forEach(file => {console.log(file.name)
                                      uploadedfileNames = uploadedfileNames + file.name});
    },

   
})