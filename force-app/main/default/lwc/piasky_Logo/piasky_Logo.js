import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/piaSky_homecustomcss'

import PiaSky_Logo from "@salesforce/resourceUrl/PiaSky_HeaderLogo"

export default class Piasky_Logo extends LightningElement {
    piaskylogo = PiaSky_Logo;
    connectedCallback() {
        loadStyle(this, customHomeStyles);
    }
}