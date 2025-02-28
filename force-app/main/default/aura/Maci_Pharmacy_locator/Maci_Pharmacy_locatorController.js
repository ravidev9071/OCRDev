({
	doInit: function (component, event, helper) {
        component.set('v.isLoading', true);
        helper.getData(component);
    },
    
    onChangeSearchPhrase : function (component, event, helper) {
        component.set('v.isLoading', true);
        var searchString = $("#searchId").val();
              
        if ($A.util.isEmpty(searchString)) {
			
            let allData = component.get("v.allData");
            component.set("v.filteredData", allData);
            helper.preparePagination(component, allData);
      
        }else{
            helper.searchRecordsBySearchPhrase(component);
        }
    },
    onNext: function(component, event, helper) {        
        let pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber + 1);
        helper.setPageDataAsPerPagination(component);
    },
     
    onPrev: function(component, event, helper) {        
        let pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber - 1);
        helper.setPageDataAsPerPagination(component);
    }
})