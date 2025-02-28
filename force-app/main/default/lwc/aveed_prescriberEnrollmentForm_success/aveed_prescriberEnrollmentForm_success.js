import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';

export default class Aveed_prescriberEnrollmentForm_success extends LightningElement {
    connectedCallback() {
        loadStyle(this, customHomeStyles); 
       
    }
}