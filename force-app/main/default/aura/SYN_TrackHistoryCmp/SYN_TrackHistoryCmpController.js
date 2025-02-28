({
	doInit : function(component, event, helper) {
		var ConList = component.get("c.fetchHistoryData");
        ConList.setParams
        ({
            recordId: component.get("v.recordId")
        });
        
        ConList.setCallback(this, function(data) 
                           {
                               component.set("v.historyList", data.getReturnValue());
                           });
        $A.enqueueAction(ConList);
        
        
 },})