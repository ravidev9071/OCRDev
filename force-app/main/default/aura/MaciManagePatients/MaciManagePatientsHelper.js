({
	handleInit : function(component, event) {
       var action = component.get("c.getCurrentUserAccountInfo");
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.cAccount', resultData);
				if(resultData.SYN_Signature__c != 'Yes'){
					component.set("v.ShowAgreementScreen",true);
				}else{
					component.set("v.ShowCompleteScreen",true);
				}
                this.getCurrentPrescriberPatients(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    getCurrentPrescriberPatients : function(component, event) {
       
      var action = component.get("c.getPatients");
         var programId = component.get("v.programId");
         var prescriberAccount= component.get("v.cAccount");
         action.setParams({
             programId : programId,
             acc: prescriberAccount
         });
        action.setCallback(this, function(result) {
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.isLoading', false);
                var resultData = result.getReturnValue();
                            

                component.set('v.allData', resultData);
                component.set('v.filteredData', resultData);
                component.set('v.caseList', resultData);

                  this.preparePagination(component, resultData);
            }else if(state === "ERROR") {
                console.log("Error: " + errorMessage);
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
        let allDatas = component.get('v.allData');
        let x = (pageNumber - 1) * pageSize;
        for (; x < (pageNumber) * pageSize; x++){
            if (allDatas[x]) {
                data.push(allDatas[x]);
            }
        }
        component.set("v.caseListPagination", data);
                component.set('v.isLoading', false);

    },
    fetchResources: function(component,event){
        var pname = component.get("v.ProgramName");
        var rtype = component.get("v.RequestorType");
        var recordtypeName = component.get("v.recordTypeDeveloperName");
        var programId = component.get("v.programId");
        var portalrole = component.get("v.portalRole");
        
        var action = component.get("c.getRelatedFilesByRecordId"); 
        action.setParams({
            recordTypeDevName : recordtypeName,
            programId : programId,
            portalRole : portalrole
        });
        action.setCallback(this, function(response) {
            
            let result = response.getReturnValue();
            
           
            
           var filesList =[];
            
             filesList = Object.keys(result).map(item => ({
           
                    "label": result[item].Name,
                    "value": item,
                    "downloadurl": result[item].ContentDownloadUrl,
                    "previewurl": result[item].DistributionPublicUrl,
                 	"contentdocumentId": result[item].ContentDocumentId
                    
                }));
               
            
            component.set("v.resourceList",filesList);
           
        });
        $A.enqueueAction(action);    
    },
    
    showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : titleType,
                message: errMsg,
                duration:' 5000',
                key: 'info_alt',
                type: titleType,
                mode: 'pester'
            });
            toastEvent.fire();
	},
    handleSort: function(component,field) {
        var sortedBy = component.get("v.sortedBy");
        var sortedDirection = component.get("v.sortDirection");
        var cloneData = component.get('v.allData');
        let isAsc = true;
        if (sortedDirection == 'asc') {
            isAsc = true;
        } else {
            isAsc = false;
        }
        cloneData.sort((a, b) => {
            let aValue = a;
            let bValue = b;
            var fields = field.split('.');
            field.split('.').forEach(subField => {
                aValue = aValue[subField];
                bValue = bValue[subField];
            });
        aValue = aValue.toLowerCase();
            bValue = bValue.toLowerCase();
            if (isAsc) {
                return aValue > bValue ? 1 : -1;
            } else {
                return aValue < bValue ? 1 : -1;
            }
        });
        component.set('v.allData', cloneData);
        component.set('v.sortDirection', sortedDirection);
        component.set('v.sortedBy', sortedBy);
        this.setPageDataAsPerPagination(component);
    },
    
    fetchCaseDetails: function(component,caseId,popUp){
        var action = component.get("c.getCaseDetails");
        action.setParams({caseId:caseId});
        action.setCallback(this, function(result) {
            var state = result.getState();
            if(state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set("v.caseDetails",resultData); 
                component.set("v.rCase",resultData); 
                if(popUp) {
                    component.set("v.isModalOpenRPS", true); 
                }
                component.set("v.ShowSpinner", false);
                
            }else{
                console.error("Failed with State:"+state);
                component.set("v.ShowSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    showNextScreen : function(component,event,helper) {
      if(event.getParam("screenName") == 'ShowPatientAgreementInformationScreen'){
           
            component.set("v.ShowPatientAgreementInformation",true);
          component.set("v.isModalOpenRPS",false);
          
        
        }
    }
})