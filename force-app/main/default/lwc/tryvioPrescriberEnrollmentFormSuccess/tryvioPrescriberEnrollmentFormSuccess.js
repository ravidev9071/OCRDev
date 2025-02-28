import { LightningElement,wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import tryvioIconCheck from '@salesforce/resourceUrl/tryvioIconCheck';
import { CurrentPageReference } from 'lightning/navigation';
export default class TryvioPrescriberEnrollmentFormSuccess extends LightningElement {
    iconPrescriber = tryvioIconPrescriber;
    iconCheck = tryvioIconCheck;
    presname;
    presnpi;
    showindicator=false;
    accountId
    @wire(CurrentPageReference)
    CurrentPageReference(pageRef) {
        if (pageRef) {
            this.presname = pageRef.state.c__name;
            this.presnpi = pageRef.state.c__npi;
            this.accountId = pageRef.state.c__id;
        }
    }
    connectedCallback() {
        loadStyle(this, customStyles);
    }

    downloadEnrollmentPage() {
        console.log('#### Redirecting to the Print download PDF page with accountId :'+this.accountId);
        let fullURL = ""+window.location.href;
        fullURL = fullURL.substring(0,fullURL.lastIndexOf("/s/")+1);
        console.log('fullURL variable:>> ', fullURL);
        window.open(fullURL+"/Tryvio_Prescriber_Enrollment?id="+this.accountId, '_blank');
    }
}