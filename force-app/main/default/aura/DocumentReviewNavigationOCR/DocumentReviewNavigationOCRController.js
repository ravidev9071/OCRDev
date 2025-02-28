({
    myAction: function (component, event, helper) {
        
        var detProgaction = component.get("c.retrieveDocumentDetails");
        detProgaction.setParams({ 'detailId': component.get("v.recordId") });
        detProgaction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let docDetObj = response.getReturnValue();
                var valid = true;
                if (!docDetObj) {
                    valid = false;
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: $A.get("$Label.c.Program_Validation_Msg"),
                        duration: ' 5000',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }else{
                    component.set("v.programId",docDetObj.ParentRecordId);
                    if(docDetObj.ParentRecord.Name){
                        component.set("v.programLabel",docDetObj.ParentRecord.Name);
                    }
                }
                
                if ((docDetObj.US_WSREMS__REMS_Service__c)) {
                    valid = false;
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: $A.get("$Label.c.Document_Reviewed_Validation"),
                        duration: ' 5000',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                
                var action = component.get("c.retrieveFileOnDocumentDetail");
                action.setParams({
                    "parentObjId": component.get("v.recordId")
                });
                action.setCallback(this, function (response) {
                    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var distObj = response.getReturnValue();
                        if(!distObj){
                            valid = false;
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                message: $A.get("$Label.c.Valid_file_Msg"),
                                duration: ' 5000',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                        if(valid){
                            let workspaceAPI = component.find("workspace"),
                                focusedTabId;
                            
                            workspaceAPI.getFocusedTabInfo().then(function(response) {
                                
                                focusedTabId = response.tabId;
                                
                                workspaceAPI.openSubtab({
                                    
                                    parentTabId:focusedTabId,
                                    
                                    pageReference: {
                                        "type": "standard__component",
                                        "attributes": {
                                            "componentName": "c__DocumentReviewOCR"  // c__<comp Name>
                                        },
                                        "state": {
                                            "uid": component.get("v.recordId"),
                                            "name": component.get("v.recordId"),
                                            "c__recordId": component.get("v.recordId"),
                                            "c__programId":  component.get("v.programId"),
                                            "c__programName":  component.get("v.programLabel")
                                        }
                                    },
                                    focus: true
                                }).then((response) => {
                                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                    dismissActionPanel.fire();
                                    $A.get('e.force:refreshView').fire();
                                    workspaceAPI.setTabLabel({
                                    tabId: response,
                                    label: "New REMS Service" + '-' + response
                                });
                            }).catch(function (error) {
                                console.log(error);
                            });
                        })
                        .catch(function(error) {
                            console.log('response' +JSON.stringify(response));
                            console.log(error);
                        });
                        
                        
                        
                    }else{
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                    }
                }
                                   });
                $A.enqueueAction(action);
            }
            
            
        });
        $A.enqueueAction(detProgaction);
    }
    
})