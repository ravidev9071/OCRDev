({
    doInit: function (component, event, helper) {
       /* component.set("v.recordId", component.get('v.pageReference').state.c__recordId);
        component.set("v.selectedProgramId", component.get('v.pageReference').state.c__programId);
      */  component.set("v.showspinner", true);
        component.set("v.createREMS", true);
       // component.set("v.selectedProgramName", component.get('v.pageReference').state.c__programName);
        
        let programList = [];
        var progMap = {};
        var action = component.get("c.retrieveFilesOnDocumentDetail");
        action.setParams({
            "parentObjId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            console.log('+++inresponse');
            var state = response.getState();
            if (state === "SUCCESS") {
                var distObj = response.getReturnValue();
                component.set("v.fileurl", distObj.DistributionPublicUrl);
                component.set("v.DistObjId", distObj.Id);
            }
        });
        $A.enqueueAction(action);


                var accConfigaction = component.get("c.retrieveAccountConfigFields");

                accConfigaction.setCallback(this, function (response) {

                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var accFldRes = response.getReturnValue();
                        var pickMap = accFldRes['pickconfigMap'];
                        for (var acc in accFldRes['acSearchConfigList']) {
                            if(accFldRes['acSearchConfigList'][acc]['DeveloperName']!= 'Default'){
                                accFldRes['acSearchConfigList'][acc]['visible'] = true;
                            }else{
                                accFldRes['acSearchConfigList'][acc]['visible'] = false;
                            }
                            
                            accFldRes['acSearchConfigList'][acc]['fieldValue'] = null;
                            var fieldName = accFldRes['acSearchConfigList'][acc]['Field_Name__c'];
                           
                            if (fieldName == 'US_WSREMS__REMS_Program__c') {
                                accFldRes['acSearchConfigList'][acc]['fieldValue'] = component.get("v.selectedProgramId");
                            }
                            var options = [];
                            if (accFldRes['acSearchConfigList'][acc]['DataType__c'] == 'Combobox') {
                                for (var key in pickMap[fieldName]) {
                                    options.push({ "label": pickMap[fieldName][key]['label'], "value": pickMap[fieldName][key]['value'] })
                                }
                                accFldRes['acSearchConfigList'][acc]['Picklist_values__c'] = options;
                            }
                        }
                        component.set("v.accFieldList", accFldRes['acSearchConfigList']);
                        component.set("v.showspinner", false);
                    }
                });
                $A.enqueueAction(accConfigaction);

           

    },

    handleSearch: function (component, event, helper) {
        component.set("v.showspinner", true);
        component.set("v.searchHlpMsg", false);
        var accinputValuesmap = {};
        var columnMap = {};
        var accinputValues = component.get("v.accFieldList");
        for (var inpObj in accinputValues) {
            accinputValuesmap[accinputValues[inpObj].Field_Name__c] = accinputValues[inpObj].fieldValue;
        }
        var accStr = JSON.stringify(accinputValuesmap);

        var remsColumnAction = component.get("c.getREMSServiceViewConfig");
        remsColumnAction.setParams(
            { "feature": "REMSServiceTable" }
        );
        remsColumnAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var remsColRes = [];
                remsColRes.push({ type: 'button-icon', initialWidth: 105, typeAttributes: { name: 'Select_Service', variant: 'brand', class: { fieldName: 'btnCls' }, iconName: { fieldName: 'iconName' }, iconClass: { fieldName: 'iconClass' }, disabled: { fieldName: 'disabledValue' }, alternativeText: 'Select Service and Account' } });
                remsColRes = [...remsColRes, ...response.getReturnValue()];
                component.set("v.gridColumns", remsColRes);
                for (var column in remsColRes) {
                    var columnAttr = {};
                    columnAttr['Parent'] = remsColRes[column].Parent;
                    columnAttr['typeAtt'] = remsColRes[column].typeAttributes;
                    columnMap[remsColRes[column].fieldName] = columnAttr;
                }

                var remsSearchAction = component.get("c.retriveExistingRemsServices");
                remsSearchAction.setParams({
                    "accountValues": accStr
                });
                remsSearchAction.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var remsRes = response.getReturnValue();
                        if (!response.getReturnValue().length > 0) {
                            component.set("v.noSearchResult", true);
                            component.set("v.isgridata", false);
                        } else {
                            component.set("v.isgridata", true);
                        }

                        var accountList = [];
                        var expandableList = [];
                        for (var acc in remsRes) {
                            var account = remsRes[acc].accObj;
                            account['btnCls'] = 'remsBtnCls';
                            account['iconName'] = 'utility:add';
                            account['iconClass'] = 'buttonIcon';
                            account['selected'] = 'false';
                            for (var fldName in account) {
                                if (columnMap[fldName]) {
                                    if (columnMap[fldName]['typeAtt']) {
                                        var fieldName = columnMap[fldName]['typeAtt']["label"]["fieldName"];
                                        if (columnMap[fldName]['Parent']) {
                                            var parent = columnMap[fldName]['Parent'];
                                            if (account[parent]['Name']) {
                                                account[fieldName] = account[parent]['Name'];
                                            } else {
                                                account[fieldName] = account[parent];
                                            }
                                            account[fldName] = window.location.origin + '/' + account[fldName];
                                        }
                                    }
                                }
                            }
                            expandableList.push(account['Id']);
                            var remsServList = remsRes[acc].remsServiceObjList;
                            var remsChildList = [];
                            for (var remService in remsServList) {
                                if(remsServList[remService].remsServiceObj.US_WSREMS__Status__c !== 'Closed'){
                                remsServList[remService].remsServiceObj['iconName'] = 'utility:add';
                                remsServList[remService].remsServiceObj['iconClass'] = 'buttonIcon';
                                remsServList[remService].remsServiceObj['btnCls'] = 'remsBtnCls';
                                remsServList[remService].remsServiceObj['selected'] = 'false';
                                   
                                }else{
                                    
                                     remsServList[remService].remsServiceObj['btnCls'] = 'btnCls';
                                }
                                for (var fldName in remsServList[remService].remsServiceObj) {
                                    if (columnMap[fldName]) {
                                        if (columnMap[fldName]['typeAtt']) {
                                            var fieldName = columnMap[fldName]['typeAtt']["label"]["fieldName"];
                                            if (columnMap[fldName]['Parent']) {
                                                var parent = columnMap[fldName]['Parent'];
                                                if (remsServList[remService].remsServiceObj[parent]['Name']) {
                                                    remsServList[remService].remsServiceObj[fieldName] = remsServList[remService].remsServiceObj[parent]['Name'];
                                                } else {
                                                    remsServList[remService].remsServiceObj[fieldName] = remsServList[remService].remsServiceObj[parent];

                                                }
                                                remsServList[remService].remsServiceObj[fldName] = window.location.origin + '/' + remsServList[remService].remsServiceObj[fldName];
                                            }
                                        }

                                    }

                                }
                                expandableList.push(remsServList[remService].remsServiceObj['Id']);
                                for (var caseObj in remsServList[remService].caseList) {
                                    remsServList[remService].caseList[caseObj]['btnCls'] = 'btnCls';
                                    for (var fldname in remsServList[remService].caseList[caseObj]) {
                                        if (columnMap[fldname]) {
                                            if (columnMap[fldname]['typeAtt']) {
                                                var fieldName = columnMap[fldname]['typeAtt']["label"]["fieldName"];
                                                if (columnMap[fldname]['Parent']) {
                                                    var parent = columnMap[fldname]['Parent'];
                                                    if (remsServList[remService].caseList[caseObj][parent]) {
                                                        remsServList[remService].caseList[caseObj][fieldName] = remsServList[remService].caseList[caseObj][parent]['Name'];
                                                    } else {
                                                        if (fldname == 'Id') {
                                                            remsServList[remService].caseList[caseObj][fieldName] = remsServList[remService].caseList[caseObj]['CaseNumber'];
                                                        } else {
                                                            remsServList[remService].caseList[caseObj][fieldName] = remsServList[remService].caseList[caseObj][parent];
                                                        }

                                                    }
                                                    remsServList[remService].caseList[caseObj][fldname] = window.location.origin + '/' + remsServList[remService].caseList[caseObj][fldname];

                                                }
                                            }
                                        }


                                    }
                                    expandableList.push(remsServList[remService].caseList[caseObj]['Id']);
                                }
                                if (remsServList[remService].caseList.length > 0) {
                                    remsServList[remService].remsServiceObj._children = remsServList[remService].caseList;

                                }
                                delete remsServList[remService].caseList;
                                remsChildList.push(remsServList[remService].remsServiceObj);
                            }
                            if (remsChildList.length > 0) {
                                account._children = remsChildList;
                            }
                            accountList.push(account);
                        }
                        component.set("v.remsRecordList", remsRes);
                        component.set("v.expandableRows", expandableList);
                        component.set("v.gridData", accountList);
                        component.set("v.showspinner", false);

                    }
                });
                $A.enqueueAction(remsSearchAction);
            } else {
                if (!response.getReturnValue().length > 0) {
                    component.set("v.noSearchResult", true);
                }
            }
        });
        $A.enqueueAction(remsColumnAction);
    },
    iframeLoad: function (component, event, helper) {
        component.set("v.privewScreenspinner", false);
    },

    fetchProgramList: function (component, event, helper) {
        component.set("v.showspinner", true);
        component.set("v.showAccountSearch", false);
        let programList = component.get("v.programs");
        if (programList.length <= 0) {
            component.set("v.showNewForm", true);
            component.set("v.isPogramExist", false);
        }
        else {
            component.set("v.showNewForm", true);
            component.set("v.isPogramExist", true);
        }
        if (programList.length == 1) {
            component.set("v.showNewForm", false);
        }
        else {
            component.set("v.showNewForm", true);
        }
        component.set("v.showspinner", false);

    },
    createDynamicComponent: function (component, event, helper) {
        let recTypeId = component.get("v.selectedaccRecTypeId"),
            recTypeLabel = recTypeId? component.get("v.accountRecTypes").filter(ele => ele.value  == component.get("v.selectedaccRecTypeId"))[0].label : '';
        if (recTypeId) {
            component.set("v.showspinner", true);
            let programId = component.get("v.selectedProgramId");
            let programs = component.get("v.programs");

            let programName;
            for (let program of programs) {
                if (program.value == programId) {
                    programName = program.label;
                    break;
                }
            }

            var action = component.get("c.getComponentName");
            action.setParams({
                
                programName: component.get("v.selectedProgramName"),
                recordTypeLabel: recTypeLabel,
                feature: 'Account Creation'

            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    if (!response.getReturnValue()) {

                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Warning!",
                            "type": 'warning',
                            "message": $A.get("$Label.c.No_Component_Configured")
                        });
                        toastEvent.fire();
                        component.set("v.showspinner", false);
                        return;
                    }

                    component.set("v.componentName", response.getReturnValue());
                    let componentName = component.get("v.componentName");
                    let dynamicComponentName = componentName;
                    console.log('+++selectedacc'+JSON.stringify(component.get("v.selectedAccObj")));
                    $A.createComponent(
                        dynamicComponentName, {
                        "programId": programId, "recordTypeId": recTypeId, "parentRecordId": component.get("v.recordId"),
                        "accfields": component.get("v.selectedAccObj")
                    },
                        function (newComponent, status, errorMessage) { //Your new created component is stored in the newComponent variable  
                            component.set("v.dynamicComponentPlaceholder", newComponent);

                        }
                    );
                    component.set("v.showNewForm", false);
                    component.set("v.showspinner", false);
                    component.set("v.isrecordTypeSelect", false);
                    component.set("v.isprogramSelect", false);
                    component.set("v.shownewAccount", true);
                }
                else {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Warning!",
                        "message": 'Something went wrong please contact admin'
                    });
                    toastEvent.fire();
                    component.set("v.showspinner", false);
                    console.log("Failed with state: " + state);
                }
            });

            $A.enqueueAction(action);
        }else{
            var input = component.find('recTypeId');
            input.showHelpMessageIfInvalid();

        }

    },

    handleReset: function (component, event, helper) {
        var accinputValues = component.get("v.accFieldList");
        for (var inpObj in accinputValues) {
            if(accinputValues[inpObj].Field_Name__c!= 'US_WSREMS__REMS_Program__c'){
            accinputValues[inpObj].fieldValue = null;
            }
        }
        component.set("v.accFieldList", accinputValues);
        component.set("v.gridData", null);
        component.set("v.gridColumns", null);
        component.set("v.selectedREMS", null);
        component.set("v.selectedRows", null);
        component.set("v.expandableRows", null);
        component.set("v.accountRecTypes", null);
        component.set("v.selectedaccRecTypeId", null);
        component.set("v.newRemsId", null);
        component.set("v.isgridata", null);
        component.set("v.caseData", null);
        component.set("v.caseColumns", null);
        component.set("v.draftValues", null);
        component.set("v.childselectedServiceId", null);
        component.set("v.showServiceIcon",true);
       
    },

    handleRowSelection: function (component, event, helper) {
        var prevRow = component.get("v.selectedRows");
        var preRowAcc = component.get("v.selectedRows");
        var selectedRow = event.getParam('row');
        console.log('selcted row'+selectedRow);
        component.set("v.selectedRows", selectedRow);
        component.set("v.selectedREMS", selectedRow);
       if(selectedRow['US_WSREMS__Requestor_Type__c']){
            component.set("v.childreqType",selectedRow['US_WSREMS__Requestor_Type__c']);
        }
        const rows = component.get("v.gridData");
        const rowIndex = rows.indexOf(selectedRow);

        for (var acc in rows) {
            if (rows[acc]['Id'] == selectedRow.Id) {
            if (preRowAcc) {
                if (rows[acc]['Id'].includes(preRowAcc.Id)) {
                    rows[acc]['iconName'] =rows[acc]['iconName'] == 'utility:add' ? 'utility:check' : 'utility:add';
                    if (rows[acc]['iconName'] != 'utility:check') {
                        component.set("v.selectedREMS", null);
                        component.set("v.childselectedServiceId", null);
                      
                      component.set("v.showServiceIcon", true);
                      component.set("v.hiddenServiceIcon", false);
                    } 
                  else {
                        component.set("v.showServiceIcon", false);
                        component.set("v.hiddenServiceIcon", true);
                       }
                    
                } else {
                    rows[acc]['iconName'] = 'utility:check';	
                   component.set("v.showServiceIcon", false);
                   component.set("v.hiddenServiceIcon", true);
                }
                
            }else {
                rows[acc]['iconName'] = 'utility:check';
                component.set("v.showServiceIcon", false);
                component.set("v.hiddenServiceIcon", true);
             
            }
        }
            if (rows[acc]['Id'].includes(selectedRow.US_WSREMS__Participant__c)) {
                var remsServList = rows[acc]._children;
                for (var remService in remsServList) {
                    if (remsServList[remService]['Id'] == selectedRow.Id) {
                        if (prevRow) {
                            if (selectedRow['Id'].includes(prevRow['Id'])) {
                                remsServList[remService]['iconName'] = remsServList[remService]['iconName'] == 'utility:add' ? 'utility:check' : 'utility:add';
                                if (remsServList[remService]['iconName'] != 'utility:check') {
                                    component.set("v.selectedREMS", null);
                                    component.set("v.childselectedServiceId", null);
                                  
                                  component.set("v.showServiceIcon", true);
                                  component.set("v.hiddenServiceIcon", false);
                                }  else {
                                    component.set("v.showServiceIcon", false);
                                    component.set("v.hiddenServiceIcon", true);
                                   }
                            } else {
                                remsServList[remService]['iconName'] = 'utility:check';
                                component.set("v.showServiceIcon", false);
                                component.set("v.hiddenServiceIcon", true);				

                               
                            }
                        } else {
                            remsServList[remService]['iconName'] = 'utility:check';
                         
                         component.set("v.showServiceIcon", false);
                         component.set("v.hiddenServiceIcon", true);
                        }
                    }

                }
                rows[acc]['_children'] = remsServList;
            }

            if (prevRow) {
                if (prevRow['Id'] != selectedRow['Id']) {
                    if (rows[acc]['Id'].includes(prevRow.US_WSREMS__Participant__c)) {
                        var remsServList = rows[acc]._children;
                        for (var remService in remsServList) {
                            if (remsServList[remService]['Id'].includes(prevRow.Id)) {
                                remsServList[remService]['iconName'] = 'utility:add';
                            }
                        }
                        rows[acc]['_children'] = remsServList;

                    }
                    else if(!rows[acc]['Id'].includes(prevRow.US_WSREMS__Participant__c)){
                            for (var acc in rows) {
                                if (rows[acc]['Id'].includes(prevRow.Id)) {
                                    rows[acc]['iconName'] = 'utility:add';
                                }
                            }
                    }
                }
            }
        
        }
       
        component.set("v.gridData", rows);
        if (component.get("v.selectedREMS") != null) {
             
             
            helper.createREMS(component, event, helper);
        }
    },


    handleSuccess: function (component, message) {
        console.log('+++in event');
        component.set("v.showNewForm", false);
        var recId = component.get("v.recordId");
        console.log('+++in event'+recId);
        var remsId = component.get("v.newRemsId");
        console.log('+++in event'+remsId);
        let action = component.get("c.handleSearch");

        // Set all the values as received
        var Source = message.getParam("Source");
        var parentId = message.getParam("Parent");
        console.log('+++in event'+parentId);
        var docId = message.getParam("DocDetailId");
        var caseObj = message.getParam("caseDetails");
        var secList = message.getParam("activeSections");
        var caseCols = message.getParam("CaseColumns");
      
            if (Source == "NewAccount") {
                var fieldsList = message.getParam("fieldsObjList");
                
                console.log('+++in event436'+JSON.stringify(fieldsList));
                  if (fieldsList) {
                debugger;
                var accinputValues = component.get("v.accFieldList");
                for (var inpObj in accinputValues) {
                    if (accinputValues[inpObj]['Field_Name__c'] == 'Name') {
                        accinputValues[inpObj]['fieldValue'] = fieldsList[accinputValues[inpObj]['Field_Name__c']];
                        console.log('+++in event43333 '+fieldsList[accinputValues[inpObj]['Field_Name__c']]);
                    }
                }
                    component.set("v.accFieldList", accinputValues);
                    component.set("v.showAccountSearch", message.getParam("showAccountSearch"));
                    console.log('+++in if476');
                    component.set("v.showNewForm", false);
                    component.set("v.shownewAccount", false);
                    $A.enqueueAction(action);

                } else {
                    component.set("v.showNewForm", message.getParam("showNewForm"));
                    component.set("v.showAccountSearch", message.getParam("showAccountSearch"));
                    component.set("v.selectedProgramId", null);
                    component.set("v.shownewAccount", false);
                }
            } else if (Source == "PreviousFromAccount") {
                component.set("v.selectedAccObj", message.getParam("accObj"));
                component.set("v.isrecordTypeSelect", true);
                component.set("v.showAccountSearch", false);
                component.set("v.showNewForm", true);
                component.set("v.shownewAccount", false);
            }
       
        console.log('+++in event'+docId);
        if (docId == recId) {
            component.set("v.privewScreenspinner",false);
            var childCmp = component.find("createService");
           
        }
    },

    handleprogPrev: function (component, event, helper) {
        component.set("v.isrecordTypeSelect", false);
        component.set("v.showAccountSearch", true);
        component.set("v.showNewForm", false);
        component.set("v.isprogramSelect", false);
    },

    handleRTPrev: function (component, event, helper) {
        
        component.set("v.isrecordTypeSelect", false);
        component.set("v.showAccountSearch", true);
        component.set("v.showNewForm", false);
        component.set("v.isprogramSelect", false);
    },

    handleCancle: function (component, event, helper) {
        component.set("v.showNewForm", false);
        component.set("v.showAccountSearch", true);
    },

    handleNext: function (component, event, helper) {		
        helper.createREMS(component, event, helper);
    },

    handleComboChange: function (component, event, helper) {
        var fldName = event.getSource().get('v.name');
        if (fldName == 'US_WSREMS__REMS_Program__c') {
            component.set("v.selectedProgramId", event.getParam("value"));
        }
    },

    handleAccRecOptions: function (component, event, helper) {
        // Chai Changes
        // Step 1 button will call Apex class to get the Dynamic component name
        // step 2 create dynamic Account creation component
        // step 3 Pass parameters to the child component
        // step 4 child component will fire the Message respnse back to parent component
        
        let programId = component.get("v.selectedProgramId");
        let programs = component.get("v.programs");
        
        
        var action = component.get("c.getComponentName");
        action.setParams({
            programName: component.get("v.selectedProgramName"),
            recordTypeLabel: '',
            feature: 'Account Creation'
            
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                if (!response.getReturnValue()) {
                    
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Warning!",
                        "type": 'warning',
                        "message": $A.get("$Label.c.No_Component_Configured")
                    });
                    toastEvent.fire();
                    component.set("v.showspinner", false);
                    return;
                }
                
                component.set("v.componentName", response.getReturnValue());
                let dynamicComponentName = component.get("v.componentName");
                console.log('Chai Acc '+dynamicComponentName);
                debugger;
                console.log('+++selectedacc'+JSON.stringify(component.get("v.selectedAccObj")));
                
                try {
                    
                    if (dynamicComponentName == 'c:REMSNewAccountViaCase'){
                        $A.createComponent(
                            dynamicComponentName, {
                                "programId": programId,
                                "calledByFaxTransfo": true,
                                "programName" : component.get("v.selectedProgramName")
                            },
                            function (newComponent, status, errorMessage) { //Your new created component is stored in the newComponent variable  
                                debugger;
                                component.set("v.dynamicComponentPlaceholder", newComponent);
                                console.log('Status '+status);
                                console.log('errorMessage '+errorMessage);
                                component.set("v.dynamicComponentPlaceholder", newComponent);
                                component.set("v.showNewForm", false);
                                component.set("v.showspinner", false);
                                component.set("v.isrecordTypeSelect", false);
                                component.set("v.isprogramSelect", false);
                                component.set("v.shownewAccount", true);
                                component.set("v.showAccountSearch", false);
                                
                }
                        ); 
                    }else{
                        $A.createComponent(
                            dynamicComponentName, {
                                "parentRecordId":component.get("v.recordId"),
                                "programId": programId,
                                "calledByFaxTransfo": true
                            },
                            function (newComponent, status, errorMessage) { //Your new created component is stored in the newComponent variable  
                                debugger;
                                component.set("v.dynamicComponentPlaceholder", newComponent);
                                console.log('Status '+status);
                                console.log('errorMessage '+errorMessage);
                                component.set("v.dynamicComponentPlaceholder", newComponent);
                                component.set("v.showNewForm", false);
                                component.set("v.showspinner", false);
                                component.set("v.isrecordTypeSelect", false);
                component.set("v.isprogramSelect", false);
                component.set("v.shownewAccount", true);
                component.set("v.showAccountSearch", false);
                                
                            }
                        );
                    }
                    
                }
                catch(e) {
                    debugger;
                    console.log('err msg '+e.message);
                    
                    console.log('E Name '+e.name);
                    
                }
                
                
                
            }
            else {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "message": 'Something went wrong please contact admin'
                });
                toastEvent.fire();
                component.set("v.showspinner", false);
                console.log("Failed with state: " + state);
            }

        });
        
        $A.enqueueAction(action);
        
    },

    handleCreateCase: function (component, event, helper) {
        var remsId = event.getParam("remsServicId");
        var navPrev = event.getParam("isPrevious");
        if (navPrev == "true") {
            component.set("v.showAccountSearch", true);
            component.set("v.createREMS", false);
            component.set("v.childselectedServiceId", event.getParam("childselectedServiceId"));
            component.set("v.childselectedRecordTypeName", event.getParam("selectedRecordTypeName"));
            component.set("v.childlayoutList", event.getParam("childlayoutList"));
            component.set("v.selectedREMS", event.getParam("childselectedREMS"));
            component.set("v.selectedCaseObj", event.getParam("childCaseObj"));
            component.set("v.ActiveSections", event.getParam("caseActiveSections"));
            component.set("v.childrecordTypes", event.getParam("childrecordTypes"));
            component.set("v.childselectId", event.getParam("childselectedId"));
            component.set("v.childreqType", event.getParam("childreqType"));
            console.log('+++'+component.get("v.childselectId"));
            var rems = component.get("v.selectedREMS");
            rems['Id'] = window.location.origin + '/' + rems['Id'];
            var selIds = [];
            selIds.push(rems['Id']);
            component.set("v.selectedRowIds", selIds);


        }
    },

    handleCaseUpdate: function (component, event, helper) {

        var updatedRecords = event.getParam('draftValues');
        var action = component.get("c.updateCases");
        action.setParams({
            "caseList": updatedRecords
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.draftValues', []);
                helper.fetchcasecolumns(component, event, helper);
            }
        });
        $A.enqueueAction(action);

    },

    handlePrevious: function (component, event, helper) {
        component.set("v.showAccountSearch", true);
        component.set("v.createREMS", false);
    }


})