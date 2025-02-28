({
	 handleNextButton: function(component,event){
       
         var mailingAddressLine2 = component.get("v.addressInfoObj.MailingAddressLine2");
         var shippingAddressLine2 = component.get("v.addressInfoObj.ShippingAddressLine2");
         if(mailingAddressLine2 != undefined){
             component.set("v.newCase.US_WSREMS__Address_Line_1__c",component.get("v.newCase.US_WSREMS__Address_Line_1__c")+' '+mailingAddressLine2);
         }
         if(shippingAddressLine2 != undefined){
             component.set("v.newCase.Address_1_Secondary_Office__c",component.get("v.newCase.Address_1_Secondary_Office__c")+' '+shippingAddressLine2);
         }
        
        var evt = component.getEvent("ShowInPatinetScreens");
        evt.setParams({
            "screenName": "ShowAgreementInfoScreen",
            "oPharmyInfo" : component.get("v.newCase")
            
        });
        evt.fire();
    },
    fireEvent: function(component,event,screenName){
        var evt = component.getEvent("ShowInPatinetScreens");
        evt.setParams({
            "screenName": screenName
        }).fire();
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
    getstatePicklist: function(component, event) {        
        var action = component.get("c.getStates");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var stateMap = [];
                for(var key in result){
                    stateMap.push({key: key, value: result[key]});
                } 
                component.set("v.stateMap", stateMap);
            }
        });
        $A.enqueueAction(action);
    },
})