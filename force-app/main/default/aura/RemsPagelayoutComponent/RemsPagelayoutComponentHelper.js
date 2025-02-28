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
                            
                            let prepopFieldValue = TargetFieldValues[fieldName] == ' ' ? '' : TargetFieldValues[fieldName];
                            component.find("InputField")[index].set("v.value",prepopFieldValue);
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
                    let AccountName = returnValue['accountRec']['Name'];
                    title = 'Success!';
                    type='success';
                    let calledByFaxTransfo = component.get("v.calledByFaxTransfo");
                    
                    
              if (!calledByFaxTransfo){   
                    var workspaceAPI = component.find("workspace");
                    
                    workspaceAPI.openTab({
                        pageReference: {
                            type : 'standard__recordPage',
                            attributes: {
                                recordId : accountId,
                                actionName: "view"
                            }
                        },
                        focus: true
                    }).then(function(newTabId) {
                        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
                            workspaceAPI.closeTab({tabId : enclosingTabId});
                            workspaceAPI.focusTab(newTabId);
                        });
                    }).catch(function(error) {
                        console.log('open Tab Error',JSON.stringify(error) );
                    });
                }else if (calledByFaxTransfo){
                      
                    let param = {Name: AccountName};
                      //alert('called By FaxTransfo '+param);
                    var dynamicAttribute = {
                        "showAccountSearch": true,
                        "fieldsObjList":param,
                        "Source":"NewAccount",
                       // "Parent":component.get("v.parentRecordId")
                    };
                    
                      component.find("REMSReviewDocumentChannel").publish(dynamicAttribute);
                }
                  
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
                     componentName : "c__NewAccountViaCase"    
                  },   
            },
            focus: true
        }).then(function(response) {
            workspaceAPI.setTabLabel({
                tabId: response,
                label: "New Account"
            });
            
        }).catch(function(error) {
            console.log(error);
        });
    },
    
     fireEvent: function(component,event){
        var evt = component.getEvent("ShowRecordTypeOption");
        evt.setParams({
            "ShowRecType" : true,
        }).fire();
    },
})