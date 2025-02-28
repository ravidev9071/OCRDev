({
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
})