({
	handleInit : function(component, event) {
        var action = component.get("c.getCurrentUserAccountInfo");
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.cAccount', resultData);
                this.getCurrentPrescriberPatientInfo(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCurrentPrescriberPatientInfo : function(component, event) {
       
        var action = component.get("c.getPatientPregnancyInfo");
        var patientAccount= component.get("v.patientID");
        
        action.setParams({
            program : 'Macitentan REMS',
            patientId : patientAccount
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.isLoading', false);
                var resultData = result.getReturnValue();
                component.set('v.pAccount', resultData);
            }
            if(component.get('v.pAccount.US_WSREMS__Patient_Risk_Category__c') =='FNRP (other medical reasons for permanent irreversible infertility)' || component.get('v.pAccount.US_WSREMS__Patient_Risk_Category__c') == 'FNRP (Patient is pre-pubertal)' || component.get('v.pAccount.US_WSREMS__Patient_Risk_Category__c') == 'FNRP (Patient is post-menopausal)' ) {
                component.set("v.isDisabled" , false);
            } 
        });
        $A.enqueueAction(action);
    },
    
    handleNextButton: function(component,event){
        var programId = component.get("v.pAccount.US_WSREMS__REMS_Program__c");
        var patientAccountId = component.get("v.pAccount.Id");
        component.set("v.dCase.US_WSREMS__REMS_Program__c",programId);
        component.set("v.dCase.US_WSREMS__Program_Picklist__c",'Macitentan REMS');
        component.set("v.dCase.US_WSREMS__Channel__c",'Portal');
        component.set("v.dCase.US_WSREMS__Participant__c",patientAccountId);
        component.set("v.dCase.US_WSREMS__Requestor_Type__c",'Patient');
        
        var action = component.get("c.patientDisEnrollment");
        action.setParams({
            dcase : component.get("v.dCase")
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            component.set('v.isLoading', false);
            if (component.isValid() && state === "SUCCESS"){
                var nav = component.find("navigation");
                var pageReference = {
                    type: "comm__namedPage",
                    attributes: {
                        pageName: 'manage-patients'
                    }
                };
                nav.navigate( pageReference ); 
            }else{
                 component.set("v.ShowSpinner",false);
            }
        });
        $A.enqueueAction(action);   
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
    
    getDissEnrollmentReasonPicklist: function(component, event) {        
        var action = component.get("c.getDisEnrollmentReason");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var DissEnrollmentReason = [];
                for(var key in result){
                    DissEnrollmentReason.push({key: key, value: result[key]});
                } 
                component.set("v.DissEnrollmentReasonMap", DissEnrollmentReason);
            }
        });
        $A.enqueueAction(action);
    },
})