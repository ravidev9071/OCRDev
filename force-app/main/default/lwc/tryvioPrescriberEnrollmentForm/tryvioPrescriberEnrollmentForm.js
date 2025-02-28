import { LightningElement,wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import tryvioIconCheck from '@salesforce/resourceUrl/tryvioIconCheck';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
export default class TryvioPrescriberEnrollmentForm extends LightningElement {
    iconPrescriber = tryvioIconPrescriber;
    iconCheck = tryvioIconCheck;
    presname;
    presnpi;
    recordId;
    @wire(CurrentPageReference)
    CurrentPageReference(pageRef) {
        if (pageRef) {
            this.presname = pageRef.state.c__name;
            this.presnpi = pageRef.state.c__npi;
            this.recordId = pageRef.state.c_id;
        }
    }

    connectedCallback() {
        loadStyle(this, customStyles);
    }

}