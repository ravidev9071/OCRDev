({
	handleOnChangeSubRole : function(component, event, helper) {
		var selectedsubRoleValue = component.find("selectSubRole").get("v.value");
        if(selectedsubRoleValue == 'Prescriber'){
            component.set("v.allowOnClickNextProvider",true);
            component.set("v.allowOnClickNextPharmacy",false);
           // component.set("v.hideScreen1",false);
            
            $A.util.addClass(component.find("messageId2"),"slds-hide");
        }else if(selectedsubRoleValue == 'Pharmacy Participant'){
            component.set("v.allowOnClickNextProvider",false);
            component.set("v.allowOnClickNextPharmacy",true);
          //  component.set("v.hideScreen1",false);
            $A.util.addClass(component.find("messageId2"),"slds-hide");
            
        }else{
            $A.util.removeClass(component.find("messageId2"),"slds-hide");
        }
	},
    
})