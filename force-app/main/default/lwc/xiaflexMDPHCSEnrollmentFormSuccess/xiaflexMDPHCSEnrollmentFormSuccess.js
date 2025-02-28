import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflexMDP_customcss';
export default class XiaflexMDPHCSEnrollmentFormSuccess extends LightningElement {
    connectedCallback() {
        loadStyle(this, customHomeStyles);
    }
}