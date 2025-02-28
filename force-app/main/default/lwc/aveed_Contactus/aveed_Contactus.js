import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import aveed_Phone from "@salesforce/resourceUrl/aveed_iconPhone";
import aveed_Fax from "@salesforce/resourceUrl/aveed_IconFax";
import contactUs from '@salesforce/resourceUrl/ContactUs';
import Phone from '@salesforce/label/c.AVEED_PhoneNumber';
import Fax from '@salesforce/label/c.AVEED_FaxNumber';
export default class Aveed_Contactus extends LightningElement {
    iconPhone = aveed_Phone;
	iconFax = aveed_Fax;
    label = {
        Phone,
        Fax
    };
  
    connectedCallback() {
        loadStyle(this, customHomeStyles); 
        loadStyle(this, contactUs); 
       
    }
}