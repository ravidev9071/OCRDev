import { LightningElement } from 'lwc';
import Phone from '@salesforce/label/c.AVEED_PhoneNumber';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
export default class Aveed_SignUpConfirmation extends LightningElement {
    label = {
        Phone
    };
    connectedCallback() {
        loadStyle(this, customHomeStyles); 
    }
}