import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPharmacy from '@salesforce/resourceUrl/tryvioIconPharmacy';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import tryvioIconPatients from '@salesforce/resourceUrl/tryvioIconPatients';
import Phone from '@salesforce/label/c.tryvioPhone';
import Fax from '@salesforce/label/c.tryvioFax';
export default class TryvioRemsFooter extends LightningElement {   
    iconPharmacy = tryvioIconPharmacy;
    iconPrescriber = tryvioIconPrescriber;
    iconPatients = tryvioIconPatients;
    phone = Phone;
    fax = Fax;
    connectedCallback() {
        loadStyle(this, customStyles);
    }
}