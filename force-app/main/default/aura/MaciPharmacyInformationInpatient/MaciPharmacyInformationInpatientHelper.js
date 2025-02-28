({
    getProviderDetails: function(component,event,helper){
            component.set("v.newCase.Inpatient_Pharmacy_Type__c",'');
            component.set("v.newCase.Other__c",'');
            component.set("v.pharmacistInfo.Title__c",component.get("v.authorizedRepTile"));
            component.set("v.pharmacistInfo.Other_Title__c",component.get("v.authorizedRepTileOther"));        
        var action = component.get("c.getPharmacyNPIDetails");        
        var providerNpi = component.get("v.newCase.US_WSREMS__NPI__c");
         action.setParams({
             providerNPI : providerNpi
         });
        action.setCallback(this, function(result) {
            var state = result.getState();
             component.set("v.ShowSpinner",false);
            
            if (component.isValid() && state === "SUCCESS"){
                var Pharmacy = result.getReturnValue();
                
                if(Pharmacy != null){
                    component.set("v.ShowNPIInfo",true);
                    component.set("v.newCase.US_WSREMS__Name__c",Pharmacy.PharmacyName);
                    //Mailing address....
                    component.set("v.newCase.US_WSREMS__Address_Line_1__c",Pharmacy.StreetAddress);
                    component.set("v.newCase.US_WSREMS__City__c",Pharmacy.city);
                    component.set("v.newCase.US_WSREMS__State__c",Pharmacy.State);
                    component.set("v.newCase.US_WSREMS__REMS_Zip_Code__c",Pharmacy.postalCode);
                    component.set("v.useMailingAddress",false);
                    component.set("v.newCase.Address_1_Secondary_Office__c",'');
                    component.set("v.newCase.City_Secondary_Office__c",'');
                    component.set("v.newCase.State_Secondary_Office__c",'');
                    component.set("v.newCase.SYN_Zip_Code__c",'');
                        //component.set("v.addressInfoObj.ShippingAddressLine2",component.get("v.addressInfoObj.MailingAddressLine2"));
                   
                    
                }else{
                   this.showToast(component,event,'We did not find pharmacy information based on your input.','Error');
                }
            }else if(state === "ERROR"){
                  this.showToast(component,event,'Something Went Wrong','Warning');
            }
        });
        $A.enqueueAction(action);
    },
    
    handleNextButton: function(component,event){
        var action = component.get("c.validatePharmacyNPIDupCheck");
        var providerNpi = component.get("v.newCase.US_WSREMS__NPI__c");
         action.setParams({
             npi : providerNpi, 
             recTypeDevName : 'Pharmacy',
             program : 'Macitentan REMS'
         });
        action.setCallback(this, function(result) {
            component.set("v.ShowSpinner",false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var duplicateFlag = result.getReturnValue();
                if(duplicateFlag == true){
                    this.showToast(component,event,'Duplicate record found.','Warning');
                }else{
                    
                    var evt = component.getEvent("ShowInPatinetScreens");
                    evt.setParams({
                        "screenName": "MailingAddressInfoScreen1",
                        "oPharmyInfo" : component.get("v.newCase"),
                        "useMailingAddress" : component.get("v.useMailingAddress")
                    });
                    evt.fire();
                }
            }else{
                this.showToast(component,event,'Something went wrong, please contact system admin.','Warning');
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
    
    fireEvent: function(component,event,screenName){
        var evt = component.getEvent("ShowInPatinetScreens");
        evt.setParams({
            "screenName": screenName
        }).fire();
    },
    
})