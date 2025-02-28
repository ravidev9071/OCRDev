({
	doInit: function(component, event, helper) {     
        helper.getpharmacyList(component, event);    
    },
    
    swithpharmacy : function(component, event, helper) {
        var recordId = component.get('v.selectPharmacy');
        var pharmacyType = component.get('v.pharmacyType');
        var action = component.get("c.updateDefaultPharmacy");
          action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();   
                
                if(result == ''){
                    helper.showToast(component,event,'Successfully, You switched the pharmacy!','success');
                    if(pharmacyType == 'Outpatient'){
                        var nav = component.find("navigation");
                        var pageReference = {
                            type: "comm__namedPage",
                            attributes: {
                                pageName: 'pharmacy-manage-home'
                            }
                        };
                        nav.navigate( pageReference );
                        helper.navigateToMangePharmacyPage(component, event);
                    }else{
                        var nav = component.find("navigation");
                        var pageReference = {
                            type: "comm__namedPage",
                            attributes: {
                                pageName: 'inpatient-manage-pharmacy'
                            }
                        };
                        nav.navigate( pageReference );
                        helper.navigateToInPatientMangePharmacyPage(component, event);
                    }
                }else{
                	helper.showToast(component,event,'Something went wrong, please contact system admin.','Warning');
                }
            }
        });
        $A.enqueueAction(action);
    },
})