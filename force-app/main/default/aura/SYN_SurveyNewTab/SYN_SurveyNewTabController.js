({
    doInit : function(component, event, helper) {
        var appEvent = $A.get("e.c:SYN_InformTabIdEvent");
        appEvent.setParams({"msg" : "tabId"});
        appEvent.fire();
        var recId=component.get("v.recordId");
        var action = component.get("c.listsurvey");
        action.setParams({ 
            recordId : recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.surveyList", response.getReturnValue() );
               var obj = {};
                for(var i=0 ; i<response.getReturnValue().length;i++) {
                		obj[response.getReturnValue()[i].value] = response.getReturnValue()[i].label;
                }
                component.set("v.surveysMap",obj);
                var result=response.getReturnValue();
                helper.fetchExistingSurveys(component,event,helper);
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log( errors );
            }
        });
        
        $A.enqueueAction(action);
    },
    handleChange: function (component, event ,helper) {
        var changeValue = event.getParam("value");
        component.set("v.value", changeValue );      
    },
    openSubTab1: function (component, event ,helper) {
        
        helper.surveyStart1(component);
    },
    startSurvey: function (component, event ,helper) {
        
        var value1=component.get("v.value");
        var recId=component.get("v.recordId");
        var allExistingSurveysList = component.get("v.existingSurveyNames");
        var isExisting = allExistingSurveysList.includes(value1);
        if(isExisting) { // 'error', 'warning', 'success', or 'info'.
            var exist = component.get("v.surveysMap");
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type":"error",
                "message":$A.get("$Label.c.RemsServiceSurveyErrorMessage") 
            });
            toastEvent.fire(); 
        } else {
            var action = component.get("c.CreateSurveyInvWrpResult");
            action.setParams({ SurveyDeveloperName : value1,
                              currentRecordId : recId
                             });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    var result=response.getReturnValue();
                    component.set("v.surveyWrapper", result ); 
                    component.set("v.surveyurl", result.URL );    
                    helper.startSurveyNewTab(component);
                    
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log( errors );
                }
            });
            
            $A.enqueueAction(action);
        }
    },   
    handleTabEvent : function(component, event, helper) {
        
        var tabId = event.getParam("tabId");     
        component.set("v.tabId",tabId);
    },
    handleChange: function (component, event) {
        
    },
    cancel: function (component, event) {
        $A.get("e.force:closeQuickAction").fire();
    }
})