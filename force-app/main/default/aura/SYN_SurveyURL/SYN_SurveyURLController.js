({
    doInit : function(component, event, helper) {
        
        var myPageRef = component.get("v.pageReference");
        var res=myPageRef.state.c__resultUrl;
        component.set("v.resultUrl",res);
        
    }
})