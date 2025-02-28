({
	getLayoutSections : function(component) {
		var ob= component.get("v.objectName");
        var ly= component.get("v.layoutName");
        var caseRec = component.get("v.caseObj");
        var remsService = component.get("v.remsRecordTypeName");
        var programName = component.get("v.programName");
		var recordId = component.get("v.recordId");
        var requestorType = component.get("v.requestorType");
        var participantId = component.get("v.participantId");
        var fieldName = component.get("v.participantFieldAPIName");
		 var docDetId =component.get("v.docDetailIdVal");
         if(caseRec){
                if(caseRec['Id']){
                var lastIndex = caseRec['Id'].lastIndexOf('/') + 1;
                var Id = caseRec['Id'].substring(lastIndex);
                component.set("v.caseId",Id);
                }
            }
         var columnList = [];
        debugger;
        var action = component.get("c.getPageLayoutFields");
        
        action.setParams({ layoutName : ly });
       
        
		action.setCallback(this, function(response) {
        	var state = response.getState();
			if (state === "SUCCESS") {
              
                 var sectionList = [];
                var layoutSec = response.getReturnValue();
                component.set("v.layoutSections", response.getReturnValue() );
                if(participantId){
                    participantId = component.get("v.currREMServiceParticipantId");
                }
                 if(response.getReturnValue().length>0){
                    for(var sec in layoutSec){
                         sectionList.push(layoutSec[sec]['label']);
                        for(var fld in  layoutSec[sec]['lstFields']){
                            if(layoutSec[sec]['lstFields'][fld]['fieldName']){
                                columnList.push(layoutSec[sec]['lstFields'][fld]['fieldName']);
                                if(layoutSec[sec]['lstFields'][fld]['fieldName'] == 'US_WSREMS__REMSProgram__c'){
                                layoutSec[sec]['lstFields'][fld]['fieldValue'] = programId;
                                }
                                var fieldName = layoutSec[sec]['lstFields'][fld]['fieldName'];
                                
                                if(caseRec){
                                    layoutSec[sec]['lstFields'][fld]['fieldValue'] = caseRec[fieldName];
                                }
                            }
                        }
                    }
                    component.set("v.activeSections", sectionList);
                    component.set("v.layoutSections", layoutSec );

                       if( component.get("v.calledByFaxTransfo")){
                 var dynamicAttribute = {
                        "DocDetailId": docDetId,
                        "Source":"CaseColumns",
                        "CaseColumns":columnList
                    };
                    component.find("REMSReviewDocumentChannel").publish(dynamicAttribute);
                 }
}
				  var sec = requestorType+';Onload;'+programName +';'+recordId;
                if(!participantId){
                    participantId = component.get("v.currREMServiceParticipantId");
                }
                if(caseRec){
            var dateRec = component.find("dateid");
            for (var index in dateRec) {
                
                if(index>=0){
                    var fieldName = dateRec[index].get("v.name");
                        
                    if (fieldName){ 
                        if (caseRec[fieldName]){
                            
                            let prepopFieldValue = caseRec[fieldName] == ' ' ? '' : caseRec[fieldName];
                            dateRec[index].set("v.value",prepopFieldValue);
                        }   
                    }
                }
            } 
            }else{
                this.getPrepopulationFields(component, event, helper ,participantId,sec);                
            }
               


                //BT6825-222
                if(ly == 'Case-SYN_PAE_PC_MI Case Layout'|| ly== 'Case-SYNDistributorEnrollment' || (programName != 'Sodium Oxybate REMS' && (remsService == 'PAE/PC/MI' || remsService == 'Change in Reproductive Potential Status and Pre-pubertal Annual Verification'|| ly == "Case-MACI Change Authorized Representative"))){
                    const cmps = component.find("inputField");
                    for(var i=0;i<cmps.length;i++){
						if(remsService == 'Change in Reproductive Potential Status and Pre-pubertal Annual Verification' && cmps[i].get("v.fieldName") =='US_WSREMS__Outcome__c'){
                           cmps[i].set("v.value", 'Misclassification Review Pending');
                         }

                      if(remsService == 'PAE/PC/MI' && cmps[i].get("v.fieldName") =='US_WSREMS__Outcome__c'  && programName != 'Sodium Oxybate REMS'){
						   cmps[i].set("v.value", 'Acknowledgment Pending');
					     }  

                        if(ly=='Case-SYN_PAE_PC_MI Case Layout' && programName == 'Sodium Oxybate REMS' ){
                            if(cmps[i].get("v.fieldName") == 'SYN_Reporter_First_Name__c'){
								var rf= component.get("v.requestorFName");
								cmps[i].set("v.value", rf);
							}
							if(cmps[i].get("v.fieldName") == 'SYN_Reporter_Last_Name__c'){
								var rl= component.get("v.requestorLName");
								cmps[i].set("v.value", rl);
                                
							}
							if(cmps[i].get("v.fieldName") == 'SYN_Type_of_Reporter__c'){
								var rt= component.get("v.requestorType");
                               
								cmps[i].set("v.value", rt);
                               
                                 
							}
                        }


                        if(ly == "Case-MACI Change Authorized Representative"){
                            if(cmps[i].get("v.fieldName") == 'US_WSREMS__Pharmacy__c'){
                                var partcptId= component.get("v.participantId"); 
                                cmps[i].set("v.value", partcptId);
                            }
						}
                        if(ly == "Case-SYNDistributorEnrollment"){
							if(cmps[i].get("v.fieldName") == 'US_WSREMS__Distributor__c'){
								 
								cmps[i].set("v.disabled", true);
							}
                        }
                     }
                }
                const Macicmps = component.find("inputField");
                if (programName =='Macitentan REMS'){
                    for(var i=0;i<Macicmps.length;i++){
                        
                        debugger; 
                        if (Macicmps[i].get("v.fieldName") =='US_WSREMS__Channel__c'){
                            if (remsService == 'REMS Dispense Authorization' ||remsService == 'Non Compliance' || remsService == 'Inbound Communication' || remsService =='Outbound Communication'){
                                debugger; 
                                Macicmps[i].set("v.value", 'Phone');
                            }else {
                                debugger; 
                                Macicmps[i].set("v.value", 'Fax');
                            }
                        }
                    } 
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
			
            }
        });
        
        $A.enqueueAction(action);
	},
    getPrepopulationFields : function (component, event, helper , recId, secName){
        
        let targetObj = component.get("v.objectName"),
            targetRCtyId = component.get("v.caseRecordTypeId"),
            remsService = component.get("v.remsRecordTypeName"),
            programName = component.get("v.programName"),
            fieldsToDisable = 'First_Name_ar2__c,Last_Name_ar2__c,US_WSREMS__Email_PharmacyAddress__c,US_WSREMS__Phone_Pharmacyaddress__c,US_WSREMS__First_Name_ar__c,US_WSREMS__Last_Name_ar__c, US_WSREMS__UserType_ar__c,US_WSREMS__Email_ar__c,US_WSREMS__Phone_ar__c';
            var section_name;
            if(typeof secName === 'undefined'){
              section_name=null;
          }else{
              section_name=secName;
          }
          
        
        let action = component.get("c.getPrepopFields"); 
        
        action.setParams({ recordId : recId , TargetObj : targetObj ,  RecordTypeId : targetRCtyId, SectionName : secName });
        action.setCallback(this,function(res){
            var state = res.getState();
            
            if (state === "SUCCESS") {
                let TargetFieldValues = res.getReturnValue();
                const Macicmps = component.find("inputField");
                
                
                
                for (var index in component.find("inputField")) { 
                    var fieldName = component.find("inputField")[index].get("v.fieldName");
                    if (fieldName){ 
                        
                        if (TargetFieldValues[fieldName]){
                           let prepopFieldValue = TargetFieldValues[fieldName] == ' ' ? '' : TargetFieldValues[fieldName];
                            //component.find("inputField")[index].set("v.value",prepopFieldValue);
                            if(fieldName == 'Monthly_Pregnancy_Test_Recorded__c' || fieldName == 'Counseling_Recorded__c' ){
                               if(TargetFieldValues[fieldName] =='false'){
                               	Macicmps[index].set("v.value",false);
                               }else{
                                Macicmps[index].set("v.value",true);   
                               }
                            }else{
                                if (programName =='Macitentan REMS' && fieldName !='US_WSREMS__Channel__c'){
                                    Macicmps[index].set("v.value",prepopFieldValue);
                                }else {
                                    Macicmps[index].set("v.value",prepopFieldValue);
                                }
                                
                            }
                            if (programName =='Macitentan REMS' && remsService == 'Change Authorized Representative' && fieldsToDisable.includes(fieldName) ){
                                Macicmps[index].set("v.disabled",true);
                            }
                        }
                        
                    }
                    
                }
                
                for (var index in component.find("dateid")) {
                    if(index>=0){
                    var fieldName = component.find("dateid")[index].get("v.name");
                    if (fieldName){ 
                        if (TargetFieldValues[fieldName]){
                            let prepopFieldValue = TargetFieldValues[fieldName] == ' ' ? '' : TargetFieldValues[fieldName];
                            component.find("dateid")[index].set("v.value",prepopFieldValue);
                        }   
                    }
                    }
                }
                
                
            }
            else if (state === "INCOMPLETE") {
                component.set("v.showSpinner", false);
            }
                else if (state === "ERROR") {
                    component.set("v.showSpinner", false);
                    var errors = res.getError();
                    
                }
            
        });
        $A.enqueueAction(action);
    },
     getCurrentProgram : function (component){
        
        var recId = component.get("v.recordId");
       
        var action = component.get("c.getRemsServiceProgramName"); 
        action.setParams({ recordId : recId });
        action.setCallback(this,function(res){
            var state = res.getState();
            if (state === "SUCCESS") {
                var program = res.getReturnValue();
                component.set("v.programName",program);
            }else if (state === "INCOMPLETE") {
                component.set("v.showSpinner", false);
            }else if (state === "ERROR") {
                component.set("v.showSpinner", false);
                var errors = response.getError();
                
            }
            
        });
        $A.enqueueAction(action);
    },
    
    futureDateValidationMsg : function (Msg){
        debugger;
    	 var toastEvent = $A.get("e.force:showToast");
         
        toastEvent.setParams({
            "title": "Error!",
            "message": Msg,
            "type": "error"
        });
        toastEvent.fire();
	},

    getPageLayoutforRequestorType: function(component, event, helper, getActionName){
        var action = component.get("c.getPageLayoutforRequestorType");
        var recordId = component.get("v.recordId");
        action.setParams({ remsServiceId : recordId, caseActionName : getActionName});
        
         action.setCallback(this, function(response) {
        	var state = response.getState();
           // debugger;
			if (state === "SUCCESS") {
              //  debugger;
                var returnedValue = response.getReturnValue();
                component.set("v.layoutName", returnedValue.pageLayoutName);
                component.set("v.caseRecordTypeId", returnedValue.caseRecordTypeId);
                component.set("v.requestorType", returnedValue.requestorType);
                component.set("v.requestorFName", returnedValue.ParticipantFName);
                component.set("v.requestorLName", returnedValue.ParticipantLName); 
                component.set("v.requestorStatus", returnedValue.ParticipantStatus); //BT-6825-253 
                component.set("v.remsRecordTypeName", returnedValue.remsServiceRecordTypeName); //BT-6825-253
                component.set("v.remsPageTitle", returnedValue.pageTitle ); // displaying Page Title dynamically (Done by Maci Team)
                component.set("v.programName", returnedValue.programName );
               // component.set("v.participantId" , returnedValue.participantId);
               component.set("v.participantFieldAPIName" , returnedValue.participantFieldAPIName);
			   component.set("v.programRecordType" , returnedValue.programRecordType);
                //Added as a part of BT-6825 - Sprint7 - 33
                 this.getLayoutSections(component);
                var reqType = component.get("v.requestorType");
                var layoutName = component.get("v.layoutName");
                var status = component.get("v.requestorStatus"); //BT-6825-253
                var serviceRecordTypeName = component.get("v.remsRecordTypeName"); //BT-6825-253
                //Added as a part of BT-6825 - Sprint7 - 33
                var reqType = component.get("v.requestorType");
                var layoutName = component.get("v.layoutName");
                var title = component.get("v.remsPageTitle");
                if(title != '' && title != undefined){
                    component.set("v.condition",true);
                    component.set("v.body", title);
                }else{
                
                    if(reqType == "Pharmacy" && layoutName == "Case-SOX Patient Counseling Checklist Layout"){
                        component.set("v.condition",true);
                        component.set("v.body", "Patient Counseling Checklist");
                    }
                    else if((reqType == "Pharmacy" && layoutName == "Case-SYN Knowledge Assessment A Layout") ||
                            (reqType == "Pharmacy Participant" && layoutName == "Case-SYN Knowledge Assessment A Layout")){
                        component.set("v.condition", true);
                        component.set("v.body", 'Knowledge Assessment A');
                    }
                    else if((reqType == "Pharmacy" && layoutName == "Case-SYN Knowledge Assessment B Layout") ||
                            (reqType == "Pharmacy Participant" && layoutName == "Case-SYN Knowledge Assessment B Layout")){
                        component.set("v.condition", true);
                        component.set("v.body", 'Knowledge Assessment B');
                    }
                    else if((reqType == "Pharmacy"  || reqType == "Prescriber") && layoutName == "Case-SOX Risk Management Report Layout"){
                        component.set("v.condition", true);
                        component.set("v.body", 'Risk Management Report');
                    }
                    else if(layoutName == "Case-SYN_PAE_PC_MI Case Layout"){
                        component.set("v.condition", true);
                        component.set("v.body", 'PAE/PC/MI');
                    }
                    else if(layoutName == "Case-SYN_Pre_Dispense_Layout"){
                        component.set("v.condition", true);
                        component.set("v.body", 'REMS Dispense Authorization');
                    }
                    //Added as a part of BT-6825 - Sprint7 - 33 till this...
                    //BT-6825-253...Start..
                    // As part of the Story status == Certified and Enrolled are added 21092022
                    else if(serviceRecordTypeName == "Reenrollment" && (status == "Disenrolled" || status == "Certified" || status == "Enrolled") && reqType == "Patient" 
                                && layoutName == "Case-SOXPatientEnrollment Layout"){
                        component.set("v.condition", true);
                        component.set("v.body", 'Patient Reenrollment');
                    }else if(serviceRecordTypeName == "Reenrollment" && (status == "Disenrolled" || status == "Certified" || status == "Enrolled") && reqType == "Prescriber" 
                                && layoutName == "Case-SOXPrescriberEnrollment Layout"){
                        component.set("v.condition", true);
                        component.set("v.body", 'Prescriber Reenrollment');
                    }else if(serviceRecordTypeName == "Reenrollment" && (status == "Disenrolled" || status == "Certified" || status == "Enrolled") && reqType == "Pharmacy" 
                                && layoutName == "Case-SOXPharmacyEnrollment Layout"){
                        component.set("v.condition", true);
                        component.set("v.body", 'Pharmacy Reenrollment');
                    }else if(serviceRecordTypeName == "Reenrollment" && (status == "Disenrolled" || status == "Certified" || status == "Enrolled") && reqType == "Distributor" 
                                && layoutName == "Case-SYNDistributorEnrollment"){
                        component.set("v.condition", true);
                        component.set("v.body", 'Distributor Reenrollment');
                    }
                    else if(layoutName == "Case-SYN Non Compliance Case Layout"){
                        component.set("v.condition", true);
                        component.set("v.body", 'Noncompliance');
                    }
                    
                }
                
                /*if(status == "Disenrolled" && serviceRecordTypeName == "Enrollment"){
                    component.set("v.statusCondition", true);
                    component.set("v.errorBody","This participant is currently dis-enrolled, please create a re-enrollment service.");
                }else if(status != "Disenrolled" && serviceRecordTypeName != "Reenrollment"){
                    component.set("v.statusCondition", false);
                }*/
                //BT-6825-253...End..
                 if (component.get("v.calledByFaxTransfo")){
                    component.set("v.programNameStr", component.get("v.programName"));
                }
              //  helper.getLayoutSections(component);
               // debugger;
                // Chai edits
               
                helper.getCurrentProgram(component);
				
				var pageLayoutName = component.get("v.layoutName");
                var prog = component.get("v.programNameStr");
                
                if(prog == 'Macitentan REMS' && pageLayoutName == 'Case-MACI Change Authorized Representative'){
                    var partId = component.get("v.participantId");
                    var sect = returnedValue.requestorType+';'+'US_WSREMS__Pharmacy__c'+';'+prog;
                    helper.getPrepopulationFields(component, event, helper,partId,sect);
                } 
		        if(prog == 'Sodium Oxybate REMS'){
                    var soxPageLayoutList = ['Case-SOXPatientEnrollment Layout','Case-SOXPharmacyEnrollment Layout','Case-SOXPrescriberEnrollment Layout','Case-SYNDistributorEnrollment',
                                         'Case-SOX Risk Management Report Layout','Case-SOX Patient Counseling Checklist Layout','Case-SYN Knowledge Assessment A Layout',
                                         'Case-SYN Knowledge Assessment B Layout','Case-SYN_Pre_Dispense_Layout'];
                    if(soxPageLayoutList.includes(pageLayoutName)) {
                        var partId = component.get("v.currREMServiceParticipantId");
                        helper.getPrepopulationFields(component, event, helper,partId);
                        var tempFacilityId = component.get("v.facilityId");
                        if(pageLayoutName == 'Case-SOXPrescriberEnrollment Layout' && tempFacilityId) {
                            helper.getPrepopulationFields(component, event, helper,tempFacilityId);
                        }
                    } else if(pageLayoutName == 'Case-SYN Non Compliance Case Layout') {
                        var partId = component.get("v.currREMServiceParticipantId");
                    	var secttionName = 'Reporter';
                    	helper.getPrepopulationFields(component, event, helper,partId,secttionName);
                    }
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
				
            }
        });
        $A.enqueueAction(action); 
    },
})