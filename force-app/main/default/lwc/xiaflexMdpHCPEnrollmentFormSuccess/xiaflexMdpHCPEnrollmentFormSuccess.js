import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStylesMdp from '@salesforce/resourceUrl/xiaflexMDP_customcss';
export default class XiaflexMdpHCPEnrollmentFormSuccess extends LightningElement {
    connectedCallback(){
        loadStyle(this, customHomeStylesMdp);  
    }
}