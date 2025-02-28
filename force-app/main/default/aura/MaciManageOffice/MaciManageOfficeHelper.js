({
	handleInit : function(component, event) {
       var action = component.get("c.getCurrentUserAccountInfo");
         action.setCallback(this, function(result) {
            var state = result.getState();
              component.set('v.isLoading', false);
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.cAccount', resultData);
                this.getPrescriberReEnrollmentInfo(component, event);
            }
        });
        $A.enqueueAction(action);

        var action = component.get("c.getPrescriberAssociatedOCList");
        action.setCallback(this, function(result) {
           var state = result.getState();
             component.set('v.isLoading', false);
           if (component.isValid() && state === "SUCCESS"){
               var resultData = result.getReturnValue();
               component.set('v.accList', resultData);
               this.getPrescriberReEnrollmentInfo(component, event);
           }
       });
       $A.enqueueAction(action);
      
    },
    
    getPrescriberReEnrollmentInfo : function(component, event) { 
        var action = component.get("c.getPresriberAccountInfo");
        action.setCallback(this, function(result) {
             component.set('v.ShowSpinner', false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.pCase', resultData);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchResources: function(component,event){
        var pname = component.get("v.ProgramName");
        var rtype = component.get("v.RequestorType");
        var recordtypeName = component.get("v.recordTypeDeveloperName");
        var programId = component.get("v.programId");
        var portalrole = component.get("v.portalRole");
        
        var action = component.get("c.getRelatedFilesByRecordId"); 
        action.setParams({
            recordTypeDevName : recordtypeName,
            programId : programId,
            portalRole : portalrole
        });
        action.setCallback(this, function(response) {
            
            let result = response.getReturnValue();
            
            
            
            var filesList =[];
            
            filesList = Object.keys(result).map(item => ({
                
                "label": result[item].Name,
                "value": item,
                "downloadurl": result[item].ContentDownloadUrl,
                "previewurl": result[item].DistributionPublicUrl,
                "contentdocumentId": result[item].ContentDocumentId
                
            }));
            
            
            component.set("v.resourceList",filesList);
            
        });
        $A.enqueueAction(action);    
    },
    
    savePrescriberInfo : function(component, event) {
        var pCase = component.get("v.pCase");
        
        
        var action = component.get("c.savePrescriberAccountInfo");
        var programId = component.get("v.programId");
        
        action.setParams({
            newCase : pCase,
            programId : programId, 
            programName : 'Macitentan REMS',
            channel : 'Portal'
         });
        action.setCallback(this, function(result) {
            component.set('v.isLoading', false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                if(resultData == ''){
                    this.showToast(component,event,'The selected contact information has been deleted successfully','success');
                    window.location.reload();
                }else{
                	this.showToast(component,event,'Something went wrong, please contact system admin.','Error');
                }
            }
        });
         
        $A.enqueueAction(action);
    },
    
    showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : titleType,
            message: errMsg,
            duration:' 5000',
            key: 'info_alt',
            type: titleType,
            mode: 'pester'
        });
        toastEvent.fire();
    },
})