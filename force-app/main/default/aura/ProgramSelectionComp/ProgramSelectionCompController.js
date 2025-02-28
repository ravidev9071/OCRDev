({
	doInit : function(component, event, helper){
        var action = component.get("c.getCurrentUserProgram");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length == 1 && result[0].US_WSREMS__REMS_Program__r.Name == 'Macitentan REMS'){
                    component.set("v.selectedProgram",result[0].US_WSREMS__REMS_Program__r.Name);
					component.set("v.showMaciComponent", true);
                }else if(result.length == 1 && result[0].US_WSREMS__REMS_Program__r.Name == 'Sodium Oxybate REMS'){
                    component.set("v.selectedProgram",result[0].US_WSREMS__REMS_Program__r.Name);
                    component.set("v.showSodiumOxybateComponent", true);
                }else{
                     component.set("v.showProductComponent", true);
                }
            }
            
        });
        $A.enqueueAction(action);
    },
})