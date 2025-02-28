import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/DocumentChecklistItem.Status';
import { getWorkspaceApi } from 'lightning/platformWorkspaceApi';
export default class StatusLinkTab extends NavigationMixin(LightningElement) {
    recordId;
    dciStatus;

    @wire(CurrentPageReference)
    getStateParameters(pageRef) {
        this.recordId = pageRef.state.c__recordId;
    }

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.dciStatus = data.fields.Status.value;
            this.navigateBasedOnStatus();
        } else if (error) {
            console.error('Error fetching status:', error);
        }
    }

    navigateBasedOnStatus() {
        getWorkspaceApi().then((workspace) => {
            if (this.dciStatus === 'New') {
                // Open UiPath in a sub-tab
                workspace.getEnclosingTabId().then((primaryTabId) => {
                    workspace.openSubtab({
                        parentTabId: primaryTabId,
                        url: 'https://cloud.uipath.com/syneoshealth/Test/orchestrator_/tasks/view/4444479',
                        label: 'UiPath Task'
                    });
                });
            } else if (this.dciStatus !== 'Complete') {
                // Open Detail Page as a sub-tab
                workspace.getEnclosingTabId().then((primaryTabId) => {
                    workspace.openSubtab({
                        parentTabId: primaryTabId,
                        url: '/lightning/r/DocumentChecklistItem/' + this.recordId + '/view',
                        label: 'Document Checklist Item'
                    });
                });
            } else {
                console.warn('No navigation action for status:', this.dciStatus);
            }
        });
    }
}