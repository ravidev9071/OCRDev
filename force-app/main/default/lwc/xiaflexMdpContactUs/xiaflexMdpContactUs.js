import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflexMDP_customcss';
import xiaflex_Phone from "@salesforce/resourceUrl/xiaflex_iconPhone";
import xiaflex_Fax from "@salesforce/resourceUrl/xiaflex_IconFax";
import xiaflex_Email from "@salesforce/resourceUrl/xiaflex_IconEmail";
import Phone from '@salesforce/label/c.xiaflex_PhonePortal';
import Fax from '@salesforce/label/c.xiaflex_MDP_Fax_Portal';
import MailingAddress from '@salesforce/label/c.xiaflex_MailingAddressPortal';


export default class XiaflexMdpContactUs extends LightningElement {
    iconPhone = xiaflex_Phone;
	iconFax = xiaflex_Fax;
    iconEmail = xiaflex_Email;
    phone = Phone;
    fax = Fax;
    mailingAddress = MailingAddress;
  
    connectedCallback() {
        loadStyle(this, customHomeStyles); 
    }
}