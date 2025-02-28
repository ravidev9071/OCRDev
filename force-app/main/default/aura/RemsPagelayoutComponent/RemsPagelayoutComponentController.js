({
    getLayoutName : function(component, event, helper) {
        var params = event.getParam('arguments');
        
        if (params) {
            var PGName = params.pageLayoutName;
            
            component.set("v.objectName",params.objectName);
         
            component.set("v.recordtypeId",params.recordtypeId);
            component.set("v.calledByFaxTransfo",params.calledByFaxTransfo);
            helper.getLayoutSections(component,PGName);
        }
    },
    
    handleLoad : function(component, event, helper) {
        
        component.set("v.showSpinner", false);   
    },
    
    handleSubmit : function(component, event, helper) {
        event.preventDefault(); 
        var clickBtnName = component.get("v.ButtonName");
        var recordTypeId = component.get("v.recordtypeId");
        
        var eventFields = event.getParam("fields");
        var allValid = true;
        const cmps = component.find("dateid");
        if(cmps){
            if(cmps.length){
                for(var i=0;i<cmps.length;i++){
                    eventFields[cmps[i].get("v.name")] = cmps[i].get("v.value");
                }
            }else {
                eventFields[cmps.get("v.name")] = cmps.get("v.value");
            }
            
            allValid =  [].concat(component.find('dateid')).reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if(!allValid && clickBtnName != 'DupCheck'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Incorrect DOB value',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        }
        eventFields.RecordTypeId = recordTypeId;
        let FieldValuesStr = JSON.stringify(eventFields);
        if(clickBtnName == 'DupCheck'){
            component.set("v.ShowSaveBtn", true);
            var action = component.get("c.checkAccountDuplicates"); 
            action.setParams({ recordTypeId : recordTypeId , fields :  FieldValuesStr }); 
            action.setCallback(this, function(response) {
                debugger;
                var state = response.getState();
                if (state === "SUCCESS") {
                    debugger;
                    var dupAcc = response.getReturnValue();
                    
                    if (dupAcc['dupFound'] == false ){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "No Duplicates",
                            "message": "No duplicate records are found",
                            "type": "error"
                        });
                        toastEvent.fire();
                        
                    }else{
                        component.set("v.displayDupCheck",true);
                        component.set('v.columns', [
                            
                            { label: 'Account Name', fieldName: 'Name', type: 'name' },
                            { label: 'First Name', fieldName: 'FirstName', type: 'text' },
                            { label: 'Last Name', fieldName: 'LastName', type: 'text' },
                            { label: 'Phone', fieldName: 'Phone', type: 'phone' },
                            { label: 'DOB', fieldName: 'US_WSREMS__DOB__c', type: 'date' },
                            { label: 'DEA', fieldName: 'US_WSREMS__DEA__c', type: 'text' },
                            { label: 'NPI', fieldName: 'US_WSREMS__NPI__c', type: 'text' },
                            { label: 'NCPDP', fieldName: 'US_WSREMS__NCPDP__c', type: 'text' },
                            { label: 'Zip', fieldName: 'ShippingPostalCode', type: 'text' },
                            { label: 'Email', fieldName: 'US_WSREMS__Email__c', type: 'text' },
                            { label: 'View', type: 'button-icon', initialWidth: 135, 
                             typeAttributes: { label: 'View Details', name: this.viewDetails, title: 'Click to View Details', 
                                              iconName: 'utility:preview', } }
                        ]);
                        var AccDataLst = dupAcc['Accountlst'];
                     
                        for (const element of AccDataLst) {
                             
                            if(element.US_WSREMS__REMS_Program__r){
                                element['RemsProgramName'] = element.US_WSREMS__REMS_Program__r.Name; 
                            }
                            
                        }
                      component.set("v.accountData", AccDataLst);
                    } 
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    
                }
            });
            $A.enqueueAction(action);
        }
        
        if(clickBtnName != 'DupCheck' && allValid){
            debugger;
            
            var action = component.get("c.DEAvalidation"); 
            action.setParams({ recordTypeId : recordTypeId , fields :  FieldValuesStr }); 
            action.setCallback(this, function(response) {
                debugger;
                var state = response.getState();
                if (state === "SUCCESS") {
                    debugger;
                    var deaValid = response.getReturnValue();
                    //component.set("v.DEAvalidation" ,deaValid );
                    component.set("v.validationResult", response.getReturnValue());
                    var todayDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    
                    var deaValidation= deaValid;
                    if (component.get("v.validationResult").DEAValidation){
                        eventFields.SYN_DEA_Validation__c = 'Valid';
                        eventFields.SYN_Validation_Date__c = todayDate; 
                    }else{
                        eventFields.SYN_DEA_Validation__c = 'Invalid';
                        eventFields.SYN_Validation_Date__c = todayDate;
                    }
                     if (component.get("v.validationResult").NPIValidation){
                        eventFields.NPI_Status__c = 'Valid';
                        
                    }else{
                        eventFields.NPI_Status__c = 'Invalid';
                      
                    }
                    
                    component.find('myform').submit(eventFields);
                    component.set("v.showSpinner",true);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    
                }
            });
            $A.enqueueAction(action);
            
        }
    },

    handleSuccess : function(component, event, helper) {
        helper.navigateToRecord(component, event, helper);
        
    },

    handleError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        $A.util.removeClass(component.find("lightning_message"), "slds-hide"); 
        toastEvent.setParams({
            "title": "Error!",
            "message": event.getParam("detail"),
            "type": "error"
        });
        
        component.set("v.showSpinner",false);
        //toastEvent.fire();
    },

    handleFieldChange : function(component, event, helper){
        component.set("v.DupButton", true);
        component.set("v.ShowSaveBtn", false);
        let fieldName = event.getSource().get("v.fieldName") ; 
        let newValue =  event.getSource().get("v.value") ;
       
        if (newValue){
            helper.getPrepopulationFields(component, event, helper , newValue);
        }
    },
    previous: function(component, event, helper){
        //Navigate to Program Selection Screen
        helper.fireEvent(component,event);
        //helper.previousScreen(component, event, helper);
    },
    
    CheckForDuplicates: function(component, event, helper){
      
        var buttonName = event.getSource().get("v.name");
        component.set("v.ButtonName",buttonName);
        $A.util.addClass(component.find("lightning_message"), "slds-hide");
    },
    handleRowAction: function(component, event, helper){
        var row = event.getParam('row');
        window.open('/' + row.Id,'_blank');
        
    },
    closeModel: function(component, event, helper) {
      component.set("v.displayDupCheck", false);
   },
})