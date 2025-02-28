({
    helperMethod: function () {
        
    },
    
    handleLayoutFieldAssignemnt: function (component, layoutConfigList, remsRecObj, programId, prevRemsObj,progSelect) {
        if (layoutConfigList.length > 0) {
            for (var sec in layoutConfigList) {
                for (var fld in layoutConfigList[sec]['lstFields']) {
                    if (layoutConfigList[sec]['lstFields'][fld]['fieldName']) {
                        if (layoutConfigList[sec]['lstFields'][fld]['fieldName'] == 'US_WSREMS__REMSProgram__c')
                            layoutConfigList[sec]['lstFields'][fld]['fieldValue'] = programId;
                            if (layoutConfigList[sec]['lstFields'][fld]['fieldName'] == 'US_WSREMS__Requestor_Type__c')
                            layoutConfigList[sec]['lstFields'][fld]['fieldValue'] = component.get("v.requestType");
                        var fieldName = layoutConfigList[sec]['lstFields'][fld]['fieldName'];
                        if(!progSelect){
                        if (remsRecObj) {
                            layoutConfigList[sec]['lstFields'][fld]['fieldValue'] = remsRecObj[fieldName];
                        }
                        if(prevRemsObj && prevRemsObj[fieldName]){
                            layoutConfigList[sec]['lstFields'][fld]['fieldValue'] = prevRemsObj[fieldName];
                        }
                    }
                    }
                }
            }
            
            component.set("v.layoutList", layoutConfigList);
            component.set("v.activeSections", layoutConfigList[0].label);
            component.set("v.showspinner", false);
        }
    },

    fetchcasecolumns: function (component) {
        var caseColumnAction = component.get("c.getREMSServiceViewConfig");
        var remsId = component.get("v.selectedREMSServiceId");
        caseColumnAction.setParams(
            { "feature": "CaseViewTable" }
        );
        caseColumnAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var caseColumns = [];
                var caseColRes = response.getReturnValue();
                //   var caseColRes=[{"fieldName":"Id","initialWidth":222,"label":"Case Number","type":"url","typeAttributes":{"label":{"fieldName":"CaseNumber"}}},{"fieldName":"Status","label":"Status","type":"Text","editable":"true"}];
                for (var column in caseColRes) {
                    if (caseColRes[column]['type'] != 'button') {
                        caseColumns.push(caseColRes[column]['fieldName']);
                        if( caseColRes[column]['type'] == 'url' && caseColRes[column]['ParentQueryField']){
                            caseColumns.push(caseColRes[column]['ParentQueryField']);
                        }
                    } else {
                        caseColRes[column]['typeAttributes'] = caseColRes[column]['typeAttributes']['typeAttributes'];
                        caseColRes[column]['typeAttributes']['disabled'] = { fieldName: 'isEditButtonDisabled'};
                    }
                    console.log('+++columnMap' + JSON.stringify(caseColumns));
                    var columnAttr = {};
                }
                component.set("v.caseColumns", caseColRes);

                if (caseColumns) {
                    var caseQueryColumns = component.get("v.caseQueryColumns");
                    for(var colObj in caseColumns){
                        caseQueryColumns.push(caseColumns[colObj]);
                    }
                    
                    var caseDataAction = component.get("c.retrieveRemsChildCases");
                    caseDataAction.setParams(
                        {
                            "remsSerId": remsId,
                            "fldsList": caseQueryColumns
                        }
                    );
                    caseDataAction.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var columnMap={};
                            var caseColumnRecs = component.get("v.caseColumns");
                            var caseDataRes = response.getReturnValue();
                            if (caseDataRes.length > 0) {
                                for (var column in caseColumnRecs) {
                                    var columnAttr = {};
                                    columnAttr['Parent'] = caseColumnRecs[column].Parent;
                                    columnAttr['typeAtt'] = caseColumnRecs[column].typeAttributes;
                                    columnMap[caseColumnRecs[column].fieldName] = columnAttr;
                                    console.log('+++++columnMap'+JSON.stringify(columnMap));
                                }
                                for(var caseObj in caseDataRes){
                                    caseDataRes[caseObj]['Id'] = window.location.origin + '/'+caseDataRes[caseObj]['Id'];
                                    var caseRec= caseDataRes[caseObj];
                                    
                                      if(caseRec['Status']==='Complete' || caseRec['Status']==='Cancelled'){
                                        caseDataRes[caseObj]['isEditButtonDisabled']=true;
                                    }
                                    for (var fldName in caseRec) {
                                       
                                        if (columnMap[fldName]) {
                                            
                                            if (columnMap[fldName]['typeAtt']) {
                                                
                                                var fieldName = columnMap[fldName]['typeAtt']["label"]["fieldName"];
                                                
                                                if (columnMap[fldName]['Parent']) {
                                                    
                                                    var parent = columnMap[fldName]['Parent'];
                                                    
                                                    if (caseRec[parent]['Name']) {
                                                        caseRec[fieldName] = caseRec[parent]['Name'];
                                                    } else {
                                                        
                                                        caseRec[fieldName] = caseRec[parent];
                                                    }
                                                    caseRec[fldName] = window.location.origin + '/' + caseRec[fldName];
                                                }
                                            }
                                        }
                                    }
                                    //  caseDataRes[caseObj] = caseRec;
                                    console.log('+++caseDataRes[caseObj]'+JSON.stringify(caseDataRes[caseObj]));
                                }
                                component.set("v.caseData", caseDataRes);
                                component.set("v.isCaseData", true);
                                component.set("v.showPrevInCaseTab", true);
                            } else {
                                component.set("v.showCase", true);
                                component.set("v.isCaseData", false);
                                component.set("v.showPrevInCaseTab", false);
                            }
                        } 
                    });
                    $A.enqueueAction(caseDataAction);

                }
            }
        });
        $A.enqueueAction(caseColumnAction);
    },

   /* handleProgramsSelect: function (component, event, helper) {
        component.set("v.showspinner", true);
        var remsRecObj = component.get("v.remsObj");
        var selservId = component.get("v.selectedServiceId");
        if (selservId) {
            var ServiceMap = component.get("v.ServMap");
            
            var servName = ServiceMap[selservId];
            component.set("v.selectedRecordTypeName", servName);
        } else {
            var selservId = document.querySelector('input[name="options"]:checked').id;
            component.set("v.selectedServiceId", selservId);
        }
        var  recortTypeList = component.get("v.recordTypes");
        for(var item of recortTypeList){
            if(item.value == selservId){
                item.checked = true;
            }
        }
        component.set("v.recordTypes",recortTypeList);
        component.set("v.showRecodEditform", false);
        component.set("v.showProg", false);
        var emptyList = [];
        component.set("v.layoutList", emptyList);
        component.set("v.activeSections", emptyList);
        var action = component.get("c.getProgramServicelayoutConfig");
        var selSerId = component.get("v.selectedServiceId");
        var programId = component.get('v.programId');
        var ServiceMap = component.get("v.ServMap");
        var servName = ServiceMap[selSerId];
        component.set("v.selectedRecordTypeName", servName);
        action.setParams({
            "serviceId": selSerId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                let layoutConfigList = response.getReturnValue();
                var remsRecObj = component.get("v.remsObj");
                if (layoutConfigList.length > 0) {
                    component.set("v.showRecodEditform", true);
                    component.set("v.showProg", false);
                 
                    if(!remsRecObj){
                    component.set("v.requestType",null);
                    component.set("v.selectedId",null);
                    }
                    helper.handleLayoutFieldAssignemnt(component, layoutConfigList, remsRecObj, programId, null, true);
                   
                    //helper.handleLayoutFieldAssignemnt(component, layoutConfigList, remsRecObj, programId, null, true);
                    if (component.get("v.selectedServiceId" && remsRecObj== null) ) {
                        component.set("v.showNext", true);
                    }
                }else{
                    component.set("v.showRecodEditform", false);
                    if(!remsRecObj){
                     component.set("v.showProg", true);
                        component.set("v.showNext", false);
                    }else{
                        helper.handleParentPrevious(component, event, helper);
                    }
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({  
                title: $A.get("$Label.c.Service_Summary_Layout_validation_Title"),
                message: $A.get("$Label.c.Service_Summary_Layout_validation"),
                            duration: ' 5000',
                            type: 'error',
                            mode: 'sticky'
                        });
                        toastEvent.fire();
        }   
                
                component.set("v.showspinner", false);
                console.log("layoutList: " + JSON.stringify(component.get("v.layoutList")));
            }

            else {
                component.set("v.showspinner", false);
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },*/ 
    handleProgramsSelect: function (component, event, helper) {
        component.set("v.showspinner", true);
        var remsRecObj = component.get("v.remsObj");
        var selservId = component.get("v.selectedServiceId");
        if (selservId) {
            var ServiceMap = component.get("v.ServMap");
            
            var servName = ServiceMap[selservId]; 
            component.set("v.selectedRecordTypeName", servName);
        } else {
            var selservId = document.querySelector('input[name="options"]:checked').id;
            component.set("v.selectedServiceId", selservId);
        }
        var  recortTypeList = component.get("v.recordTypes");
        for(var item of recortTypeList){
            if(item.value == selservId){
                item.checked = true;
            }
        }
        component.set("v.recordTypes",recortTypeList);
                        component.set("v.showRecodEditform", false);
        component.set("v.showProg", false);
        var emptyList = [];
        component.set("v.layoutList", emptyList);
        component.set("v.activeSections", emptyList);
        var action = component.get("c.getProgramServicelayoutConfig");
        var selSerId = component.get("v.selectedServiceId");
        var programId = component.get('v.programId');
        var ServiceMap = component.get("v.ServMap");
        var servName = ServiceMap[selSerId];
        component.set("v.selectedRecordTypeName", servName);
        component.set("v.selectedServiceName", servName);
        action.setParams({
            "serviceId": selSerId
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                
                let layoutConfigWrap = response.getReturnValue();
                component.set("v.ButtonName", layoutConfigWrap.ButtonName);
                console.log('Chai button-- '+component.get("v.ButtonName")); 
                debugger;
                let layoutConfigList = layoutConfigWrap.layoutSecobjListInfo;
                var remsRecObj = component.get("v.remsObj");
                if (layoutConfigList.length > 0) {
                    
                    component.set("v.showRecodEditform", true);
                    component.set("v.showProg", false);
                    if(!remsRecObj){
                        component.set("v.requestType",null);
                        component.set("v.selectedId",null);
                        }
                    helper.handleLayoutFieldAssignemnt(component, layoutConfigList, remsRecObj, programId, null, true);
                    if (component.get("v.selectedServiceId")) {
                        component.set("v.showNext", true);
                    }
                }else{
                    component.set("v.showRecodEditform", false);
                    if(!remsRecObj){
                     component.set("v.showProg", true);
                        component.set("v.showNext", false);
                    }else{
                        helper.handleParentPrevious(component, event, helper);
                    }
                    var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                title: $A.get("$Label.c.Service_Summary_Layout_validation_Title"),
                message: $A.get("$Label.c.Service_Summary_Layout_validation"),
                duration: ' 5000',
                type: 'error',
                mode: 'sticky'
            });
            toastEvent.fire();
        }   
                
                component.set("v.showspinner", false);
                console.log("layoutList: " + JSON.stringify(component.get("v.layoutList")));
            }

            else {
                component.set("v.showspinner", false);
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    handleParentPrevious: function (component, event, helper) {
        
        var compEvent = component.getEvent("remsServiceEvt");
        compEvent.setParams({
            "isPrevious": "true",
            "childselectedServiceId": component.get("v.selectedServiceId"),
            "childselectedREMSServiceId": component.get("v.selectedREMSServiceId"),
            "childselectedRecordTypeName": component.get("v.selectedRecordTypeName"),
            "childlayoutList": component.get("v.layoutList"),
            "childselectedREMS": component.get("v.remsObj"),
            "childCaseObj": component.get("v.childCaseObj"),
            "caseActiveSections": component.get("v.caseActiveSections"),
            "childrecordTypes": component.get("v.recordTypes"),
            "childselectedId":component.get("v.selectedId"),
            "childreqType":component.get("v.requestType")
        });
        console.log('+++SelId'+component.get("v.selectedId"));
        
        compEvent.fire();
    },

    handleServiceSubmit: function(component, event, helper,participantId){
        console.log('+++In helper');
        var eventFields = event.getParam('fields');
        console.log('+++In submit'+JSON.stringify(eventFields));

        if(participantId && eventFields){
             eventFields['US_WSREMS__Participant__c'] = participantId;
            console.log('+++In submit'+JSON.stringify(eventFields));
        }
        component.find('myServiceform').submit(eventFields);
        component.set("v.showspinner", false);
    },
})