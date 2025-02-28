import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import aveed_HCP from "@salesforce/resourceUrl/aveed_iconHCP";
import aveed_HCS from "@salesforce/resourceUrl/aveed_iconHCS";
import navStyles from '@salesforce/resourceUrl/aveed_navcss';
export default class Aveed_main extends LightningElement {
    iconHCP = aveed_HCP;
	iconHCS = aveed_HCS;
    connectedCallback() {
        loadStyle(this, customHomeStyles); 
        loadStyle(this, navStyles); 
    }
}