({
    getLayoutSections : function(component,PGName) {
        var action = component.get("c.getPGfileds");
        action.setParams({ PGlayoutName : PGName  }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnedValue = response.getReturnValue();
                var activeSection =[];
                for(const index in returnedValue ){
                    activeSection.push(returnedValue[index]['label']);
                }
                component.set("v.activeSections",activeSection);
                component.set("v.layoutSections", returnedValue );
                component.set("v.showSpinner", false);   
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getPrepopulationFields : function (component, event, helper , recId){
        
        
        var targetObj = component.get("v.objectName");
        var targetRCtyId = component.get("v.recordtypeId");
        
        var action = component.get("c.getPrepopFields");
        
        action.setParams({ recordId : recId , TargetObj : targetObj ,  RecordTypeId : targetRCtyId });
        action.setCallback(this,function(res){
            var state = res.getState();
            
            if (state === "SUCCESS") {
                
                
                var TargetFieldValues = res.getReturnValue();
                for (var index in component.find("InputField")) { 
                    var fieldName = component.find("InputField")[index].get("v.fieldName");
                    if (fieldName){ 
                        if (TargetFieldValues[fieldName]){
                            component.find("InputField")[index].set("v.value",TargetFieldValues[fieldName]);
                        }
                    }
                }
            }
            else if (state === "INCOMPLETE") {
                component.set("v.showSpinner", false);
            }
                else if (state === "ERROR") {
                    component.set("v.showSpinner", false);
                    var errors = response.getError();
                    
                }
            
        });
        $A.enqueueAction(action);
    },
    
    stopSpinner : function(component){
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    navigateToRecord : function(component, event, helper){
        var payload = event.getParams().response;
        
        var action = component.get("c.createAccountOnCaseCreation");
        action.setParams({ CaseId : payload.id });
        action.setCallback(this,function(res){
            var state = res.getState();
            debugger;
            if (state === "SUCCESS") {
                
                let returnValue = res.getReturnValue();
                let isAccountCreated = returnValue['AccountCreate'];
                var title='';
                var type='';
                
                if (isAccountCreated){
                    let accountId = returnValue['AccountId'];
                    let navService = component.find("navService");
                    title = 'Success!';
                    type='success';
                   
                    
                    
                    var workspaceAPI = component.find("workspace");
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
                        console.log(error);
                    });
                   
                }else{
                    title = 'Error!';
                    type='error';
                }
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": title,
                    "message": returnValue['notificationMsg'] ,
                    "type": type 
                });
                component.set("v.showSpinner",false);
                toastEvent.fire();  
                
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = res.getError();
                    console.log('Error Msg '+JSON.stringify(errors));
                    
                }
        });
        $A.enqueueAction(action);
        
    },
    
    previousScreen : function(component, event, helper){
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            helper.openTabOnCancelButton(component, event, helper);
            workspaceAPI.closeTab({tabId : enclosingTabId});
       })
        .catch(function(error) {
            console.log('enclosing erro : ',error);
        });

    },

    openTabOnCancelButton : function(component, event, helper){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            pageReference: {
                type : "standard__component",
                attributes: {
                     componentName : "c__NewAccountCreation_Incontact"    
                  },   
                  state: {
                    c__contactId_incontact : component.get("v.contactId_incontact"),
                    c__callerId : component.get("v.callerId")  
                }   
            },
            focus: true
        }).then(function(response) {
            console.log('TabId ',response);
               workspaceAPI.setTabLabel({
                tabId: response,
                label: "SYN_SearchCustomOnInboundCallPage"
            });
        }).catch(function(error) {
            console.log('error**',error);
        });
    }
})