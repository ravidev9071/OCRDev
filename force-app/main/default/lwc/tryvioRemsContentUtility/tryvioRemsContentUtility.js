import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
/* import tryvioIconPharmacy from '@salesforce/resourceUrl/tryvioIconPharmacy';
import tryvioIconPrecriber from '@salesforce/resourceUrl/tryvioIconPrecriber';
import tryvioIconPatients from '@salesforce/resourceUrl/tryvioIconPatients';
import Phone from '@salesforce/label/c.tryvioPhone';
import Fax from '@salesforce/label/c.tryvioFax'; */
export default class TryvioRemsContentUtility extends LightningElement {   
   /*  iconPharmacy = tryvioIconPharmacy;
    iconPrescriber = tryvioIconPrecriber;
    iconPatients = tryvioIconPatients;
    phone = Phone;
    fax = Fax; */
    connectedCallback() {
        loadStyle(this, customStyles);
    }
}