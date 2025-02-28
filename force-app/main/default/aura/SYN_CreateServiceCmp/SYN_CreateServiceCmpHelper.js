({
	
   opennewTab:function(component) {
      
         var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
          
            pageReference: {
                "type": "standard__recordPage",
                 attributes: {
                 recordId: component.get("v.ServiceId"),
                objectApiName: "US_WSREMS__REMS_Service_Summary__c",
                actionName: "view"
                      }
            },
            focus: true
        }).then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
               pageReference: {
                    "type": "standard__component",
                    "attributes": {
                       // "componentName": "c__SYN_CaseEditComponent" 
                        "componentName": "c__SYN_InboundOutboundCaseCmp"
                    },
                    "state": {
                        c__caserecordId: component.get("v.CaseId")
                    }
                },
                focus: true
            }).then(function(subtabId) {
                
                workspaceAPI.setTabLabel({
                    tabId: subtabId,
                    label: 'Case'
                });
                
            });
            })
       
        .catch(function(error) {
            console.log(error);
        });
       
     
  
    },
})