import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import aveed_logo from "@salesforce/resourceUrl/aveed_logo";
export default class Aveed_HCP_Header extends LightningElement {
    logo = aveed_logo;
    connectedCallback() {
        loadStyle(this, customHomeStyles);        
    }
}