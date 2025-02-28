({
	doInit : function(component, event, helper) {
		  helper.getAccess(component, event, helper);
    },
    onSearchTermChange: function( component, event, helper ) {
        component.set('v.CaseList', []);
        var AuthorizationNum = component.get("v.AuthNUM")
        var PatientName = component.get("v.PatientName");
        var PatientDOB = component.get("v.PatientDOB");
        var PrescriberName = component.get("v.PrescriberName");
        var PrescriberDEA = component.get("v.DEA");
        if((AuthorizationNum == '' || AuthorizationNum == null)&&(PatientName == '' || PatientName == null) && (PatientDOB == ''||PatientDOB ==null ) && (PrescriberName == ''||PrescriberName ==null)&& (PrescriberDEA == ''||PrescriberDEA ==null)){
             helper.init(component, event,helper);
        } else{
            helper.handleSearch(component);
        }
    },
    handlePagination: function(cmp, event, helper) {
        var currentPageValue = event.getParam("currentPageValue");
        helper.buildData(cmp, currentPageValue);
	},
})