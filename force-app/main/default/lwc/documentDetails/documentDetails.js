import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = ['DocumentChecklistItem.Status'];

export default class DocumentDetails extends LightningElement {
    @api recordId;
    dciStatus;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    recordHandler({ error, data }) {
        if (data) {
            this.dciStatus = data.fields.Status.value;
        } else if (error) {
            console.error(error);
        }
    }

    handleCheckStatus() {
        if (this.dciStatus === 'New') {
            window.open('https://cloud.uipath.com/syneoshealth/Test/orchestrator_/tasks/view/4444479', '_self');
        }
    }
}