({
    doInit : function(component, event, helper) {
        // Log the pageReference for debugging.
        var pageRef = component.get("v.pageReference");
        console.log('PageReference received:', pageRef);
        
        // Try to retrieve recordId from pageReference (if coming from URL) 
        if(pageRef && pageRef.state && pageRef.state.c__recordId) {
            component.set("v.recordId", pageRef.state.c__recordId);
        }
        
        // Log the recordId value.
        var recId = component.get("v.recordId");
        console.log('Record Id:', recId);
        
        if(!recId) {
            console.error("Record Id is not available. Check URL parameter naming.");
            return;
        }
        
        // Call helper method to update records and redirect.
        helper.updateRecordAndRedirect(component, recId);
    }
})