({
    doInit : function(component, event, helper) {
       helper.getAccess(component, event, helper);
    },
    onSearchTermChange: function( component, event, helper ) {
        component.set('v.accountList', []);
        var FirstName = component.get("v.FName")
        var LastName = component.get("v.LName");
        var DEA = component.get("v.DEASearch");
        var Phone = component.get("v.PhoneSearch");
        if((FirstName == '' || FirstName == null)&&(LastName == '' || LastName == null) && (DEA == ''||DEA ==null ) && (Phone == ''||Phone ==null)){
             helper.init(component, event,helper);
        } else{
            helper.handleSearch(component);
        }
    },
    handlePagination: function(cmp, event, helper) {
        var currentPageValue = event.getParam("currentPageValue");
        helper.buildData(cmp, currentPageValue);
    },
    navigateToDetail: function(component, event, helper) {
    var selectedItem = event.target.dataset.item;
    var navEvent = $A.get("e.force:navigateToSObject");  
        navEvent.setParams({
            "recordId": selectedItem,   
            "slideDevName": "detail"
        });
        navEvent.fire(); 
    }
    
    
})