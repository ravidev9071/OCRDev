({
    closeModel : function(component,event,helper) {
        component.set("v.isEdit",false);
    },
    saveLogic : function(component,event,helper) {
        component.set('v.loaded',true);
        console.log('User ID '+component.get("v.userDetails.Contact.AccountId"));
        console.log('fields: ' + JSON.stringify(event.getParam('fields')));
        let fields = event.getParam('fields');
        fields = Object.assign( { 'sobjectType': 'Account' }, fields );
        fields.Id = component.get("v.userDetails.Contact.AccountId");
        if(component.get("v.communityName") ==='SOXPrescriberPortal'){
            fields.ShippingState = component.find('state').get('v.value');
        }
        //component.get("v.userDetails.Contact.Account.State__c");
        var action = component.get("c.updatePersonAccount");
        action.setParams({
            "accnt": fields,
            "CommunityName":component.get("v.communityName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var isEmailChanged = component.get("v.isEmailChangedValue");
            var otherFieldsChanged = component.get("v.isChangedValue");
            var toastMsg = '';
            if(isEmailChanged && otherFieldsChanged ) {
                toastMsg = 'Your email address has changed. Please verify this request by clicking on the verification link emailed to you.';
            } else if(isEmailChanged && !otherFieldsChanged) {
                toastMsg = 'Your email address has changed. Please verify this request by clicking on the verification link emailed to you.';
            }
                else if(!isEmailChanged && otherFieldsChanged) {
                    toastMsg= 'Account Updated succesfully';
                }
            if(component.isValid() && state == "SUCCESS" ) {
                if(response == null || response == ''){
                    component.find('notifLib').showToast({
                        "title": "Error!",
                        "message": response,
                        "variant" :"error"
                    });
                }else{
                    helper.closeModel(component,event,helper);
                    if((isEmailChanged && !otherFieldsChanged ) || (isEmailChanged && otherFieldsChanged )) {
                        helper.showPopup(component,event,helper,toastMsg);
                        helper.showToast(component,event,helper,'Account Updated succesfully');
                    }
                    if((!isEmailChanged && otherFieldsChanged)) {
                         helper.showToast(component,event,helper,'Account Updated succesfully');
                    }
                    component.set("v.isChangedValue",false);
                    component.set("v.isEmailChangedValue",false);
                    // component.set("v.showSpinner", false);
                }
                
            }
            else if (state === "ERROR") {
                console.log('Problem saving site, response state: ' + state);
                var errors = response.getError();
                console.log('error');
                console.log(errors[0].message);
                component.find('notifLib').showToast({
                    "title": "ERROR ",
                    "message": errors[0].message,
                    "variant" :"error",
                    "mode":"dismissible"
                });
                // component.set("v.isChangedValue",false);
                component.set("v.showSpinner", false);
                //  component.set("v.isEmailChangedValue",false);
            }
            
        });
        $A.enqueueAction(action);
    },
    handleValidation : function(component) {
        debugger;
        var allValid =  component.find('validfield').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
    },
    showToast : function(component,event,helper,msg) {
        component.find('notifLib').showToast({
            "title": "Success",
            "message":msg,
            "variant" :"success",
            "mode":"dismissible"
            
        });
    },
    showPopup :function(component,event,helper,msg) {
        component.find('notifLib').showNotice({
            "variant": "info",
            "header": "Success",
            "message":msg, 
            closeCallback: function() 
            {
                $A.get('e.force:refreshView').fire();
            }
        });
    }
})