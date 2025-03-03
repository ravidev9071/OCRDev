({
    doInit: function (component, event, helper) {
        

        var totalPages = Math.ceil(component.get("v.totalRecords") / component.get("v.recordsPerPage"));
        component.set("v.totalPages", totalPages);
        

        component.set("v.startPage", 1);
        component.set("v.startIndex", 1);

        component.set("v.currentPage", 1);
        var currentPage = component.get("v.currentPage");
        


        var pageNumbersToDisplay = [];
        var startPage = (currentPage - 3) < 1 ? 1 : (currentPage - 3);
       

        var endPage = (currentPage + 3) > totalPages ? totalPages : (currentPage + 3);
       

        for (var i = startPage; i <= endPage; ++i) {
            pageNumbersToDisplay.push(i);
        }
        component.set("v.pageNumbersToDisplay", pageNumbersToDisplay);
        
        var endIndex = component.get('v.totalRecords')<component.get("v.recordsPerPage") ? component.get('v.totalRecords') : component.get("v.recordsPerPage");
        component.set("v.endIndex", endIndex);
        component.set("v.endPage", totalPages);
    },

    paginate: function (component, event, helper) {
        var pageNo = parseInt(event.getSource().get("v.value"));
        
        component.set("v.currentPage", pageNo);
        component.set("v.startIndex", (((pageNo - 1) * component.get("v.recordsPerPage")) + 1));
        var endIndex = pageNo * component.get("v.recordsPerPage");
        component.set("v.endIndex", (endIndex > component.get("v.totalRecords")) ? component.get("v.totalRecords") : endIndex);

        var currentPage = component.get("v.currentPage");
        var totalPages = component.get("v.totalPages");

        var pageNumbersToDisplay = [];
        var startPage = (currentPage - 3) < 1 ? 1 : (currentPage - 3);

        var endPage = (currentPage + 3) > totalPages ? totalPages : (currentPage + 3);
        for (var i = startPage; i <= endPage; ++i) {
            pageNumbersToDisplay.push(i);
        }
        component.set("v.pageNumbersToDisplay", pageNumbersToDisplay);
        var compEvent = component.getEvent("ChangePage");
        compEvent.setParams({ "currentPageValue": pageNo });
        compEvent.fire();
    }
})