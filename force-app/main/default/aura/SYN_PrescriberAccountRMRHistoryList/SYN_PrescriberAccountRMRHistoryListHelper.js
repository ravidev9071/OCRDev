({
	setColumns : function(component, event, helper) {
        var cols = [
            {
                'label': 'Prescriber Alert Date',
                'fieldName': 'patientAlertDate',
                'type': 'date',
                'sortable':'true',
                typeAttributes:
                {day:'numeric',month:'numeric',year:'numeric'},
                 cellAttributes: {
                    class: {
                        fieldName: 'PatientAlertDateClass'
                    }
                }
            },
            {
                'label': 'Activity Type',
                'fieldName': 'activityType',
                'type': 'text',
                'sortable':'true',
                 cellAttributes: {
                    class: {
                        fieldName: 'ActivityTypeClass'
                    }
                }
            },
            {
                label: 'Should Prescriber be Monitored?',
                fieldName: 'patientMonitored',
                type: 'text',
                sortable:'true',
                 cellAttributes: {
                    class: {
                        fieldName: 'PatientMonitoredCellClass'
                    }
                }
            },
            {
                label: 'Prescriber Alert Status',
                fieldName: 'patientAlertStatus',
                type: 'text',
                sortable:'true',
                 cellAttributes: {
                    class: {
                        fieldName: 'PatientAlertStatusCellClass'
                    }
                }
            }
        ];
        component.set( 'v.cols', cols );
    },
    setRows : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var action = component.get("c.getRMRAndCOICasesPrescriber"); 
        action.setParams({ prescriberAccountId : recId });
        action.setCallback(this,function(res){
            var state = res.getState();
            if (state === "SUCCESS") {
                var returnResponseList = res.getReturnValue();
                var recordList = [];
                var completeStatusCaseDate = '';
                var completeOutcomeCaseDate = '';
                var createdCaseDate = '';
                for (var i = 0; i < returnResponseList.length; i++ ) {
                    var currentRecord = returnResponseList[i];
                    var record = {};
                    createdCaseDate = '';
                    completeStatusCaseDate = '';
                    completeOutcomeCaseDate = '';
                    //record.patientAlertDate = currentRecord.CreatedDate;
                    if(currentRecord.Histories) {
                        for (var j = 0; j < currentRecord.Histories.length; j++ ) {
                            if(currentRecord.Histories[j].Field == 'US_WSREMS__Outcome__c' && currentRecord.Histories[j].NewValue == 'Complete') {
                                completeOutcomeCaseDate = currentRecord.Histories[j].CreatedDate;
                                break;
                            }
                            if(currentRecord.Histories[j].Field == 'Status' && currentRecord.Histories[j].NewValue == 'Complete') {
                                completeStatusCaseDate = currentRecord.Histories[j].CreatedDate;
                                break;
                            }
                            
                            if(currentRecord.Histories[j].Field == 'created') {
                                createdCaseDate = currentRecord.Histories[j].CreatedDate;
                            }
                            
                        }
                        record.patientAlertDate = createdCaseDate ? createdCaseDate : record.patientAlertDate;
                        record.patientAlertDate = completeStatusCaseDate ? completeStatusCaseDate : record.patientAlertDate;
                        record.patientAlertDate = completeOutcomeCaseDate ? completeOutcomeCaseDate : record.patientAlertDate;
                    }
                    if (currentRecord.RecordType && currentRecord.RecordType.Name) {
                        record.activityType = currentRecord.RecordType.Name;
                        record.activityType = record.activityType == 'Prescriber COI' ? 'Change of Information' : record.activityType;
                    }
                    record.patientMonitored = currentRecord.Should_prescriber_be_monitored__c;
                    record.patientAlertStatus = 'Active';
                    if (record.patientMonitored=="Yes") {
						record.PatientAlertDateClass = "slds-truncate textcolor";
                        record.ActivityTypeClass = "slds-truncate textcolor";
                        record.PatientMonitoredCellClass = "slds-truncate textcolor";
                        record.PatientAlertStatusCellClass = "slds-truncate textcolor";
                    }
                    recordList.push(record);
                }
                // sort by ASC
                recordList = this.sortColumnData(component, recordList, true, 'patientAlertDate');
                recordList = this.populatePatientAlertStatus(component, recordList);
                // sort by DESC
                recordList = this.sortColumnData(component, recordList, false, 'patientAlertDate');
                component.set("v.results", recordList);
                helper.buildData(component, 1);
                var rowres = component.get("v.results");
                var result = rowres.length;
                if(result>0){
                    var paginationCmp = component.find("cPagination");
                    paginationCmp.RefreshPagination();
                }
            }else if (state === "INCOMPLETE") {
            }else if (state === "ERROR") {
                var errors = response.getError();
                console.log( errors );
            }
        });
        $A.enqueueAction(action);
    },
    buildData:  function(component, pageNo) {
        var callList = component.get("v.results");
        var noOfCalls = component.get("v.noOfCallsToBeShown");
        var callListToBeShown = [];
        for(var i=(pageNo-1)*noOfCalls; i<(pageNo*noOfCalls); i++) {
            if(callList[i]) {
                callListToBeShown.push(callList[i]);
            }
        }
        component.set('v.rows', callListToBeShown);
         
    },
    sortColumnData: function(component,recordList,isSortAsc,sortingField) {
        recordList.sort(function(a, b){
            var s1 = a[sortingField] == b[sortingField];
            var s2 = (!a[sortingField] && b[sortingField]) || (a[sortingField] < b[sortingField]);
            return s1? 0: (isSortAsc?-1:1)*(s2?1:-1);
        });
        return recordList;
    },
    populatePatientAlertStatus : function(component,recordList) {
        for (var i = 0; i < recordList.length; i++ ) {
            if(i == 0) {
                recordList[i].patientAlertStatus = recordList[i].patientMonitored == 'No' ? 'Inactive' : 'Active';
            } else {
                recordList[i].patientAlertStatus = recordList[i-1].patientAlertStatus == 'Inactive' && recordList[i].patientMonitored == 'Yes' ? 'Active' : 'Inactive';
                recordList[i].patientAlertStatus = recordList[i-1].patientAlertStatus == 'Active' ? 'Active' : recordList[i].patientAlertStatus;
                recordList[i].patientAlertStatus = recordList[i-1].patientAlertStatus == 'Active' && recordList[i].activityType == 'Change of Information' && recordList[i].patientMonitored == 'No' ? 'Inactive' : recordList[i].patientAlertStatus;
            }
        }
        return recordList;
    }
})