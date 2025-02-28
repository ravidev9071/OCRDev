({
    
    handleTabEvent : function(component, event, helper) {
        
        var tabId = event.getParam("tabId");     
        component.set("v.tabId",tabId);
    },
    doInit : function(component, event, helper) {
        
        var name = component.get("v.sObjectName"); // gives you the sObject name
        var recordId = component.get("v.recordId"); // gives you the id of the sObject
       // component.set("v.recordId_new",recordId);
        //component.set("v.sObjectName_new",name);
        var action = component.get("c.getTaskStatus");
        action.setParams({recordId:recordId, sObjectName:name});
        // Call back method
        action.setCallback(this, function(response) {
            var responseValue = response.getReturnValue(); 
            component.set("v.taskStatus",responseValue);
            
            if(component.get("v.taskStatus.status")){
                helper.doMakeacall(component, event, helper);
            }else{
                $A.get("e.force:closeQuickAction").fire();
                
                helper.showToast(component, "info", "Can not make a call for this record as Outbound service and case is associated with this task",null,"dismissable");
                var workspaceAPI = component.find("workspace");
                workspaceAPI.openTab({
                    
                    pageReference: {
                        "type": "standard__recordPage",
                        attributes: {
                            recordId: component.get("v.taskStatus.record_Id"),
                            objectApiName: "US_WSREMS__REMS_Service_Summary__c",
                            actionName: "view"
                        }
                    },
                    focus: true
                }).then(function(response) {
                    
                    
                    
                })
                
                .catch(function(error) {
                    console.log(error);
                });  
            }
        });
        // Enqueue Action
        $A.enqueueAction(action);
        
    },
})