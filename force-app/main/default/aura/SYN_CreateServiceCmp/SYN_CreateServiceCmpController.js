({
	 doInit : function(component, event, helper) {

         var myPageRef = component.get("v.pageReference");
        
        var contact=myPageRef.state.c__caseId;
            var service=myPageRef.state.c__serviceId;
            component.set("v.CaseId",contact);
             component.set("v.ServiceId",service);
            helper.opennewTab(component);
        
       
    },
    
    
})