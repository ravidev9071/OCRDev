import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';

export default class Xiaflex_pharmaHCSEnrollmentForm_success extends LightningElement {

     connectedCallback() {
        loadStyle(this, customHomeStyles);
    }

}