({
    doInit: function (component, event, helper) {
        let selectedId = component.get("v.selectedId");
        var action = component.get("c.getObjectDetails");
        component.set("v.returnFields",$A.get("$Label.US_WSREMS.REMSLookupAtrributes").split(","));
        action.setParams({ 'ObjectName': component.get("v.objectAPIName") });
        action.setCallback(this, function (response) {
            var details = response.getReturnValue();
            if (!component.get('v.IconName')) {
                component.set("v.IconName", details.iconName);
            }
            component.set("v.objectLabel", details.label);
            component.set("v.objectLabelPlural", details.pluralLabel);
            if (selectedId == null || selectedId.trim().length <= 0) {
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);

        var actiongetId = component.get("c.getRecordTypeId");
        actiongetId.setParams({
            'objAPIName': component.get("v.objectAPIName"),
            'RecordTypeDeveloperName': component.get("v.recordTypeDeveloperName")
        });
        actiongetId.setCallback(this, function (response) {
            var recordTypeId = response.getReturnValue();
            component.set("v.recordTypeId", recordTypeId);
        });
        $A.enqueueAction(actiongetId);

        var returnFields = component.get("v.returnFields"),
            queryFields = component.get("v.queryFields");

        if (returnFields == null || returnFields.length <= 0) {
            component.set("v.returnFields", ['Name']);
        }

        if (queryFields == null || queryFields.length <= 0) {
            component.set("v.queryFields", ['Name']);
        }

        //help for cancelling the create new record
        //find the latest accessed record for the user
        if (component.get("v.showAddNew")) {
            let action = component.get("c.GetRecentRecords");
            action.setParams({
                'ObjectName': component.get("v.objectAPIName"),
                'ReturnFields': null,
                'MaxResults': 1
            });
            action.setCallback(this, function (response) {
                var results = response.getReturnValue();
                if (results != null && results.length > 0) {
                    component.lastRecordId = results[0].Id;
                }
            });
            $A.enqueueAction(action);
        }
        if (selectedId != null && selectedId.trim().length > 0) {
            var action = component.get("c.GetRecord"),
                returnFields = component.get("v.returnFields");
            action.setParams({
                'ObjectName': component.get("v.objectAPIName"),
                'ReturnFields': returnFields,
                'Id': component.get("v.selectedId")
            });
            action.setCallback(this, function (response) {
                var results = response.getReturnValue();
                results = helper.processResults(results, returnFields);
                component.set("v.selectedName", results[0].Field0);
                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);
        }
    },

    onFocus: function (component, event, helper) {
        var inputBox = component.find("lookup-input-box"),
            searchText = component.get("v.searchText") || '';

        $A.util.addClass(inputBox, 'slds-is-open');
        $A.util.removeClass(inputBox, 'slds-is-close');

        if (component.get("v.showRecent") && searchText.trim() == '') {
            component.set("v.isSearching", true);
            var action = component.get("c.GetRecentRecords"),
                returnFields = component.get("v.returnFields");

            action.setParams({
                'ObjectName': component.get("v.objectAPIName"),
                'ReturnFields': $A.get("$Label.US_WSREMS.REMSLookupAtrributes").split(","),
                'MaxResults': component.get("v.maxResults")
            });
            action.setCallback(this, function (response) {
                var results = response.getReturnValue();
                if (results != null) {
                    component.set("v.statusMessage", results.length > 0 ? null : 'No recent records.');
                    component.set("v.searchResult",
                        helper.processResults(results, returnFields));
                } else {
                       
                    component.set("v.statusMessage", $A.get('$Label.US_WSREMS.Search_Account_Message'));
                }
                component.set("v.isSearching", false);
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.isSearching", true);
            var action = component.get("c.SearchRecords"),
                returnFields = component.get("v.returnFields");
			
            action.setParams({
                'ObjectName': component.get("v.objectAPIName"),
                'ReturnFields': $A.get("$Label.US_WSREMS.REMSLookupAtrributes").split(","),
                'QueryFields': component.get("v.queryFields"),
                'SearchText': searchText,
                'SortColumn': component.get("v.sortColumn"),
                'SortOrder': component.get("v.sortOrder"),
                'MaxResults': component.get("v.maxResults"),
                'Filter': component.get("v.filter"),
                'Label': component.get("v.label"),
                'ProgramId': component.get("v.ProgramId"),
                'requestorType': component.get("v.requestorType")

            });

            action.setCallback(this, function (response) {
                var results = response.getReturnValue();
                if (results != null) {
                    component.set("v.statusMessage", results.length > 0 ? null : 'No records found.');
                    component.set("v.searchResult",
                        helper.processResults(results, returnFields, searchText));
                } else {
                       
                    component.set("v.statusMessage", $A.get('$Label.US_WSREMS.Search_Account_Message'));
                }
                component.set("v.isSearching", false);
            });
            $A.enqueueAction(action);
        }

    },

    onBlur: function (component, event, helper) {
        var inputBox = component.find("lookup-input-box");
        $A.util.addClass(inputBox, 'slds-is-close');
        $A.util.removeClass(inputBox, 'slds-is-open');
        $A.util.removeClass(component.find("lookup-input-box"), 'slds-has-focus');
    },

    onKeyUp: function (component, event, helper) {

        var searchText = component.get('v.searchText');
        //do not repeat the search if nothing changed
        if (component.lastSearchText !== searchText) {
            component.lastSearchText = searchText;
        } else {
            return;
        }

        if (searchText == null || searchText.trim().length < 3) {
            component.set("v.searchResult", []);
            component.set("v.statusMessage", null);
            return;
        }

        component.set("v.isSearching", true);
        var action = component.get("c.SearchRecords"),
            returnFields = component.get("v.returnFields");

        action.setParams({
            'ObjectName': component.get("v.objectAPIName"),
            'ReturnFields': $A.get("$Label.US_WSREMS.REMSLookupAtrributes").split(","),
            'QueryFields': component.get("v.queryFields"),
            'SearchText': searchText,
            'SortColumn': component.get("v.sortColumn"),
            'SortOrder': component.get("v.sortOrder"),
            'MaxResults': component.get("v.maxResults"),
            'Filter': component.get("v.filter"),
            'Label': component.get("v.label"),
            'ProgramId': component.get("v.ProgramId"),
            'requestorType': component.get("v.requestorType")

        });

        action.setCallback(this, function (response) {
            var results = response.getReturnValue();        
            if (results != null) {
                component.set("v.statusMessage", results.length > 0 ? null : 'No records found.');
                component.set("v.searchResult",
                    helper.processResults(results, returnFields, searchText));
            } else {
              	  
                component.set("v.statusMessage", $A.get('$Label.US_WSREMS.Search_Account_Message'));
            }
            component.set("v.isSearching", false);
        });
        $A.enqueueAction(action);

    },

    onSelectItem: function (component, event, helper) {
        var selId = event.currentTarget.dataset.id;
        component.set("v.selectedId", selId);
        var results = component.get("v.searchResult");
        var parentComponent = component.get("v.parent");
        parentComponent.primaryFacilityValues(selId);
        for (var i = 0; i < results.length; i++) {
            if (results[i].Id == selId) {
                component.set("v.selectedName", results[i].Field0.replace("<mark>", "").replace("</mark>", ""));
                break;
            }
        }

        $A.enqueueAction(component.get("c.onBlur"));
    },

    removeSelectedOption: function (component, event, helper) {
        component.set("v.selectedId", null);
        component.set("v.showError",false);
        component.set("v.showParticipantEror",false);
        component.set("v.searchText",'');
    },

    createNewRecord: function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord"),
            objectName = component.get("v.objectAPIName"),
            recordTypeId = component.get("v.recordTypeId"),
            returnFields = component.get("v.returnFields");
        createRecordEvent.setParams({
            "entityApiName": objectName,
            "recordTypeId": recordTypeId,
            "navigationLocation": "LOOKUP",
            "panelOnDestroyCallback": function (event) {
                let action = component.get("c.GetRecentRecords");
                action.setParams({
                    'ObjectName': objectName,
                    'MaxResults': 1,
                    'ReturnFields': returnFields
                });
                action.setCallback(this, function (response) {
                    var records = response.getReturnValue();
                    if (records != null && records.length > 0) {
                        if (records[0].Id != component.lastRecordId) {
                            component.set("v.selectedId", records[0].Id);
                            component.set("v.selectedName", records[0][returnFields[0]]);
                            component.lastRecordId = records[0].Id;
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        });
        createRecordEvent.fire();
    },

    ShowMessage: function (component, event, helper) {
        var inputCmp = component.find('inputCls');
        var params = event.getParam('arguments');
        if (params) {
            var validAcc = params.isValid;
            if (validAcc) {
                inputCmp.set("v.errors", null);
                component.set("v.showError",false);
               component.set("v.showParticipantEror",false);
            } else {
               component.set("v.showError",true);
               component.set("v.showParticipantEror",true);
            }
        }
    }

})