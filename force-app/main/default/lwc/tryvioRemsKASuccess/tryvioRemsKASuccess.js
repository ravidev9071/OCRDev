import { LightningElement, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
export default class TryvioRemsKASuccess extends NavigationMixin(LightningElement) {
    iconPrescriber = tryvioIconPrescriber;
    name;
    npi;
    recordid;
    @wire(CurrentPageReference)
    CurrentPageReference(pageRef) {
        if (pageRef) {
            this.presname = pageRef.state.c__name;
            this.presnpi = pageRef.state.c__npi;
            this.recordId = pageRef.state.c_id;
            console.log('recordid', this.recordId);
        }
    }
    connectedCallback() {
        loadStyle(this, customStyles);
    }

    handleContinue(event) {
        try {
            event.preventDefault();
            event.stopPropagation();
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Prescriber_Enrollment_Form__c'
                }, state: {
                    c__name: this.presname,
                    c__npi: this.presnpi,
                    c__id: this.recordId
                }
            });
        } catch (error) {
            console.log('error --' + error.message);
        }
    }
}