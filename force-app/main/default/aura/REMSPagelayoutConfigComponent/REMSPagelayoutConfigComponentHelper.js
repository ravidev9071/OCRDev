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
                
				var program =  component.get('v.programName');
                 const cmps = component.find("InputField");
                    for(var i=0;i<cmps.length;i++){
							if(cmps[i].get("v.fieldName") == 'US_WSREMS__Program_Picklist__c'){
								cmps[i].set("v.value", program);
							}
}
            } else if (state === "ERROR") {
                var errors = response.getError();
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getlookupfields : function(component, event, helper) {
        var targetObj = component.get("v.objectName");
        var program =  component.get('v.programName');
        var action = component.get("c.getLookupFields");
        action.setParams({ TargetObj : targetObj , programName : program });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnedValue = response.getReturnValue();
                component.set("v.lookupfields",returnedValue);
            } else if (state === "ERROR") {
                var errors = response.getError();
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getPrepopulationFields : function (component, event, helper , recId, fieldName){
        
        
        var targetObj = component.get("v.objectName");
        var targetRCtyId = component.get("v.recordtypeId");
        var program =  component.get('v.programName');
        
        var action = component.get("c.getPrepopFields");
        
        action.setParams({ recordId : recId , TargetObj : targetObj ,  RecordTypeId : targetRCtyId , programName : program , parentField : fieldName });
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
                    title = 'Success!';
                    type='success';
                    let AccountName = returnValue['accountRec']['Name'];
                    let calledByFaxTransfo = component.get("v.calledByFaxTransfo");
                    /*var pageReference = {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId : accountId,
                            actionName: "view"
                        }
                    };*/
                    
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
                    
                    var dynamicAttribute = {
                        "showAccountSearch": true,
                        "fieldsObjList":param,
                        "Source":"NewAccount",
                        
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
                     componentName : "c__ProgramSelectionComp"                      
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
            "ShowRecTypesOption" : true,
        }).fire();
    },
})