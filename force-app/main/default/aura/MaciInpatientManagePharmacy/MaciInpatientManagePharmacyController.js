({
	doInit : function(component,event,helper){ 
        component.set('v.isLoading', true);
        helper.getCurrentPharmacistInfo(component,event);
        helper.fetchResources(component,event);
    },
    
    reSendInvitation : function(component, event, helper) {
        component.set('v.isLoading', true);
        var selectedItem = event.currentTarget;
        var recId = selectedItem.dataset.row;
        var action = component.get("c.sendInviteNotification"); 
        action.setParams({
            recordId : recId
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            let result = response.getReturnValue();
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                if(result != null){
                    helper.showToast(component,event,'Invitation sent successfully.','Success');
                }else{
                    helper.showToast(component,event,'Something went wrong, please contact system admin.','Error');
                }
            }else{
                helper.showToast(component,event,'Something went wrong, please contact system admin.','Error');
            }
        });
        $A.enqueueAction(action); 
         
	},
    
    showConfirmMessage : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var recId = selectedItem.dataset.row;
        component.set("v.deleterecordid", recId);
        component.set("v.isModalOpen", true); 
    },

     // RT 2376 changes
     showReactivateConfirmation : function(component, event, helper) {
        var itemSelected = event.currentTarget;
        var userId = itemSelected.getAttribute('data-id');
        var name = itemSelected.dataset.row;
        component.set("v.reActivateUserName", name);
        component.set("v.reActivateUserId", userId)
        component.set("v.isReactivateModalOpen", true); 
    },

    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        // RT 2376 changes
        component.set("v.isReactivateModalOpen", false); 
    },
        // RT 2376 changes
    activatePharmacyStaff : function(component, event, helper) {
        component.set("v.isReactivateModalOpen", false);
        component.set("v.isLoading", true);
        var recId = component.get("v.reActivateUserId");
        var action = component.get("c.activatePharmacyUser"); 
        action.setParams({
            recordId : recId
        });
        action.setCallback(this, function(response) {
            let result = response.getReturnValue();
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                if(result == ''){
                    helper.showToast(component,event,'Pharmacy Staff Reactivation Successful.','success');
                        $A.get('e.force:refreshView').fire();
                }else{
                    helper.showToast(component,event,'Something went wrong, please contact system admin.','Error');
                }
            }else{
                helper.showToast(component,event,'Something went wrong, please contact system admin.','Error');
            }
        });
        $A.enqueueAction(action); 
        
    },
    deletePharmacyStaff : function(component, event, helper) {
        component.set("v.isModalOpen", false);
        component.set("v.isLoading", true);
        var recId = component.get("v.deleterecordid");
        var pharmacyAccount = component.get("v.pharmacy");
        var programId = component.get("v.programId");
        var action = component.get("c.removePharmacyStaff"); 
        action.setParams({
            recordId : recId,
            pharmacyAcct : pharmacyAccount,
            programId : programId,
            pharmacyType : 'Inpatient'
        });
        action.setCallback(this, function(response) {
            let result = response.getReturnValue();
            var state = response.getState();
            component.set("v.isLoading", false);
            if (component.isValid() && state === "SUCCESS"){
                if(result == ''){
                    helper.showToast(component,event,'Removed successfully.','success');
                     $A.get('e.force:refreshView').fire();
                }else{
                    helper.showToast(component,event,'Something went wrong, please contact system admin.','Error');
                }
            }else{
                helper.showToast(component,event,'Something went wrong, please contact system admin.','Error');
            }
        });
        $A.enqueueAction(action); 
        
	},
    
    refreshtable: function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
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
    },

    
})