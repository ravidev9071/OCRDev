import { LightningElement, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPharmacy from '@salesforce/resourceUrl/tryvioIconPharmacy';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import tryvioIconPatients from '@salesforce/resourceUrl/tryvioIconPatients';
import Phone from '@salesforce/label/c.tryvioPhone';
import Fax from '@salesforce/label/c.tryvioFax';
import { CurrentPageReference } from 'lightning/navigation';
export default class TryvioRemsOppEnrollmentFormSuccess extends LightningElement {   
    iconPharmacy = tryvioIconPharmacy;
    iconPrescriber = tryvioIconPrescriber;
    iconPatients = tryvioIconPatients;
    phone = Phone;
    fax = Fax;
    accountId;
    connectedCallback() {
        loadStyle(this, customStyles);
    }

    downloadEnrollmentPage() {
        console.log('#### Redirecting to the Print download PDF page with accountId :'+this.accountId);
        let fullURL = ""+window.location.href;
        fullURL = fullURL.substring(0,fullURL.lastIndexOf("/s/")+1);
        console.log('fullURL variable:>> ', fullURL);
        window.open(fullURL+"/Tryvio_Outpatient_Enrollment?id="+this.accountId, '_blank');
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.accountId = currentPageReference.state?.id;
       }
    }
}