({
	 getData: function (component) {
        var action = component.get("c.getPrescriberList");
         var programId = component.get("v.programId");
         action.setParams({
             programId : programId
         });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.isLoading', false);
                var resultData = result.getReturnValue();
                component.set('v.allData', resultData);
                component.set('v.filteredData', resultData);
                component.set('v.accList', resultData);
                this.preparePagination(component, resultData);
            }
        });
        $A.enqueueAction(action);
    },
    
    preparePagination: function (component, pharmacyRecords) {
        let countTotalPage = Math.ceil(pharmacyRecords.length/component.get("v.pageSize"));
        let totalPage = countTotalPage > 0 ? countTotalPage : 1;
        component.set("v.totalPages", totalPage);
        component.set("v.currentPageNumber", 1);
        this.setPageDataAsPerPagination(component);
    },
 
    setPageDataAsPerPagination: function(component) {
        let data = [];
        let pageNumber = component.get("v.currentPageNumber");
        let pageSize = component.get("v.pageSize");
        let filteredData = component.get('v.filteredData');
        let x = (pageNumber - 1) * pageSize;
        for (; x < (pageNumber) * pageSize; x++){
            if (filteredData[x]) {
                data.push(filteredData[x]);
            }
        }
        component.set("v.accList", data);
        component.set('v.isLoading', false);

    },
    
    searchRecordsBySearchPhrase : function (component) {
        let searchPhrase =  $("#searchId").val();
        if (!$A.util.isEmpty(searchPhrase)) {
            var acc  = component.get('v.allData');
            let filteredData =  acc.filter(record => String(record.Name).toLowerCase().includes(searchPhrase.toLowerCase()) || String(record.US_WSREMS__NPI__c).toLowerCase().includes(searchPhrase.toLowerCase()));            
            component.set("v.filteredData", filteredData);
            this.preparePagination(component, filteredData);
        }
    },
    
     setBackgroundImage: function(component, event, helper) {
       // Use a timeout to ensure the DOM element is available
       setTimeout(function() {
           try {
               // Use relative path construction to avoid namespace prefix
               var imgUrl = '/resource/MaciImages/img/pharmacy.jpg';
               // get the element and set the background image
               var element = component.find("backgroundDiv");
               if (element) {
                   element = element.getElement();
                   element.style.backgroundImage = 'url(' + imgUrl + ')';
                   
               } else {
                   console.error("Element not found");
               }
           } catch (error) {
               console.error("Error in setBackgroundImage: ", error);
           }
       }, 100); // Adjust the timeout duration as needed
   },
    
    
    
})