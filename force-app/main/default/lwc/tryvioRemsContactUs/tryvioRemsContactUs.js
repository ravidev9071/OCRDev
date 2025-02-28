import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconContactUs from '@salesforce/resourceUrl/tryvioIconContactUs';
import tryvioIconPhone from '@salesforce/resourceUrl/tryvioIconPhone';
import tryvioIconFax from '@salesforce/resourceUrl/tryvioIconFax';
import Phone from '@salesforce/label/c.tryvioPhone';
import Fax from '@salesforce/label/c.tryvioFax';
export default class TryvioRemsContactUs extends LightningElement {
    iconContactUs = tryvioIconContactUs;
    iconPhone = tryvioIconPhone;
    iconFax = tryvioIconFax;
    phone = Phone;
    fax = Fax;

    connectedCallback() {
        loadStyle(this, customStyles);
    }
}