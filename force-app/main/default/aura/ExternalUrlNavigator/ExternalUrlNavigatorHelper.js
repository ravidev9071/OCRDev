({
    updateRecordAndRedirect : function(component, recordId) {
        var action = component.get("c.updateRecordsAndGetRedirectUrl");
        action.setParams({ recordId: recordId });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var url = response.getReturnValue();
                console.log("Apex returned URL: ", url);
                
                var workspaceAPI = component.find("workspace");
                workspaceAPI.openTab({
                    url: url,
                    focus: true
                }).then(function(tabId) {
                    console.log("Tab opened with id: " + tabId);
                }).catch(function(error) {
                    console.error("Error opening tab via workspace API:", error);
                });
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Apex error: " + errors[0].message);
                } else {
                    console.error("Unknown error in Apex call.");
                }
            }
        });
        $A.enqueueAction(action);
    }
})