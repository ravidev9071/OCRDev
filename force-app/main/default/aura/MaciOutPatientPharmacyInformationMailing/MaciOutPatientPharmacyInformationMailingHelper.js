({
	 handleNextButton: function(component,event){
        
       
         
         var addr1 = component.get("v.mailingAddressInfoObj.Address1");
         var addr2 = component.get("v.mailingAddressInfoObj.AddressLine2");
         if(addr2 != undefined){
             component.set("v.newCase.US_WSREMS__Address_Line_1__c",addr1+' '+addr2);
         }else{
             component.set("v.newCase.US_WSREMS__Address_Line_1__c",addr1);
         }
         component.set("v.newCase.US_WSREMS__City__c",component.get("v.mailingAddressInfoObj.city"));
         component.set("v.newCase.US_WSREMS__State__c",component.get("v.mailingAddressInfoObj.state"));
         component.set("v.newCase.US_WSREMS__REMS_Zip_Code__c",component.get("v.mailingAddressInfoObj.zipcode"));
        
        var evt = component.getEvent("ShowOutPatinetScreens");
        evt.setParams({
            "screenName": "ShowAgreementInfoScreen",
            "oPharmyInfo" : component.get("v.newCase")
            
        });
        evt.fire();
    },
    fireEvent: function(component,event,screenName){
        var evt = component.getEvent("ShowOutPatinetScreens");
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