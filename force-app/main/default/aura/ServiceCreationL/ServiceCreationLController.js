({
    fetchRecordTypes: function (component, event, helper) {
        component.set("v.showspinner", true);
        
        let remsRecObj = component.get("v.remsObj"),
            layoutList = component.get("v.layoutList"),
            docDetId = component.get("v.recievedDetailDocumentId"),
        	recortTypeList = [],
         	programId = component.get('v.programId'),
            recordtypeMap = {},
          	action = component.get("c.getProgramServiceConfigRecordTypeList");
        
        action.setParams({
            "programId": programId
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var selServiceId;
                let recortTypeLst = response.getReturnValue();
              
               // console.log('+++25' + JSON.stringify(recortTypeLst));
                for (let item of recortTypeLst) {
                     var checked = false;
                    if(selServiceId && selServiceId == item.US_WSREMS__Service_API_Name__c){
                        checked = true;
                    }
                    recortTypeList.push({
                        'label': item.US_WSREMS__Service_Name__c, 'value': item.US_WSREMS__Service_API_Name__c,
                        'description': item.US_WSREMS__Description__c, 'isDesciptionAvailable': item.US_WSREMS__Description__c != undefined, 'checked': checked
                    });
                    recordtypeMap[item.US_WSREMS__Service_API_Name__c] = item.US_WSREMS__Service_Name__c;

                }
                component.set("v.recordTypes", recortTypeList);
                component.set("v.ServMap", recordtypeMap);
               	component.set("v.showNewREMS", true);
                component.set("v.showProg", true);
                component.set("v.showRecodEditform", false);
                component.set("v.showspinner", false);
               
                if(remsRecObj['Name'] && remsRecObj['US_WSREMS__Requestor_Type__c']==null ){
                  component.set("v.requestType",remsRecObj['RecordType']['Name']);
                }

                if (remsRecObj['US_WSREMS__Requestor_Type__c']) {
                    let lastIndex = remsRecObj['Id'].lastIndexOf('/') + 1,
                        Id = remsRecObj['Id'].substring(lastIndex);
                    component.set("v.selectedREMSServiceId", Id);
                    remsRecObj['Id'] = Id;
                   
                    if(remsRecObj['US_WSREMS__Participant__c']){
                        component.set("v.selectedId",remsRecObj['US_WSREMS__Participant__c']);
                    }
                    if (remsRecObj['US_WSREMS__REMSProgram__c']) {
                        let proglastIndex = remsRecObj['US_WSREMS__REMSProgram__c'].lastIndexOf('/') + 1
                            progId = remsRecObj['US_WSREMS__REMSProgram__c'].substring(proglastIndex);
                        remsRecObj['US_WSREMS__REMSProgram__c'] = progId;
                        component.set("v.selectedServiceId", remsRecObj['RecordType']['Id']);
                    }
                }
                selServiceId = component.get("v.selectedServiceId");
                if((!remsRecObj) && selServiceId){
                    component.set("v.showNext", true);
                }
        
                if (remsRecObj['US_WSREMS__Requestor_Type__c']) {
                    console.log('+++in RemsIf 8');
                    var lastIndex = remsRecObj['Id'].lastIndexOf('/') + 1;
                    var Id = remsRecObj['Id'].substring(lastIndex);
                    component.set("v.selectedREMSServiceId", Id);
                    remsRecObj['Id'] = Id;
                    if (remsRecObj['US_WSREMS__REMSProgram__c']) {
                        var proglastIndex = remsRecObj['US_WSREMS__REMSProgram__c'].lastIndexOf('/') + 1;
                        var progId = remsRecObj['US_WSREMS__REMSProgram__c'].substring(proglastIndex);
                        remsRecObj['US_WSREMS__REMSProgram__c'] = progId;
                        component.set("v.selectedServiceId", remsRecObj['RecordType']['Id']);

                    }
                    helper.handleProgramsSelect(component, event, helper);
                }
            }

            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);


        if (layoutList) {
            component.set("v.showspinner", true);
            helper.handleLayoutFieldAssignemnt(component, layoutList, remsRecObj, programId,null,false);
        }
    },

    handleProgramSelect: function (component, event, helper) {
        var recortTypeList = component.get("v.recordTypes");
        for (var item of recortTypeList) {
            item.checked = false;
        }
        var selservId = document.querySelector('input[name="options"]:checked').id;
        component.set("v.selectedServiceId", selservId);
        if (selservId) {
        var ServiceMap = component.get("v.ServMap");
        var servName = ServiceMap[selservId];
        component.set("v.selectedRecordTypeName", servName);
            console.log('selectedService Name '+document.querySelector('input[name="options"]:checked').value);
        component.set("v.selectedServiceName",document.querySelector('input[name="options"]:checked').value);
          console.log('selectedService Name 1'+component.get("v.selectedServiceName"));
        }
        helper.handleProgramsSelect(component, event, helper);
    },

    handleError: function (component, event, helper) {
        component.set("v.showspinner", false);
        var prevRems = component.get("v.previousRemsObj");
        var programId = component.get('v.programId');
        var layoutList = component.get("v.layoutList");
        var remsRec = component.get("v.remsObj");
        console.log('+++++remsRec' + JSON.stringify(prevRems));
    },

    handleSave: function (component, event, helper) {
        component.set("v.showspinner", true);
    },

    handleRemsPrevious: function (component, event, helper) {
     
        let remsObj = component.get("v.remsObj");
        if (remsObj) {
           if(remsObj['Name'] && remsObj['US_WSREMS__Requestor_Type__c']==null){
            component.set("v.selectedId",null);
            component.set("v.showRecodEditform", false);
            component.set("v.showProg", true);
            component.set("v.showNext", true);
            //$A.get('e.force:refreshView').fire();

           }
           if (remsObj['US_WSREMS__Requestor_Type__c']) {
            helper.handleParentPrevious(component, event, helper);
           }
        } else {
            component.set("v.showRecodEditform", false);
            component.set("v.showProg", true);
            component.set("v.showNext", true);
        }
        
    },

    handleProgNext: function (component, event, helper) {
        component.set("v.showRecodEditform", true);
        component.set("v.showProg", false);
        component.set("v.showNext", false);
    },
    handleSubmit: function (component, event, helper) {
        event.preventDefault();
        var participantId = component.get("v.selectedId");
        var reqType = component.get("v.requestType");
        component.set("v.showspinner", true);

        if(participantId){

            var action = component.get("c.validateSelectedParticiapant");
                action.setParams({
                    "AccountId": participantId,
                    "requesterType":reqType
                });

                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var validAccount = response.getReturnValue();
                        
                        if(validAccount){
                            helper.handleServiceSubmit(component, event, helper, participantId);
                        }else{
                            var childCmp = component.find('participantId');
                            childCmp.validateParticipant(false); 
                            component.set("v.showspinner", false);
                        }
                    }
                });
                $A.enqueueAction(action);
       
                }else{
                    helper.handleServiceSubmit(component, event, helper, null);
                }
        
    },
    handleSuccess: function (component, event, helper) {
        
        component.set("v.showspinner", true);
        var payload = event.getParams().response;
        component.set("v.selectedREMSServiceId", payload.id);
        var remsId = payload.id;
        

        //Received Document Update
        var action = component.get("c.updateReceivedDetailsDocumentList");

        action.setParams({
            "serviceId": payload.id,
            "receivedDocumentId": component.get("v.recievedDetailDocumentId")
        });
       
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var compEvent = component.getEvent("remsServiceEvt");
                	compEvent.setParams({ "remsServicId": payload.id });
                	compEvent.fire();

                let docDetId = component.get("v.recievedDetailDocumentId"),
                    distId = component.get("v.DistLinkObjId"),
					action = component.get("c.getComponentName"),
					caseValObj = component.get("v.childCaseObj"),
  					acsecObj = component.get("v.caseActiveSections"),
  					progName = component.get("v.programName");
                
                action.setParams({
                    "programName": progName,
                    "recordTypeLabel": '',
                    "feature": "Case Creation"

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
                        console.log('+++136');
                         let docDetId = component.get("v.recievedDetailDocumentId");
                        component.set("v.isEditCase", false);
                        component.set("v.componentName", response.getReturnValue());
                        let componentName = component.get("v.componentName");
                        let dynamicComponentName = componentName;
                        console.log('+++before coponnet create' + docDetId);

                        var selectRSSName = component.get("v.selectedServiceName");
                          console.log('+++136'+selectRSSName);
                        var buttonName = component.get("v.ButtonName");
                        var programName =component.get("v.programName");
						var pharmacyType = component.get("v.radioValue");
                        var reqType = component.get("v.requestType");
                         console.log('+++136'+programName +' >'+component.get("v.programName"));
                        if (selectRSSName == 'Enrollment' && reqType == 'Pharmacy' && programName == 'Macitentan REMS'){
                             buttonName = (pharmacyType == 'Inpatient') ? 'SYN_Inpatient_Pharmacy':'SYN_Outpatient_Pharmacy';
                        } else if (selectRSSName == 'Reenrollment' && reqType == 'Pharmacy' && programName == 'Macitentan REMS'){
                            buttonName = (pharmacyType == 'Inpatient') ? 'Inpatient_Pharmacy_Reenrollment_Form' :'Outpatient_Pharmacy_Reenrollment_Form';
                        }else if(selectRSSName == 'Change Authorized Representative' && programName == 'Sodium Oxybate REMS' ){
                            buttonName='Change_Authorized_Rep';
                            componentName='c:SYN_REMSChangeAuthorizedRep';
                            dynamicComponentName=componentName;
                        }else if(selectRSSName == 'Change of Information' ){
                            buttonName='Change_Of_Information';
                            componentName='c:SYN_ChangeOfInformation';
                            dynamicComponentName=componentName;
                        }else if(selectRSSName == 'Disenrollment.'  ){
                            buttonName='Disenrollment';
                            componentName='c:SYN_Disenrollment';
                            dynamicComponentName=componentName;
                        }
                           console.log('+++136 component'+dynamicComponentName);
                         component.set("v.componentName",dynamicComponentName);
                        try{
                            $A.createComponent(
                                //"docDetailIdVal": docDetId, "recordId": remsId, "distributionlink": distId, "caseObj": caseValObj, "activeSections": acsecObj
                                dynamicComponentName, {
                                    "docDetailIdVal": docDetId,
                                    "caseObj": caseValObj,
                                    "recordId": remsId, 
                                    "activeSections": acsecObj,
                                    "calledByFaxTransfo": true,
                                    "programName" : component.get("v.programName"),
                                    "currREMServiceParticipantId" : component.get("v.selectedId"),
                                    "ButtonName": buttonName
                                },
                                function (newComponent, status, errorMessage) { //Your new created component is stored in the newComponent variable  
                                    component.set("v.dynamicCaseComponentPlaceholder", newComponent);
                                    component.set("v.showNewREMS", false);
                                    component.set("v.showCase", true);
                                    component.set("v.showNewCase", true);
                                    component.set("v.showspinner", false);
                                    console.log('+++in component create'+newComponent);
                                     console.log('+++in component create'+buttonName);
                                    
                                }
                            );
                        } catch(e){
                            debugger;
                            console.log('try catch '+e.message);
                        }
                        
                        
                        console.log('+++199after event fire');
                       /* if (!response.getReturnValue()) {

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
                        
                        component.set("v.isEditCase", false);
                        component.set("v.componentName", response.getReturnValue());
                        let componentName = component.get("v.componentName"),
                        	dynamicComponentName = componentName;
                        
                        $A.createComponent(
                            dynamicComponentName, { "docDetailIdVal": docDetId, "recordId": remsId, "distributionlink": distId, "caseObj": caseValObj, "activeSections": acsecObj },
                            function (newComponent, status, errorMessage) { //Your new created component is stored in the newComponent variable  
                                component.set("v.dynamicCaseComponentPlaceholder", newComponent);
                                component.set("v.showNewREMS", false);
                                component.set("v.showCase", true);
                                component.set("v.showNewCase", true);
                                component.set("v.showspinner", false);
                            }
                        );*/
                    }
                    else {
                        console.log("Failed with state: " + state);
                    }
                });

                $A.enqueueAction(action);

            }
            else {
				console.log("Failed with state: ");
            }
        });
        $A.enqueueAction(action);
    },
	handleRadioChange : function(component, event, helper){
        var radioOption = event.getParam("value");
        component.set("v.radioValue" , radioOption);
    },

    handlePrevious: function (component, event, helper) {
        helper.handleParentPrevious(component, event, helper);
    },

    handleChange: function (component, event, helper) {
        var fieldValue = event.getParam("value");
        var fieldName = event.getSource().get("v.fieldName");
        var remsObj = component.get("v.remsObj");
        var prevRemsObj = component.get("v.previousRemsObj");

        if(fieldName == 'US_WSREMS__Requestor_Type__c'){
            component.set("v.requestType",fieldValue);
			if(fieldValue == 'Pharmacy' && (component.get("v.selectedRecordTypeName") == 'Enrollment' || component.get("v.selectedRecordTypeName") == 'Reenrollment') ){
                component.set("v.showPharmacyType", true);
            }else{
                component.set("v.showPharmacyType", false);
            }
        }
        if (remsObj) {
            remsObj[fieldName] = fieldValue;
            component.set("v.remsObj", remsObj);

        }
    },

    handleNavigation: function (component, message) {
        console.log('Handle Navigation');
        let docDetId = component.get("v.recievedDetailDocumentId"),
            Source = message.getParam("Source"),
            parentId = message.getParam("DocDetailId"),
            caseObj = message.getParam("caseDetails"),
            acSecist = message.getParam("activeSections");
 console.log('Handle Navigation'+docDetId+'  '+parentId+' '+Source);
debugger;
        if (docDetId == parentId) {
            if (Source == 'PreviousClick') {
                component.set("v.showNewREMS", true);
                component.set("v.showNewCase", false);
                component.set("v.childCaseObj", caseObj);
                component.set("v.caseActiveSections", acSecist);
            }
            else if (Source == "NewCase") {
                var remsId = component.get("v.selectedREMSServiceId");
                var workspaceAPI = component.find("workspace");
                var focusedTabId;
                console.log('NewCase'+message.getParam("REMSServiceId"));
                workspaceAPI.openTab({
    				pageReference: {
        			"type": "standard__recordPage",
        			"attributes": {
            			"recordId": message.getParam("REMSServiceId"),
            			"actionName":"view"
        			}
    			},
    			focus: true
				}).then(function(newTabId){
    				workspaceAPI.getEnclosingTabId()
    				.then(function(enclosingTabId) {
        				workspaceAPI.closeTab({tabId : enclosingTabId});
        				workspaceAPI.focusTab(newTabId);
    				});

				});

            } else if (Source == 'CaseColumns') {
                	//console.log('casecoulmns' + JSON.stringify(caseColumns));
                var CaseQueryColumns = message.getParam("CaseColumns");
                component.set("v.caseQueryColumns", CaseQueryColumns);

            }

        }
    },

    handleCaseListView: function (component, event, helper) {
        console.log('handleCaseListView');
        if (component.get("v.isEditCase")) {
            component.set("v.showCase", true);
            component.set("v.showPrevInCaseTab", false);
        } else {

            if (component.get("v.childCaseObj")) {
                component.set("v.showCase", true);
                component.set("v.showPrevInCaseTab", false);
            } else {
                console.log('handleCaseListView-else');
                component.set("v.showCase", false);
                helper.fetchcasecolumns(component);
            }
        }
    },

    handleRowction: function (component, event, helper) {
        console.log('In Handlerowaction');
        let recId = event.getParam("row").Id,
            caseValObj = event.getParam("row"),
            remsId = component.get("v.selectedREMSServiceId"),
            docDetId = component.get("v.recievedDetailDocumentId"),
            componentName = component.get("v.componentName"),
            dynamicComponentName = component.get("v.componentName"),
			distId = component.get("v.DistLinkObjId"),
			acsecObj = component.get("v.caseActiveSections");
        component.set("v.dynamicCaseComponentPlaceholder", null);
        component.set("v.isEditCase", true);
        console.log('case obj'+JSON.stringify(caseValObj));
        $A.createComponent(
            dynamicComponentName, { "recordId": remsId, "docDetailIdVal": docDetId, "distributionlink": distId, "caseObj": caseValObj, "activeSections": acsecObj ,  "calledByFaxTransfo": true,  "ButtonName": component.get("v.ButtonName")},
            function (newComponent, status, errorMessage) { //Your new created component is stored in the newComponent variable  
                component.set("v.dynamicCaseComponentPlaceholder", newComponent);
                component.set("v.showNewREMS", false);
                component.set("v.showNewCase", true);
                component.set("v.showspinner", false);
                component.set("v.showCase", true);
                component.set("v.showPrevInCaseTab", false);
            }
        );

    },

    handleCaseTablePrevious: function (component, event, helper) {
        component.set("v.showNewCase", false);
        component.set("v.showRecodEditform", true);
        component.set("v.showProg", false);
        component.set("v.showNewREMS", true);
    },

    getPrimaryfacility : function(component, event) {
        //get method paramaters
        var params = event.getParam('arguments');
        if (params) {
            var param1 = params.primFacilityId;
            component.set("v.selectedId",param1)
        }
    },

    
    
    
    
    
})