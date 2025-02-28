({
	doInit : function(component, event, helper) {
        helper.setColumns(component, event, helper);
        helper.setRows(component, event, helper);
	},
    handlePagination: function(cmp, event, helper) {
        var currentPageValue = event.getParam("currentPageValue");
        helper.buildData(cmp, currentPageValue);
    },
    handleSort: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = component.get("v.sortedDirection");
        console.log('sortDirection before::',sortDirection);
        var isSortASC = sortDirection == 'asc' ? true : false;
        sortDirection = sortDirection == 'asc' ? 'desc' : 'asc';
        component.set("v.sortedBy",fieldName);
        component.set("v.sortedDirection",sortDirection);
        var recordList = component.get("v.results");
        recordList = helper.sortColumnData(component, recordList, isSortASC, fieldName);
        component.set("v.results", recordList);
        helper.buildData(component, 1);
        var rowres = component.get("v.results");
        var result = rowres.length;
        if(result>0){
            var paginationCmp = component.find("cPagination");
            paginationCmp.RefreshPagination();
        }
    }
})