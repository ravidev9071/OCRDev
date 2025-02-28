import { LightningElement,api,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import navStyles from '@salesforce/resourceUrl/xiaflex_navcss';
import xiaflex_Logo from "@salesforce/resourceUrl/xiaflex_HeaderLogo";
export default class xiaflex_Navigation extends LightningElement {
    xiaflexlogo = xiaflex_Logo;
    currentUrl;
    homeUrl;
    loginpage;

    connectedCallback() {
        loadStyle(this, customHomeStyles); 
        loadStyle(this,navStyles);
        this.currentUrl = window.location.href;
        this.homeUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s';
        this.loginpage = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'login';
    }
    handlePageopen(event){
         this.currentUrl = window.location.href;
        this.contactusUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s/login-Signup';
        window.open(this.contactusUrl,'_self');
    }
}