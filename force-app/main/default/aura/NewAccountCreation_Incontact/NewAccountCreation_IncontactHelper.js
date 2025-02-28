({
    previousButton : function(component, event, helper) {
        
        var url = '/apex/SYN_SearchCustomerOnInboundCallPage?c__ANI='+component.get("v.callerId")+'&c__contactid='+component.get("v.contactId_incontact");
        var workspaceAPI = component.find("workspace");
                        
                        workspaceAPI.openConsoleURL({
                            "url": url,
                            "focus": true,
                            "labels": ["SYN_SearchCustomOnInboundCallPage", "", ""]
                        }).then(function(activeTabId) {
                            workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
                                workspaceAPI.closeTab({tabId : enclosingTabId});
                workspaceAPI.focusTab(activeTabId);
                                            });
        })
        .catch(function(error) {
            console.log('Error :',error);
        });
    }
})