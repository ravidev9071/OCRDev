({
	getLayoutSections : function(component) {
		var ob= component.get("v.objectName");
        var ly= component.get("v.layoutName");
         var caseRec = component.get("v.caseObj");
         var docDetId =component.get("v.docDetailIdVal");
         if(caseRec){
                if(caseRec['Id']){
                var lastIndex = caseRec['Id'].lastIndexOf('/') + 1;
                var Id = caseRec['Id'].substring(lastIndex);
                component.set("v.caseId",Id);
                }
            }
         var columnList = [];
        var action = component.get("c.getPageLayoutFields");
        action.setParams({ layoutName : ly });
		action.setCallback(this, function(response) {
        	var state = response.getState();
			if (state === "SUCCESS") {
                var sectionList = [];
                var layoutSec = response.getReturnValue();
                 if(response.getReturnValue().length>0){
                    for(var sec in layoutSec){
                         sectionList.push(layoutSec[sec]['label']);
                        for(var fld in  layoutSec[sec]['lstFields']){
                            if(layoutSec[sec]['lstFields'][fld]['fieldName']){
                                columnList.push(layoutSec[sec]['lstFields'][fld]['fieldName']);
                                if(layoutSec[sec]['lstFields'][fld]['fieldName'] == 'US_WSREMS__REMSProgram__c')
                                layoutSec[sec]['lstFields'][fld]['fieldValue'] = programId;
                                var fieldName = layoutSec[sec]['lstFields'][fld]['fieldName'];
                                if(caseRec){
                                    layoutSec[sec]['lstFields'][fld]['fieldValue'] = caseRec[fieldName];
                                }
                            }
                        }
                    }
                    component.set("v.activeSections", sectionList);
                    component.set("v.layoutSections", layoutSec );
                 var dynamicAttribute = {
                        "DocDetailId": docDetId,
                        "Source":"CaseColumns",
                        "CaseColumns":columnList
                    };
                    component.find("REMSReviewDocumentChannel").publish(dynamicAttribute);
                 }
                var result=response.getReturnValue();
                
                var strname=[];
                if (result != null) {
                    
                    var listLength = result.length;
                    for (var i=0; i < listLength; i++) {
                        strname.push(result[i].label);
                        
                    }
                }
                
                component.set("v.activeSections",strname );
                component.set("v.layoutSections", response.getReturnValue() );
                   
                if (component.get("v.OAffliation") && component.get("v.OAffliation").US_WSREMS__Pharmacy_User__c) {
                    let layoutSections = component.get("v.layoutSections"),
                        layoutSectionsString = JSON.stringify(layoutSections),
                        action = component.get("c.getRelatedFieldsForPharmacyUser");
                    action.setParams({ existingLaoutSectionString : layoutSectionsString,
                                    pharmacyUserId : component.get("v.OAffliation").US_WSREMS__Pharmacy_User__c,
                                    onLoadOnly : true,
                                    recordId : component.get("v.recordId")
                                 });
                    action.setCallback(this, function(response) {
                        let state = response.getState();
                        if (state === "SUCCESS") {
                            component.set("v.layoutSections", response.getReturnValue() );
                                   
                            
                        } 
                        else if (state === "ERROR") {
                            let errors = response.getError();
                            console.log( errors );
                        }
                        if (component.get("v.pharmacy")) {
                            let layoutSections = component.get("v.layoutSections"),
                                layoutSectionsString = JSON.stringify(layoutSections),
                                action = component.get("c.getRelatedFieldsForPharmacy"),
                                pharmacyValue = component.get("v.pharmacy");
                    
                            action.setParams({ existingLaoutSectionString : layoutSectionsString,
                                                pharmacyId : pharmacyValue
                                             });
                            action.setCallback(this, pharmacyResponse => {
                                let state = pharmacyResponse.getState();
                                if (state === "SUCCESS") {
                                    let returnedValue = pharmacyResponse.getReturnValue();
                                    component.set("v.layoutSections", pharmacyResponse.getReturnValue() );
                                } 
                                else if (state === "ERROR") {
                                    let errors = pharmacyResponse.getError();
                                    console.log( errors );
                                }
                            });
                            $A.enqueueAction(action);
                        }
                    });
                    $A.enqueueAction(action);
                } else if (component.get("v.pharmacy")) {
                    let layoutSections = component.get("v.layoutSections"),
                        layoutSectionsString = JSON.stringify(layoutSections),
                        action = component.get("c.getRelatedFieldsForPharmacy"),
                        pharmacyValue = component.get("v.pharmacy");
            
                    action.setParams({ existingLaoutSectionString : layoutSectionsString,
                                        pharmacyId : pharmacyValue
                                     });
                    action.setCallback(this, pharmacyResponse => {
                        let state = pharmacyResponse.getState();
                        if (state === "SUCCESS") {
                            let returnedValue = pharmacyResponse.getReturnValue();
                            component.set("v.layoutSections", pharmacyResponse.getReturnValue() );
                        } 
                        else if (state === "ERROR") {
                            let errors = pharmacyResponse.getError();
                            console.log( errors );
                        }
                    });
                    $A.enqueueAction(action);
                }

                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
				console.log( errors );
            }
        });
        $A.enqueueAction(action);
	},
    getObjectAPIName : function(component) {
		var recordId= component.get("v.recordId");
        
        var action = component.get("c.getObjectAPIName");
        action.setParams({ recordId : recordId });
		action.setCallback(this, function(response) {
        	var state = response.getState();
			if (state === "SUCCESS") {
                var objectAPIName = response.getReturnValue();
                if(objectAPIName == 'Case'){
                    component.set("v.programRecordType" , returnedValue.programRecordType);
                    component.set("v.CaseId", recordId);
                    component.set("v.launchedFromCase", true);
                }
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
				console.log( errors );
            }
        });
        
        $A.enqueueAction(action);
	},

    getNameSpa : function(component){
    
        var action = component.get("c.getNameSpace");
        action.setCallback(this, function (response) {
            if(response.getReturnValue()){
                let responseValue = response.getReturnValue();
                 component.set("v.nameSpaceStr",responseValue);
                 let namespcstring = responseValue.includes('__') ?  responseValue.slice(0, -2) : responseValue;
                let affiliationType = $A.get(`$Label.${namespcstring}.Affiliation_User_Type_value`);
                component.set('v.affiliationType',affiliationType);
                /*component.set("v.programRecordType" , returnedValue.programRecordType);*/
            }else{
                component.set("v.nameSpaceStr",'');
            }
          });
        $A.enqueueAction(action);
    }
})