({
    initHelper : function (component, event) {
        component.set("v.recordId", component.get('v.pageReference').state.c__recordId);
        component.set("v.selectedProgramId", component.get('v.pageReference').state.c__programId);
        component.set("v.showspinner", true);
        component.set("v.selectedProgramName", component.get('v.pageReference').state.c__programName);
        let programList = [];
        var progMap = {};
        var action = component.get("c.retrieveFilesOnDocumentDetail");
        action.setParams({
            "parentObjId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
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
                            var fieldName = accFldRes['acSearchConfigList'][acc]['US_WSREMS__Field_Name__c'];
                           
                            if (fieldName == 'US_WSREMS__REMS_Program__c') {
                                accFldRes['acSearchConfigList'][acc]['fieldValue'] = component.get("v.selectedProgramId");
                            }
                            var options = [];
                            if (accFldRes['acSearchConfigList'][acc]['US_WSREMS__DataType__c'] == 'Combobox') {
                                for (var key in pickMap[fieldName]) {
                                    options.push({ "label": pickMap[fieldName][key]['label'], "value": pickMap[fieldName][key]['value'] })
                                }
                                accFldRes['acSearchConfigList'][acc]['US_WSREMS__Picklist_values__c'] = options;
                            }
                        }
                        component.set("v.accFieldList", accFldRes['acSearchConfigList']);
                        component.set("v.showspinner", false);
                    }
                });
                $A.enqueueAction(accConfigaction);
    },

})