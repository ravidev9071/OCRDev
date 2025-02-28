({
    doInit: function( component, event, helper ) {
        debugger;
       // component.set("v.AccountflagMsg" , false);
        var action = component.get("c.getRCTYPId");
        action.setParams({ rctypename : "Prescriber_Person_Account" });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnedValue = response.getReturnValue();
                console.log('RcId+++'+returnedValue.CaseRectypeId);
                component.set("v.caseRecordTypeId", returnedValue.CaseRectypeId);
                component.set("v.programId", returnedValue.ProgramId);
                component.set("v.programRecordType" , 'Sodium Oxybate REMS-Prescriber_Person_Account');
                console.log('ProgramId+++'+component.get("v.programId"));
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    handleSubmit : function(component, event, helper) {
        debugger;
        component.set("v.AccountflagMsg" , false);
        component.set("v.DEAInvalidMsg", false);
         component.set("v.NPIInvalidMsg", false);
         component.set("v.SLNInvalidMsg", false);
        
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam('fields');
        var recordTypeId = component.get("v.caseRecordTypeId");
        var PrgmId = component.get("v.programId");
        var NPIValue = component.find("casefield5").get("v.value");
        console.log('PrgmId+++'+PrgmId);
        console.log('NPIValue+++'+NPIValue);
        eventFields.RecordTypeId = recordTypeId;
        eventFields.US_WSREMS__REMS_Program__c = PrgmId;
        eventFields.US_WSREMS__Channel__c = 'Portal';
        eventFields.Status = 'Completed';
        eventFields.SYN_DEA_Validation__c  = 'Valid';
        eventFields.SYN_Validation_Date__c  = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        let FieldValuesStr = JSON.stringify(eventFields);
        var action = component.get("c.checkAccountDuplicates"); 
        component.set("v.showSpinner", true);
        action.setParams({ recordTypeId : recordTypeId , fields :  FieldValuesStr }); 
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var dupCheck = response.getReturnValue();
                console.log('DEA Valid '+dupCheck.DEAvalidation);
				
                component.set("v.AccountPresent", dupCheck.AccountExists);
                component.set("v.AcctId", dupCheck.AccountId);
                console.log('createAccount+++'+dupCheck.createAccount);
                console.log('dupfound++'+dupCheck.AccountExists);
                eventFields.US_WSREMS__Name__c = eventFields.SYN_Facility__c;
                eventFields.US_WSREMS__Facility__c  =dupCheck.FacilityId ;
                if ((dupCheck.createAccount) && (dupCheck.NPINumber != NPIValue || !NPIValue) && dupCheck.DEAvalidation && dupCheck.NPIvalidation && dupCheck.SLNvalidation ){
                    component.find('caseForm').submit(eventFields); 
                }
                else if ((dupCheck.createAccount) && dupCheck.NPINumber === NPIValue && dupCheck.HasUser === false && dupCheck.DEAvalidation && dupCheck.NPIvalidation && dupCheck.SLNvalidation){
                    component.find('caseForm').submit(eventFields); 
                }else if(dupCheck.createAccount === false){
                    	//component.set("v.flag", false);
                    	component.set("v.AccountflagMsg" , true);
                        
                } else if ( dupCheck.createAccount == true && dupCheck.DEAvalidation == false && dupCheck.Sche3Validation == true ){
                       //component.set("v.flag", false);
                        component.set("v.Sche3validMsg", true);
                }else if(dupCheck.createAccount == true && dupCheck.DEAvalidation == false && dupCheck.Sche3Validation == false ){
                    
                        component.set("v.DEAInvalidMsg", true);
                
                } /**1173:else if(dupCheck.createAccount == true && dupCheck.DEAvalidation == true && dupCheck.DEAAddressValidation == false ){
                    
                    component.set("v.DEAAddressInvalidMsg", true);
            
                } **/
                else if ( dupCheck.createAccount == true && dupCheck.DEAvalidation == true && dupCheck.NPIvalidation == false ){
                       //component.set("v.flag", false);
                        component.set("v.NPIInvalidMsg", true);
                 }else if ( dupCheck.createAccount == true &&dupCheck.DEAvalidation == true && dupCheck.NPIvalidation == true && dupCheck.SLNvalidation == false ){
                      // component.set("v.flag", false);
                        component.set("v.SLNInvalidMsg", true);
                 }
                
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log( 'Dup check error ',JSON.stringify(errors));
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);


        
     
    },
    handleSuccess : function(component, event, helper) {
        debugger;
        var AP = component.get("v.AccountPresent");
        var Accid = component.get("v.AcctId");
        if(AP === true){
            helper.updateAccountRecord(component, event, helper, Accid);
        }else{
            helper.navigateToRecord(component, event, helper);
        }
    },
    handleError : function(component, event, helper) {
        debugger;
        console.log('error ****'+event.getParam("detail"));
        var toastEvent = $A.get("e.force:showToast");
        $A.util.removeClass(component.find("lightning_message"), "slds-hide"); 
        toastEvent.setParams({
            "title": "Error!",
            "message": event.getParam("detail"),
            "type": "error"
        });
        
        toastEvent.fire();
    }
            
})