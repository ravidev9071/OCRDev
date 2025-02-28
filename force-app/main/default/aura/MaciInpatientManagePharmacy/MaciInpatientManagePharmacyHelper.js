({  
    
    getCurrentPharmacistInfo : function(component,event){
        var pname = component.get("v.ProgramName");
        
        var action = component.get("c.getPharmacistInfo"); 
        action.setCallback(this, function(response) {
           let result = response.getReturnValue();
           
           component.set('v.pharmacist', result);
            
           this.getCurrentPharmacyInfo(component,event);
        });
        $A.enqueueAction(action);    
    },
    
    getCurrentPharmacyInfo : function(component,event){
        var pname = component.get("v.ProgramName");
        var action = component.get("c.getPharmacyInfo"); 
        var userAccount = component.get("v.pharmacist");
        action.setParams({
            acc : userAccount,
            ProgramName : pname
        });
        action.setCallback(this, function(response) {
           let result = response.getReturnValue();
           
           component.set('v.pharmacy', result);
           var pharmacyPhone = component.get("v.pharmacy.Phone");
           if(pharmacyPhone != undefined){
           var pharmacyPhoneFormat =  pharmacyPhone.substr(0, 3) + '-' + pharmacyPhone.substr(3, 3) + '-' + pharmacyPhone.substr(6,4);
           component.set('v.pharmacyPhone', pharmacyPhoneFormat);
           }
           this.getAuthorizedRepsInfo(component,event);
        });
        $A.enqueueAction(action);    
    },
    
    getAuthorizedRepsInfo : function(component,event){
        var programId = component.get("v.programId");
        var action = component.get("c.getAuthorizedReps"); 
        var pharmacyAccount = component.get("v.pharmacy");
        var arAccount = component.get("v.pharmacist");
        var arAccountId = component.get("v.pharmacist.Id");
                   

        action.setParams({
            pharmacyact : pharmacyAccount,
            programId : programId,
            authrepAccount :arAccount
        });
        action.setCallback(this, function(result) {
           var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.isLoading', false);
                var resultData = result.getReturnValue();
                var listLength = resultData.length;
                var ArCounts=0;
               
                for (var i=0; i < listLength; i++) {
                    if(resultData[i].US_WSREMS__UserType__c  == 'Authorized Representative' && resultData[i].Status__c != 'Inactive'){
                       ArCounts =  ArCounts+1;
                    }
                    

                    if(resultData[i].US_WSREMS__Pharmacy_User__c == arAccountId && resultData[i].US_WSREMS__UserType__c != 'Authorized Representative' && resultData[i].Default__c == true){
                        component.set('v.showActions', false); 
                    }

                }
                
                if(ArCounts > 1){
                   component.set('v.showInviteAuthorizedRepButton', false);
                }
                
                if(listLength > 10){
                    component.set('v.showNextbuttonbar', true);
                }
                component.set('v.allData', resultData);
                component.set('v.filteredData', resultData);
                component.set('v.affiliationList', resultData);
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
        component.set("v.affiliationList", data);
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
})