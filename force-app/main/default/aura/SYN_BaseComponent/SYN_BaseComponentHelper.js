({
    callServerAction: function (component, functionName, params, successCallback, spinnerId) {
        this.startSpinner(component, true, spinnerId);
        var serverAction = component.get(functionName);
        if (!$A.util.isEmpty(params)) {
            serverAction.setParams(params);
        }
        serverAction.setCallback(this, function (result) {
            var responseState = result.getState();
            if (component.isValid() && responseState === "SUCCESS") {
                var response = result.getReturnValue();
                successCallback(response);
            }
            else if (component.isValid() && responseState === "ERROR") {
                this.processErrors(component, this, result);
                this.stopSpinner(component, true, spinnerId);
            }
        });
        $A.enqueueAction(serverAction);
    },

    sortColumns: function (component, event, helper) {
        var tableName = event.getSource().getLocalId();
        var dataTable = component.find(event.getSource().getLocalId());
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);
        dataTable.set("v.data",
            helper.postSortProcessing(helper.sortData(
                helper.preSortProcessing(dataTable.get("v.data"), tableName),
                fieldName,
                sortDirection
            ), tableName)
        );
    },

    preSortProcessing: function (data, tableName) {
        return data;
    },

    postSortProcessing: function (data, tableName) {
        return data;
    },
    sortData: function (data, fieldName, sortDirection) {
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        return data;
    },

    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function (x) { return primer(x[field]) }
            : function (x) { return x[field] };

        return function (a, b) {
            var A = key(a) ? key(a) : '';
            var B = key(b) ? key(b) : '';
            return reverse * ((A > B) - (B > A));
        };
    },

    openOverlayModal: function (component, header, body, footerBtnList, theme, showClose, modalId) {
        if ($A.get("$Browser.isTablet")) {
            theme += " slds-modal_large";
        }
        var helper = this;
        $A.createComponent("c:CustomModalFooter", {
            modalFooterButtonDetailList: footerBtnList
        }, function (footerComponent, status) {
            if (status === "SUCCESS") {
                ////console.log("SUCCESS!!!");
                component.find('overlayLib').showCustomModal({
                    header: header,
                    showCloseButton: showClose,
                    body: body,
                    footer: footerComponent,
                    cssClass: "texture " + theme
                });
            }
        });
    },

    startSpinner: function (component, isParent, spinnerId) {
        if (isParent) {
            $A.util.removeClass(component.find(spinnerId), 'slds-hide');
        } else {
            component.getEvent("SpinnerEvent").set({ on: "true" }).fire();
        }
    },

    stopSpinner: function (component, isParent, spinnerId) {
        if (isParent) {
            $A.util.addClass(component.find(spinnerId), 'slds-hide');
        } else {
            component.getEvent("SpinnerEvent").set({ off: "true" }).fire();
        }
    },

    showToast: function (component, variant, title, message, messageData, mode) {
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "messageData": messageData,
            "mode": mode,
            "variant": variant
        });
    },

    closeTab: function (component) {
        var device = $A.get("$Browser.formFactor");
        if (device == 'DESKTOP') {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({ tabId: focusedTabId });
            })
                .catch(function (error) {
                    console.log(error);
                });
        } else {
            window.history.back();
        }
    },

    getProperty: function (data, path) {
        ////console.log(data);
        var tokens = path.split(".");
        var obj = data;
        for (var i = 0; i < tokens.length; i++) {
            if (obj) {
                obj = obj[tokens[i]];
            } else {
                return null;
            }
        }
        return obj;
    },

    processErrors: function (component, helper, response) {
        console.log(JSON.stringify(response.getError()));
        var errors = response.getError();
        helper.showErrorMessage(component, helper, errors);
    },

    showErrorMessage: function (component, helper, errors) {
        if (errors) {
            if (errors[0] && errors[0].fieldErrors) {
                console.log(errors[0]);
                for (var key in errors[0].fieldErrors) {
                    if (errors[0].fieldErrors[key] && errors[0].fieldErrors[key][0]) {
                        helper.showToast(component, "error", "Validation!", errors[0].fieldErrors[key][0].message, null, "dismissible");
                    }
                }
            }

            if (errors[0] && errors[0].pageErrors) {
                console.log(errors[0].pageErrors);
                for (var ind = 0; ind < errors[0].pageErrors.length; ind++) {
                    helper.showToast(component, "error", "Validation!", errors[0].pageErrors[ind].message, null, "dismissible");
                }
            }

            if (errors[0] && errors[0].message) {
                console.log(errors[0].message);
                helper.showToast(component, "error", "Validation!", errors[0].message, null, "dismissible");
            }

        }
    }

})