({
    ValidateSelectedRows: function (component, selectedRows) {
        if (selectedRows.length > 0) {
            var lastIndex = selectedRows[0]['Id'].lastIndexOf('/') + 1;
            var selectedRemsId = selectedRows[0]['Id'].substring(lastIndex);
                component.set("v.selectedREMS", selectedRows[0]);
                var lastIndex = selectedRows[0]['US_WSREMS__REMSProgram__c'].lastIndexOf('/') + 1;
                var selectedProgId = selectedRows[0]['US_WSREMS__REMSProgram__c'].substring(lastIndex);
                component.set("v.selectedProgramId", selectedProgId);
                return true;
        }
        return true;
    },

    fetchcasecolumns: function (component, event, helper) {
        var caseColumnAction = component.get("c.getREMSServiceViewConfig");
        var remsId = component.get("v.newRemsId");
        caseColumnAction.setParams(
            { "feature": "CaseViewTable" }
        );
        caseColumnAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var caseColumns = [];
                var caseColRes = response.getReturnValue();
                component.set("v.caseColumns", caseColRes);
                for (var column in caseColRes) {
                    caseColumns.push(caseColRes[column]['fieldName']);
                }

                if (caseColumns) {
                    var caseDataAction = component.get("c.retrieveRemsChildCases");
                    caseDataAction.setParams(
                        {
                            "remsSerId": remsId,
                            "fldsList": caseColumns
                        }
                    );
                    caseDataAction.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var caseColumns = [];
                            var caseDataRes = response.getReturnValue();
                            component.set("v.caseData", caseDataRes)
                        }
                    });
                    $A.enqueueAction(caseDataAction);

                }
            }
        });
        $A.enqueueAction(caseColumnAction);
    },

    createREMS: function (component, event, helper) {
        var selectedRow = component.get("v.selectedREMS");
        component.set("v.showspinner", true);
        if (component.get("v.selectedREMS") || component.get("v.selectedProgramId")) {
            if (selectedRow) {
                if (selectedRow['US_WSREMS__REMSProgram__r'] && component.get("v.selectedProgramId") == null) {
                    component.set("v.selectedProgramId", selectedRow['US_WSREMS__REMSProgram__r']['Id'])
                }
            }
            console.log('Chai prog --'+component.get("v.selectedProgramId"));
            component.set("v.createREMS", true);
            component.set("v.isrecordTypeSelect", false);
            component.set("v.showNewForm", false);
            component.set("v.showAccountSearch", false);
           
            component.set("v.isprogramSelect", false);
        } 
        component.set("v.showspinner", false);
    }

})