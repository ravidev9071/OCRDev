({
	previousButton : function(component, event, helper) {
        
        var programList = component.get("v.REMSPrograms");
        var workspaceAPI = component.find("workspace");
        if(programList.length  > 1){
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
            
        }else{
            var navService = component.find("navSer");
            var pageReference = {
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Account',
                    actionName: 'home'
                }
            };
            workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
                navService.navigate(pageReference);
                workspaceAPI.closeTab({tabId : enclosingTabId});
            }).catch(function(error) {
                console.log('enclosing error : ',error);
            });
        }
	},
     showScreen: function(component,event){
         component.set("v.ShowRecTypesOption",true);
     },

     previousButtonFaxTransformation : function(component){
        var dynamicAttribute = {
            "showAccountSearch": true,
            "Source":"NewAccount",
        };
        
        component.find("REMSReviewDocumentChannel").publish(dynamicAttribute);
    }
   
})