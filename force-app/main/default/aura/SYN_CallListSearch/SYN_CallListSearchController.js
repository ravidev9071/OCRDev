({
	showCallList : function(cmp, event, helper) {
        var callListResultCmp = cmp.find("cCallListResult");
        callListResultCmp.showCallListResult(event.getParam("callListFilterWrapper"), event.getParam("selectedProject"), event.getParam("resetValues"));
    }
})