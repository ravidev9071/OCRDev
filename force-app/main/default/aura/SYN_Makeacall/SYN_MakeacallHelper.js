({
    doServiceCreation : function(component, event, helper) {
        
        var name = component.get("v.sObjectName"); // gives you the sObject name
        var recordId = component.get("v.recordId"); 
        var contactId = component.get("v.callWrapper.ContactId"); // gives you the id of the sObject
        var action = component.get("c.callServiceCreation");
        action.setParams({recordId:recordId, sObjectName:name,Contact_Id:contactId});
        // Call back method
        action.setCallback(this, function(response) {
            var responseValue = response.getReturnValue();
            component.set("v.WrapperObj",responseValue);
            if(component.get("v.WrapperObj").status){
                this.opennewTab(component);  
            }else{
                helper.showToast(component, "Error",component.get("v.WrapperObj").status_message ,null,"dismissable");
            }
            
        });
        // Enqueue Action
        $A.enqueueAction(action);
    },
    opennewTab:function(component) {
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            
            pageReference: {
                "type": "standard__recordPage",
                attributes: {
                    recordId: component.get("v.WrapperObj.ServiceId"),
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
                        "componentName": "c__SYN_InboundOutboundCaseCmp"
                    },
                    "state": {
                        c__caserecordId: component.get("v.WrapperObj.CaseId")
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
    doMakeacall : function(component, event, helper) {
        
        var name = component.get("v.sObjectName"); // gives you the sObject name
        var record_Id = component.get("v.recordId"); // gives you the id of the sObject
        var action = component.get("c.makeacall");
        
        action.setParams({recordId:record_Id, sObjectName:name});
        // Call back method
        action.setCallback(this, function(response) {
            var responseValue = response.getReturnValue(); 
            
            component.set("v.callWrapper",responseValue);
            if(component.get("v.callWrapper").status){
                this.doServiceCreation(component, event, helper);
                component.set("v.messageStatus",true);
                component.set("v.status_message","Connecting call to "+component.get("v.callWrapper").Phoneno);
            }else{
                 component.set("v.messageStatus",false);
                component.set("v.status_message",component.get("v.callWrapper").status_message);
            }
            
            
        });
        // Enqueue Action
        $A.enqueueAction(action);
    },
    
    showToast: function (component, variant, title, message, messageData, mode) {
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "messageData": messageData,
            "mode": mode,
            "variant": variant
        });
    },
})