import { LightningElement,api, track } from 'lwc';

export default class UipathTab extends LightningElement {
    @api dciStatus;
    @track showLink = false;
    @track showTab = false;
    uipathUrl = 'https://cloud.uipath.com/syneoshealth/Test/orchestrator_/tasks/view/4444479';

    connectedCallback() {
        // Check the DCI status
        if (this.dciStatus === 'Review in OCR') {
            this.showLink = true;
        }
    }

    openTab(event) {
        event.preventDefault();
        this.showTab = true;
    }

    closeTab() {
        this.showTab = false;
    }
}