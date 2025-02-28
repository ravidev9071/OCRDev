import { LightningElement,api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

import PiaSky_Logo from "@salesforce/resourceUrl/PiaSky_HeaderLogo"
import PiaSky_Arrow from "@salesforce/resourceUrl/PiaSky_iconArrowRight"
import PiaSky_email from "@salesforce/resourceUrl/PiaSky_iconemail"
import PiaSky_fax from "@salesforce/resourceUrl/PiaSky_iconfax"
import PiaSky_phone from "@salesforce/resourceUrl/PiaSky_iconphone"
import customHomeStyles from '@salesforce/resourceUrl/piaSky_homecustomcss'

export default class PiaSky_MainHomePage extends LightningElement {
		piaskylogo = PiaSky_Logo;
		piaskyArrow = PiaSky_Arrow;
		piaskyemail = PiaSky_email;
		piaskyfax = PiaSky_fax;
		piaskyphone = PiaSky_phone;

 		@api pageName;
		homepage = false;
		contactUs = false;

		connectedCallback() {
        loadStyle(this, customHomeStyles); 
		
		if(this.pageName == 'Home'){
			this.homepage = true;
		}

		if(this.pageName == 'contactUs'){
			this.contactUs = true;
		}
		}
}