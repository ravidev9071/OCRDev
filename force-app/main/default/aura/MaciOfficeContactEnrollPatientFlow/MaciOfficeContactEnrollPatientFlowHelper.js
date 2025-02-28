({
    doInit : function(component, event, helper) {
        var action = component.get("c.getCurrentUserAccountInfo");
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.cAccount', resultData);
                helper.getPrescriberList(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },

    getPrescriberList: function(component, event, helper) {
        var action = component.get("c.getOCAssociatedPrescriberList");
        action.setParams({
            "officeContact": component.get("v.cAccount")
        });
        action.setCallback(this, function(result) {
           var state = result.getState();
           if (component.isValid() && state === "SUCCESS"){
               let resultData = result.getReturnValue();
               var options = [];
               Object.entries(resultData).forEach(function(element) {
                    options.push({ value: element[0], label: element[1] });
                });

               component.set('v.prescribers', options);
           }
       });
       $A.enqueueAction(action);
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
     savePrescriberDetails: function(component, event, helper) {
        component.set('v.prescriberName', event.getParam("prescriberName"));
        component.set('v.prescriberNPI', event.getParam("prescriberNPI"));
    },
})