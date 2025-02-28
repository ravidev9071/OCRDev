({
    startSurveyNewTab:function(component) {
       
        var workspaceAPI = component.find("workspace");      
        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {           
            workspaceAPI.openSubtab({
                parentTabId: component.get("v.tabId"),       
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__SYN_SurveyURL"
                        
                    },
                    "state": {
                        c__resultUrl: component.get("v.surveyurl")
                    }
                },
                focus: true
            }).then(function(subtabId) {
                
                workspaceAPI.setTabLabel({
                    tabId: subtabId,
                    label: component.get("v.surveyWrapper").SurveyName
                });
                
            }).catch(function(error) {
                console.log( 'Error is ' + error );
            });
            
            
        });
    },
    fetchExistingSurveys : function(component,event,helper){
        var action  = component.get("c.getInvitations");
        action.setParams({
            "recordId" :component.get("v.recordId") 
        });
        action.setCallback(this,function(response){
           var state  = response.getState();
            if(state==="SUCCESS") {
                component.set("v.existingSurveyNames",response.getReturnValue());
            }
            if(state === "Error") {
                console.log('error occured');
            }
        });
        $A.enqueueAction(action);
    }
    
    
})