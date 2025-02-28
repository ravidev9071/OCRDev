({
	getEnclosingTabId : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            console.log(tabId);
            component.set("v.tabId",tabId);
       })
        .catch(function(error) {
            console.log(error);
        });
    },
    handleInformEvent : function(component, event, helper) {
        
        var appEvent = $A.get("e.c:SYN_SendTabIdEvent");
        appEvent.setParams({"tabId" : component.get("v.tabId")});
        appEvent.fire();
    }
})