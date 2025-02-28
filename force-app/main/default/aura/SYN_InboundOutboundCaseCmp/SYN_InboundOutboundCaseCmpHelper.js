({
    getLayoutSections : function(component) {
        var ob= component.get("v.objectName");
        var ly= component.get("v.layoutName");
        
        var action = component.get("c.getPageLayoutFields");
        action.setParams({ layoutName : ly });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.layoutSections", response.getReturnValue() );
                var result=response.getReturnValue();
                
                var strname=[];
                if (result != null) {
                    
                    var listLength = result.length;
                    for (var i=0; i < listLength; i++) {
                        strname.push(result[i].label);
                   
                    }
                }
            
                component.set("v.activeSections",strname );
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log( errors );
            }
        });
        
        $A.enqueueAction(action);
    }
})