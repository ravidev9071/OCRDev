({
	doInit: function( component, event, helper ) {

        helper.getNameSpa(component);        
        helper.getObjectAPIName(component);
		let action = component.get("c.getPageLayoutNameAndRecordTypeIdForChangeAuthorizedRep");
        action.setParams({ recordId : component.get('v.recordId')
                         });
		action.setCallback(this, function(response) {
        	let state = response.getState();
			if (state === "SUCCESS") {
                let returnedValue = response.getReturnValue(),
                    pharmacyValue = returnedValue.oSummary.US_WSREMS__Participant__c ? returnedValue.oSummary.US_WSREMS__Participant__c : '';

                component.set("v.layoutName", returnedValue.pageLayoutName);
                component.set("v.caseRecordTypeId", returnedValue.caseRecordTypeId);
                component.set("v.OAffliation", returnedValue.oAffliation);
                component.set("v.oSummary", returnedValue.oSummary);
                component.set("v.pharmacy", pharmacyValue);
                component.set("v.programRecordType" , returnedValue.programRecordType);

                
                helper.getLayoutSections(component);
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
				console.log( errors );
            }
        });
    
        $A.enqueueAction(action);
    },

    handleLoad : function(component, event, helper) {
    	component.set("v.showSpinner", false);   
    },

    handleSubmit : function(component, event, helper) {
        let recordId = component.get("v.recordId"),
            recordTypeId = component.get("v.caseRecordTypeId"),
            launchedFromCase = component.get("v.launchedFromCase");
            debugger;
        if(!launchedFromCase){
            event.preventDefault(); // stop form submission
            let eventFields = event.getParam("fields"),
                nameSpace = component.get("v.nameSpaceStr"),
                rss = nameSpace+'REMS_Service_Summary__c',
                userType=nameSpace+'UserType__c',
               // pharmacyUser=nameSpace+'Pharmacy_User__c',
                affiliationType = 'Authorized Representative';
           debugger;
         //  alert(eventFields[userType]);
           if (eventFields[userType] == null ||eventFields[userType] == '' || (!eventFields[userType].includes(affiliationType))) {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": affiliationType+ ' must be one of the selected user types' ,
                    "type": "Error"
                });
                toastEvent.fire();
                return;
            }  
            eventFields[rss] = recordId;
            eventFields[`${nameSpace}Pharmacy_User_ar__c`] = component.get("v.OAffliation")?component.get("v.OAffliation")[`${nameSpace}Pharmacy_User__c`] : null;
            eventFields[`${nameSpace}Pharmacy__c`] = component.get("v.oSummary")[`${nameSpace}Participant__c`];
            // eventFields[`${nameSpace}Pharmacy_User__c`] = component.get("v.pharmacyUser");
            eventFields.RecordTypeId = recordTypeId;
            component.find('myform').submit(eventFields);
        }
    },
    handleSuccess : function(component, event, helper) {
        let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Case record is created.",
                    "type": "success"
                });
                toastEvent.fire();
        if (component.get("v.calledByFaxTransfo")){
            var dynamicAttribute = {
                "DocDetailId": component.get("v.docDetailIdVal"),
                "REMSServiceId": component.get("v.recordId"),
                "Source":"NewCase"
            };
            component.find("REMSReviewDocumentChannel").publish(dynamicAttribute);    
        }
        if (!component.get("v.calledByFaxTransfo")){
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        }
               
        
    },
    handlePharmacyUserChange : function(component, event, helper) { 
       //alert('HI1');
        let layoutSections = component.get("v.layoutSections"),
            layoutSectionsString = JSON.stringify(layoutSections),
            pharmacyUserValue = event.getParam("value")[0],
            action = component.get("c.getRelatedFieldsForPharmacyUser");
        component.set("v.pharmacyUser", pharmacyUserValue);
        action.setParams({ existingLaoutSectionString : layoutSectionsString,
                            pharmacyUserId : pharmacyUserValue,
                            onLoadOnly : false,
                            recordId : component.get("v.recordId")
                         });
		action.setCallback(this, function(response) {
        	let state = response.getState();
			if (state === "SUCCESS") {
                component.set("v.layoutSections", response.getReturnValue() );
            } 
            else if (state === "ERROR") {
                let errors = response.getError();
				console.log( errors );
            }
        });
        $A.enqueueAction(action);

    },
    handlePharmacyChange : function(component, event, helper) {
       // alert('HI');
        let layoutSections = component.get("v.layoutSections"),
            layoutSectionsString = JSON.stringify(layoutSections),
            pharmacyValue = event.getParam("value")[0],
            action = component.get("c.getRelatedFieldsForPharmacy");
        component.set("v.pharmacy", pharmacyValue);

        action.setParams({ existingLaoutSectionString : layoutSectionsString,
                            pharmacyId : pharmacyValue
                         });
		action.setCallback(this, function(response) {
        	let state = response.getState();
			if (state === "SUCCESS") {
                let returnedValue = response.getReturnValue();
                component.set("v.layoutSections", response.getReturnValue() );
            } 
            else if (state === "ERROR") {
                let errors = response.getError();
				console.log( errors );
            }
        });
        $A.enqueueAction(action);
    },
    handleError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
         
        toastEvent.setParams({
            "title": "Error!",
            "message": event.getParam("detail"),
            "type": "error"
        });
        toastEvent.fire();
        
   },
})