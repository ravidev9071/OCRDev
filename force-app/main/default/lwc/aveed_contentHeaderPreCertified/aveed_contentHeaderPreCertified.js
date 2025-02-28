import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import navStyles from '@salesforce/resourceUrl/aveed_navcss';
import navigationStyles from '@salesforce/resourceUrl/aveed_navigation';
import iconCreateDown from "@salesforce/resourceUrl/aveed_iconcreateDown";
import aveed_logo from "@salesforce/resourceUrl/aveed_logo";
export default class Aveed_contentHeaderPreCertified extends LightningElement {
    logo = aveed_logo;
    iconCreate = iconCreateDown;
    connectedCallback() {
        loadStyle(this, customHomeStyles); 
        loadStyle(this, navStyles); 
        loadStyle(this, navigationStyles);         
    }
}